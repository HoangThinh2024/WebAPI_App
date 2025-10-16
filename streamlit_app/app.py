"""Streamlit application for exploring Base.vn candidate data."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, Mapping, Optional, ContextManager, cast

import requests
import streamlit as st

from api_client import (
    fetch_candidate_detail as _fetch_candidate_detail_raw,
    fetch_candidate_messages as _fetch_candidate_messages_raw,
    fetch_candidates as _fetch_candidates_raw,
    fetch_openings_list as _fetch_openings_list_raw,
)
from config_manager import (
    ENV_PATH,
    get_default_num_per_page,
    load_env_values,
    save_env_values,
)
from data_processor import process_candidate_data
from ui.components import (
    render_candidate_detail_view,
    render_candidate_list,
    render_candidate_messages_view,
    render_metrics,
)


def _handle_api_response(response: requests.Response) -> Dict[str, Any]:
    """Convert requests.Response to dict with success/error keys."""
    try:
        response.raise_for_status()
        data = response.json()
        return {"success": True, "data": data}
    except requests.RequestException as e:
        return {"success": False, "error": str(e)}
    except Exception as e:
        return {"success": False, "error": f"Unexpected error: {str(e)}"}


def fetch_openings_list(access_token: str) -> Dict[str, Any]:
    """Wrapper for fetch_openings_list that returns dict."""
    response = _fetch_openings_list_raw(access_token)
    return _handle_api_response(response)


def fetch_candidates(access_token: str, filters: Dict[str, Any]) -> Dict[str, Any]:
    """Wrapper for fetch_candidates that returns dict."""
    response = _fetch_candidates_raw(
        access_token,
        filters.get("opening_id", ""),
        filters.get("page", 1),
        filters.get("num_per_page", 10),
        filters.get("stage", ""),
    )
    return _handle_api_response(response)


def fetch_candidate_detail(access_token: str, candidate_id: str) -> Dict[str, Any]:
    """Wrapper for fetch_candidate_detail that returns dict."""
    response = _fetch_candidate_detail_raw(access_token, candidate_id)
    return _handle_api_response(response)


def fetch_candidate_messages(access_token: str, candidate_id: str) -> Dict[str, Any]:
    """Wrapper for fetch_candidate_messages that returns dict."""
    response = _fetch_candidate_messages_raw(access_token, candidate_id)
    return _handle_api_response(response)

st.set_page_config(page_title="Base.vn Candidate Explorer", page_icon="📊", layout="wide")


def _as_context_manager(obj: object) -> ContextManager[Any]:
    if not (hasattr(obj, "__enter__") and hasattr(obj, "__exit__")):
        raise TypeError(f"Object {obj!r} is not a context manager")
    return cast(ContextManager[Any], obj)


def ensure_session_defaults() -> None:
    if "active_tab" not in st.session_state:
        st.session_state.active_tab = "filters"
    if "openings_raw" not in st.session_state:
        st.session_state.openings_raw = []
    if "candidate_results" not in st.session_state:
        st.session_state.candidate_results = None
    if "latest_candidate_filters" not in st.session_state:
        st.session_state.latest_candidate_filters = {}
    if "selected_candidate_id" not in st.session_state:
        st.session_state.selected_candidate_id = None


def render_page_header() -> None:
    st.title("Base.vn Candidate Explorer 📊")
    st.markdown("Công cụ tra cứu và quản lý ứng viên từ Base.vn API.")


def render_config_section() -> Dict[str, Any]:
    st.subheader("Cấu hình API")
    env_values = load_env_values()
    access_token = st.text_input(
        "Access Token (bắt buộc)",
        value=env_values.get("ACCESS_TOKEN", ""),
        type="password",
        key="access_token_input",
    )
    default_num_per_page = get_default_num_per_page(env_values)
    num_per_page = st.number_input(
        "Số ứng viên trên một trang (mặc định)",
        min_value=1,
        max_value=500,
        value=default_num_per_page,
        key="num_per_page_input",
    )
    if st.button("Lưu cấu hình", key="save_config_btn"):
        new_values = {
            "ACCESS_TOKEN": access_token,
            "DEFAULT_NUM_PER_PAGE": str(num_per_page),
        }
        save_env_values(new_values)
        st.success(f"Đã lưu cấu hình vào {ENV_PATH}")
        st.rerun()
    return env_values


def render_access_token_form(env_values: Dict[str, Any]) -> Optional[str]:
    access_token_value = st.session_state.get("access_token_input") or env_values.get("ACCESS_TOKEN") or ""
    if not access_token_value:
        st.info("Vui lòng nhập **Access Token** ở trên và nhấn **Lưu cấu hình**.")
        return None
    return access_token_value


def handle_opening_fetch(access_token: str) -> bool:
    if st.button("🔄 Lấy danh sách Openings", key="fetch_openings_btn"):
        with st.spinner("Đang lấy danh sách openings..."):
            openings_response = fetch_openings_list(access_token)
            if openings_response.get("success"):
                st.session_state.openings_raw = openings_response.get("data", [])
                st.success(f"Đã lấy được {len(st.session_state.openings_raw)} opening(s).")
                return True
            else:
                error_msg = openings_response.get("error", "Lỗi không xác định")
                st.error(f"Lỗi khi lấy openings: {error_msg}")
                return False
    return False


def render_candidate_filters(access_token: str) -> None:
    st.subheader("Bộ lọc ứng viên")
    openings = st.session_state.get("openings_raw", [])
    opening_options = {op["id"]: op.get("name", "No name") for op in openings if isinstance(op, dict) and "id" in op}
    if not opening_options:
        st.warning("Chưa có dữ liệu opening. Hãy nhấn 'Lấy danh sách Openings' ở trên.")
        return

    selected_opening_id = st.selectbox(
        "Chọn Opening",
        options=list(opening_options.keys()),
        format_func=lambda x: f"{x} - {opening_options[x]}",
        key="opening_id_select",
    )
    if not selected_opening_id:
        st.info("Vui lòng chọn một opening để tiếp tục.")
        return

    selected_opening = next((op for op in openings if op.get("id") == selected_opening_id), {})
    stages = selected_opening.get("stages", [])
    stage_options = {s["id"]: s.get("name", "No name") for s in stages if isinstance(s, dict) and "id" in s}

    stage_id_value: Optional[str] = None
    if stage_options:
        stage_id_value = st.selectbox(
            "Chọn Stage",
            options=list(stage_options.keys()),
            format_func=lambda x: f"{x} - {stage_options[x]}",
            key="stage_id_select",
        )
    else:
        st.warning("Không có stage nào. Vui lòng nhập Stage ID thủ công nếu cần.")
        stage_id_value = st.text_input("Nhập Stage ID (nếu có)", key="stage_id_manual")

    page = st.number_input("Trang (bắt đầu từ 1)", min_value=1, value=1, key="page_input")
    env_values = load_env_values()
    num_per_page_filter = st.number_input(
        "Số ứng viên trên trang",
        min_value=1,
        max_value=500,
        value=get_default_num_per_page(env_values),
        key="num_per_page_filter",
    )

    if st.button("🔍 Tìm kiếm ứng viên", key="fetch_candidates_btn"):
        filters = {
            "opening_id": selected_opening_id,
            "stage": stage_id_value if stage_id_value else "",
            "page": page,
            "num_per_page": num_per_page_filter,
        }
        with st.spinner("Đang tìm kiếm ứng viên..."):
            candidate_response = fetch_candidates(access_token, filters)
            if candidate_response.get("success"):
                st.session_state.candidate_results = candidate_response
                st.session_state.latest_candidate_filters = filters
                st.success("Tìm kiếm thành công!")
            else:
                error_msg = candidate_response.get("error", "Lỗi không xác định")
                st.error(f"Lỗi khi tìm kiếm ứng viên: {error_msg}")


def fetch_candidates_with_proxy(access_token: str, filters: Dict[str, Any]) -> Dict[str, Any]:
    proxy_url = "http://127.0.0.1:8000/candidates"
    headers = {"Content-Type": "application/json"}
    body = {
        "access_token": access_token,
        "opening_id": filters.get("opening_id", ""),
        "stage_id": filters.get("stage", ""),
        "page": filters.get("page", 1),
        "num_per_page": filters.get("num_per_page", 10),
    }
    try:
        response = requests.post(proxy_url, json=body, headers=headers, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        return {"success": False, "error": str(e)}


def render_candidate_modal(candidate_id: str, access_token: str) -> None:
    candidate_response = fetch_candidate_detail(access_token, candidate_id)
    messages_response = fetch_candidate_messages(access_token, candidate_id)

    # Use dialog if available (Streamlit 1.50+), otherwise use expander
    try:
        dialog_ctx = st.dialog(f"Chi tiết ứng viên #{candidate_id}")
        with _as_context_manager(dialog_ctx):
            tab_detail, tab_messages = st.tabs(["Thông tin chi tiết", "Tin nhắn"])
            with tab_detail:
                if candidate_response.get("success"):
                    render_candidate_detail_view(candidate_response.get("data", {}))
                else:
                    error_msg = candidate_response.get("error", "Lỗi không xác định")
                    st.error(f"Lỗi khi lấy chi tiết ứng viên: {error_msg}")

            with tab_messages:
                if messages_response.get("success"):
                    render_candidate_messages_view(messages_response.get("data", {}))
                else:
                    error_msg = messages_response.get("error", "Lỗi không xác định")
                    st.error(f"Lỗi khi lấy tin nhắn: {error_msg}")
    except AttributeError:
        # Fallback to expander if dialog is not available
        with st.expander(f"Chi tiết ứng viên #{candidate_id}", expanded=True):
            tab_detail, tab_messages = st.tabs(["Thông tin chi tiết", "Tin nhắn"])
            with tab_detail:
                if candidate_response.get("success"):
                    render_candidate_detail_view(candidate_response.get("data", {}))
                else:
                    error_msg = candidate_response.get("error", "Lỗi không xác định")
                    st.error(f"Lỗi khi lấy chi tiết ứng viên: {error_msg}")

            with tab_messages:
                if messages_response.get("success"):
                    render_candidate_messages_view(messages_response.get("data", {}))
                else:
                    error_msg = messages_response.get("error", "Lỗi không xác định")
                    st.error(f"Lỗi khi lấy tin nhắn: {error_msg}")


def render_filter_summary() -> None:
    filters = st.session_state.get("latest_candidate_filters", {})
    if not filters:
        return
    st.markdown("**Bộ lọc hiện tại:**")
    filter_summary = f"Opening ID: `{filters.get('opening_id')}`, Stage ID: `{filters.get('stage')}`, Trang: `{filters.get('page')}`, Số lượng: `{filters.get('num_per_page')}`"
    st.markdown(filter_summary)


def render_candidate_results(access_token: str) -> None:
    st.subheader("Kết quả tìm kiếm")
    results = st.session_state.get("candidate_results")
    if not results:
        st.info("Chưa có kết quả nào. Hãy tìm kiếm ứng viên ở trên.")
        return

    render_filter_summary()
    data = results.get("data", {})
    processed = process_candidate_data(data)
    metrics = processed["metrics"]
    df = processed["dataframe"]

    render_metrics(metrics)
    st.divider()

    selected_candidate_id = render_candidate_list(df)
    if selected_candidate_id:
        st.session_state.selected_candidate_id = selected_candidate_id
        render_candidate_modal(selected_candidate_id, access_token)


def render_cached_candidate_results(access_token: str) -> None:
    st.subheader("Kết quả đã lưu")
    if st.session_state.candidate_results:
        render_filter_summary()
        data = st.session_state.candidate_results.get("data", {})
        processed = process_candidate_data(data)
        metrics = processed["metrics"]
        df = processed["dataframe"]

        render_metrics(metrics)
        st.divider()

        selected_candidate_id = render_candidate_list(df)
        if selected_candidate_id:
            st.session_state.selected_candidate_id = selected_candidate_id
            render_candidate_modal(selected_candidate_id, access_token)
    else:
        st.info("Chưa có kết quả nào được lưu.")


def main() -> None:
    ensure_session_defaults()
    render_page_header()

    with st.sidebar:
        env_values = render_config_section()
        st.divider()
        access_token = render_access_token_form(env_values)
        if not access_token:
            st.stop()

        st.divider()
        handle_opening_fetch(access_token)

    tab_filters, tab_results = st.tabs(["Bộ lọc", "Kết quả"])
    with tab_filters:
        render_candidate_filters(access_token)

    with tab_results:
        render_candidate_results(access_token)


if __name__ == "__main__":
    main()

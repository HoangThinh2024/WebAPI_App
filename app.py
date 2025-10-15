"""Streamlit application for exploring Base.vn candidate data."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, Mapping, Optional

import requests
import streamlit as st

from api_client import (
    fetch_candidate_detail,
    fetch_candidate_messages,
    fetch_candidates,
    fetch_openings_list,
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


class SimpleResp:
    """Lightweight response adapter for proxy responses."""

    def __init__(self, status_code: int, json_data: Mapping[str, Any], text: str) -> None:
        self.status_code = status_code
        self._json = json_data
        self.text = text

    def json(self) -> Mapping[str, Any]:
        return self._json


def ensure_session_defaults() -> None:
    """Guarantee required session state keys exist."""
    defaults = {
        "openings": {},
        "selected_candidate_id": None,
        "show_candidate_modal": False,
        "last_access_token": "",
        "use_proxy_toggle": False,
        "latest_candidates_payload": None,
        "latest_candidates_status": None,
        "latest_candidates_text": "",
        "latest_candidate_filters": {},
    }
    for key, value in defaults.items():
        st.session_state.setdefault(key, value)


def render_page_header(env_values: Mapping[str, str]) -> None:
    st.title("🎯 Ứng dụng Truy vấn Base.vn")
    st.caption("Theo dõi ứng viên, xem chi tiết và lịch sử trao đổi một cách trực quan.")

    status_placeholder = st.empty()
    if ENV_PATH.exists():
        status_placeholder.success(
            f"Đã nạp {len(env_values)} biến cấu hình từ `{ENV_PATH.name}`"
        )
    else:
        status_placeholder.warning(
            "Chưa tìm thấy file `.env`. Hãy cấu hình token và thông số để tạo mới."
        )
    st.markdown("---")


def render_config_section(env_values: Dict[str, str]) -> Dict[str, str]:
    with st.expander("⚙️ Cấu hình (.env)", expanded=not ENV_PATH.exists()):
        with st.form("config_form"):
            st.write(
                "Nhập token và các tham số mặc định. Giá trị sẽ được lưu vào file `.env` (không commit)."
            )
            token_input = st.text_input(
                "BASE_TOKEN",
                value=env_values.get("BASE_TOKEN", ""),
                help="Access token được cấp bởi Base.vn",
            )
            opening_input = st.text_input(
                "OPENING_ID",
                value=env_values.get("OPENING_ID", ""),
                help="ID vị trí tuyển dụng mặc định",
            )
            stage_input = st.text_input(
                "STAGE_ID",
                value=env_values.get("STAGE_ID", ""),
                help="Stage mặc định khi truy vấn",
            )
            num_per_page_default = get_default_num_per_page(env_values)
            num_per_page_input = st.number_input(
                "NUM_PER_PAGE",
                min_value=1,
                max_value=100,
                value=num_per_page_default,
            )
            submitted = st.form_submit_button("💾 Lưu vào .env")

        if submitted:
            try:
                env_values = save_env_values(
                    {
                        "BASE_TOKEN": token_input,
                        "OPENING_ID": opening_input,
                        "STAGE_ID": stage_input,
                        "NUM_PER_PAGE": str(num_per_page_input),
                    }
                )
                st.success("Đã cập nhật file .env thành công. Đảm bảo file này không được commit.")
            except Exception as exc:  # pragma: no cover - streamlit UI feedback
                st.error(f"Không thể lưu .env: {exc}")
    return env_values


def render_access_token_form(env_values: Mapping[str, str]) -> tuple[str, bool]:
    with st.form("access_token_form"):
        st.subheader("🔑 Tham số API")
        access_token = st.text_input(
            "Access Token",
            value=env_values.get("BASE_TOKEN", ""),
            help="Token để gọi Base.vn API",
        )
        load_openings = st.form_submit_button("🔄 Tải danh sách Opening & Stage")
    return access_token, load_openings


def handle_opening_fetch(load_openings: bool, access_token: str) -> None:
    if not load_openings:
        return
    if not access_token:
        st.warning("Vui lòng nhập Access Token trước khi tải danh sách opening.")
        return

    with st.spinner("Đang tải danh sách openings..."):
        try:
            response = fetch_openings_list(access_token, page=1, num_per_page=100)
            if response.status_code != 200:
                st.error(f"Lỗi API: {response.status_code} - {response.text}")
                return
            data = response.json()
            openings = data.get("openings", []) or []
            if not openings:
                st.warning("Không tìm thấy opening nào.")
                return

            opening_options = {}
            for opening in openings:
                key = f"{opening.get('id')} - {opening.get('name', 'N/A')}"
                opening_options[key] = opening
            st.session_state["openings"] = opening_options
            st.success(f"✅ Đã tải {len(openings)} openings")
        except Exception as exc:  # pragma: no cover - network feedback
            st.error(f"Gặp lỗi khi lấy danh sách openings: {exc}")


def render_candidate_filters(
    opening_options: Mapping[str, Mapping[str, Any]],
    env_values: Mapping[str, str],
    default_num_per_page: int,
) -> tuple[bool, Dict[str, Any]]:
    with st.form("candidate_query_form"):
        st.subheader("🗂️ Lọc danh sách ứng viên")
        col1, col2 = st.columns(2)

        with col1:
            if opening_options:
                selected_opening_key = st.selectbox(
                    "🎯 Chọn Opening",
                    options=list(opening_options.keys()),
                    help="Chọn vị trí tuyển dụng",
                )
                selected_opening = opening_options[selected_opening_key]
                opening_id = str(selected_opening.get("id"))

                stages = selected_opening.get("stages", [])
                if stages:
                    stage_options = {
                        f"{stage.get('id')} - {stage.get('name', 'N/A')}": stage.get("id")
                        for stage in stages
                    }
                    selected_stage_key = st.selectbox(
                        "📊 Chọn Stage",
                        options=list(stage_options.keys()),
                        help="Giai đoạn tuyển dụng",
                    )
                    stage_id = str(stage_options[selected_stage_key])
                else:
                    stage_id = st.text_input(
                        "Stage ID",
                        value=env_values.get("STAGE_ID", ""),
                        help="Opening này chưa có stage, nhập thủ công",
                    )
            else:
                st.info("👆 Nhấn 'Tải danh sách Opening & Stage' để hiển thị lựa chọn.")
                opening_id = st.text_input(
                    "Opening ID",
                    value=env_values.get("OPENING_ID", ""),
                )
                stage_id = st.text_input(
                    "Stage ID",
                    value=env_values.get("STAGE_ID", ""),
                )

            page = st.number_input("Trang (page)", min_value=1, value=1)

        with col2:
            num_per_page = st.number_input(
                "Số lượng mỗi trang",
                min_value=1,
                max_value=100,
                value=default_num_per_page,
            )
            use_proxy = st.checkbox(
                "🔄 Sử dụng Proxy Server Local",
                value=st.session_state.get("use_proxy_toggle", False),
                help="Bật để chuyển hướng request qua proxy FastAPI nội bộ.",
            )

        submitted = st.form_submit_button("🚀 Gửi yêu cầu API")

    params = {
        "opening_id": opening_id.strip(),
        "stage_id": stage_id.strip(),
        "page": int(page),
        "num_per_page": int(num_per_page),
        "use_proxy": use_proxy,
    }
    return submitted, params


def fetch_candidates_with_proxy(
    access_token: str,
    payload: Dict[str, Any],
) -> SimpleResp:
    proxy_url = os.getenv("LOCAL_PROXY_URL", "http://127.0.0.1:8000/candidates")
    proxy_resp = requests.post(proxy_url, data={**payload, "access_token": access_token})
    if proxy_resp.status_code == 200:
        proxy_json = proxy_resp.json()
        return SimpleResp(200, proxy_json.get("raw", {}), json.dumps(proxy_json))
    return SimpleResp(proxy_resp.status_code, {}, proxy_resp.text)


def render_candidate_modal(access_token: str) -> None:
    if not (st.session_state.get("show_candidate_modal") and access_token):
        return

    candidate_id = st.session_state.get("selected_candidate_id")
    if not candidate_id:
        return

    use_proxy = st.session_state.get("use_proxy_toggle", False)

    detail_data: Optional[Mapping[str, Any]] = None
    message_data: Optional[Mapping[str, Any]] = None
    detail_error: Optional[str] = None
    message_error: Optional[str] = None

    try:
        if use_proxy:
            base_url = os.getenv("LOCAL_PROXY_URL", "http://127.0.0.1:8000")
            detail_resp = requests.post(
                f"{base_url}/candidate/{candidate_id}",
                params={"access_token": access_token},
            )
        else:
            detail_resp = fetch_candidate_detail(access_token, candidate_id)

        if detail_resp.status_code == 200:
            detail_data = detail_resp.json()
        else:
            detail_error = f"Không thể lấy chi tiết ứng viên (mã {detail_resp.status_code})."
    except Exception as exc:  # pragma: no cover - network feedback
        detail_error = str(exc)

    try:
        if use_proxy:
            base_url = os.getenv("LOCAL_PROXY_URL", "http://127.0.0.1:8000")
            message_resp = requests.post(
                f"{base_url}/candidate/{candidate_id}/messages",
                params={"access_token": access_token},
            )
        else:
            message_resp = fetch_candidate_messages(access_token, candidate_id)

        if message_resp.status_code == 200:
            message_data = message_resp.json()
        else:
            message_error = f"Không thể lấy tin nhắn (mã {message_resp.status_code})."
    except Exception as exc:  # pragma: no cover - network feedback
        message_error = str(exc)

    modal_fn = getattr(st, "modal", None)
    dialog_fn = getattr(st, "dialog", None)

    def _render_modal_contents(show_fallback_header: bool) -> None:
        if show_fallback_header:
            st.markdown("---")
        if detail_error:
            st.error(detail_error)
        else:
            render_candidate_detail_view(detail_data or {})

        st.markdown("---")

        if message_error:
            st.error(message_error)
        else:
            render_candidate_messages_view(message_data or {})

        with st.expander("JSON chi tiết"):
            cols = st.columns(2)
            with cols[0]:
                st.caption("Candidate Detail")
                st.json(detail_data or {})
            with cols[1]:
                st.caption("Candidate Messages")
                st.json(message_data or {})

        if st.button("Đóng", use_container_width=True):
            st.session_state["show_candidate_modal"] = False
            st.session_state["selected_candidate_id"] = None
            rerun = getattr(st, "rerun", None) or getattr(st, "experimental_rerun")
            rerun()

    modal_title = f"📁 Ứng viên #{candidate_id}"
    context_manager = None

    if callable(modal_fn):
        potential_ctx = modal_fn(modal_title)
        if hasattr(potential_ctx, "__enter__") and hasattr(potential_ctx, "__exit__"):
            context_manager = potential_ctx
    if context_manager is None and callable(dialog_fn):
        potential_ctx = dialog_fn(modal_title)
        if hasattr(potential_ctx, "__enter__") and hasattr(potential_ctx, "__exit__"):
            context_manager = potential_ctx

    if context_manager is not None:
        with context_manager:
            _render_modal_contents(False)
    else:
        if callable(modal_fn) or callable(dialog_fn):
            st.warning(
                "Phiên bản Streamlit hiện tại không hỗ trợ context manager cho modal/dialog. Nội dung sẽ hiển thị trực tiếp."
            )
        st.markdown(f"### 📁 Ứng viên #{candidate_id}")
        st.caption(
            "Chế độ modal không khả dụng trong phiên bản Streamlit hiện tại. Hiển thị nội dung ngay trên trang."
        )
        with st.container():
            _render_modal_contents(True)


def render_filter_summary() -> None:
    """Display current filter context for clarity."""
    filters = st.session_state.get("latest_candidate_filters") or {}
    if not isinstance(filters, Mapping):
        filters = {}

    opening_id = filters.get("opening_id") or st.session_state.get("opening_id")
    stage_id = filters.get("stage_id") or filters.get("stage")
    page = filters.get("page")
    per_page = filters.get("num_per_page")
    candidate_id = st.session_state.get("selected_candidate_id")

    summary_parts = []
    if opening_id:
        summary_parts.append(f"**Opening ID:** `{opening_id}`")
    if stage_id:
        summary_parts.append(f"**Stage ID:** `{stage_id}`")
    if page:
        summary_parts.append(f"**Page:** `{page}`")
    if per_page:
        summary_parts.append(f"**Per Page:** `{per_page}`")
    if candidate_id:
        summary_parts.append(f"**Candidate ID đã chọn:** `{candidate_id}`")

    if summary_parts:
        st.markdown(" • ".join(summary_parts))


def render_candidate_results(
    response: SimpleResp,
) -> None:
    st.subheader("📋 Kết quả ứng viên")
    st.write(f"**Mã trạng thái:** `{response.status_code}`")
    render_filter_summary()

    st.session_state["latest_candidates_status"] = response.status_code
    st.session_state["latest_candidates_text"] = getattr(response, "text", "")

    if response.status_code != 200:
        st.session_state["latest_candidates_payload"] = None
        st.error(f"API trả về lỗi {response.status_code}")
        st.code(response.text, language="text")
        return

    json_data = response.json()
    st.session_state["latest_candidates_payload"] = json_data
    processed = process_candidate_data(json_data)

    render_metrics(processed["metrics"])

    selected_id = render_candidate_list(processed["dataframe"])
    if selected_id:
        st.session_state["selected_candidate_id"] = selected_id
        st.session_state["show_candidate_modal"] = True

    with st.expander("Xem JSON phản hồi thô"):
        st.json(json_data)


def render_cached_candidate_results() -> None:
    """Render previously fetched candidates stored in session state."""
    status = st.session_state.get("latest_candidates_status")
    if status is None:
        return

    payload = st.session_state.get("latest_candidates_payload")
    text = st.session_state.get("latest_candidates_text", "")
    if not isinstance(payload, Mapping):
        payload = {}

    cached_response = SimpleResp(status, payload, text)
    render_candidate_results(cached_response)


def main() -> None:
    st.set_page_config(page_title="Base.vn Candidate Explorer", layout="wide")

    ensure_session_defaults()
    env_values = load_env_values()
    default_num_per_page = get_default_num_per_page(env_values)

    render_page_header(env_values)
    env_values = render_config_section(env_values)

    access_token, load_openings = render_access_token_form(env_values)
    handle_opening_fetch(load_openings, access_token)

    opening_options = st.session_state.get("openings", {})
    submitted, filters = render_candidate_filters(opening_options, env_values, default_num_per_page)

    rendered_new_results = False
    if submitted:
        if not access_token:
            st.warning("Vui lòng nhập Access Token để gửi yêu cầu.")
        else:
            st.session_state["use_proxy_toggle"] = filters["use_proxy"]
            st.session_state["last_access_token"] = access_token
            st.session_state["latest_candidate_filters"] = dict(filters)

            payload = {
                "opening_id": filters["opening_id"],
                "page": filters["page"],
                "num_per_page": filters["num_per_page"],
                "stage": filters["stage_id"],
            }

            st.info("Đang gửi yêu cầu và xử lý dữ liệu...")
            try:
                if filters["use_proxy"]:
                    response = fetch_candidates_with_proxy(access_token, payload)
                else:
                    response = fetch_candidates(
                        access_token,
                        payload["opening_id"],
                        payload["page"],
                        payload["num_per_page"],
                        payload["stage"],
                    )
                render_candidate_results(response)
                rendered_new_results = True
            except ConnectionError as exc:  # pragma: no cover - network feedback
                st.error(str(exc))
            except json.JSONDecodeError:
                st.error("Lỗi giải mã JSON. API có thể đã trả về dữ liệu không hợp lệ.")

    if not rendered_new_results:
        render_cached_candidate_results()

    render_candidate_modal(st.session_state.get("last_access_token", ""))


if __name__ == "__main__":
    main()

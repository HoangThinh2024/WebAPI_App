"""Reusable Streamlit UI components for the Base.vn candidate app."""

from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, Iterable, Optional

import pandas as pd
import streamlit as st


def _format_timestamp(value: Any) -> str:
    """Convert timestamp-like value to human readable string."""
    if value in (None, "", 0, "0"):
        return "-"
    try:
        ts = int(value)
        if ts <= 0:
            return "-"
        return datetime.fromtimestamp(ts).strftime("%d/%m/%Y %H:%M")
    except (ValueError, TypeError):
        return "-"


def _format_text(value: Any, default: str = "-") -> str:
    if value in (None, ""):
        return default
    return str(value)


def _render_badges(items: Iterable[Any]) -> str:
    items = items or []
    if not items:
        return "<span class='candidate-label muted'>Không có</span>"
    tags_html = "".join(
        f"<span class='candidate-badge'>{_format_text(item.get('name') if isinstance(item, dict) else item)}</span>"
        for item in items
    )
    return tags_html


def render_metrics(metrics: Dict[str, Any]) -> None:
    """Render top-level metrics cards."""
    col_total, col_count, col_page = st.columns(3)
    col_total.metric("Tổng số ứng viên", metrics.get("total"))
    col_count.metric("Số lượng trên trang", metrics.get("count"))
    col_page.metric("Trang hiện tại", metrics.get("page"))


def render_candidate_list(df: pd.DataFrame) -> Optional[str]:
    """Render candidate cards with action button per row.

    Returns the candidate ID selected by the user, if any.
    """
    if df.empty:
        st.warning("Không tìm thấy ứng viên nào.")
        return None

    st.markdown(
        """
        <style>
        .candidate-item {background:#ffffff; border:1px solid #e2e8f0; border-radius:14px; padding:1.1rem; margin-bottom:0.75rem; box-shadow:0 1px 3px rgba(15,23,42,0.08);} 
        .candidate-item:hover {border-color:#94a3b8; box-shadow:0 2px 6px rgba(15,23,42,0.12);} 
        .candidate-name {font-size:1.05rem; font-weight:600; color:#0f172a; margin-bottom:0.15rem;} 
        .candidate-sub {color:#475569; font-size:0.9rem;} 
        .candidate-meta {color:#334155; font-size:0.85rem; margin-top:0.4rem;} 
        .candidate-actions {text-align:right;} 
        .candidate-pill {display:inline-flex; align-items:center; gap:0.3rem; padding:0.2rem 0.65rem; background:#f1f5f9; border-radius:999px; font-size:0.8rem; color:#1e293b;} 
        </style>
        """,
        unsafe_allow_html=True,
    )

    selected_id: Optional[str] = None
    for _, row in df.iterrows():
        candidate_id = _format_text(row.get("ID"))
        name = _format_text(row.get("Họ & Tên"))
        stage = _format_text(row.get("Giai đoạn"))
        source = _format_text(row.get("Nguồn"))
        opening = _format_text(row.get("Vị trí ứng tuyển"))
        email = _format_text(row.get("Email"))
        phone = _format_text(row.get("SĐT"))
        cv_link = row.get("CV Link")

        with st.container():
            st.markdown("<div class='candidate-item'>", unsafe_allow_html=True)
            info_col, action_col = st.columns([4, 1])
            with info_col:
                st.markdown(
                    f"<div class='candidate-name'>{name}</div>"
                    f"<div class='candidate-sub'>ID: {candidate_id} · Stage: {stage}</div>",
                    unsafe_allow_html=True,
                )
                st.markdown(
                    f"<div class='candidate-meta'>Vị trí: {opening}</div>"
                    f"<div class='candidate-meta'>Nguồn: {source}</div>"
                    f"<div class='candidate-meta'>Email: {email} · SĐT: {phone}</div>",
                    unsafe_allow_html=True,
                )
                if cv_link and cv_link != "Không có":
                    st.markdown(f"<div class='candidate-meta'><a href='{cv_link}' target='_blank'>📄 CV</a></div>", unsafe_allow_html=True)
            with action_col:
                st.markdown("<div class='candidate-actions'>", unsafe_allow_html=True)
                if st.button(
                    f"#{candidate_id}",
                    key=f"view_{candidate_id}",
                    use_container_width=True,
                ):
                    selected_id = candidate_id
                st.markdown(
                    f"<div class='candidate-pill'>{stage}</div>",
                    unsafe_allow_html=True,
                )
                st.markdown("</div>", unsafe_allow_html=True)
            st.markdown("</div>", unsafe_allow_html=True)

    return selected_id


def render_candidate_detail_view(json_data: Dict[str, Any]) -> None:
    """Render detailed view for a single candidate."""
    candidate: Dict[str, Any] = {}
    if isinstance(json_data, dict):
        candidate = json_data.get("candidate") or {}
        if not candidate and isinstance(json_data.get("data"), dict):
            data_section = json_data["data"]
            candidate = data_section.get("candidate") or data_section if isinstance(data_section, dict) else {}
    if not candidate or not isinstance(candidate, dict):
        st.info("Không tìm thấy dữ liệu ứng viên.")
        return

    opening_info = candidate.get("opening_export", {}) or {}
    stage_name = candidate.get("stage_name") or opening_info.get("stage_name") or "Chưa xác định"
    time_apply = _format_timestamp(candidate.get("time_apply"))

    st.markdown(
        """
        <style>
        .candidate-card {background-color:#f8fafc; border:1px solid #e2e8f0; border-radius:16px; padding:1.5rem; margin-bottom:1rem;}
        .candidate-header {display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:0.5rem;}
        .candidate-title {font-size:1.4rem; font-weight:600; color:#0f172a; margin:0;}
        .candidate-subtitle {font-size:0.95rem; color:#475569;}
        .candidate-badge {display:inline-block; padding:0.25rem 0.75rem; border-radius:999px; background:#e0f2fe; color:#0369a1; font-size:0.8rem; margin:0.15rem 0.4rem 0.15rem 0;}
        .candidate-label {font-weight:600; color:#0f172a;}
        .candidate-label.muted {color:#94a3b8; font-weight:500;}
        .candidate-section {margin-top:1.35rem;}
        .candidate-section h4 {margin-bottom:0.6rem; color:#1e293b;}
        .candidate-divider {margin:1.3rem 0; border-top:1px dashed #cbd5f5;}
        </style>
        """,
        unsafe_allow_html=True,
    )

    with st.container():
        st.markdown("<div class='candidate-card'>", unsafe_allow_html=True)
        header_cols = st.columns([3, 2])
        with header_cols[0]:
            st.markdown(
                f"<div class='candidate-header'>"
                f"<div><p class='candidate-title'>{_format_text(candidate.get('disp_name') or candidate.get('name'))}</p>"
                f"<p class='candidate-subtitle'>ID: {_format_text(candidate.get('id'))} · Stage: {stage_name}</p></div>"
                f"</div>",
                unsafe_allow_html=True,
            )
        with header_cols[1]:
            metric_cols = st.columns(2)
            metric_cols[0].metric("Đánh giá", _format_text(candidate.get("score", "0")))
            metric_cols[1].metric("Trạng thái", _format_text(candidate.get("status", "default")))

        st.markdown("<div class='candidate-divider'></div>", unsafe_allow_html=True)

        st.markdown("<div class='candidate-section'><h4>Thông tin liên hệ</h4></div>", unsafe_allow_html=True)
        contact_cols = st.columns(3)
        contact_cols[0].markdown(f"**Email**\n\n{_format_text(candidate.get('email'))}")
        contact_cols[1].markdown(f"**Điện thoại**\n\n{_format_text(candidate.get('phone'))}")
        contact_cols[2].markdown(f"**Ngày sinh**\n\n{_format_text(candidate.get('dob'))}")

        st.markdown("<div class='candidate-divider'></div>", unsafe_allow_html=True)

        st.markdown("<div class='candidate-section'><h4>Thông tin bổ sung</h4></div>", unsafe_allow_html=True)
        extra_cols = st.columns(3)
        gender_label = candidate.get("gender_text") or {
            "0": "Nữ",
            "1": "Nam",
            "2": "Khác",
            "-1": "Không xác định",
        }.get(str(candidate.get("gender")), "Không xác định")
        extra_cols[0].markdown(f"**Giới tính**\n\n{_format_text(gender_label)}")
        extra_cols[1].markdown(f"**Địa chỉ**\n\n{_format_text(candidate.get('address'))}")
        extra_cols[2].markdown(f"**Nguồn**\n\n{_format_text(candidate.get('source'))}")

        st.markdown("<div class='candidate-divider'></div>", unsafe_allow_html=True)

        st.markdown("<div class='candidate-section'><h4>Thông tin tuyển dụng</h4></div>", unsafe_allow_html=True)
        opening_cols = st.columns(4)
        opening_cols[0].markdown(f"**Vị trí**\n\n{_format_text(opening_info.get('name'))}")
        opening_cols[1].markdown(f"**Mã vị trí**\n\n{_format_text(opening_info.get('codename'))}")
        opening_cols[2].markdown(f"**Stage ID**\n\n{_format_text(candidate.get('stage_id'))}")
        opening_cols[3].markdown(f"**Thời gian nộp**\n\n{time_apply}")

        st.markdown("<div class='candidate-divider'></div>", unsafe_allow_html=True)

        st.markdown("<div class='candidate-section'><h4>Hồ sơ & nhãn</h4></div>", unsafe_allow_html=True)
        cvs = candidate.get("cvs") or []
        if cvs:
            for idx, cv in enumerate(cvs, start=1):
                url = cv if isinstance(cv, str) else cv.get("url") if isinstance(cv, dict) else None
                if url:
                    st.markdown(f"- [CV {idx}]({url})")
                else:
                    st.markdown(f"- CV {idx}: {_format_text(cv)}")
        else:
            st.markdown("<span class='candidate-label muted'>Chưa có CV đính kèm</span>", unsafe_allow_html=True)

        tags = candidate.get("tags") or []
        st.markdown("**Tags**")
        st.markdown(_render_badges(tags), unsafe_allow_html=True)

        timelines = candidate.get("timelines") or []
        changelogs = candidate.get("changelogs") or []
        if timelines or changelogs:
            st.markdown("<div class='candidate-divider'></div>", unsafe_allow_html=True)
            st.markdown("<div class='candidate-section'><h4>Lịch sử cập nhật</h4></div>", unsafe_allow_html=True)
            if changelogs:
                for log in changelogs:
                    log_time = _format_timestamp(log.get("since"))
                    st.markdown(
                        f"- **{_format_text(log.get('name'))}**\n\n  · Thời gian: {log_time}"
                    )
            if timelines:
                for timeline in timelines:
                    timeline_time = _format_timestamp(timeline.get("created_at") or timeline.get("time"))
                    title = timeline.get("title") or timeline.get("description")
                    st.markdown(f"- {_format_text(title)} ({timeline_time})")

        st.markdown("</div>", unsafe_allow_html=True)


def _extract_messages(payload: Any) -> tuple[list[Dict[str, Any]], Dict[str, Any]]:
    """Best-effort extraction of messages and their metadata from varied payload shapes."""
    if isinstance(payload, list):
        return payload, {}

    if not isinstance(payload, dict):
        return [], {}

    key_priority = ["messages", "data", "results", "items", "records", "threads"]
    meta: Dict[str, Any] = {}

    for key in key_priority:
        value = payload.get(key)
        if isinstance(value, list):
            meta = {k: v for k, v in payload.items() if k != key}
            return value, meta
        if isinstance(value, dict):
            sub_messages, sub_meta = _extract_messages(value)
            if sub_messages:
                meta = {k: v for k, v in payload.items() if k != key}
                meta.update({k: v for k, v in sub_meta.items() if k not in meta})
                return sub_messages, meta

    return [], {k: v for k, v in payload.items() if k not in key_priority}


def render_candidate_messages_view(json_data: Dict[str, Any]) -> None:
    """Render structured view for candidate messages."""
    messages, meta = _extract_messages(json_data)
    if not messages:
        st.info("Không có tin nhắn để hiển thị.")
        return

    filters = st.session_state.get("latest_candidate_filters", {}) if hasattr(st, "session_state") else {}
    selected_candidate_id = st.session_state.get("selected_candidate_id") if hasattr(st, "session_state") else None

    opening_id_value = (meta.get("opening_id") if isinstance(meta, dict) else None) or filters.get("opening_id")
    stage_id_value = (meta.get("stage_id") if isinstance(meta, dict) else None) or filters.get("stage_id") or filters.get("stage")
    candidate_id_value = (meta.get("candidate_id") if isinstance(meta, dict) else None) or selected_candidate_id

    st.markdown(
        """
        <style>
        .message-card {background:#ffffff; border:1px solid #e2e8f0; border-radius:14px; padding:1.2rem; margin-bottom:1rem; box-shadow:0 1px 2px rgba(15,23,42,0.05);} 
        .message-title {font-size:1.05rem; font-weight:600; color:#0f172a; margin-bottom:0.35rem;} 
        .message-meta {font-size:0.9rem; color:#475569; margin-bottom:0.2rem;} 
        .message-meta.align-right {text-align:right;} 
        .message-body {font-family:'Segoe UI',sans-serif; color:#0f172a; line-height:1.55;} 
        .message-body img {max-width:100%; border-radius:10px; margin:0.3rem 0;} 
        .message-body ul {padding-left:1.2rem;} 
        .message-section-header {display:flex; align-items:center; justify-content:space-between; margin-bottom:0.5rem;} 
        .badge-pill {display:inline-flex; align-items:center; padding:0.25rem 0.75rem; background:#e0f2fe; color:#0369a1; border-radius:999px; font-size:0.8rem; margin-left:0.4rem;} 
        </style>
        """,
        unsafe_allow_html=True,
    )

    header_text = "Danh sách tin nhắn"
    count_badge = f"<span class='badge-pill'>Tổng {len(messages)}</span>"
    st.markdown(
        f"<div class='message-section-header'><h4>{header_text}</h4>{count_badge}</div>",
        unsafe_allow_html=True,
    )

    summary_parts = []
    if opening_id_value:
        summary_parts.append(f"**Opening ID:** `{_format_text(opening_id_value)}`")
    if stage_id_value:
        summary_parts.append(f"**Stage ID:** `{_format_text(stage_id_value)}`")
    if candidate_id_value:
        summary_parts.append(f"**Candidate ID:** `{_format_text(candidate_id_value)}`")
    if summary_parts:
        st.markdown(" • ".join(summary_parts))

    if meta:
        meta_cols = st.columns(4)
        meta_cols[0].markdown(f"**Candidate ID**\n\n{_format_text(meta.get('candidate_id') or candidate_id_value)}")
        meta_cols[1].markdown(f"**Opening ID**\n\n{_format_text(meta.get('opening_id') or opening_id_value)}")
        meta_cols[2].markdown(f"**Stage ID**\n\n{_format_text(meta.get('stage_id') or stage_id_value)}")
        meta_cols[3].markdown(f"**Thời gian cập nhật**\n\n{_format_timestamp(meta.get('since'))}")

    for idx, message in enumerate(messages, start=1):
        user = message.get("user") or {}
        author_name = user.get("name") or user.get("username") or user.get("email") or "Không rõ"
        author_type = user.get("type") or ""
        subject = message.get("subject") or "Không có tiêu đề"
        time_sent = _format_timestamp(message.get("since"))
        thread_id = message.get("thread_id") or "-"
        message_id = message.get("id") or "-"

        st.markdown("<div class='message-card'>", unsafe_allow_html=True)
        header_cols = st.columns([3, 1])
        with header_cols[0]:
            st.markdown(
                f"<div class='message-title'>{idx}. {_format_text(subject)}</div>",
                unsafe_allow_html=True,
            )
            st.markdown(
                f"<div class='message-meta'>Từ: {_format_text(author_name)} · Loại: {_format_text(author_type)}</div>",
                unsafe_allow_html=True,
            )
            st.markdown(
                f"<div class='message-meta'>Message ID: {_format_text(message_id)} · Thread: {_format_text(thread_id)}</div>",
                unsafe_allow_html=True,
            )
        with header_cols[1]:
            st.markdown(
                f"<div class='message-meta align-right'>Thời gian: {time_sent}</div>",
                unsafe_allow_html=True,
            )

        content_html = message.get("content") or message.get("body") or ""
        if isinstance(content_html, str):
            content_html = content_html.replace("\\r\\n", "\n")
        content_html = content_html or "<p>Không có nội dung.</p>"

        st.markdown(
            f"<div class='message-body'>{content_html}</div>",
            unsafe_allow_html=True,
        )

        attachments = message.get("attachments") or []
        if attachments:
            st.markdown("**Tệp đính kèm**")
            for attachment in attachments:
                name = attachment.get("name") or attachment.get("filename") or "Tệp"
                url = attachment.get("url") or attachment.get("download_url")
                if url:
                    st.markdown(f"- [{_format_text(name)}]({url})")
                else:
                    st.markdown(f"- {_format_text(name)}")

        tracking_events = message.get("tracking_events") or []
        if tracking_events:
            with st.expander("Lịch sử gửi/đọc"):
                for event in tracking_events:
                    event_name = event.get("event") or "unknown"
                    event_time = _format_timestamp(event.get("since"))
                    st.markdown(f"- **{_format_text(event_name)}** · {event_time}")

        st.markdown("</div>", unsafe_allow_html=True)


__all__ = [
    "render_metrics",
    "render_candidate_list",
    "render_candidate_detail_view",
    "render_candidate_messages_view",
]

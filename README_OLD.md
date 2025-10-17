# Base.vn Candidate Explorer

Ứng dụng giúp truy vấn và khai thác dữ liệu ứng viên từ Base.vn với hai cách tiếp cận:

- **Vue 3 + Vite + Node.js** – giao diện SPA hiện đại kết nối Node backend (Express) để proxy public API.
- **Streamlit + FastAPI** – lựa chọn Python truyền thống (giữ lại cho mục đích tham khảo).

## 🎯 Tính năng chính

- Truy xuất openings, stages và danh sách ứng viên từ Base.vn.
- Bộ lọc theo opening, stage, trang và số lượng phần tử.
- Thống kê nhanh (total, count, page, num_per_page).
- Xem chi tiết ứng viên và lịch sử tin nhắn.
- Xuất hiện JSON thô để tiện debug.

## 🚀 Quick Start (Vue + Node.js)

```powershell
# Terminal 1: khởi động backend Express
cd node_backend
npm install
npm run dev

# Terminal 2: khởi động frontend Vue
cd web_vue
npm install
npm run dev
```

Mở trình duyệt: <http://localhost:5173> (proxy sẵn tới <http://localhost:3000/api>).

## Tuỳ chọn khác

- **Streamlit UI:** chạy `npm start` trong `node_backend/`, sau đó `streamlit run app.py` ở `streamlit_app/`.
- **Standalone Vue (app_vue.html):** chạy Node backend rồi phục vụ file HTML qua `python -m http.server`.

## 📁 Cấu trúc chính

```text
WebAPI_App/
├── node_backend/          # Express proxy (axios + qs + cors)
├── web_vue/               # Vue 3 SPA (axios, composition API)
├── streamlit_app/         # Công cụ Python kế thừa (tùy chọn)
├── HUONG_DAN_CHAY_VUE.md  # Hướng dẫn chi tiết cho Vue
└── README_PROJECT.md      # Tài liệu đầy đủ
```

## 🔗 API (Node backend)

- Base URL: <http://localhost:3000/api>
- `POST /openings` – danh sách openings.
- `POST /openings/:id` – chi tiết opening.
- `POST /candidates` – danh sách ứng viên + metrics.
- `POST /candidate/:id` – chi tiết ứng viên.
- `POST /candidate/:id/messages` – lịch sử tin nhắn.

## 🛠️ Phát triển

- Vue sử dụng Composition API; chỉnh sửa `web_vue/src/App.vue` và tận dụng HMR của Vite.
- Backend Express được định nghĩa ở `node_backend/src/server.js` (Axios form-encoded requests tới Base.vn).
- Điều chỉnh CORS hoặc port bằng `node_backend/.env`.

## 🏗️ Build sản phẩm

```powershell
cd web_vue
npm run build
```

Kết quả nằm tại `web_vue/dist/`, deploy được lên hosting tĩnh (Netlify, Vercel,...).

## � Tài liệu bổ sung

- `README_PROJECT.md` – sơ đồ tổng quan và hướng dẫn chi tiết.
- `HUONG_DAN_CHAY_VUE.md` – quy trình từng bước cho frontend + backend Node.
- `streamlit_app/README.md` – hướng dẫn cho giải pháp Streamlit kế thừa.

## 📝 License

MIT
```

# Base.vn Candidate Explorer

Ứng dụng quản lý và theo dõi ứng viên từ Base.vn với 2 phiên bản frontend:
- **Streamlit App** - Python-based UI với Streamlit
- **Vue App** - Modern SPA với Vue 3 + Vite

## Cấu trúc Project

```
WebAPI_App/
├── streamlit_app/          # Backend + Streamlit UI
│   ├── app.py             # Streamlit application
│   ├── web_api.py         # FastAPI proxy server
│   ├── api_client.py      # Base.vn API client
│   ├── data_processor.py  # Data processing utilities
│   ├── config_manager.py  # Configuration management
│   ├── requirements.txt   # Python dependencies
│   └── ui/                # Streamlit UI components
├── web_vue/               # Vue 3 + Vite frontend
│   ├── src/
│   │   ├── App.vue       # Main Vue component
│   │   ├── main.js       # Entry point
│   │   └── style.css     # Global styles
│   ├── package.json      # Node dependencies
│   └── vite.config.js    # Vite configuration
├── app_vue.html          # Standalone Vue SPA (CDN version)
└── .env                  # Environment variables (không commit)
```

## Cài đặt

### Backend (FastAPI)

```powershell
cd streamlit_app
pip install -r requirements.txt
```

### Vue Frontend

```powershell
cd web_vue
npm install
```

## Cấu hình

Tạo file `.env` trong thư mục gốc:

```env
BASE_TOKEN=your-base-vn-token-here
OPENING_ID=9346
STAGE_ID=75440
NUM_PER_PAGE=50
LOCAL_PROXY_URL=http://127.0.0.1:8000
```

## Chạy ứng dụng

### Option 1: Chạy Vue + Vite (Khuyến nghị)

**Terminal 1 - FastAPI Backend:**
```powershell
cd streamlit_app
python web_api.py
```

**Terminal 2 - Vue Frontend:**
```powershell
cd web_vue
npm run dev
```

Mở trình duyệt: http://localhost:5173

### Option 2: Chạy Streamlit App

**Terminal 1 - FastAPI Backend:**
```powershell
cd streamlit_app
python web_api.py
```

**Terminal 2 - Streamlit:**
```powershell
cd streamlit_app
streamlit run app.py
```

Mở trình duyệt: http://localhost:8501

### Option 3: Chạy Standalone Vue HTML

**Terminal 1 - FastAPI Backend:**
```powershell
cd streamlit_app
python web_api.py
```

**Terminal 2 - Static Server:**
```powershell
python -m http.server 5555
```

Mở trình duyệt: http://127.0.0.1:5555/app_vue.html

## Tính năng

- 🔑 Quản lý Access Token và cấu hình
- 🗂️ Tải danh sách Openings & Stages
- 📋 Lọc và hiển thị danh sách ứng viên
- 📈 Hiển thị metrics và thống kê
- 📁 Xem chi tiết ứng viên
- 💬 Xem lịch sử tin nhắn/notes
- 🧾 Xem JSON phản hồi thô để debug

## API Endpoints

FastAPI server cung cấp các endpoint sau:

- `POST /openings` - Lấy danh sách openings
- `POST /opening/{id}` - Lấy chi tiết opening
- `POST /candidates` - Lấy danh sách ứng viên
- `POST /candidate/{id}` - Lấy chi tiết ứng viên
- `POST /candidate/{id}/messages` - Lấy tin nhắn ứng viên

API Documentation: http://127.0.0.1:8000/docs

## Development

### Vue Extension (VS Code)

- Đã cài extension Vue Official
- Syntax highlighting, autocomplete, lint cho .vue files
- Hot reload khi sửa code

### Build Production

```powershell
cd web_vue
npm run build
```

Output tại `web_vue/dist/`

## Troubleshooting

### CORS Error
- Đảm bảo FastAPI backend đang chạy
- Kiểm tra `LOCAL_PROXY_URL` trong `.env`
- Vue dev server đã cấu hình proxy tự động

### Port đã sử dụng
- FastAPI: thay đổi port trong `web_api.py`
- Vue: thay đổi port trong `vite.config.js`
- Streamlit: chạy `streamlit run app.py --server.port=8502`

## License

MIT

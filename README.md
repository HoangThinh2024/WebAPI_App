# Base.vn Candidate Explorer

Ứng dụng quản lý và theo dõi ứng viên từ Base.vn với 2 phiên bản frontend:

## 🎯 Tính năng

- 🔑 Quản lý Access Token và cấu hình
- 🗂️ Tải danh sách Openings & Stages từ Base.vn
- 📋 Lọc và hiển thị danh sách ứng viên
- 📈 Hiển thị metrics và thống kê
- 📁 Xem chi tiết ứng viên
- 💬 Xem lịch sử tin nhắn/notes
- 🧾 Xem JSON phản hồi thô để debug

## 📁 Cấu trúc Project

```
WebAPI_App/
├── streamlit_app/          # Backend (FastAPI) + Streamlit UI
│   ├── app.py             # Streamlit application
│   ├── web_api.py         # FastAPI proxy server ⭐
│   ├── api_client.py      # Base.vn API client
│   ├── data_processor.py  # Data processing
│   ├── config_manager.py  # Configuration
│   ├── requirements.txt   # Python dependencies
│   └── ui/                # Streamlit UI components
│
├── web_vue/               # Vue 3 + Vite frontend ⭐
│   ├── src/
│   │   ├── App.vue       # Main component
│   │   ├── main.js       # Entry point
│   │   └── style.css     # Styles
│   ├── package.json      # Node dependencies
│   └── vite.config.js    # Vite config
│
├── app_vue.html          # Standalone Vue (CDN, không cần Node.js)
├── .env                  # Environment variables
└── README_PROJECT.md     # Chi tiết đầy đủ
```

## 🚀 Quick Start

### Option 1: Vue + Vite (Khuyến nghị) ⭐

**Yêu cầu:** Node.js 18+ từ https://nodejs.org/

```powershell
# Terminal 1: Chạy FastAPI backend
cd streamlit_app
python web_api.py

# Terminal 2: Cài đặt và chạy Vue
cd web_vue
npm install
npm run dev
```

**Mở:** http://localhost:5173

### Option 2: Streamlit App

```powershell
# Terminal 1: FastAPI backend
cd streamlit_app
python web_api.py

# Terminal 2: Streamlit UI
cd streamlit_app
streamlit run app.py
```

**Mở:** http://localhost:8501

### Option 3: Standalone Vue HTML (Không cần Node.js)

```powershell
# Terminal 1: FastAPI backend
cd streamlit_app
python web_api.py

# Terminal 2: Static server
python -m http.server 5555
```

**Mở:** http://127.0.0.1:5555/app_vue.html

## ⚙️ Cấu hình

Tạo file `.env`:

```env
BASE_TOKEN=your-base-vn-token-here
OPENING_ID=9346
STAGE_ID=75440
NUM_PER_PAGE=50
LOCAL_PROXY_URL=http://127.0.0.1:8000
```

## 📚 Tài liệu

- **README_PROJECT.md** - Tài liệu chi tiết toàn bộ project
- **HUONG_DAN_CHAY_VUE.md** - Hướng dẫn Vue app chi tiết
- **streamlit_app/README.md** - Backend documentation
- **web_vue/README.md** - Vue frontend documentation

## 🔗 API Endpoints

FastAPI server: http://127.0.0.1:8000

- `POST /openings` - Danh sách openings
- `POST /opening/{id}` - Chi tiết opening
- `POST /candidates` - Danh sách ứng viên
- `POST /candidate/{id}` - Chi tiết ứng viên
- `POST /candidate/{id}/messages` - Tin nhắn ứng viên

**API Docs:** http://127.0.0.1:8000/docs

## 🛠️ Development

### Vue với Extension (VS Code)

- Cài extension: **Vue - Official**
- Hot reload tự động
- Syntax highlighting, IntelliSense
- Component refactoring

### Build Production

```powershell
cd web_vue
npm run build
```

Output: `web_vue/dist/`

## 📝 License

MIT

This repository contains utilities and a small proxy web API for the public Base.vn hiring API.

Files of interest:

- `api_client.py` - helper functions that call Base.vn public endpoints.
- `data_processor.py` - transforms candidate JSON into a pandas DataFrame and metrics.
- `web_api.py` - FastAPI application that exposes a complete REST API wrapper with the following endpoints:
	- GET `/html` - Beautiful HTML landing page with complete API documentation
	- GET `/` - JSON API information with all endpoints and examples
	- POST `/openings` - proxies `/opening/list` on hiring.base.vn
	- POST `/opening/{id}` - proxies `/opening/get` for a given opening id
	- POST `/candidates` - fetches candidate list and returns processed table + raw JSON
	- POST `/candidate/{id}` - proxies `/candidate/get` for candidate details
	- POST `/candidate/{id}/messages` - proxies `/candidate/messages` for candidate message history

Requirements and run
--------------------

Install dependencies (prefer virtualenv):

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Run the FastAPI server with uvicorn:

```powershell
uvicorn web_api:app --reload --port 8000
```

Access the API:

1. **HTML Landing Page** (Beautiful documentation page):
   ```
   http://localhost:8000/html
   ```

2. **JSON API Info** (All endpoints and examples):
   ```
   http://localhost:8000/
   ```

3. **Interactive Swagger UI**:
   ```
   http://localhost:8000/docs
   ```

Examples (curl):

```powershell
# List openings
curl -X POST "http://127.0.0.1:8000/openings?access_token=token&page=1&num_per_page=50&order_by=starred"

# Get opening details
curl -X POST "http://127.0.0.1:8000/opening/9346?access_token=token"

# List candidates
curl -X POST "http://127.0.0.1:8000/candidates?access_token=token&opening_id=9346&page=1&num_per_page=50&stage=75440"

# Get candidate details
curl -X POST "http://127.0.0.1:8000/candidate/518156?access_token=token"

# Get candidate messages
curl -X POST "http://127.0.0.1:8000/candidate/510943/messages?access_token=token"
```

Notes
-----
- Keep your access tokens secret. Consider using `.env` for local development (existing `app.py` uses python-dotenv).
- The `web_api.py` is a lightweight proxy — it does not add authentication. Add auth or rate-limiting for production.

Ứng dụng Streamlit để truy vấn Base.vn Candidate List API.

## 📋 Yêu cầu

- Python 3.12.x (khuyến nghị)
- `uv` package manager (hoặc `pip`)

**Lưu ý:** Python 3.14+ có thể gặp vấn đề tương thích với một số packages (đặc biệt là `pyarrow`).

## 🚀 Cài đặt

### 1. Clone repository

```bash
git clone <repository-url>
cd WebAPI_App
```

### 2. Tạo virtual environment

Sử dụng `uv`:
```bash
uv venv --python 3.12
```

Hoặc sử dụng `python`:
```bash
python -m venv .venv
```

### 3. Kích hoạt virtual environment

**Windows (PowerShell):**
```powershell
.venv\Scripts\activate
```

**Linux/Mac:**
```bash
source .venv/bin/activate
```

### 4. Cài đặt dependencies

Sử dụng `uv`:
```bash
uv pip install -r requirements.txt
```

Hoặc sử dụng `pip`:
```bash
pip install -r requirements.txt
```

## ⚙️ Cấu hình

### Thiết lập Access Token

1. Tạo file `.streamlit/secrets.toml` (nếu chưa có)
2. Thêm access token của bạn:

```toml
BASE_TOKEN = "your_actual_access_token_here"
```

**⚠️ Quan trọng:** File `secrets.toml` đã được thêm vào `.gitignore` để bảo vệ thông tin nhạy cảm.

## 🎯 Chạy ứng dụng

### Cách 1: Với virtual environment đã kích hoạt

```bash
streamlit run app.py
```

### Cách 2: Không cần kích hoạt venv (Windows)

```powershell
.venv\Scripts\python.exe -m streamlit run app.py
```

### Cách 3: Không cần kích hoạt venv (Linux/Mac)

```bash
.venv/bin/python -m streamlit run app.py
```

Ứng dụng sẽ chạy tại: http://localhost:8501

## 📂 Cấu trúc dự án

```
WebAPI_App/
├── app.py                 # Ứng dụng Streamlit chính
├── api_client.py          # Module gọi API
├── data_processor.py      # Module xử lý dữ liệu
├── requirements.txt       # Dependencies với version cụ thể
├── README.md             # File này
├── .gitignore            # Danh sách file/folder không commit
├── .streamlit/
│   └── secrets.toml      # Lưu trữ API tokens (không commit)
└── .venv/                # Virtual environment (không commit)
```

## 🔧 Tính năng

### Core Features
- ✅ Truy vấn Base.vn Candidate List API
- ✅ Hiển thị danh sách ứng viên dạng bảng
- ✅ Hiển thị các chỉ số tổng quan (total, count, page)
- ✅ Xem JSON response thô
- ✅ Form tương tác để nhập tham số API
- ✅ Xử lý lỗi API và kết nối

### 🆕 Advanced Features
- ✅ **Dropdown Opening & Stage**: Tự động load và chọn từ danh sách thay vì nhập thủ công
- ✅ **Session State**: Lưu danh sách openings trong session, không cần load lại
- ✅ **Environment Config**: Lưu cấu hình vào `.env` file
- ✅ **Local Proxy Support**: Hỗ trợ gọi API qua FastAPI proxy server local

> 📖 Xem chi tiết: [DROPDOWN_GUIDE.md](DROPDOWN_GUIDE.md)

## 📦 Dependencies

### Core
- `requests==2.32.5` - HTTP client
- `pandas==2.3.3` - Data processing
- `numpy==2.3.3` - Numerical computing
- `streamlit==1.50.0` - Web framework

### Configuration & Environment
- `python-dotenv==1.0.1` - Environment variables management

### Optional (for local proxy server)
- `fastapi==0.115.6` - API framework
- `uvicorn==0.34.2` - ASGI server
- `httpx==0.28.1` - Async HTTP client
- `pydantic==2.10.6` - Data validation

## 🐛 Debug

Nếu gặp lỗi khi cài đặt:

1. **Lỗi `pyarrow` không build được:**
   - Đảm bảo dùng Python 3.12.x thay vì 3.14+
   - Tạo lại venv: `uv venv --python 3.12`

2. **Lỗi `streamlit` không tìm thấy:**
   - Đảm bảo đã kích hoạt virtual environment
   - Hoặc chạy trực tiếp: `.venv\Scripts\python.exe -m streamlit run app.py`

3. **Lỗi API 401/403:**
   - Kiểm tra access token trong `.streamlit/secrets.toml`
   - Đảm bảo token còn hiệu lực

## 📝 License

Xem file `LICENSE` để biết thêm chi tiết.
```

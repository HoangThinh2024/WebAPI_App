# Streamlit App - Backend & UI

Backend FastAPI proxy server và Streamlit UI cho Base.vn Candidate Explorer.

## Cấu trúc

```
streamlit_app/
├── app.py              # Streamlit application
├── web_api.py          # FastAPI proxy server
├── api_client.py       # Base.vn API client
├── api_server.py       # Alternative FastAPI server
├── data_processor.py   # Data processing utilities
├── config_manager.py   # Configuration management
├── requirements.txt    # Python dependencies
├── test_api.py         # API tests
├── example_usage.py    # Usage examples
└── ui/
    ├── __init__.py
    └── components.py   # Reusable UI components
```

## Cài đặt

```bash
pip install -r requirements.txt
```

## Chạy

### FastAPI Proxy Server

```bash
python web_api.py
```

Server: http://127.0.0.1:8000
Docs: http://127.0.0.1:8000/docs

### Streamlit UI

```bash
streamlit run app.py
```

UI: http://localhost:8501

## API Endpoints

- `POST /openings` - Danh sách openings
- `POST /opening/{id}` - Chi tiết opening  
- `POST /candidates` - Danh sách ứng viên
- `POST /candidate/{id}` - Chi tiết ứng viên
- `POST /candidate/{id}/messages` - Tin nhắn ứng viên

## Environment Variables

Tạo file `.env` trong thư mục gốc:

```env
BASE_TOKEN=your-token-here
OPENING_ID=9346
STAGE_ID=75440
NUM_PER_PAGE=50
```

## Testing

```bash
python test_api.py
```

## Development

- Python 3.12+ recommended
- FastAPI với uvicorn
- Streamlit 1.50+
- Pandas, Requests, python-dotenv

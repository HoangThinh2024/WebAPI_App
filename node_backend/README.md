# Node.js Backend - Express Proxy for Base.vn API

Modern, efficient Node.js backend sử dụng pnpm.

## 🚀 Quick Start

```powershell
# Cài đặt pnpm (nếu chưa có)
npm install -g pnpm

# Cài đặt dependencies
pnpm install

# Chạy development mode (auto-reload)
pnpm dev

# Hoặc production mode
pnpm start
```

Server sẽ chạy tại: <http://localhost:3000>

## 📁 Structure

```text
node_backend/
├── src/
│   └── server.js       # Express server với API routes
├── .env.example        # Environment template
├── package.json        # Dependencies & scripts
└── README.md          # File này
```

## 🔧 Configuration

Sao chép `.env.example` thành `.env` và điều chỉnh:

```env
PORT=3000
API_TIMEOUT_MS=30000
CORS_ALLOWED_ORIGINS=http://localhost:5173
LOG_LEVEL=info
```

## 🔗 API Endpoints

Base URL: `http://localhost:3000/api`

### Health Check

- `GET /health` - Kiểm tra trạng thái server

### Base.vn Proxy Endpoints

- `POST /api/openings` - Danh sách openings
- `POST /api/openings/:id` - Chi tiết opening
- `POST /api/candidates` - Danh sách ứng viên (với metrics)
- `POST /api/candidate/:id` - Chi tiết ứng viên
- `POST /api/candidate/:id/messages` - Lịch sử tin nhắn

### Request Parameters

Tất cả endpoints chấp nhận parameters qua:

- Query string: `?access_token=xxx&opening_id=123`
- Request body (JSON hoặc form-encoded)

Example:

```javascript
// POST /api/candidates
{
  "access_token": "your-token",
  "opening_id": "9346",
  "stage": "75440",
  "page": 1,
  "num_per_page": 50
}
```

## 🎯 Features

- ✅ Form-encoded proxy tới Base.vn API
- ✅ CORS configuration
- ✅ Error handling với proper status codes
- ✅ Request timeout protection
- ✅ Structured logging
- ✅ Metrics transformation cho frontend

## 🔒 Security Notes

- Không lưu access token trên server
- Token được gửi từ client mỗi request
- CORS được cấu hình cho development
- **Production:** thêm rate limiting, authentication middleware

## 🛠️ Development

```powershell
# Auto-reload khi code thay đổi
pnpm dev

# Lint code
pnpm lint

# Production mode
pnpm start
```

## 📦 Dependencies

- `express` - Web framework
- `axios` - HTTP client cho Base.vn API
- `cors` - CORS middleware
- `dotenv` - Environment variables
- `qs` - Query string parser

## 🐛 Troubleshooting

### Port 3000 already in use

Đổi port trong `.env`:

```env
PORT=3001
```

### CORS errors

Kiểm tra `CORS_ALLOWED_ORIGINS` trong `.env` khớp với Vue dev server.

### Connection timeout

Tăng `API_TIMEOUT_MS` trong `.env`:

```env
API_TIMEOUT_MS=60000
```

## 📝 License

MIT

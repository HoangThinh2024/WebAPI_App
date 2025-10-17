# WebAPI App - Base.vn Candidate Explorer

> Ứng dụng web hiện đại, responsive, đa nền tảng để quản lý và theo dõi ứng viên từ Base.vn Public API

[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![Vue](https://img.shields.io/badge/Vue-3.5-brightgreen.svg)](https://vuejs.org/)
[![pnpm](https://img.shields.io/badge/pnpm-9.0-orange.svg)](https://pnpm.io/)
[![Security](https://img.shields.io/badge/Security-Production%20Ready-brightgreen.svg)](docs/SECURITY_DEPLOYMENT_GUIDE.md)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Version:** 2.2.2 (Production Ready) ✅
**Released:** 2025-10-17

## ✨ Highlights

- 🎨 **Responsive Design** - Tối ưu cho desktop, tablet, mobile (iOS/Android)
- ⚡ **High Performance** - Vite HMR, 70% faster modal open time, optimized RAM usage
- 🌐 **Network Mode** - Share trên LAN, truy cập từ nhiều thiết bị
- 🔒 **Production Security** - XSS protection, authentication, security audit automation
- 🌙 **Dark Mode** - Auto-detect system theme, smooth transitions
- 🎯 **Modern Stack** - Vue 3 Composition API, Express.js, DOMPurify, SHA256
- 📦 **Automated Deployment** - Build, test, deploy scripts với security checks

## 🚀 Siêu Nhanh - Dùng App Manager!

```powershell
# Chạy 1 lệnh duy nhất - mọi thứ tự động!
.\app-manager.ps1
```

**Menu tương tác:**
- Development: Start Vue, Backend, Full Stack
- Production: Security audit, Build, Deploy
- Maintenance: Cleanup, Authentication, Reports
- Documentation: Guides, Structure

## 📖 Quick Start (Traditional)

### Yêu cầu

- **Node.js** 18 LTS+ ([Download](https://nodejs.org/))
- **pnpm** 9.0+ (Install: `npm install -g pnpm`)

### Development Mode

```powershell
# Option 1: Sử dụng App Manager (Recommended)
.\app-manager.ps1
# Chọn [3] Start Full Stack

# Option 2: Manual
# Terminal 1 - Backend
.\scripts\development\start-backend.ps1

# Terminal 2 - Frontend (Network mode)
.\scripts\development\start-network.ps1
```

### Production Mode

```powershell
# 1. Security audit
.\scripts\production\security-audit.ps1

# 2. Build production
.\scripts\production\build-production.ps1

# 3. Deploy
.\scripts\production\deploy-production.ps1 -DeployTarget local
```

### Truy cập

- **Desktop:** <http://localhost:5173>
- **Mobile (LAN):** <http://192.168.x.x:5173>
- **Backend API:** <http://localhost:3000>
- **Health Check:** <http://localhost:3000/health>

## 🎯 Tính năng

### Core Features

- 🔑 Quản lý Access Token và cấu hình backend URL
- 🗂️ Tải danh sách Openings & Stages từ Base.vn
- 📋 Lọc ứng viên theo opening, stage, phân trang
- 📈 Hiển thị metrics tổng quan (total, count, page)
- 📁 Xem chi tiết ứng viên với modal
- 💬 Truy xuất lịch sử tin nhắn/ghi chú
- 🧾 Debug JSON response thô

### Responsive Features

- ✅ Adaptive layout với CSS Grid & Flexbox
- ✅ Table responsive với horizontal scroll
- ✅ Hidden columns trên mobile (phone, stage)
- ✅ Touch-friendly buttons và spacing
- ✅ Smooth animations & transitions
- ✅ Dark mode tối ưu cho mọi thiết bị
- ✅ Accessibility support (keyboard, screen readers)

### Developer Experience

- ⚡ Vite HMR instant reload
- 📦 pnpm ~50% faster than npm
- 🎨 ESLint + Prettier tích hợp
- 🔧 VS Code extension support
- 🐛 Source maps cho debugging
- 📊 Bundle analyzer ready

## 📁 Cấu trúc dự án

```text
WebAPI_App/
├── node_backend/                   # Node.js Express backend
│   ├── src/
│   │   └── server.js              # API routes & proxy logic
│   ├── package.json               # pnpm dependencies
│   ├── .env.example               # Environment template
│   └── README.md
│
├── web_vue/                        # Vue 3 + Vite frontend
│   ├── src/
│   │   ├── App.vue               # Main component (Composition API)
│   │   ├── main.js               # Entry point
│   │   └── style.css             # Responsive CSS (mobile-first)
│   ├── vite.config.js            # Build config, proxy, HMR
│   ├── package.json              # pnpm dependencies
│   └── README.md
│
├── streamlit_app/                  # Python tools (legacy/optional)
│   └── ...
│
├── HUONG_DAN_CHAY_VUE_PNPM.md     # Hướng dẫn chi tiết pnpm
├── README_PROJECT.md              # Tài liệu đầy đủ
└── README.md                      # File này
```

## 🔗 API Endpoints

Base URL: `http://localhost:3000/api`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/api/openings` | Danh sách openings |
| POST | `/api/openings/:id` | Chi tiết opening |
| POST | `/api/candidates` | Danh sách ứng viên + metrics |
| POST | `/api/candidate/:id` | Chi tiết ứng viên |
| POST | `/api/candidate/:id/messages` | Lịch sử tin nhắn |

**Request Format:**

```javascript
POST /api/candidates
{
  "access_token": "your-token",
  "opening_id": "9346",
  "stage": "75440",
  "page": 1,
  "num_per_page": 50
}
```

## 🌐 Cross-platform Support

### Desktop

- ✅ Windows (Edge, Chrome, Firefox)
- ✅ macOS (Safari, Chrome, Firefox)
- ✅ Linux (Chrome, Firefox)

### Mobile

- ✅ iOS (Safari Mobile - iPhone/iPad)
- ✅ Android (Chrome Mobile)
- ✅ Responsive breakpoints: 480px, 768px, 1024px

### Truy cập từ Mobile

1. Đảm bảo máy tính và điện thoại cùng mạng WiFi
2. Chạy `pnpm dev` trong `web_vue/`
3. Tìm địa chỉ **Network** trong terminal (vd: `http://192.168.1.100:5173`)
4. Mở địa chỉ đó trên điện thoại

## 👨‍💻 For Developers

### Clone & Contribute

Developers có thể clone project và phát triển tính năng mới mà **KHÔNG Ảnh hưởng** đến scripts tự động hóa:

```bash
# Clone repository
git clone https://github.com/HoangThinh2024/WebAPI_App.git
cd WebAPI_App

# Install dependencies
pnpm install

# Create feature branch
git checkout -b feature/my-feature

# Start development
pnpm dev  # hoặc dùng app-manager.ps1
```

**📖 Đọc trước khi code:**

- **[DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md)** - Hướng dẫn đầy đủ cho developers ⭐
- **[CONTRIBUTING.md](docs/CONTRIBUTING.md)** - Quy tắc đóng góp code
- **[docs/README.md](docs/README.md)** - Documentation index

**Quy tắc quan trọng:**

- ✅ **CÓ THỂ SỬA**: `web_vue/src/`, `node_backend/`, `docs/`
- ❌ **KHÔNG SỬA**: `scripts/`, `app-manager.ps1`, automation scripts

**Workflow:**

1. Fork & clone repo
2. Create feature branch
3. Make changes in `web_vue/src/` or `node_backend/`
4. Test locally
5. Commit with conventional message (`feat:`, `fix:`, etc.)
6. Create Pull Request
7. Wait for review

Chi tiết xem [DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md)

---

## 🏗️ Build Production

```powershell
# Option 1: Dùng automation script (Recommended)
.\scripts\production\build-production.ps1

# Option 2: Manual
cd web_vue
pnpm build
```

Output: `web_vue/dist/` (ready to deploy)

**Deploy to:**

- ✅ Vercel / Netlify (khuyến nghị)
- ✅ AWS S3 + CloudFront
- ✅ GitHub Pages
- ✅ Nginx / Apache
- ✅ Docker container

### Preview Production Build

```powershell
cd web_vue
pnpm preview
# ➜ http://localhost:4173
```

## ⚙️ Configuration

### Backend (.env)

```env
PORT=3000
API_TIMEOUT_MS=30000
CORS_ALLOWED_ORIGINS=http://localhost:5173
LOG_LEVEL=info
```

### Frontend (trong ứng dụng)

- Access Token: Nhập trong UI
- Backend URL: Mặc định `http://localhost:3000/api`
- LocalStorage: Tự động lưu token và URL

## 🛠️ Scripts

### Backend (`node_backend/`)

```powershell
pnpm dev        # Chạy với nodemon (auto-reload)
pnpm start      # Production mode
pnpm lint       # ESLint check
```

### Frontend (`web_vue/`)

```powershell
pnpm dev        # Dev server với HMR
pnpm build      # Build production
pnpm preview    # Preview production build
pnpm lint       # ESLint + Prettier
```

## 📚 Tài liệu chi tiết

- 📖 [HUONG_DAN_CHAY_VUE_PNPM.md](./HUONG_DAN_CHAY_VUE_PNPM.md) - Hướng dẫn pnpm & troubleshooting
- 📖 [README_PROJECT.md](./README_PROJECT.md) - Tổng quan kiến trúc & deployment
- 📖 [web_vue/README.md](./web_vue/README.md) - Frontend documentation
- 📖 [node_backend/README.md](./node_backend/README.md) - Backend API docs
- 📖 [streamlit_app/README.md](./streamlit_app/README.md) - Python tools (legacy)

## 🐛 Troubleshooting

### pnpm command not found

```powershell
npm install -g pnpm
```

### Port đã được sử dụng

Vite tự động tìm port tiếp theo (5174, 5175...) hoặc đổi trong `.env`

### CORS errors

Đảm bảo backend chạy tại `http://localhost:3000` và kiểm tra `vite.config.js`

### Không kết nối từ mobile

- Kiểm tra firewall
- Đảm bảo cùng mạng WiFi
- Dùng địa chỉ Network (không phải localhost)

### Build errors

```powershell
# Xóa cache và rebuild
rm -rf node_modules .pnpm-store dist
pnpm install
pnpm build
```

## ⚡ Performance Metrics

| Metric | Value |
|--------|-------|
| pnpm install | ~50% faster than npm |
| Vite HMR | < 100ms update time |
| Bundle size (gzipped) | ~150KB |
| Lighthouse Score | 95+ |
| First Contentful Paint | < 1.5s |
| Time to Interactive | < 2.5s |

## 🤝 Contributing

1. Fork repository
2. Tạo branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

## 📝 License

MIT License - xem file [LICENSE](LICENSE) để biết thêm chi tiết.

## 🙏 Acknowledgments

- [Vue.js](https://vuejs.org/) - Progressive JavaScript framework
- [Vite](https://vitejs.dev/) - Next generation frontend tooling
- [pnpm](https://pnpm.io/) - Fast, disk space efficient package manager
- [Express.js](https://expressjs.com/) - Fast, unopinionated web framework
- [Base.vn](https://base.vn/) - Recruitment platform API

---

**Made with ❤️ for modern web development**

📧 Issues & Questions: [GitHub Issues](https://github.com/HoangThinh2024/WebAPI_App/issues)

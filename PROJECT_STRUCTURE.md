# 📁 Cấu trúc Project WebAPI_App v2.2.2

## 🎯 Tổng quan

Project đã được tổ chức lại gọn gàng và chuyên nghiệp:

```
WebAPI_App/
├── 📚 docs/                    # Tất cả tài liệu
├── 🔧 scripts/                 # Tất cả scripts
│   ├── production/            # Scripts production
│   └── development/           # Scripts development
├── 🎨 web_vue/                # Vue 3 Frontend app
├── ⚙️  node_backend/          # Node.js Backend API
├── 📊 streamlit_app/          # Streamlit app (optional)
├── 📄 Config files            # package.json, .gitignore, etc.
└── 🚀 app-manager.ps1         # Master script (QUAN TRỌNG!)
```

## 🚀 Cách sử dụng mới

### ⚡ Siêu nhanh - Dùng App Manager!

```powershell
# Chạy 1 lệnh duy nhất
.\app-manager.ps1
```

Menu tương tác với 12 chức năng:
- **Development**: Start Vue, Backend, Full Stack
- **Production**: Security audit, Build, Deploy
- **Maintenance**: Cleanup, Authentication, Reports
- **Documentation**: Guides, Structure

### 📁 Chi tiết từng thư mục

#### 1. `docs/` - Tài liệu

Tất cả documentation đã được di chuyển vào đây:

**Quick Start:**
- `QUICK_START.md` - Hướng dẫn khởi động nhanh
- `QUICK_REFERENCE.md` - Tham khảo lệnh nhanh
- `QUICKSTART.md` - Quick guide

**Setup & Installation:**
- `HUONG_DAN_CHAY_VUE.md` - Hướng dẫn chạy Vue (npm)
- `HUONG_DAN_CHAY_VUE_PNPM.md` - Hướng dẫn chạy Vue (pnpm)
- `NETWORK_SETUP.md` - Setup network LAN

**Security & Deployment:**
- `SECURITY_DEPLOYMENT_GUIDE.md` - Bảo mật & deployment
- `GIT_COMMIT_GUIDE.md` - Git workflow

**Release History:**
- `CHANGELOG.md` - Lịch sử thay đổi đầy đủ
- `RELEASE_*.md` - Release notes
- `README_v2.2.2.md` - Version 2.2.2 notes

**Feature Updates:**
- `COMPLETED_UI_2.2.0.md` - UI redesign
- `DARK_MODE_FIX_2.2.1.md` - Dark mode
- `DEBUG_MODE_2.2.1.1.md` - Debug mode
- `FIELD_MAPPING_FIX_2.2.1.2.md` - Field mapping

**Index:**
- `README.md` - Documentation index (đọc đầu tiên!)

#### 2. `scripts/` - Automation Scripts

##### 2.1. `scripts/production/`

Scripts cho production deployment:

**Authentication:**
```powershell
.\scripts\production\auth-gate.ps1 -Action add-user
```
- SHA256 password hashing
- Multi-user support
- 3 login attempts
- Role-based access

**Security Audit:**
```powershell
.\scripts\production\security-audit.ps1
```
- Hardcoded secrets scan
- Dependencies vulnerabilities
- eval() usage detection
- console.log check
- File permissions
- CORS configuration
- Exit code: 0 (pass), 1 (failed)

**Security Fixes:**
```powershell
.\scripts\production\security-fix.ps1 -All
```
- XSS protection (DOMPurify)
- File permissions
- Environment setup

**Cleanup:**
```powershell
.\scripts\production\cleanup.ps1 -DryRun
```
- Cache removal (.vite, .cache)
- Log files cleanup
- Temp files deletion
- Deep clean (node_modules)

**Build Production:**
```powershell
.\scripts\production\build-production.ps1
```
- Security audit first
- Install dependencies
- Vite build (minify, tree-shaking)
- Manifest generation
- Size report

**Deploy:**
```powershell
.\scripts\production\deploy-production.ps1 -DeployTarget local
```
- Authentication check
- Git status verification
- Security audit
- Tests run
- Build production
- Create deployment package (ZIP)
- Deploy to target
- Generate deployment checklist

**Security Report:**
- `security-audit-report.json` - JSON report với details

##### 2.2. `scripts/development/`

Scripts cho development:

**Start Network:**
```powershell
.\scripts\development\start-network.ps1
```
- Auto-detect local IP (192.168.x.x)
- Start Vite on 0.0.0.0:5173
- Access from LAN devices
- HMR enabled

**Start Backend:**
```powershell
.\scripts\development\start-backend.ps1
```
- Start Express on localhost:3000
- CORS enabled
- Auto reload (nodemon)
- Request logging

##### 2.3. Legacy scripts

Old scripts (backward compatibility):
- `clean.cjs` - Old cleanup script (Node.js)
- `clean.ps1` - Old cleanup script (PowerShell)
- `clean.sh` - Old cleanup script (Bash)

#### 3. `web_vue/` - Frontend

Vue 3 + Vite frontend application:

```
web_vue/
├── src/
│   ├── components/        # Vue components
│   ├── utils/            # Utilities (sanitizer, etc.)
│   ├── App.vue           # Main app
│   └── main.js           # Entry point
├── public/               # Static assets
├── .env                  # Development environment
├── .env.production       # Production environment
├── package.json          # Dependencies
└── vite.config.js        # Vite configuration
```

**Chạy development:**
```powershell
cd web_vue
pnpm install
pnpm dev
```

**Build production:**
```powershell
cd web_vue
pnpm build
```

#### 4. `node_backend/` - Backend

Node.js + Express backend API:

```
node_backend/
├── server.js             # Main server file
├── package.json          # Dependencies
└── [API routes]          # API endpoints
```

**Chạy backend:**
```powershell
cd node_backend
pnpm install
pnpm dev
```

**Endpoints:**
- `GET /api/health` - Health check
- `GET /api/data` - Fetch data
- `POST /api/data` - Create data
- `PUT /api/data/:id` - Update data
- `DELETE /api/data/:id` - Delete data

#### 5. `streamlit_app/` - Streamlit (Optional)

Streamlit app nếu cần:

```
streamlit_app/
├── app.py               # Main Streamlit app
├── api_client.py        # API client
├── api_server.py        # API server
├── data_processor.py    # Data processing
└── requirements.txt     # Python dependencies
```

#### 6. Root Files

Files cấu hình ở root:

- `app-manager.ps1` - **Master script (QUAN TRỌNG!)**
- `README.md` - Main README
- `package.json` - Root package.json (pnpm workspace)
- `pnpm-workspace.yaml` - pnpm workspace config
- `pnpm-lock.yaml` - Dependencies lock file
- `.gitignore` - Git ignore rules
- `.gitattributes` - Git attributes
- `.env.example` - Environment template
- `LICENSE` - MIT license
- `app_vue.html` - HTML template (legacy)

## 🔄 Workflow mới

### Development Workflow

```powershell
# Option 1: Dùng App Manager (Recommended)
.\app-manager.ps1
# Chọn [3] Start Full Stack

# Option 2: Manual (từng bước)
# Terminal 1 - Backend
.\scripts\development\start-backend.ps1

# Terminal 2 - Frontend
.\scripts\development\start-network.ps1
```

### Production Workflow

```powershell
# Option 1: Dùng App Manager
.\app-manager.ps1
# Chọn [4] Security Audit
# Chọn [5] Build Production
# Chọn [6] Deploy

# Option 2: Manual (từng bước)
.\scripts\production\security-audit.ps1
.\scripts\production\build-production.ps1
.\scripts\production\deploy-production.ps1 -DeployTarget local
```

## 📊 So sánh cũ vs mới

### Trước đây (v2.2.1)

```
WebAPI_App/
├── auth-gate.ps1                # Root (lộn xộn!)
├── security-audit.ps1           # Root
├── cleanup.ps1                  # Root
├── start-network.ps1            # Root
├── start-backend.ps1            # Root
├── CHANGELOG.md                 # Root
├── README.md                    # Root
├── ... 25+ files khác ...       # Root (quá nhiều!)
├── web_vue/
├── node_backend/
└── streamlit_app/
```

### Bây giờ (v2.2.2)

```
WebAPI_App/
├── 📚 docs/                    # Tất cả docs
├── 🔧 scripts/                 # Tất cả scripts
│   ├── production/            # Production scripts
│   └── development/           # Development scripts
├── 🎨 web_vue/                # Frontend
├── ⚙️  node_backend/          # Backend
├── 📊 streamlit_app/          # Streamlit
├── README.md                  # Main README
├── package.json               # Root config
└── 🚀 app-manager.ps1         # Master script
```

**Lợi ích:**
- ✅ Gọn gàng, dễ tìm kiếm
- ✅ Phân loại rõ ràng
- ✅ Dễ maintenance
- ✅ Professional structure
- ✅ Scalable

## 🎯 Quick Reference

### Chạy development

```powershell
# Cách 1: Siêu nhanh!
.\app-manager.ps1
# → Chọn [3]

# Cách 2: Manual
.\scripts\development\start-network.ps1
```

### Deploy production

```powershell
# Cách 1: Siêu nhanh!
.\app-manager.ps1
# → Chọn [4] → [5] → [6]

# Cách 2: Manual
.\scripts\production\security-audit.ps1
.\scripts\production\build-production.ps1
.\scripts\production\deploy-production.ps1 -DeployTarget local
```

### Dọn dẹp

```powershell
# Cách 1: App Manager
.\app-manager.ps1
# → Chọn [8]

# Cách 2: Manual
.\scripts\production\cleanup.ps1
```

### Xem docs

```powershell
# Cách 1: App Manager
.\app-manager.ps1
# → Chọn [11]

# Cách 2: Manual
start docs\README.md
```

### Xem security report

```powershell
# Cách 1: App Manager
.\app-manager.ps1
# → Chọn [10]

# Cách 2: Manual
Get-Content scripts\production\security-audit-report.json | ConvertFrom-Json | Format-List
```

## 📝 Migration Notes

### Đã di chuyển

**Scripts production** (6 files):
- `auth-gate.ps1` → `scripts/production/auth-gate.ps1`
- `security-audit.ps1` → `scripts/production/security-audit.ps1`
- `security-fix.ps1` → `scripts/production/security-fix.ps1`
- `cleanup.ps1` → `scripts/production/cleanup.ps1`
- `build-production.ps1` → `scripts/production/build-production.ps1`
- `deploy-production.ps1` → `scripts/production/deploy-production.ps1`

**Scripts development** (2 files):
- `start-network.ps1` → `scripts/development/start-network.ps1`
- `start-backend.ps1` → `scripts/development/start-backend.ps1`

**Documentation** (23 files):
- All `*.md` files → `docs/`
- Except: `README.md` (stays in root)

**Reports:**
- `security-audit-report.json` → `scripts/production/security-audit-report.json`

### Không thay đổi

- `web_vue/` - Giữ nguyên
- `node_backend/` - Giữ nguyên
- `streamlit_app/` - Giữ nguyên
- `node_modules/` - Giữ nguyên
- Root config files - Giữ nguyên

### Đã tạo mới

- `app-manager.ps1` - Master script
- `docs/README.md` - Documentation index
- `scripts/production/README.md` - Production scripts guide
- `scripts/development/README.md` - Development scripts guide

## 🆘 Troubleshooting

### Script không tìm thấy?

```powershell
# Old way (SẼ LỖI!)
.\security-audit.ps1

# New way (ĐÚNG!)
.\scripts\production\security-audit.ps1

# Best way (SIÊU NHANH!)
.\app-manager.ps1  # → Chọn [4]
```

### Documentation không tìm thấy?

```powershell
# Old way (SẼ LỖI!)
cat CHANGELOG.md

# New way (ĐÚNG!)
cat docs\CHANGELOG.md

# Best way (SIÊU NHANH!)
.\app-manager.ps1  # → Chọn [11]
```

### Làm sao biết file nào ở đâu?

```powershell
# Option 1: App Manager
.\app-manager.ps1
# → Chọn [12] View Project Structure

# Option 2: Xem docs
cat docs\README.md

# Option 3: Search
Get-ChildItem -Recurse -Filter "*.md"
```

## 🎉 Kết luận

Cấu trúc mới:
- ✅ **Gọn gàng hơn** - Files được phân loại rõ ràng
- ✅ **Dễ tìm kiếm** - Biết ngay file ở đâu
- ✅ **Chuyên nghiệp** - Chuẩn industry standard
- ✅ **Dễ mở rộng** - Thêm file mới dễ dàng
- ✅ **Siêu nhanh** - 1 lệnh duy nhất với app-manager!

**Nhớ sử dụng `app-manager.ps1` để làm mọi thứ nhanh nhất!** 🚀

---

**Version:** 2.2.2 (Production Ready)  
**Last Updated:** 2025-10-17  
**Migration Status:** ✅ Completed

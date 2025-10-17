# Base.vn Candidate Explorer - Chi tiết dự án

> Tài liệu đầy đủ về kiến trúc, deployment và development workflow

## 📋 Mục lục

- [Tổng quan](#tổng-quan)
- [Kiến trúc hệ thống](#kiến-trúc-hệ-thống)
- [Công nghệ sử dụng](#công-nghệ-sử-dụng)
- [Cài đặt](#cài-đặt)
- [Development](#development)
- [Production Build & Deploy](#production-build--deploy)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## 🎯 Tổng quan

Base.vn Candidate Explorer là ứng dụng web full-stack hiện đại để quản lý ứng viên từ Base.vn Public API. Được xây dựng với:

- **Frontend:** Vue 3 + Vite (SPA responsive, mobile-first)
- **Backend:** Node.js + Express (API proxy, CORS handling)
- **Package Manager:** pnpm (hiệu suất cao, tiết kiệm disk)
- **Styling:** Custom CSS3 (responsive, dark mode, animations)

### Đặc điểm nổi bật

- 🎨 **100% Responsive** - Desktop, tablet, mobile (iOS/Android)
- ⚡ **Performance tối ưu** - Vite HMR, code splitting, lazy loading
- 🌐 **Cross-platform** - Windows, macOS, Linux
- 🔒 **Type-safe** - JSDoc typing, ESLint, Prettier
- 📱 **Mobile-first** - Touch-optimized, adaptive layout
- 🎯 **Modern DX** - Hot reload, source maps, debugging tools

## 🏗️ Kiến trúc hệ thống

```text
┌─────────────────────────────────────────────────────────────┐
│                        Client Layer                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Vue 3 SPA (Composition API)                           │ │
│  │  - App.vue: Main component                             │ │
│  │  - style.css: Responsive styles                        │ │
│  │  - Axios: HTTP client                                  │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↕ HTTP/HTTPS
┌─────────────────────────────────────────────────────────────┐
│                      Backend Layer                           │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Node.js Express Server                                │ │
│  │  - API Routes: /api/*                                  │ │
│  │  - CORS: Cross-origin handling                         │ │
│  │  - Proxy: Base.vn API requests                         │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↕ HTTPS
┌─────────────────────────────────────────────────────────────┐
│                   External API Layer                         │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Base.vn Public API (hiring.base.vn)                   │ │
│  │  - Opening management                                  │ │
│  │  - Candidate data                                      │ │
│  │  - Messages/Notes                                      │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🛠️ Công nghệ sử dụng

### Frontend Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Vue.js | 3.5+ | Progressive framework |
| Vite | 6.0+ | Build tool & dev server |
| Axios | 1.7+ | HTTP client |
| pnpm | 9.0+ | Package manager |

### Backend Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Node.js | 18+ LTS | Runtime environment |
| Express.js | 4.19+ | Web framework |
| Axios | 1.7+ | HTTP client |
| CORS | 2.8+ | Cross-origin middleware |
| dotenv | 16.4+ | Environment config |

### Development Tools

- **ESLint** - Code linting
- **Prettier** - Code formatting
- **Nodemon** - Auto-reload server
- **VS Code** - IDE (with Vue extensions)

## 📦 Cài đặt

### Yêu cầu hệ thống

- Node.js 18.x LTS hoặc mới hơn
- pnpm 9.0 hoặc mới hơn
- Git
- Terminal/Command Prompt

### Clone Repository

```powershell
git clone https://github.com/HoangThinh2024/WebAPI_App.git
cd WebAPI_App
```

### Cài đặt pnpm

```powershell
# Windows (PowerShell)
npm install -g pnpm

# Verify installation
pnpm --version  # Should show 9.x.x
```

### Cài đặt Dependencies

#### Backend

```powershell
cd node_backend
pnpm install
```

#### Frontend

```powershell
cd web_vue
pnpm install
```

### Environment Configuration

#### Backend (.env)

Tạo file `node_backend/.env`:

```env
PORT=3000
API_TIMEOUT_MS=30000
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://192.168.1.100:5173
LOG_LEVEL=info
```

#### Frontend (runtime)

Configuration được nhập trong UI:
- Access Token (từ Base.vn)
- Backend URL (mặc định: `http://localhost:3000/api`)

## 💻 Development

### Khởi động Development Server

#### Terminal 1 - Backend

```powershell
cd node_backend
pnpm dev
```

Output:
```text
Node backend listening on port 3000
```

#### Terminal 2 - Frontend

```powershell
cd web_vue
pnpm dev
```

Output:
```text
  VITE v6.0.5  ready in 500 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: http://192.168.1.100:5173/
  ➜  press h + enter to show help
```

### Development Workflow

1. **Backend Changes:** Nodemon tự động restart server
2. **Frontend Changes:** Vite HMR instant update (< 100ms)
3. **Style Changes:** Hot reload without page refresh
4. **State Preserved:** Vue keeps component state during HMR

### Debugging

#### Frontend (Chrome DevTools)

1. Mở DevTools (F12)
2. Sources → `web_vue/src/`
3. Set breakpoints trong `.vue` files
4. Source maps được enable mặc định

#### Backend (VS Code)

Tạo `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Backend",
      "program": "${workspaceFolder}/node_backend/src/server.js",
      "runtimeExecutable": "pnpm",
      "runtimeArgs": ["dev"],
      "console": "integratedTerminal",
      "skipFiles": ["<node_internals>/**"]
    }
  ]
}
```

### Code Quality

```powershell
# Lint frontend
cd web_vue
pnpm lint

# Lint backend
cd node_backend
pnpm lint
```

## 🚀 Production Build & Deploy

### Build Frontend

```powershell
cd web_vue
pnpm build
```

Output: `web_vue/dist/` (optimized, minified)

### Preview Production Build

```powershell
cd web_vue
pnpm preview
# ➜ http://localhost:4173
```

### Deployment Options

#### 1. Vercel (Recommended)

```powershell
# Install Vercel CLI
npm install -g vercel

# Deploy
cd web_vue
vercel --prod
```

**vercel.json:**
```json
{
  "buildCommand": "pnpm build",
  "outputDirectory": "dist",
  "framework": "vite"
}
```

#### 2. Netlify

```powershell
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
cd web_vue
netlify deploy --prod --dir=dist
```

**netlify.toml:**
```toml
[build]
  command = "pnpm build"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

#### 3. Static Hosting (Nginx)

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/base-vn-app/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # API proxy to backend
    location /api {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

#### 4. Docker

**Dockerfile (Frontend):**
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Dockerfile (Backend):**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile --prod
COPY src ./src
EXPOSE 3000
CMD ["node", "src/server.js"]
```

**docker-compose.yml:**
```yaml
version: '3.8'
services:
  backend:
    build: ./node_backend
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
      - NODE_ENV=production

  frontend:
    build: ./web_vue
    ports:
      - "80:80"
    depends_on:
      - backend
```

## 📚 API Documentation

### Base URL

Development: `http://localhost:3000/api`
Production: `https://your-domain.com/api`

### Endpoints

#### 1. Health Check

```http
GET /health
```

Response:
```json
{
  "status": "ok",
  "timestamp": 1697520000000
}
```

#### 2. List Openings

```http
POST /api/openings
Content-Type: application/json

{
  "access_token": "your-token",
  "page": 1,
  "num_per_page": 50,
  "order_by": "starred"
}
```

Response:
```json
{
  "success": true,
  "openings": [...],
  "pagination": {
    "page": 1,
    "num_per_page": 50,
    "total": 100,
    "count": 50
  }
}
```

#### 3. Get Opening Detail

```http
POST /api/openings/:id
Content-Type: application/json

{
  "access_token": "your-token"
}
```

#### 4. List Candidates

```http
POST /api/candidates
Content-Type: application/json

{
  "access_token": "your-token",
  "opening_id": "9346",
  "stage": "75440",
  "page": 1,
  "num_per_page": 50
}
```

Response:
```json
{
  "success": true,
  "metrics": {
    "total": 150,
    "count": 50,
    "page": 1,
    "num_per_page": 50
  },
  "candidates_table": [
    {
      "id": "518156",
      "full_name": "Nguyễn Văn A",
      "email": "nguyenvana@example.com",
      "phone": "0123456789",
      "stage_name": "Interview",
      "cv_link": "https://..."
    }
  ]
}
```

## 🧪 Testing

### Unit Tests (Future)

```powershell
# Frontend
cd web_vue
pnpm test

# Backend
cd node_backend
pnpm test
```

### Manual Testing Checklist

- [ ] Load openings successfully
- [ ] Select opening and stage
- [ ] Fetch candidates list
- [ ] View candidate details
- [ ] View candidate messages
- [ ] Responsive on mobile (< 768px)
- [ ] Touch interactions work smoothly
- [ ] Modal opens and closes correctly
- [ ] Data persists in LocalStorage
- [ ] Error handling displays properly

## 🐛 Troubleshooting

### Common Issues

#### 1. pnpm not found

```powershell
npm install -g pnpm
# Restart terminal
```

#### 2. Port already in use

Backend:
```env
# Change in node_backend/.env
PORT=3001
```

Frontend: Vite auto-increments port (5174, 5175...)

#### 3. CORS errors

Check `node_backend/.env`:
```env
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://192.168.1.100:5173
```

#### 4. Module not found

```powershell
# Clear cache and reinstall
pnpm store prune
rm -rf node_modules
pnpm install
```

#### 5. Build fails

```powershell
# Clean build
rm -rf dist .vite
pnpm build --force
```

#### 6. Mobile can't connect

- Check firewall settings
- Use Network address (not localhost)
- Ensure same WiFi network
- Try different port if blocked

## 📊 Performance Optimization

### Frontend

- ✅ Code splitting by route
- ✅ Lazy loading components
- ✅ Minification (Terser)
- ✅ Tree shaking
- ✅ Asset compression
- ✅ Image optimization (future)

### Backend

- ✅ Request timeout (30s)
- ✅ CORS caching
- ✅ Response compression (add gzip)
- ⏳ Rate limiting (production)
- ⏳ Caching layer (Redis)

## 🔐 Security Considerations

### Current Implementation

- ✅ Token not stored on server
- ✅ CORS configured
- ✅ Environment variables
- ✅ No sensitive data in git

### Production Recommendations

- [ ] Add rate limiting (express-rate-limit)
- [ ] Implement authentication middleware
- [ ] Add request validation (Joi/Zod)
- [ ] Enable HTTPS only
- [ ] Add security headers (helmet)
- [ ] Implement API key rotation
- [ ] Add monitoring (Sentry)

## 📝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Code Style

- Use ESLint + Prettier
- Follow Vue 3 Composition API best practices
- Write descriptive commit messages
- Add comments for complex logic

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Credits

- Vue.js Team
- Vite Team
- pnpm Contributors
- Express.js Community
- Base.vn API Team

---

**Project maintained by:** HoangThinh2024  
**Last updated:** October 2025

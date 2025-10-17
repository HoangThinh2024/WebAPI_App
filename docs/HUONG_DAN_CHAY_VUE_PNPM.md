# Hướng dẫn chạy ứng dụng Vue (Phiên bản pnpm)

## 🚀 Yêu cầu hệ thống

- **Node.js** 18.x LTS hoặc mới hơn: <https://nodejs.org/>
- **pnpm** 9.x hoặc mới hơn (package manager hiện đại, nhanh hơn npm/yarn)

## 📦 Cài đặt pnpm

### Windows (PowerShell)

```powershell
# Cách 1: Qua npm (nếu đã có npm)
npm install -g pnpm

# Cách 2: Qua Scoop
scoop install pnpm

# Cách 3: Qua Chocolatey
choco install pnpm
```

### Linux/macOS

```bash
# Cách 1: Qua npm
npm install -g pnpm

# Cách 2: Standalone script (khuyến nghị)
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Cách 3: Homebrew (macOS)
brew install pnpm
```

### Kiểm tra cài đặt

```powershell
pnpm --version
# Kỳ vọng: 9.x.x
```

## 🛠️ Cài đặt dependencies

```powershell
# Backend Node.js
cd node_backend
pnpm install

# Frontend Vue
cd ../web_vue
pnpm install
```

## ▶️ Chạy ứng dụng

### Terminal 1 - Backend Node.js

```powershell
cd node_backend
pnpm dev
```

Backend sẽ chạy tại: <http://localhost:3000> (API prefix: `/api`)

### Terminal 2 - Frontend Vue

```powershell
cd web_vue
pnpm dev
```

Vue app sẽ chạy tại: <http://localhost:5173>

**Lưu ý:** Frontend đã được cấu hình proxy tự động tới backend, bạn có thể truy cập từ:

- Desktop: <http://localhost:5173>
- Mobile (cùng mạng LAN): <http://[IP-máy-tính]:5173>

## 📱 Truy cập từ thiết bị di động

Sau khi chạy `pnpm dev`, Vite sẽ hiển thị:

```text
  ➜  Local:   http://localhost:5173/
  ➜  Network: http://192.168.1.100:5173/
```

Sử dụng địa chỉ **Network** để truy cập từ điện thoại/tablet trong cùng mạng WiFi.

## 🌐 Sử dụng ứng dụng

1. Mở trình duyệt: <http://localhost:5173>
2. Nhập **Access Token** (lấy từ Base.vn)
3. Nhập **Backend API URL** (mặc định: `http://localhost:3000/api`)
4. Bấm **🔄 Tải Openings**
5. Chọn **Opening** và **Stage** từ dropdown
6. Bấm **🚀 Gửi yêu cầu API**
7. Nhấn **Xem chi tiết** để mở modal thông tin ứng viên

## ✨ Tính năng nổi bật

### 🎨 Responsive Design

- Tự động điều chỉnh layout cho desktop, tablet và mobile
- Table responsive với horizontal scroll trên màn hình nhỏ
- Ẩn các cột không quan trọng trên mobile
- Touch-friendly buttons và spacing

### ⚡ Performance

- **pnpm**: Cài đặt nhanh hơn 2-3x so với npm
- **Vite HMR**: Hot Module Replacement instant
- Code splitting tự động
- Lazy loading cho modal
- Optimized bundle size

### 🔄 Cross-platform

- Chạy trên Windows, macOS, Linux
- Responsive trên iOS Safari, Android Chrome
- PWA-ready (có thể cải tiến thành Progressive Web App)

### 🎯 Developer Experience

- ESLint + Prettier tích hợp
- VS Code extension support
- TypeScript definitions (qua JSDoc)
- Hot reload không mất state

## 🏗️ Build Production

```powershell
cd web_vue
pnpm build
```

Output tại `web_vue/dist/` - sẵn sàng deploy lên:

- Vercel / Netlify (hosting tĩnh)
- AWS S3 + CloudFront
- GitHub Pages
- Bất kỳ web server nào (Nginx, Apache, ...)

### Preview production build

```powershell
pnpm preview
```

## 🐛 Troubleshooting

### pnpm command not found

```powershell
# Cài đặt pnpm globally
npm install -g pnpm

# Hoặc sử dụng npx
npx pnpm install
```

### Port 5173 đã được sử dụng

Vite sẽ tự động chọn port tiếp theo (5174, 5175...). Hoặc chỉnh thủ công trong `vite.config.js`:

```js
server: {
  port: 5174, // port mới
}
```

### CORS error khi gọi API

- Đảm bảo Node backend đang chạy tại `http://localhost:3000`
- Kiểm tra cấu hình proxy trong `vite.config.js`
- Trên production, cấu hình backend URL trong input field

### Không kết nối từ mobile

- Kiểm tra firewall Windows/macOS
- Đảm bảo cùng mạng WiFi
- Sử dụng địa chỉ IP thay vì `localhost`

```powershell
# Windows: lấy IP
ipconfig | findstr IPv4

# macOS/Linux: lấy IP
ifconfig | grep inet
```

### pnpm install quá chậm

```powershell
# Xóa cache và cài lại
pnpm store prune
pnpm install --force
```

## 📚 pnpm Workspace (Tùy chọn nâng cao)

Để quản lý monorepo tốt hơn, có thể tạo `pnpm-workspace.yaml`:

```yaml
packages:
  - 'node_backend'
  - 'web_vue'
  - 'streamlit_app'
```

Sau đó chạy từ root:

```powershell
# Cài đặt tất cả
pnpm install -r

# Chạy scripts
pnpm --filter web_vue dev
pnpm --filter node_backend dev
```

## 🔧 Scripts có sẵn

### Backend (`node_backend/`)

- `pnpm dev` - Chạy với nodemon (auto-reload)
- `pnpm start` - Chạy production mode
- `pnpm lint` - Kiểm tra code style

### Frontend (`web_vue/`)

- `pnpm dev` - Chạy dev server với HMR
- `pnpm build` - Build cho production
- `pnpm preview` - Preview production build
- `pnpm lint` - Kiểm tra code style (Vue, JS)

## 🎓 Tài liệu tham khảo

- [pnpm Documentation](https://pnpm.io/)
- [Vite Documentation](https://vitejs.dev/)
- [Vue 3 Documentation](https://vuejs.org/)
- [Axios Documentation](https://axios-http.com/)
- [Express.js Documentation](https://expressjs.com/)

## 📝 Ghi chú

- pnpm sử dụng **hard links** và **symbolic links** để tiết kiệm dung lượng đĩa
- Tất cả packages được lưu trong global store (`~/.pnpm-store`)
- Nhanh hơn và tiết kiệm không gian hơn npm/yarn đáng kể
- Tương thích 100% với npm packages

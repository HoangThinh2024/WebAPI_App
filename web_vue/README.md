# Base.vn Candidate Explorer - Vue + Node.js (pnpm)

Modern responsive web application để quản lý ứng viên từ Base.vn API.

## 🎯 Công nghệ sử dụng

- **Frontend:** Vue 3 (Composition API) + Vite
- **Backend:** Node.js + Express
- **Package Manager:** pnpm (nhanh, tiết kiệm dung lượng)
- **Styling:** CSS3 với responsive design
- **HTTP Client:** Axios

## 🚀 Quick Start

```powershell
# Cài đặt pnpm (nếu chưa có)
npm install -g pnpm

# Cài đặt dependencies
cd node_backend
pnpm install

cd ../web_vue
pnpm install

# Chạy backend (Terminal 1)
cd node_backend
pnpm dev

# Chạy frontend (Terminal 2)
cd web_vue
pnpm dev
```

Truy cập: <http://localhost:5173>

## 📱 Responsive Features

- ✅ Desktop, tablet, mobile responsive
- ✅ Touch-friendly interface
- ✅ Adaptive layout với CSS Grid & Flexbox
- ✅ Hidden columns trên mobile để tối ưu không gian
- ✅ Smooth animations & transitions
- ✅ Dark mode tối ưu cho mọi thiết bị

## 🌐 Cross-platform Testing

### Desktop

- Windows: Edge, Chrome, Firefox
- macOS: Safari, Chrome, Firefox
- Linux: Chrome, Firefox

### Mobile

- iOS: Safari Mobile (iPhone/iPad)
- Android: Chrome Mobile
- Truy cập qua LAN: `http://[YOUR-IP]:5173`

## 🎨 Responsive Breakpoints

```css
/* Mobile First */
Base: < 480px (mobile)
Small: 480px - 768px (large mobile, small tablet)
Medium: 768px - 1024px (tablet)
Large: 1024px+ (desktop)
```

## 📦 Build & Deploy

```powershell
cd web_vue
pnpm build
```

Deploy `dist/` folder lên:

- Vercel (khuyến nghị)
- Netlify
- AWS S3 + CloudFront
- GitHub Pages
- Nginx/Apache

## 📚 Documentation

- [HUONG_DAN_CHAY_VUE_PNPM.md](../HUONG_DAN_CHAY_VUE_PNPM.md) - Hướng dẫn chi tiết
- [README_PROJECT.md](../README_PROJECT.md) - Tổng quan dự án

## ⚡ Performance

- pnpm: ~50% faster than npm
- Vite HMR: < 100ms update time
- Build size: ~150KB (gzipped)
- Lighthouse score: 95+

## 📝 License

MIT

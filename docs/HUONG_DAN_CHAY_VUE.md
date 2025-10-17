# Hướng dẫn chạy Vue App

## Bước 1: Cài đặt Node.js (nếu chưa có)

Tải và cài đặt Node.js từ: <https://nodejs.org/>

Khuyến nghị: Node.js 18 LTS hoặc mới hơn

Kiểm tra đã cài đặt:

```powershell
node --version
npm --version
```

## Bước 2: Cài đặt dependencies

```powershell
cd node_backend
npm install

# Cài đặt frontend
cd web_vue
npm install
```

Các lệnh trên sẽ cài đặt:

- **Backend:** Express, Axios, CORS, Nodemon
- **Frontend:** Vue 3, Vite, Axios, @vitejs/plugin-vue

## Bước 3: Chạy Node.js Backend

Mở Terminal 1:

```powershell
cd node_backend
npm run dev
```

Backend sẽ chạy tại: <http://localhost:3000> (API prefix: `/api`)

## Bước 4: Chạy Vue Development Server

Mở Terminal 2:

```powershell
cd web_vue
npm run dev
```

Vue app sẽ chạy tại: <http://localhost:5173>

## Bước 5: Sử dụng ứng dụng

1. Mở trình duyệt: <http://localhost:5173>
2. Nhập Access Token (và kiểm tra Backend URL nếu cần)
3. Bấm "Tải Openings"
4. Chọn Opening và Stage
5. Bấm "Gửi yêu cầu API"
6. Nhấn "Xem chi tiết" để mở modal chi tiết + tin nhắn

## Tính năng nổi bật của Vue + Vite

✅ **Hot Module Replacement (HMR)**

- Sửa code .vue file → tự động reload ngay lập tức
- Không cần refresh toàn bộ trang

✅ **Vue Extension Support**

- Syntax highlighting
- IntelliSense / autocomplete
- Error checking
- Refactoring tools

✅ **Component-based Architecture**

- Dễ tách nhỏ thành nhiều component
- Code dễ maintain và scale

✅ **Modern Build Tool**

- Vite build cực nhanh
- ES modules native
- Code splitting tự động

## Nếu không cài được Node.js

Bạn vẫn có thể dùng bản standalone Vue HTML:

**Terminal 1 - Node backend:**

```powershell
cd node_backend
npm start
```

**Terminal 2 - Static Server:**

```powershell
python -m http.server 5555
```

Mở: <http://127.0.0.1:5555/app_vue.html>

## Build Production

Sau khi hoàn thiện code, build production:

```powershell
cd web_vue
npm run build
```

Output tại `web_vue/dist/` - có thể deploy lên hosting tĩnh (Vercel, Netlify, v.v.)

## Troubleshooting

### npm install bị lỗi

- Xóa folder `node_modules` và file `package-lock.json`
- Chạy lại `npm install`

### Port 5173 đã được sử dụng

Sửa file `vite.config.js`:

```js
server: {
  port: 5174, // thay đổi port
  // ...
}
```

### CORS error

- Đảm bảo Node backend đang chạy ở <http://localhost:3000>
- Vite proxy đã cấu hình sẵn trong `vite.config.js`

## Scripts

- `npm run dev` - Chạy development server
- `npm run build` - Build production
- `npm run preview` - Preview production build locally

# 🚀 Development Scripts

Scripts để chạy app trong môi trường development.

## 📋 Scripts có sẵn:

### 1. `start-network.ps1` - Chạy Vue app trên mạng LAN

Khởi động Vue dev server và cho phép truy cập từ các máy khác trong mạng.

**Sử dụng:**

```powershell
.\start-network.ps1
```

**Chức năng:**

- ✅ Lấy local IP tự động (192.168.x.x)
- ✅ Start Vite dev server trên `0.0.0.0:5173`
- ✅ Hiển thị URL để truy cập:
  - Local: `http://localhost:5173`
  - Network: `http://192.168.x.x:5173`
- ✅ HMR (Hot Module Replacement)
- ✅ Console rõ ràng với màu sắc

**Khi chạy:**

```
🌐 Starting Vue App on Network...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Local IP: 192.168.1.100
✅ Network URL: http://192.168.1.100:5173

🚀 Starting Vite dev server...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  VITE v5.4.11  ready in 543 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: http://192.168.1.100:5173/
```

**Truy cập từ máy khác:**

1. Mở browser trên máy khác trong cùng mạng LAN
2. Vào: `http://192.168.1.100:5173`
3. Enjoy! 🎉

---

### 2. `start-backend.ps1` - Chạy Node.js backend API

Khởi động Express server để xử lý API requests.

**Sử dụng:**

```powershell
.\start-backend.ps1
```

**Chức năng:**

- ✅ Start Express server trên `http://localhost:3000`
- ✅ CORS enabled (allow từ Vue app)
- ✅ Auto reload khi code thay đổi (nodemon)
- ✅ Log requests với màu sắc

**Endpoints:**

- `GET /api/health` - Health check
- `GET /api/data` - Lấy dữ liệu
- `POST /api/data` - Tạo dữ liệu mới
- `PUT /api/data/:id` - Update dữ liệu
- `DELETE /api/data/:id` - Xóa dữ liệu

**Khi chạy:**

```
🚀 Starting Backend Server...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Server running on: http://localhost:3000
✅ CORS enabled for: http://localhost:5173
✅ Ready to accept requests!

[15:30:45] GET /api/health → 200 OK (5ms)
[15:30:47] GET /api/data → 200 OK (12ms)
```

---

## 🔄 Workflow phát triển:

### Chạy full stack:

```powershell
# Terminal 1: Start backend
.\start-backend.ps1

# Terminal 2: Start frontend trên network
.\start-network.ps1
```

### Chỉ chạy frontend:

```powershell
# Nếu không cần backend
.\start-network.ps1
```

---

## 🌐 Network Setup:

### Windows Firewall:

Nếu máy khác không truy cập được, mở port 5173:

```powershell
# Allow Vite port
New-NetFirewallRule -DisplayName "Vite Dev Server" `
    -Direction Inbound -LocalPort 5173 -Protocol TCP -Action Allow

# Allow Backend port (nếu cần)
New-NetFirewallRule -DisplayName "Node Backend" `
    -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

### Kiểm tra kết nối:

```powershell
# Kiểm tra IP local
ipconfig | Select-String "IPv4"

# Test port đang mở
Test-NetConnection -ComputerName localhost -Port 5173
```

---

## 🐛 Debug:

### Vite không start:

```powershell
# Xóa cache và rebuild
cd web_vue
Remove-Item -Recurse -Force node_modules, .vite, dist
pnpm install
```

### Port đã được dùng:

```powershell
# Kill process trên port 5173
Get-Process -Id (Get-NetTCPConnection -LocalPort 5173).OwningProcess | Stop-Process

# Hoặc dùng port khác
$env:PORT=5174; .\start-network.ps1
```

### Backend không kết nối:

```powershell
# Kiểm tra backend đang chạy
Test-NetConnection -ComputerName localhost -Port 3000

# Check CORS config trong web_vue/vite.config.js
```

---

## 📱 Hot Module Replacement (HMR):

Vite hỗ trợ HMR - code thay đổi tự động reload:

- ✅ Vue components: Instant reload
- ✅ CSS/SCSS: No page refresh
- ✅ JavaScript: Fast refresh
- ✅ State preserved (trong hầu hết trường hợp)

**Lưu ý:** HMR hoạt động trên cả local và network!

---

## 🎨 Development Features:

### Vue DevTools:

1. Install extension: [Vue DevTools](https://devtools.vuejs.org/)
2. Mở app trong browser
3. Mở DevTools (F12)
4. Tab "Vue" để inspect components

### Vite Features:

- ⚡ Lightning fast startup (~500ms)
- 🔥 HMR instant updates
- 📦 Optimized dependencies (esbuild)
- 🎯 Source maps for debugging
- 🔍 Error overlay trong browser

---

## 📚 Tài liệu liên quan:

- [Network Setup Guide](../../docs/NETWORK_SETUP.md)
- [Quick Start Guide](../../docs/QUICK_START.md)
- [Development Tips](../../docs/QUICKSTART.md)

---

## 🚨 Tips:

1. **Always start backend first** - Frontend cần API
2. **Use network URL for testing** - Test trên mobile/tablet
3. **Keep both terminals open** - Để xem logs
4. **Use Chrome/Edge** - Best Vue DevTools support

---

**Version:** 2.2.2 (Development Ready)  
**Last Updated:** 2025-10-17

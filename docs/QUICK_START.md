# 🚀 Quick Start - Network Mode

## Cách 1: Automatic (Recommended) ✅

### Bước 1: Start Backend
```powershell
.\start-backend.ps1
```

### Bước 2: Start Frontend (terminal mới)
```powershell
.\start-network.ps1
```

### Bước 3: Truy cập
- **Máy bạn:** http://localhost:5173
- **Máy khác:** http://YOUR_IP:5173

---

## Cách 2: Manual

### Terminal 1 - Backend
```powershell
cd node_backend
node src/server.js
```

### Terminal 2 - Frontend
```powershell
cd web_vue
npm run dev -- --host 0.0.0.0
```

---

## 📋 Checklist

- [ ] Backend running on port 3000
- [ ] Frontend running on port 5173
- [ ] Windows Firewall allows ports 3000 + 5173
- [ ] Both devices on same WiFi/LAN
- [ ] Using http://YOUR_IP:5173 (not localhost)

---

## 🐛 Troubleshooting

### ❌ Network Error
1. Check backend: `curl http://localhost:3000/api/health`
2. Check firewall rules in `start-network.ps1`
3. Restart both backend + frontend

### 🐌 Still laggy?
- Clear browser cache (Ctrl+Shift+Delete)
- Disable browser DevTools
- Use incognito mode

---

**Version:** 2.2.2  
**Status:** ✅ Ready for LAN sharing

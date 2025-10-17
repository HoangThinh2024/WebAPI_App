# Quick Reference - Version 2.1.0

## 🚀 Start Application

```bash
# Terminal 1 - Backend
cd node_backend
pnpm dev

# Terminal 2 - Frontend  
cd web_vue
pnpm dev
```

**URLs:**
- Backend: <http://localhost:3000>
- Frontend: <http://localhost:5173>
- Mobile: <http://192.168.1.81:5173>

## 🔐 Token Features

**Access at:** <http://localhost:5173>

1. Enter token → Click "▼" to open settings
2. Set expiry hours (1-720)
3. Toggle encryption 🔐
4. Click "💾 Save Token"
5. View status (time remaining, encrypted)

**Buttons:**
- 💾 Save - Lưu token với settings
- 📥 Load - Load từ LocalStorage
- 🗑️ Clear - Xóa token
- ⚠️ Clear All - Xóa tất cả

## 🧹 Clean Commands

```bash
pnpm clean      # Xóa node_modules, dist, cache
pnpm clean:all  # Clean + reinstall
```

## 📂 Documentation

| File | Description |
|------|-------------|
| `COMPLETED_2.1.0.md` | ✅ Task completion report |
| `RELEASE_2.1.0.md` | Full release notes |
| `RELEASE_SUMMARY.md` | Quick overview |
| `GIT_COMMIT_GUIDE.md` | Git commit instructions |
| `CHANGELOG.md` | Version history |
| `scripts/README.md` | Clean scripts guide |

## 🔒 Token Storage

**Windows Chrome:**
```
C:\Users\[USER]\AppData\Local\Google\Chrome\User Data\Default\Local Storage\leveldb\
```

**View in Browser:**
F12 → Application → Local Storage → `http://localhost:5173`

**Keys:**
- `base_access_token` (encrypted if enabled)
- `base_backend_url`
- `base_access_token_expiry`
- `base_encryption_enabled`

## 📦 Updated Dependencies

- pnpm: **10.0.0**
- ESLint: **9.37.0**
- Prettier: **3.6.2**
- Express: **4.21.2**
- Vue: **3.5.22**
- Vite: **6.4.0**
- crypto-js: **4.2.0** (NEW)

## 🆕 New Files

1. `scripts/clean.cjs, .ps1, .sh`
2. `web_vue/src/composables/useTokenManager.js`
3. `web_vue/src/components/TokenSettings.vue`
4. `pnpm-workspace.yaml`
5. `package.json` (root)

## ✨ Features

- [x] Token encryption (AES-256)
- [x] Token expiry timer
- [x] Token preview (masked)
- [x] Clear token functions
- [x] Auto-load on start
- [x] Clean scripts (3 platforms)
- [x] Cross-platform support

## 🎯 Next Actions

1. ✅ Test on <http://localhost:5173>
2. ✅ Try clean: `pnpm clean`
3. ✅ Test mobile access
4. 📝 Git commit (see GIT_COMMIT_GUIDE.md)
5. 🚀 Deploy

---

**Version:** 2.1.0  
**Date:** October 17, 2025  
**Status:** ✅ Complete

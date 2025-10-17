# Clean Scripts Documentation

## 📋 Mô tả

Collection của các script để dọn dẹp project, xóa dependencies, build artifacts và cache files.

## 🔧 Scripts có sẵn

### 1. **clean.js** (Node.js - Cross-platform)
```bash
# Từ web_vue hoặc node_backend
pnpm clean

# Hoặc chạy trực tiếp
node scripts/clean.js
```

### 2. **clean.ps1** (Windows PowerShell)
```powershell
# PowerShell
.\scripts\clean.ps1

# Hoặc
pwsh scripts/clean.ps1
```

### 3. **clean.sh** (Linux/macOS Bash)
```bash
# Bash
bash scripts/clean.sh

# Hoặc make executable
chmod +x scripts/clean.sh
./scripts/clean.sh
```

## 🗑️ Các file/folder sẽ bị xóa

| Path | Mô tả | Kích thước trung bình |
|------|-------|----------------------|
| `web_vue/node_modules/` | Frontend dependencies | ~200-500 MB |
| `node_backend/node_modules/` | Backend dependencies | ~50-100 MB |
| `node_modules/` | Root dependencies | Variable |
| `web_vue/dist/` | Frontend build output | ~1-5 MB |
| `node_backend/dist/` | Backend build output | ~100 KB - 1 MB |
| `web_vue/.vite/` | Vite cache | ~10-50 MB |
| `.eslintcache` | ESLint cache | ~1-10 KB |
| `*.log` | Log files | Variable |
| `.DS_Store` | macOS metadata | ~6-12 KB |
| `Thumbs.db` | Windows thumbnails | Variable |

## 🎯 Use Cases

### Clean toàn bộ project
```bash
# Xóa tất cả và reinstall
pnpm clean:all  # Từ web_vue hoặc node_backend
```

### Clean một phần cụ thể
```bash
# Chỉ xóa build outputs
rm -rf web_vue/dist node_backend/dist

# Chỉ xóa cache
rm -rf web_vue/.vite .eslintcache
```

## ⚠️ Lưu ý

1. **Backup trước khi clean**
   - Scripts sẽ xóa VĨNH VIỄN các file/folder
   - Không thể undo sau khi xóa

2. **pnpm-lock.yaml**
   - Scripts **KHÔNG** xóa `pnpm-lock.yaml`
   - File này cần được commit vào Git

3. **.env files**
   - Scripts **KHÔNG** xóa `.env` files
   - Secrets được bảo vệ

4. **Source code**
   - Scripts **KHÔNG** xóa source code trong `src/`
   - Chỉ xóa generated files

## 🚀 Workflow khuyến nghị

### Khi gặp lỗi dependency
```bash
# 1. Clean dependencies
pnpm clean

# 2. Reinstall
pnpm install

# 3. Restart dev server
pnpm dev
```

### Khi upgrade packages
```bash
# 1. Update packages
pnpm update

# 2. Clean old cache
pnpm clean

# 3. Reinstall với cache mới
pnpm install

# 4. Test
pnpm dev
```

### Trước khi deploy
```bash
# 1. Clean everything
pnpm clean

# 2. Fresh install
pnpm install --frozen-lockfile

# 3. Build production
pnpm build

# 4. Test production build
pnpm preview
```

## 📊 Performance

| Script | Execution Time | Platforms |
|--------|---------------|-----------|
| `clean.js` | ~2-5s | Windows, Linux, macOS |
| `clean.ps1` | ~3-7s | Windows only |
| `clean.sh` | ~2-4s | Linux, macOS, WSL |

## 🔍 Troubleshooting

### Permission denied (Linux/macOS)
```bash
chmod +x scripts/clean.sh
sudo bash scripts/clean.sh
```

### PowerShell execution policy (Windows)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\scripts\clean.ps1
```

### Node.js not found
```bash
# Install Node.js first
# Then run
node --version  # Should show v18+
node scripts/clean.js
```

## 🎨 Output Example

```
🧹 Clean Script - Xóa tệp build và cache

📂 Project root: C:\WebAPI_App

🔍 Scanning for files to delete...

  🗑️  Deleting: Frontend dependencies (342.5 MB)...
  ✓ Deleted: web_vue/node_modules
  
  🗑️  Deleting: Backend dependencies (87.3 MB)...
  ✓ Deleted: node_backend/node_modules
  
  ⊘ Not found: dist

============================================================
🎉 Clean completed!
📊 Files/Folders deleted: 8
💾 Disk space freed: 445.67 MB
============================================================

💡 Tip: Run 'pnpm install' to reinstall dependencies
```

## 📝 Notes

- Scripts an toàn và có thể chạy nhiều lần
- Idempotent: Chạy lại không gây lỗi
- Cross-platform compatible
- Verbose output để tracking
- Color-coded messages

## 🔗 Related Commands

```bash
# List all generated files
find . -name "node_modules" -o -name "dist" -o -name ".vite"

# Check sizes before clean
du -sh web_vue/node_modules node_backend/node_modules

# Manual clean (if scripts fail)
rm -rf web_vue/node_modules node_backend/node_modules web_vue/dist
```

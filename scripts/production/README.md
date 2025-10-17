# 🔒 Production Scripts

Scripts để kiểm tra bảo mật, build và deploy app lên production.

## 📋 Scripts có sẵn:

### 1. `auth-gate.ps1` - Xác thực người dùng
Hệ thống authentication với SHA256 hashing.

**Sử dụng:**
```powershell
# Thêm user mới
.\auth-gate.ps1 -Action add-user

# Xóa user
.\auth-gate.ps1 -Action remove-user

# Liệt kê users
.\auth-gate.ps1 -Action list-users

# Reset password
.\auth-gate.ps1 -Action reset-password
```

**Features:**
- SHA256 password hashing
- Multi-user support
- 3 login attempts
- Role-based (admin/user)

---

### 2. `security-audit.ps1` - Kiểm tra bảo mật
Quét toàn bộ project để tìm lỗ hổng bảo mật.

**Sử dụng:**
```powershell
.\security-audit.ps1
```

**Kiểm tra:**
- ✅ Hardcoded secrets (API keys, passwords)
- ✅ Dependencies vulnerabilities (npm audit)
- ✅ eval() usage (code injection risk)
- ✅ console.log statements
- ✅ File permissions
- ✅ CORS configuration
- ✅ Environment variables

**Output:**
- Terminal report với màu sắc
- JSON report: `security-audit-report.json`
- Exit code: 0 (pass), 1 (failed)

---

### 3. `security-fix.ps1` - Sửa lỗi bảo mật nhanh
Quick fix cho các lỗi thường gặp.

**Sử dụng:**
```powershell
# Fix XSS protection
.\security-fix.ps1 -XSS

# Fix file permissions (requires Admin)
.\security-fix.ps1 -Permissions

# Setup environment files
.\security-fix.ps1 -Environment

# Fix tất cả
.\security-fix.ps1 -All
```

**Fixes:**
- **XSS**: Install DOMPurify, tạo sanitizer utility
- **Permissions**: Restrict ACL cho .env files
- **Environment**: Tạo .env và .env.production

---

### 4. `cleanup.ps1` - Dọn dẹp cache/logs
Xóa cache, logs, temp files để giải phóng dung lượng.

**Sử dụng:**
```powershell
# Xem sẽ xóa gì (dry-run)
.\cleanup.ps1 -DryRun

# Dọn dẹp thực tế
.\cleanup.ps1

# Deep clean (xóa cả node_modules)
.\cleanup.ps1 -DeepClean

# Chỉ dọn Vue project
.\cleanup.ps1 -TargetPath "web_vue"
```

**Xóa:**
- Vite cache (.vite)
- Node modules cache (.cache)
- Build outputs (dist, build)
- Log files (*.log)
- Temp files (.tmp, .temp)

---

### 5. `build-production.ps1` - Build app production
Build app với optimization cho production.

**Sử dụng:**
```powershell
.\build-production.ps1
```

**Quy trình:**
1. ✅ Security audit
2. ✅ Dependencies check
3. ✅ Clean old build
4. ✅ Install dependencies (pnpm)
5. ✅ Build với Vite (minify, tree-shaking)
6. ✅ Generate manifest.json
7. ✅ Size report

---

### 6. `deploy-production.ps1` - Deploy automation
Full deployment workflow với checklist.

**Sử dụng:**
```powershell
# Deploy local (test)
.\deploy-production.ps1 -DeployTarget local

# Deploy to server
.\deploy-production.ps1 -DeployTarget server -ServerPath "\\server\path"

# Deploy to cloud
.\deploy-production.ps1 -DeployTarget cloud
```

**Quy trình:**
1. 🔐 Authentication check
2. ✅ Git status check
3. ✅ Security audit
4. ✅ Tests run
5. ✅ Build production
6. 📦 Create deployment package (ZIP)
7. 🚀 Deploy to target
8. 📋 Generate deployment checklist

**Deployment checklist:**
- Server requirements
- Environment variables
- Database migrations
- SSL certificates
- Firewall rules
- Backup verification

---

## 🔄 Workflow đầy đủ:

```powershell
# 1. Setup authentication
.\auth-gate.ps1 -Action add-user

# 2. Kiểm tra bảo mật
.\security-audit.ps1

# 3. Fix lỗi nếu có
.\security-fix.ps1 -All

# 4. Dọn dẹp
.\cleanup.ps1

# 5. Build production
.\build-production.ps1

# 6. Deploy
.\deploy-production.ps1 -DeployTarget local
```

---

## 📊 Security Audit Report

File `security-audit-report.json` chứa kết quả kiểm tra:

```json
{
  "TotalIssues": 6,
  "Critical": 0,    // ❌ Blocking issues
  "Warnings": 3,    // ⚠️ Should fix
  "Info": 3,        // ℹ️ Recommendations
  "Timestamp": "2025-10-17 15:50:03"
}
```

**Status codes:**
- Critical = 0: ✅ **PASS** - Sẵn sàng deploy
- Critical > 0: ❌ **FAILED** - Phải fix trước khi deploy

---

## 🚨 Lưu ý:

1. **Chạy security-audit trước khi deploy**
   ```powershell
   .\security-audit.ps1
   # Exit code = 0 → OK to deploy
   ```

2. **Fix permissions (Windows Admin required)**
   ```powershell
   # Run PowerShell as Administrator
   .\security-fix.ps1 -Permissions
   ```

3. **Backup trước khi deploy**
   ```powershell
   # Script tự động tạo backup ZIP
   .\deploy-production.ps1 -DeployTarget local
   ```

4. **Test local trước khi deploy server**
   ```bash
   # Test trên localhost trước
   .\deploy-production.ps1 -DeployTarget local
   # Sau đó mới deploy lên server
   ```

---

## 📚 Tài liệu liên quan:

- [Security Deployment Guide](../../docs/SECURITY_DEPLOYMENT_GUIDE.md)
- [Quick Reference](../../docs/QUICK_REFERENCE.md)
- [Git Commit Guide](../../docs/GIT_COMMIT_GUIDE.md)

---

**Version:** 2.2.2 (Production Ready)  
**Last Updated:** 2025-10-17

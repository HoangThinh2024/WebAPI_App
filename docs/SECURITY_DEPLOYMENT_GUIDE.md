# 🔒 Production Security & Deployment Guide

## 📋 Tổng quan

Hệ thống scripts tự động cho production deployment với đầy đủ security checks, authentication, và automation.

---

## 🎯 Scripts có sẵn

### 1. **`auth-gate.ps1`** - Cổng xác thực
Yêu cầu đăng nhập trước khi thực hiện bất kỳ thao tác nào.

**Sử dụng:**
```powershell
# Đăng nhập và chọn action
.\auth-gate.ps1

# Thêm user mới
.\auth-gate.ps1 -Action add-user

# Xóa user
.\auth-gate.ps1 -Action remove-user -Username "john"

# Liệt kê users
.\auth-gate.ps1 -Action list-users
```

**⚠️ QUAN TRỌNG:** Đổi mật khẩu admin mặc định ngay!
```powershell
.\auth-gate.ps1 -Action add-user
# Username: admin
# Password: <your-strong-password>
```

---

### 2. **`security-audit.ps1`** - Kiểm tra bảo mật
Quét toàn bộ codebase tìm lỗ hổng bảo mật.

**Kiểm tra:**
- ✅ Hardcoded secrets (API keys, passwords, tokens)
- ✅ Dependencies vulnerabilities (npm audit, safety)
- ✅ Console.log statements
- ✅ eval() usage
- ✅ v-html without sanitization
- ✅ CORS configuration
- ✅ File permissions
- ✅ .gitignore completeness

**Sử dụng:**
```powershell
# Chạy audit
.\security-audit.ps1

# Output: security-audit-report.json
```

**Kết quả:**
- ✅ **PASSED**: An toàn, có thể deploy
- ⚠️ **PASSED WITH WARNINGS**: Có cảnh báo, review trước khi deploy
- ❌ **FAILED**: Có lỗi critical, KHÔNG được deploy!

---

### 3. **`cleanup.ps1`** - Dọn dẹp
Xóa cache, logs, temp files, và build artifacts.

**Sử dụng:**
```powershell
# Clean cache và builds
.\cleanup.ps1 -Cache

# Clean logs
.\cleanup.ps1 -Logs

# Deep clean (including node_modules)
.\cleanup.ps1 -Deep

# Clean everything (bao gồm sensitive data)
.\cleanup.ps1 -All

# Dry run (xem sẽ xóa gì mà không thực sự xóa)
.\cleanup.ps1 -All -DryRun
```

**Xóa:**
- 🗑️ `dist/` folders
- 🗑️ `.vite/` cache
- 🗑️ `node_modules/.cache/`
- 🗑️ `__pycache__/`
- 🗑️ `*.log` files
- 🗑️ `*.tmp` files
- 🗑️ (Optional) `node_modules/`
- 🗑️ (Optional) `.env` files

---

### 4. **`build-production.ps1`** - Build production
Build ứng dụng cho production với optimization.

**Sử dụng:**
```powershell
# Build với đầy đủ checks
.\build-production.ps1

# Build nhanh (skip audit và tests)
.\build-production.ps1 -SkipAudit -SkipTests
```

**Quy trình:**
1. ✅ Security audit
2. ✅ Clean old builds
3. ✅ Set NODE_ENV=production
4. ✅ Install dependencies
5. ✅ Build frontend (Vite)
6. ✅ Prepare backend
7. ✅ Optimize assets
8. ✅ Generate manifest
9. ✅ Create deployment package

**Output:**
- 📦 `web_vue/dist/` - Frontend build
- 📦 `deploy/` - Deployment package
- 📄 `deploy/README.md` - Deployment guide
- 📄 `build-manifest.json` - Build info

---

### 5. **`deploy-production.ps1`** - Deploy tự động
Tự động hóa toàn bộ quy trình deployment.

**Sử dụng:**
```powershell
# Deploy local (test)
.\deploy-production.ps1 -DeployTarget local

# Deploy staging
.\deploy-production.ps1 -DeployTarget staging

# Deploy production (YÊU CẦU XÁC NHẬN!)
.\deploy-production.ps1 -DeployTarget production

# Auto-confirm (không hỏi)
.\deploy-production.ps1 -DeployTarget local -AutoConfirm
```

**Quy trình:**
1. 🔐 Authentication required
2. ✅ Pre-deployment checks (Git, disk space)
3. 🔒 Security audit
4. 🧹 Cleanup old builds
5. 🏗️ Production build
6. 🧪 Testing
7. 📦 Create deployment archive
8. 🚀 Deploy to target
9. 📊 Generate report

**Output:**
- 📦 `webapi-app-v2.2.2-<timestamp>.zip` - Deployment archive
- 📋 `deployment-checklist-<timestamp>.md` - Production checklist

---

## 🚀 Workflow đầy đủ

### Development → Production

```powershell
# 1. Hoàn thành development
git add .
git commit -m "Feature complete"

# 2. Xác thực
.\auth-gate.ps1

# 3. Dọn dẹp
.\cleanup.ps1 -Cache

# 4. Kiểm tra bảo mật
.\security-audit.ps1

# 5. Build production
.\build-production.ps1

# 6. Test local
cd deploy
.\start-production.ps1

# 7. Deploy staging
.\deploy-production.ps1 -DeployTarget staging

# 8. Test staging
# Open https://staging.your-domain.com

# 9. Deploy production
.\deploy-production.ps1 -DeployTarget production
```

---

## 🔒 Security Best Practices

### 1. Authentication

**✅ DO:**
- Đổi mật khẩu admin mặc định ngay lập tức
- Sử dụng mật khẩu mạnh (>12 ký tự, chữ hoa, chữ thường, số, ký tự đặc biệt)
- Giới hạn số lần đăng nhập sai
- Log tất cả authentication attempts

**❌ DON'T:**
- Dùng mật khẩu mặc định
- Share credentials qua email/chat
- Lưu passwords trong code

### 2. Secrets Management

**✅ DO:**
- Lưu secrets trong `.env` files (add to `.gitignore`)
- Sử dụng environment variables
- Encrypt sensitive data at rest
- Rotate secrets định kỳ

**❌ DON'T:**
- Hardcode API keys trong code
- Commit `.env` files to Git
- Share secrets qua public channels

### 3. Dependencies

**✅ DO:**
- Chạy `npm audit` định kỳ
- Update dependencies thường xuyên
- Review security advisories
- Use lock files (`package-lock.json`, `pnpm-lock.yaml`)

**❌ DON'T:**
- Ignore security warnings
- Use outdated packages
- Install packages từ untrusted sources

### 4. Code Security

**✅ DO:**
- Remove `console.log` trước production
- Sanitize HTML content (use DOMPurify)
- Validate user input
- Use parameterized queries
- Enable HTTPS
- Set security headers

**❌ DON'T:**
- Use `eval()`
- Trust user input
- Expose sensitive data in errors
- Use `v-html` without sanitization

---

## 🛡️ Security Checklist

### Pre-Deployment

- [ ] Security audit passed (no critical issues)
- [ ] No hardcoded secrets
- [ ] All dependencies updated
- [ ] No console.log in production code
- [ ] CORS configured properly
- [ ] Authentication enabled
- [ ] `.gitignore` includes sensitive files
- [ ] Environment variables set correctly

### Post-Deployment

- [ ] HTTPS enabled (Let's Encrypt)
- [ ] Firewall configured
- [ ] Rate limiting enabled
- [ ] Monitoring setup (logs, errors)
- [ ] Backups configured
- [ ] Disaster recovery plan documented

---

## 📊 Report Files

### `security-audit-report.json`

```json
{
  "Timestamp": "2025-10-17 14:30:00",
  "TotalIssues": 3,
  "Critical": 0,
  "Warnings": 2,
  "Issues": [
    {
      "Severity": "WARNING",
      "Category": "Code Quality",
      "Description": "5 console.log statements found",
      "Fix": "Remove or wrap in if(DEBUG) checks"
    }
  ]
}
```

### `build-manifest.json`

```json
{
  "BuildDate": "2025-10-17 14:35:00",
  "Version": "2.2.2",
  "Environment": "production",
  "Frontend": {
    "Framework": "Vue 3 + Vite",
    "BuildSize": "2.5 MB",
    "Files": 42
  },
  "SecurityAudit": {
    "Passed": true,
    "Date": "2025-10-17 14:30:00"
  }
}
```

---

## 🚨 Troubleshooting

### Security Audit Failed

**Problem:** Critical issues found

**Solution:**
1. Check `security-audit-report.json`
2. Fix each issue:
   - Hardcoded secrets → Move to `.env`
   - Dependencies → Run `npm audit fix`
   - Console.log → Remove from code
3. Re-run audit: `.\security-audit.ps1`

### Build Failed

**Problem:** npm/pnpm errors

**Solution:**
```powershell
# Clear cache
.\cleanup.ps1 -Deep

# Reinstall dependencies
cd web_vue
pnpm install

# Retry build
.\build-production.ps1
```

### Authentication Failed

**Problem:** Can't login

**Solution:**
```powershell
# Reset admin password
Remove-Item .auth\users.json -Force
.\auth-gate.ps1 -Action add-user
# Username: admin
# Password: <new-password>
```

### Deploy Archive Too Large

**Problem:** Archive > 100MB

**Solution:**
```powershell
# Remove source maps
# In vite.config.js:
build: {
  sourcemap: false
}

# Rebuild
.\build-production.ps1
```

---

## 📞 Emergency Rollback

Nếu production deployment gặp vấn đề:

```bash
# SSH to server
ssh user@production-server

# Stop services
pm2 stop webapi-backend

# Restore backup
rm -rf /var/www/webapi-app
mv /var/www/webapi-app.backup /var/www/webapi-app

# Restart
pm2 start webapi-backend
pm2 save

# Verify
curl https://your-domain.com/api/health
```

---

## 🎓 Training Checklist

Đảm bảo team biết cách:

- [ ] Chạy security audit
- [ ] Build production
- [ ] Deploy to staging
- [ ] Rollback if needed
- [ ] Monitor production logs
- [ ] Respond to security incidents

---

## 📚 Additional Resources

- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **Node.js Security**: https://nodejs.org/en/docs/guides/security/
- **Vue Security**: https://vuejs.org/guide/best-practices/security.html
- **Let's Encrypt**: https://letsencrypt.org/

---

**Version:** 2.2.2  
**Last Updated:** October 17, 2025  
**Status:** ✅ Production Ready

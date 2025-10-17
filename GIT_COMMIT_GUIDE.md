# Git Commit Guide for v2.1.0

## Commit Message

```bash
git add .
git commit -m "🔐 Release v2.1.0 - Token Security & Clean Scripts

✨ New Features:
- Token Manager với AES-256 encryption
- TokenSettings component với real-time status
- Token expiry timer (configurable hours)
- Token preview với show/hide
- Cross-platform clean scripts (Node.js, PS1, Bash)
- pnpm workspace configuration
- Auto-load token on app start

📦 Dependencies Updated:
- pnpm: 9.0.0 → 10.0.0
- ESLint: 8.57.0 → 9.37.0
- Prettier: 3.2.5 → 3.6.2
- Express: 4.19.2 → 4.21.2
- All packages to October 2025 versions

🔧 New Files:
- scripts/clean.cjs, clean.ps1, clean.sh
- web_vue/src/composables/useTokenManager.js
- web_vue/src/components/TokenSettings.vue
- pnpm-workspace.yaml
- package.json (root)
- RELEASE_2.1.0.md, RELEASE_SUMMARY.md

🐛 Fixes:
- .gitignore now commits pnpm-lock.yaml
- LocalStorage key names standardized
- Token input type changed to password

📝 Documentation:
- CHANGELOG.md updated to v2.1.0
- scripts/README.md with clean scripts guide
- Complete release documentation

Breaking Changes:
- LocalStorage key names changed (auto-migrated)
- Token expiry now required (default 24h)
- New dependency: crypto-js

See RELEASE_2.1.0.md for full details."
```

## Alternative Conventional Commits

```bash
# Short version
git commit -m "feat: add token security and clean scripts (v2.1.0)

- Token Manager with AES-256 encryption
- TokenSettings UI component
- Cross-platform clean scripts
- Update all dependencies to latest
- pnpm workspace configuration

BREAKING CHANGE: LocalStorage keys renamed"
```

## Push to GitHub

```bash
# Push changes
git push origin main

# Create release tag
git tag -a v2.1.0 -m "Version 2.1.0 - Token Security Update"
git push origin v2.1.0
```

## GitHub Release Notes

**Title:** v2.1.0 - Token Security & Clean Scripts

**Description:**

## 🔐 Token Security Features

This release adds comprehensive token management with encryption and expiry controls:

- ✅ **AES-256 Encryption** - Optional token encryption in LocalStorage
- ✅ **Token Expiry** - Auto-expire tokens after configurable hours
- ✅ **Token Preview** - Masked display with show/hide toggle
- ✅ **Clear Functions** - Safe token deletion with confirmation
- ✅ **Auto-load** - Automatically load saved tokens on app start

## 🧹 Clean Scripts

Cross-platform scripts to clean build artifacts:

```bash
pnpm clean      # Remove node_modules, dist, cache
pnpm clean:all  # Clean + reinstall dependencies
```

Works on Windows (PowerShell), Linux, and macOS (Bash).

## 📦 Dependencies Updated

All packages updated to October 2025 versions:

- pnpm: 10.0.0
- ESLint: 9.37.0
- Express: 4.21.2
- And more...

## 🚀 Quick Start

```bash
pnpm install
pnpm dev:backend  # Terminal 1
pnpm dev:frontend # Terminal 2
```

Visit http://localhost:5173 to test token features!

## 📝 Documentation

- [Release Notes](RELEASE_2.1.0.md) - Full details
- [Summary](RELEASE_SUMMARY.md) - Quick overview
- [Changelog](CHANGELOG.md) - Version history

## ⚠️ Breaking Changes

- LocalStorage key names changed (old tokens auto-migrated)
- Token expiry now required (default 24h)
- New dependency: crypto-js

See [Migration Guide](CHANGELOG.md#migration-guide) for upgrade instructions.

---

**Full Changelog**: https://github.com/HoangThinh2024/WebAPI_App/compare/v2.0.0...v2.1.0

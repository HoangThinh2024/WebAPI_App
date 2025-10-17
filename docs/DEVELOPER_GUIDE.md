# 👨‍💻 Developer Guide - WebAPI_App v2.2.2

> Hướng dẫn đầy đủ cho developers clone project, setup, develop và không ảnh hưởng scripts tự động hóa

## 📋 Mục lục

1. [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
2. [Clone & Setup](#clone--setup)
3. [Cấu trúc project](#cấu-trúc-project)
4. [Development Workflow](#development-workflow)
5. [Coding Guidelines](#coding-guidelines)
6. [Testing](#testing)
7. [Git Workflow](#git-workflow)
8. [Deployment](#deployment)
9. [Troubleshooting](#troubleshooting)

---

## 🖥️ Yêu cầu hệ thống

### Required

- **Node.js** 18 LTS hoặc mới hơn ([Download](https://nodejs.org/))
- **pnpm** 9.0+ (Package manager)
- **Git** 2.30+ ([Download](https://git-scm.com/))
- **PowerShell** 7+ (Windows) hoặc Bash (Linux/Mac)

### Recommended

- **VS Code** với extensions:
  - Volar (Vue 3)
  - ESLint
  - Prettier
  - GitLens
- **Chrome** hoặc **Edge** (Vue DevTools support)

### Optional

- **Python** 3.10+ (nếu dùng Streamlit app)
- **Docker** (nếu muốn containerize)

---

## 🚀 Clone & Setup

### 1. Clone Repository

```bash
# Clone repo
git clone https://github.com/HoangThinh2024/WebAPI_App.git
cd WebAPI_App

# Hoặc clone với SSH
git clone git@github.com:HoangThinh2024/WebAPI_App.git
cd WebAPI_App
```

### 2. Install pnpm (nếu chưa có)

```bash
# Windows PowerShell
npm install -g pnpm

# Verify
pnpm --version  # Should be 9.0+
```

### 3. Install Dependencies

```bash
# Install tất cả dependencies (workspace)
pnpm install

# Hoặc install từng project
cd web_vue && pnpm install
cd ../node_backend && pnpm install
```

### 4. Setup Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env với thông tin của bạn
code .env  # Hoặc dùng editor khác
```

**File `.env` example:**

```env
# API Configuration
VITE_API_BASE_URL=http://localhost:3000
VITE_API_TARGET=http://localhost:3000

# Environment
NODE_ENV=development

# Base.vn API
BASE_VN_API_KEY=your_api_key_here
```

### 5. Verify Setup

```bash
# Check Node.js version
node --version  # Should be >= 18

# Check pnpm
pnpm --version  # Should be >= 9

# Check Git
git --version

# Check project structure
ls -la
```

---

## 📁 Cấu trúc project

### Overview

```
WebAPI_App/
├── 📚 docs/                    # Documentation (ĐỌC TRƯỚC!)
│   ├── README.md              # Documentation index
│   ├── QUICK_START.md         # Quick start guide
│   └── ...                    # Other docs
│
├── 🔧 scripts/                 # Automation scripts (KHÔNG SỬA!)
│   ├── production/            # Production scripts
│   │   ├── auth-gate.ps1
│   │   ├── security-audit.ps1
│   │   ├── cleanup.ps1
│   │   └── ...
│   └── development/           # Development scripts
│       ├── start-network.ps1
│       └── start-backend.ps1
│
├── 🎨 web_vue/                # Frontend - DEVELOP HERE
│   ├── src/
│   │   ├── components/       # Vue components
│   │   ├── utils/            # Utilities
│   │   ├── App.vue           # Main app
│   │   └── main.js           # Entry point
│   ├── public/               # Static assets
│   ├── package.json          # Dependencies
│   └── vite.config.js        # Vite config
│
├── ⚙️  node_backend/          # Backend - DEVELOP HERE
│   ├── server.js             # Express server
│   ├── routes/               # API routes
│   ├── middleware/           # Middleware
│   └── package.json          # Dependencies
│
├── 📊 streamlit_app/          # Streamlit (Optional)
│   ├── app.py
│   └── ...
│
└── 🚀 app-manager.ps1         # Master script (OPTIONAL)
```

### ⚠️ QUAN TRỌNG - Quy tắc phát triển:

#### ✅ CÓ THỂ SỬA (Development Areas):

```
web_vue/src/              # Frontend code
  ├── components/         ✅ Thêm/sửa Vue components
  ├── utils/              ✅ Thêm/sửa utilities
  ├── App.vue             ✅ Sửa main app
  ├── main.js             ✅ Sửa entry point
  └── style.css           ✅ Sửa styles

node_backend/             # Backend code
  ├── server.js           ✅ Sửa server logic
  ├── routes/             ✅ Thêm/sửa API routes
  ├── middleware/         ✅ Thêm/sửa middleware
  └── models/             ✅ Thêm/sửa data models

web_vue/public/           ✅ Thêm static assets
docs/                     ✅ Thêm/sửa documentation
README.md                 ✅ Sửa main README
package.json              ✅ Thêm dependencies
```

#### ❌ KHÔNG NÊN SỬA (Automation Scripts):

```
scripts/                  ❌ Scripts tự động hóa
  ├── production/         ❌ Production scripts
  └── development/        ❌ Development scripts

app-manager.ps1           ❌ Master script
deep-cleanup.ps1          ❌ Cleanup script
.gitignore                ⚠️  Hỏi team lead trước khi sửa
vite.config.js            ⚠️  Cẩn thận khi sửa
```

#### ⚠️ CẦN XIN PHÉP (Infrastructure):

```
.github/                  ⚠️  CI/CD workflows
docker-compose.yml        ⚠️  Docker config
nginx.conf                ⚠️  Server config
.env.production           ⚠️  Production environment
```

---

## 🔄 Development Workflow

### Option 1: Dùng Scripts (Recommended)

```powershell
# Start full stack với 1 lệnh
.\app-manager.ps1
# → Chọn [3] Start Full Stack

# Hoặc manual
.\scripts\development\start-backend.ps1  # Terminal 1
.\scripts\development\start-network.ps1  # Terminal 2
```

### Option 2: Manual (Không dùng scripts)

#### Terminal 1 - Backend:

```bash
cd node_backend
pnpm install
pnpm dev
# Server running on http://localhost:3000
```

#### Terminal 2 - Frontend:

```bash
cd web_vue
pnpm install
pnpm dev
# App running on http://localhost:5173
```

### Hot Reload

- ✅ **Vue components**: Auto reload khi save
- ✅ **CSS**: No page refresh
- ✅ **JavaScript**: Fast refresh
- ✅ **Backend**: Nodemon auto restart

### Development URLs

- **Frontend Local**: <http://localhost:5173>
- **Frontend Network**: <http://192.168.x.x:5173> (LAN access)
- **Backend API**: <http://localhost:3000>
- **Health Check**: <http://localhost:3000/health>

---

## 💻 Coding Guidelines

### 1. Vue 3 Component Structure

```vue
<template>
  <!-- Template: Semantic HTML, accessibility -->
  <div class="component-name">
    <h1>{{ title }}</h1>
  </div>
</template>

<script setup>
// Script: Composition API, reactive state
import { ref, computed, onMounted } from 'vue'

const title = ref('Hello World')

const computedValue = computed(() => {
  return title.value.toUpperCase()
})

onMounted(() => {
  console.log('Component mounted')
})
</script>

<style scoped>
/* Styles: Scoped, BEM naming */
.component-name {
  padding: 1rem;
}
</style>
```

### 2. Naming Conventions

**Components:**
```
PascalCase: MyComponent.vue
```

**Functions:**
```javascript
camelCase: getUserData(), handleClick()
```

**Constants:**
```javascript
UPPER_SNAKE_CASE: API_BASE_URL, MAX_RETRY
```

**CSS Classes:**
```css
kebab-case: .my-component, .btn-primary
```

### 3. File Organization

**Components:**
```
web_vue/src/components/
  ├── UserProfile.vue          # Main component
  ├── UserProfileCard.vue      # Sub-component
  └── user/                    # Feature folder
      ├── UserList.vue
      └── UserDetail.vue
```

**Utilities:**
```
web_vue/src/utils/
  ├── api.js                   # API calls
  ├── helpers.js               # Helper functions
  ├── constants.js             # Constants
  └── sanitizer.js             # Sanitization
```

### 4. Code Style

**Use ESLint + Prettier:**

```bash
# Run linter
cd web_vue
pnpm lint

# Fix auto-fixable issues
pnpm lint --fix

# Format code
pnpm format
```

**Example `.eslintrc.js`:**

```javascript
module.exports = {
  extends: [
    'plugin:vue/vue3-recommended',
    'eslint:recommended',
  ],
  rules: {
    'vue/multi-word-component-names': 'off',
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'warn',
  }
}
```

### 5. Security Best Practices

#### XSS Protection:

```javascript
// ✅ GOOD: Sanitize HTML
import { sanitizeHTML } from '@/utils/sanitizer'
const safeHTML = sanitizeHTML(userInput)

// ❌ BAD: Direct HTML injection
v-html="userInput"  // Dangerous!
```

#### API Keys:

```javascript
// ✅ GOOD: Environment variables
const apiKey = import.meta.env.VITE_API_KEY

// ❌ BAD: Hardcoded
const apiKey = 'sk-1234567890abcdef'  // Never do this!
```

#### Authentication:

```javascript
// ✅ GOOD: SHA256 hashing
import crypto from 'crypto'
const hash = crypto.createHash('sha256').update(password).digest('hex')

// ❌ BAD: Plain text
const password = 'password123'  // Never store plain text!
```

---

## 🧪 Testing

### Run Tests

```bash
# Frontend tests
cd web_vue
pnpm test

# Backend tests
cd node_backend
pnpm test

# Coverage
pnpm test:coverage
```

### Write Tests

**Component Test (Vitest):**

```javascript
import { mount } from '@vue/test-utils'
import MyComponent from '@/components/MyComponent.vue'

describe('MyComponent', () => {
  it('renders properly', () => {
    const wrapper = mount(MyComponent, {
      props: { title: 'Hello' }
    })
    expect(wrapper.text()).toContain('Hello')
  })
})
```

**API Test (Jest):**

```javascript
const request = require('supertest')
const app = require('../server')

describe('GET /api/health', () => {
  it('returns 200 OK', async () => {
    const res = await request(app).get('/api/health')
    expect(res.statusCode).toBe(200)
  })
})
```

---

## 📦 Git Workflow

### Branch Strategy

```
main              # Production-ready code
├── develop       # Development branch
│   ├── feature/user-profile
│   ├── feature/dark-mode
│   ├── bugfix/login-issue
│   └── hotfix/security-patch
```

### Create Feature Branch

```bash
# Update main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/my-feature

# Work on your feature...
git add .
git commit -m "feat: add my feature"

# Push to remote
git push origin feature/my-feature
```

### Commit Messages (Conventional Commits)

```bash
# Format: <type>(<scope>): <subject>

# Examples:
git commit -m "feat(auth): add login functionality"
git commit -m "fix(api): resolve CORS issue"
git commit -m "docs(readme): update installation steps"
git commit -m "style(ui): improve button styling"
git commit -m "refactor(utils): optimize sanitizer"
git commit -m "test(user): add user component tests"
git commit -m "chore(deps): update dependencies"
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style (not CSS)
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Maintenance

### Pull Request

```bash
# 1. Push your branch
git push origin feature/my-feature

# 2. Create PR on GitHub
# 3. Request review from team
# 4. Address feedback
# 5. Merge when approved
```

### Keep Branch Updated

```bash
# Rebase on main
git checkout feature/my-feature
git fetch origin
git rebase origin/main

# Resolve conflicts if any
git add .
git rebase --continue

# Force push (if already pushed)
git push --force-with-lease
```

---

## 🚀 Deployment

### ⚠️ QUAN TRỌNG: Không tự deploy!

**Deployment được quản lý bởi scripts tự động:**

```powershell
# Production deployment (Team Lead only)
.\scripts\production\security-audit.ps1    # Step 1
.\scripts\production\build-production.ps1  # Step 2
.\scripts\production\deploy-production.ps1 # Step 3
```

### Developer's Role:

1. ✅ **Develop features** trong branch riêng
2. ✅ **Test locally** trước khi commit
3. ✅ **Create PR** với mô tả đầy đủ
4. ✅ **Wait for review** và approval
5. ❌ **KHÔNG deploy** lên production

### Preview Build (Local Testing)

```bash
# Build for production (local test)
cd web_vue
pnpm build

# Preview build
pnpm preview
# Open http://localhost:4173
```

### Docker (Optional)

```bash
# Build image
docker build -t webapi-app .

# Run container
docker run -p 5173:5173 -p 3000:3000 webapi-app
```

---

## 🐛 Troubleshooting

### 1. pnpm install fails

```bash
# Clear cache
pnpm store prune

# Remove node_modules
rm -rf node_modules
rm -rf web_vue/node_modules
rm -rf node_backend/node_modules

# Reinstall
pnpm install
```

### 2. Port already in use

```bash
# Kill process on port 5173 (Windows)
netstat -ano | findstr :5173
taskkill /PID <PID> /F

# Kill process on port 3000
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:5173 | xargs kill -9
lsof -ti:3000 | xargs kill -9
```

### 3. Hot reload not working

```bash
# Restart dev server
cd web_vue
pnpm dev

# Check Vite config
# vite.config.js should have:
server: {
  watch: {
    usePolling: true
  }
}
```

### 4. Git conflicts

```bash
# Abort merge/rebase
git merge --abort
# or
git rebase --abort

# Get latest changes
git fetch origin
git reset --hard origin/main
```

### 5. ESLint errors

```bash
# Auto-fix
cd web_vue
pnpm lint --fix

# Ignore specific rule (temporary)
/* eslint-disable-next-line rule-name */
```

### 6. Module not found

```bash
# Reinstall dependencies
pnpm install

# Check import path
import MyComponent from '@/components/MyComponent.vue'
# @ = src/ alias
```

---

## 📚 Useful Resources

### Documentation

- **Project Docs**: `docs/README.md`
- **Quick Start**: `docs/QUICK_START.md`
- **Security**: `docs/SECURITY_DEPLOYMENT_GUIDE.md`
- **Network**: `docs/NETWORK_SETUP.md`

### External Resources

- **Vue 3**: <https://vuejs.org/>
- **Vite**: <https://vitejs.dev/>
- **pnpm**: <https://pnpm.io/>
- **Express**: <https://expressjs.com/>
- **Conventional Commits**: <https://www.conventionalcommits.org/>

### Commands Cheatsheet

```bash
# pnpm
pnpm install              # Install dependencies
pnpm dev                  # Start dev server
pnpm build                # Build for production
pnpm preview              # Preview production build
pnpm lint                 # Run linter
pnpm test                 # Run tests

# Git
git status                # Check status
git log --oneline         # View commits
git branch -a             # List branches
git checkout -b <branch>  # Create branch
git merge <branch>        # Merge branch
git rebase -i HEAD~3      # Interactive rebase

# Development
npm install -g pnpm       # Install pnpm
pnpm store prune          # Clean pnpm cache
git gc --aggressive       # Optimize Git repo
```

---

## 🤝 Team Collaboration

### Code Review Guidelines

**As Reviewer:**
- ✅ Check functionality
- ✅ Review security issues
- ✅ Verify tests pass
- ✅ Check code style
- ✅ Suggest improvements

**As Developer:**
- ✅ Write clear PR description
- ✅ Add screenshots/videos
- ✅ Link related issues
- ✅ Address all feedback
- ✅ Update docs if needed

### Communication

- **Issues**: Use GitHub Issues
- **Questions**: Ask in team chat
- **Proposals**: Create RFC (Request for Comments)
- **Updates**: Comment on PRs

---

## 🎯 Quick Start Checklist

### First Time Setup

- [ ] Clone repository
- [ ] Install Node.js 18+
- [ ] Install pnpm globally
- [ ] Run `pnpm install`
- [ ] Copy `.env.example` to `.env`
- [ ] Start backend: `cd node_backend && pnpm dev`
- [ ] Start frontend: `cd web_vue && pnpm dev`
- [ ] Open <http://localhost:5173>
- [ ] Read `docs/README.md`

### Daily Development

- [ ] Pull latest changes: `git pull origin main`
- [ ] Create feature branch: `git checkout -b feature/my-feature`
- [ ] Start dev servers
- [ ] Make changes in `web_vue/src/` or `node_backend/`
- [ ] Test locally
- [ ] Commit with conventional message
- [ ] Push and create PR
- [ ] Wait for review

### Before Commit

- [ ] Run `pnpm lint`
- [ ] Run `pnpm test`
- [ ] Test in browser
- [ ] Write clear commit message
- [ ] No `console.log` in production code
- [ ] No hardcoded secrets
- [ ] Update docs if needed

---

## ⚠️ REMEMBER

### ✅ DO:

- ✅ Work in `web_vue/src/` and `node_backend/`
- ✅ Create feature branches
- ✅ Write tests
- ✅ Use conventional commits
- ✅ Ask questions
- ✅ Update documentation
- ✅ Review others' code

### ❌ DON'T:

- ❌ Edit files in `scripts/` folder
- ❌ Edit automation scripts
- ❌ Commit to `main` directly
- ❌ Deploy to production yourself
- ❌ Commit `.env` file
- ❌ Hardcode secrets
- ❌ Ignore ESLint errors

---

## 🆘 Need Help?

1. **Check documentation**: `docs/` folder
2. **Search issues**: GitHub Issues
3. **Ask team**: Team chat
4. **Read code**: Learn from existing code
5. **Experiment**: Try things in local branch

---

**Happy Coding! 🚀**

---

**Version:** 2.2.2  
**Last Updated:** 2025-10-17  
**Author:** HoangThinh2024

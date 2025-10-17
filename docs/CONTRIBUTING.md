# 🤝 Contributing to WebAPI_App

Thank you for your interest in contributing! 🎉

## 📖 Quick Links

- **Developer Guide**: [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md) - Đọc đầu tiên!
- **Quick Start**: [QUICK_START.md](./QUICK_START.md)
- **Security**: [SECURITY_DEPLOYMENT_GUIDE.md](./SECURITY_DEPLOYMENT_GUIDE.md)

---

## 🚀 Quick Start for Contributors

### 1. Fork & Clone

```bash
# Fork repo trên GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/WebAPI_App.git
cd WebAPI_App

# Add upstream
git remote add upstream https://github.com/HoangThinh2024/WebAPI_App.git
```

### 2. Setup Environment

```bash
# Install pnpm
npm install -g pnpm

# Install dependencies
pnpm install

# Copy environment
cp .env.example .env
```

### 3. Create Branch

```bash
# Update main
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/my-awesome-feature
```

### 4. Make Changes

**Areas you can work on:**

```
✅ web_vue/src/        - Frontend code
✅ node_backend/       - Backend code
✅ docs/               - Documentation
✅ tests/              - Tests

❌ scripts/            - Automation scripts (DON'T TOUCH!)
❌ app-manager.ps1     - Master script (DON'T TOUCH!)
```

### 5. Test Locally

```bash
# Start development
cd node_backend && pnpm dev  # Terminal 1
cd web_vue && pnpm dev       # Terminal 2

# Run tests
pnpm test

# Run linter
pnpm lint
```

### 6. Commit Changes

```bash
# Stage changes
git add .

# Commit with conventional message
git commit -m "feat: add awesome feature"

# Push to your fork
git push origin feature/my-awesome-feature
```

### 7. Create Pull Request

1. Go to GitHub
2. Click "New Pull Request"
3. Fill in template
4. Request review
5. Wait for feedback

---

## 📝 Commit Message Convention

Format: `<type>(<scope>): <subject>`

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, semicolons, etc)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

### Examples

```bash
feat(auth): add login functionality
fix(api): resolve CORS issue  
docs(readme): update installation steps
style(ui): improve button styling
refactor(utils): optimize sanitizer
test(user): add user component tests
chore(deps): update dependencies
```

---

## 🎯 Development Guidelines

### Code Style

- Use **ESLint** for JavaScript
- Use **Prettier** for formatting
- Follow **Vue 3 style guide**
- Write **clean, readable code**

### Component Structure (Vue)

```vue
<template>
  <!-- Semantic HTML -->
</template>

<script setup>
// Composition API
// Clear, documented code
</script>

<style scoped>
/* Scoped styles */
/* Use CSS variables */
</style>
```

### Security

- ✅ **Never** commit secrets (API keys, passwords)
- ✅ **Always** sanitize user input
- ✅ **Use** environment variables
- ✅ **Validate** data on both frontend and backend

### Testing

- ✅ Write tests for new features
- ✅ Update tests for changes
- ✅ Run tests before committing
- ✅ Aim for >80% coverage

---

## 🔍 Code Review Process

### As Author

1. Write clear PR description
2. Add screenshots/videos
3. Link related issues
4. Pass all CI checks
5. Address reviewer feedback
6. Keep PR updated

### As Reviewer

1. Check functionality
2. Review code quality
3. Test locally if needed
4. Be constructive
5. Approve or request changes

---

## 🐛 Reporting Bugs

### Before Reporting

1. Search existing issues
2. Check if it's already fixed
3. Try latest version
4. Reproduce the bug

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
- OS: [e.g. Windows 11]
- Browser: [e.g. Chrome 120]
- Version: [e.g. 2.2.2]
```

---

## 💡 Feature Requests

### Suggest a Feature

1. Check if already requested
2. Describe use case
3. Explain benefits
4. Propose implementation (optional)

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution**
What you want to happen.

**Describe alternatives**
Other solutions you've considered.

**Additional context**
Screenshots, mockups, examples.
```

---

## 📋 Pull Request Template

```markdown
## Description
Brief description of changes

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist
- [ ] Code follows project style
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests passing
- [ ] No console.log in code
- [ ] No hardcoded secrets

## Screenshots (if applicable)
Add screenshots here

## Related Issues
Fixes #123
```

---

## 🚫 What NOT to Do

### DON'T:

- ❌ Edit files in `scripts/` folder
- ❌ Modify automation scripts
- ❌ Commit directly to `main`
- ❌ Deploy to production
- ❌ Commit `.env` file
- ❌ Commit `node_modules/`
- ❌ Hardcode secrets
- ❌ Ignore linter errors
- ❌ Skip tests
- ❌ Make huge PRs (>500 lines)

### DO:

- ✅ Work in feature branches
- ✅ Write tests
- ✅ Update documentation
- ✅ Follow conventions
- ✅ Ask questions
- ✅ Review others' code
- ✅ Be patient
- ✅ Have fun! 🎉

---

## 🎓 Learning Resources

### Vue 3

- [Vue 3 Documentation](https://vuejs.org/)
- [Vue 3 Style Guide](https://vuejs.org/style-guide/)
- [Composition API](https://vuejs.org/guide/extras/composition-api-faq.html)

### Node.js / Express

- [Express Documentation](https://expressjs.com/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

### Git

- [Git Documentation](https://git-scm.com/doc)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

### Testing

- [Vitest Documentation](https://vitest.dev/)
- [Vue Testing Library](https://testing-library.com/docs/vue-testing-library/intro/)

---

## 🤝 Community Guidelines

### Be Respectful

- Treat everyone with respect
- Be patient with newcomers
- Accept constructive criticism
- Give constructive feedback

### Be Collaborative

- Help others learn
- Share knowledge
- Ask questions
- Contribute ideas

### Be Professional

- Keep discussions on-topic
- Use appropriate language
- Follow code of conduct
- Credit others' work

---

## 📞 Getting Help

### Questions?

1. Check [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md)
2. Search existing issues
3. Ask in discussions
4. Create new issue

### Found a Bug?

1. Check if already reported
2. Create issue with template
3. Provide reproduction steps

### Want a Feature?

1. Check if already requested
2. Create feature request
3. Discuss with maintainers

---

## 🎉 Recognition

Contributors are recognized in:

- **README.md** - Contributors section
- **CHANGELOG.md** - Release notes
- **GitHub** - Contributors page

Thank you for making this project better! 🙌

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Happy Contributing! 🚀**

For detailed development guide, see [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md)

# Quick Setup Guide for GitHub Actions Publishing

## 🔐 Required Secrets Setup

### 1. Public NPM Publishing
**Create NPM Token:**
1. Go to https://www.npmjs.com/settings/tokens
2. Click "Generate New Token"
3. Select "Automation" type
4. Enable "Publish" permissions
5. Copy the generated token

**Add to GitHub:**
1. Go to your fork → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `NPM_TOKEN`
4. Paste the npm token
5. Click "Add secret"

### 2. GitHub Packages Publishing
**Create GitHub Token:**
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `repo`, `write:packages`
4. Copy the generated token

**Add to GitHub:**
1. Go to your fork → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `GITHUB_TOKEN`
4. Paste the GitHub token
5. Click "Add secret"

## 🚀 Ready to Publish

Once secrets are configured:

1. Go to **Actions** tab in your repository
2. Select **"Publish to NPM"** workflow
3. Click **"Run workflow"**
4. Choose your preferences:
   - **registry**: `public` or `github-packages`
   - **suffix**: `openshift-ai` (or your choice)
5. Click **"Run workflow"**

## 📦 Installation Commands After Publishing

### Public NPM (registry: public)
```bash
npm install kubernetes-mcp-server-openshift-ai
```

### GitHub Packages (registry: github-packages)
```bash
npm config set @macayaven:registry https://npm.pkg.github.com/
npm install @macayaven/kubernetes-mcp-server
```

## ✅ Benefits

- **One-click publishing** - no local setup
- **Automated versioning** - uses git tags
- **Multi-platform** - all 7 packages published
- **Secure** - tokens encrypted in GitHub
- **Flexible** - choose registry and suffix
- **Transparent** - full logs and progress

---

*Setup takes 5 minutes, publishing takes 2-3 minutes* ⚡
# GitHub Actions Publishing Guide

## 🚀 Automated NPM Publishing

This repository includes a GitHub Actions workflow that allows you to publish packages to NPM with manual triggering.

### 📋 Workflow Features

- **Manual Trigger**: Choose when to publish
- **Registry Selection**: Public NPM or GitHub Packages
- **Custom Suffix**: Define package naming (e.g., `openshift-ai`)
- **Version Management**: Automatic version from git tags
- **Multi-Platform**: Publishes all platform-specific packages
- **Security**: Uses encrypted secrets for authentication

### 🔧 Setup Required

#### 1. Repository Secrets
Go to **Settings → Secrets and variables → Actions** and add:

**For Public NPM Publishing:**
- `NPM_TOKEN`: Your npm access token with publish permissions

**For GitHub Packages Publishing:**
- `GITHUB_TOKEN`: Your GitHub personal access token with `write:packages` scope

#### 2. Token Creation

**Public NPM Token:**
1. Go to [npmjs.com](https://www.npmjs.com/settings/tokens)
2. Click "Generate New Token"
3. Select "Automation" type
4. Enable "Publish" permissions
5. Copy the token

**GitHub Token:**
1. Go to [GitHub Settings](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select scopes: `repo`, `write:packages`
4. Copy the token

### 🎮 How to Use

#### 1. Go to Actions
1. Navigate to **Actions** tab in your repository
2. Select **"Publish to NPM"** workflow from the left sidebar
3. Click **"Run workflow"** button

#### 2. Configure Publishing
Fill in the workflow parameters:

- **registry**: Choose `public` or `github-packages`
- **suffix**: Enter your package suffix (e.g., `openshift-ai`)

#### 3. Run and Monitor
1. Click **"Run workflow"** to start publishing
2. Monitor progress in real-time
3. Check the summary for installation instructions

### 📦 Publishing Options

#### Option 1: Public NPM Registry
- **Registry**: `https://registry.npmjs.org/`
- **Package Name**: `kubernetes-mcp-server-{suffix}`
- **Installation**: `npm install kubernetes-mcp-server-{suffix}`
- **Visibility**: Public to everyone

#### Option 2: GitHub Packages Registry
- **Registry**: `https://npm.pkg.github.com/`
- **Package Name**: `@macayaven/kubernetes-mcp-server`
- **Installation**: Requires registry configuration
- **Visibility**: Private to your account

### 🔄 Workflow Process

1. **Checkout**: Downloads your code
2. **Setup**: Configures Node.js and Go
3. **Configure**: Sets up NPM registry and authentication
4. **Version**: Gets version from git tags
5. **Prepare**: Runs `prepare-fork-npm.sh` with your suffix
6. **Build**: Compiles binaries for all platforms
7. **Copy**: Moves binaries to npm packages
8. **Publish**: Uploads all packages to NPM
9. **Summary**: Creates GitHub Actions summary

### 📊 What Gets Published

#### Platform Packages (7 total)
- `kubernetes-mcp-server-{suffix}-darwin-amd64`
- `kubernetes-mcp-server-{suffix}-darwin-arm64`
- `kubernetes-mcp-server-{suffix}-linux-amd64`
- `kubernetes-mcp-server-{suffix}-linux-arm64`
- `kubernetes-mcp-server-{suffix}-windows-amd64`
- `kubernetes-mcp-server-{suffix}-windows-arm64`

#### Main Package (1 total)
- `kubernetes-mcp-server-{suffix}` (with optionalDependencies)

### 🎯 Example Usage

#### Publishing to Public NPM with OpenShift AI suffix:
1. **Run workflow** with:
   - registry: `public`
   - suffix: `openshift-ai`

2. **Result**: Users can install with:
   ```bash
   npm install kubernetes-mcp-server-openshift-ai
   ```

#### Publishing to GitHub Packages:
1. **Run workflow** with:
   - registry: `github-packages`
   - suffix: `openshift-ai`

2. **Result**: Users can install with:
   ```bash
   npm config set @macayaven:registry https://npm.pkg.github.com/
   npm install @macayaven/kubernetes-mcp-server
   ```

### 🔍 Troubleshooting

#### Common Issues

**Authentication Failed (401/403)**
- Check that secrets are correctly set
- Verify tokens have required permissions
- Ensure tokens haven't expired

**Publish Failed (409 Conflict)**
- Version already exists
- Check if you need to increment version
- Git tag may already be published

**Build Failed**
- Check workflow logs for build errors
- Ensure Go version compatibility
- Verify all dependencies are available

**Registry Configuration Error**
- Verify registry URL is correct
- Check .npmrc file format
- Ensure token is properly encoded

### 📝 Workflow File

The workflow is defined in `.github/workflows/publish-npm.yml` and includes:

- **Manual triggering** with configurable parameters
- **Multi-platform support** for all major OS/architectures
- **Security best practices** using GitHub secrets
- **Comprehensive logging** and error handling
- **Automatic summaries** with installation instructions

### 🎉 Benefits

- **One-click publishing** - no local setup required
- **Consistent process** - same steps every time
- **Version management** - automatic from git tags
- **Multi-registry support** - public npm or GitHub Packages
- **Security** - tokens encrypted and managed by GitHub
- **Transparency** - full logs and progress tracking

### 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [NPM Documentation](https://docs.npmjs.com/)
- [Semantic Versioning](https://semver.org/)
- [OpenShift AI Documentation](https://docs.redhat.com/en-us/openshift_data_science/)

---

*This workflow makes publishing your OpenShift AI enhanced MCP server as simple as clicking a button!* 🚀
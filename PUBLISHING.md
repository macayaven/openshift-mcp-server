# 🚀 Publishing Guide

Complete guide for publishing the OpenShift AI enhanced MCP server fork.

## 📋 Table of Contents

- [Overview](#overview)
- [Publishing Options](#publishing-options)
- [Manual Publishing](#manual-publishing)
- [GitHub Actions Publishing](#github-actions-publishing)
- [Package Names](#package-names)
- [Setup Requirements](#setup-requirements)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This fork enhances the original [kubernetes-mcp-server](https://github.com/containers/kubernetes-mcp-server) by Marc Nuri with **OpenShift AI** capabilities.

### 🍴 Fork Attribution
- **Original**: kubernetes-mcp-server by Marc Nuri
- **This Fork**: OpenShift AI enhanced version by Carlos Macaya
- **License**: Apache License 2.0 (preserved)
- **Status**: Learning phase, actively developed

### 📦 Available Packages
- **Native Binaries**: Linux, macOS, Windows
- **NPM Packages**: Cross-platform distribution
- **Container Images**: Docker/Podman compatible
- **Python Package**: PyPI distribution

## 🚀 Publishing Options

### Option 1: GitHub Actions (Recommended)
- **Trigger**: Manual workflow dispatch
- **Features**: Automated multi-platform publishing
- **Registries**: GitHub Packages or Public npm
- **Architecture Selection**: Choose specific platforms

### Option 2: Manual Publishing
- **Control**: Full manual control
- **Commands**: Shell scripts provided
- **Flexibility**: Custom configurations

## 📋 Package Names

### GitHub Packages (@macayaven namespace)
```
@macayaven/kubernetes-mcp-server                    # Main package
@macayaven/kubernetes-mcp-server-darwin-amd64     # macOS Intel
@macayaven/kubernetes-mcp-server-darwin-arm64     # macOS Apple Silicon
@macayaven/kubernetes-mcp-server-linux-amd64      # Linux Intel
@macayaven/kubernetes-mcp-server-linux-arm64      # Linux ARM
@macayaven/kubernetes-mcp-server-windows-amd64    # Windows Intel
@macayaven/kubernetes-mcp-server-windows-arm64    # Windows ARM
```

### Public NPM (descriptive names)
```
kubernetes-mcp-server-openshift-ai                    # Main package
kubernetes-mcp-server-openshift-ai-darwin-amd64     # macOS Intel
kubernetes-mcp-server-openshift-ai-darwin-arm64     # macOS Apple Silicon
kubernetes-mcp-server-openshift-ai-linux-amd64      # Linux Intel
kubernetes-mcp-server-openshift-ai-linux-arm64      # Linux ARM
kubernetes-mcp-server-openshift-ai-windows-amd64    # Windows Intel
kubernetes-mcp-server-openshift-ai-windows-arm64    # Windows ARM
```

### Container Images
```
quay.io/macayaven/kubernetes_mcp_server_openshift_ai:latest    # Multi-arch
quay.io/macayaven/kubernetes_mcp_server_openshift_ai:v1.0.0   # Tagged
```

## ⚙️ Setup Requirements

### GitHub Packages Setup
1. **Create GitHub Personal Access Token**:
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Generate new token with `write:packages` scope
   - Save token securely

2. **Configure GitHub Secrets**:
   ```bash
   gh secret set NPM_TOKEN -R macayaven/openshift-mcp-server --body "your-github-token"
   ```

3. **Local Authentication** (optional):
   ```bash
   npm login --scope=@macayaven --registry=https://npm.pkg.github.com
   ```

### Public NPM Setup
1. **Create NPM Access Token**:
   - Go to [npmjs.com](https://www.npmjs.com/settings/macayaven/tokens)
   - Create automation token
   - Save token securely

2. **Configure GitHub Secrets**:
   ```bash
   gh secret set NPM_TOKEN -R macayaven/openshift-mcp-server --body "your-npm-token"
   ```

### Container Registry Setup
1. **Create Quay.io Account**:
   - Sign up at [quay.io](https://quay.io)
   - Create repository: `kubernetes_mcp_server_openshift_ai`

2. **Configure GitHub Secrets**:
   ```bash
   gh secret set QUAY_USERNAME -R macayaven/openshift-mcp-server --body "your-quay-username"
   gh secret set QUAY_PASSWORD -R macayaven/openshift-mcp-server --body "your-quay-token"
   ```

## 🤖 GitHub Actions Publishing

### Workflow: Publish to NPM
**Location**: `.github/workflows/publish-npm.yml`

#### Parameters
- **Registry**: `github-packages` or `public`
- **Suffix**: Package suffix (e.g., `openshift-ai`)
- **Architectures**: Select target platforms

#### Usage
1. Go to: https://github.com/macayaven/openshift-mcp-server/actions
2. Click "Publish to NPM" workflow
3. Click "Run workflow"
4. Configure parameters:
   - **Registry**: Choose target registry
   - **Suffix**: Enter package suffix
   - **Architectures**: Select platforms (default: all)
5. Click "Run workflow"

#### Architecture Selection
Available options:
- `darwin-amd64` - macOS Intel
- `darwin-arm64` - macOS Apple Silicon  
- `linux-amd64` - Linux Intel
- `linux-arm64` - Linux ARM
- `windows-amd64` - Windows Intel
- `windows-arm64` - Windows ARM

### Workflow: Release Container Image
**Location**: `.github/workflows/release-image.yml`

#### Parameters
- **Trigger**: Manual or on tags
- **Platforms**: Multi-architecture builds

#### Usage
1. Go to Actions → "Release as container image"
2. Click "Run workflow"
3. Select branch: `main`
4. Click "Run workflow"

## 🔧 Manual Publishing

### Step 1: Prepare Packages

#### For GitHub Packages
```bash
./update-npm-for-fork.sh macayaven
```

#### For Public NPM
```bash
./prepare-fork-npm.sh openshift-ai
```

### Step 2: Build Binaries
```bash
make build-all-platforms
```

### Step 3: Copy to NPM Directories
```bash
make npm-copy-binaries
```

### Step 4: Publish
```bash
# Login to appropriate registry
npm login  # For public npm
# OR
npm login --scope=@macayaven --registry=https://npm.pkg.github.com  # For GitHub Packages

# Publish all packages
make npm-publish
```

### Manual Container Publishing
```bash
# Build image
podman build -t quay.io/macayaven/kubernetes_mcp_server_openshift_ai:latest .

# Login to Quay
podman login quay.io

# Push image
podman push quay.io/macayaven/kubernetes_mcp_server_openshift_ai:latest
```

## 📦 Installation Instructions

### From GitHub Packages
```bash
# Configure registry
npm config set @macayaven:registry https://npm.pkg.github.com/

# Install
npm install @macayaven/kubernetes-mcp-server

# Run
npx @macayaven/kubernetes-mcp-server
```

### From Public NPM
```bash
# Install
npm install kubernetes-mcp-server-openshift-ai

# Run
npx kubernetes-mcp-server-openshift-ai
```

### From Container Registry
```bash
# Pull
podman pull quay.io/macayaven/kubernetes_mcp_server_openshift_ai:latest

# Run
podman run -it --rm \
  -v ~/.kube/config:/root/.kube/config:ro \
  quay.io/macayaven/kubernetes_mcp_server_openshift_ai:latest
```

### From Python Package
```bash
# Install
pip install kubernetes-mcp-server

# Run
python -m kubernetes_mcp_server
```

## 🧪 Validation

### Quick Validation
```bash
./quick-validate
```

### Full Validation
```bash
./validate-openshift-ai.sh
```

### MCP Inspector Testing
```bash
make build
npx @modelcontextprotocol/inspector@latest $(pwd)/kubernetes-mcp-server
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Authentication Errors
**Problem**: `401 Unauthorized` or `E401`
**Solution**: 
- Check token permissions
- Verify registry configuration
- Ensure secrets are set correctly

#### 2. Version Errors
**Problem**: `Invalid version` or `EINVALIDVERSION`
**Solution**:
- Ensure semantic versioning (x.y.z)
- Check git tags exist
- Use version preparation scripts

#### 3. Package Name Conflicts
**Problem**: `403 Forbidden` or name conflicts
**Solution**:
- Use unique package names
- Check registry availability
- Verify namespace configuration

#### 4. Build Failures
**Problem**: Compilation or build errors
**Solution**:
- Run `make clean && make build`
- Check Go version compatibility
- Verify dependencies

### Debug Commands

#### Check Package Configuration
```bash
# Verify package.json
cat npm/kubernetes-mcp-server/package.json | jq .

# Check version consistency
find npm -name "package.json" -exec grep '"version"' {} \;
```

#### Test Authentication
```bash
# Test npm registry access
npm ping --registry=https://registry.npmjs.org/
npm ping --registry=https://npm.pkg.github.com/

# Test who you're logged in as
npm whoami
```

#### Verify Container Registry
```bash
# Test Quay access
podman login quay.io --get-login
podman search quay.io/macayaven
```

## 📚 Additional Resources

- [Original Project](https://github.com/containers/kubernetes-mcp-server)
- [MCP Documentation](https://modelcontextprotocol.io/)
- [OpenShift AI Documentation](https://docs.redhat.com/en-us/openshift-data-science/)
- [GitHub Packages Guide](https://docs.github.com/en/packages/working-with-a-github-packages-registry)
- [NPM Publishing Guide](https://docs.npmjs.com/cli/v8/commands/publish)

## 🤝 Contributing

This is a learning project. Contributions are welcome!

1. **Fork** the repository
2. **Create** feature branch
3. **Make** changes with tests
4. **Submit** pull request

### Development Workflow
```bash
# Setup development environment
make tools
make local-env-setup

# Run tests
make test

# Validate changes
./quick-validate
```

---

**Thank you for using the OpenShift AI enhanced MCP server!** 🚀

For issues and questions:
- **GitHub Issues**: https://github.com/macayaven/openshift-mcp-server/issues
- **Original Project**: https://github.com/containers/kubernetes-mcp-server/issues
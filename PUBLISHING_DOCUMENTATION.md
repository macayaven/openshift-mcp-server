# Kubernetes MCP Server Fork Publishing Guide

## Overview

This guide documents the process of publishing forked npm packages for the kubernetes-mcp-server project with OpenShift AI support, ensuring proper attribution and ethical naming conventions.

## Current Setup

### Repository Structure
- **Original**: `containers/kubernetes-mcp-server` (by Marc Nuri/Red Hat)
- **Fork**: `macayaven/openshift-mcp-server` (with OpenShift AI toolset)
- **Contribution**: Added OpenShift AI toolset integration

### Package Options

#### 1. GitHub Packages (Published ✅)
- **Scope**: `@macayaven/kubernetes-mcp-server`
- **Registry**: `https://npm.pkg.github.com/`
- **Status**: Published and working
- **Installation**: Requires registry configuration

#### 2. Public npm (Ready to Publish 🚀)
- **Name**: `kubernetes-mcp-server-openshift-ai`
- **Registry**: `https://registry.npmjs.org/`
- **Status**: Prepared, ready to publish
- **Installation**: Simple `npm install`

## Scripts Created

### `update-npm-for-fork.sh`
Updates npm packages for GitHub Packages publishing:
```bash
./update-npm-for-fork.sh macayaven
```
- Updates repository URLs to point to fork
- Adds `publishConfig` for GitHub Packages
- Sets up scoped package names (`@macayaven/...`)

### `prepare-fork-npm.sh`
Prepares packages for public npm with ethical naming:
```bash
./prepare-fork-npm.sh openshift-ai
```
- Creates appropriate package names with suffix
- Maintains attribution to original author
- Removes GitHub Packages specific configuration

## Publishing Workflows

### GitHub Packages Workflow
```bash
# 1. Update packages for GitHub Packages
./update-npm-for-fork.sh macayaven

# 2. Authenticate with GitHub Packages
gh auth refresh -h github.com -s "repo,write:packages,gist,workflow,write:org"
echo "//npm.pkg.github.com/:_authToken=$(gh auth token)" > ~/.npmrc
echo "@macayaven:registry=https://npm.pkg.github.com/" >> ~/.npmrc

# 3. Publish
make npm-publish
```

### Public npm Workflow
```bash
# 1. Prepare packages for public npm
./prepare-fork-npm.sh openshift-ai

# 2. Login to npm
npm login

# 3. Publish
make npm-publish
```

## Package Naming Philosophy

### Ethical Considerations
- **Attribution**: Original author (Marc Nuri) credited in package metadata
- **Transparency**: Clear indication this is a fork, not replacement
- **Descriptive**: Suffix explains the specific contribution
- **No confusion**: Package name makes origin obvious

### Naming Convention
- **Main package**: `kubernetes-mcp-server-{suffix}`
- **Platform packages**: `kubernetes-mcp-server-{suffix}-{platform}`
- **Suffix options**:
  - `openshift-ai` (recommended - describes your contribution)
  - `macayaven-fork` (alternative - indicates fork author)
  - `custom` (any other descriptive suffix)

## Installation Instructions

### For GitHub Packages
```bash
# One-time setup
npm config set @macayaven:registry https://npm.pkg.github.com/
npm login --scope=@macayaven --registry=https://npm.pkg.github.com

# Install
npm install @macayaven/kubernetes-mcp-server
```

### For Public npm (after publishing)
```bash
# Simple installation
npm install kubernetes-mcp-server-openshift-ai
```

### Alternative Installation Methods
```bash
# One-time with registry flag
npm install kubernetes-mcp-server-openshift-ai --registry=https://npm.pkg.github.com

# Using npx
npx @macayaven/kubernetes-mcp-server

# Direct tarball
npm install https://npm.pkg.github.com/download/@macayaven/kubernetes-mcp-server/VERSION/tarball.tgz
```

## Authentication Setup

### GitHub Packages Authentication
```bash
# Method 1: GitHub CLI (recommended)
gh auth refresh -h github.com -s "repo,write:packages,gist,workflow,write:org"

# Method 2: Personal Access Token
# 1. Create token at https://github.com/settings/tokens
# 2. Add write:packages scope
# 3. Use token for npm login
npm login --scope=@macayaven --registry=https://npm.pkg.github.com
```

### Public npm Authentication
```bash
npm login
# Follow browser prompts for 2FA if enabled
```

## File Structure

```
npm/
├── kubernetes-mcp-server/                 # Main package
│   ├── package.json                      # Main package configuration
│   └── bin/
│       └── index.js                      # Entry point script
├── kubernetes-mcp-server-darwin-amd64/   # macOS Intel
├── kubernetes-mcp-server-darwin-arm64/   # macOS Apple Silicon
├── kubernetes-mcp-server-linux-amd64/    # Linux Intel
├── kubernetes-mcp-server-linux-arm64/    # Linux ARM
├── kubernetes-mcp-server-windows-amd64/   # Windows Intel
└── kubernetes-mcp-server-windows-arm64/   # Windows ARM
```

## Version Management

### Version Sources
- **Git tags**: Used for version numbers
- **Build info**: Commit hash, build time embedded in binary
- **NPM version**: Synchronized with git describe

### Version Format
```
v{MAJOR}.{MINOR}.{PATCH}-{COMMITS_SINCE_TAG}-{GIT_HASH}
```
Example: `v0.0.53-127-gee20cd9`

## Troubleshooting

### Common Issues

#### 404 Not Found on npm install
**Problem**: Trying to install GitHub Packages from public npm registry
**Solution**: Configure npm registry or use public npm packages

```bash
# For GitHub Packages
npm config set @macayaven:registry https://npm.pkg.github.com/

# Or use public npm
npm install kubernetes-mcp-server-openshift-ai
```

#### Permission Denied (403)
**Problem**: Token missing `write:packages` scope
**Solution**: Refresh GitHub token with correct scopes

```bash
gh auth refresh -h github.com -s "repo,write:packages,gist,workflow,write:org"
```

#### Package Name Conflicts
**Problem**: Package name already exists on npm
**Solution**: Use different suffix or scoped name

```bash
./prepare-fork-npm.sh different-suffix
```

### Debug Commands
```bash
# Check npm configuration
npm config list

# Test npm authentication
npm whoami --registry=https://npm.pkg.github.com/

# Check package info
npm view @macayaven/kubernetes-mcp-server --registry=https://npm.pkg.github.com/

# Dry run publish
cd npm/package-name && npm publish --dry-run
```

## Best Practices

### Before Publishing
1. **Test locally**: `make build && make test`
2. **Verify packages**: Check package.json files
3. **Update version**: Ensure version is correct
4. **Check authentication**: Verify npm/GitHub token

### Publishing Process
1. **Choose registry**: GitHub Packages (private) or public npm
2. **Prepare packages**: Use appropriate script
3. **Authenticate**: Set up correct token
4. **Publish**: `make npm-publish`
5. **Verify**: Test installation

### After Publishing
1. **Test installation**: Install in clean environment
2. **Update documentation**: Update README with install instructions
3. **Tag release**: Create git tag for version
4. **Communicate**: Let users know about availability

## Quick Reference

### Commands Summary
```bash
# Update for GitHub Packages
./update-npm-for-fork.sh macayaven

# Prepare for public npm
./prepare-fork-npm.sh openshift-ai

# Build and publish
make npm-publish

# Test installation
npm install kubernetes-mcp-server-openshift-ai
```

### Package Names
- **GitHub Packages**: `@macayaven/kubernetes-mcp-server`
- **Public npm**: `kubernetes-mcp-server-openshift-ai`

### Registry URLs
- **GitHub Packages**: `https://npm.pkg.github.com/`
- **Public npm**: `https://registry.npmjs.org/`

## Notes

- GitHub Packages requires authentication for both public and private repositories
- Public npm packages are visible to everyone immediately
- Package names must be unique on public npm
- Scoped packages (@username/package) can only be published by the scope owner
- Platform-specific packages are automatically selected by npm based on user's OS/architecture

---

*Last updated: October 31, 2025*
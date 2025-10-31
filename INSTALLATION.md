# Installation Instructions for @macayaven/kubernetes-mcp-server

## Method 1: Using GitHub Packages (Recommended)

### Step 1: Configure npm registry
```bash
npm config set @macayaven:registry https://npm.pkg.github.com/
```

### Step 2: Authenticate with GitHub Packages
```bash
# Create a GitHub personal access token with 'read:packages' scope
# Then login:
npm login --scope=@macayaven --registry=https://npm.pkg.github.com
```

### Step 3: Install the package
```bash
npm install @macayaven/kubernetes-mcp-server
```

## Method 2: One-time installation with registry flag
```bash
npm install @macayaven/kubernetes-mcp-server --registry=https://npm.pkg.github.com
```

## Method 3: Using npx (one-time execution)
```bash
npx --registry=https://npm.pkg.github.com @macayaven/kubernetes-mcp-server
```

## Method 4: Direct tarball installation
```bash
npm install https://npm.pkg.github.com/download/@macayaven/kubernetes-mcp-server/0.0.53-127-gee20cd9/kubernetes-mcp-server-0.0.53-127-gee20cd9.tgz
```

## Notes
- GitHub Packages requires authentication for both public and private repositories
- Users need a GitHub account to install packages from GitHub Packages
- The packages are scoped to @macayaven and only available on GitHub Packages registry
#!/bin/bash

# Script to prepare packages for public npm with appropriate naming
# Usage: ./prepare-fork-npm.sh VERSION_SUFFIX

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 VERSION_SUFFIX"
    echo "Example: $0 openshift-ai"
    echo "Example: $0 macayaven-fork"
    exit 1
fi

VERSION_SUFFIX="$1"
REPO_NAME="openshift-mcp-server"

echo "Preparing npm packages for public npm registry with suffix: $VERSION_SUFFIX"
echo ""

# First, let's manually set the correct optionalDependencies
echo "Setting up main package..."
cat > npm/kubernetes-mcp-server/package.json << EOF
{
  "name": "kubernetes-mcp-server-$VERSION_SUFFIX",
  "version": "0.0.53-127-gee20cd9",
  "description": "Model Context Protocol (MCP) server for Kubernetes and OpenShift (fork with OpenShift AI support)",
  "main": "./bin/index.js",
  "bin": {
    "kubernetes-mcp-server": "bin/index.js"
  },
  "optionalDependencies": {
    "kubernetes-mcp-server-$VERSION_SUFFIX-darwin-amd64": "0.0.53-127-gee20cd9",
    "kubernetes-mcp-server-$VERSION_SUFFIX-darwin-arm64": "0.0.53-127-gee20cd9",
    "kubernetes-mcp-server-$VERSION_SUFFIX-linux-amd64": "0.0.53-127-gee20cd9",
    "kubernetes-mcp-server-$VERSION_SUFFIX-linux-arm64": "0.0.53-127-gee20cd9",
    "kubernetes-mcp-server-$VERSION_SUFFIX-windows-amd64": "0.0.53-127-gee20cd9",
    "kubernetes-mcp-server-$VERSION_SUFFIX-windows-arm64": "0.0.53-127-gee20cd9"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/macayaven/$REPO_NAME.git"
  },
  "keywords": [
    "mcp",
    "kubernetes",
    "openshift",
    "model context protocol",
    "model",
    "context",
    "protocol"
  ],
  "author": {
    "name": "Marc Nuri (Original), macayaven (OpenShift AI fork)",
    "url": "https://www.marcnuri.com"
  },
  "license": "Apache-2.0",
  "bugs": {
    "url": "https://github.com/macayaven/$REPO_NAME.git/issues"
  },
  "homepage": "https://github.com/macayaven/$REPO_NAME#readme"
}
EOF

# Update platform packages
platforms=("darwin-amd64" "darwin-arm64" "linux-amd64" "linux-arm64" "windows-amd64" "windows-arm64")

for platform in "${platforms[@]}"; do
    package_name="kubernetes-mcp-server-$platform"
    fork_name="kubernetes-mcp-server-$VERSION_SUFFIX-$platform"
    package_file="npm/$package_name/package.json"
    
    echo "Updating $package_file..."
    
    cat > "$package_file" << EOF
{
  "name": "$fork_name",
  "version": "0.0.53-127-gee20cd9",
  "description": "Model Context Protocol (MCP) server for Kubernetes and OpenShift (fork with OpenShift AI support)",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/macayaven/$REPO_NAME.git"
  },
  "os": [
    "$(echo $platform | cut -d'-' -f1)"
  ],
  "cpu": [
    "$(echo $platform | cut -d'-' -f2)"
  ],
  "bugs": {
    "url": "https://github.com/macayaven/$REPO_NAME.git/issues"
  },
  "homepage": "https://github.com/macayaven/$REPO_NAME#readme"
}
EOF
    
    echo "✓ Updated $package_file as $fork_name"
done

echo ""
echo "✅ All packages prepared for public npm registry!"
echo ""
echo "Next steps:"
echo "1. Login to npm: npm login"
echo "2. Publish: make npm-publish"
echo ""
echo "Packages will be published as:"
echo "- kubernetes-mcp-server-$VERSION_SUFFIX"
echo "- kubernetes-mcp-server-$VERSION_SUFFIX-darwin-amd64"
echo "- kubernetes-mcp-server-$VERSION_SUFFIX-darwin-arm64"
echo "- etc."
echo ""
echo "Users can install with: npm install kubernetes-mcp-server-$VERSION_SUFFIX"
echo ""
echo "This naming clearly indicates it's a fork while giving credit to the original project."
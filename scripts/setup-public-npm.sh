#!/bin/bash
set -e

# Setup packages for public npm publishing
# Usage: ./scripts/setup-public-npm.sh [suffix]

SUFFIX="${1:-openshift-ai}"

echo "🔧 Setting up packages for public npm registry with suffix: $SUFFIX"

# Update main package
echo "Setting up main package..."
sed -i.bak 's|"name": ".*"|"name": "kubernetes-mcp-server-'$SUFFIX'"|g' npm/kubernetes-mcp-server/package.json
sed -i.bak 's|"repository": ".*"|"repository": {"type": "git", "url": "git+https://github.com/macayaven/openshift-mcp-server.git"}|g' npm/kubernetes-mcp-server/package.json
sed -i.bak 's|"bugs": ".*"|"bugs": {"url": "https://github.com/macayaven/openshift-mcp-server.git/issues"}|g' npm/kubernetes-mcp-server/package.json
sed -i.bak 's|"homepage": ".*"|"homepage": "https://github.com/macayaven/openshift-mcp-server#readme"|g' npm/kubernetes-mcp-server/package.json

# Use public npm index.js for binary resolution
cp npm/kubernetes-mcp-server/bin/index.js npm/kubernetes-mcp-server/bin/index-public.js

# Update platform packages
for platform in darwin-amd64 darwin-arm64 linux-amd64 linux-arm64 windows-amd64 windows-arm64; do
    echo "Updating npm/kubernetes-mcp-server-$platform/package.json..."
    sed -i.bak 's|"name": ".*"|"name": "kubernetes-mcp-server-'$SUFFIX'-'$platform'"|g' "npm/kubernetes-mcp-server-$platform/package.json"
    sed -i.bak 's|"repository": ".*"|"repository": {"type": "git", "url": "git+https://github.com/macayaven/openshift-mcp-server.git"}|g' "npm/kubernetes-mcp-server-$platform/package.json"
    sed -i.bak 's|"bugs": ".*"|"bugs": {"url": "https://github.com/macayaven/openshift-mcp-server.git/issues"}|g' "npm/kubernetes-mcp-server-$platform/package.json"
    sed -i.bak 's|"homepage": ".*"|"homepage": "https://github.com/macayaven/openshift-mcp-server#readme"|g' "npm/kubernetes-mcp-server-$platform/package.json"
done

# Update optionalDependencies in main package
echo "Updating optionalDependencies in main package..."
VERSION=$(cat npm/kubernetes-mcp-server/package.json | grep '"version"' | cut -d'"' -f4)

# Create optional dependencies JSON
TEMP_FILE=$(mktemp -t deps.XXXXXX.json)
cat > "$TEMP_FILE" << EOF
{
  "optionalDependencies": {
    "kubernetes-mcp-server-$SUFFIX-darwin-amd64": "$VERSION",
    "kubernetes-mcp-server-$SUFFIX-darwin-arm64": "$VERSION",
    "kubernetes-mcp-server-$SUFFIX-linux-amd64": "$VERSION",
    "kubernetes-mcp-server-$SUFFIX-linux-arm64": "$VERSION",
    "kubernetes-mcp-server-$SUFFIX-windows-amd64": "$VERSION",
    "kubernetes-mcp-server-$SUFFIX-windows-arm64": "$VERSION"
  }
}
EOF

# Update the main package.json
jq -s '.[0] * .[1]' npm/kubernetes-mcp-server/package.json "$TEMP_FILE" > npm/kubernetes-mcp-server/package.json.tmp && mv npm/kubernetes-mcp-server/package.json.tmp npm/kubernetes-mcp-server/package.json

rm -f "$TEMP_FILE"

echo "✅ All packages prepared for public npm registry!"

echo ""
echo "Next steps:"
echo "1. Login to npm:"
echo "   npm login"
echo ""
echo "2. Publish with GitHub Actions or manually:"
echo "   make npm-publish"
echo ""
echo "Packages will be published as:"
echo "- kubernetes-mcp-server-$SUFFIX"
echo "- kubernetes-mcp-server-$SUFFIX-$platform"
echo ""
echo "Users can install with: npm install kubernetes-mcp-server-$SUFFIX"
echo ""
echo "This naming clearly indicates it's a fork while giving credit to the original project."
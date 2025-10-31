#!/bin/bash
set -e

# Setup packages for public npm publishing
# Usage: ./scripts/setup-public-npm.sh [suffix]

SUFFIX="${1:-openshift-ai}"

echo "🔧 Setting up packages for public npm registry with suffix: $SUFFIX"

# Update main package
echo "Setting up main package..."
sed -i "s|\"name\": \".*\"|\"name\": \"kubernetes-mcp-server-$SUFFIX\"|g" npm/kubernetes-mcp-server/package.json
sed -i "s|\"repository\": \".*\"|\"repository\": {\"type\": \"git\", \"url\": \"git+https://github.com/macayaven/openshift-mcp-server.git\"}|g" npm/kubernetes-mcp-server/package.json
sed -i "s|\"bugs\": \".*\"|\"bugs\": {\"url\": \"https://github.com/macayaven/openshift-mcp-server.git/issues\"}|g" npm/kubernetes-mcp-server/package.json
sed -i "s|\"homepage\": \".*\"|\"homepage\": \"https://github.com/macayaven/openshift-mcp-server#readme\"|g" npm/kubernetes-mcp-server/package.json

# Update platform packages
for platform in darwin-amd64 darwin-arm64 linux-amd64 linux-arm64 windows-amd64 windows-arm64; do
    echo "Updating npm/kubernetes-mcp-server-$platform/package.json..."
    sed -i "s|\"name\": \".*\"|\"name\": \"kubernetes-mcp-server-$SUFFIX-$platform\"|g" "npm/kubernetes-mcp-server-$platform/package.json"
    sed -i "s|\"repository\": \".*\"|\"repository\": {\"type\": \"git\", \"url\": \"git+https://github.com/macayaven/openshift-mcp-server.git\"}|g" "npm/kubernetes-mcp-server-$platform/package.json"
    sed -i "s|\"bugs\": \".*\"|\"bugs\": {\"url\": \"https://github.com/macayaven/openshift-mcp-server.git/issues\"}|g" "npm/kubernetes-mcp-server-$platform/package.json"
    sed -i "s|\"homepage\": \".*\"|\"homepage\": \"https://github.com/macayaven/openshift-mcp-server#readme\"|g" "npm/kubernetes-mcp-server-$platform/package.json"
done

# Update optionalDependencies in main package
echo "Updating optionalDependencies in main package..."
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE" << 'EOF'
  "optionalDependencies": {
EOF

for platform in darwin-amd64 darwin-arm64 linux-amd64 linux-arm64 windows-amd64 windows-arm64; do
    echo "    \"kubernetes-mcp-server-$SUFFIX-$platform\": \"$(cat npm/kubernetes-mcp-server/package.json | grep '"version"' | cut -d'"' -f4)\"," >> "$TEMP_FILE"
done

# Remove trailing comma and close object
sed -i '$ s/,$//' "$TEMP_FILE"
echo "  }" >> "$TEMP_FILE"

# Update the main package.json
jq --argfile deps "$TEMP_FILE" '.optionalDependencies = $deps.optionalDependencies' npm/kubernetes-mcp-server/package.json > npm/kubernetes-mcp-server/package.json.tmp && mv npm/kubernetes-mcp-server/package.json.tmp npm/kubernetes-mcp-server/package.json

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
#!/bin/bash
set -e

# Setup packages for GitHub Packages publishing
# Usage: ./scripts/setup-github-packages.sh [username]

USERNAME="${1:-macayaven}"

echo "🔧 Setting up packages for GitHub Packages with username: $USERNAME"
echo "Repository: https://github.com/$USERNAME/openshift-mcp-server"

# Update main package
echo "Updating npm/kubernetes-mcp-server/package.json..."
sed -i "s|\"name\": \".*\"|\"name\": \"@$USERNAME/kubernetes-mcp-server\"|g" npm/kubernetes-mcp-server/package.json
sed -i "s|\"repository\": \".*\"|\"repository\": {\"type\": \"git\", \"url\": \"git+https://github.com/$USERNAME/openshift-mcp-server.git\"}|g" npm/kubernetes-mcp-server/package.json
sed -i "s|\"bugs\": \".*\"|\"bugs\": {\"url\": \"https://github.com/$USERNAME/openshift-mcp-server.git/issues\"}|g" npm/kubernetes-mcp-server/package.json
sed -i "s|\"homepage\": \".*\"|\"homepage\": \"https://github.com/$USERNAME/openshift-mcp-server#readme\"|g" npm/kubernetes-mcp-server/package.json

# Update platform packages
for platform in darwin-amd64 darwin-arm64 linux-amd64 linux-arm64 windows-amd64 windows-arm64; do
    echo "Updating npm/kubernetes-mcp-server-$platform/package.json..."
    sed -i "s|\"name\": \".*\"|\"name\": \"@$USERNAME/kubernetes-mcp-server-$platform\"|g" "npm/kubernetes-mcp-server-$platform/package.json"
    sed -i "s|\"repository\": \".*\"|\"repository\": {\"type\": \"git\", \"url\": \"git+https://github.com/$USERNAME/openshift-mcp-server.git\"}|g" "npm/kubernetes-mcp-server-$platform/package.json"
    sed -i "s|\"bugs\": \".*\"|\"bugs\": {\"url\": \"https://github.com/$USERNAME/openshift-mcp-server.git/issues\"}|g" "npm/kubernetes-mcp-server-$platform/package.json"
    sed -i "s|\"homepage\": \".*\"|\"homepage\": \"https://github.com/$USERNAME/openshift-mcp-server#readme\"|g" "npm/kubernetes-mcp-server-$platform/package.json"
done

# Update optionalDependencies in main package
echo "Updating optionalDependencies in main package..."
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE" << 'EOF'
  "optionalDependencies": {
EOF

for platform in darwin-amd64 darwin-arm64 linux-amd64 linux-arm64 windows-amd64 windows-arm64; do
    echo "    \"@$USERNAME/kubernetes-mcp-server-$platform\": \"$(cat npm/kubernetes-mcp-server/package.json | grep '"version"' | cut -d'"' -f4)\"," >> "$TEMP_FILE"
done

# Remove trailing comma and close object
sed -i '$ s/,$//' "$TEMP_FILE"
echo "  }" >> "$TEMP_FILE"

# Update the main package.json
jq --argfile deps "$TEMP_FILE" '.optionalDependencies = $deps.optionalDependencies' npm/kubernetes-mcp-server/package.json > npm/kubernetes-mcp-server/package.json.tmp && mv npm/kubernetes-mcp-server/package.json.tmp npm/kubernetes-mcp-server/package.json

rm -f "$TEMP_FILE"

echo "✅ All packages prepared for GitHub Packages!"

echo ""
echo "Next steps:"
echo "1. Set up authentication:"
echo "   npm login --scope=@$USERNAME --registry=https://npm.pkg.github.com"
echo ""
echo "2. Publish with GitHub Actions or manually:"
echo "   make npm-publish"
echo ""
echo "Packages will be published as:"
echo "- @$USERNAME/kubernetes-mcp-server"
echo "- @$USERNAME/kubernetes-mcp-server-$platform"
#!/bin/bash

# Script to prepare packages for public npm registry
# Usage: ./prepare-public-npm.sh YOUR_NPM_USERNAME

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 YOUR_NPM_USERNAME"
    echo "Example: $0 macayaven"
    exit 1
fi

NPM_USERNAME="$1"
REPO_NAME="openshift-mcp-server"

echo "Preparing npm packages for public npm registry with username: $NPM_USERNAME"
echo ""

# Function to update package.json for public npm
update_public_package_json() {
    local package_file="$1"
    local package_name="$2"
    
    echo "Updating $package_file for public npm..."
    
    # Use jq to update the package.json for public npm
    jq --arg username "$NPM_USERNAME" --arg repo "$REPO_NAME" --arg name "$package_name" '
        .name = $name |
        .repository.url = "git+https://github.com/macayaven/\($repo).git" |
        .bugs.url = "https://github.com/macayaven/\($repo).git/issues" |
        .homepage = "https://github.com/macayaven/\($repo)#readme" |
        del(.publishConfig)
    ' "$package_file" > "${package_file}.tmp" && mv "${package_file}.tmp" "$package_file"
    
    echo "✓ Updated $package_file"
}

# Function to update optionalDependencies for public npm
update_public_optional_dependencies() {
    local main_package_file="npm/kubernetes-mcp-server/package.json"
    
    echo "Updating optionalDependencies for public npm..."
    
    # Update optionalDependencies to use public names (remove @username/ prefix and add username- prefix)
    jq --arg username "$NPM_USERNAME" '
        .optionalDependencies |= with_entries(
            .key = ($username + "-" + (.key | ltrimstr("@" + $username + "/")))
        )
    ' "$main_package_file" > "${main_package_file}.tmp" && mv "${main_package_file}.tmp" "$main_package_file"
    
    echo "✓ Updated optionalDependencies"
}

# Update main package
update_public_package_json "npm/kubernetes-mcp-server/package.json" "$NPM_USERNAME-kubernetes-mcp-server"

# Update platform-specific packages
platforms=("darwin-amd64" "darwin-arm64" "linux-amd64" "linux-arm64" "windows-amd64" "windows-arm64")

for platform in "${platforms[@]}"; do
    package_name="kubernetes-mcp-server-$platform"
    public_name="$NPM_USERNAME-$package_name"
    package_file="npm/$package_name/package.json"
    
    if [ -f "$package_file" ]; then
        update_public_package_json "$package_file" "$public_name"
    else
        echo "⚠ Package file not found: $package_file"
    fi
done

# Update optionalDependencies in main package
update_public_optional_dependencies

echo ""
echo "✅ All packages prepared for public npm registry!"
echo ""
echo "Next steps:"
echo "1. Login to npm: npm login"
echo "2. Publish: make npm-publish"
echo ""
echo "Packages will be published as:"
echo "- $NPM_USERNAME-kubernetes-mcp-server"
echo "- $NPM_USERNAME-kubernetes-mcp-server-darwin-amd64"
echo "- etc."
echo ""
echo "Users can install with: npm install $NPM_USERNAME-kubernetes-mcp-server"
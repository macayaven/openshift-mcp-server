#!/bin/bash

# Script to update npm package.json files for your fork
# Usage: ./update-npm-for-fork.sh YOUR_GITHUB_USERNAME

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 YOUR_GITHUB_USERNAME"
    echo "Example: $0 carlos"
    exit 1
fi

GITHUB_USERNAME="$1"
REPO_NAME="openshift-mcp-server"

echo "Updating npm packages for GitHub username: $GITHUB_USERNAME"
echo "Repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""

# Function to update package.json
update_package_json() {
    local package_file="$1"
    local package_name="$2"
    
    echo "Updating $package_file..."
    
    # Use jq to update the package.json
    jq --arg username "$GITHUB_USERNAME" --arg repo "$REPO_NAME" --arg name "$package_name" '
        .name = $name |
        .repository.url = "git+https://github.com/\($username)/\($repo).git" |
        .bugs.url = "https://github.com/\($username)/\($repo)/issues" |
        .homepage = "https://github.com/\($username)/\($repo)#readme" |
        .publishConfig = {
            "registry": "https://npm.pkg.github.com/"
        }
    ' "$package_file" > "${package_file}.tmp" && mv "${package_file}.tmp" "$package_file"
    
    echo "✓ Updated $package_file"
}

# Function to update optionalDependencies in main package
update_optional_dependencies() {
    local main_package_file="npm/kubernetes-mcp-server/package.json"
    
    echo "Updating optionalDependencies in main package..."
    
    # Update optionalDependencies to use scoped names
    jq --arg username "$GITHUB_USERNAME" '
        .optionalDependencies |= with_entries(.key = "@" + $username + "/" + .key)
    ' "$main_package_file" > "${main_package_file}.tmp" && mv "${main_package_file}.tmp" "$main_package_file"
    
    echo "✓ Updated optionalDependencies"
}

# Update main package
update_package_json "npm/kubernetes-mcp-server/package.json" "@$GITHUB_USERNAME/kubernetes-mcp-server"

# Update platform-specific packages
platforms=("darwin-amd64" "darwin-arm64" "linux-amd64" "linux-arm64" "windows-amd64" "windows-arm64")

for platform in "${platforms[@]}"; do
    package_name="kubernetes-mcp-server-$platform"
    scoped_name="@$GITHUB_USERNAME/$package_name"
    package_file="npm/$package_name/package.json"
    
    if [ -f "$package_file" ]; then
        update_package_json "$package_file" "$scoped_name"
    else
        echo "⚠ Package file not found: $package_file"
    fi
done

# Update optionalDependencies in main package to use scoped names
update_optional_dependencies

echo ""
echo "✅ All package.json files updated successfully!"
echo ""
echo "Next steps:"
echo "1. Commit these changes to your fork"
echo "2. Set up authentication for GitHub Packages:"
echo "   npm login --scope=@$GITHUB_USERNAME --registry=https://npm.pkg.github.com"
echo "3. Run: make npm-publish"
echo ""
echo "Note: Make sure you have a personal access token with 'write:packages' permission."
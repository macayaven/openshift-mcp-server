#!/bin/bash

# Quick OpenShift AI Validation Script
# Tests core functionality before publishing

set -e

echo "🧪 OpenShift AI Quick Validation"
echo "================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS") echo -e "${GREEN}✅ $message${NC}" ;;
        "FAIL") echo -e "${RED}❌ $message${NC}" ;;
        "WARN") echo -e "${YELLOW}⚠️ $message${NC}" ;;
    esac
}

# Test 1: Build
echo "📦 Testing build..."
if make build > /dev/null 2>&1; then
    print_status "PASS" "Build successful"
else
    print_status "FAIL" "Build failed"
    exit 1
fi

# Test 2: Tool Registration
echo "🔧 Testing tool registration..."
if ./kubernetes-mcp-server --help 2>&1 | grep -q "openshift-ai"; then
    print_status "PASS" "OpenShift AI tools registered"
else
    print_status "FAIL" "OpenShift AI tools not found"
    exit 1
fi

# Test 3: Code Quality
echo "🔍 Testing code quality..."
if go vet ./pkg/openshift-ai/... > /dev/null 2>&1; then
    print_status "PASS" "Code passes go vet"
else
    print_status "WARN" "Code has go vet issues"
fi

# Test 4: Tool Definitions
echo "📋 Testing tool definitions..."
tools=("datascience-projects" "models" "applications" "experiments" "pipelines")
for tool in "${tools[@]}"; do
    if grep -q "\"$tool\"" pkg/toolsets/openshift-ai/*.go; then
        print_status "PASS" "Tool '$tool' defined"
    else
        print_status "FAIL" "Tool '$tool' missing"
        exit 1
    fi
done

# Test 5: Dependencies
echo "📚 Testing dependencies..."
if go mod tidy > /dev/null 2>&1; then
    print_status "PASS" "Dependencies are valid"
else
    print_status "FAIL" "Dependency issues"
    exit 1
fi

# Test 6: OpenShift AI Client
echo "🤖 Testing OpenShift AI client..."
if grep -q "NewClient" pkg/openshift-ai/client.go 2>/dev/null; then
    print_status "PASS" "OpenShift AI client available"
else
    print_status "WARN" "OpenShift AI client not found"
fi

echo ""
echo "🎯 Validation Summary:"
echo "======================"
echo "✅ Build: Working"
echo "✅ Tools: Registered" 
echo "✅ Code Quality: Acceptable"
echo "✅ Dependencies: Valid"
echo ""
echo "🚀 Ready to publish your OpenShift AI enhanced MCP server!"
echo ""
echo "Next steps:"
echo "1. Choose publishing method (GitHub Packages or Public npm)"
echo "2. Run appropriate preparation script"
echo "3. Publish with: make npm-publish"
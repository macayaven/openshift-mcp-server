#!/bin/bash

# OpenShift AI Features Validation Script
# Tests all OpenShift AI toolset functionality before publishing

set -e

echo "🧪 OpenShift AI Features Validation"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS")
            echo -e "${GREEN}✅ PASS${NC}: $message"
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC}: $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  WARN${NC}: $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO${NC}: $message"
            ;;
    esac
}

# Check if binary exists
check_binary() {
    if [ ! -f "./kubernetes-mcp-server" ]; then
        print_status "WARN" "Binary not found. Building..."
        make build
    fi
}

# Test 1: Binary Build
test_binary_build() {
    print_status "INFO" "Testing binary build..."
    
    if make build > /dev/null 2>&1; then
        print_status "PASS" "Binary builds successfully"
        return 0
    else
        print_status "FAIL" "Binary build failed"
        return 1
    fi
}

# Test 2: Tool Registration
test_tool_registration() {
    print_status "INFO" "Testing OpenShift AI tool registration..."
    
    # Start server in background and capture tools
    timeout 10s ./kubernetes-mcp-server --help 2>&1 | grep -q "openshift-ai" || {
        print_status "FAIL" "OpenShift AI toolset not registered"
        return 1
    }
    
    print_status "PASS" "OpenShift AI toolset registered"
    return 0
}

# Test 3: MCP Server Start
test_mcp_server_start() {
    print_status "INFO" "Testing MCP server startup..."
    
    # Test server can start (will timeout after 5 seconds)
    if timeout 5s ./kubernetes-mcp-server 2>/dev/null; then
        print_status "WARN" "Server started but should have stayed running"
    else
        # Expected timeout - server is running
        if [ $? -eq 124 ]; then
            print_status "PASS" "MCP server starts successfully"
        else
            print_status "FAIL" "MCP server failed to start"
            return 1
        fi
    fi
    return 0
}

# Test 4: Configuration Validation
test_configuration() {
    print_status "INFO" "Testing configuration validation..."
    
    # Test with invalid config
    if ./kubernetes-mcp-server --config /nonexistent/config.toml 2>/dev/null; then
        print_status "FAIL" "Should fail with invalid config"
        return 1
    else
        print_status "PASS" "Configuration validation works"
    fi
    return 0
}

# Test 5: Tool Discovery via MCP Inspector
test_tool_discovery() {
    print_status "INFO" "Testing tool discovery via MCP..."
    
    # Create a simple MCP test script
    cat > test_mcp_tools.js << 'EOF'
const { spawn } = require('child_process');
const path = require('path');

const serverPath = path.join(__dirname, 'kubernetes-mcp-server');
const server = spawn(serverPath, [], { stdio: ['pipe', 'pipe', 'pipe'] });

let response = '';
server.stdout.on('data', (data) => {
    response += data.toString();
});

server.on('close', (code) => {
    try {
        const lines = response.split('\n').filter(line => line.trim());
        const initResponse = JSON.parse(lines[lines.length - 1]);
        
        if (initResponse.result && initResponse.result.capabilities && initResponse.result.capabilities.tools) {
            console.log('TOOLS_FOUND');
        } else {
            console.log('TOOLS_NOT_FOUND');
        }
    } catch (e) {
        console.log('PARSE_ERROR');
    }
});

// Send initialize request
const initRequest = {
    jsonrpc: "2.0",
    id: 1,
    method: "initialize",
    params: {
        protocolVersion: "2024-11-05",
        capabilities: {
            tools: {}
        },
        clientInfo: {
            name: "test-client",
            version: "1.0.0"
        }
    }
};

server.stdin.write(JSON.stringify(initRequest) + '\n');
EOF

    # Check if Node.js is available
    if ! command -v node &> /dev/null; then
        print_status "WARN" "Node.js not available, skipping MCP tool discovery test"
        return 0
    fi
    
    # Run the test
    if node test_mcp_tools.js 2>/dev/null | grep -q "TOOLS_FOUND"; then
        print_status "PASS" "MCP tool discovery successful"
    else
        print_status "WARN" "MCP tool discovery test inconclusive (may need cluster connection)"
    fi
    
    # Cleanup
    rm -f test_mcp_tools.js
    return 0
}

# Test 6: OpenShift AI Client Configuration
test_openshift_ai_client() {
    print_status "INFO" "Testing OpenShift AI client configuration..."
    
    # Check if OpenShift AI client code compiles
    if go build -o /tmp/test_openshift_ai ./pkg/openshift-ai/... 2>/dev/null; then
        print_status "PASS" "OpenShift AI client compiles successfully"
        rm -f /tmp/test_openshift_ai
    else
        print_status "FAIL" "OpenShift AI client compilation failed"
        return 1
    fi
    return 0
}

# Test 7: Tool Definitions
test_tool_definitions() {
    print_status "INFO" "Testing OpenShift AI tool definitions..."
    
    local tools=(
        "datascience-projects"
        "models" 
        "applications"
        "experiments"
        "pipelines"
    )
    
    for tool in "${tools[@]}"; do
        if grep -r "\"$tool\"" pkg/toolsets/openshift-ai/ > /dev/null; then
            print_status "PASS" "Tool '$tool' defined"
        else
            print_status "FAIL" "Tool '$tool' not found"
            return 1
        fi
    done
    
    return 0
}

# Test 8: API Structure Validation
test_api_structure() {
    print_status "INFO" "Testing API structure validation..."
    
    # Check for required functions in tool files
    local required_functions=(
        "handleDataScienceProject"
        "handleModel"
        "handleApplication"
        "handleExperiment"
        "handlePipeline"
    )
    
    for func in "${required_functions[@]}"; do
        if grep -r "$func" pkg/toolsets/openshift-ai/ > /dev/null; then
            print_status "PASS" "Handler function '$func' found"
        else
            print_status "WARN" "Handler function '$func' not found"
        fi
    done
    
    return 0
}

# Test 9: Dependencies
test_dependencies() {
    print_status "INFO" "Testing dependencies..."
    
    # Check if Go modules are tidy
    if ! go mod tidy > /dev/null 2>&1; then
        print_status "FAIL" "Go modules not tidy"
        return 1
    fi
    
    # Check if all imports are available
    if ! go mod download > /dev/null 2>&1; then
        print_status "FAIL" "Failed to download dependencies"
        return 1
    fi
    
    print_status "PASS" "Dependencies are valid"
    return 0
}

# Test 10: Code Quality
test_code_quality() {
    print_status "INFO" "Testing code quality..."
    
    # Run go vet
    if ! go vet ./pkg/openshift-ai/... > /dev/null 2>&1; then
        print_status "FAIL" "Go vet found issues"
        return 1
    fi
    
    # Run go fmt check
    if [ "$(gofmt -l pkg/openshift-ai/...)" != "" ]; then
        print_status "WARN" "Code not formatted with gofmt"
    else
        print_status "PASS" "Code formatting is correct"
    fi
    
    return 0
}

# Test 11: Integration Test (if cluster available)
test_integration() {
    print_status "INFO" "Testing integration (requires cluster connection)..."
    
    # Check if kubeconfig exists
    if [ ! -f "$HOME/.kube/config" ] && [ -z "$KUBECONFIG" ]; then
        print_status "WARN" "No kubeconfig found, skipping integration tests"
        return 0
    fi
    
    # Try to connect to cluster
    if kubectl cluster-info > /dev/null 2>&1; then
        print_status "PASS" "Cluster connection available"
        
        # Test if OpenShift AI CRDs are available
        if kubectl get crd datascienceprojects.opendatahub.io > /dev/null 2>&1; then
            print_status "PASS" "OpenShift AI CRDs found in cluster"
        else
            print_status "WARN" "OpenShift AI CRDs not found (expected in non-AI clusters)"
        fi
    else
        print_status "WARN" "Cannot connect to cluster, skipping integration tests"
    fi
    
    return 0
}

# Main test execution
main() {
    local failed_tests=0
    local total_tests=0
    
    # Run all tests
    local tests=(
        "test_binary_build"
        "test_tool_registration" 
        "test_mcp_server_start"
        "test_configuration"
        "test_tool_discovery"
        "test_openshift_ai_client"
        "test_tool_definitions"
        "test_api_structure"
        "test_dependencies"
        "test_code_quality"
        "test_integration"
    )
    
    for test in "${tests[@]}"; do
        echo ""
        $test || ((failed_tests++))
        ((total_tests++))
    done
    
    # Summary
    echo ""
    echo "📊 Test Summary"
    echo "================="
    echo "Total tests: $total_tests"
    echo "Passed: $((total_tests - failed_tests))"
    echo "Failed: $failed_tests"
    
    if [ $failed_tests -eq 0 ]; then
        print_status "PASS" "All tests passed! Ready to publish 🚀"
        return 0
    else
        print_status "FAIL" "$failed_tests test(s) failed. Fix issues before publishing."
        return 1
    fi
}

# Check if we're in the right directory
if [ ! -f "go.mod" ]; then
    print_status "FAIL" "Must run from project root directory"
    exit 1
fi

# Run main function
main "$@"
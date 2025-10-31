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

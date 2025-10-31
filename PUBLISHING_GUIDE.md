# Ethical Fork Publishing Guide

## Package Naming Philosophy

Your fork adds OpenShift AI support to the excellent kubernetes-mcp-server by Marc Nuri and the Red Hat team. The naming reflects this:

### **Main Package**: `kubernetes-mcp-server-openshift-ai`
- **Clear attribution**: Maintains original project name
- **Descriptive suffix**: "-openshift-ai" indicates your specific contribution
- **No confusion**: Clearly shows it's a variant, not replacement

### **Platform Packages**: `kubernetes-mcp-server-openshift-ai-darwin-arm64`
- **Consistent naming**: Same pattern across all platforms
- **Transparent**: Users know exactly what they're getting

## Installation Commands

### For Public npm (after publishing):
```bash
npm install kubernetes-mcp-server-openshift-ai
```

### For GitHub Packages (current):
```bash
npm config set @macayaven:registry https://npm.pkg.github.com/
npm install @macayaven/kubernetes-mcp-server
```

## Publishing to Public npm

1. **Login to npm**:
   ```bash
   npm login
   ```

2. **Publish packages**:
   ```bash
   make npm-publish
   ```

## Ethical Considerations Met

✅ **Clear attribution**: Original author credited in package metadata  
✅ **Descriptive naming**: "-openshift-ai" suffix explains your contribution  
✅ **No confusion**: Not trying to pass off as original work  
✅ **Transparent**: Fork nature is obvious from name  

This approach respects the original work while making your valuable OpenShift AI contribution easily discoverable.
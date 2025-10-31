# Forking & Extension Guidelines

This document outlines the proper etiquette and guidelines followed when creating this fork of kubernetes-mcp-server.

## 🍴 Fork Information

### Original Project
- **Name**: kubernetes-mcp-server
- **Author**: Marc Nuri
- **Repository**: https://github.com/containers/kubernetes-mcp-server
- **License**: Apache License 2.0

### This Fork
- **Name**: openshift-mcp-server (with OpenShift AI enhancements)
- **Author**: Carlos Macaya
- **Repository**: https://github.com/macayaven/openshift-mcp-server
- **License**: Apache License 2.0 (preserved)

## 🎯 Purpose of This Fork

This fork was created to add **OpenShift AI** capabilities to the excellent kubernetes-mcp-server foundation while maintaining full compatibility with the original project.

### Key Principles Followed

1. **🔧 Compatibility**: All original functionality preserved
2. **📝 Attribution**: Original work clearly credited
3. **🏷️ Naming**: Distinct package names to avoid confusion
4. **📚 Documentation**: Comprehensive documentation of changes
5. **🤝 Openness**: Transparent development process
6. **🎓 Learning**: Clear indication of learning/development status

## 📋 Forking Etiquette Checklist

### ✅ What We Did Right

1. **Proper Attribution**
   - Original author and project clearly credited
   - Link to original repository provided
   - Original license preserved

2. **Clear Naming**
   - Different package names: `kubernetes-mcp-server-openshift-ai`
   - Different container registry: `quay.io/macayaven/kubernetes_mcp_server_openshift_ai`
   - Clear indication in documentation

3. **Documentation**
   - Comprehensive README with fork notice
   - Clear explanation of enhancements
   - Installation differences documented

4. **License Compliance**
   - Original Apache License 2.0 maintained
   - No license violations

5. **Transparent Development**
   - All commits publicly visible
   - Clear commit messages
   - Proper branching strategy

6. **Learning Phase Indication**
   - Clear notice about learning/development status
   - Encouragement for issue reporting
   - Patience requested from users

### 🎯 Development Guidelines

#### Code Changes
- **Preserve Original**: Don't modify core functionality unnecessarily
- **Additive Approach**: Add new features without breaking existing ones
- **Code Style**: Follow original project's coding conventions
- **Testing**: Maintain or improve test coverage

#### Distribution
- **Separate Packages**: Use different package names
- **Different Registries**: Use your own container registry
- **Clear Documentation**: Explain differences and installation

#### Communication
- **Credit Original**: Always mention original project
- **Be Transparent**: Be clear about fork status and purpose
- **Contribute Back**: Consider contributing useful changes upstream

## 🚀 For Others Wanting to Fork

If you want to fork this (or the original) project, here's a recommended approach:

### 1. Initial Setup
```bash
# Fork the repository on GitHub
git clone https://github.com/YOUR_USERNAME/kubernetes-mcp-server.git
cd kubernetes-mcp-server
git remote add upstream https://github.com/containers/kubernetes-mcp-server.git
```

### 2. Make Changes
```bash
# Create a feature branch
git checkout -b feature/your-enhancement

# Make your changes
# ... (code changes) ...

# Commit with clear messages
git commit -m "feat: add your enhancement description"
```

### 3. Update Package Names
```bash
# Update package.json files with your own scope/name
find npm -name "package.json" -exec sed -i 's/kubernetes-mcp-server/your-mcp-server/g' {} \;
```

### 4. Update Container Registry
```yaml
# In .github/workflows/release-image.yml
env:
  IMAGE_NAME: quay.io/YOUR_USERNAME/your_mcp_server
```

### 5. Update Documentation
- Add fork notice to README.md
- Create attribution section
- Document your enhancements
- Update installation instructions

### 6. Publishing
- Use your own npm registry or scope
- Use your own container registry
- Don't conflict with original package names

## 🤝 Contributing Back

If you add useful features, consider contributing them back to the original project:

1. **Check Original**: Does the original project need this feature?
2. **Create PR**: Submit a pull request to upstream
3. **Coordinate**: Work with original maintainer
4. **Credit**: Mention your fork in the PR

## 📚 Resources

- [GitHub Forking Guide](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
- [Open Source Etiquette](https://opensource.guide/starting-a-project/)
- [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)

---

**Remember**: Forking is a normal part of open source. The key is to do it respectfully, with proper attribution, and clear communication about your intentions and changes.
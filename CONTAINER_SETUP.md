# Container Publishing Setup

This guide helps you set up container publishing for your fork of kubernetes-mcp-server.

## 🐳 Container Registry Configuration

### Current Configuration
- **Registry**: `quay.io/macayaven/kubernetes_mcp_server_openshift_ai`
- **Workflow**: `.github/workflows/release-image.yml`
- **Trigger**: Push to main branch or manual workflow dispatch

### Required GitHub Secrets

You need to set up these secrets in your GitHub repository:

#### 1. QUAY_USERNAME
Your Quay.io username.

```bash
# Set the secret
gh secret set QUAY_USERNAME -R macayaven/openshift-mcp-server --body "your-quay-username"
```

#### 2. QUAY_PASSWORD
Your Quay.io password or access token.

```bash
# Set the secret
gh secret set QUAY_PASSWORD -R macayaven/openshift-mcp-server --body "your-quay-password-or-token"
```

### Quay.io Setup

If you don't have a Quay.io account:

1. **Create Account**: Go to [quay.io](https://quay.io) and sign up
2. **Create Repository**: Create a repository named `kubernetes_mcp_server_openshift_ai`
3. **Generate Token**: Create an access token with `write` permissions

#### Using Access Token (Recommended)
1. Go to your Quay.io account settings
2. Navigate to "Applications" → "Generate Token"
3. Give it a name (e.g., "github-actions")
4. Select permissions: `write` for repositories
5. Use the token as `QUAY_PASSWORD`

### Manual Publishing

If you prefer to publish manually:

```bash
# Build the image
podman build -t quay.io/macayaven/kubernetes_mcp_server_openshift_ai:latest .

# Login to Quay
podman login quay.io

# Push the image
podman push quay.io/macayaven/kubernetes_mcp_server_openshift_ai:latest
```

### Testing the Workflow

After setting up secrets:

1. **Go to**: https://github.com/macayaven/openshift-mcp-server/actions
2. **Click**: "Release as container image" workflow
3. **Click**: "Run workflow"
4. **Select branch**: `main`
5. **Click**: "Run workflow"

### Troubleshooting

#### Common Issues

1. **Authentication Failed**
   - Check QUAY_USERNAME and QUAY_PASSWORD secrets
   - Ensure token has proper permissions
   - Verify repository exists on Quay.io

2. **Repository Not Found**
   - Create the repository on Quay.io first
   - Check spelling of repository name

3. **Permission Denied**
   - Ensure token has `write` permissions
   - Check if you're the repository owner

#### Debugging

Check the workflow logs:
```bash
# View recent workflow runs
gh run list --repo macayaven/openshift-mcp-server

# View specific run logs
gh run view --log <run-id> --repo macayaven/openshift-mcp-server
```

### Container Image Usage

Once published, users can pull your image:

```bash
# Pull the image
podman pull quay.io/macayaven/kubernetes_mcp_server_openshift_ai:latest

# Run the image
podman run -it --rm \
  -v ~/.kube/config:/root/.kube/config:ro \
  quay.io/macayaven/kubernetes_mcp_server_openshift_ai:latest
```

### Security Considerations

- **Secrets**: Never commit secrets to repository
- **Tokens**: Use access tokens instead of passwords
- **Permissions**: Grant minimum required permissions
- **Rotation**: Rotate tokens regularly

---

**Note**: This container publishing is optional. The primary distribution method for this fork is through npm packages.
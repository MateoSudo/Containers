# GitHub OAuth Integration Setup for Gitea

This guide shows how to configure GitHub OAuth authentication in your Gitea instance using the provided OAuth credentials.

## 🔐 GitHub OAuth Credentials
- **Client ID**: `Ov23lizUjUk7HUJi1tTi`
- **Client Secret**: `71486232bfd63c596e669667f525ee797d6147fa`

## 📋 Setup Steps

### Step 1: Access Gitea Admin Panel
1. Navigate to your Gitea instance: http://localhost:3000
2. Sign in as administrator
3. Go to **Site Administration** → **Authentication Sources**

### Step 2: Add GitHub OAuth Source
1. Click **Add Authentication Source**
2. Configure the following settings:

   **Basic Settings:**
   - **Authentication Type**: `OAuth2`
   - **Authentication Name**: `GitHub`
   - **OAuth2 Provider**: `GitHub`

   **OAuth2 Configuration:**
   - **Client ID**: `Ov23lizUjUk7HUJi1tTi`
   - **Client Secret**: `71486232bfd63c596e669667f525ee797d6147fa`
   - **OpenID Connect Auto Discovery URL**: Leave empty
   - **Custom URLs**: Leave empty (GitHub defaults will be used)

   **Advanced Settings:**
   - **Icon URL**: `https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png`
   - **Skip Local 2FA**: ☐ (unchecked - recommended)
   - **Scopes**: `user:email,read:org` (optional, for additional permissions)

3. Click **Add Authentication Source**

### Step 3: Configure Gitea Settings
Update your Gitea configuration to enable OAuth:

1. **Via Web Interface:**
   - Go to **Site Administration** → **Configuration**
   - Under **Service Configuration**:
     - ✅ Enable **Allow Only External Registration**
     - ✅ Enable **Enable OpenID Sign-In**
     - ✅ Enable **Enable OAuth2 Sign-In**

2. **Via Environment Variables** (in docker-compose.yml):
   ```yaml
   environment:
     - GITEA__oauth2_client__ENABLE_OPENID_SIGNIN=true
     - GITEA__service__ALLOW_ONLY_EXTERNAL_REGISTRATION=false
     - GITEA__service__ENABLE_OPENID_SIGN_IN=true
     - GITEA__service__ENABLE_OAUTH2_SIGN_IN=true
   ```

### Step 4: Test OAuth Integration
1. **Logout** from Gitea admin account
2. On the login page, you should see a **"Sign in with GitHub"** button
3. Click it to test the OAuth flow
4. You should be redirected to GitHub for authorization
5. After approving, you'll be redirected back to Gitea with a new account

## 🔄 Webhook Integration Benefits

With OAuth configured, users can:
- **Sign in with GitHub** credentials
- **Automatic account linking** for webhook operations
- **Seamless user experience** between GitHub and Gitea
- **Synchronized user permissions** (if configured)

## 🛠️ Advanced Configuration

### Custom User Mapping
You can configure how GitHub user data maps to Gitea:

```yaml
environment:
  - GITEA__oauth2_client__USERNAME=preferred_username
  - GITEA__oauth2_client__EMAIL=email
  - GITEA__oauth2_client__FULL_NAME=name
```

### Organization Synchronization
To sync GitHub organizations:

1. **In GitHub OAuth App Settings:**
   - Grant organization access
   - Request `read:org` scope

2. **In Gitea:**
   - Enable organization creation from OAuth
   - Configure team synchronization

### Webhook User Authentication
For webhook operations, ensure the webhook has access to:
- Repository read/write permissions
- User account linking
- Organization membership (if applicable)

## 🔐 Security Considerations

1. **Client Secret Protection:**
   - Store in environment variables only
   - Never commit to version control
   - Rotate periodically

2. **Scope Limitations:**
   - Request minimal required scopes
   - Regularly audit OAuth permissions
   - Monitor OAuth application usage

3. **Access Control:**
   - Configure Gitea user registration policies
   - Set up appropriate team/organization permissions
   - Review OAuth user access regularly

## 📊 Testing the Complete Setup

### Test OAuth Login:
```bash
# 1. Logout from Gitea
# 2. Visit login page
# 3. Click "Sign in with GitHub"
# 4. Verify successful authentication
```

### Test Webhook Sync:
```bash
# 1. Make a change in GitHub repository
# 2. Check if it appears in Gitea mirror
# 3. Make a change in Gitea repository
# 4. Check if it syncs to GitHub
```

### Monitor Webhook Activity:
```bash
# Check webhook logs
docker logs gitea-webhook-github
docker logs gitea-webhook-gitea

# Check webhook endpoints
curl http://localhost:5000/health
curl http://localhost:5001/health
```

## 🎯 Expected Results

After successful setup:
- ✅ Users can sign in with GitHub accounts
- ✅ Webhook sync works bidirectionally
- ✅ Repository changes appear in both platforms
- ✅ User accounts are linked between platforms
- ✅ Seamless development workflow

## 🚨 Troubleshooting

### OAuth Login Issues:
- Check Client ID/Secret configuration
- Verify OAuth app callback URL
- Check Gitea service configuration

### Webhook Sync Issues:
- Verify webhook URLs are accessible
- Check webhook secrets match
- Review webhook handler logs
- Test network connectivity

### Permission Issues:
- Verify GitHub token permissions
- Check Gitea user permissions
- Review repository access rights 
# PlombiPro Automated Build & Deploy System

## Overview

This automated build and deployment system automatically builds your Android app, increments the version number, and deploys it to Firebase App Distribution whenever you pull changes from the `main` branch.

## 🎯 Current Configuration

- **Current Version**: 0.7.0+1
- **Firebase App ID**: 1:268663350911:android:e3f69147ff7c8bcd66014a
- **Firebase Project**: plombipro-devlpt
- **Default Tester**: editionsrevel@gmail.com
- **Auto-increment**: Patch version (0.7.0 → 0.7.1 → 0.7.2, etc.)

## 📁 Files Created

1. **scripts/version-manager.sh** - Manages version numbers in pubspec.yaml
2. **auto-build-deploy.sh** - Main automation script for build and deploy
3. **.git/hooks/post-merge** - Git hook that triggers on `git pull`

## 🚀 How It Works

### Automatic Workflow (After Git Pull)

When you pull changes from the `main` branch:

```bash
git pull origin main
```

The system automatically:
1. ✅ Detects merge on main branch
2. ✅ Increments version number (patch increment by default)
3. ✅ Commits version change to git
4. ✅ Runs clean Flutter build
5. ✅ Generates release APK
6. ✅ Deploys to Firebase App Distribution
7. ✅ Sends invitation email to tester

**Result**: editionsrevel@gmail.com receives email with download link

## 📝 Manual Usage

### Quick Deploy (with auto version increment)

```bash
./auto-build-deploy.sh
```

This will:
- Increment patch version (0.7.0 → 0.7.1)
- Build release APK
- Deploy to Firebase
- Send to editionsrevel@gmail.com

### Custom Version Increment

**Increment patch version** (0.7.0 → 0.7.1):
```bash
./auto-build-deploy.sh --increment patch
```

**Increment minor version** (0.7.0 → 0.8.0):
```bash
./auto-build-deploy.sh --increment minor
```

**Increment major version** (0.7.0 → 1.0.0):
```bash
./auto-build-deploy.sh --increment major
```

### Deploy Without Version Change

```bash
./auto-build-deploy.sh --skip-version
```

### Debug Build

```bash
./auto-build-deploy.sh --type debug
```

### Custom Tester Email

```bash
./auto-build-deploy.sh --email another@example.com
```

### All Options Combined

```bash
./auto-build-deploy.sh \
  --increment minor \
  --type release \
  --email test@example.com
```

## 🔧 Version Manager

The version manager can be used standalone:

**Get current version:**
```bash
./scripts/version-manager.sh get
```

**Increment versions:**
```bash
./scripts/version-manager.sh patch   # 0.7.0 → 0.7.1
./scripts/version-manager.sh minor   # 0.7.0 → 0.8.0
./scripts/version-manager.sh major   # 0.7.0 → 1.0.0
```

**Set specific version:**
```bash
./scripts/version-manager.sh set 0.9.5+20
```

## ⚙️ Configuration

### Change Default Tester Email

Edit `auto-build-deploy.sh`:
```bash
TESTER_EMAIL="newemail@example.com"
```

### Change Version Increment Type

Edit `auto-build-deploy.sh`:
```bash
VERSION_INCREMENT="minor"  # Options: patch, minor, major
```

### Change Default Build Type

Edit `auto-build-deploy.sh`:
```bash
BUILD_TYPE="debug"  # Options: debug, release
```

### Disable Auto-Deploy Hook

Edit `.git/hooks/post-merge`:
```bash
AUTO_DEPLOY_ENABLED=false
```

### Enable Auto-Deploy Only on Main Branch

The hook is already configured to only run on the `main` branch. To change the target branch, edit `.git/hooks/post-merge`:
```bash
TARGET_BRANCH="develop"  # Change to your preferred branch
```

## 🎬 First Time Setup

1. **Ensure Firebase CLI is authenticated:**
   ```bash
   firebase login
   ```

2. **Test the version manager:**
   ```bash
   ./scripts/version-manager.sh get
   ```

3. **Test manual build (without version increment):**
   ```bash
   ./auto-build-deploy.sh --skip-version --skip-commit
   ```

4. **Test the full workflow:**
   ```bash
   ./auto-build-deploy.sh
   ```

5. **Check Firebase Console:**
   - Go to: https://console.firebase.google.com
   - Navigate to: App Distribution
   - Verify the build appears

## 📊 Version Number Format

Format: `MAJOR.MINOR.PATCH+BUILD`

Example: `0.7.0+1`
- **0** = Major version (breaking changes)
- **7** = Minor version (new features)
- **0** = Patch version (bug fixes)
- **1** = Build number (internal counter)

### Automatic Increments:
- **Patch**: 0.7.0+1 → 0.7.1+2
- **Minor**: 0.7.0+1 → 0.8.0+2
- **Major**: 0.7.0+1 → 1.0.0+2

## 🔍 Troubleshooting

### Hook Not Triggering

Check if hook is executable:
```bash
ls -la .git/hooks/post-merge
```

If not, make it executable:
```bash
chmod +x .git/hooks/post-merge
```

### Firebase CLI Not Found

Install Firebase CLI:
```bash
npm install -g firebase-tools
firebase login
```

### Build Fails

Try manual build first:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Check Hook Is Enabled

```bash
cat .git/hooks/post-merge | grep AUTO_DEPLOY_ENABLED
```

Should show: `AUTO_DEPLOY_ENABLED=true`

### View Deployment Logs

If running in background, check:
```bash
cat auto-deploy.log
```

## 📱 Tester Instructions

When editionsrevel@gmail.com receives the Firebase email:

1. Open email from Firebase App Distribution
2. Click "Download" or "View Release"
3. Allow installation from unknown sources (if needed)
4. Install the APK
5. Open PlombiPro app
6. Test and report feedback

## 🎯 Best Practices

1. **Always test locally** before deploying
2. **Commit changes** before triggering auto-deploy
3. **Use semantic versioning**:
   - Patch: Bug fixes only
   - Minor: New features (backwards compatible)
   - Major: Breaking changes
4. **Check Firebase console** after deployment
5. **Verify tester receives email**

## 🔄 Workflow Example

```bash
# 1. Make changes to code
git add .
git commit -m "feat: add new feature"

# 2. Push to remote
git push origin main

# 3. On another machine (or after pulling)
git pull origin main
# → Auto-deploy triggers!
# → Version increments: 0.7.0 → 0.7.1
# → Builds APK
# → Deploys to Firebase
# → Sends email to tester

# 4. Check result
./scripts/version-manager.sh get
# Output: 0.7.1+2
```

## 📚 Additional Resources

- [Firebase App Distribution Docs](https://firebase.google.com/docs/app-distribution)
- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)
- [Git Hooks Guide](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)

## ✅ Quick Reference

| Command | Description |
|---------|-------------|
| `./auto-build-deploy.sh` | Build, increment patch, deploy |
| `./auto-build-deploy.sh --increment minor` | Increment minor version |
| `./auto-build-deploy.sh --skip-version` | Deploy without version change |
| `./auto-build-deploy.sh --type debug` | Build debug APK |
| `./scripts/version-manager.sh get` | Show current version |
| `git pull origin main` | Pull and auto-deploy (if on main) |

## 🎉 You're All Set!

The system is now ready. Every time you `git pull` on the main branch, a new build will automatically be created and deployed to Firebase App Distribution, with the version number automatically incremented.

**Current Version**: 0.7.0+1
**Next Version**: 0.7.1+2 (after next deployment)

---

*Generated by Claude Code - PlombiPro Automated Build System*

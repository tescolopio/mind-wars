# GitHub Actions Workflows

This directory contains automated workflows for building and deploying Mind Wars.

## Available Workflows

### 🤖 Build Alpha APK (`build-alpha.yml`)

Builds an Android APK with the alpha flavor for testing.

**Triggers:**
- Manual: Go to Actions → Build Alpha APK → Run workflow
- Automatic: On push to `main` or `develop` branches (excluding docs changes)

**Output:**
- Artifact: `mind-wars-alpha-apk`
- File: `mind-wars-v{version}-alpha.apk`
- Retention: 30 days

**Steps:**
1. Checks out code
2. Sets up Java 17 and Flutter 3.24.x
3. Runs analyzer and tests
4. Builds alpha APK
5. Uploads as artifact

**To download:**
1. Go to Actions tab
2. Click on the workflow run
3. Scroll to "Artifacts" section
4. Download `mind-wars-alpha-apk`

### 🍎 Build Alpha iOS (`build-alpha-ios.yml`)

Builds an iOS app for alpha testing (without codesigning).

**Triggers:**
- Manual only: Go to Actions → Build Alpha iOS → Run workflow

**Output:**
- Artifact: `mind-wars-alpha-ios`
- File: `Runner.xcarchive`
- Retention: 30 days

**Note:** For actual device installation, you need:
- Apple Developer account
- Proper code signing certificates
- Provisioning profiles
- TestFlight setup or ad-hoc distribution

This workflow builds without codesigning for demonstration purposes. For production iOS builds, see [Flutter iOS deployment docs](https://docs.flutter.dev/deployment/ios).

## Running Workflows Manually

1. Navigate to the repository on GitHub
2. Click the **Actions** tab
3. Select the workflow you want to run from the left sidebar
4. Click **"Run workflow"** button (top right)
5. Select the branch to run on (usually `main`)
6. Click **"Run workflow"** to start

## Viewing Results

After a workflow completes:
1. Click on the workflow run to see details
2. Check the job logs for any issues
3. Download artifacts from the "Artifacts" section at the bottom

## Troubleshooting

### Build Fails at "Run tests"
- Check test output in the logs
- Fix failing tests in your branch
- Re-run the workflow

### Build Fails at "Build Alpha APK"
- Check Flutter and Gradle output
- Ensure all dependencies are properly configured
- Verify `pubspec.yaml` and `build.gradle` are correct

### Artifacts Not Available
- Artifacts are only created if the build succeeds
- Artifacts expire after 30 days
- Check workflow logs for build errors

## Adding New Workflows

To add a new workflow:
1. Create a new `.yml` file in this directory
2. Define triggers, jobs, and steps
3. Commit and push to test
4. Document it in this README

## Useful Links

- [GitHub Actions documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD guide](https://docs.flutter.dev/deployment/cd)
- [Android deployment guide](https://docs.flutter.dev/deployment/android)
- [iOS deployment guide](https://docs.flutter.dev/deployment/ios)

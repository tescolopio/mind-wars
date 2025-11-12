# Quick Start Guide - Alpha Testing Authentication

## 🎯 Overview

This guide helps you get started with Mind Wars alpha testing. The app now supports **local authentication** so you can create accounts and login without requiring a backend server.

## 🚀 Getting Started

### 1. Build and Run the App

```bash
# Install dependencies
flutter pub get

# Run on your device
flutter run
```

### 2. Create Your Account

When you launch the app:

1. **See the splash screen** with "ALPHA VERSION" badge
2. **On the login screen**, tap "Create New Account"
3. **Fill in your details**:
   - Username (minimum 3 characters)
   - Email (valid format)
   - Password (8+ chars, uppercase, lowercase, number)
   - Confirm password
4. **Tap "Create Account"**
5. You're in! 🎉

### 3. Using the App

After creating your account:
- ✅ Your credentials are saved locally on your device
- ✅ You can logout and login again anytime
- ✅ Check "Remember me" to auto-login on app restart
- ✅ All your game progress is saved locally

## 📱 What You'll See

### Alpha Mode Indicators

You'll notice these visual cues that you're in alpha mode:

1. **Splash Screen**: Shows "ALPHA VERSION" badge
2. **Login Screen**: Blue info banner explaining local authentication
3. **Registration Screen**: Blue info banner about local storage
4. **App Title**: "Mind Wars Alpha" instead of "Mind Wars"

## 🔐 Your Data

### Where is it stored?

- **Locally on your device** in an SQLite database
- **Password is hashed** (not stored in plain text)
- **No data sent to servers** (there's no backend yet!)

### Multiple Accounts

You can create multiple accounts on the same device:
- Each needs a unique email
- Each needs a unique username
- Switch accounts by logging out and logging back in

## 🧪 Testing Scenarios

Try these scenarios to help us test:

### Registration
- ✅ Create account with valid credentials
- ✅ Try weak passwords (should fail)
- ✅ Try invalid emails (should fail)
- ✅ Try duplicate email (should fail)
- ✅ Try duplicate username (should fail)

### Login
- ✅ Login with correct credentials
- ✅ Try wrong password (should fail)
- ✅ Try non-existent email (should fail)
- ✅ Use "Remember me" and restart app

### Multiple Sessions
- ✅ Create multiple accounts
- ✅ Logout and login to different accounts
- ✅ Verify each account has its own data

## ❓ Troubleshooting

### Can't Login After Creating Account

- Double-check your email and password
- Make sure password meets requirements (8+ chars, mixed case, numbers)
- Try logging out and logging back in

### Forgot Your Password

In alpha mode, there's no password recovery. You can:
- Create a new account with a different email
- Clear app data and start fresh
- Reinstall the app

### App Crashes or Errors

Please report any issues with:
- Device model and OS version
- Steps to reproduce the problem
- Screenshots if possible
- Error messages if any

## 📊 What We're Testing

Help us validate these features:

- [ ] Account creation process
- [ ] Login flow
- [ ] Auto-login (remember me)
- [ ] Password validation
- [ ] Email validation
- [ ] Duplicate prevention
- [ ] Multiple accounts
- [ ] Logout functionality
- [ ] App performance
- [ ] UI/UX flow

## 🐛 Reporting Issues

Found a bug? Please report it with:

1. **Clear title** describing the issue
2. **Steps to reproduce** the problem
3. **Expected behavior** vs actual behavior
4. **Screenshots** if applicable
5. **Device info** (model, OS version)
6. **Label**: `alpha-testing`

## 💡 Tips

- **Use a test email** - Use a throwaway email for testing
- **Try edge cases** - Test with unusual inputs to find bugs
- **Document everything** - Take notes on your experience
- **Be creative** - Try to break things!

## 🎮 Next Steps

Once you're logged in:
1. Explore the home screen
2. Try the lobby system
3. Test the games
4. Check the leaderboard
5. Customize your profile

## 🔮 Coming Soon

When the backend is ready:
- ☁️ Cloud sync of your local account
- 🔄 Multi-device sync
- 📧 Email verification
- 🔑 Password reset
- 🌐 Online multiplayer
- 📊 Global leaderboards

## 📚 Technical Details

Want to know how it works? Check out:
- `ALPHA_AUTH_SETUP.md` - Detailed technical documentation
- `lib/services/local_auth_service.dart` - Authentication implementation
- `test/alpha_auth_integration_test.dart` - Test scenarios

## 🤝 Thank You!

Your alpha testing helps us build a better game. Every bug you find, every piece of feedback you provide, makes Mind Wars better for everyone.

**Happy testing!** 🧠⚔️

---

*Questions? Issues? Reach out via GitHub issues or team channels.*

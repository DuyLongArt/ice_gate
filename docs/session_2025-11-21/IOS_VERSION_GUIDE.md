# How to Change iOS Version in Flutter - Step by Step Guide

## Understanding the Issue

Your Flutter app is trying to run on an iPhone 16 Plus simulator that requires iOS 26.1, but:
1. You don't have iOS 26.1 SDK installed in Xcode
2. Your app's minimum deployment target is set to iOS 15.0

**You have 3 options:**

---

## Option 1: Use a Different Simulator (Easiest) ✅ RECOMMENDED

### Step 1: List Available Simulators
```bash
flutter devices
```

### Step 2: Choose macOS or Chrome
```bash
# Run on macOS (works great for development)
flutter run -d macos

# Or run on Chrome (web version)
flutter run -d chrome
```

**Pros:** No Xcode changes needed, works immediately
**Cons:** Not testing on iOS specifically

---

## Option 2: Install iOS 26.1 Runtime in Xcode

### Step 1: Open Xcode
```bash
open -a Xcode
```

### Step 2: Go to Settings
- Click **Xcode** in menu bar → **Settings** (or press `Cmd + ,`)

### Step 3: Navigate to Platforms Tab
- Click on **Platforms** tab (or **Components** in older Xcode versions)

### Step 4: Download iOS 26.1
- Look for **iOS 26.1** in the list
- Click the **Download** button (⬇️ icon)
- Wait for download to complete (can take 10-30 minutes)

### Step 5: Restart Xcode
- Close and reopen Xcode

### Step 6: Run Flutter App
```bash
flutter run
```

**Pros:** Can test on latest iOS version
**Cons:** Large download, takes time

---

## Option 3: Use an Older iOS Simulator

### Step 1: Check Available Simulators
```bash
xcrun simctl list devices available
```

### Step 2: Create a Simulator with Installed iOS Version
```bash
# List available runtimes
xcrun simctl list runtimes

# Create a new simulator (example with iOS 18.5 if available)
xcrun simctl create "iPhone 15" "iPhone 15" "iOS-18-5"
```

### Step 3: Open Simulator
```bash
open -a Simulator
```

### Step 4: Select Your New Simulator
- In Simulator app: **File** → **Open Simulator** → Choose your created device

### Step 5: Run Flutter App
```bash
flutter run
```

**Pros:** Uses iOS runtime you already have
**Cons:** Requires command-line work

---

## Files We Already Modified (For Reference)

### 1. Podfile
**Location:** `ios/Podfile`
**Line 2:** Changed to `platform :ios, '15.0'`

This sets the **minimum** iOS version your app supports (iOS 15.0+).

### 2. Xcode Project
**Location:** `ios/Runner.xcodeproj/project.pbxproj`
**Lines 458, 587, 638:** Changed `IPHONEOS_DEPLOYMENT_TARGET = 15.0`

This ensures Xcode knows the minimum deployment target.

---

## What Each Version Number Means

### Deployment Target (15.0)
- **Minimum** iOS version users need to run your app
- Set in Podfile and project.pbxproj
- Your app will run on iOS 15.0, 16.0, 17.0, 18.0, etc.

### Simulator Runtime (26.1)
- The **specific** iOS version the simulator is running
- Needs to be installed in Xcode
- Independent of deployment target

### Example:
- Your app supports iOS 15.0+ (deployment target)
- But you're trying to run on a simulator with iOS 26.1 (not installed)
- Solution: Either install iOS 26.1 OR use a different simulator

---

## Quick Fix Commands

### Check what you have:
```bash
# See available devices
flutter devices

# See installed iOS runtimes
xcrun simctl list runtimes
```

### Run on available device:
```bash
# macOS (easiest)
flutter run -d macos

# Chrome
flutter run -d chrome

# Specific device
flutter run -d <device-id>
```

---

## Recommended Solution for You

Since you're developing and testing features, I recommend:

### For Development & Testing:
```bash
flutter run -d macos
```
**Why:** 
- ✅ Works immediately
- ✅ Camera works on Mac
- ✅ Fast hot reload
- ✅ No iOS SDK downloads needed

### For iOS-Specific Testing Later:
1. Download iOS 26.1 in Xcode Settings → Platforms
2. Or use a physical iPhone (best for camera testing)

---

## Troubleshooting

### "Unable to find a destination matching..."
**Cause:** Simulator iOS version not installed
**Fix:** Use Option 1 (macOS) or Option 2 (Download iOS runtime)

### "iOS 26.1 is not installed"
**Cause:** Xcode doesn't have that iOS version
**Fix:** Download from Xcode Settings → Platforms

### "CocoaPods version warning"
**Cause:** Old CocoaPods version
**Fix:** 
```bash
sudo gem install cocoapods
```

---

## Summary

**Current Status:**
- ✅ iOS deployment target set to 15.0
- ✅ Podfile configured correctly
- ✅ App can run on macOS
- ❌ iOS 26.1 runtime not installed

**Next Steps:**
1. Run on macOS for now: `flutter run -d macos`
2. Later, download iOS 26.1 in Xcode if needed
3. Or test on physical iPhone for camera features

**The app is working!** Just use macOS instead of the iOS simulator for now.

# macOS Camera Fix - Documentation

## Problem
The camera feature was failing on macOS with a "camera delegate" error because:
1. `image_picker` package has limited macOS support
2. macOS doesn't support `ImageSource.camera` - only file picking
3. The app needed platform-specific handling

## Solution

### 1. Added `file_selector` Package
**File:** `pubspec.yaml`
```yaml
file_selector: ^1.0.3
```

### 2. Updated CameraFoodImport.dart
**Changes:**
- Added platform detection (`Platform.isMacOS`)
- Added `file_selector` import for macOS file picking
- Modified `_captureFromCamera()` to show error on macOS
- Modified `_selectFromGallery()` to use `file_selector` on macOS

### 3. Added macOS Permissions
**Files Updated:**
- `macos/Runner/DebugProfile.entitlements`
- `macos/Runner/Release.entitlements`
- `macos/Runner/Info.plist`

**Permissions Added:**
```xml
<!-- Entitlements -->
<key>com.apple.security.device.camera</key>
<true/>
<key>com.apple.security.assets.pictures.read-write</key>
<true/>

<!-- Info.plist -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to let you take photos of your food for calorie tracking</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to let you select food photos for calorie tracking</string>
```

## How It Works Now

### On macOS:
- **Camera button**: Shows error message explaining camera isn't available
- **Gallery button**: Opens native macOS file picker for images
- Supports: JPG, JPEG, PNG, GIF, BMP, WEBP

### On iOS/Android:
- **Camera button**: Opens native camera
- **Gallery button**: Opens photo gallery
- Full image_picker functionality

## Testing

### macOS:
```bash
flutter run -d macos
```
1. Navigate to Health → Calories
2. Tap "Take Food Photo"
3. Select "Gallery" (Camera will show error)
4. File picker opens
5. Select an image file
6. Image preview appears

### iOS (when iOS 26.1 SDK is installed):
```bash
flutter run
```
Both camera and gallery work normally.

## Files Modified

1. `pubspec.yaml` - Added file_selector dependency
2. `lib/ui_layer/health_page/CameraFoodImport.dart` - Platform-specific code
3. `macos/Runner/DebugProfile.entitlements` - Camera permissions
4. `macos/Runner/Release.entitlements` - Camera permissions
5. `macos/Runner/Info.plist` - Usage descriptions

## Next Steps

The app now works on macOS with file picking. For full camera support:
- iOS: Install iOS 26.1 SDK in Xcode
- Android: Use Android emulator or physical device
- macOS: File picking only (no camera hardware on most Macs)

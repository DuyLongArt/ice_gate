---
description: Build a release version of the Flutter application for macOS
---
1. Clean the project
   `flutter clean`

2. Get dependencies
   `flutter pub get`

3. Run code generation
   `dart run build_runner build --delete-conflicting-outputs`

4. Build for macOS
   `flutter build macos --release`

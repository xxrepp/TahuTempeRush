# How to Run TahuTempeRush

## Prerequisites

You need Flutter SDK installed. If not installed, download from: https://flutter.dev/docs/get-started/install/windows

## Quick Start

### Step 1: Add Flutter to PATH (if needed)

**Temporary (current PowerShell session only):**
```powershell
$env:Path += ";C:\flutter\bin"  # Replace with your actual Flutter path
```

**Permanent:**
1. Search "Environment Variables" in Windows Start
2. Click "Environment Variables"
3. Under "System variables", select "Path" and click "Edit"
4. Click "New" and add your Flutter bin path (e.g., `C:\flutter\bin`)
5. Click OK on all dialogs
6. **Restart your terminal**

### Step 2: Verify Flutter Installation

```powershell
flutter --version
flutter doctor
```

### Step 3: Get Dependencies

Navigate to the project directory:
```powershell
cd "d:\VSCode\TahuTempe Project"
flutter pub get
```

### Step 4: Run the App

**Option A: On Android Emulator**
1. Open Android Studio
2. Start an Android emulator (AVD Manager)
3. Run:
```powershell
flutter run
```

**Option B: On Physical Android Device**
1. Enable Developer Options on your phone
2. Enable USB Debugging
3. Connect phone via USB
4. Run:
```powershell
flutter run
```

**Option C: On iOS Simulator (Mac only)**
```powershell
open -a Simulator
flutter run
```

**Option D: On Chrome (Web - for testing UI only)**
```powershell
flutter run -d chrome
```

**Note:** Haptics, ads, and IAP won't work on web. Use Android/iOS for full features.

### Step 5: Select Device

If you have multiple devices connected:
```powershell
flutter devices                    # List all devices
flutter run -d <device-id>        # Run on specific device
```

## Common Issues

### "Flutter not recognized"
- Flutter is not in PATH. Follow Step 1 above.

### "No devices found"
- Start an emulator OR connect a physical device
- Run `flutter devices` to check

### "Package not found" errors
- Run `flutter pub get` again
- Check internet connection

### Android license issues
```powershell
flutter doctor --android-licenses
```

## Development Tips

**Hot Reload** (while app is running):
- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

**Debug Mode:**
```powershell
flutter run --debug
```

**Release Mode (better performance):**
```powershell
flutter run --release
```

**View logs:**
```powershell
flutter logs
```

## Building APK/IPA

**Android APK:**
```powershell
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (for Play Store):**
```powershell
flutter build appbundle --release
```

**iOS (Mac only):**
```powershell
flutter build ios --release
```

## Next Steps After Running

1. **Test gameplay** - Tap to shoot single, swipe up for dual
2. **Check haptics** - Feel vibrations on shoot/destroy
3. **Visit shop** - Try buying skins with Beans
4. **Test IAP** - Verify test products load
5. **Add audio files** - See README.md for asset instructions

## Need Help?

Run `flutter doctor -v` for detailed diagnostics and share the output if you encounter issues.

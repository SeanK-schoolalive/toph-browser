# Toph Browser Build Workflow

## Overview

Toph Browser is built from a locked Tor Browser source tree with Toph-specific patches applied.

## Prerequisites

- Android SDK (API 23+)
- Android NDK
- Java Development Kit (JDK 8 or 11)
- Perl with required modules (see workflow)
- Tor Browser source (auto-fetched by `make bootstrap`)

## Quick Build

```bash
# 1. Bootstrap the upstream Tor Browser source
make bootstrap

# 2. Run the complete build workflow
bash scripts/build-with-patches.sh
```

## Detailed Build Steps

### Step 1: Bootstrap Upstream Sources

```bash
make bootstrap
```

This:
- Clones the locked Tor Browser commit
- Checks out Firefox/Tor at exact revisions in VERSION.lock
- Initializes all submodules

### Step 2: Generate Icon Assets

```bash
bash scripts/generate-icon-assets.sh
```

This:
- Reads `assets/toph-icon.svg`
- Generates launcher icons at all Android densities
- Places them in the upstream Tor Browser resource directories
- Supports Inkscape, ImageMagick, or Python/cairosvg

### Step 3: Apply Toph Patches

```bash
bash scripts/apply-toph-patches.sh
```

This applies patches in order:
1. **android6/** — API 23 compatibility fixes
2. **telemetry/** — Remove telemetry and update checks
3. **tor-config/** — Tor integration and network modes
4. **browser-ui/** — Toph branding and icon

### Step 4: Build APK

```bash
bash scripts/build-android.sh
```

This:
- Validates the locked Tor Browser is checked out
- Bootstraps the Tor Browser build environment
- Compiles with the applied patches
- Packages the APK(s)

## Build Artifacts

Generated APKs are found in:
- `artifacts/` directory (copied from tor-browser-build output)
- Also searchable in `tor-browser-build/` tree

Example:
```
artifacts/
├── torbrowser-android-armv7-unsigned.apk
├── torbrowser-android-aarch64-unsigned.apk
├── torbrowser-android-x86-unsigned.apk
└── torbrowser-android-x86_64-unsigned.apk
```

## Testing on Android 6

### Using Emulator

```bash
# Create Android 6.0 emulator if not present
andy create avd -n android6 -k "system-images;android-23;default;arm64-v8a"

# Start emulator
emulator -avd android6 &

# Install APK
adb install -r artifacts/torbrowser-android-aarch64-unsigned.apk
```

### Using Real Device

1. Enable Developer Mode on Android 6 device
2. Enable USB Debugging
3. Connect device via USB
4. Install APK:
   ```bash
   adb install -r artifacts/torbrowser-android-arm*.apk
   ```

## Verification Checklist

- [ ] App installs without errors
- [ ] Toph icon appears on launcher
- [ ] App name shows "Toph Browser"
- [ ] No telemetry network requests (use packet capture)
- [ ] Tor connects in Official mode
- [ ] Can switch between Official/Custom/Disabled modes
- [ ] No clearnet DNS leaks in Tor modes
- [ ] Network mode persists across app restarts

## Troubleshooting

### Build fails with "Capture::Tiny" error

The required Perl module is missing:
```bash
sudo apt-get install libcapture-tiny-perl
```

### Icon assets not generated

Ensure SVG converter is installed:
```bash
# Option 1: Inkscape
sudo apt-get install inkscape

# Option 2: ImageMagick
sudo apt-get install imagemagick

# Option 3: Python
pip3 install cairosvg pillow
```

### APK not found after build

Search the output directory:
```bash
find tor-browser-build -name "*.apk" -type f
```

## Development Workflow

For iterative development:

1. Make changes to patches or config
2. Re-run `scripts/apply-toph-patches.sh`
3. Re-run `scripts/build-android.sh`
4. Test on device

Note: First build is slow (~1-2 hours). Subsequent builds with caching are faster.

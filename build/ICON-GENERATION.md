# Toph Icon Generation

## Overview

The Toph Browser icon is defined in `assets/toph-icon.svg` as a vector graphic. This needs to be exported to Android launcher icon assets at multiple densities.

## Required Icon Sizes

Android requires launcher icons at the following densities:

```
mdpi:    48x48 px   (1.0x)
hdpi:    72x72 px   (1.5x)
xhdpi:   96x96 px   (2.0x)
xxhdpi: 144x144 px  (3.0x)
xxxhdpi:192x192 px  (4.0x)
```

## Generation Steps

### Option 1: Using Inkscape (Recommended)

```bash
#!/usr/bin/env bash
ASSETS="assets"
ICON_SVG="$ASSETS/toph-icon.svg"
ANDROID_RES="upstream/tor-browser/mobile/android/app/src/main/res"

# Create mipmap directories if they don't exist
mkdir -p "$ANDROID_RES/mipmap-mdpi"
mkdir -p "$ANDROID_RES/mipmap-hdpi"
mkdir -p "$ANDROID_RES/mipmap-xhdpi"
mkdir -p "$ANDROID_RES/mipmap-xxhdpi"
mkdir -p "$ANDROID_RES/mipmap-xxxhdpi"

# Export at each density
inkscape --export-type=png -w 48 -h 48 "$ICON_SVG" -o "$ANDROID_RES/mipmap-mdpi/ic_toph_launcher.png"
inkscape --export-type=png -w 72 -h 72 "$ICON_SVG" -o "$ANDROID_RES/mipmap-hdpi/ic_toph_launcher.png"
inkscape --export-type=png -w 96 -h 96 "$ICON_SVG" -o "$ANDROID_RES/mipmap-xhdpi/ic_toph_launcher.png"
inkscape --export-type=png -w 144 -h 144 "$ICON_SVG" -o "$ANDROID_RES/mipmap-xxhdpi/ic_toph_launcher.png"
inkscape --export-type=png -w 192 -h 192 "$ICON_SVG" -o "$ANDROID_RES/mipmap-xxxhdpi/ic_toph_launcher.png"

# Also create rounded versions for Android 7.1+
for dir in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
    cp "$ANDROID_RES/mipmap-$dir/ic_toph_launcher.png" "$ANDROID_RES/mipmap-$dir/ic_toph_launcher_round.png"
done

echo "Icon assets generated successfully"
```

### Option 2: Using ImageMagick

```bash
#!/usr/bin/env bash
ASSETS="assets"
ICON_SVG="$ASSETS/toph-icon.svg"
ANDROID_RES="upstream/tor-browser/mobile/android/app/src/main/res"

mkdir -p "$ANDROID_RES/mipmap-mdpi"
mkdir -p "$ANDROID_RES/mipmap-hdpi"
mkdir -p "$ANDROID_RES/mipmap-xhdpi"
mkdir -p "$ANDROID_RES/mipmap-xxhdpi"
mkdir -p "$ANDROID_RES/mipmap-xxxhdpi"

# Convert SVG to PNG at each density
convert -density 96 -resize 48x48 "$ICON_SVG" "$ANDROID_RES/mipmap-mdpi/ic_toph_launcher.png"
convert -density 96 -resize 72x72 "$ICON_SVG" "$ANDROID_RES/mipmap-hdpi/ic_toph_launcher.png"
convert -density 96 -resize 96x96 "$ICON_SVG" "$ANDROID_RES/mipmap-xhdpi/ic_toph_launcher.png"
convert -density 96 -resize 144x144 "$ICON_SVG" "$ANDROID_RES/mipmap-xxhdpi/ic_toph_launcher.png"
convert -density 96 -resize 192x192 "$ICON_SVG" "$ANDROID_RES/mipmap-xxxhdpi/ic_toph_launcher.png"

for dir in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
    cp "$ANDROID_RES/mipmap-$dir/ic_toph_launcher.png" "$ANDROID_RES/mipmap-$dir/ic_toph_launcher_round.png"
done

echo "Icon assets generated successfully"
```

### Option 3: Using Python Pillow

```python
#!/usr/bin/env python3
import os
import cairosvg
from PIL import Image

ICON_SVG = "assets/toph-icon.svg"
ANDROID_RES = "upstream/tor-browser/mobile/android/app/src/main/res"

sizes = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

for density, size in sizes.items():
    mipmap_dir = os.path.join(ANDROID_RES, f"mipmap-{density}")
    os.makedirs(mipmap_dir, exist_ok=True)
    
    png_path = os.path.join(mipmap_dir, "ic_toph_launcher.png")
    
    # Convert SVG to PNG using cairosvg
    cairosvg.svg2png(url=ICON_SVG, write_to=png_path, output_width=size, output_height=size)
    
    # Copy for rounded icon
    round_path = os.path.join(mipmap_dir, "ic_toph_launcher_round.png")
    img = Image.open(png_path).convert("RGBA")
    img.save(round_path)

print("Icon assets generated successfully")
```

## Verification

After generation, verify the structure:

```
upstream/tor-browser/mobile/android/app/src/main/res/
├── mipmap-mdpi/
│   ├── ic_toph_launcher.png       (48x48)
│   └── ic_toph_launcher_round.png (48x48)
├── mipmap-hdpi/
│   ├── ic_toph_launcher.png       (72x72)
│   └── ic_toph_launcher_round.png (72x72)
├── mipmap-xhdpi/
│   ├── ic_toph_launcher.png       (96x96)
│   └── ic_toph_launcher_round.png (96x96)
├── mipmap-xxhdpi/
│   ├── ic_toph_launcher.png       (144x144)
│   └── ic_toph_launcher_round.png (144x144)
└── mipmap-xxxhdpi/
    ├── ic_toph_launcher.png       (192x192)
    └── ic_toph_launcher_round.png (192x192)
```

## Integration into Build

The build workflow should:

1. Check out the locked Tor Browser source
2. Generate icon assets at all densities
3. Apply the patches in `patches/browser-ui/`
4. Build the APK with Toph branding

This is typically done in a pre-build step before invoking the Tor Browser `mach build` command.

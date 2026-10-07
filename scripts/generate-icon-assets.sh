#!/usr/bin/env bash
#
# generate-icon-assets.sh
#
# Generate Android launcher icon assets from the Toph icon SVG at all required
# densities for mdpi, hdpi, xhdpi, xxhdpi, and xxxhdpi.
#
# Requires: inkscape, imagemagick, or python3 with cairosvg/pillow
#

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICON_SVG="$ROOT/assets/toph-icon.svg"
TB="$ROOT/upstream/tor-browser"
ANDROID_RES="$TB/mobile/android/app/src/main/res"

if [[ ! -f "$ICON_SVG" ]]; then
  echo "ERROR: Icon SVG not found at $ICON_SVG"
  exit 1
fi

if [[ ! -d "$ANDROID_RES" ]]; then
  echo "ERROR: Android resources directory not found at $ANDROID_RES"
  echo "Ensure Tor Browser source is checked out at $TB"
  exit 1
fi

echo "Generating Toph icon assets..."
echo "  Source SVG: $ICON_SVG"
echo "  Target res: $ANDROID_RES"
echo

# Check for available tools
HAS_INKSCAPE=false
HAS_IMAGEMAGICK=false
HAS_PYTHON=false

command -v inkscape >/dev/null 2>&1 && HAS_INKSCAPE=true
command -v convert >/dev/null 2>&1 && HAS_IMAGEMAGICK=true
command -v python3 >/dev/null 2>&1 && HAS_PYTHON=true

if [[ "$HAS_INKSCAPE" == "true" ]]; then
  echo "Using Inkscape for SVG export..."
  
  mkdir -p "$ANDROID_RES/mipmap-mdpi"
  mkdir -p "$ANDROID_RES/mipmap-hdpi"
  mkdir -p "$ANDROID_RES/mipmap-xhdpi"
  mkdir -p "$ANDROID_RES/mipmap-xxhdpi"
  mkdir -p "$ANDROID_RES/mipmap-xxxhdpi"
  
  inkscape --export-type=png -w 48 -h 48 "$ICON_SVG" -o "$ANDROID_RES/mipmap-mdpi/ic_toph_launcher.png"
  inkscape --export-type=png -w 72 -h 72 "$ICON_SVG" -o "$ANDROID_RES/mipmap-hdpi/ic_toph_launcher.png"
  inkscape --export-type=png -w 96 -h 96 "$ICON_SVG" -o "$ANDROID_RES/mipmap-xhdpi/ic_toph_launcher.png"
  inkscape --export-type=png -w 144 -h 144 "$ICON_SVG" -o "$ANDROID_RES/mipmap-xxhdpi/ic_toph_launcher.png"
  inkscape --export-type=png -w 192 -h 192 "$ICON_SVG" -o "$ANDROID_RES/mipmap-xxxhdpi/ic_toph_launcher.png"
  
  for dir in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
    cp "$ANDROID_RES/mipmap-$dir/ic_toph_launcher.png" "$ANDROID_RES/mipmap-$dir/ic_toph_launcher_round.png"
  done
  
  echo "✓ Icon assets generated with Inkscape"
  
elif [[ "$HAS_IMAGEMAGICK" == "true" ]]; then
  echo "Using ImageMagick for SVG conversion..."
  
  mkdir -p "$ANDROID_RES/mipmap-mdpi"
  mkdir -p "$ANDROID_RES/mipmap-hdpi"
  mkdir -p "$ANDROID_RES/mipmap-xhdpi"
  mkdir -p "$ANDROID_RES/mipmap-xxhdpi"
  mkdir -p "$ANDROID_RES/mipmap-xxxhdpi"
  
  convert -density 96 -resize 48x48 "$ICON_SVG" "$ANDROID_RES/mipmap-mdpi/ic_toph_launcher.png"
  convert -density 96 -resize 72x72 "$ICON_SVG" "$ANDROID_RES/mipmap-hdpi/ic_toph_launcher.png"
  convert -density 96 -resize 96x96 "$ICON_SVG" "$ANDROID_RES/mipmap-xhdpi/ic_toph_launcher.png"
  convert -density 96 -resize 144x144 "$ICON_SVG" "$ANDROID_RES/mipmap-xxhdpi/ic_toph_launcher.png"
  convert -density 96 -resize 192x192 "$ICON_SVG" "$ANDROID_RES/mipmap-xxxhdpi/ic_toph_launcher.png"
  
  for dir in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
    cp "$ANDROID_RES/mipmap-$dir/ic_toph_launcher.png" "$ANDROID_RES/mipmap-$dir/ic_toph_launcher_round.png"
  done
  
  echo "✓ Icon assets generated with ImageMagick"
  
elif [[ "$HAS_PYTHON" == "true" ]]; then
  echo "Using Python with cairosvg for SVG conversion..."
  
  python3 << 'PYTHON_EOF'
import os
import sys
try:
    import cairosvg
except ImportError:
    print("ERROR: cairosvg not installed. Install with: pip3 install cairosvg")
    sys.exit(1)

icon_svg = os.environ.get("ICON_SVG")
android_res = os.environ.get("ANDROID_RES")

sizes = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

for density, size in sizes.items():
    mipmap_dir = os.path.join(android_res, f"mipmap-{density}")
    os.makedirs(mipmap_dir, exist_ok=True)
    
    png_path = os.path.join(mipmap_dir, "ic_toph_launcher.png")
    round_path = os.path.join(mipmap_dir, "ic_toph_launcher_round.png")
    
    cairosvg.svg2png(url=icon_svg, write_to=png_path, output_width=size, output_height=size)
    # For now, round icon is same as regular (Android will handle rounding for 7.1+)
    import shutil
    shutil.copy(png_path, round_path)
    
    print(f"  Generated {density}: {size}x{size}")

print("✓ Icon assets generated with cairosvg")
PYTHON_EOF
  
else
  echo "ERROR: No suitable SVG conversion tool found."
  echo "Install one of: inkscape, imagemagick (convert), or python3 with cairosvg"
  exit 1
fi

echo
echo "Verification:"
for dir in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  if [[ -f "$ANDROID_RES/mipmap-$dir/ic_toph_launcher.png" ]]; then
    size=$(identify -format "%wx%h" "$ANDROID_RES/mipmap-$dir/ic_toph_launcher.png" 2>/dev/null || echo "unknown")
    echo "  ✓ mipmap-$dir: $size"
  else
    echo "  ✗ mipmap-$dir: MISSING"
  fi
done

echo
echo "Done. Toph icon assets are ready for the Android build."

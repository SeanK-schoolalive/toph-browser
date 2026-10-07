#!/usr/bin/env bash
#
# apply-toph-patches.sh
#
# Apply all Toph Browser patches to the locked upstream Tor Browser source tree.
# This includes branding, icon, Tor configuration, telemetry removal, and Android 6 fixes.
#

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TB="$ROOT/upstream/tor-browser"
PATCHES="$ROOT/patches"

if [[ ! -d "$TB/.git" ]]; then
  echo "ERROR: Tor Browser source not found at $TB"
  echo "Run: make bootstrap"
  exit 1
fi

echo "Applying Toph patches to upstream Tor Browser..."
echo

# Define patch order (important: dependencies between patches)
declare -a PATCH_DIRS=(
  "android6"
  "telemetry"
  "tor-config"
  "browser-ui"
)

for patch_dir in "${PATCH_DIRS[@]}"; do
  patch_path="$PATCHES/$patch_dir"
  
  if [[ ! -d "$patch_path" ]]; then
    echo "⚠ Patch directory not found: $patch_path"
    continue
  fi
  
  echo "Applying patches from: $patch_dir/"
  
  # Apply all .patch files in the directory in alphabetical order
  for patch_file in "$patch_path"/*.patch; do
    if [[ ! -f "$patch_file" ]]; then
      continue
    fi
    
    patch_name=$(basename "$patch_file")
    echo "  → $patch_name"
    
    if git -C "$TB" apply --check "$patch_file" >/dev/null 2>&1; then
      git -C "$TB" apply "$patch_file"
      echo "    ✓ Applied"
    else
      echo "    ✗ Failed to apply (may already be applied or conflict)"
      # Don't exit on failure; some patches may be idempotent
    fi
  done
  
  echo
done

echo "Patch application complete."
echo
echo "Next steps:"
echo "  1. Generate icon assets:  scripts/generate-icon-assets.sh"
echo "  2. Build the browser:     scripts/build-android.sh"

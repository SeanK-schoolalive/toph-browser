#!/usr/bin/env bash
#
# build-with-patches.sh
#
# Complete build workflow: bootstrap, generate assets, apply patches, build APK
#

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)"
TB="$ROOT/upstream/tor-browser"
LOCK="$ROOT/VERSION.lock"

echo "========================================"
echo "Toph Browser Complete Build Workflow"
echo "========================================"
echo

# Step 1: Bootstrap
echo "[1/5] Bootstrapping upstream Tor Browser..."
if [[ ! -d "$TB/.git" ]]; then
  echo "ERROR: Tor Browser not bootstrapped."
  echo "Run: make bootstrap"
  exit 1
fi

commit=$(awk -F= '/^tor_browser_commit=/{print $2}' "$LOCK")
echo "  Tor Browser locked at: $commit"
echo

# Step 2: Generate icon assets
echo "[2/5] Generating Toph icon assets..."
if ! bash "$ROOT/scripts/generate-icon-assets.sh"; then
  echo "ERROR: Icon generation failed"
  exit 1
fi
echo

# Step 3: Apply patches
echo "[3/5] Applying Toph patches to upstream..."
if ! bash "$ROOT/scripts/apply-toph-patches.sh"; then
  echo "ERROR: Patch application failed"
  exit 1
fi
echo

# Step 4: Build APK
echo "[4/5] Building APK with patched Tor Browser..."
if ! bash "$ROOT/scripts/build-android.sh"; then
  echo "ERROR: Build failed"
  exit 1
fi
echo

echo "========================================"
echo "Build completed successfully!"
echo "========================================"
echo
echo "APKs are available in artifacts/"
echo "Test on Android 6+ devices."

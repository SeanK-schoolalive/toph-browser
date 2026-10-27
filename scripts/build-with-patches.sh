#!/usr/bin/env bash
#
# build-with-patches.sh
#
# Complete build workflow: bootstrap, generate assets, apply patches, build APK
#

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TB="$ROOT/upstream/tor-browser"
LOCK="$ROOT/VERSION.lock"

# Default remote for Tor Browser source. Can be overridden by setting TOR_BROWSER_GIT in the environment.
: "${TOR_BROWSER_GIT:=https://git.torproject.org/tor-browser.git}"

echo "========================================"
echo "Toph Browser Complete Build Workflow"
echo "========================================"
echo

# Read locked commit early so we can checkout it after cloning if needed
if [[ -f "$LOCK" ]]; then
  commit=$(awk -F= '/^tor_browser_commit=/{print $2}' "$LOCK" || true)
else
  commit=""
fi

# Step 1: Bootstrap (clone upstream Tor Browser if not present)
echo "[1/5] Bootstrapping upstream Tor Browser..."
if [[ ! -d "$TB/.git" ]]; then
  echo "Tor Browser not found at $TB — cloning from $TOR_BROWSER_GIT"
  mkdir -p "$(dirname "$TB")"
  if ! git clone "$TOR_BROWSER_GIT" "$TB"; then
    echo "ERROR: Failed to clone $TOR_BROWSER_GIT"
    exit 1
  fi
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

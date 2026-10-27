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
: "${TOR_BROWSER_GIT:=https://gitlab.torproject.org/tpo/applications/tor-browser.git}"

echo "========================================"
echo "Toph Browser Complete Build Workflow"
echo "========================================"
echo

# Read locked commit early so we can checkout it after cloning if needed.
if [[ -f "$LOCK" ]]; then
  commit=$(awk -F= '/^tor_browser_commit=/{print $2}' "$LOCK" || true)
else
  commit=""
fi

checkout_valid_tor_browser_ref() {
  local repo_dir="$1"
  local pinned_commit="${2:-}"
  local ref

  # Prefer the exact locked SHA when it exists.
  if [[ -n "$pinned_commit" ]] && git -C "$repo_dir" rev-parse --verify "${pinned_commit}^{commit}" >/dev/null 2>&1; then
    echo "Checking out locked Tor Browser commit: $pinned_commit"
    git -C "$repo_dir" checkout --detach "$pinned_commit"
    return 0
  fi

  # If the lock is stale or missing, try release refs instead of generic HEAD.
  local -a refs=(
    "tor-browser_140.17.0esr-15.0-24"
    "tor-browser_140.17.0esr-15.0"
    "tor-browser-15.0.24"
    "15.0.24"
    "release-15.0"
    "release-15.0.24"
  )

  for ref in "${refs[@]}"; do
    if git -C "$repo_dir" rev-parse --verify "${ref}^{commit}" >/dev/null 2>&1; then
      echo "Checking out Tor Browser release ref: $ref"
      git -C "$repo_dir" checkout --detach "$ref"
      return 0
    fi
  done

  echo "ERROR: No valid Android-compatible Tor Browser release ref was found for this repo."
  echo "The upstream checkout does not contain the expected Android source tree."
  return 1
}

# Step 1: Bootstrap (clone upstream Tor Browser if not present)
echo "[1/5] Bootstrapping upstream Tor Browser..."
if [[ ! -d "$TB/.git" ]]; then
  echo "Tor Browser not found at $TB — cloning from $TOR_BROWSER_GIT"
  mkdir -p "$(dirname "$TB")"
  if ! git clone "$TOR_BROWSER_GIT" "$TB"; then
    echo "ERROR: Failed to clone $TOR_BROWSER_GIT"
    exit 1
  fi
fi

if ! checkout_valid_tor_browser_ref "$TB" "$commit"; then
  exit 1
fi

if [[ ! -d "$TB/mobile/android/app/src/main/res" ]]; then
  echo "ERROR: Android resources directory not found at $TB/mobile/android/app/src/main/res"
  echo "Ensure Tor Browser source is checked out at $TB"
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

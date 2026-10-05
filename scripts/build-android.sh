#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TB="$ROOT/upstream/tor-browser"
LOCK="$ROOT/VERSION.lock"

if [[ ! -d "$TB/.git" ]]; then
  echo "ERROR: Tor Browser source is missing."
  echo "Run: make bootstrap"
  exit 1
fi

expected="$(awk -F= '/^tor_browser_commit=/{print $2}' "$LOCK")"
actual="$(git -C "$TB" rev-parse HEAD)"
if [[ "$actual" != "$expected" ]]; then
  echo "ERROR: upstream/tor-browser is not at the locked revision."
  echo "  expected: $expected"
  echo "  actual:   $actual"
  echo "Run: make bootstrap"
  exit 1
fi

if [[ ! -x "$TB/mach" ]]; then
  echo "ERROR: upstream/tor-browser/mach was not found."
  echo "The locked Tor Browser checkout must provide the Firefox/Android build tooling."
  exit 1
fi

if [[ -z "${ANDROID_HOME:-}" && -z "${ANDROID_SDK_ROOT:-}" ]]; then
  echo "ERROR: ANDROID_HOME or ANDROID_SDK_ROOT is not set."
  echo "Set the Android SDK path before building."
  exit 1
fi

if [[ -z "${JAVA_HOME:-}" ]]; then
  echo "WARNING: JAVA_HOME is not set. The upstream build may select its own JDK."
fi

echo "Toph Browser upstream Android build"
echo "  Tor Browser commit: $actual"
echo "  Android minimum/target baseline: API 23"
echo
echo "This first build intentionally makes no Toph source modifications."
echo "It verifies that the locked upstream baseline can build before branding/privacy patches are applied."
echo

cd "$TB"

if [[ -n "${MOZCONFIG:-}" ]]; then
  echo "Using MOZCONFIG=$MOZCONFIG"
fi

./mach --no-interactive bootstrap --application-choice="GeckoView/Firefox for Android"
./mach build
./mach package

echo
echo "Build completed. Search the object directory for generated Android APKs:"
find "$TB" -type f -path "*/dist/*.apk" -o -type f -path "*/outputs/apk/**/*.apk" 2>/dev/null | sort || true

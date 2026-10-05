#!/usr/bin/env bash
set -euo pipefail
command -v adb >/dev/null 2>&1 || { echo "adb is not installed or not on PATH."; exit 1; }
echo "Android SDK:"
adb shell getprop ro.build.version.sdk
echo "Primary ABI:"
adb shell getprop ro.product.cpu.abi
echo "ABI list:"
adb shell getprop ro.product.cpu.abilist

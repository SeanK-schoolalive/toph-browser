# Android 6 build plan

## Baseline

Toph currently targets the Tor Browser 15.0.24 source baseline:

- Firefox ESR: 140.17.0
- Tor: 0.4.9.13
- Android baseline: API 23 target device

Tor Browser 15.0.24 was released September 29, 2026. Its Android release updates GeckoView to Firefox ESR 140.17.0.

## Important

Do the first build with **no Toph patches**. This separates upstream build problems from Toph changes.

## Host preparation

Use a Linux build host with the toolchain required by the checked-out Tor Browser source. The exact dependency list should come from the upstream build documentation for the locked revision rather than being guessed from a current Firefox release.

Install Git, Git LFS, Python 3, a C/C++ build toolchain, archive tools, and the JDK/toolchain versions required by the upstream revision.

## Steps

1. Run `scripts/bootstrap-upstream.sh`.
2. Verify the revisions with `scripts/record-versions.sh`.
3. Read the build instructions in `upstream/tor-browser` for the locked revision.
4. Reproduce the upstream Android build first.
5. Install the resulting APK on an API-23 emulator/device.
6. Record the result in `tests/android6-compatibility.md`.
7. Only after a clean upstream baseline, apply Toph patches.

## Device check

Use `scripts/check-android-api.sh` with ADB to record API level and ABI before choosing an APK architecture.

## Reproducibility

Do not replace locked revisions with branch tips. If an upstream security release changes the baseline, update `VERSION.lock`, record why, and rerun the compatibility tests.

# Verified Android 6 baseline

Selected baseline: **Tor Browser 15.0.24**, released September 29, 2026.

Why this baseline:
- Tor Browser 15.0 is based on Firefox ESR 140.
- Tor Browser 15.0.24 updates Android GeckoView to Firefox ESR 140.17.0.
- Tor Browser 15.x is the final major Tor Browser series supporting Android 5, 6, and 7.
- Tor Browser 16 drops Android versions older than 8.0.

## Locked revisions

| Component | Version | Revision |
|---|---|---|
| Tor Browser | 15.0.24 | 8cae94965791def3a7e63a1acb9e998ce8133de9 |
| Base Browser | Firefox ESR 140.17.0 | c62d7c244409d6d6ca37cd7f4819260ffc3cf60b |
| Fenix/Tor Browser Android source | release build dependency | 61d9e9dc2c94ca0e071ce3be0b018c5a5958101f |
| Tor | 0.4.9.13 | tor-0.4.9.13 |

## Important distinction

The Tor Browser repository is a Firefox-derived source tree. The Base Browser and Tor Browser revisions above are therefore the authoritative source revisions for this baseline.

We do not invent a Mozilla-central SHA for Firefox 140.17.0esr. If a direct Mozilla revision is needed later, it must be resolved from Mozilla's own release/source metadata and recorded separately.

## Android 6 target

Toph's target is Android 6 / API 23.

The upstream Tor Browser 15.0.24 Android artifacts include ARMv7, ARM64, x86, and x86_64 builds. Toph still needs its own build and runtime validation on API 23.

## Next validation steps

1. Fetch the exact upstream repositories.
2. Check out the locked Tor Browser/Base Browser revisions.
3. Reproduce the upstream Android build environment.
4. Build without Toph patches first.
5. Test installation/startup/page loading on API 23.
6. Only after that, add Toph privacy and network-mode patches.

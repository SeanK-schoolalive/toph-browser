# Mozilla Firefox source

Toph Browser uses Firefox technology through the Tor Browser/Base Browser source
baseline. The complete Mozilla Firefox source tree is intentionally not vendored
into this repository.

Official source repository:

https://github.com/mozilla-firefox/firefox

To fetch a local checkout, run:

    scripts/fetch-firefox-source.sh

The script defaults to the repository's current `main` revision. Set
`FIREFOX_REV` to a specific branch, tag, or commit when you need a reproducible
checkout.

Important: the Android 6 build baseline remains the Tor Browser/Base Browser
revision recorded in `VERSION.lock`; this standalone Firefox checkout is a
reference/development source tree and does not replace that locked baseline.

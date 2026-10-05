# Upstream baseline test

Before Toph modifications, verify:

- exact Tor Browser revision matches `VERSION.lock`
- exact Tor revision matches `VERSION.lock`
- Android API 23 installation succeeds
- browser starts
- a normal HTTPS page loads
- JavaScript executes normally
- Tor connectivity works in the upstream build
- no unexpected crash occurs during basic browsing

This test establishes the control build for later Toph privacy and network changes.

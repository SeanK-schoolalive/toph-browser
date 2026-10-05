#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$ROOT/upstream/firefox"
URL="https://github.com/mozilla-firefox/firefox.git"
REV="${FIREFOX_REV:-main}"

if [[ -d "$DIR/.git" ]]; then
  git -C "$DIR" fetch origin --prune
else
  git clone "$URL" "$DIR"
fi

git -C "$DIR" fetch origin "$REV"
git -C "$DIR" checkout --detach "$REV"

echo "Firefox source: $(git -C "$DIR" rev-parse HEAD)"
echo "Source: $URL"
echo "Checkout: $REV"
echo
echo "Note: Toph's locked Android build baseline is the Tor Browser/Base Browser"
echo "source revision in VERSION.lock. This checkout is the official Mozilla Firefox"
echo "source tree for inspection/development and is not substituted for that baseline."

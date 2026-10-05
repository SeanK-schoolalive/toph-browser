#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$ROOT/upstream"

clone_or_fetch() {
  local name="$1" url="$2" rev="$3"
  local dir="$ROOT/upstream/$name"
  if [[ -d "$dir/.git" ]]; then
    git -C "$dir" fetch --tags --prune
  else
    git clone "$url" "$dir"
  fi
  git -C "$dir" fetch --tags --force
  git -C "$dir" checkout --detach "$rev"
  echo "$name: $(git -C "$dir" rev-parse HEAD)"
}

clone_or_fetch tor-browser https://gitlab.torproject.org/tpo/applications/tor-browser.git 8cae94965791def3a7e63a1acb9e998ce8133de9
clone_or_fetch tor https://gitlab.torproject.org/tpo/core/tor.git tor-0.4.9.13

echo
printf '%s\n' "Upstream Tor Browser and Tor revisions are locked." "Run scripts/record-versions.sh to audit the checkouts."

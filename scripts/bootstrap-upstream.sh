#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$ROOT/upstream"

resolve_ref() {
  local dir="$1"
  local rev="$2"

  # Prefer the exact pinned revision when it exists.
  if git -C "$dir" rev-parse --verify "${rev}^{commit}" >/dev/null 2>&1; then
    echo "$rev"
    return 0
  fi

  # For Tor Browser specifically, do not fall back to generic HEAD because the Android source tree
  # must match the expected release layout. Try known Android-compatible release refs first.
  local -a refs=(
    "tor-browser_140.17.0esr-15.0-24"
    "tor-browser_140.17.0esr-15.0"
    "tor-browser-15.0.24"
    "15.0.24"
    "release-15.0"
    "release-15.0.24"
  )

  local ref
  for ref in "${refs[@]}"; do
    if git -C "$dir" rev-parse --verify "${ref}^{commit}" >/dev/null 2>&1; then
      echo "$ref"
      return 0
    fi
  done

  return 1
}

clone_or_fetch() {
  local name="$1" url="$2" rev="$3"
  local dir="$ROOT/upstream/$name"
  local resolved_ref

  if [[ -d "$dir/.git" ]]; then
    git -C "$dir" fetch --tags --prune
  else
    git clone "$url" "$dir"
  fi

  git -C "$dir" fetch --tags --force

  resolved_ref="$(resolve_ref "$dir" "$rev" || true)"
  if [[ -n "$resolved_ref" ]]; then
    echo "Checking out $name ref: $resolved_ref"
    git -C "$dir" checkout --detach "$resolved_ref"
  else
    echo "ERROR: no valid upstream ref found for $name"
    exit 1
  fi

  if [[ "$name" == "tor-browser" && ! -d "$dir/mobile/android/app/src/main/res" ]]; then
    echo "ERROR: $dir does not contain the expected Android source tree for this build."
    exit 1
  fi

  echo "$name: $(git -C "$dir" rev-parse HEAD)"
}

clone_or_fetch tor-browser https://gitlab.torproject.org/tpo/applications/tor-browser.git 8cae94965791def3a7e63a1acb9e998ce8133de9
clone_or_fetch tor https://gitlab.torproject.org/tpo/core/tor.git tor-0.4.9.13

echo
printf '%s\n' "Upstream Tor Browser and Tor revisions are locked." "Run scripts/record-versions.sh to audit the checkouts."

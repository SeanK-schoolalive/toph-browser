#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$BASH_SOURCE")/.." && pwd)"
LOCK="$ROOT/VERSION.lock"

expected_tb="$(awk -F= '/^tor_browser_commit=/{print $2}' "$LOCK")"
expected_tor="$(awk -F= '/^tag=/{print $2}' "$LOCK" | head -n1)"

fail=0

check_repo() {
  local name="$1" expected="$2" dir="$ROOT/upstream/$1"
  if [[ ! -d "$dir/.git" ]]; then
    echo "MISSING: $name is not cloned at $dir"
    fail=1
    return
  fi

  local actual
  actual="$(git -C "$dir" rev-parse HEAD)"
  if [[ "$actual" != "$expected" ]]; then
    echo "MISMATCH: $name"
    echo "  expected: $expected"
    echo "  actual:   $actual"
    fail=1
  else
    echo "OK: $name $actual"
  fi
}

check_repo tor-browser "$expected_tb"

if [[ ! -d "$ROOT/upstream/tor/.git" ]]; then
  echo "MISSING: tor is not cloned at $ROOT/upstream/tor"
  fail=1
else
  tag_sha="$(git -C "$ROOT/upstream/tor" rev-list -n1 "refs/tags/$expected_tor" 2>/dev/null || true)"
  actual="$(git -C "$ROOT/upstream/tor" rev-parse HEAD)"
  if [[ -n "$tag_sha" && "$actual" == "$tag_sha" ]]; then
    echo "OK: tor $expected_tor ($actual)"
  else
    echo "MISMATCH: tor"
    echo "  expected tag: $expected_tor"
    echo "  actual:       $actual"
    fail=1
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo
  echo "Revision verification failed."
  echo "Run: make bootstrap"
  exit 1
fi

echo "All locked upstream revisions verified."

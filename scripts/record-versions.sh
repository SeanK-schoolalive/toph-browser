#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for name in firefox tor tor-browser; do
  dir="$ROOT/upstream/$name"
  if [[ -d "$dir/.git" ]]; then
    echo "[$name]"
    git -C "$dir" describe --tags --always --dirty || true
    git -C "$dir" rev-parse HEAD
    echo
  else
    echo "[$name] not cloned: $dir"
  fi
done

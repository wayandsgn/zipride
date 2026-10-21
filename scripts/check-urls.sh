#!/usr/bin/env bash
# Fails if any Unsplash image referenced in the app does not answer HTTP 200.
set -euo pipefail
cd "$(dirname "$0")/.."
ids=$(grep -rhoE 'photo-[0-9]+-[0-9a-f]+' Zipride | sort -u)
fail=0
for id in $ids; do
  url="https://images.unsplash.com/${id}?w=800&q=80&fit=crop"
  code=$(curl -s -o /dev/null -w '%{http_code}' -L "$url")
  echo "$code $url"
  [ "$code" = "200" ] || fail=1
done
exit $fail

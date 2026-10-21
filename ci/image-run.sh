#!/usr/bin/env bash
# A run of L5 that leaves its results where the record writer reads them, whatever it decided: the lines of
# ci/image.sh and the instants the run began and ended.
set -uo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$root/.results"
date -u +%Y-%m-%dT%H:%M:%SZ > "$root/.results/started"
bash "$root/ci/image.sh" "$@" | tee "$root/.results/image.txt"
status="${PIPESTATUS[0]}"
date -u +%Y-%m-%dT%H:%M:%SZ > "$root/.results/finished"
exit "$status"

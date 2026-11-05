#!/usr/bin/env bash
# Assembles the record of a run from what that run left behind, and writes it to standard output.
# It runs nothing: a record is evidence of a run that already happened.
#
# The tool is the one `develop` put on PATH, and the record names it by the build information the
# binary carries: the version it states, and nothing learnt from where it was installed.
# Usage: record.sh [level] [board] [results directory] — the level is L1 unless named. L1's results are the
# checks' lines; L5's are the image build's, which ci/image-run.sh leaves, of the emulated machines; L5 board's
# are the board pass's, which the board workflow leaves with the form it booted (653).
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
level=L1 tier=reference
if [[ "${1:-}" =~ ^L[0-9]$ ]]; then level="$1"; shift; fi
if [[ "$level" == L5 && "${1:-}" == board ]]; then tier=board; shift; fi
results="${1:-$root/.results}"
lines=checks.txt
environment=()
if [[ "$level" == L5 && "$tier" == board ]]; then
  lines=board.txt
  [[ -f "$results/form" ]] || { echo "record: the board pass left no form in $results" >&2; exit 1; }
  form="$(tr -d '[:space:]' < "$results/form")"
  case "$form" in
    yoke) environment+=(--environment "deployment form=application") ;;
    yoke-service) environment+=(--environment "deployment form=service") ;;
    *) echo "record: the board pass booted no form this repository knows: $form" >&2; exit 1 ;;
  esac
  environment+=(--environment machine=raspberrypi5)
elif [[ "$level" == L5 ]]; then
  lines=image.txt
  environment+=(--environment machine=qemu)
fi

for each in "$lines" started finished; do
  [[ -f "$results/$each" ]] || { echo "record: the run left no $each in $results" >&2; exit 1; }
done

# The architecture as the environment's dimension names it.
case "$(uname -m)" in
  x86_64) architecture=amd64 ;;
  aarch64 | arm64) architecture=arm64 ;;
  *) architecture="$(uname -m)" ;;
esac

# The board pass's architecture is the board's, not the runner's.
[[ "$tier" == board ]] && architecture=arm64

tool="$(command -v yoke-verify)" || { echo "record: yoke-verify is not on PATH; \`just develop\` puts it there" >&2; exit 1; }
version="$(grep -aoE $'mod\tgithub\\.com/yoke-project/yoke\t[^\t]+' "$tool" | head -n 1 | cut -f3)"
revision="$(grep -aoE 'vcs\.revision=[0-9a-f]{40}' "$tool" | head -n 1 | cut -d= -f2)"

yoke-verify record \
  --level "$level" \
  --tier "$tier" \
  --repository meta-yoke \
  --environment "architecture=$architecture" \
  "${environment[@]}" \
  --started "$(tr -d '[:space:]' < "$results/started")" \
  --finished "$(tr -d '[:space:]' < "$results/finished")" \
  --ran "yoke-verify=${version:-unknown}@${revision:0:12}" \
  --results "$results/$lines" \
  "$root"

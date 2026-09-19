#!/usr/bin/env bash
# The checks described by verbs-and-licence.std.md, one function per case.
# Each function prints why it failed and returns non-zero; checks/run.sh reports them.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
verbs=(build test lint fmt develop release)

# std: meta-yoke:verbs-and-licence.01
check_verbs_defined() {
  [[ -f "$root/justfile" ]] || { echo "no justfile"; return 1; }
  local summary
  summary=" $(cd "$root" && just --summary) "
  for verb in "${verbs[@]}"; do
    [[ "$summary" == *" $verb "* ]] || { echo "verb '$verb' is not defined"; return 1; }
    local body
    body="$(cd "$root" && just --show "$verb" | grep -E '^[[:space:]]+[^[:space:]]')"
    [[ -n "$body" ]] || { echo "verb '$verb' has an empty body"; return 1; }
  done
}

# std: meta-yoke:verbs-and-licence.02
check_no_path_outside() {
  [[ -f "$root/justfile" ]] || { echo "no justfile"; return 1; }
  local hits
  hits="$(cd "$root" && grep -nE '(^|[^.])\.\./' justfile go.mod go.work Cargo.toml pyproject.toml CMakeLists.txt package.json 2>/dev/null)"
  [[ -z "$hits" ]] || { echo "a path outside the repository: $hits"; return 1; }
}

# std: meta-yoke:verbs-and-licence.03
check_container_build() {
  [[ -f "$root/Containerfile" ]] || { echo "no Containerfile"; return 1; }
  local engine
  engine="$(command -v podman || command -v docker)" || { echo "no container engine"; return 1; }
  "$engine" build -q -t meta-yoke-check-build -f "$root/Containerfile" "$root" >/dev/null \
    || { echo "the image did not build"; return 1; }
  "$engine" run --rm meta-yoke-check-build just build >/dev/null \
    || { echo "build failed inside the container"; return 1; }
}

# std: meta-yoke:verbs-and-licence.04
check_licence() {
  [[ -f "$root/LICENSE" ]] || { echo "no LICENSE"; return 1; }
  grep -q '^MIT License' "$root/LICENSE" && grep -q 'Permission is hereby granted, free of charge' "$root/LICENSE" \
    || { echo "LICENSE is not MIT"; return 1; }
  grep -q 'Davide Cardillo' "$root/LICENSE" || { echo "LICENSE does not name the copyright holder"; return 1; }
  local others
  others="$(cd "$root" && ls -d LICENSE.* LICENCE* COPYING* NOTICE 2>/dev/null)"
  [[ -z "$others" ]] || { echo "a second licence file: $others"; return 1; }
}

# std: meta-yoke:verbs-and-licence.05
check_develop_floor() {
  [[ -f "$root/justfile" ]] || { echo "no justfile"; return 1; }
  local out
  if out="$(cd "$root" && just develop 999.0.0 2>&1)"; then
    echo "develop passed with a floor above the installed just"; return 1
  fi
  [[ "$out" == *999.0.0* ]] || { echo "develop did not name the floor it was given"; return 1; }
  [[ "$out" == *"$(just --version | awk '{print $2}')"* ]] || { echo "develop did not name the version it found"; return 1; }
}

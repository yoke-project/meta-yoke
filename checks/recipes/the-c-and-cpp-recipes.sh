#!/usr/bin/env bash
# The checks described by the-c-and-cpp-recipes.std.md that read the recipes; the cases that build them are ci/image.sh's.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# std: meta-yoke:the-c-and-cpp-recipes.01
check_each_recipe_pins_the_release_its_family_published() {
  local family recipe sources libraries
  for family in "yoke-sdk-c grpc protobuf-c" "yoke-sdk-cpp grpc protobuf"; do
    read -r family libraries <<<"$family"
    recipe="$(compgen -G "$root/recipes-*/$family/${family}_*.bb" | head -1)"
    [[ -n "$recipe" ]] || { echo "no recipe for $family"; return 1; }
    sources="$(awk '/^SRC_URI = /,/[^\\]$/' "$recipe" | grep -oE '[a-z]+://[^ ";]+')"
    expected="https://github.com/yoke-project/$family/releases/download/v\${PV}/$family-\${PV}-source.tar.gz"
    # Generated C++ compiles only against the protobuf that generated it, so C++ generates its definitions
    # again, from the module its record pins.
    [[ "$family" == yoke-sdk-cpp ]] \
      && expected+=$'\n'"https://proxy.golang.org/github.com/yoke-project/yoke/proto/@v/\${DEFINITIONS_VERSION}.zip"
    [[ "$sources" == "$expected" ]] || { echo "$family fetches [$(tr '\n' ' ' <<<"$sources")]"; return 1; }
    grep -qE '^SRC_URI\[sha256sum\] = "[0-9a-f]{64}"$' "$recipe" || { echo "the $family archive is not pinned by its sha256"; return 1; }
    if [[ "$family" == yoke-sdk-cpp ]]; then
      grep -qE '^SRC_URI\[definitions\.sha256sum\] = "[0-9a-f]{64}"$' "$recipe" \
        || { echo "the definitions module $family generates from is not pinned by its sha256"; return 1; }
      libraries+=" protobuf-native grpc-native"
    fi
    for each in $libraries; do
      grep -E '^DEPENDS = ' "$recipe" | grep -qwF "$each" || { echo "$family does not take $each from the layers"; return 1; }
    done
  done
}

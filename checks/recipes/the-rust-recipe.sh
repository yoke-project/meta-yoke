#!/usr/bin/env bash
# The checks described by the-rust-recipe.std.md that read the recipe; the case that builds it is ci/image.sh's.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# std: meta-yoke:the-rust-recipe.01
check_the_rust_recipe_pins_the_crate_and_its_dependencies() {
  local recipe dir sources source name version
  recipe="$(compgen -G "$root/recipes-*/yoke-sdk-rust/yoke-sdk-rust_*.bb" | head -1)"
  [[ -n "$recipe" ]] || { echo "no recipe for yoke-sdk-rust"; return 1; }
  dir="$(dirname "$recipe")"
  [[ -f "$dir/yoke-sdk-rust-crates.inc" ]] || { echo "no crate list beside the recipe"; return 1; }
  grep -qE '^require \$\{BPN\}-crates\.inc$' "$recipe" || { echo "the recipe does not require its crate list"; return 1; }
  grep -qE '^inherit .*\bcargo\b' "$recipe" || { echo "the recipe does not build with Cargo's class"; return 1; }
  sources="$(awk '/^SRC_URI = /,/[^\\]$/' "$recipe" | grep -oE '[a-z]+://[^ ";]+')"
  [[ "$sources" == 'crate://crates.io/yoke-sdk/${PV}' ]] || { echo "yoke-sdk-rust fetches [$(tr '\n' ' ' <<<"$sources")]"; return 1; }
  grep -qE '^SRC_URI\[yoke-sdk\.sha256sum\] = "[0-9a-f]{64}"$' "$recipe" || { echo "the crate is not pinned by its sha256"; return 1; }
  sources="$(grep -oE '[a-z]+://[^ ";\\]+' "$dir/yoke-sdk-rust-crates.inc")"
  [[ -n "$sources" ]] || { echo "the crate list names no crate"; return 1; }
  for source in $sources; do
    [[ "$source" =~ ^crate://crates\.io/([^/]+)/([^/]+)$ ]] || { echo "the crate list fetches $source"; return 1; }
    name="${BASH_REMATCH[1]}" version="${BASH_REMATCH[2]}"
    grep -F "SRC_URI[$name-$version.sha256sum] = " "$dir/yoke-sdk-rust-crates.inc" | grep -qE '^[^ ]+ = "[0-9a-f]{64}"$' \
      || { echo "$name $version is not pinned by its sha256"; return 1; }
  done
}

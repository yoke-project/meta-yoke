#!/usr/bin/env bash
# The checks described by the-yoke-recipe.std.md that read the recipe; the case that builds it is ci/image.sh's.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# std: meta-yoke:the-yoke-recipe.01
check_the_recipe_pins_what_the_release_published() {
  local recipe
  recipe="$(compgen -G "$root/recipes-*/yoke/yoke_*.bb" | head -1)"
  [[ -n "$recipe" ]] || { echo "no recipe for yoke"; return 1; }
  local sources
  sources="$(awk '/^SRC_URI = /,/[^\\]$/' "$recipe" | grep -oE '[a-z]+://[^ ";]+')"
  local want=("https://github.com/yoke-project/yoke/releases/download/v\${PV}/yoke-\${PV}-source.tar.gz"
              "https://github.com/yoke-project/yoke/releases/download/v\${PV}/yoke-\${PV}-modules.tar.gz")
  [[ "$sources" == "$(printf '%s\n' "${want[@]}")" ]] || { echo "the recipe fetches [$(tr '\n' ' ' <<<"$sources")]"; return 1; }
  for name in source modules; do
    grep -qE "^SRC_URI\[$name\.sha256sum\] = \"[0-9a-f]{64}\"$" "$recipe" || { echo "the $name archive is not pinned by its sha256"; return 1; }
  done
  grep -qE '^export CGO_ENABLED = "0"$' "$recipe" || { echo "the recipe builds with C"; return 1; }
  grep -qE '^export GOFLAGS = "-mod=vendor"$' "$recipe" || { echo "the dependencies are not taken from vendor/"; return 1; }
  grep -qE '^export GOPROXY = "off"$' "$recipe" || { echo "the module proxy is not off"; return 1; }
}

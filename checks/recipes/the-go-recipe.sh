#!/usr/bin/env bash
# The checks described by the-go-recipe.std.md that read the recipe; the case that builds it is ci/image.sh's.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# std: meta-yoke:the-go-recipe.01
check_the_go_recipe_pins_the_module_and_its_dependencies() {
  local recipe dir sources source licences module
  recipe="$(compgen -G "$root/recipes-*/yoke-sdk-go/yoke-sdk-go_*.bb" | head -1)"
  [[ -n "$recipe" ]] || { echo "no recipe for yoke-sdk-go"; return 1; }
  dir="$(dirname "$recipe")"
  for each in go-mods licenses; do
    [[ -f "$dir/yoke-sdk-go-$each.inc" ]] || { echo "no $each list beside the recipe"; return 1; }
    grep -qE "^require \\\$\\{BPN\\}-$each\\.inc$" "$recipe" || { echo "the recipe does not require its $each list"; return 1; }
  done
  grep -qE '^inherit .*\bgo\b' "$recipe" || { echo "the recipe does not build with Go's class"; return 1; }
  sources="$(awk '/^SRC_URI = /,/[^\\]$/' "$recipe" | grep -oE '[a-z]+://[^ ";]+')"
  [[ "$sources" == 'https://proxy.golang.org/github.com/yoke-project/yoke-sdk-go/@v/v${PV}.zip' ]] \
    || { echo "yoke-sdk-go fetches [$(tr '\n' ' ' <<<"$sources")]"; return 1; }
  grep -qE '^SRC_URI\[sha256sum\] = "[0-9a-f]{64}"$' "$recipe" || { echo "the module is not pinned by its sha256"; return 1; }
  sources="$(grep -oE '[a-z]+://[^ "\\]+' "$dir/yoke-sdk-go-go-mods.inc")"
  [[ -n "$sources" ]] || { echo "the module list names no module"; return 1; }
  licences="$(grep -oE 'file://pkg/mod/[^;]+' "$dir/yoke-sdk-go-licenses.inc")"
  for source in $sources; do
    [[ "$source" =~ ^gomod://([^;]+)\;version=([^;]+)(\;mod=1)?\;sha256sum=[0-9a-f]{64}$ ]] \
      || { echo "the module list fetches $source"; return 1; }
    [[ -n "${BASH_REMATCH[3]}" ]] && continue
    module="${BASH_REMATCH[1]}@${BASH_REMATCH[2]}"
    grep -qF "file://pkg/mod/$module/" <<<"$licences" || { echo "the licence list names no licence of $module"; return 1; }
  done
}

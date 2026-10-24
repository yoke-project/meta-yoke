#!/usr/bin/env bash
# The checks described by the-reference-recipe.std.md that read the recipe; the case that builds it is ci/image.sh's.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# std: meta-yoke:the-reference-recipe.01
check_the_reference_recipe_pins_a_commit_and_its_dependencies() {
  local recipe dir sources source licences module append
  recipe="$(compgen -G "$root/recipes-*/yoke-reference/yoke-reference_*.bb" | head -1)"
  [[ -n "$recipe" ]] || { echo "no recipe for yoke-reference"; return 1; }
  dir="$(dirname "$recipe")"
  for each in go-mods licenses; do
    [[ -f "$dir/yoke-reference-$each.inc" ]] || { echo "no $each list beside the recipe"; return 1; }
    grep -qE "^require \\\$\\{BPN\\}-$each\\.inc$" "$recipe" || { echo "the recipe does not require its $each list"; return 1; }
  done
  sources="$(awk '/^SRC_URI = /,/[^\\]$/' "$recipe" | grep -oE '[a-z]+://[^ "]+')"
  [[ "$sources" =~ ^git://github\.com/yoke-project/yoke-reference\.git\;(.*)$ ]] || { echo "yoke-reference fetches [$(tr '\n' ' ' <<<"$sources")]"; return 1; }
  [[ ";${BASH_REMATCH[1]};" == *";protocol=https;"* && ";${BASH_REMATCH[1]};" == *";branch=main;"* ]] \
    || { echo "the repository is not fetched over https from main: ${BASH_REMATCH[1]}"; return 1; }
  grep -qE '^SRCREV = "[0-9a-f]{40}"$' "$recipe" || { echo "the repository is not pinned by a full commit"; return 1; }
  sources="$(grep -oE '[a-z]+://[^ "\\]+' "$dir/yoke-reference-go-mods.inc")"
  [[ -n "$sources" ]] || { echo "the module list names no module"; return 1; }
  licences="$(grep -oE 'file://pkg/mod/[^;]+' "$dir/yoke-reference-licenses.inc")"
  for source in $sources; do
    [[ "$source" =~ ^gomod://([^;]+)\;version=([^;]+)(\;mod=1)?\;sha256sum=[0-9a-f]{64}$ ]] \
      || { echo "the module list fetches $source"; return 1; }
    [[ -n "${BASH_REMATCH[3]}" ]] && continue
    module="${BASH_REMATCH[1]}@${BASH_REMATCH[2]}"
    grep -qF "file://pkg/mod/$module/" <<<"$licences" || { echo "the licence list names no licence of $module"; return 1; }
  done
  for each in yoke-sdk-c lvgl; do
    grep -E '^DEPENDS = ' "$recipe" | grep -qwF "$each" || { echo "yoke-reference does not take $each from the layers"; return 1; }
  done
  append="$(compgen -G "$root/recipes-*/lvgl/lvgl_*.bbappend" | head -1)"
  [[ -n "$append" ]] || { echo "the layer appends nothing to LVGL's recipe"; return 1; }
  grep -qE '^PACKAGECONFIG:append = ".*\bfbdev\b' "$append" || { echo "the layer does not ask LVGL for its framebuffer driver"; return 1; }
}

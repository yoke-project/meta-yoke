#!/usr/bin/env bash
# The checks described by the-python-recipes.std.md that read the recipes; the case that builds them is ci/image.sh's.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# std: meta-yoke:the-python-recipes.01
check_each_python_recipe_pins_what_its_family_published() {
  local recipe sources expected name
  for name in yoke-sdk yoke-proto; do
    recipe="$(compgen -G "$root/recipes-*/python3-$name/python3-${name}_*.bb" | head -1)"
    [[ -n "$recipe" ]] || { echo "no recipe for python3-$name"; return 1; }
    sources="$(awk '/^SRC_URI = /,/[^\\]$/' "$recipe" | grep -oE '[a-z]+://[^ ";]+')"
    expected="https://files.pythonhosted.org/packages/py3/y/$name/${name//-/_}-\${PV}-py3-none-any.whl"
    # Generated Python imports only on the protobuf and gRPC that generated it, so the definitions are
    # generated again, from the module at the definitions' version.
    [[ "$name" == yoke-proto ]] && expected+=$'\n'"https://proxy.golang.org/github.com/yoke-project/yoke/proto/@v/v\${PV}.zip"
    [[ "$sources" == "$expected" ]] || { echo "python3-$name fetches [$(tr '\n' ' ' <<<"$sources")]"; return 1; }
    grep -qE '^SRC_URI\[sha256sum\] = "[0-9a-f]{64}"$' "$recipe" || { echo "the $name wheel is not pinned by its sha256"; return 1; }
    if [[ "$name" == yoke-proto ]]; then
      grep -qE '^SRC_URI\[definitions\.sha256sum\] = "[0-9a-f]{64}"$' "$recipe" \
        || { echo "the definitions module python3-$name generates from is not pinned by its sha256"; return 1; }
      grep -E '^DEPENDS = ' "$recipe" | grep -qwF python3-grpcio-tools-native \
        || { echo "python3-$name does not take the series' gRPC generator"; return 1; }
    fi
  done
  sed -nE 's/^LAYERDEPENDS_yoke = "(.*)"$/\1/p' "$root/conf/layer.conf" | grep -qw meta-python \
    || { echo "the layer does not depend on meta-python"; return 1; }
}

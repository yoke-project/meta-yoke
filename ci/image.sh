#!/usr/bin/env bash
# L5: builds an image with this layer, in the container ci/image.Containerfile defines, and prints one line
# per case as checks/run.sh does; exits non-zero if any failed.
#
# What a build keeps between runs — the layers' checkouts, the downloads and the shared state — is kept
# under the cache directory, outside the checkout: YOKE_YOCTO_CACHE, or ~/.cache/meta-yoke.
# Usage: image.sh [machine ...] — qemux86-64 and qemuarm64 unless named.
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cache="${YOKE_YOCTO_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/meta-yoke}"
engine="${CONTAINER_ENGINE:-podman}"
image=localhost/meta-yoke-build
cases=(meta-yoke:the-layer.04 meta-yoke:the-layer.05 meta-yoke:the-yoke-recipe.02 meta-yoke:the-c-and-cpp-recipes.02 meta-yoke:the-c-and-cpp-recipes.03 meta-yoke:the-rust-recipe.02)

fail_all() { for id in "${cases[@]}"; do echo "FAIL  $id — $*"; done; exit 1; }

command -v "$engine" > /dev/null || fail_all "no $engine to run the build host in"
mkdir -p "$cache" || fail_all "the cache $cache cannot be made"
"$engine" build -q -t "$image" -f "$root/ci/image.Containerfile" "$root/ci" > "$cache/container.log" 2>&1 \
  || fail_all "the build host does not build: $(tail -3 "$cache/container.log")"

# The user who runs this is the user inside, so what the build writes belongs to them.
user_args=(--user "$(id -u):$(id -g)")
[[ "$engine" == podman ]] && user_args=(--userns=keep-id)
exec "$engine" run --rm "${user_args[@]}" \
  -v "$root:/layer/meta-yoke:ro,Z" -v "$cache:/cache:Z" -e HOME=/cache/home \
  "$image" bash /layer/meta-yoke/ci/image-build.sh "$@"

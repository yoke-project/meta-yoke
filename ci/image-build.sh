#!/usr/bin/env bash
# The build itself, inside the build host ci/image.sh starts: the layers the lock names at their commits,
# this layer added, and for each machine the image fetched and then built with the network off.
# Prints one line per case, as checks/run.sh does.
set -uo pipefail

layer=/layer/meta-yoke
cache=/cache
machines=("$@")
(( ${#machines[@]} )) || machines=(qemux86-64 qemuarm64)
mkdir -p "$HOME" "$cache/layers" "$cache/downloads" "$cache/sstate" "$cache/logs"
status=0

say() { if [[ -z "$2" ]]; then echo "pass  $1"; else echo "FAIL  $1 — $2"; status=1; fi; }

# Each layer of the lock, at its commit and at no branch.
why=""
while read -r name url commit; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  dir="$cache/layers/$name"
  [[ -d "$dir/.git" ]] || git clone -q --no-checkout "$url" "$dir" > /dev/null 2>&1 || { why="$name cannot be cloned"; break; }
  git -C "$dir" cat-file -e "$commit^{commit}" 2> /dev/null || git -C "$dir" fetch -q origin > /dev/null 2>&1
  git -C "$dir" -c advice.detachedHead=false checkout -q --force "$commit" > /dev/null 2>&1 || { why="$name has no commit $commit"; break; }
done < "$layer/ci/layers.lock"
if [[ -n "$why" ]]; then say meta-yoke:the-layer.04 "$why"; say meta-yoke:the-layer.05 "$why"; exit 1; fi

# A build directory per machine; downloads and shared state are one for all.
build_for() {
  local machine="$1" build="$cache/build-$1"
  mkdir -p "$build/conf"
  cat > "$build/conf/bblayers.conf" <<CONF
BBPATH = "\${TOPDIR}"
BBFILES ?= ""
BBLAYERS = "$cache/layers/openembedded-core/meta $cache/layers/meta-openembedded/meta-oe $layer"
CONF
  cat > "$build/conf/local.conf" <<CONF
MACHINE = "$machine"
DISTRO = "nodistro"
INIT_MANAGER = "systemd"
DL_DIR = "$cache/downloads"
SSTATE_DIR = "$cache/sstate"
BB_NUMBER_THREADS ?= "\${@oe.utils.cpu_count()}"
PARALLEL_MAKE ?= "-j \${@oe.utils.cpu_count()}"
CONNECTIVITY_CHECK_URIS = ""
INHERIT += "rm_work"
CONF
  echo "$build"
}

bitbake_in() {
  local build="$1"; shift
  # shellcheck disable=SC1091
  (cd "$build" && export BBPATH="$build" PATH="$cache/layers/bitbake/bin:$PATH" PYTHONPATH="$cache/layers/bitbake/lib" \
     BB_ENV_PASSTHROUGH_ADDITIONS="BB_NO_NETWORK BB_NUMBER_THREADS" && "$@")
}

first="$(build_for "${machines[0]}")"

# std: meta-yoke:the-layer.04
check_the_layer_is_taken_into_a_build() {
  local log="$cache/logs/layers.log" parse="$cache/logs/parse.log"
  bitbake_in "$first" bitbake-layers show-layers > "$log" 2>&1 || { echo "the layers cannot be listed: $(tail -3 "$log")"; return 1; }
  grep -qE "^yoke[[:space:]]+$layer[[:space:]]" "$log" \
    || { echo "the build does not list the collection yoke from $layer: $(grep -E '^[a-z-]+ ' "$log" | awk '{print $1}' | tr '\n' ' ')"; return 1; }
  bitbake_in "$first" bitbake -p > "$parse" 2>&1 || { echo "the parse fails: $(grep -m3 ERROR "$parse")"; return 1; }
  if grep -qiE 'not compatible|LAYERSERIES' "$parse" "$log"; then
    echo "the layer is said to be incompatible: $(grep -m1 -hiE 'not compatible|LAYERSERIES' "$parse" "$log")"; return 1
  fi
}

# std: meta-yoke:the-layer.05
check_an_image_builds_offline_once_fetched() {
  local target="${YOKE_IMAGE:-core-image-minimal}" why="" machine build log
  for machine in "${machines[@]}"; do
    build="$(build_for "$machine")"
    log="$cache/logs/$machine-fetch.log"
    # Fetching is bound by the host's link, not its processors: a few downloads at a time leave the
    # runner's own connection to the forge room, which a download per processor starved. A fetch keeps
    # what it already has, so one interrupted by the link is performed again, a few times, before it fails.
    local tries="${YOKE_FETCH_TRIES:-3}" try fetched=""
    for (( try = 1; try <= tries; try++ )); do
      if bitbake_in "$build" env BB_NUMBER_THREADS="${YOKE_FETCH_THREADS:-2}" bitbake --runall=fetch "$target" > "$log" 2>&1; then
        fetched=1; break
      fi
    done
    [[ -n "$fetched" ]] || { why+=" $machine does not fetch after $tries tries: $(grep -m2 ERROR "$log");"; continue; }
    log="$cache/logs/$machine-build.log"
    bitbake_in "$build" env BB_NO_NETWORK=1 bitbake "$target" > "$log" 2>&1 \
      || { why+=" $machine does not build offline: $(grep -m3 ERROR "$log");"; continue; }
    ls "$build/tmp/deploy/images/$machine/$target-$machine".rootfs*.ext4 > /dev/null 2>&1 \
      || why+=" $machine built no root filesystem;"
  done
  [[ -z "$why" ]] || { echo "${why# }"; return 1; }
}

for each in "meta-yoke:the-layer.04 check_the_layer_is_taken_into_a_build" \
            "meta-yoke:the-layer.05 check_an_image_builds_offline_once_fetched"; do
  read -r id fn <<<"$each"
  if out="$("$fn" 2>&1)"; then say "$id" ""; else say "$id" "$out"; fi
done
exit "$status"

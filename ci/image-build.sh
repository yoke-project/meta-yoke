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
BBLAYERS = "$cache/layers/openembedded-core/meta $cache/layers/meta-openembedded/meta-oe $cache/layers/meta-openembedded/meta-python $layer"
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
     BB_ENV_PASSTHROUGH_ADDITIONS="BB_NO_NETWORK" && "$@")
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

# What a machine's build is asked for: the image, and every recipe of this layer, fetched once and then
# built with the network off. Each machine's outcome is kept for the cases below to read.
target="${YOKE_IMAGE:-core-image-minimal}"
recipes="$(find "$layer"/recipes-* -name '*.bb' 2> /dev/null | sed -E 's#.*/([^/_]+)(_[^/]*)?\.bb$#\1#' | sort -u | tr '\n' ' ')"
declare -A built=()
for machine in "${machines[@]}"; do
  build="$(build_for "$machine")"
  log="$cache/logs/$machine-fetch.log"
  # Fetching is bound by the host's link, not its processors: a few downloads at a time leave the
  # runner's own connection to the forge room, which a download per processor starved. A fetch keeps
  # what it already has, so one interrupted by the link is performed again, a few times, before it fails.
  tries="${YOKE_FETCH_TRIES:-3}" fetched=""
  for (( try = 1; try <= tries; try++ )); do
    if bitbake_in "$build" env BB_NUMBER_THREADS="${YOKE_FETCH_THREADS:-2}" bitbake --runall=fetch "$target" $recipes > "$log" 2>&1; then
      fetched=1; break
    fi
  done
  if [[ -z "$fetched" ]]; then
    built[$machine]="does not fetch after $tries tries: $(grep -m2 ERROR "$log")"
    continue
  fi
  log="$cache/logs/$machine-build.log"
  if ! bitbake_in "$build" env BB_NO_NETWORK=1 bitbake "$target" $recipes > "$log" 2>&1; then
    built[$machine]="does not build offline: $(grep -m3 ERROR "$log")"
    continue
  fi
  built[$machine]=ok
done

# std: meta-yoke:the-layer.05
check_an_image_builds_offline_once_fetched() {
  local why="" machine build
  for machine in "${machines[@]}"; do
    build="$cache/build-$machine"
    if [[ "${built[$machine]}" != ok ]]; then why+=" $machine ${built[$machine]};"; continue; fi
    ls "$build/tmp/deploy/images/$machine/$target-$machine".rootfs*.ext4* > /dev/null 2>&1 || why+=" $machine built no root filesystem;"
  done
  [[ -z "$why" ]] || { echo "${why# }"; return 1; }
}

# unpack <machine> <package> <dir>: the package the machine's build deployed, unpacked under <dir>, whose
# files the cases read; the work directories are gone once a recipe is built (rm_work), the package is not.
unpack() {
  local ipk
  ipk="$(compgen -G "$cache/build-$1/tmp/deploy/ipk/*/$2_*.ipk" | head -1)"
  [[ -n "$ipk" ]] || return 1
  mkdir -p "$3/root" && (cd "$3" && ar x "$ipk" && tar -xf data.tar.* -C root)
}
# files_of <dir>: the files of an unpacked package, as they are installed, one per line.
files_of() { (cd "$1/root" && find . \( -type f -o -type l \) | sed 's#^\.##'); }

# std: meta-yoke:the-yoke-recipe.02
check_yokes_recipe_builds_its_packages() {
  local why="" machine package rest expect held dir arch
  for machine in "${machines[@]}"; do
    [[ "${built[$machine]}" == ok ]] || { why+=" $machine ${built[$machine]};"; continue; }
    case "$machine" in qemux86-64) arch="x86-64" ;; qemuarm64) arch="aarch64" ;; *) arch="" ;; esac
    for expect in "yoke-core /usr/bin/yoke-core" "yoke /usr/bin/yoke" "yoke-guardian /usr/bin/yoke-guardian" \
                  "yoke-auth /usr/bin/yoke-auth" "yoke-compose /usr/bin/yoke-compose" "yoke-conformance /usr/bin/yoke-conformance" \
                  "yoke-packaging /usr/lib/systemd/system/yoke.service /usr/lib/systemd/system-preset/98-yoke-packaging.preset /usr/lib/tmpfiles.d/yoke.conf /usr/lib/sysusers.d/yoke.conf /etc/yoke/core.yaml"; do
      read -r package rest <<<"$expect"
      dir="$(mktemp -d)"
      if ! unpack "$machine" "$package" "$dir"; then why+=" $machine built no package $package;"; rm -rf "$dir"; continue; fi
      held="$(files_of "$dir" | sort | tr '\n' ' ')"
      [[ "$held" == "$(tr ' ' '\n' <<<"$rest" | sort | tr '\n' ' ')" ]] || why+=" $machine's $package holds [${held% }], want [$rest];"
      # The Core, the manager and the tools are static; yoke-auth opens libpam when it runs, and is not.
      if [[ "$package" == yoke-auth ]]; then
        file "$dir/root$rest" | grep -q "$arch" && file "$dir/root$rest" | grep -q "dynamically linked" \
          || why+=" $machine's $package is not a dynamically linked program for $arch;"
      elif [[ "$package" != yoke-packaging ]]; then
        file "$dir/root$rest" | grep -q "$arch" && file "$dir/root$rest" | grep -q "statically linked" \
          || why+=" $machine's $package is not a static program for $arch;"
      fi
      rm -rf "$dir"
    done
    compgen -G "$cache/build-$machine/tmp/deploy/ipk/*/yoke-verify_*.ipk" > /dev/null \
      && why+=" $machine packages yoke-verify;"
  done
  [[ -z "$why" ]] || { echo "${why# }"; return 1; }
}

# family_lacks <family> <library>: what a library family's recipe did not build for each machine — its
# static development package holding the library for the machine's architecture, its development package
# holding the headers, the CMake configuration and the pkg-config file, and no program in any package.
family_lacks() {
  local family="$1" library="$2" why="" machine dir arch held file object
  for machine in "${machines[@]}"; do
    [[ "${built[$machine]}" == ok ]] || { why+=" $machine ${built[$machine]};"; continue; }
    case "$machine" in qemux86-64) arch="x86-64" ;; qemuarm64) arch="aarch64" ;; *) arch="" ;; esac
    dir="$(mktemp -d)"
    if ! unpack "$machine" "$family-dev" "$dir/dev" || ! unpack "$machine" "$family-staticdev" "$dir/static"; then
      why+=" $machine built no development packages of $family;"; rm -rf "$dir"; continue
    fi
    held="$(files_of "$dir/dev")"
    grep -q '^/usr/include/yoke/.*\.h$' <<<"$held" || why+=" $machine's $family-dev holds no public header;"
    for file in "/usr/lib/cmake/$family/$family-config.cmake" "/usr/lib/cmake/$family/$family-config-version.cmake" \
                "/usr/lib/cmake/$family/$family-targets.cmake" "/usr/lib/pkgconfig/$family.pc"; do
      grep -qxF "$file" <<<"$held" || why+=" $machine's $family-dev does not hold $file;"
    done
    [[ "$(files_of "$dir/static")" == "/usr/lib/$library.a" ]] \
      || why+=" $machine's $family-staticdev holds [$(files_of "$dir/static" | tr '\n' ' ')], want [/usr/lib/$library.a];"
    if [[ -f "$dir/static/root/usr/lib/$library.a" ]]; then
      object="$(ar t "$dir/static/root/usr/lib/$library.a" | head -1)"
      (cd "$dir/static" && ar x "root/usr/lib/$library.a" "$object")
      file "$dir/static/$object" | grep -q "$arch" || why+=" $machine's $library is not built for $arch;"
    fi
    for file in $(compgen -G "$cache/build-$machine/tmp/deploy/ipk/*/${family}*_*.ipk"); do
      rm -rf "$dir/each" && mkdir -p "$dir/each/root" && (cd "$dir/each" && ar x "$file" && tar -xf data.tar.* -C root)
      files_of "$dir/each" | grep -qE '^/usr/(s?bin)/' && why+=" $machine's $(basename "$file") holds a program;"
    done
    rm -rf "$dir"
  done
  [[ -z "$why" ]] || { echo "${why# }"; return 1; }
}

# std: meta-yoke:the-c-and-cpp-recipes.02
check_the_c_recipe_builds_the_library_and_what_builds_against_it() { family_lacks yoke-sdk-c libyoke-c; }

# std: meta-yoke:the-c-and-cpp-recipes.03
check_the_cpp_recipe_builds_the_library_and_what_builds_against_it() { family_lacks yoke-sdk-cpp libyoke-cpp; }

# std: meta-yoke:the-rust-recipe.02
check_the_rust_recipe_builds_the_library() {
  local why="" machine dir arch held rlib object file
  for machine in "${machines[@]}"; do
    [[ "${built[$machine]}" == ok ]] || { why+=" $machine ${built[$machine]};"; continue; }
    case "$machine" in qemux86-64) arch="x86-64" ;; qemuarm64) arch="aarch64" ;; *) arch="" ;; esac
    dir="$(mktemp -d)"
    if ! unpack "$machine" yoke-sdk-rust-dev "$dir/dev"; then
      why+=" $machine built no development package of yoke-sdk-rust;"; rm -rf "$dir"; continue
    fi
    held="$(files_of "$dir/dev")"
    rlib="$(grep -E '^/usr/lib/rustlib/[^/]+/lib/libyoke_sdk\.rlib$' <<<"$held" | head -1)"
    if [[ -z "$rlib" ]]; then
      why+=" $machine's yoke-sdk-rust-dev holds no libyoke_sdk rlib;"
    else
      object="$(ar t "$dir/dev/root$rlib" | grep -m1 '\.o$')"
      (cd "$dir/dev" && ar x "root$rlib" "$object")
      file "$dir/dev/$object" | grep -q "$arch" || why+=" $machine's libyoke_sdk is not built for $arch;"
    fi
    for file in $(compgen -G "$cache/build-$machine/tmp/deploy/ipk/*/yoke-sdk-rust*_*.ipk"); do
      rm -rf "$dir/each" && mkdir -p "$dir/each/root" && (cd "$dir/each" && ar x "$file" && tar -xf data.tar.* -C root)
      files_of "$dir/each" | grep -qE '^/usr/(s?bin)/' && why+=" $machine's $(basename "$file") holds a program;"
    done
    rm -rf "$dir"
  done
  [[ -z "$why" ]] || { echo "${why# }"; return 1; }
}

# std: meta-yoke:the-python-recipes.02
check_the_python_recipes_build_the_libraries() {
  local why="" machine dir package top dist held module protobuf grpc versions file
  # The versions the series generates with: protobuf's major, and gRPC's generator.
  protobuf="$(compgen -G "$cache/layers/meta-openembedded/meta-python/recipes-devtools/python/python3-protobuf_*.bb" | sed -E 's/.*_([0-9]+)\..*/\1/')"
  grpc="$(compgen -G "$cache/layers/meta-openembedded/meta-python/recipes-devtools/python/python3-grpcio-tools_*.bb" | sed -E 's/.*_(.*)\.bb$/\1/')"
  for machine in "${machines[@]}"; do
    [[ "${built[$machine]}" == ok ]] || { why+=" $machine ${built[$machine]};"; continue; }
    for package in "python3-yoke-sdk yoke_sdk yoke_sdk" "python3-yoke-proto yoke yoke_proto"; do
      read -r package top dist <<<"$package"
      dir="$(mktemp -d)"
      if ! unpack "$machine" "$package" "$dir"; then why+=" $machine built no package $package;"; rm -rf "$dir"; continue; fi
      held="$(files_of "$dir")"
      grep -qE "^/usr/lib/python3\.[0-9]+/site-packages/$top/" <<<"$held" || why+=" $machine's $package holds no $top in site-packages;"
      for file in LICENSE NOTICE; do
        grep -qE "^/usr/lib/python3\.[0-9]+/site-packages/$dist-[^/]+\.dist-info/licenses/$file$" <<<"$held" \
          || why+=" $machine's $package holds no $file;"
      done
      grep -qE '^/usr/(s?bin)/' <<<"$held" && why+=" $machine's $package holds a program;"
      if [[ "$package" == python3-yoke-proto ]]; then
        module="$(grep -cE '_pb2(_grpc)?\.py$' <<<"$held")"
        (( module > 0 )) || why+=" $machine's $package holds no generated module;"
        versions="$(cd "$dir/root" && grep -hoE '^# Protobuf Python Version: [0-9]+' $(grep -E '_pb2\.py$' <<<"$held" | sed 's#^/##') | awk '{print $NF}' | sort -u | tr '\n' ' ')"
        [[ "$versions" == "$protobuf " ]] || why+=" $machine's definitions are generated for protobuf [$versions], the series' is $protobuf;"
        versions="$(cd "$dir/root" && grep -hoE "^GRPC_GENERATED_VERSION = '[^']+'" $(grep -E '_pb2_grpc\.py$' <<<"$held" | sed 's#^/##') | cut -d"'" -f2 | sort -u | tr '\n' ' ')"
        [[ "$versions" == "$grpc " ]] || why+=" $machine's definitions are generated for gRPC [$versions], the series' generator is $grpc;"
      fi
      rm -rf "$dir"
    done
  done
  [[ -z "$why" ]] || { echo "${why# }"; return 1; }
}

for each in "meta-yoke:the-layer.04 check_the_layer_is_taken_into_a_build" \
            "meta-yoke:the-layer.05 check_an_image_builds_offline_once_fetched" \
            "meta-yoke:the-yoke-recipe.02 check_yokes_recipe_builds_its_packages" \
            "meta-yoke:the-c-and-cpp-recipes.02 check_the_c_recipe_builds_the_library_and_what_builds_against_it" \
            "meta-yoke:the-c-and-cpp-recipes.03 check_the_cpp_recipe_builds_the_library_and_what_builds_against_it" \
            "meta-yoke:the-rust-recipe.02 check_the_rust_recipe_builds_the_library" \
            "meta-yoke:the-python-recipes.02 check_the_python_recipes_build_the_libraries"; do
  read -r id fn <<<"$each"
  if out="$("$fn" 2>&1)"; then say "$id" ""; else say "$id" "$out"; fi
done
exit "$status"

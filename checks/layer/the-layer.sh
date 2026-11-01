#!/usr/bin/env bash
# The checks described by the-layer.std.md that read the layer; the cases that build it are ci/image.sh's.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# std: meta-yoke:the-layer.01
check_the_layer_says_what_it_is() {
  local conf="$root/conf/layer.conf"
  [[ -f "$conf" ]] || { echo "no conf/layer.conf"; return 1; }
  grep -qE '^BBFILE_COLLECTIONS \+= "yoke"$' "$conf" || { echo "the collection is not yoke"; return 1; }
  grep -qF '${LAYERDIR}/recipes-*/*/*.bb' "$conf" || { echo "recipes are not found under recipes-*/"; return 1; }
  grep -qE '^LAYERSERIES_COMPAT_yoke = "wrynose"$' "$conf" \
    || { echo "the layer is not compatible with wrynose alone: $(grep LAYERSERIES_COMPAT "$conf")"; return 1; }
  local depends
  depends="$(sed -nE 's/^LAYERDEPENDS_yoke = "(.*)"$/\1/p' "$conf")"
  for each in core openembedded-layer; do
    [[ " $depends " == *" $each "* ]] || { echo "the layer does not depend on $each"; return 1; }
  done
}

# std: meta-yoke:the-layer.02
check_the_build_it_is_tested_in_is_pinned() {
  local base="$root/kas/base.yml" each file name commit
  [[ -f "$base" ]] || { echo "no kas/base.yml"; return 1; }
  # Each layer the build needs, at a full commit: the line after its url names a branch to read, the commit
  # is what is checked out.
  for each in bitbake openembedded-core meta-openembedded; do
    commit="$(awk -v r="  $each:" '$0 == r {f=1; next} f && /^  [^ ]/ {f=0} f && $1 == "commit:" {print $2; exit}' "$base")"
    [[ "$commit" =~ ^[0-9a-f]{40}$ ]] || { echo "kas/base.yml does not pin $each by a full commit: '${commit}'"; return 1; }
  done
  grep -qE '^distro: nodistro$' "$base" || { echo "kas/base.yml does not build without a distribution"; return 1; }
  grep -qF 'INIT_MANAGER = "systemd"' "$base" && grep -qF 'DISTRO_FEATURES:append = " pam"' "$base" \
    || { echo "kas/base.yml does not ask for systemd and pam"; return 1; }
  # Every other file includes the base, so a machine and a form combine in either order.
  for file in "$root"/kas/*.yml "$root/ci/kas.yml"; do
    name="${file#"$root/"}"
    [[ "$name" == kas/base.yml ]] && continue
    grep -qE '^    - kas/base\.yml$' "$file" || { echo "$name does not include kas/base.yml"; return 1; }
  done
  for each in qemux86-64 qemuarm64 raspberrypi5; do
    grep -qE "^machine: $each\$" "$root/kas/$each.yml" 2> /dev/null || { echo "no kas/$each.yml for the machine $each"; return 1; }
  done
  # A board's support layer is pinned like the others, in the board's own file.
  commit="$(awk '$0 == "  meta-raspberrypi:" {f=1; next} f && /^  [^ ]/ {f=0} f && $1 == "commit:" {print $2; exit}' "$root/kas/raspberrypi5.yml")"
  [[ "$commit" =~ ^[0-9a-f]{40}$ ]] || { echo "kas/raspberrypi5.yml does not pin meta-raspberrypi by a full commit: '${commit}'"; return 1; }
  for each in application service; do
    grep -qE '^target: [a-z0-9-]+$' "$root/kas/$each.yml" 2> /dev/null || { echo "no kas/$each.yml naming the $each form's image"; return 1; }
  done
  # The workflow builds through the same files, with the kas they are written for.
  grep -qF 'kas checkout' "$root/ci/image-build.sh" && grep -qF '$layer/kas/$1.yml:$layer/ci/kas.yml' "$root/ci/image-build.sh" \
    || { echo "the image workflow does not build through kas/"; return 1; }
  grep -qF 'kas/application.yml' "$root/ci/image-build.sh" && grep -qF 'kas/service.yml' "$root/ci/image-build.sh" \
    || { echo "the image workflow does not build the images the forms' files name"; return 1; }
  grep -qE 'kas==[0-9]+\.[0-9]+' "$root/ci/image.Containerfile" || { echo "the build host does not pin kas"; return 1; }
  [[ ! -e "$root/ci/layers.lock" ]] || { echo "ci/layers.lock still says the same thing a second time"; return 1; }
  grep -qE '^FROM [^ ]+:[0-9]' "$root/ci/image.Containerfile" || { echo "the build host is not a container at a stated version"; return 1; }
  grep -qF 'ci/image.Containerfile' "$root/ci/image.sh" || { echo "the build does not run in the container this repository defines"; return 1; }
}

# std: meta-yoke:the-layer.03
check_an_image_is_built_on_the_projects_runner_only() {
  local workflow="$root/.github/workflows/image.yml"
  [[ -f "$workflow" ]] || { echo "no image workflow"; return 1; }
  grep -qE '^[[:space:]]*runs-on: \[self-hosted' "$workflow" || { echo "the image is not built on a self-hosted runner"; return 1; }
  grep -qE '^[[:space:]]+branches: \[main\]' "$workflow" || { echo "a push to the default branch builds no image"; return 1; }
  grep -qF "github.event.pull_request.head.repo.full_name == github.repository" "$workflow" \
    || { echo "a proposed change from a fork would run on the runner"; return 1; }
  grep -qE '^[[:space:]]*pull_request_target' "$workflow" && { echo "pull_request_target hands a fork's change the repository's rights"; return 1; }
  local cmd
  while read -r cmd; do
    [[ "$cmd" =~ ^just\ (develop|build|lint|fmt|test)$ || "$cmd" =~ ^ci/[a-z0-9-]+\.sh ]] \
      || { echo "the workflow runs '$cmd', which is neither a verb nor a script under ci/"; return 1; }
  done < <(sed -nE 's/^[[:space:]]*- run: (.*)$/\1/p' "$workflow")
  grep -qE '^[[:space:]]*- run: ci/record\.sh L5' "$workflow" || { echo "no record at L5 is assembled"; return 1; }
  (( $(grep -cE '^[[:space:]]*if: always\(\)' "$workflow") >= 2 )) || { echo "the record's steps do not run whatever the build decided"; return 1; }
  grep -qF 'upload-artifact' "$workflow" || { echo "the record is not handed over"; return 1; }
}

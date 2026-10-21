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
  local lock="$root/ci/layers.lock" name url commit seen=""
  [[ -f "$lock" ]] || { echo "no ci/layers.lock"; return 1; }
  while read -r name url commit; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    [[ "$commit" =~ ^[0-9a-f]{40}$ ]] || { echo "$name is pinned by '$commit', not by a full commit"; return 1; }
    seen+=" $name"
  done < "$lock"
  for each in bitbake openembedded-core meta-openembedded; do
    [[ "$seen " == *" $each "* ]] || { echo "the lock does not name $each"; return 1; }
  done
  grep -qF 'checkout -q --force "$commit"' "$root/ci/image-build.sh" || { echo "the build does not check out the lock's commits"; return 1; }
  grep -qE 'clone[^|]*(-b|--branch)' "$root/ci/image-build.sh" && { echo "the build clones a branch"; return 1; }
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

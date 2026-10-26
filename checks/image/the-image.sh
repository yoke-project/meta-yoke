#!/usr/bin/env bash
# The checks described by the-image.std.md that read the layer; the cases that build and boot it are
# ci/image.sh's.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# std: meta-yoke:the-image.01
check_the_image_says_what_a_host_of_the_example_holds() {
  local image host dir first unit
  image="$(compgen -G "$root/recipes-*/images/yoke-example-image.bb" | head -1)"
  [[ -n "$image" ]] || { echo "no image recipe yoke-example-image"; return 1; }
  host="$(compgen -G "$root/recipes-*/yoke-example-host/yoke-example-host*.bb" | head -1)"
  [[ -n "$host" ]] || { echo "no recipe for the example's host"; return 1; }
  dir="$(dirname "$host")"
  grep -E '^IMAGE_INSTALL' "$image" | grep -qw yoke-example-host || { echo "the image does not install the example's host"; return 1; }
  grep -qE 'yoke-compose|yoke-conformance' "$image" "$host" && { echo "the image or the host names a tooling package"; return 1; }
  for each in yoke yoke-core yoke-guardian yoke-packaging yoke-reference-instrument yoke-reference-station-device; do
    grep -E '^RDEPENDS:\$\{PN\}' "$host" | grep -qw -- "$each" || { echo "the example's host does not depend on $each"; return 1; }
  done
  grep -qE '^REQUIRED_DISTRO_FEATURES = "systemd pam"$' "$host" \
    || { echo "the example's host does not require the distro features systemd and pam"; return 1; }
  # The guardian's unit is yoke's to write: the layer enables it and states it nowhere.
  unit="$(grep -rlE '^ExecStart=.*yoke-guardian' "$root"/recipes-* 2> /dev/null)"
  [[ -z "$unit" ]] || { echo "the layer writes a unit of the guardian's: $unit"; return 1; }
  grep -q 'yoke-guardian\.service' "$host" || { echo "the example's host does not enable the guardian's unit"; return 1; }
  first="$(compgen -G "$dir/files/first-boot" | head -1)"
  [[ -n "$first" ]] || { echo "no first-boot script beside the host's recipe"; return 1; }
  for each in "yoke app install" "yoke instance create .*--running" "yoke instance enable"; do
    grep -qE "^$each" "$first" || { echo "the first boot does not run $each"; return 1; }
  done
  # Nothing told and no guardian summoned: the unit's guardian brings the instance up.
  grep -qE '^yoke instance (start|restart)' "$first" && { echo "the first boot starts the instance itself"; return 1; }
  grep -qE '^Before=user@[0-9]+\.service$' "$dir/files/yoke-example-first-boot.service" \
    || { echo "the first boot is not ordered before the account's user manager"; return 1; }
  grep -qE '^target="\$\{YOKE_IMAGE:-yoke-example-image\}"$' "$root/ci/image-build.sh" \
    || { echo "ci/image-build.sh does not build yoke-example-image"; return 1; }
}

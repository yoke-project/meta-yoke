#!/usr/bin/env bash
# The checks described by the-yoke-image.std.md that read the recipes; the cases that build and boot the
# images are ci/image.sh's.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# std: meta-yoke:the-yoke-image.01
check_the_images_hold_yoke_and_nothing_an_application_adds() {
  local image service host each
  image="$(compgen -G "$root/recipes-*/images/yoke-image.bb" | head -1)"
  [[ -n "$image" ]] || { echo "no image recipe yoke-image"; return 1; }
  service="$(compgen -G "$root/recipes-*/images/yoke-service-image.bb" | head -1)"
  [[ -n "$service" ]] || { echo "no image recipe yoke-service-image"; return 1; }
  host="$(compgen -G "$root/recipes-*/yoke-host/yoke-host*.bb" | head -1)"
  [[ -n "$host" ]] || { echo "no recipe yoke-host"; return 1; }

  grep -E '^IMAGE_INSTALL' "$image" | grep -qw yoke-host || { echo "yoke-image does not install yoke-host"; return 1; }
  grep -qE '^REQUIRED_DISTRO_FEATURES = "systemd pam"$' "$host" || { echo "yoke-host does not require systemd and pam"; return 1; }
  grep -qE '^YOKE_ACCOUNT \?= "apps"$' "$host" || { echo "yoke-host's account is not apps"; return 1; }
  grep -qE -- '--groups yoke-apps' "$host" || { echo "yoke-host's account is not in yoke-apps"; return 1; }
  grep -qF 'lib/systemd/linger' "$host" || { echo "yoke-host's account does not linger"; return 1; }
  grep -qF 'ln -s ${systemd_user_unitdir}/yoke-guardian.service' "$host" \
    || { echo "yoke-host does not enable the guardian's unit yoke ships"; return 1; }
  [[ -z "$(find "$(dirname "$host")" -name '*.service')" ]] || { echo "yoke-host writes a unit of its own"; return 1; }
  for each in yoke yoke-core yoke-guardian yoke-packaging; do
    grep -E '^RDEPENDS:\$\{PN\}' "$host" | grep -qw -- "$each" || { echo "yoke-host does not depend on $each"; return 1; }
  done
  for each in yoke yoke-core yoke-packaging; do
    grep -E '^IMAGE_INSTALL' "$service" | grep -qw -- "$each" || { echo "yoke-service-image does not install $each"; return 1; }
  done
  grep -qE 'SYSTEMD_AUTO_ENABLE|systemctl|\.wants' "$service" && { echo "yoke-service-image enables something"; return 1; }
  grep -qE 'yoke-compose|yoke-conformance|yoke-reference|yoke-example' "$image" "$service" "$host" \
    && { echo "an image or the host names a tooling package or the example"; return 1; }

  grep -qE '^target: yoke-image$' "$root/kas/application.yml" || { echo "kas/application.yml does not name yoke-image"; return 1; }
  grep -qE '^target: yoke-service-image$' "$root/kas/service.yml" || { echo "kas/service.yml does not name yoke-service-image"; return 1; }
}

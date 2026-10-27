#!/usr/bin/env bash
# The checks described by the-service-image.std.md that read the layer; the cases that build and boot it are
# ci/image.sh's.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# std: meta-yoke:the-service-image.01
check_the_service_image_says_what_a_service_host_holds() {
  local image host dir each
  image="$(compgen -G "$root/recipes-*/images/yoke-example-service-image.bb" | head -1)"
  [[ -n "$image" ]] || { echo "no image recipe yoke-example-service-image"; return 1; }
  host="$(compgen -G "$root/recipes-*/yoke-example-service/yoke-example-service*.bb" | head -1)"
  [[ -n "$host" ]] || { echo "no recipe for the example's service host"; return 1; }
  dir="$(dirname "$host")"
  grep -E '^IMAGE_INSTALL' "$image" | grep -qw yoke-example-service || { echo "the image does not install the service host"; return 1; }
  grep -qE 'yoke-compose|yoke-conformance' "$image" "$host" && { echo "the image or the host names a tooling package"; return 1; }
  for each in yoke yoke-core yoke-packaging yoke-reference-acquire yoke-reference-panel yoke-reference-instrument \
              yoke-reference-station-service; do
    sed -n '/^RDEPENDS:\${PN}/,/[^\\]$/p' "$host" | grep -qw -- "$each" || { echo "the service host does not depend on $each"; return 1; }
  done
  sed -n '/^RDEPENDS:\${PN}/,/[^\\]$/p' "$host" | grep -qw yoke-guardian && { echo "the service host depends on the guardian"; return 1; }
  grep -q '${sysconfdir}/yoke/deployments/station.yaml' "$host" || { echo "the composition is not installed in deployments/"; return 1; }
  grep -qE 'ln -s deployments/station.yaml \$\{D\}\$\{sysconfdir\}/yoke/deployment.yaml' "$host" \
    || { echo "the conventional path is not linked to the composition"; return 1; }
  grep -qx 'enable yoke.service' "$dir/files/90-yoke-example-service.preset" 2> /dev/null \
    || { echo "no preset enabling yoke.service"; return 1; }
  [[ -z "$(grep -rlE '^ExecStart=.*yoke(-core)? ' "$dir/files" 2> /dev/null)" ]] || { echo "the host writes a unit of yoke's"; return 1; }
  grep -qx 'Before=yoke.service' "$dir/files/yoke-example-spectro.service" 2> /dev/null \
    || { echo "the instrument is not ordered before yoke.service"; return 1; }
}

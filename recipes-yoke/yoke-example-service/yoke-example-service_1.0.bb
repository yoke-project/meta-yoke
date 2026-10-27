SUMMARY = "A host of Yoke's example in the service form: the deployment the init system starts"
DESCRIPTION = "What makes an image run the example as a device in the service form: the administrator's \
half of it. The composition document in /etc/yoke/deployments/, the conventional path linked to it, \
yoke.service enabled, and the instrument acquire binds run as a device of the image's own. The Plugins \
and the panel come from the reference recipe's packages, as a distribution's would."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://station.yaml \
           file://yoke-example-spectro.service \
           file://90-yoke-example-service.preset"
S = "${UNPACKDIR}"

inherit systemd allarch features_check

REQUIRED_DISTRO_FEATURES = "systemd"

do_install() {
	# The composition, root's in /etc as core.yaml is, and the conventional path the Core reads first.
	install -D -m 0644 ${S}/station.yaml ${D}${sysconfdir}/yoke/deployments/station.yaml
	ln -s deployments/station.yaml ${D}${sysconfdir}/yoke/deployment.yaml
	# yoke.service is yoke's: enabled here, by the preset the image's systemd reads before yoke-packaging's,
	# and by the link `systemctl enable` makes.
	install -D -m 0644 ${S}/90-yoke-example-service.preset ${D}${systemd_system_unitdir}-preset/90-yoke-example-service.preset
	install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
	ln -s ${systemd_system_unitdir}/yoke.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/yoke.service
	install -D -m 0644 ${S}/yoke-example-spectro.service ${D}${systemd_system_unitdir}/yoke-example-spectro.service
}

FILES:${PN} = "${sysconfdir}/yoke ${sysconfdir}/systemd/system/multi-user.target.wants/yoke.service \
               ${systemd_system_unitdir}-preset ${systemd_system_unitdir}/yoke-example-spectro.service"
CONFFILES:${PN} = "${sysconfdir}/yoke/deployments/station.yaml"

SYSTEMD_SERVICE:${PN} = "yoke-example-spectro.service"
SYSTEMD_AUTO_ENABLE = "enable"

# The runtime and the inputs, the Plugin and the panel where the service form reads them, the instrument,
# and the example's own composition, which the image's case compares this one with; no tooling, and no
# guardian: the init system starts this deployment.
RDEPENDS:${PN} = "yoke yoke-core yoke-packaging yoke-reference-acquire yoke-reference-panel \
                  yoke-reference-instrument yoke-reference-station-service"

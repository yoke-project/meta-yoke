SUMMARY = "A host of Yoke's example: an account that hosts the applications, and its first boot"
DESCRIPTION = "What makes an image a host of the example as a device runs it alone: an account whose user \
manager runs at boot and starts the guardian with the unit yoke ships; the instrument acquire binds, run as \
a device of the image's own; and a first boot that installs the example's package, creates its instance \
running and enables it, before the account's guardian is started."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://first-boot \
           file://station.toml \
           file://yoke-example-first-boot.service \
           file://yoke-example-instrument.service"
S = "${UNPACKDIR}"

inherit useradd systemd allarch features_check

# The account's user manager runs under PAM, which systemd builds in only with the distro feature.
REQUIRED_DISTRO_FEATURES = "systemd pam"

# The account, at a fixed identifier: the first boot is ordered before its user manager, user@1200.service.
# It may install applications (yoke-apps, the group yoke's sysusers file names) and draw to the framebuffer
# (video); the group is added here as well, because the account is made when the image is.
EXAMPLE_ACCOUNT = "station"
EXAMPLE_UID = "1200"
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "--system yoke-apps"
USERADD_PARAM:${PN} = "--uid ${EXAMPLE_UID} --create-home --home-dir /home/${EXAMPLE_ACCOUNT} --shell /bin/sh \
                       --groups yoke-apps,video --password '*' ${EXAMPLE_ACCOUNT}"

do_install() {
	install -D -m 0755 ${S}/first-boot ${D}${libexecdir}/yoke-example/first-boot
	install -D -m 0644 ${S}/station.toml ${D}${datadir}/yoke-example/station.toml
	for unit in yoke-example-first-boot.service yoke-example-instrument.service; do
		install -D -m 0644 ${S}/$unit ${D}${systemd_system_unitdir}/$unit
	done
	# The account's user manager runs at boot, with no one signed in: logind starts it for an account that
	# lingers.
	install -d ${D}${localstatedir}/lib/systemd/linger
	touch ${D}${localstatedir}/lib/systemd/linger/${EXAMPLE_ACCOUNT}
	# The guardian's unit, yoke's, enabled for the account as `systemctl --user enable` would.
	wants=/home/${EXAMPLE_ACCOUNT}/.config/systemd/user/default.target.wants
	install -d ${D}$wants
	ln -s ${systemd_user_unitdir}/yoke-guardian.service ${D}$wants/yoke-guardian.service
	chown -R ${EXAMPLE_ACCOUNT}:${EXAMPLE_ACCOUNT} ${D}/home/${EXAMPLE_ACCOUNT}
}

FILES:${PN} = "${libexecdir}/yoke-example ${datadir}/yoke-example ${systemd_system_unitdir} \
               ${localstatedir}/lib/systemd/linger /home/${EXAMPLE_ACCOUNT}"

SYSTEMD_SERVICE:${PN} = "yoke-example-first-boot.service yoke-example-instrument.service"
SYSTEMD_AUTO_ENABLE = "enable"

# The runtime and the inputs, the example's package and the instrument it binds; no tooling.
RDEPENDS:${PN} = "yoke yoke-core yoke-guardian yoke-packaging yoke-reference-instrument yoke-reference-station-device"

SUMMARY = "A host of Yoke in the application form: an account that hosts applications, with its guardian"
DESCRIPTION = "What makes an image a host of Yoke alone in the application form: an account that may \
install applications, whose user manager runs at boot with no one signed in and starts the guardian with the \
unit yoke ships. No application is installed; one is installed into the account afterwards."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit useradd allarch features_check

# The account's user manager runs under PAM, which systemd builds in only with the distro feature.
REQUIRED_DISTRO_FEATURES = "systemd pam"

# The account that hosts the applications; an image may name another.
YOKE_ACCOUNT ?= "apps"
# It may install applications (yoke-apps, the group yoke's sysusers file names), and the group is added here
# as well, because the account is made when the image is.
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "--system yoke-apps"
USERADD_PARAM:${PN} = "--create-home --home-dir /home/${YOKE_ACCOUNT} --shell /bin/sh \
                       --groups yoke-apps --password '*' ${YOKE_ACCOUNT}"

do_install() {
	# The account's user manager runs at boot, with no one signed in: logind starts it for an account that
	# lingers.
	install -d ${D}${localstatedir}/lib/systemd/linger
	touch ${D}${localstatedir}/lib/systemd/linger/${YOKE_ACCOUNT}
	# The guardian's unit, yoke's, enabled for the account as `systemctl --user enable` would.
	wants=/home/${YOKE_ACCOUNT}/.config/systemd/user/default.target.wants
	install -d ${D}$wants
	ln -s ${systemd_user_unitdir}/yoke-guardian.service ${D}$wants/yoke-guardian.service
	chown -R ${YOKE_ACCOUNT}:${YOKE_ACCOUNT} ${D}/home/${YOKE_ACCOUNT}
}

FILES:${PN} = "${localstatedir}/lib/systemd/linger /home/${YOKE_ACCOUNT}"

# The runtime and the inputs; no tooling, and no application.
RDEPENDS:${PN} = "yoke yoke-core yoke-guardian yoke-packaging"

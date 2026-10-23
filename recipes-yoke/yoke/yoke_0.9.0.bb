SUMMARY = "Yoke: the Core, the manager, the guardian, and the tooling a workstation uses with them"
DESCRIPTION = "The programs of a Yoke release, built from its source archive and the archive of its \
module dependencies, with the network off. A device takes the runtime packages and the packaging \
inputs; the composer and the conformance suite are for a workstation."
HOMEPAGE = "https://github.com/yoke-project/yoke"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327 \
                    file://NOTICE;md5=d449f03f350dad45b01299df4ea73840"

# The two archives the release publishes, each pinned by the digest its manifest line carries.
SRC_URI = "https://github.com/yoke-project/yoke/releases/download/v${PV}/yoke-${PV}-source.tar.gz;name=source \
           https://github.com/yoke-project/yoke/releases/download/v${PV}/yoke-${PV}-modules.tar.gz;name=modules"
SRC_URI[source.sha256sum] = "d869121d9c9becfd68c632a43de494dc7a900b66cc2da88351e578f71edddc47"
SRC_URI[modules.sha256sum] = "e00f3cddf5571926cf238803eea6be6eb3a8f0780ca2ec13d4d4a9387dc7c96c"

# Both archives unpack into yoke-<version>/: the modules archive is the vendor/ directory of that tree.
S = "${UNPACKDIR}/yoke-${PV}"

GO_IMPORT = "github.com/yoke-project/yoke"
inherit go systemd

# As the release builds them: no C, the dependencies from vendor/, and nothing fetched while building.
export CGO_ENABLED = "0"
export GOFLAGS = "-mod=vendor"
export GOPROXY = "off"

RUNTIME_PROGRAMS = "yoke-core yoke yoke-guardian yoke-auth"
TOOLING_PROGRAMS = "yoke-compose yoke-conformance"

do_configure() {
	:
}

do_compile() {
	cd ${S}
	for program in ${RUNTIME_PROGRAMS} ${TOOLING_PROGRAMS}; do
		${GO} build -trimpath -buildvcs=false -ldflags="-buildid=" -o ${B}/bin/$program ./cmd/$program
	done
}

do_install() {
	install -d ${D}${bindir}
	for program in ${RUNTIME_PROGRAMS} ${TOOLING_PROGRAMS}; do
		install -m 0755 ${B}/bin/$program ${D}${bindir}/$program
	done
	# The packaging inputs `yoke` ships, installed where the init system and the Core read them.
	install -D -m 0644 ${S}/packaging/yoke.service ${D}${systemd_system_unitdir}/yoke.service
	install -D -m 0644 ${S}/packaging/yoke.tmpfiles ${D}${nonarch_libdir}/tmpfiles.d/yoke.conf
	install -D -m 0644 ${S}/packaging/yoke.sysusers ${D}${nonarch_libdir}/sysusers.d/yoke.conf
	install -D -m 0644 ${S}/packaging/core.yaml ${D}${sysconfdir}/yoke/core.yaml
}

# One package per artifact: the runtime, the tooling, and the inputs a device's init system is given.
PACKAGES =+ "yoke-core yoke-guardian yoke-auth yoke-compose yoke-conformance yoke-packaging"
FILES:yoke-core = "${bindir}/yoke-core"
FILES:${PN} = "${bindir}/yoke"
FILES:yoke-guardian = "${bindir}/yoke-guardian"
FILES:yoke-auth = "${bindir}/yoke-auth"
FILES:yoke-compose = "${bindir}/yoke-compose"
FILES:yoke-conformance = "${bindir}/yoke-conformance"
FILES:yoke-packaging = "${systemd_system_unitdir}/yoke.service ${nonarch_libdir}/tmpfiles.d/yoke.conf \
                        ${nonarch_libdir}/sysusers.d/yoke.conf ${sysconfdir}/yoke/core.yaml"
CONFFILES:yoke-packaging = "${sysconfdir}/yoke/core.yaml"

# The manager executes the Core, and `yoke-auth` asks the host's authentication service through PAM, which
# it opens when it runs.
RDEPENDS:${PN} = "yoke-core"
RRECOMMENDS:yoke-auth = "${@bb.utils.contains('DISTRO_FEATURES', 'pam', 'libpam', '', d)}"
RDEPENDS:yoke-packaging = "${PN}"

SYSTEMD_PACKAGES = "yoke-packaging"
SYSTEMD_SERVICE:yoke-packaging = "yoke.service"
# The unit starts the deployment installed on the host; an image without one would start a refusal.
SYSTEMD_AUTO_ENABLE = "disable"

# Go links its own programs: a static binary carries no GNU hash, and its build identifier is emptied.
INSANE_SKIP:yoke-core += "ldflags"
INSANE_SKIP:${PN} += "ldflags"
INSANE_SKIP:yoke-guardian += "ldflags"
INSANE_SKIP:yoke-auth += "ldflags"
INSANE_SKIP:yoke-compose += "ldflags"
INSANE_SKIP:yoke-conformance += "ldflags"

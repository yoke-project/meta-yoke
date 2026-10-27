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
SRC_URI[source.sha256sum] = "a96c14357cde223ce615f36746cc3f06cacf35e3a27d0b57801a03fb5ecb50bf"
SRC_URI[modules.sha256sum] = "a294fd028cc956876fafe4b94e5e79aa38e5dcca5699dfa7c4d5b4cd636ac421"

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

# Built for the build host, the recipe is the composer alone: what a build composes an application with.
BBCLASSEXTEND = "native"
RUNTIME_PROGRAMS:class-native = ""
TOOLING_PROGRAMS:class-native = "yoke-compose"

do_configure() {
	:
}

do_compile() {
	cd ${S}
	# The release builds its programs in a checkout at its tag, and Go stamps the tag into each as the version
	# the manager reads a range against. The archives are that tree, so a repository of it, tagged, gives the
	# programs the version the release's own state.
	rm -rf .git
	git init -q
	git add -A
	GIT_AUTHOR_DATE="@${SOURCE_DATE_EPOCH}" GIT_COMMITTER_DATE="@${SOURCE_DATE_EPOCH}" \
		git -c user.name=yoke -c user.email=yoke@localhost -c commit.gpgsign=false commit -q -m "v${PV}"
	git -c tag.gpgsign=false tag "v${PV}"
	for program in ${RUNTIME_PROGRAMS} ${TOOLING_PROGRAMS}; do
		${GO} build -trimpath -buildvcs=true -ldflags="-buildid=" -o ${B}/bin/$program ./cmd/$program
	done
}

do_install() {
	install -d ${D}${bindir}
	for program in ${RUNTIME_PROGRAMS} ${TOOLING_PROGRAMS}; do
		install -m 0755 ${B}/bin/$program ${D}${bindir}/$program
	done
	# The packaging inputs `yoke` ships, installed where the init system and the Core read them.
	install -D -m 0644 ${S}/packaging/yoke.service ${D}${systemd_system_unitdir}/yoke.service
	install -D -m 0644 ${S}/packaging/yoke-guardian.service ${D}${systemd_user_unitdir}/yoke-guardian.service
	install -D -m 0644 ${S}/packaging/yoke.tmpfiles ${D}${nonarch_libdir}/tmpfiles.d/yoke.conf
	install -D -m 0644 ${S}/packaging/yoke.sysusers ${D}${nonarch_libdir}/sysusers.d/yoke.conf
	install -D -m 0644 ${S}/packaging/core.yaml ${D}${sysconfdir}/yoke/core.yaml
}

do_install:class-native() {
	install -D -m 0755 ${B}/bin/yoke-compose ${D}${bindir}/yoke-compose
}

# One package per artifact: the runtime, the tooling, and the inputs a device's init system is given.
PACKAGES =+ "yoke-core yoke-guardian yoke-auth yoke-compose yoke-conformance yoke-packaging"
FILES:yoke-core = "${bindir}/yoke-core"
FILES:${PN} = "${bindir}/yoke"
FILES:yoke-guardian = "${bindir}/yoke-guardian"
FILES:yoke-auth = "${bindir}/yoke-auth"
FILES:yoke-compose = "${bindir}/yoke-compose"
FILES:yoke-conformance = "${bindir}/yoke-conformance"
FILES:yoke-packaging = "${systemd_system_unitdir}/yoke.service ${systemd_user_unitdir}/yoke-guardian.service \
                        ${nonarch_libdir}/tmpfiles.d/yoke.conf \
                        ${nonarch_libdir}/sysusers.d/yoke.conf ${sysconfdir}/yoke/core.yaml"
CONFFILES:yoke-packaging = "${sysconfdir}/yoke/core.yaml"

# The manager executes the Core, and `yoke-auth` asks the host's authentication service through PAM, which
# it opens when it runs.
RDEPENDS:${PN} = "yoke-core"
RRECOMMENDS:yoke-auth = "${@bb.utils.contains('DISTRO_FEATURES', 'pam', 'libpam', '', d)}"
RDEPENDS:yoke-packaging = "${PN}"

SYSTEMD_PACKAGES = "yoke-packaging"
SYSTEMD_SERVICE:yoke-packaging = "yoke.service"
# The unit starts the deployment installed on the host; an image without one would start a refusal. The
# guardian's unit is a user unit, enabled for an account by whoever gives the host one.
SYSTEMD_AUTO_ENABLE = "disable"

# Go links its own programs: a static binary carries no GNU hash, and its build identifier is emptied.
INSANE_SKIP:yoke-core += "ldflags"
INSANE_SKIP:${PN} += "ldflags"
INSANE_SKIP:yoke-guardian += "ldflags"
INSANE_SKIP:yoke-auth += "ldflags"
INSANE_SKIP:yoke-compose += "ldflags"
INSANE_SKIP:yoke-conformance += "ldflags"

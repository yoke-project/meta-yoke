SUMMARY = "The Go family's harnesses: the plugin, interface and administrative ones"
DESCRIPTION = "The Go family of a Yoke release, the module github.com/yoke-project/yoke-sdk-go built with the \
series' Go against every module it depends on, each pinned by its checksum. A Go library is compiled inside \
its consumer's build, so what the recipe builds is the family's harnesses, which show the module builds \
alone: programs for a workstation, which a device takes nothing from."
HOMEPAGE = "https://github.com/yoke-project/yoke-sdk-go"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327 \
                    file://NOTICE;md5=d449f03f350dad45b01299df4ea73840"
require ${BPN}-licenses.inc

# The module the family publishes, as the Go proxy serves it: the zip whose h1: digest its manifest line
# carries, pinned by its own checksum.
SRC_URI = "https://proxy.golang.org/github.com/yoke-project/yoke-sdk-go/@v/v${PV}.zip;downloadfilename=yoke-sdk-go-v${PV}.zip;subdir=module"
SRC_URI[sha256sum] = "8a0f706eeb0d20fff60a1220449e1ad33e05d9ebe5bb00559eb3c56ac1d08bc1"
require ${BPN}-go-mods.inc

S = "${UNPACKDIR}/module/github.com/yoke-project/yoke-sdk-go@v${PV}"

GO_IMPORT = "github.com/yoke-project/yoke-sdk-go"
inherit go-mod

# No C, the dependencies from the module cache the fetch filled, and nothing fetched while building.
export CGO_ENABLED = "0"
export GOFLAGS = "-mod=mod -modcacherw"
export GOPROXY = "off"

HARNESSES = "yoke-go-plugin-harness yoke-go-interface-harness yoke-go-admin-harness"

do_configure() {
	:
}

do_compile() {
	cd ${S}
	for harness in ${HARNESSES}; do
		${GO} build -trimpath -buildvcs=false -ldflags="-buildid=" -o ${B}/bin/$harness ./cmd/$harness
	done
}

do_install() {
	install -d ${D}${bindir}
	for harness in ${HARNESSES}; do
		install -m 0755 ${B}/bin/$harness ${D}${bindir}/$harness
	done
}

FILES:${PN} = "${bindir}"

# Go links its own programs: a static binary carries no GNU hash, and its build identifier is emptied.
INSANE_SKIP:${PN} += "ldflags"

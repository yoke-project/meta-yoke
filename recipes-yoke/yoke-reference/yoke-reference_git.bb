SUMMARY = "Yoke's example application's units that run on the host, and the Go clock"
DESCRIPTION = "From a commit of yoke-reference: acquire, the example application's Plugin on the host, the \
instrument program that plays its spectrometer, the LVGL panel, its managed interface on a framebuffer, and \
the Go clock. The units the example keeps in containers are not built."
HOMEPAGE = "https://github.com/yoke-project/yoke-reference"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327 \
                    file://NOTICE;md5=d449f03f350dad45b01299df4ea73840"
require ${BPN}-licenses.inc

# The repository releases nothing, so the recipe pins a commit of main, moved by hand; every module its Go
# programs depend on is fetched into the module cache, each pinned by its checksum.
SRC_URI = "git://github.com/yoke-project/yoke-reference.git;protocol=https;branch=main"
SRCREV = "017fae86f52e9a45299eb66e3379b8ea171fd744"
require ${BPN}-go-mods.inc

PV = "0+git"
S = "${UNPACKDIR}/${BB_GIT_DEFAULT_DESTSUFFIX}"

# The panel builds against the C family and the LVGL the layers provide.
DEPENDS = "yoke-sdk-c lvgl"

GO_IMPORT = "github.com/yoke-project/yoke-reference"
inherit go-mod cmake pkgconfig

OECMAKE_SOURCEPATH = "${S}/clients/lvgl/panel"

# No C in the Go programs, the dependencies from the module cache the fetch filled, and nothing fetched while
# building.
export CGO_ENABLED = "0"
export GOFLAGS = "-mod=mod -modcacherw"
export GOPROXY = "off"

do_configure() {
	cmake_do_configure
}

go_program() {
	(cd ${S}/$1 && ${GO} build -trimpath -buildvcs=false -ldflags="-buildid=" -o ${B}/go-bin/$2 $3)
}

do_compile() {
	go_program plugins/go/acquire acquire .
	go_program plugins/go/acquire instrument ./instrument
	go_program plugins/go/clock clock .
	cmake_do_compile
}

do_install() {
	install -d ${D}${libexecdir}/yoke-reference ${D}${datadir}/yoke-reference/manifests
	for program in acquire instrument clock; do
		install -m 0755 ${B}/go-bin/$program ${D}${libexecdir}/yoke-reference/$program
	done
	install -m 0755 ${B}/panel ${D}${libexecdir}/yoke-reference/panel
	install -m 0644 ${S}/plugins/go/acquire/manifest.yaml ${D}${datadir}/yoke-reference/manifests/com.yoke.station.acquire.yaml
	install -m 0644 ${S}/plugins/go/clock/manifest.yaml ${D}${datadir}/yoke-reference/manifests/com.yoke.reference.clock.yaml
}

# One package per program, each with the Manifest its Plugin declares.
PACKAGES =+ "${PN}-acquire ${PN}-instrument ${PN}-clock ${PN}-panel"
FILES:${PN}-acquire = "${libexecdir}/yoke-reference/acquire ${datadir}/yoke-reference/manifests/com.yoke.station.acquire.yaml"
FILES:${PN}-instrument = "${libexecdir}/yoke-reference/instrument"
FILES:${PN}-clock = "${libexecdir}/yoke-reference/clock ${datadir}/yoke-reference/manifests/com.yoke.reference.clock.yaml"
FILES:${PN}-panel = "${libexecdir}/yoke-reference/panel"
ALLOW_EMPTY:${PN} = "1"

# Go links its own programs: a static binary carries no GNU hash, and its build identifier is emptied.
INSANE_SKIP:${PN}-acquire += "ldflags"
INSANE_SKIP:${PN}-instrument += "ldflags"
INSANE_SKIP:${PN}-clock += "ldflags"

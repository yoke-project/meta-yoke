SUMMARY = "Yoke's example application's units that run on the host, the example as a device runs it, and the Go clock"
DESCRIPTION = "From a commit of yoke-reference: acquire, the example application's Plugin on the host, the \
instrument program that plays its spectrometer, the LVGL panel, its managed interface on a framebuffer, and \
the Go clock; and com.yoke.station.device, the example as a device runs it alone, composed from them by the \
composer built for the build host. The units the example keeps in containers are not built."
HOMEPAGE = "https://github.com/yoke-project/yoke-reference"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327 \
                    file://NOTICE;md5=d449f03f350dad45b01299df4ea73840"
require ${BPN}-licenses.inc

# The repository releases nothing, so the recipe pins a commit of main, moved by hand; every module its Go
# programs depend on is fetched into the module cache, each pinned by its checksum.
SRC_URI = "git://github.com/yoke-project/yoke-reference.git;protocol=https;branch=main"
SRCREV = "ae1bb18064942ba60e57845121e6645d100bcdc7"
require ${BPN}-go-mods.inc

PV = "0+git"
S = "${UNPACKDIR}/${BB_GIT_DEFAULT_DESTSUFFIX}"

# The panel builds against the C family and the LVGL the layers provide; the example is composed by the
# composer built for the build host.
DEPENDS = "yoke-sdk-c lvgl yoke-native"

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
	# The example as a device runs it, composed with the composer's verbs from the programs just built, for
	# the machine's architecture, and built into the package the manager installs.
	rm -rf ${B}/station-device ${B}/station-device-out
	HOME=${B} bash ${S}/applications/station/compose-device.sh ${STAGING_BINDIR_NATIVE}/yoke-compose \
		${B}/station-device ${TARGET_ARCH} ${B}/go-bin/acquire ${B}/panel
	install -d ${B}/station-device-out
	HOME=${B} ${STAGING_BINDIR_NATIVE}/yoke-compose build --dir ${B}/station-device --out ${B}/station-device-out
}

do_install() {
	# The Plugins and the panel as a distribution's packages put them for the service form: each Manifest in
	# the scanned directory, each Plugin's executable where the Core resolves it from the identity, the
	# panel's where a composition names it. instrument is the image's own device, run by its own unit.
	for each in acquire:com.yoke.station.acquire clock:com.yoke.reference.clock; do
		program="${each%%:*}" plugin="${each#*:}"
		install -D -m 0644 ${S}/plugins/go/$program/manifest.yaml ${D}${sysconfdir}/yoke/plugins.d/$plugin/manifest.yaml
		install -D -m 0755 ${B}/go-bin/$program ${D}${nonarch_libdir}/yoke/plugins/$plugin
	done
	install -D -m 0755 ${B}/panel ${D}${nonarch_libdir}/yoke/interfaces/station-panel
	install -D -m 0755 ${B}/go-bin/instrument ${D}${libexecdir}/yoke-reference/instrument
	# The example as a device runs it: the application package, and the composition an administrator takes
	# to run the same device as a service.
	install -d ${D}${datadir}/yoke-reference/packages
	install -m 0644 ${B}/station-device-out/*.yoke ${D}${datadir}/yoke-reference/packages/
	install -D -m 0644 ${S}/applications/station/device.composition.yaml \
		${D}${datadir}/yoke-reference/compositions/station-device.yaml
}

# One package per program, each with the Manifest its Plugin declares; the example's package, which
# carries its own copies of acquire and the panel inside an archive the build does not look into: it needs
# the libraries the panel links, which the build finds for the panel's own package; and the example's
# service composition, a document for an administrator, which installs nothing in force.
PACKAGES =+ "${PN}-acquire ${PN}-instrument ${PN}-clock ${PN}-panel ${PN}-station-device ${PN}-station-service"
FILES:${PN}-acquire = "${sysconfdir}/yoke/plugins.d/com.yoke.station.acquire ${nonarch_libdir}/yoke/plugins/com.yoke.station.acquire"
FILES:${PN}-instrument = "${libexecdir}/yoke-reference/instrument"
FILES:${PN}-clock = "${sysconfdir}/yoke/plugins.d/com.yoke.reference.clock ${nonarch_libdir}/yoke/plugins/com.yoke.reference.clock"
FILES:${PN}-panel = "${nonarch_libdir}/yoke/interfaces/station-panel"
FILES:${PN}-station-device = "${datadir}/yoke-reference/packages"
FILES:${PN}-station-service = "${datadir}/yoke-reference/compositions"
RDEPENDS:${PN}-station-device = "lvgl grpc protobuf-c libssl libcrypto"
ALLOW_EMPTY:${PN} = "1"

# Go links its own programs: a static binary carries no GNU hash, and its build identifier is emptied.
INSANE_SKIP:${PN}-acquire += "ldflags"
INSANE_SKIP:${PN}-instrument += "ldflags"
INSANE_SKIP:${PN}-clock += "ldflags"

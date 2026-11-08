SUMMARY = "The Rust library a Plugin unit and an interface client of Yoke are written with"
DESCRIPTION = "The Rust family of a Yoke release, the crate yoke-sdk built with the series' Rust against the \
dependencies its lock names, each pinned by its checksum: the library, in a development package. A device \
takes nothing from it."
HOMEPAGE = "https://github.com/yoke-project/yoke-sdk-rust"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327 \
                    file://NOTICE;md5=d449f03f350dad45b01299df4ea73840"

# The crate the family publishes, pinned by the digest its manifest line carries.
SRC_URI = "crate://crates.io/yoke-sdk/${PV};name=yoke-sdk"
SRC_URI[yoke-sdk.sha256sum] = "3e252cb05a4cac75e2e856169e18a90e7803311d0793dd5fb1ab9afa891c62d0"

S = "${CARGO_VENDORING_DIRECTORY}/yoke-sdk-${PV}"

inherit cargo cargo-update-recipe-crates

require ${BPN}-crates.inc

# A library crate: what the build makes is the rlib, which is for building against and not for a device.
CARGO_INSTALL_LIBRARIES = "1"
FILES:${PN}-dev += "${rustlibdir}"
RDEPENDS:${PN}-dev = ""

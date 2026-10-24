SUMMARY = "The C libraries a Plugin unit and an interface client of Yoke are written with"
DESCRIPTION = "The C family of a Yoke release, built from its source archive against the gRPC and protobuf-c \
the layers provide: the library, and in a development package its headers, its CMake configuration and its \
pkg-config file."
HOMEPAGE = "https://github.com/yoke-project/yoke-sdk-c"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327 \
                    file://NOTICE;md5=d449f03f350dad45b01299df4ea73840"

# The archive the release publishes, pinned by the digest its manifest line carries.
SRC_URI = "https://github.com/yoke-project/yoke-sdk-c/releases/download/v${PV}/yoke-sdk-c-${PV}-source.tar.gz"
SRC_URI[sha256sum] = "91092e6bd6d60c2704799193e130d01c364f95d5864d9889b0ea705556665c0f"

S = "${UNPACKDIR}/yoke-sdk-c-${PV}"

# json-c is the harnesses', which the configuration looks for; TLS is the library's own, with OpenSSL.
DEPENDS = "grpc protobuf-c openssl json-c"

inherit cmake pkgconfig

# The harnesses and the case programs are the repository's own build, not what a consumer installs.
OECMAKE_TARGET_COMPILE = "yoke-c"

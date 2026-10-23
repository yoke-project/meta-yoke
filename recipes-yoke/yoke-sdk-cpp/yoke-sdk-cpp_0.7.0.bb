SUMMARY = "The C++ libraries a Plugin unit and an interface client of Yoke are written with"
DESCRIPTION = "The C++ family of a Yoke release, built from its source archive against the gRPC and protobuf \
the layers provide: the library, and in a development package its headers, its CMake configuration and its \
pkg-config file."
HOMEPAGE = "https://github.com/yoke-project/yoke-sdk-cpp"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327 \
                    file://NOTICE;md5=d449f03f350dad45b01299df4ea73840"

# The archive the release publishes, pinned by the digest its manifest line carries.
SRC_URI = "https://github.com/yoke-project/yoke-sdk-cpp/releases/download/v${PV}/yoke-sdk-cpp-${PV}-source.tar.gz"
SRC_URI[sha256sum] = "3e1b4877c6f8e8effd3168eb3685edac490ea1a1d76c9b7fcfced09283dcb081"

S = "${UNPACKDIR}/yoke-sdk-cpp-${PV}"

# TLS is the library's own, with OpenSSL.
DEPENDS = "grpc protobuf openssl"

inherit cmake pkgconfig

# The harnesses and the case programs are the repository's own build, not what a consumer installs.
EXTRA_OECMAKE = "-DYOKE_SDK_CPP_TESTING=OFF"

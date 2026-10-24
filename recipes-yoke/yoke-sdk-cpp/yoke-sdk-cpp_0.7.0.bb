SUMMARY = "The C++ libraries a Plugin unit and an interface client of Yoke are written with"
DESCRIPTION = "The C++ family of a Yoke release, built from its source archive against the gRPC and protobuf \
the layers provide: the library, and in a development package its headers, its CMake configuration and its \
pkg-config file."
HOMEPAGE = "https://github.com/yoke-project/yoke-sdk-cpp"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327 \
                    file://NOTICE;md5=d449f03f350dad45b01299df4ea73840"

# The definitions version the archive's record pins.
DEFINITIONS_VERSION = "v0.4.0"

# The archive the release publishes, pinned by the digest its manifest line carries; and the definitions
# module its definitions were generated from, as the Go proxy serves it.
SRC_URI = "https://github.com/yoke-project/yoke-sdk-cpp/releases/download/v${PV}/yoke-sdk-cpp-${PV}-source.tar.gz \
           https://proxy.golang.org/github.com/yoke-project/yoke/proto/@v/${DEFINITIONS_VERSION}.zip;name=definitions;downloadfilename=yoke-proto-${DEFINITIONS_VERSION}.zip;subdir=definitions-module"
SRC_URI[sha256sum] = "3e1b4877c6f8e8effd3168eb3685edac490ea1a1d76c9b7fcfced09283dcb081"
SRC_URI[definitions.sha256sum] = "2c8ebc82eb168c5998318698a8ce8a47766d067d2e5212445408146db1c68aea"

S = "${UNPACKDIR}/yoke-sdk-cpp-${PV}"

# TLS is the library's own, with OpenSSL. The generators are the layers', since generated C++ compiles only
# against the protobuf that generated it.
DEPENDS = "grpc protobuf openssl protobuf-native grpc-native"

inherit cmake pkgconfig

# The harnesses and the case programs are the repository's own build, not what a consumer installs.
EXTRA_OECMAKE = "-DYOKE_SDK_CPP_TESTING=OFF"

# The module is the one the record names: its version, and the h1: digest the manifest publishes — the
# SHA-256 of the sorted list of every file's SHA-256 and name, in base64.
python check_definitions_module() {
    import base64, hashlib, os
    record = {}
    with open(d.expand("${S}/definitions/record")) as f:
        for line in f:
            key, _, value = line.strip().partition(" ")
            record[key] = value
    if record.get("version") != d.getVar("DEFINITIONS_VERSION"):
        bb.fatal("the record pins definitions %s, the recipe fetches %s" % (record.get("version"), d.getVar("DEFINITIONS_VERSION")))
    root = d.expand("${UNPACKDIR}/definitions-module")
    names = sorted(os.path.relpath(os.path.join(p, n), root) for p, _, files in os.walk(root) for n in files)
    listing = ""
    for name in names:
        with open(os.path.join(root, name), "rb") as f:
            listing += "%s  %s\n" % (hashlib.sha256(f.read()).hexdigest(), name)
    computed = "h1:" + base64.b64encode(hashlib.sha256(listing.encode()).digest()).decode()
    if computed != record.get("digest"):
        bb.fatal("the definitions module is not the one the record names (computed %s, recorded %s)" % (computed, record.get("digest")))
}
do_configure[prefuncs] += "check_definitions_module"

# The record's contracts, generated again with the layers' protoc and gRPC plugin in place of the tree the
# repository's own generators wrote; the well-known types are libprotobuf's own.
do_configure:prepend() {
    module="${UNPACKDIR}/definitions-module/github.com/yoke-project/yoke/proto@${DEFINITIONS_VERSION}"
    contracts="$(awk '$1 == "contracts" { $1 = ""; print }' ${S}/definitions/record)"
    find ${S}/definitions -mindepth 1 -maxdepth 1 ! -name record -exec rm -rf {} +
    for contract in $contracts; do
        protoc -I "$module" -I ${STAGING_INCDIR_NATIVE} --cpp_out=${S}/definitions --grpc_out=${S}/definitions \
            --plugin=protoc-gen-grpc=${STAGING_BINDIR_NATIVE}/grpc_cpp_plugin \
            $(cd "$module" && find yoke/$contract -name '*.proto' | LC_ALL=C sort)
    done
}

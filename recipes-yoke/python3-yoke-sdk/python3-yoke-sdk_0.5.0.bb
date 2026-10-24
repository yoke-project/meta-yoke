SUMMARY = "The Python libraries a Plugin unit and an interface client of Yoke are written with"
DESCRIPTION = "The Python family of a Yoke release, the wheel yoke-sdk its family published, in a package a \
device installs, over the definitions package and the layers' gRPC."
HOMEPAGE = "https://github.com/yoke-project/yoke-sdk-python"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://yoke_sdk-${PV}.dist-info/licenses/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327 \
                    file://yoke_sdk-${PV}.dist-info/licenses/NOTICE;md5=d449f03f350dad45b01299df4ea73840"

# The wheel the release publishes, pinned by the digest its manifest line carries. A wheel is a zip,
# unpacked as one.
SRC_URI = "https://files.pythonhosted.org/packages/py3/y/yoke-sdk/yoke_sdk-${PV}-py3-none-any.whl;downloadfilename=yoke_sdk-${PV}-py3-none-any.zip;subdir=wheel"
SRC_URI[sha256sum] = "4161d360c288e928b051a5a00587721b52c483cb747836c16cc4c078a669b166"

S = "${UNPACKDIR}/wheel"

inherit allarch python3-dir

do_configure[noexec] = "1"
do_compile[noexec] = "1"

# A wheel that is pure Python installs by placing its tree in site-packages.
do_install() {
    install -d ${D}${PYTHON_SITEPACKAGES_DIR}
    cp -R --no-preserve=ownership ${S}/yoke_sdk ${S}/yoke_sdk-${PV}.dist-info ${D}${PYTHON_SITEPACKAGES_DIR}/
}

# The wheel states the gRPC its family is tested with as its floor; what it calls is in the layers' own.
FILES:${PN} = "${PYTHON_SITEPACKAGES_DIR}"
RDEPENDS:${PN} = "python3-core python3-asyncio python3-ctypes python3-io python3-json python3-mmap \
                  python3-grpcio python3-yoke-proto"

SUMMARY = "The protocol definitions of Yoke, generated for Python"
DESCRIPTION = "The definitions package of the Python family of a Yoke release, the wheel yoke-proto with its \
definitions generated again by the layers' gRPC generator from the definitions module at the same version, \
since generated Python imports only on the protobuf and gRPC that generated it."
HOMEPAGE = "https://github.com/yoke-project/yoke"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://yoke_proto-${PV}.dist-info/licenses/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327 \
                    file://yoke_proto-${PV}.dist-info/licenses/NOTICE;md5=d449f03f350dad45b01299df4ea73840"

# The wheel the release publishes, pinned by the digest its manifest line carries; and the definitions
# module at its version, as the Go proxy serves it. A wheel is a zip, unpacked as one.
SRC_URI = "https://files.pythonhosted.org/packages/py3/y/yoke-proto/yoke_proto-${PV}-py3-none-any.whl;downloadfilename=yoke_proto-${PV}-py3-none-any.zip;subdir=wheel \
           https://proxy.golang.org/github.com/yoke-project/yoke/proto/@v/v${PV}.zip;name=definitions;downloadfilename=yoke-proto-v${PV}.zip;subdir=definitions-module"
SRC_URI[sha256sum] = "41d9a5b7870cf49eca2880d2dcc881d74fd4c15ddf0b204d818e84ca596a8d5a"
SRC_URI[definitions.sha256sum] = "2c8ebc82eb168c5998318698a8ce8a47766d067d2e5212445408146db1c68aea"

S = "${UNPACKDIR}/wheel"

DEPENDS = "python3-grpcio-tools-native"

inherit allarch python3native python3-dir

# Every module the wheel generated, generated again from the module's contracts with the layers' generator;
# the well-known types are the generator's own.
do_compile() {
    module="${UNPACKDIR}/definitions-module/github.com/yoke-project/yoke/proto@v${PV}"
    contracts="$(cd ${S} && find yoke -name '*_pb2.py' | sed 's/_pb2\.py$/.proto/' | LC_ALL=C sort)"
    [ -n "$contracts" ] || bbfatal "the wheel holds no generated module"
    find ${S}/yoke \( -name '*_pb2.py' -o -name '*_pb2.pyi' -o -name '*_pb2_grpc.py' \) -delete
    (cd "$module" && nativepython3 -m grpc_tools.protoc -I. --python_out=${S} --pyi_out=${S} --grpc_python_out=${S} $contracts)
}

# The wheel's record lists what it installs by digest, so it is written again for the modules generated here.
python write_record() {
    import base64, hashlib, os
    s = d.getVar("S")
    record = "yoke_proto-%s.dist-info/RECORD" % d.getVar("PV")
    lines = []
    for path, _, files in os.walk(s):
        for name in files:
            rel = os.path.relpath(os.path.join(path, name), s)
            if rel == record:
                continue
            with open(os.path.join(s, rel), "rb") as f:
                data = f.read()
            digest = base64.urlsafe_b64encode(hashlib.sha256(data).digest()).rstrip(b"=").decode()
            lines.append("%s,sha256=%s,%d" % (rel, digest, len(data)))
    lines.sort()
    lines.append("%s,," % record)
    with open(os.path.join(s, record), "w") as f:
        f.write("\n".join(lines) + "\n")
}
do_compile[postfuncs] += "write_record"

# A wheel that is pure Python installs by placing its tree in site-packages.
do_install() {
    install -d ${D}${PYTHON_SITEPACKAGES_DIR}
    cp -R --no-preserve=ownership ${S}/yoke ${S}/yoke_proto-${PV}.dist-info ${D}${PYTHON_SITEPACKAGES_DIR}/
}

# The wheel states the protobuf and gRPC it was generated with as its floor; the modules generated here need
# only the layers' own, which are what the package takes.
FILES:${PN} = "${PYTHON_SITEPACKAGES_DIR}"
RDEPENDS:${PN} = "python3-core python3-protobuf python3-grpcio"

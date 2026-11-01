SUMMARY = "An image of Yoke alone, in the application form"
DESCRIPTION = "The smallest image with Yoke's runtime, its packaging inputs and an account that hosts \
applications, its guardian running at boot; no application is installed. The image the documentation builds, \
and one this layer is tested with (L5). It is a starting point, not a product: root signs in on the console \
with no password."
LICENSE = "MIT"

require recipes-core/images/core-image-minimal.bb

# shadow-base carries su, with which the account is read.
IMAGE_INSTALL:append = " yoke-host shadow-base"
IMAGE_FEATURES += "allow-empty-password empty-root-password allow-root-login"
# runqemu boots an uncompressed root filesystem; another machine keeps the formats its layer gives it.
IMAGE_FSTYPES:qemuall = "ext4"
QB_DEFAULT_FSTYPE:qemuall = "ext4"

# An application installed later is unpacked into the account's install root; the image leaves it the room.
IMAGE_ROOTFS_EXTRA_SPACE = "262144"

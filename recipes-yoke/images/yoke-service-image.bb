SUMMARY = "An image of Yoke alone, in the service form"
DESCRIPTION = "The smallest image with Yoke's runtime and its packaging inputs for the service form: \
yoke.service is installed and left disabled, since it starts a deployment and an image of Yoke alone has none. \
The image the documentation builds, and one this layer is tested with (L5). It is a starting point, not a \
product: root signs in on the console with no password."
LICENSE = "MIT"

require recipes-core/images/core-image-minimal.bb

IMAGE_INSTALL:append = " yoke yoke-core yoke-packaging"
IMAGE_FEATURES += "allow-empty-password empty-root-password allow-root-login"
# runqemu boots an uncompressed root filesystem; another machine keeps the formats its layer gives it.
IMAGE_FSTYPES:qemuall = "ext4"
QB_DEFAULT_FSTYPE:qemuall = "ext4"

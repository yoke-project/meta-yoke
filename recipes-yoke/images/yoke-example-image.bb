SUMMARY = "An image that is a host of Yoke's example, as a device runs it alone"
DESCRIPTION = "The image this layer is tested with (L5): the smallest image, with the runtime packages, the \
packaging inputs and the example's host. It is a test of the layer, not a product: root signs in on the \
console with no password, which is how the test reads the host."
LICENSE = "MIT"

require recipes-core/images/core-image-minimal.bb

# The test reads the host as the account with su, which shadow-base carries.
IMAGE_INSTALL:append = " yoke-example-host shadow-base"
IMAGE_FEATURES += "allow-empty-password empty-root-password allow-root-login"

# The first boot installs the example into the install root; the image leaves it the room.
IMAGE_ROOTFS_EXTRA_SPACE = "262144"

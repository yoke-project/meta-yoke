SUMMARY = "An image that runs Yoke's example as a device, in the service form"
DESCRIPTION = "The image this layer is tested with in the service form (L5): the smallest image, with the \
runtime, the packaging inputs, the example's Plugin and panel where the service form reads them, and a host \
that composes and enables the deployment. It is a test of the layer, not a product: root signs in on the \
console with no password, which is how the test reads the host."
LICENSE = "MIT"

require recipes-core/images/core-image-minimal.bb

IMAGE_INSTALL:append = " yoke-example-service"
IMAGE_FEATURES += "allow-empty-password empty-root-password allow-root-login"
# runqemu boots an uncompressed root filesystem.
IMAGE_FSTYPES = "ext4"

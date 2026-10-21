# The host an image of this layer is built on: Ubuntu 24.04, one of the series' tested hosts, with the
# packages the Yocto Project names for a build host. BitBake refuses to run as root, so the build runs as
# the user who starts the container.
FROM docker.io/library/ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential chrpath cpio debianutils diffstat file gawk gcc git iputils-ping libacl1 lz4 locales \
      python3 python3-git python3-jinja2 python3-pexpect python3-pip python3-subunit socat texinfo unzip \
      wget xz-utils zstd ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

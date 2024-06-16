#!/bin/bash -e
#
# To be executed inside the chroot, to provision the environment

export DEBIAN_FRONTEND=noninteractive
apt-get update

# Ubuntu Xenial does not get the _apt user installed when creating
# a chroot via debootstrap, so create it now to prevent failures.
adduser --force-badname --system --home /nonexistent  \
        --no-create-home --quiet _apt || true

# General build dependencies:
apt-get install -y --assume-yes \
        bison \
        cmake \
        debhelper \
        flex \
        gawk \
        gcc-11-base \
        gperf \
        libasan8 \
        libgcc-11-dev \
        libstdc++-11-dev \
        pkg-config \
        ruby

# Cross compiler:
apt-get install -y --assume-yes \
        cpp-11-arm-linux-gnueabihf \
        g++-11-arm-linux-gnueabihf \
        gcc-11-arm-linux-gnueabihf \
        gcc-11-arm-linux-gnueabihf-base \
        libasan8-armhf-cross \
        libgcc-11-dev-armhf-cross \
        libstdc++-11-dev-armhf-cross

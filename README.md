# WebKit2GTK+ cross-compilation environment for ARM

Resources to allow cross compiling WebKit2GTK+ for ARM.

## Requirements

* A host machine with lots of CPUs and RAM (16GB recommended)
* RootFS for the target device
  - You must adjust the path in the CMake Toolchain file accordingly (e.g `/schroot/eos-master-armhf`)
* Packages to create and use the chroot: debootstrap, chroot and schroot
  - Debian/Ubuntu: `sudo apt-get install debootstrap schroot`
  - Fedora: `sudo dnf install debootstrap chroot schroot`

## Instructions

(1) First, create a directory to host the chroot, adjusting `/path/to/chroot` accordingly (e.g `/schroot/eos-master-armhf`):
```console
  $ sudo /usr/sbin/debootstrap \
    --arch amd64 \
    --components=main,universe \
    jammy /path/to/chroot http://uk.archive.ubuntu.com/ubuntu
```

(2) Create a configuration file for the schroot tool, for example `/etc/schroot/chroot.d/jammy-amd64`, with the following contents (replacing `<username>`, `<group>`, and `/path/to/chroot` accordingly):
```ini
[jammy-amd64]
description=Ubuntu 64-bit chroot based on Jammy
type=directory
directory=/path/to/chroot
users=<username>
groups=<group>
root-users=<username>
setup.copyfiles=default/copyfiles
setup.fstab=default/jammy-amd64.fstab
```

(3) Next you need to create the mentioned fstab file under `/etc/schroot/default` so that schroot can bind mount the path to the RootFS. To do that, create a copy of `/etc/schroot/default/fstab` (`sudo cp /etc/schroot/default/fstab /etc/schroot/default/jammy-amd64.fstab`), then add this line to its contents:
```bash
# To crosscompile WebKitGTK
/schroot/eos-master-armhf  /schroot/eos-master-armhf        none    rw,bind         0       0
```
IMPORTANT: the second column specifies the mount point **inside** the chroot, so it must be in sync with the path referenced from the CMake Toolchain file.

(4) You should now be able to **enter the chroot** from your user session (sudo not required):
```console
  $ schroot -c jammy-amd64
```

(5) From inside the chroot, **run the `bootstrap.sh` script as the root user** (or using sudo) provided with this repository to provision it with the tools you need to build Webkit, and then **copy the `armv7l-toolchain.cmake` file to some local path**, and you're good to go.

(6) Next create a BUILD directory in `/path/to/your/WebKit` and configure the build (you might want to pass extra/different parameters, though) from inside the chroot:
```console
  $ mkdir /path/to/your/WebKit/BUILD && cd /path/to/your/WebKit/BUILD
  $ cmake -DCMAKE_TOOLCHAIN_FILE=/home/mario/work/webkit2gtk-ARM/armv7l-toolchain.cmake \
        -DPORT=GTK \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_SYSCONFDIR=/etc \
        -DCMAKE_INSTALL_LOCALSTATEDIR=/var \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_INSTALL_LIBDIR=lib/arm-linux-gnueabihf \
        -DCMAKE_INSTALL_LIBEXECDIR=lib/arm-linux-gnueabihf \
        -DENABLE_PLUGIN_PROCESS_GTK2=OFF \
        -DENABLE_GEOLOCATION=OFF \
        -DENABLE_GLES2=ON \
        -DUSE_LD_GOLD=OFF \
        /path/to/your/WebKit
```

(7) Finally, from inside the chroot, build WebKit:
```console
  $ make VERBOSE=1 -j12    # Or anything else, this is just what I use
```

And that should be all. You now should be able to copy the output files over to the target machine and run your cross-compiled WebKit build.

Enjoy!

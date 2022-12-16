# Emacs running directly on Linux (Pid1)

## Setup prerequisites

``` shellsession
$ export ROOTFS_MNT=$PWD/rootfs_mnt
$ export ROOTFS=$PWD/rootfs
$ ./make_emacs_rootfs.sh
```

## Statically compiled Ncurses
Emacs will complain about not being able to find tputs, unless a statically linked library of `ncurses` can be found
``` shellsession
$ pushd ncurses
$ ./configure CC=gcc CXX=gcc LDFLAGS=-static CFLAGS=-static --prefix=""
$ make -j$(nproc)
$ make DESTDIR=$PWD/build install
$ popd
```

## Statically compiled Emacs
We need a statically compiled version of emacs if we want to keep the rootfs minimal

``` shellsession
$ pushd emacs
$ ./autogen.sh
$ ./configure --with-json=no --without-x --without-libsystemd --without-gnutls --with-sound=no --without-lcms2 --without-dbus CFLAGS="-static -O3 -I$PWD/../ncurses/build/include" LDFLAGS="-static -L$PWD/../ncurses/build/lib" CC=musl-gcc CXX=musl-gcc --prefix=""
$ make -j$(nproc)
$ sudo make DESTDIR=$ROOTFS_MNT install
$ popd
```

# User Mode Linux
This is not strictly necessary and you can also use a virtual machine instead, but this makes for a much faster workflow

``` shellsession
$ pushd Linux
$ make ARCH=um menuconfig
$ make ARCH=um -j$(nproc)
$ install -m 755 linux $HOME/.local/bin/uml
$ popd
```

# Statically compile busybox

When creating your busybox config the following settings must be set correctly

[x] Settings->Don't use /usr
[x] Settings->Build static binary (no shared libs)
[x] Linux System Utilities->mount
[x] Linux System Utilities->umount
[x] Login/Password Management Utilities->getty

``` shellsession
$ pushd busybox
$ make menuconfig
$ make -j$(nproc)
$ make install
$ popd
```

# Shutdown and Reboot utilities

``` shellsession
$ pushd shutdown
$ gcc -static shutdown.c -o shutdown
$ popd
```

# Finishing steps

``` shellsession
$ ./setup_emacs_rootfs.sh
$ sudo umount $ROOTFS_MNT
```

# Launch Emacs-Os

``` shellsession
$ uml ubd0=$ROOTFS init=/sbin/getty -i -n -l /bin/emacs 0 /dev/tty0 linux
```

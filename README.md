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

## Statically compiled libxml2
The Emacs web browser requires libxml2 to work

``` shellsession
$ pushd libxml2
$ cmake -DBUILD_SHARED_LIBS=OFF -DLIBXML2_WITH_LZMA=OFF -DLIBXML2_WITH_ZLIB=OFF -DLIBXML_HTTP_ENABLED=OFF -DCMAKE_INSTALL_PREFIX:PATH=$PWD/build .
$ sudo cmake --build . --target install
$ popd 
```

## Statically compiled nettle
Nettle is a cryptograpy library used by gnutls

``` shellsession
$ pushd nettle
$ ./configure CC=musl-gcc --prefix=$PWD/build --enable-static --disable-documentation --disable-shared --enable-mini-gmp
$ make -j$(nproc)
$ make install
$ popd
```

## Statically compiled libev
Libev is an event loop library required by gnutls

``` shellsession
$ pushd libev
$ ./configure CC=musl-gcc CXX=musl-gcc --prefix=$PWD/build --enable-static --enable-shared=no
$ make -j$(nproc)
$ make install
$ popd
```

## Statically compiled gnutls
The Emacs web browser requires gnutls support to connect to https websites

``` shellsession
$ pushd gnutls
$ ./bootstrap
$ ./configure CC=musl-gcc NETTLE_CFLAGS="-I$PWD/../nettle/build/include" NETTLE_LIBS="-static -L$PWD/../nettle/build/lib64 -lhogweed -lnettle" HOGWEED_CFLAGS="-I$PWD/../nettle/build/include" HOGWEED_LIBS="-static -L$PWD/../nettle/build/lib64 -lhogweed -lnettle" LDFLAGS="-static -L$PWD/../nettle/build/lib64 -lhogweed -lnettle" CFLAGS="-I$PWD/../nettle/build/include" --with-libev-prefix="$PWD/../libev/build" --prefix=$PWD/build --enable-static --disable-shared --with-included-unistring --with-included-libtasn1 --disable-cxx --without-p11-kit --without-idn --disable-doc --disable-gost --with-nettle-mini
$ make -j$(nproc)
$ make install
$ popd
```

## Statically compiled Emacs
We need a statically compiled version of emacs if we want to keep the rootfs minimal

``` shellsession
$ pushd emacs
$ git apply ../patches/emacs/*.patch
$ ./autogen.sh
$ ./configure --with-json=no --without-x --without-libsystemd --with-sound=no --without-lcms2 --without-dbus CFLAGS="-O3 -I$PWD/../ncurses/build/include" LIBGNUTLS_CFLAGS="-I$PWD/../nettle/build/include -I$PWD/../gnutls/build/include" LIBXML2_CFLAGS="-I$PWD/../libxml2/build/include/libxml2" LDFLAGS="-static -L$PWD/../ncurses/build/lib" LIBXML2_LIBS="-static -L$PWD/../libxml2/build/lib -lxml2" LIBGNUTLS_LIBS="-static -L$PWD/../nettle/build/lib64 -L$PWD/../gnutls/build/lib -lgnutls -lhogweed -lnettle" CC=musl-gcc CXX=musl-gcc --prefix=""
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

# Statically compiled ffmpeg
This allows the ability to record the framebuffer and to stream to twitch

``` shellsession
$ pushd twitch
$ git apply ../patches/ffmpeg/*.patch
$ ./build.sh -j$(nproc)
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

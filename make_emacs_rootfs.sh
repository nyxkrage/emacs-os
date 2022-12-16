#!/usr/bin/env sh

rfs_mkdir() {
    echo "$@" | tr ' ' '\n' | xargs -I{} sudo mkdir -p "$ROOTFS_MNT/{}"
}

SIZE=${1:-500M}
SIZE=$(numfmt --from=iec $SIZE)

dd if=/dev/urandom of=$ROOTFS status=progress count=$(($SIZE / 10000000)) bs=10M
mke2fs $ROOTFS
mkdir -p $ROOTFS_MNT
sudo mount -o loop $ROOTFS $ROOTFS_MNT

rfs_mkdir bin/ boot/ dev/ etc/ lib/ proc/ run/ sbin/ sys/ tmp/
sudo ln -s . "$ROOTFS_MNT/usr"
sudo mknod -m 600 "$ROOTFS_MNT/dev/console" c 5 1
sudo mknod -m 666 "$ROOTFS_MNT/dev/null" c 1 3

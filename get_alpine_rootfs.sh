#!/usr/bin/env sh

VERSION=${1:-3.17}
OUTDIR=$PWD/alpine_rootfs/

mkdir $OUTDIR
wget "http://dl-cdn.alpinelinux.org/alpine/v$VERSION/releases/x86_64/alpine-minirootfs-$VERSION.0-x86_64.tar.gz" -O- | tar xzf - -C $OUTDIR

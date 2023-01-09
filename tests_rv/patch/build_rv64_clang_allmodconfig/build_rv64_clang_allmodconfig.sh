#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
#
# Copyright (c) 2022 by Rivos Inc.

tmpdir=$(mktemp -d)
rc=0

tuxmake --wrapper ccache --target-arch riscv --directory . \
        --environment=KBUILD_BUILD_TIMESTAMP=@1621270510 \
        --environment=KBUILD_BUILD_USER=tuxmake --environment=KBUILD_BUILD_HOST=tuxmake \
        -o $tmpdir --toolchain llvm -z none --kconfig allmodconfig \
        -K CONFIG_RANDSTRUCT_NONE=y CROSS_COMPILE=riscv64-linux- || rc=1

if [ $rc -ne 0 ]; then
  echo "Build failed" >&$DESC_FD
else
  echo "Build OK" >&$DESC_FD
fi

rm -rf $tmpdir

exit $rc

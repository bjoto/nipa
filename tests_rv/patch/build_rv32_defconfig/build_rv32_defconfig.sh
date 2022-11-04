#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
#
# Copyright (c) 2022 by Rivos Inc.

tmpdir=$(mktemp -d)
rc=0

tuxmake --wrapper ccache --target-arch riscv --runtime podman --directory . \
        --environment=KBUILD_BUILD_TIMESTAMP=@1621270510 \
        --environment=KBUILD_BUILD_USER=tuxmake --environment=KBUILD_BUILD_HOST=tuxmake \
        -o $tmpdir --toolchain gcc-11 -z none -k rv32_defconfig || rc=1

if [ $rc -ne 0 ]; then
  echo "Build failed" >&$DESC_FD
else
  echo "Build and OK" >&$DESC_FD
  fi
fi

rm -rf $tmpdir

exit $rc

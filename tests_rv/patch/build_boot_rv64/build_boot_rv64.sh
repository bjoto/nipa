#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
#
# Copyright (c) 2022 by Rivos Inc.

tmpdir=build
rc=0

tuxmake --wrapper ccache --target-arch riscv -e PATH=$PATH --directory . \
	--environment=KBUILD_BUILD_TIMESTAMP=@1621270510 \
	--environment=KBUILD_BUILD_USER=tuxmake --environment=KBUILD_BUILD_HOST=tuxmake \
	-o $tmpdir --toolchain gcc || rc=1

if [ $rc -ne 0 ]; then
  echo "Build failed" >&$DESC_FD
else
  tuxrun --device qemu-riscv64 --tuxmake $tmpdir || rc=1
  if [ $rc -ne 0 ]; then
    echo "Boot/poweroff failed" >&$DESC_FD
  else
    echo "Build and boot/poweroff OK" >&$DESC_FD
  fi
fi

rm -rf $tmpdir

exit $rc

#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2019 Netronome Systems, Inc.

# Modified tests/patch/build_defconfig_warn.sh for RISC-V builds

tmpfile_b=$(mktemp)
tmpfile_o=$(mktemp)
tmpfile_n=$(mktemp)

tmpdir0=build

rc=0

echo "Redirect to $tmpfile_b $tmpfile_o and $tmpfile_n"

HEAD=$(git rev-parse HEAD)

echo "Tree base:"
git log -1 --pretty='%h ("%s")' HEAD~

echo "Baseline building the tree"

tuxmake --wrapper ccache --target-arch riscv -e PATH=$PATH --directory . \
	--environment=KBUILD_BUILD_TIMESTAMP=@1621270510 --fail-fast \
	--environment=KBUILD_BUILD_USER=tuxmake --environment=KBUILD_BUILD_HOST=tuxmake \
	-o $tmpdir0 --toolchain gcc -z none --kconfig allmodconfig -K CONFIG_WERROR=n \
	-K CONFIG_GCC_PLUGINS=n \
	> $tmpfile_b || rc=1

if [ $rc -eq 1 ]
then
	echo "Failed to build the tree with this patch." >&$DESC_FD
	grep "\(warning\|error\):" $tmpfile_b >&2
	exit $rc
fi

git checkout -q HEAD~

echo "Building the tree before the patch"

tuxmake --wrapper ccache --target-arch riscv -e PATH=$PATH --directory . \
	--environment=KBUILD_BUILD_TIMESTAMP=@1621270510 \
	--environment=KBUILD_BUILD_USER=tuxmake --environment=KBUILD_BUILD_HOST=tuxmake \
	-o $tmpdir0 --toolchain gcc -z none --kconfig allmodconfig -K CONFIG_WERROR=n \
	-K CONFIG_GCC_PLUGINS=n W=1 \
	> $tmpfile_o

incumbent=$(grep -c "\(warning\|error\):" $tmpfile_o)

echo "Building the tree with the patch"

git checkout -q $HEAD

tuxmake --wrapper ccache --target-arch riscv -e PATH=$PATH --directory . \
	--environment=KBUILD_BUILD_TIMESTAMP=@1621270510 \
	--environment=KBUILD_BUILD_USER=tuxmake --environment=KBUILD_BUILD_HOST=tuxmake \
	-o $tmpdir0 --toolchain gcc -z none --kconfig allmodconfig -K CONFIG_WERROR=n \
	-K CONFIG_GCC_PLUGINS=n W=1 \
	> $tmpfile_n || rc=1

current=$(grep -c "\(warning\|error\):" $tmpfile_n)

echo "Errors and warnings before: $incumbent this patch: $current" >&$DESC_FD

if [ $current -gt $incumbent ]; then
  echo "New errors added" 1>&2
  diff -U 0 $tmpfile_o $tmpfile_n 1>&2

  echo "Per-file breakdown" 1>&2
  tmpfile_fo=$(mktemp)
  tmpfile_fn=$(mktemp)

  grep "\(warning\|error\):" $tmpfile_o | sed -n 's@\(^\.\./[/a-zA-Z0-9_.-]*.[ch]\):.*@\1@p' | sort | uniq -c \
    > $tmpfile_fo
  grep "\(warning\|error\):" $tmpfile_n | sed -n 's@\(^\.\./[/a-zA-Z0-9_.-]*.[ch]\):.*@\1@p' | sort | uniq -c \
    > $tmpfile_fn

  diff -U 0 $tmpfile_fo $tmpfile_fn 1>&2
  rm $tmpfile_fo $tmpfile_fn

  rc=1
fi

rm -rf $tmpdir0 $tmpfile_o $tmpfile_n $tmpfile_b

exit $rc

#!/bin/bash

SCRIPTSDIR="$PWD/scripts"

pushd libs/netclasses
sudo make distclean
./configure
make
sudo ${SCRIPTSDIR}/install.sh
popd

make
sudo ./scripts/install.sh

exit 0

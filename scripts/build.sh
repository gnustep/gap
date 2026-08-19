#!/bin/bash

SCRIPTSDIR="$PWD/scripts"

sudo make distclean

echo "--- build netclasses"
pushd libs/netclasses
sudo make distclean
./configure
make
sudo ${SCRIPTSDIR}/install.sh
popd

echo "--- build everything else"
make
sudo ${SCRIPTSDIR}/install.sh

exit 0

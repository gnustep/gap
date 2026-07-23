#!/bin/sh

pushd libs/netclasses
./configure
popd

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh
make GNUSTEP_INSTALLATION_DOMAIN=LOCAL install

exit 0

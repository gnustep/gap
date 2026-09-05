#!/bin/bash

set -e

cd "$(dirname "$0")/.."

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh

(cd libs/netclasses && ./configure)

INSTALL_DOMAIN="${GNUSTEP_INSTALLATION_DOMAIN:-LOCAL}"

if [ "$INSTALL_DOMAIN" != "USER" ] && [ "$(id -u)" -ne 0 ]; then
  echo "Installing to the $INSTALL_DOMAIN GNUstep domain requires elevated permissions." >&2
  echo "Run this script with sudo, or set GNUSTEP_INSTALLATION_DOMAIN=USER." >&2
  exit 1
fi

make GNUSTEP_INSTALLATION_DOMAIN="$INSTALL_DOMAIN" install

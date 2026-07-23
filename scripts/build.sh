#!/bin/sh

cd libs
sudo make distclean
make
sudo ../scripts/install.sh
cd ..
make
sudo ./scripts/install.sh

exit 0

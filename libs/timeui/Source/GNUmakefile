include $(GNUSTEP_MAKEFILES)/common.make

include ../Version
#include ../config.make


PACKAGE_NAME = timeui
FRAMEWORK_NAME = TimeUI

TimeUI_HEADER_FILES_DIR = ../Headers/TimeUI
TimeUI_HEADER_FILES = TimeUI.h QSTimeControl.h QSTimeClockCell.h

TimeUI_OBJC_FILES = QSTimeControl.m QSTimeClockCell.m

-include GNUmakefile.preamble
-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/framework.make

-include GNUmakefile.postamble

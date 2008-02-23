GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make


PACKAGE_NAME = TimeUIControlsPalette
PALETTE_NAME = TimeUIControls

FRAMEWORKS = TimeUI

TimeUIControls_PALETTE_ICON = TimeUIPaletteIcon

TimeUIControls_OBJC_FILES = TimeUIPalette.m TimeClockInspector.m TimeClockEditor.m

TimeUIControls_PRINCIPAL_CLASS = TimeUIPalette

TimeUIControls_RESOURCE_FILES = \
	TimeUIPaletteIcon.tiff \
	TimeUIPalette.gorm \
	TimeClockInspector.gorm \
	palette.table \

-include GNUmakefile.preamble
-include GNUmakefile.local

TimeUIControls_STANDARD_INSTALL = no

PALETTE_LIBS += -lTimeUI

include $(GNUSTEP_MAKEFILES)/palette.make

-include GNUmakefile.postamble

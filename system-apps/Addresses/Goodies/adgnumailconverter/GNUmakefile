include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME=adgnumailconverter

adgnumailconverter_OBJC_FILES=main.m
adgnumailconverter_LDFLAGS += -L../../Frameworks/Addresses/Addresses.framework \
	-lAddresses
adgnumailconverter_INCLUDE_DIRS = -I../../Frameworks

-include GNUmakefile.preamble
-include GNUmakefile.local
include $(GNUSTEP_MAKEFILES)/tool.make
-include GNUmakefile.postamble

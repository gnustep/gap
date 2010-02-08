

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = TreeDatabase
BUNDLE_EXTENSION = .grrdb

$(BUNDLE_NAME)_STANDARD_INSTALL=no

TreeDatabase_OBJC_FILES = \
	TreeDatabaseComponent.m \

TreeDatabase_HEADERS = \
	TreeDatabaseComponent.h \

TreeDatabase_PRINCIPAL_CLASS = TreeDatabaseComponent


ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../..

include $(GNUSTEP_MAKEFILES)/bundle.make

include ../../GNUmakefile.preamble

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_LIB_DIRS += ../../$(GNUSTEP_OBJ_DIR)/Database.m.o \
		       ../../$(GNUSTEP_OBJ_DIR)/DatabaseElement.m.o \
		       ../../$(GNUSTEP_OBJ_DIR)/Category.m.o \
		       ../../$(GNUSTEP_OBJ_DIR)/PipeType.m.o
endif

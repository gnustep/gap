

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = DatabaseTreeView
BUNDLE_EXTENSION = .grrc

$(BUNDLE_NAME)_STANDARD_INSTALL=no

DatabaseTreeView_OBJC_FILES = \
	DatabaseTreeViewController.m

DatabaseTreeView_HEADERS = \
	DatabaseTreeViewController.h

DatabaseTreeView_PRINCIPAL_CLASS = DatabaseTreeViewController

DatabaseTreeView_LANGUAGES = English German

DatabaseTreeView_LOCALIZED_RESOURCE_FILES = \
	DatabaseTreeViewController.gorm \


ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../..

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble

include ../../GNUmakefile.preamble

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_LIB_DIRS += ../../$(GNUSTEP_OBJ_DIR)/Database.m.o \
		       ../../$(GNUSTEP_OBJ_DIR)/DatabaseElement.m.o \
		       ../../$(GNUSTEP_OBJ_DIR)/Article.m.o \
		       ../../$(GNUSTEP_OBJ_DIR)/ImageTextCell.m.o \
		       ../../$(GNUSTEP_OBJ_DIR)/NumberedImageTextCell.m.o \
		       ../../$(GNUSTEP_OBJ_DIR)/Components.m.o \
		       ../../$(GNUSTEP_OBJ_DIR)/PipeType.m.o
endif

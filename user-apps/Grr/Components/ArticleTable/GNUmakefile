

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = ArticleTable
BUNDLE_EXTENSION = .grrc

$(BUNDLE_NAME)_STANDARD_INSTALL=no

ArticleTable_OBJC_FILES = \
	ArticleTablePlugin.m

ArticleTable_HEADERS = \
	ArticleTablePlugin.h

ArticleTable_PRINCIPAL_CLASS = ArticleTablePlugin

ArticleTable_LANGUAGES = English German

ArticleTable_LOCALIZED_RESOURCE_FILES = \
	ArticleTablePlugin.gorm \


ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../..

include $(GNUSTEP_MAKEFILES)/bundle.make

include ../../GNUmakefile.preamble

ADDITIONAL_INCLUDE_DIRS += -I../../../../libs/

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_LIB_DIRS += ../../$(GNUSTEP_OBJ_DIR)/GNRatingCell.m.o ../../$(GNUSTEP_OBJ_DIR)/PipeType.m.o ../../$(GNUSTEP_OBJ_DIR)/Components.m.o
endif

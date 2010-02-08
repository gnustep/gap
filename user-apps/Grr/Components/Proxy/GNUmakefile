

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = Proxy
BUNDLE_EXTENSION = .grrc

$(BUNDLE_NAME)_STANDARD_INSTALL=no

Proxy_OBJC_FILES = \
	ProxyComponent.m \

Proxy_HEADERS = \
	ProxyComponent.h \


Proxy_PRINCIPAL_CLASS = ProxyComponent

Proxy_LANGUAGES = English German

Proxy_LOCALIZED_RESOURCE_FILES = \
	ProxyComponent.gorm \


ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../..

include $(GNUSTEP_MAKEFILES)/bundle.make

include ../../GNUmakefile.preamble

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_LIB_DIRS += ../../$(GNUSTEP_OBJ_DIR)/PreferencesComponent.m.o \
		       ../../$(GNUSTEP_OBJ_DIR)/Components.m.o
endif

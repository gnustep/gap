#
# GNUmakefile for PictureFrame
#

ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
  ifeq ($(GNUSTEP_MAKEFILES),)
    $(warning )
    $(warning Unable to obtain GNUSTEP_MAKEFILES setting from gnustep-config!)
    $(warning Perhaps gnustep-make is not properly installed,)
    $(warning so gnustep-config is not in your PATH.)
    $(warning )
    $(warning Your PATH is currently $(PATH))
    $(warning )
  endif
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

VERSION=1.1.3

PACKAGE_NAME=$(NAME)
CVS_MODULE_NAME = gap/user-apps/$(NAME)
CVS_TAG_NAME=$(PACKAGE_NAME)
NAME=PictureFrame
APP_NAME=$(NAME)
SUBPROJECTS = SimpleWeather

#$(NAME)_APPLICATION_ICON=icon.tiff
$(NAME)_MAIN_MODEL_FILE=MainMenu.gorm

$(NAME)_LOCALIZED_RESOURCE_FILES=

$(NAME)_LANGUAGES= English 

$(NAME)_RESOURCE_FILES= English.lproj/MainMenu.gorm \
	English.lproj/Preferences.gorm \
	SimpleWeather/SimpleWeather.bundle

$(NAME)_HEADER_FILES= \
ClockView.h \
FrameView.h \
GNUstep.h \
OverlayView.h \
PhotoController.h \
PhotoView.h \
PictureFrameController.h \
PictureWindow.h \
PreferencesController.h

$(NAME)_OBJC_FILES= \
main.m \
ClockView.m \
OverlayView.m \
PhotoController.m \
PhotoView.m \
PictureFrameController.m \
PictureWindow.m \
PreferencesController.m

$(NAME)_C_FILES= 

ADDITIONAL_GUI_LIBS += 

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
include $(GNUSTEP_MAKEFILES)/aggregate.make
-include GNUmakefile.postamble

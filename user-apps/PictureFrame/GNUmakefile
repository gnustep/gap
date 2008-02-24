#
# GNUmakefile for PictureFrame
#
include $(GNUSTEP_MAKEFILES)/common.make

VERSION=1.0.0

PACKAGE_NAME=PictureFrame
CVS_MODULE_NAME = gap/user-apps/PictureFrame
CVS_TAG_NAME=$(PACKAGE_NAME)
APP_NAME=PictureFrame
SUBPROJECTS = SimpleWeather

#PictureFrame_APPLICATION_ICON=icon.tiff
PictureFrame_MAIN_MODEL_FILE=MainMenu.gorm

PictureFrame_LOCALIZED_RESOURCE_FILES=


PictureFrame_LANGUAGES= English 

PictureFrame_RESOURCE_FILES= English.lproj/MainMenu.gorm \
	English.lproj/Preferences.gorm \
	SimpleWeather/SimpleWeather.bundle

PictureFrame_HEADER_FILES= \
ClockView.h \
FrameView.h \
GNUstep.h \
OverlayView.h \
PhotoController.h \
PhotoView.h \
PictureFrameController.h \
PictureWindow.h \
PreferencesController.h

PictureFrame_OBJC_FILES= \
main.m \
ClockView.m \
OverlayView.m \
PhotoController.m \
PhotoView.m \
PictureFrameController.m \
PictureWindow.m \
PreferencesController.m

PictureFrame_C_FILES= 

ADDITIONAL_GUI_LIBS += 

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
include $(GNUSTEP_MAKEFILES)/aggregate.make
-include GNUmakefile.postamble

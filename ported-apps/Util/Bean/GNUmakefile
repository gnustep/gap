# Build with GNUstep Make (source GNUstep.sh first if it is not on PATH).
ifeq ($(strip $(GNUSTEP_MAKEFILES)),)
GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif
ifeq ($(strip $(GNUSTEP_MAKEFILES)),)
$(error GNUstep Make was not found. Install gnustep-make and source GNUstep.sh)
endif

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Bean
Bean_OBJC_FILES = main.m MyDocument.m PageView.m JHScrollView.m \
    InspectorController.m PrefWindowController.m JHLayoutManager.m \
    KBWordCountingTextStorage.m ServicesObject.m Controller.m \
    EncodeRTFwithPictures.m NSCursorExtensions.m JHScroller.m \
    JHDocumentController.m
Bean_RESOURCE_FILES = defaults.plist $(wildcard *.icns) \
    $(filter-out TBUndoItemImage original.tiff,$(wildcard *.tiff)) \
    $(wildcard *.tif)
# Copy the complete localization directory, preserving nib directories and help.
Bean_LANGUAGES = English
Bean_LOCALIZED_RESOURCE_FILES = MainMenu.nib MyDocument.nib MarginSheet.nib \
    LinkSheet.nib Inspector.nib Localizable.strings InfoPlist.strings \
    ServicesMenu.strings Credits.rtf
Bean_MAIN_MODEL_FILE = MainMenu.nib
Bean_APPLICATION_ICON = icn-beanapp.icns
Bean_PLIST = BeanInfo.plist

include $(GNUSTEP_MAKEFILES)/application.make

after-all::
	mkdir -p "$(GNUSTEP_BUILD_DIR)/Bean.app/Resources/English.lproj/Bean Help"
	cp -R "English.lproj/Bean Help/." "$(GNUSTEP_BUILD_DIR)/Bean.app/Resources/English.lproj/Bean Help/"

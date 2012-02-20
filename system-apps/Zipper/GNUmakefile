include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Zipper
PACKAGE_NAME = Zipper
VERSION = 1.4

Zipper_APPLICATION_ICON = zipper.tiff
ADDITIONAL_GUI_LIBS += 

Zipper_RESOURCE_FILES = \
	Resources/MainMenu.gorm \
	Resources/Preferences.gorm \
	Resources/ZipperDocument.gorm \
	Resources/FileIcon.tiff \
	Resources/no_order.tiff \
	Resources/sort_ascending.tiff \
	Resources/sort_descending.tiff \
	Resources/zipper.tiff

Zipper_OBJC_FILES = \
	AppDelegate.m \
	Archive.m \
	ArchiveService.m\
    FileInfo.m \
    GzipArchive.m\
	LhaArchive.m\
	LzxArchive.m\
	main.m \
	NSArray+Custom.m\
	NSFileManager+Custom.m\
	NSObject+Custom.m \
    NSString+Custom.m \
	Preferences.m\
	PreferencesController.m\
	RarArchive.m\
	SevenZipArchive.m\
	TableViewDataSource.m\
	TarArchive.m\
	ZipArchive.m\
	ZipperCell.m\
	ZipperDocument.m

Zipper_HEADER_FILES = \
	AppDelegate.h \
	Archive.h \
	ArchiveService.h\
	config.h \
    FileInfo.h \
    GzipArchive.h\
	LhaArchive.h\
	LzxArchive.h\
	NSArray+Custom.h\
	NSFileManager+Custom.h\
	NSObject+Custom.h \
    NSString+Custom.h \
	Preferences.h\
	PreferencesController.h\
	RarArchive.h\
	SevenZipArchive.h\
	TableViewDataSource.h\
	TarArchive.h\
	ZipArchive.h\
	ZipperCell.h\
	ZipperDocument.h

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble

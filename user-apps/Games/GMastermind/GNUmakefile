
include $(GNUSTEP_MAKEFILES)/common.make

# The application to be compiled
APP_NAME = GMastermind

# The Objective-C source files to be compiled

GMastermind_OBJC_FILES = main.m  \
  Controller.m \
  Views.m


GMastermind2_LOCALIZED_RESOURCE_FILES = Localizable.strings

GMastermind2_LANGUAGES = French 


SHARED_CFLAGS     += -g

# The Resource files to be copied into the app's resources directory
GMastermind_RESOURCE_FILES = Resources/*

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/application.make

-include GNUmakefile.postamble


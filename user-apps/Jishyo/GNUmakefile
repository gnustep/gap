include $(GNUSTEP_MAKEFILES)/common.make

NAME = Jishyo

PACKAGE_NAME = $(NAME)
VERSION = 0.1

APP_NAME = $(NAME) 
$(NAME)_APPLICATION_ICON = Jishyo.tiff
$(NAME)_MAIN_MODEL_FILE = Jishyo.nib 

$(NAME)_OBJC_FILES = \
Controller.m \
Dictionary.m \
main.m

$(NAME)_C_FILES = \
externs.c \
xjdcomm.c \
xjdsa.c \
xjdservcomm.c

ifeq ($(FOUNDATION_LIB), apple)
  $(NAME)_RESOURCE_FILES = Resources/Shared/* Resources/MacOS/*
else
  $(NAME)_RESOURCE_FILES = Resources/Shared/* Resources/GNUstep/*
endif
		
ADDITIONAL_OBJCFLAGS = -Wall

ADDITIONAL_CFLAGS = -DXJDDIC -DMMAP

-include GNUmakefile.preamble
-include GNUmakefile.local
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble


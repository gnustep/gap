#
# GNUmakefile - Generated by ProjectCenter
#
ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif
ifeq ($(GNUSTEP_MAKEFILES),)
 $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

#
# Application
#
VERSION = 0.7
PACKAGE_NAME = Sudoku
APP_NAME = Sudoku
Sudoku_APPLICATION_ICON = Sudoku.tiff


#
# Resource files
#
Sudoku_RESOURCE_FILES = \
Resources/Sudoku.tiff \


#
# Header files
#
Sudoku_HEADER_FILES = \
Controller.h \
DigitSource.h \
Document.h \
Sudoku.h \
SudokuView.h

#
# Class files
#
Sudoku_OBJC_FILES = \
Controller.m \
DigitSource.m \
Document.m \
Sudoku.m \
SudokuView.m

#
# Other sources
#
Sudoku_OBJC_FILES += \
main.m 

#
# Makefiles
#
-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble

#
#  Test apps makefile for GNUstep X/RAW GUI Backend
#
#  Copyright (C) 1997 Free Software Foundation, Inc.
#
#  Author: Scott Christley <scottc@net-community.com>
#  Author: Felipe A. Rodriguez <far@ix.netcom.com>
#
#  This file is part of the GNUstep X/RAW GUI Backend.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  Library General Public License for more details.
#
#  If you are interested in a warranty or support for this source code,
#  contact Scott Christley at scottc@net-community.com
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; see the file COPYING.LIB.
#  If not, write to the Free Software Foundation,
#  59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

TimeMon_MAIN_MODEL_FILE = TimeMon.gorm
TimeMon_APPLICATION_ICON = icon.png

include $(GNUSTEP_MAKEFILES)/common.make

# The application to be compiled
APP_NAME = TimeMon

ADDITIONAL_OBJCFLAGS += -Wall

# The Objective-C source files to be compiled
TimeMon_OBJC_FILES = \
Percentages.m \
TimeMonColors.m \
TimeMon_main.m \
TimeMonWraps.m

TimeMon_C_FILES = \
loadave.c

# The Resource files to be copied into the app's resources directory
TimeMon_RESOURCE_FILES = \
English.lproj/TimeMon.gorm \
icon.png \
TimeMonP.png

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
include $(GNUSTEP_MAKEFILES)/aggregate.make
-include GNUmakefile.postamble


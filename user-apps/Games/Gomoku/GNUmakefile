#   GNUmakefile: makefile for Gomoku.app
#
#   Copyright (C) 2000 Nicola Pero <n.pero@mi.flashnet.it>
#
#   Author:  Nicola Pero <n.pero@mi.flashnet.it>
#   Date: April 2000
#   
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#   
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = Gomoku
PACKAGE_VERSION = 1.2.9

APP_NAME = Gomoku
Gomoku_OBJC_FILES = \
  Board.m \
  Controller.m \
  main.m 
Gomoku_HEADERS = \
  Board.h \
  Controller.h
Gomoku_RESOURCE_FILES = \
  Empty.png \
  EmptyLeft.png \
  EmptyRight.png \
  EmptyTop.png \
  EmptyBottom.png \
  EmptyTopLeft.png \
  EmptyTopRight.png \
  EmptyBottomLeft.png \
  EmptyBottomRight.png \
  Computer.png \
  ComputerLeft.png \
  ComputerRight.png \
  ComputerTop.png \
  ComputerBottom.png \
  ComputerTopLeft.png \
  ComputerTopRight.png \
  ComputerBottomLeft.png \
  ComputerBottomRight.png \
  Human.png \
  HumanLeft.png \
  HumanRight.png \
  HumanTop.png \
  HumanBottom.png \
  HumanTopLeft.png \
  HumanTopRight.png \
  HumanBottomLeft.png \
  HumanBottomRight.png \
  Gomoku.png

Gomoku_LANGUAGES = \
  English \
  Italian \
  French \
  Swedish \
  Spanish \
  German \
  TraditionalChinese \
  Hungarian \
  Norwegian

Gomoku_LOCALIZED_RESOURCE_FILES = Localizable.strings

include $(GNUSTEP_MAKEFILES)/application.make

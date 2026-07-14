# GNUmakefile - this file is part of Cynthiune
#
# Copyright (C) 2003-2006  Wolfgang Sourdeau
#
# Author: Wolfgang Sourdeau <wolfgang@contre.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.
#

PKG_CONFIG ?= pkg-config

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

#optional file to include your setup
-include bundle_config.make

pkg_config_package_exists = $(shell $(PKG_CONFIG) --exists $(1) >/dev/null 2>&1 && echo yes)

ifneq (mingw32,$(GNUSTEP_TARGET_OS))
HAVE_AUDIOFILE = $(call pkg_config_package_exists,audiofile)
HAVE_ALSA = $(call pkg_config_package_exists,alsa)
HAVE_AO = $(if $(wildcard /usr/include/ao/ao.h /usr/local/include/ao/ao.h),yes)
HAVE_AVIFILE = $(if $(wildcard /usr/include/avifile.h /usr/local/include/avifile.h),yes)
HAVE_ESD = $(if $(wildcard /usr/include/esd.h /usr/local/include/esd.h),yes)
HAVE_FLAC = $(call pkg_config_package_exists,flag)
HAVE_ID3TAG = $(call pkg_config_package_exists,id3tag)
HAVE_MAD = $(call pkg_config_package_exists,mad)
HAVE_MODPLUG = $(if $(wildcard /usr/include/modplug.h /usr/include/libmodplug/modplug.h /usr/local/include/modplug.h /usr/local/include/libmodplug/modplug.h),yes)
HAVE_MUSEPACK = $(if $(wildcard /usr/include/mpcdec/mpcdec.h /usr/include/mpc/mpcdec.h /usr/local/include/mpcdec/mpcdec.h /usr/local/include/mpc/mpcdec.h),yes)
HAVE_OSS = $(if $(wildcard /usr/include/soundcard.h /usr/include/sys/soundcard.h /usr/local/include/soundcard.h /usr/local/include/sys/soundcard.h),yes)
HAVE_TAGLIB = $(call pkg_config_package_exists,taglib_c)
HAVE_VORBIS = $(call pkg_config_package_exists,vorbisfile)
endif

FRAMEWORKS_DIRS = Frameworks/Cynthiune
FRAMEWORKS = Cynthiune

#
# Subprojects
#

BUNDLES =

ifneq (yes,$(disable-bundles))
ifneq (yes,$(disable-mp3))
ifeq (mingw32,$(GNUSTEP_TARGET_OS))
BUNDLES += MP3
else ifeq (yes,$(HAVE_MAD))
ifeq (yes,$(HAVE_ID3TAG))
BUNDLES += MP3
endif
endif

ifneq (yes,$(disable-id3tag))
ifeq (mingw32,$(GNUSTEP_TARGET_OS))
BUNDLES += ID3Tag
else ifeq (yes,$(HAVE_ID3TAG))
BUNDLES += ID3Tag
endif
endif

endif

ifneq (yes,$(disable-ogg))
ifeq (mingw32,$(GNUSTEP_TARGET_OS))
BUNDLES += Ogg
else ifeq (yes,$(HAVE_VORBIS))
BUNDLES += Ogg
endif

ifneq (yes,$(disable-vorbistags))
ifeq (mingw32,$(GNUSTEP_TARGET_OS))
BUNDLES += VorbisTags
else ifeq (yes,$(HAVE_VORBIS))
BUNDLES += VorbisTags
endif
endif

endif

ifneq (yes,$(disable-audiofile))
ifeq (mingw32,$(GNUSTEP_TARGET_OS))
BUNDLES += AudioFile
else ifeq (yes,$(HAVE_AUDIOFILE))
BUNDLES += AudioFile
endif
endif

ifneq (yes,$(disable-flac))
ifeq (mingw32,$(GNUSTEP_TARGET_OS))
BUNDLES += FLAC
else ifeq (yes,$(HAVE_FLAC))
BUNDLES += FLAC
endif

ifneq (yes,$(disable-flactags))
ifeq (mingw32,$(GNUSTEP_TARGET_OS))
BUNDLES += FLACTags
else ifeq (yes,$(HAVE_FLAC))
BUNDLES += FLACTags
endif
endif

endif

ifneq (yes,$(disable-mod))
ifeq (mingw32,$(GNUSTEP_TARGET_OS))
BUNDLES += Mod ModTags
else ifeq (yes,$(HAVE_MODPLUG))
BUNDLES += Mod ModTags
endif
endif

ifneq (yes,$(disable-windowsmedia))
ifeq (mingw32,$(GNUSTEP_TARGET_OS))
BUNDLES += WindowsMedia
else ifeq (yes,$(HAVE_AVIFILE))
BUNDLES += WindowsMedia
endif
endif

ifneq (yes,$(disable-musepack))
ifeq (mingw32,$(GNUSTEP_TARGET_OS))
BUNDLES += Musepack
else ifeq (yes,$(HAVE_MUSEPACK))
BUNDLES += Musepack
endif
endif

ifneq (yes,$(disable-timidity))
BUNDLES += Timidity
endif
ifneq (yes,$(disable-taglib))
ifeq (mingw32,$(GNUSTEP_TARGET_OS))
BUNDLES += Taglib
else ifeq (yes,$(HAVE_TAGLIB))
BUNDLES += Taglib
endif
endif

ifneq (yes,$(disable-asftags))
BUNDLES += ASFTags
endif

ifeq (mingw32,$(GNUSTEP_TARGET_OS))

ifneq (yes,$(disable-waveout))
BUNDLES += WaveOut
endif

else

# GNUSTEP_TARGET_OS is defined to `linux-gnueabi' on armel and
# `linux-gnuspe' on powerpcspe.
ifneq (,$(findstring linux-gnu,$(GNUSTEP_TARGET_OS)))

ifneq (yes,$(disable-alsa))
ifeq (yes,$(HAVE_ALSA))
BUNDLES += ALSA
disable-esound=yes
disable-ao=yes
endif
endif

endif

ifneq (yes,$(disable-oss))
ifeq (yes,$(HAVE_OSS))
BUNDLES += OSS
endif
endif

# sndio is OpenBSD only
ifeq ($(findstring openbsd, $(GNUSTEP_TARGET_OS)), openbsd)
ifneq (yes,$(disable-sndio))
BUNDLES += Sndio
endif
endif

ifneq (yes,$(disable-esound))
ifeq (yes,$(HAVE_ESD))
BUNDLES += Esound
endif
endif

ifneq (yes,$(disable-ao))
ifeq (yes,$(HAVE_AO))
BUNDLES += AO
endif
endif

# disable arts by default, rarely used
ifeq (yes,$(enable-arts))
BUNDLES += aRts
endif

endif

endif

SUBPROJECTS = Frameworks/Cynthiune $(addprefix Bundles/,$(BUNDLES))

#
# Main application
#

PACKAGE_NAME=Cynthiune
APP_NAME=Cynthiune
VERSION=1.0.0

Cynthiune_APPLICATION_ICON=Cynthiune.tiff
Cynthiune_MAIN_MODEL_FILE=Cynthiune.gorm
Cynthiune_LANGUAGES= \
Armenian English French German Hungarian Italian \
Slovak Spanish TraditionalChinese
Cynthiune_LOCALIZED_RESOURCE_FILES=Localizable.strings

#
# Additional libraries
#

ADDITIONAL_GUI_LIBS +=

#
# Resource files
#

NIB_FILES = \
Cynthiune.gorm \
GeneralPreference.gorm \
Preferences.gorm \
SongInspector.gorm

buttons_IMAGE_FILES = \
Images/add.tiff \
Images/cleanup.tiff \
Images/eject.tiff \
Images/eject-pushed.tiff \
Images/next.tiff \
Images/next-pushed.tiff \
Images/pause.tiff \
Images/pause-pushed.tiff \
Images/play.tiff \
Images/play-pushed.tiff \
Images/playlist.tiff \
Images/playlist-pushed.tiff \
Images/previous.tiff \
Images/previous-pushed.tiff \
Images/remove.tiff \
Images/repeat.tiff \
Images/repeat-pushed.tiff \
Images/save-as.tiff \
Images/shuffle.tiff \
Images/shuffle-pushed.tiff \
Images/song-inspector.tiff \
Images/song-inspector-pushed.tiff \
Images/stop.tiff \
Images/stop-pushed.tiff

Cynthiune_RESOURCE_FILES= \
Images/Cynthiune.tiff \
Images/Cynthiune-song-48.tiff \
Images/Cynthiune-playlist-48.tiff \
Images/cynthiune-splash.tiff \
Images/cynthiune-splash-faded.tiff \
Images/anim-logo-1.tiff \
Images/anim-logo-2.tiff \
Images/anim-logo-3.tiff \
Images/anim-logo-4.tiff \
Images/anim-logo-5.tiff \
Images/anim-logo-6.tiff \
Images/anim-logo-7.tiff \
Images/anim-logo-8.tiff \
Images/lock.tiff \
Images/lookup-mb-on.tiff \
Images/lookup-mb-off.tiff \
Images/dragged-song.tiff \
Images/dragged-songs.tiff \
Images/slider-knob-disabled.tiff \
Images/slider-knob-enabled.tiff \
Images/song-pointer.tiff \
Images/common_ToolbarSeparatorItem.tiff \
$(buttons_IMAGE_FILES) \
$(NIB_FILES) \
COPYING

#
# Header files
#

Cynthiune_HEADERS= \
BundleManager.h \
CynthiuneAnimatedImageView.h \
CynthiuneController.h \
CynthiuneFadingTextField.h \
CynthiuneHeaderCell.h \
CynthiunePauseButton.h \
CynthiunePopUpButton.h \
CynthiuneSliderCell.h \
CynthiuneSongTitleCell.h \
CynthiuneTextCell.h \
CynthiuneWindow.h \
DictionaryCoder.h \
FormatTester.h \
GeneralPreference.h \
InfoDisplayController.h \
M3UArchiver.h \
MBResultsPanel.h \
Player.h \
PlayerController.h \
PlayerPreference.h \
Playlist.h \
PlaylistArchiver.h \
PlaylistController.h \
PlaylistView.h \
PlaylistViewController.h \
PLSArchiver.h \
PreferencesController.h \
Song.h \
SongInspectorController.h

#
# Class files
#

Cynthiune_OBJC_FILES= \
main.m \
BundleManager.m \
CynthiuneAnimatedImageView.m \
CynthiuneController.m \
CynthiuneFadingTextField.m \
CynthiuneHeaderCell.m \
CynthiunePauseButton.m \
CynthiunePopUpButton.m \
CynthiuneSliderCell.m \
CynthiuneSongTitleCell.m \
CynthiuneTextCell.m \
CynthiuneWindow.m \
DictionaryCoder.m \
FormatTester.m \
GeneralPreference.m \
InfoDisplayController.m \
M3UArchiver.m \
MBResultsPanel.m \
Player.m \
PlayerController.m \
PlayerPreference.m \
Playlist.m \
PlaylistArchiver.m \
PlaylistController.m \
PlaylistView.m \
PlaylistViewController.m \
PLSArchiver.m \
PreferencesController.m \
Song.m \
SongInspectorController.m

ifeq (yes,$(enable-goom))
Cynthiune_OBJC_FILES += GoomView.m
endif

ADDITIONAL_INCLUDE_DIRS += -IFrameworks

include frameworks.make

-include GNUmakefile.preamble
-include GNUmakefile.local
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble

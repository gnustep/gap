
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

PACKAGE_NAME=TalkSoup
VERSION=1.1

SVN_BASE_URL = svn+ssh://svn.savannah.nongnu.org/gap/user-apps
SVN_MODULE_NAME = TalkSoup

ifneq ($(USE_DMALLOC),)
ADDITIONAL_OBJCFLAGS += -include stdlib.h -include dmalloc.h
ADDITIONAL_LDFLAGS += -ldmalloc
endif

ifeq ($(USE_APPKIT),)
USE_APPKIT = yes
endif

ifneq ($(USE_APPKIT),yes)
USE_APPKIT = no
endif

export ADDITIONAL_LDFLAGS
export ADDITIONAL_OBJCFLAGS
export USE_APPKIT

SUBPROJECTS = TalkSoupBundles Source Input Output InFilters OutFilters

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
-include GNUmakefile.postamble

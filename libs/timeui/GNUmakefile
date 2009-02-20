PACKAGE_NEEDS_CONFIGURE = YES

SVN_MODULE_NAME = timeui
SVN_BASE_URL = svn+ssh://svn.gna.org/svn/garma/cosmetic/frameworks

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = timeui
FRAMEWORK_NAME = TimeUIModule

include ./Version

SUBPROJECTS = \
Source \
TestTimeUI \

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/aggregate.make

-include GNUmakefile.postamble

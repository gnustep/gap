include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = VCFViewer
BUNDLE_EXTENSION = .inspector

VCFViewer_HAS_RESOURCE_BUNDLE = yes

VCFViewer_OBJCFLAGS += -Wall
VCFViewer_LDFLAGS += -lInspector -lAddresses -lAddressView

VCFViewer_OBJC_FILES = VCFViewer.m 
VCFViewer_PRINCIPAL_CLASS = VCFViewer
VCFViewer_RESOURCE_FILES = InspectorInfo.plist VCFImage.tiff

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble

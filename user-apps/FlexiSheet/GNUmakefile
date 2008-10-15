#
#  Functions
#
#  Copyright (C) 2008 Free Software Foundation, Inc.
#
#   Written by: Fred Kiefer <FredKiefer@gmx.de>
#   Created: July 2008
#
#  This file is part of FlexiSheet.
#

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = FlexiSheet
VERSION = 0.5.7

# The application to be compiled
APP_NAME = FlexiSheet

FlexiSheet_SUBPROJECTS = \
FSCore \
Functions \
Operators \
Application 


OBJCFLAGS += -Wall -ICore -IFunctions -IOperators 

FlexiSheet_OBJC_FILES = \

FlexiSheet_HEADER_FILE = \

#FlexiSheet_PRINCIPAL_CLASS = 

# The Resource files to be copied into the app's resources directory
FlexiSheet_RESOURCE_FILES = \
Images/AlertIcon.tiff             Images/TBRedo.tiff \
Images/Application.icns           Images/TBRevert.tiff \
Images/BlackLeftArrow.tiff        Images/TBSaveDocument.tiff \
Images/BlackRightArrow.tiff       Images/TBUndo.tiff \
Images/ChartSmIcon.tiff           Images/TB_Documents.tiff \
Images/ClosedGrabHandCursor.tiff  Images/TB_Lock_0.tiff \
Images/CornerMenu.tiff            Images/TB_Lock_1.tiff \
Images/Document.icns              Images/TB_Settings.tiff \
Images/FTEqualSign.tiff           Images/TB_Stop.tiff \
Images/FTIfBlock.tiff             Images/TViewSmIcon.tiff \
Images/FormulaError.tiff          Images/TableSmIcon.tiff \
Images/FormulaOK.tiff             Images/VertResizeCursor.tiff \
Images/FormulaWarning.tiff        Images/centeralign_nib.tiff \
Images/HorzResizeCursor.tiff      Images/fingerCursor.tiff \
Images/OpenGrabHandCursor.tiff    Images/justifyalign_nib.tiff \
Images/Quantrix.icns              Images/ldock-6.tiff \
Images/Sheet.icns                 Images/leftalign_nib.tiff \
Images/Splash.png                 Images/lempty-6.tiff \
Images/TBAttach.tiff              Images/mdock-6.tiff \
Images/TBDelete.tiff              Images/mempty-6.tiff \
Images/TBEdit.tiff                Images/naturalalign_nib.tiff \
Images/TBFind.tiff                Images/rdock-6.tiff \
Images/TBFormula.tiff             Images/rempty-6.tiff \
Images/TBInspect.tiff             Images/rightalign_nib.tiff \
Images/TBRecalc.tiff              Images/splimg.png


FlexiSheet_LOCALIZED_RESOURCE_FILES =
FlexiSheet_MAIN_MODEL_FILE = MainMenu.nib

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make

-include GNUmakefile.postamble

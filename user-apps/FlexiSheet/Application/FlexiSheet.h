//  $Id: FlexiSheet.h,v 1.2 2008/12/15 14:44:25 rmottola Exp $
//
//  FlexiSheet.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 09-MAY-2002.
//

// Based on Apple's cool Cocoa frameworks
#import <Cocoa/Cocoa.h>

#define FS_LOCALIZE(__STRG__) [[NSBundle mainBundle] localizedStringForKey:(__STRG__) value:@"" table:nil]

// FlexiSheet core
#import <FSCore/FSCore.h>
#import <FSCore/FoundationExtentions.h>
#import <FSCore/FSParserFunctions.h>

// Application structure (Scriptable)
#import "FSController.h"
#import "FSDocument.h"
#import "FSWorksheet.h"
#import "FSTableController.h"
#import "FSChartController.h"

// Protocols
#import "FSPasteboardHandling.h"
#import "FSInspection.h"
#import "FSMatrixDataSource.h"

// GUI
#import "FSFormulaTable.h"
#import "FSHeaderDock.h"
#import "FSTableTabs.h"
#import "FSTableView.h"
#import "FSMatrix.h"
#import "FSVarioMatrix.h"
#import "FSCellStyle.h"

// GUI helpers
#import "SLFloatingMark.h"
#import "ImageAndTextCell.h"
#import "FSHeaderLayout.h"

// AppleScript support
// No header files yet

//#define FSActiveDocumentChangedNotification @"FSActiveDocumentChangedNotification"

/* Function Replacements */
#ifdef __MINGW__
#define bzero(s, n) memset ((s), 0, (n))
#endif

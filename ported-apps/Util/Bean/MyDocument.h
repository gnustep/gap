/*
  MyDocument.h
  Bean

  Created 11 JUL 2006 by JH.
  Copyright (c) 2007 James Hoover

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

//add category that encodes RTF with pictures
//courtesy of Keith Blount, coder of Scrivener

#import <Cocoa/Cocoa.h>
#import "PageView.h"
#import "JHScrollView.h"
#import "InspectorController.h"
#import "JHLayoutManager.h"
#import "KBWordCountingTextStorage.h"
#import "ServicesObject.h"
#import "PrefWindowController.h"
#import "EncodeRTFwithPictures.h"

@interface MyDocument : NSDocument
{
	//objects
	JHLayoutManager *layoutManager;
	KBWordCountingTextStorage *textStorage;
	ServicesObject *servicesObject;
	NSSpellChecker *spellChecker;
	NSAttributedString *loadedText;
	NSDictionary *altTextColor;
	NSColor *backgroundColor;
	NSString *newLineChar;
	NSPrintInfo *printInfo;
	NSDictionary *options;
	NSMutableDictionary *docAttributes;
	NSColor *textViewTextColor;
	NSColor *textViewBackgroundColor;
	NSTimer *autosaveTimer;
	NSAlert *alertSheet;
	NSString *currentFileType;
	NSDate *fileModDate;
	NSString *originalFileName;
	NSString *docEncodingString;
	NSDictionary *hfsFileAttributes;
	NSNumberFormatter *thousandFormatter;
	
	//variables
	int numberOfWords;
	int words;
	int numberOfChars;
	unsigned int smartQuotesStyleTag;
	unsigned docEncoding;
	unsigned int savedEditLocation;
	unsigned int linkPrefixTag;
	float viewWidth;
	float viewHeight;
	float pageSeparatorLength;
	float lineFragPosYSave;
	float pointsPerUnitAccessor;
	
	NSSize imageSize;
	
	//outlets
	IBOutlet NSWindow *docWindow;
	IBOutlet JHScrollView *theScrollView;
	IBOutlet NSTextField *wordCountField;
	IBOutlet NSTextField *charCountField;
	IBOutlet NSTextField *charCountMinusSpacesField;
	IBOutlet NSTextField *selWordCountField;
	IBOutlet NSTextField *selCharCountField;
	IBOutlet NSPanel *infoSheet;
	IBOutlet NSSlider *zoomSlider;
	IBOutlet NSPanel *zoomSliderWindow;
	IBOutlet NSTextField *zoomAmt;
	IBOutlet NSTextField *pageCountField;
	IBOutlet NSButton *liveWordCountButton;
	IBOutlet NSTextView *condensedTextView;
	IBOutlet NSTextField *lineCountField;
	IBOutlet NSTextField *paragraphCountField;
	IBOutlet NSTextField *lineFragCountField;
	IBOutlet NSTextField *liveWordCountField;
	IBOutlet NSWindow *printMarginSheet;
	IBOutlet NSTextField *tfLeftMargin;
	IBOutlet NSTextField *tfRightMargin;
	IBOutlet NSTextField *tfTopMargin;
	IBOutlet NSTextField *tfBottomMargin;
	IBOutlet NSTextField *measurementUnitTextField;
	IBOutlet NSTextView *liveWordCountTextField;
	IBOutlet NSDictionary *oldAttributes;
	IBOutlet NSPanel *inspectorPanel;
	IBOutlet NSSlider *characterSpacingSlider;
	IBOutlet NSTextField *characterSpacingTextField;
	IBOutlet NSStepper *characterSpacingStepper;
	IBOutlet NSSlider *interlineSpacingSlider;
	IBOutlet NSTextField *interlineSpacingTextField;
	IBOutlet NSStepper *interlineSpacingStepper;
	IBOutlet NSSlider *multipleSpacingSlider;
	IBOutlet NSTextField *multipleSpacingTextField;
	IBOutlet NSStepper *multipleSpacingStepper;
	IBOutlet NSSlider *beforeParagraphSpacingSlider;
	IBOutlet NSTextField *beforeParagraphSpacingTextField;
	IBOutlet NSStepper *beforeParagraphSpacingStepper;
	IBOutlet NSWindow *linkSheet;	
	IBOutlet NSTextField *linkTextField;
	IBOutlet NSMatrix *linkTypeMatrix;
	IBOutlet NSTextField *linkPrefixTextField;
	IBOutlet NSButton *applyLink;
	IBOutlet NSButton *cancelLink;
	IBOutlet NSMatrix *linkSelectMatrix;
	IBOutlet NSTextField *richTextFontField;
	IBOutlet NSPanel *tabStopPanel;
	IBOutlet NSButton *tabStopAlignmentButton;
	IBOutlet NSButton *removeTabStopsButton;
	IBOutlet NSTextField *tabStopValueField;
	IBOutlet NSTextField *tabStopValueLabel;
	IBOutlet InspectorController *inspectorController;
	IBOutlet NSButton *lockedFileButton;
	IBOutlet NSTextField *lockedFileLabel;
	IBOutlet NSButton *readOnlyButton;
	IBOutlet NSButton *backupAutomaticallyButton;
	IBOutlet NSTextField *backupAutomaticallyLabel;
	IBOutlet NSButton *doAutosaveButton;
	IBOutlet NSTextField *doAutosaveTextField;
	IBOutlet NSStepper *doAutosaveStepper;
	IBOutlet NSTextField *doAutosaveLabel;
	IBOutlet NSButton *revealFileInFinderButton;
	IBOutlet NSPanel *encodingSheet;
	IBOutlet NSPopUpButton *encodingPopup;
	IBOutlet NSButton *encodingOKButton;
	IBOutlet NSButton *encodingCancelButton;
	IBOutlet NSTextView *encodingPreviewTextView;
	IBOutlet NSTextField *infoSheetEncoding;
	IBOutlet NSTextField *infoSheetEncodingButton;
	IBOutlet NSBox *infoSheetEncodingBox;
	IBOutlet NSTextField *propsAuthor;
	IBOutlet NSTextField *propsCompany;
	IBOutlet NSTextField *propsCopyright;
	IBOutlet NSTextField *propsTitle;
	IBOutlet NSTextField *propsSubject;
	IBOutlet id propsKeywords;
	IBOutlet NSTextField *propsComment;
	IBOutlet NSTextField *propsEditor;
	IBOutlet NSPanel *propertiesSheet;
	IBOutlet NSImageView *floatImage;
	IBOutlet NSPopUpButton *defaultLineSpacingPopUpButton;
	IBOutlet NSTextField *defaultFirstLineIndentTextField;
	IBOutlet NSButton *defaultIsMetric;
	IBOutlet id rangeLabel;
	IBOutlet NSPanel *imageSheet;
	IBOutlet NSSlider *imageSlider;
	IBOutlet NSTextField *imageSliderTextField;
	IBOutlet id pageUpButton;
	IBOutlet id pageDownButton;
	
	//bools
	BOOL isDocumentSaved;
	BOOL restoreShowInvisibles;
	BOOL isFloating;
	BOOL shouldUseAltTextColors;
	BOOL restoreAltTextColors;
	BOOL shouldDoLiveWordCount;	
	BOOL hasMultiplePages;
	BOOL isRTFForWord;
	BOOL areRulersVisible;
	BOOL isTerminatingGracefully;
	BOOL isTransientDocument;
	BOOL shouldFadeInWindow;
	BOOL shouldRestorePageViewAfterPrinting;
	BOOL shouldShowHorizontalScroller;
	BOOL createDatedBackup;
	BOOL needsDatedBackup;
	BOOL doAutosave;
	BOOL autosaveUntitledDocs;
	BOOL isFadingIn;
	BOOL shouldCheckForGraphics;
	BOOL showMarginsGuide;
	BOOL shouldForceInspectorUpdate;
	BOOL isLossy;
	BOOL readOnlyDoc;
	BOOL isDirty;
	BOOL shouldConstrainScroll;
	BOOL shouldUseSmartQuotes;
	BOOL registerUndoThroughShouldChange;
	BOOL needsAutosave;
	
	unichar SINGLE_OPEN_QUOTE;
	unichar SINGLE_CLOSE_QUOTE;
	unichar DOUBLE_OPEN_QUOTE;
	unichar DOUBLE_CLOSE_QUOTE;
}

/* object accessors */
-(JHLayoutManager *)layoutManager;
-(KBWordCountingTextStorage *)textStorage;
-(NSTextView *)firstTextView;
/* NSDoc and NSWindow stuff */
-(BOOL)isTerminatingGracefully;
-(void)setIsTerminatingGracefully:(BOOL)flag;
-(BOOL)isTransientDocument;
-(void)setIsTransientDocument:(BOOL)flag;
//saving...
-(IBAction)revertDocumentToSaved:(id)sender;
-(void)setDocEdited:(BOOL)flag;
-(BOOL)isDirty;
//backup...
-(BOOL)createDatedBackup;
-(void)setCreateDatedBackup:(BOOL)flag;
-(IBAction)backupDocumentAction:(id)sender;
-(BOOL)backupDocument;
-(BOOL)needsDatedBackup;
-(void)setNeedsDatedBackup:(BOOL)flag;
-(IBAction)backupDocumentAtQuitAction:(id)sender;
//autosaving...
-(BOOL)doAutosave;
-(void)setDoAutosave:(BOOL)flag;
-(void)beginAutosavingDocument;
-(IBAction)saveTheDocument:(id)sender;
- (BOOL)needsAutosave;
- (void)setNeedsAutosave:(BOOL)flag;
-(IBAction)startAndStopAutosaveAction:(id)sender;
-(void)autosaveDocument: (NSTimer *)theTimer;
//exporting
-(IBAction)exportToHTML:(id)sender;
-(IBAction)saveRTFwithPictures:(id)sender;
//check if externally edited
-(void)setFileModDate:(NSDate *)date;
-(NSDate *)fileModDate;
-(BOOL)isEditedExternally;
//using locked files and stationary pads as templates
-(void)setOriginalFileName:(NSString*)aFileName;
-(NSString *)originalFileName;
-(BOOL)isStationaryPad:(NSString *)path;
//save problem alert delegate methods
-(BOOL)checkBeforeSaveWithContextInfo:(void *)contextInfo isClosing:(BOOL)flag;
//errorRecovery
-(void)didPresentErrorWithRecovery:(BOOL)didRecover contextInfo:(void *)contextInfo;
//HFSFileAttribute methods
-(NSDictionary *)hfsFileAttributes;
- (void)setHfsFileAttributes:(NSDictionary*)newAttributes;

/* doc format stuff */
-(BOOL)shouldCheckForGraphics;
-(void)setShouldCheckForGraphics:(BOOL)flag;
-(void)setCurrentFileType:(NSString*)typeName;
-(NSString *)currentFileType;
-(BOOL)isLossy;
-(void)setLossy:(BOOL)flag;
-(BOOL)isRTFForWord;
-(void)setIsRTFForWord:(BOOL)flag;

/* encoding stuff */
-(void)setDocEncoding:(unsigned)newDocEncoding;
-(unsigned)docEncoding;
-(IBAction)encodingPreviewAction:(id)sender;
-(void)setDocEncodingString:(NSString*)anEncodingString;
-(NSString *)docEncodingString;
-(IBAction)closeEncodingSheet:(id)sender;
-(IBAction)closeEncodingSheetWithCancel:(id)sender;

/* window-related methods */
//float window
-(IBAction)floatWindow:(id)sender;
-(BOOL)isFloating;
-(void)setFloating:(BOOL)flag;

/* view and print related methods */
//note:view size is pageSize -margins
-(NSSize)theViewSize;
-(void)setViewSize:(NSSize)size;
-(void)setViewWidth:(float)width;
-(float)viewWidth;
-(void)setViewHeight:(float)height;
-(float)viewHeight;
-(void)setPaperSize:(NSSize)size;
-(float)pageSeparatorLength; //page spacer
//print info method
-(void)setPrintInfo:(NSPrintInfo *)anObject;
-(NSPrintInfo *)printInfo;
-(NSSize)paperSize;
-(void)printInfoUpdated;
//page layout lets user pick paperSize
-(void)doPageLayout:(id)sender;
-(void)didEndPageLayout:(NSPageLayout *)pageLayout returnCode:(int)result contextInfo:(void *)contextInfo;
-(NSRect)textRectForPageNumber:(unsigned)pageNumber; 
//set margins
-(void)setPrintMargins:(id)sender;
-(IBAction)printMarginsWereSet:(id)sender;
//doc attributes
-(void)setDefaultDocumentAttributes;
-(IBAction)applyPrefs:(id)sender;
-(void)setDocumentAttributes;
-(NSMutableDictionary *)fileDictionary;
-(BOOL)readOnlyDoc;
-(void)setReadOnlyDoc:(BOOL)flag;
//printing methods
-(BOOL)shouldRestorePageViewAfterPrinting;
-(void)setShouldRestorePageViewAfterPrinting:(BOOL)flag;
-(BOOL)restoreShowInvisibles;
-(void)setRestoreShowInvisibles:(BOOL)flag;
-(void)setRestoreAltTextColors:(BOOL)flag;
-(BOOL)restoreAltTextColors;
/*zoom (view scale) slider actions */
-(IBAction)zoomInAction:(id)sender;
-(IBAction)zoomOutAction:(id)sender;
-(IBAction)zoomSelect:(id)sender;
-(IBAction)zoomSlider:(id)sender;
-(IBAction)zoomAction:(id)sender;
-(void)updateZoomSlider;
//misc view
-(IBAction)scrollUpWhenAtBeginning:(id)sender;

/* toggle view items methods */
//layout vs. continuous text
-(IBAction)setTheViewType:(id)sender;
-(BOOL)hasMultiplePages;
-(void)setHasMultiplePages:(BOOL)flag;
//alt text colors
-(void)updateAltTextColors;
-(void)setShouldUseAltTextColors:(BOOL)flag;
-(BOOL)shouldUseAltTextColors;
-(void)setBackgroundColor:(NSColor*)aColor;
-(void)setBackgroundColor:(NSColor *)color;
-(IBAction)textColors:(id)sender; //for alt text view white on blue
-(void)setTextViewTextColor:(NSColor*)aColor;
-(void)setTextViewBackgroundColor:(NSColor*)aColor;
-(NSColor *)textViewTextColor;
-(NSColor *)textViewBackgroundColor;
-(IBAction)switchTextColors:(id)sender;
-(void)applyAltTextColors;
//rulers
-(BOOL)areRulersVisible;
-(void)setAreRulersVisible:(BOOL)flag;
-(IBAction)toggleBothRulers:(id)sender;
//margins
-(IBAction)toggleMarginsAction:(id)sender;
-(BOOL)showMarginsGuide;
-(void)setShowMarginsGuide:(BOOL)flag;
//misc
-(BOOL)shouldShowHorizontalScroller;
-(void)setShouldShowHorizontalScroller:(BOOL)flag;
-(IBAction)toggleInvisiblesAction:(id)sender;

/* initialized textView; adding and removing pages */
-(void)setupInitialTextViewSharedState;
-(void)plainTextSettings;
-(void)addPageWithFlag:(BOOL)isFirstPage;
-(void)removePage;

/* change text attributes methods */
-(void)updateDocumentAttributes:(NSDictionary *)docAttrsDict;
/* link attribute methods */
-(void)showLinkSheet:(id)sender;
-(IBAction)selectLinkType:(id)sender;
-(IBAction)cancelLink:(id)sender;
-(void)showLinkSheet:(id)sender;
- (void)setLinkPrefixTag:(unsigned int)theTag;
- (unsigned int)linkPrefixTag;
/* list methods */
-(IBAction)listItemIndent:(id)sender;
-(IBAction)listItemUnindent:(id)sender;
//creates bulleted list or list with numerals
-(IBAction) specialTextListAction:(id)sender;
/* tabStop methods */
-(IBAction)showAddTabStopPanelAction:(id)sender;
-(IBAction)addTabStopAction:(id)sender;
-(IBAction)cancelAddTabStopAction:(id)sender;
/* insert time/date stamp and breaks  */
-(IBAction)insertDateTimeStamp:(id)sender;
-(IBAction)insertBreakAction:(id)sender;

/* inspector controller and its actions */
-(NSDictionary *)oldAttributes;
-(void)setOldAttributes:(NSDictionary*)someAttributes;
-(BOOL)shouldForceInspectorUpdate;
-(void)setShouldForceInspectorUpdate:(BOOL)flag;
-(void)updateInspectorController:(NSNotification *)aNotification;
-(IBAction)inspectorSpacingAction:(id)sender;
-(IBAction)fontStylesAction:(id)sender;

/* styles menu action method */ 
-(IBAction)copyAndPasteFontOrRulerAction:(id)sender;

/* undo actions */
-(void)undoChangeLeftMargin:(int)theLeftMargin rightMargin:(int)theRightMargin topMargin:(int)theTopMargin bottomMargin:(int)TheBottomMargin;

/* invert selection menu action */
-(IBAction)invertSelection:(id)sender;
-(void)undoInvertSelection:(NSArray *)theOldRangesArray;

/* statistics and word count methods */
//info sheet
-(IBAction)getInfoSheet:(id)sender;
-(unsigned)wordCountForString:(NSAttributedString *)textString;
-(IBAction)revealFileInFinder:(id)sender;
-(IBAction)readOnlyButtonAction:(id)sender;
-(IBAction)lockedFileButtonAction:(id)sender;
-(IBAction)backupAutomaticallyAction:(id)sender;
-(IBAction)changeEncodingAction:(id)sender;
//properties sheet
-(IBAction)propertiesSheetAction:(id)sender;
-(IBAction)closePropertiesSheet:(id)sender;

//live word count
-(BOOL)shouldDoLiveWordCount;
-(void)setShouldDoLiveWordCount:(BOOL)flag;
-(IBAction)liveWordCount:(id)sender;
- (NSString *)thousandFormatedStringFromNumber:(NSNumber *)number;
-(int)whitespaceCountForString:(NSString *)textString;

//to avoid slow (background) repagination
-(void)doForegroundLayoutToCharacterIndex:(unsigned)loc;
//called from a button in spacing inspector, just cos not every text attribute can be set from the spacing inspector
-(IBAction) orderFrontStylesPanelAction:(id)sender;
//for testing
-(IBAction)testMethod:(id)sender;
//determines if clipView scrollsToPoint
-(void)setLineFragPosYSave:(int)lineFragPosY;
-(float)lineFragPosYSave;
//validates revertToSaved
-(BOOL)isDocumentSaved;
-(void)setIsDocumentSaved:(BOOL)flag;
//constrainScroll
-(void)setShouldConstrainScroll:(BOOL)toConstrainScrollOrNotToConstrainScroll;
-(BOOL)shouldConstrainScroll;
-(void)constrainScrollWithForceFlag:(BOOL)flag;
//save and restore cursor location
-(void)setSavedEditLocation:(unsigned int)editLocationToSave;
-(unsigned int)savedEditLocation;
-(IBAction)restoreCursorLocationAction:(id)sender;
//smart quotes / shoudldChangeText
-(BOOL)shouldUseSmartQuotes;
-(void)setShouldUseSmartQuotes:(BOOL)flag;
-(IBAction)convertQuotesAction:(id)sender;
-(IBAction)setSmartQuotesStyleAction:(id)sender;
- (BOOL)registerUndoThroughShouldChange;
- (void)setRegisterUndoThroughShouldChange:(BOOL)flag;
- (void)setSmartQuotesStyleTag:(unsigned int)theTag;
- (unsigned int)smartQuotesStyleTag;
//other
-(void)closeTheTransientDocument;
-(IBAction)sendToMail:(id)sender;
//images
-(IBAction)imageSheetCloseAction:(id)sender;
- (NSSize)imageSize;
- (void)setImageSize:(NSSize)size;
- (IBAction)showResizeImageSheetAction:(id)sender;
- (NSImage *)cellImageForAttachment:(NSTextAttachment *)attachment;
- (NSFileWrapper *)fileWrapperForImage:(NSImage *)anImage withMaxWidth:(float)newWidth withMaxHeight:(float)newHeight;

/* method for toolbar actions */
-(void)setupToolbar;
//misc toolbar actions
-(IBAction)defineWord:(id)sender;
-(IBAction)undoChange:(id)sender;
-(IBAction)redoChange:(id)sender;
-(IBAction)performFind:(id)sender;
-(IBAction)copyAction:(id)sender;
-(IBAction)pasteAction:(id)sender;

/* misc methods */
-(void)isCentimetersOrInches;
-(float)pointsPerUnitAccessor;
-(void)setPointsPerUnitAccessor:(float)points;
-(IBAction)autocompleteAction:(id)sender;
-(IBAction)displayHelp:(id)sender;
-(IBAction) checkForUpdate:(id) sender;
-(IBAction)showFontPanel:(id)sender;
//hide control to change document background color in font panel
- (unsigned int)validModesForFontPanel:(NSFontPanel *)fontPanel;

//unenable the pageUp, pageDown buttons
-(IBAction)windowResignedMain:(id)sender;

typedef struct {
	id delegate;
	SEL shouldCloseSelector;
	void *contextInfo;
} SelectorContextInfo;

@end

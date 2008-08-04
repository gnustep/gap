/*
	MyDocument.m
	Bean

	Started 11 JUL 2006 by James Hoover

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

#import "MyDocument.h"

#ifdef GNUSTEP
#import <values.h>
#endif

//	internal identifiers for toolbar items; the string describes the item's action
//	DO NOT LOCALIZE 
static NSString	*MyDocToolbarIdentifier = @"My Document Toolbar Identifier"; //toolbar instance
static NSString	*SaveDocToolbarItemIdentifier = @"Save Document Item Identifier";
static NSString	*LookUpInDictionaryItemIdentifier = @"Define Word Item Identifier";
static NSString	*UndoItemIdentifier = @"Undo Item Identifier";
static NSString	*RedoItemIdentifier = @"Redo Item Identifier";
static NSString	*FindItemIdentifier = @"Find Item Identifier";
static NSString	*AlternateTextColorItemIdentifier = @"Alternate Text Color Identifier";
static NSString	*ShowInspectorItemIdentifier = @"Show Inspector Item Identifier";
static NSString	*ShowStatisticsItemIdentifier = @"Show Statistics Item Identifier"; //Get Info...
static NSString	*BackupItemIdentifier = @"Backup Item Identifier";
static NSString	*ToggleViewtypeItemIdentifier = @"Toggle Viewtype Item Identifier";
static NSString	*AutocompleteItemIdentifier = @"Autocomplete Item Indentifier";
static NSString	*FloatWindowItemIdentifier = @"Float Window Item Identifier";
static NSString	*CopyItemIdentifier = @"Copy Item Identifier";
static NSString	*PasteItemIdentifier = @"Paste Item Identifier";
static NSString	*InsertPictureIdentifier = @"Insert Picture Identifier";
static NSString	*ShowRulerItemIdentifier = @"Show Ruler Item Identifier";
static NSString	*ShowFontPanelItemIdentifier= @"Toggle Font Panel Item Identifier"; //now toggles font panel

#ifdef GNUSTEP
#define SInt32 long
#endif

//static NSString	*ShowFontPanelItemIdentifier= @"Show Font panel Item Identifier";

/*
//	for genstrings...connects strings below to localized versions of the names of the file types!
NSLocalizedString(@"Rich Text with Graphics Document (.rtfd)", @"name of file format: Rich Text with Graphics Document (.rtfd)");
NSLocalizedString(@"Bean Document (.bean)", @"name of the file format: Bean Document (.bean)");
NSLocalizedString(@"Web Archive (.webarchive)", @"name of the file format: Web Archive (.webarchive)");
NSLocalizedString(@"Rich Text Format (.rtf)", @"name of the file format: Rich Text Format (.rtf)");
NSLocalizedString(@"Word 97 (.doc)", @"name of the file format: Word 97 (.doc)");
NSLocalizedString(@"Word 2003 XML (.xml)", @"name of the file format: Word 2003 XML (.xml)");
NSLocalizedString(@"Web Page (.html)", @"name of the file format: Web Page (.html)");
NSLocalizedString(@"Text Document (.txt)", @"name of the file format: Text Document (.txt)");
NSLocalizedString(@"Text (you provide extension)", @"name of the file format: Text (you provide extension)");
*/

//	A note about how to localize the names of fileTypes...
//	The below string identifiers point to strings which are localized just above; so whereas unlocalized fileType name strings would reference Info.plist, these localized strings reference InfoPlist.strings

//	internal identifiers for the document types specified in info.plist
//	
//	NOTE:'human-readable' string must *EXACTLY* match the names in InfoPlist.strings! 
//
//	ALSO: the defaultType returned by NSDocumentController is in Bean returned by a subclass of NSDocumentController, JHDocumentController, which returns not the usual first document type in info.plist, but rather whatever item in the list has been selected in the Preferences popup for Default Save Type, or, if there is no Preference, then (.rtfd) 11 July 2007 BH

static NSString *RTFDDoc = @"Rich Text with Graphics Document (.rtfd)";
static NSString *BeanDoc = @"Bean Document (.bean)";
static NSString *WebArchiveDoc = @"Web Archive (.webarchive)";
static NSString *RTFDoc = @"Rich Text Format (.rtf)";
static NSString *DOCDoc = @"Word 97 (.doc)";
static NSString *XMLDoc = @"Word 2003 XML (.xml)";
static NSString *HTMLDoc = @"Web Page (.html)";
static NSString *TXTDoc = @"Text Document (.txt)";
static NSString *TXTwExtDoc = @"Text (you provide extension)";

//	straight double quote symbol, used for dialogs
static unichar quote = 0x0022;

//	used in textView:shouldChangeTextInRange: for Smart Quotes
// 'first level' quotation marks
#define DOUBLE_QUOTE 0x0022
// equivalent to 'nested' quotation marks
#define SINGLE_QUOTE 0x0027 

//	key for invalid file format (fileType)
#define kCFStringEncodingInvalidId (0xffffffffU)

//	Bean's creator code, registered with Apple
#ifdef GNUSTEP
const int kMyAppCreatorCode = 0;
#else
const OSType kMyAppCreatorCode = 'bEAN';
#endif

@implementation MyDocument

#pragma mark -
#pragma mark ---- Init, Dealloc, Load Nib ----

// ******************* Init ********************

- (id)init
{
	//	call superclass for inheritance
	self = [super init];
	if (self)
	{
		//	load MyDocument.nib
		if (![NSBundle loadNibNamed:@"MyDocument" owner:self])
		{
			NSLog(@"Failed to load MyDocument.nib");
			[NSApp activateIgnoringOtherApps:YES];
			NSAlert *alert = [[[NSAlert alloc] init] autorelease];
			NSBeep();
			[alert setMessageText:NSLocalizedString(@"Bean will quit due to an unrecoverable error. Perhaps the app was renamed while Bean was running?", @"alert title: Bean will quit due to an unrecoverable error. Perhaps the app was renamed while Bean was running?")];
			[alert setInformativeText:NSLocalizedString(@"Bean could not find MyDocument.nib.", @"alert text: Bean could not find MyDocument.nib.")];
			[alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
			[alert runModal];
			[self release];
			[NSApp terminate:nil];
			return nil;
		}
		
		//	version compatibility check from Smultron by Peter Borg
#ifndef GNUSTEP
		SInt32 systemVersion;
		if (Gestalt(gestaltSystemVersion, &systemVersion) == noErr)
		{
			if (systemVersion < 0x1040)
			{
				[NSApp activateIgnoringOtherApps:YES];
				NSAlert *alert = [[[NSAlert alloc] init] autorelease];
				[alert setMessageText:NSLocalizedString(@"You need Mac OS X 10.4 \\U2018Tiger\\U2019 to run Bean", @"alert title: You need Mac OS X 10.4 Tiger to run Bean.")];
				[alert setInformativeText:@""];
				[alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
				[alert runModal];
				[NSApp terminate:nil];
			}
		}
#endif		
		//	create layoutManager and textStorage
		textStorage = [[KBWordCountingTextStorage alloc] init];
		[textStorage setDelegate:self];
		layoutManager = [[JHLayoutManager alloc] init];
		[layoutManager setDelegate:self];
		[textStorage addLayoutManager:[self layoutManager]];
		[layoutManager release];
		
		//	set defaults for accessors
		[self setFloating:NO];
		[self setRestoreAltTextColors:NO];
		[self setRestoreShowInvisibles:NO];
		[self setShouldDoLiveWordCount:NO];
		[self setHasMultiplePages:YES];
		[self setIsRTFForWord:NO];
		[self setAreRulersVisible:YES];
		[self setIsTransientDocument:YES];
		[self setIsTerminatingGracefully:NO];
		[self setDoAutosave:NO];
		[self setShouldCheckForGraphics:YES];
		[self setShouldForceInspectorUpdate:NO];
		[self setIsDocumentSaved:NO];
		[self setLossy:NO];
		[[self layoutManager] setShowInvisibleCharacters:NO]; 
		[self setDocEncoding:nil];
		[self setDocEdited:NO];
		[self setShouldConstrainScroll:YES];
		[self setCreateDatedBackup:NO];
		[self setNeedsDatedBackup:NO];
		[self setNeedsAutosave:NO];
		[self setLinkPrefixTag:0];
		[self setReadOnlyDoc:NO]; /// 11 Oct 2007 JH
				
		//	create reusable alert sheet
		alertSheet = [[NSAlert alloc] init];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
		[alertSheet setAlertStyle:NSWarningAlertStyle];
	}
	
	//	create formatter for get info and word count 1 Sept 2007 JH
	thousandFormatter = [[NSNumberFormatter alloc] init];
#ifndef GNUSTEP
	[thousandFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
#endif
	[thousandFormatter setFormat:@"#,##0"];
		
	//	if trying to open an invalid file type, inform user and don't create document
	if ([self currentFileType]==@"invalidFileType")
	{
		[alertSheet setMessageText:[NSString stringWithFormat:NSLocalizedString(@"The document \\U201C%@\\U201D could not be opened by Bean.", @"alert title: The document (document name inserted at runtime) could not be opened by Bean."), [self displayName]]];
       	[alertSheet setInformativeText:NSLocalizedString(@"Bean cannot open documents of this type, or there is a problem with the document.", @"alert text: Bean cannot open documents of this type, or there is a  problem with the document.")];
		[alertSheet runModal];
		return nil;
	}
	
	return self;
}

// ******************* Dealloc ********************

- (void)dealloc
{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[self firstTextView] setDelegate:nil];
	[[self layoutManager] setDelegate:nil];
	//	"When you release the NSTextStorage object, it releases its NSLayoutManagers, which release their NSTextContainers, which in turn release their NSTextViews." ("Assembling the Text System by Hand" Apple) 
	[textStorage release];
	[loadedText release];
	[altTextColor release];
	[printInfo release];
	[alertSheet release];
	[thousandFormatter release];
	
	[super dealloc];
}

// ******************* Window Nib Methods ********************
- (NSString *)windowNibName
{
	//	overriding the nib file name makes MyDocument the nib's owner
	return @"MyDocument";
}

//	add code here that needs to be executed once the windowController has loaded the document's window.
- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	//	call super
	[super windowControllerDidLoadNib:aController];
	
	//	close document if file was not a format that Bean can read (10 June 2007 JH)
	if ([self currentFileType]==@"invalidFileType")
	{
		[docWindow setAlphaValue: 0.0]; //	to keep window from flashing into existence before it closes
		[self close];
		[alertSheet setMessageText:[NSString stringWithFormat:NSLocalizedString(@"The document \\U201C%@\\U201D could not be opened by Bean.", @"alert title: The document (document name inserted at runtime) could not be opened by Bean."), [self displayName]]];
		[alertSheet setInformativeText:NSLocalizedString(@"Bean cannot open documents of this type, or there is a problem with the document.", @"alert text: Bean cannot open documents of this type, or there is a  problem with the document.")];
		[alertSheet runModal];
	}
	
	//	save initial window size and position for Untitled docs...experimented with this; it's not very consistant and I think is meant for Apps that have only one window 18 June 2007 
	//[[theScrollView window] setFrameAutosaveName:@"MyWindow"];
		
	//	should Bean use centimeters or inches for this document's ruler and sheets? check NSGlobalDomain for current user default 
	[self isCentimetersOrInches];
	
	//	get user defaults for later
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//	set shared spell checker pointer for later
	spellChecker = [NSSpellChecker sharedSpellChecker];
	
	//	this makes the status bar look nice before any counting occcurs
	[liveWordCountField setObjectValue:NSLocalizedString(@"B  E  A  N", @"status bar label: B  E  A  N")];		
	[liveWordCountField setTextColor:[NSColor darkGrayColor]];

	//	set 'default' print info
	[self setPrintInfo:[NSPrintInfo sharedPrintInfo]];
	[printInfo setHorizontalPagination:NSFitPagination];
	
	//	if plain or attributed text was loaded from document's file, load it into text storage
	if (loadedText) 
	{
		[textStorage replaceCharactersInRange:NSMakeRange(0,[textStorage length]) withAttributedString:loadedText];
		[self setIsTransientDocument:NO];
		[self setIsDocumentSaved:YES];
		NSFileManager *fm = [NSFileManager defaultManager];
		NSDictionary *theFileAttrs = [fm fileAttributesAtPath:[self fileName] traverseLink:YES];
		if ([self fileName])
		{
			//	if file is locked, open an 'Untitled' doc with the contents of the original, that is, treat is as a 'template'
			if ([[theFileAttrs objectForKey:NSFileImmutable] boolValue] == YES || [self isStationaryPad:[self fileName]])
			{
				[self setOriginalFileName:[self fileName]];
				[self setFileName:nil];
				[self setLossy:NO];
				[self setIsDocumentSaved:NO];
				[self setFileModDate:nil];
			}
			else
			{
				//	otherwise, remember file mod date to compare before saving later to see if the file has been externally edited
				[self setFileModDate:[[fm fileAttributesAtPath:[self fileName] traverseLink:YES] fileModificationDate]];
			}
		}
	}
	
	//	add the first page
	[self addPageWithFlag:NO];
	
	//	the first page must be added before the shared text state can be set up, which we do here
	[self setupInitialTextViewSharedState];
	
	//	if new document, get default typingAttributes (incl. font) and pagesize/margins that are indicated in Preferences and apply
	if (loadedText==nil)
	{
		//	retrieve default typing attributes for cocoa
		NSMutableParagraphStyle *theParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		//	get line spacing attribute from defaults in preferences
		switch ([defaults integerForKey:@"prefDefaultLineSpacing"]) //binding is selectedTag
		{
			case 0: //single space
				[theParagraphStyle setLineHeightMultiple:1.0];
				break;
			case 2: //double space
				[theParagraphStyle setLineHeightMultiple:2.0];
				break;
			default: //1.5 space
				[theParagraphStyle setLineHeightMultiple:1.5];
				break;
		}
		//	get first line indent from defaults in preferences
		float firstLineIndent = 0.0;
		firstLineIndent = [defaults boolForKey:@"prefIsMetric"]
					? [[defaults valueForKey:@"prefDefaultFirstLineIndent"] floatValue] * 28.35 
					: [[defaults valueForKey:@"prefDefaultFirstLineIndent"] floatValue] * 72.0;
		if (firstLineIndent) { [theParagraphStyle setFirstLineHeadIndent:firstLineIndent]; }

		//	make a dictionary of the attributes
		NSMutableDictionary *theTypingAttributes = [ [[NSMutableDictionary alloc] initWithObjectsAndKeys:theParagraphStyle, 
					NSParagraphStyleAttributeName, nil] autorelease];
		[theParagraphStyle release];
		
		//	retrieve the default font name and size from user prefs; add to dictionary
		NSString *richTextFontName = [defaults valueForKey:@"prefRichTextFontName"];
		float richTextFontSize = [[defaults valueForKey:@"prefRichTextFontSize"] floatValue];
		//	create NSFont from name and size
		NSFont *aFont = [NSFont fontWithName:richTextFontName size:richTextFontSize];
		//	use system font on error (Lucida Grande, it's nice)
		if (aFont == nil) aFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
		//	add font to typingAttributes
		if (aFont) [theTypingAttributes setObject:aFont forKey:NSFontAttributeName];
		
		//	apply to textview (for new documents)
		[[self firstTextView] setTypingAttributes:theTypingAttributes];
		//	get (default) paper size and figure textContainer size
		NSRect rect = NSZeroRect;
		rect.size = [printInfo paperSize];
		//	figure width of textContainer
		[self setViewWidth:(rect.size.width - [printInfo leftMargin]- [printInfo rightMargin])];
		//	figure height of textContainer
		[self setViewHeight:(rect.size.height - [printInfo topMargin] - [printInfo bottomMargin])];
		//	setup pageView container size, etc.
		[self printInfoUpdated];
		//	we supply default margins too
		[self setDefaultDocumentAttributes];
		//
		richTextFontName = nil;
		richTextFontSize = 0.0;
	}
	
	//	if text or html, use default _plain_ text font from user defaults and some default margins
	if ([[self currentFileType] isEqualToString:TXTDoc] 
				|| [[self currentFileType] isEqualToString:HTMLDoc]
				|| [[self currentFileType] isEqualToString:TXTwExtDoc])
	{
		//	added to give layout view reasonable margins and prepare for fitWidth (25 May 2007 BH)
		[self setDefaultDocumentAttributes];
		//	for txt and html, use continuous text view
		[self setTheViewType:nil];
		//	prepare to open plain text file (appropriate font, etc.)
		[self plainTextSettings];
	}
	//	otherwise, use attributes from the file, if they exist (pageSize, margins)
	else
	{
		[self setDocumentAttributes];
	}

	//	should scroll of scrollview constrain to show insertion point approx in middle of screen (based on user Pref)? 
	id val = nil;
	if (val = [defaults objectForKey:@"prefConstrainScroll"]) { [self setShouldConstrainScroll:[val boolValue]]; }
	
	//	doForegroundLayout... prevents vertical scroller from racing to top of page
	//	increased to 500K characters because interface slows way down when laying out text in background (24 May 2007 BH)
	[self doForegroundLayoutToCharacterIndex:500000];
	
	//	force doc to scroll to restored insertion point//
	if ([self hasMultiplePages]) { [self constrainScrollWithForceFlag:YES]; }
	else { [[self firstTextView] centerSelectionInVisibleArea:self]; }
	
	[self setDocEdited:NO];
	
	//	register for notifications (note: 'object:NULL' means change in any view sends notification)
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	//	to update inspector
	[nc addObserver:self selector:@selector(updateInspectorController:) name:NSApplicationDidUpdateNotification object:NULL];
	[nc addObserver:self selector: @selector(forceUpdateInspectorController:) name:NSWindowDidBecomeMainNotification object:NULL];
	//	unenable buttons when window loses focus
	[nc addObserver:self selector: @selector(windowResignedMain:) name:NSWindowDidResignMainNotification object:NULL];
	//	for word counting text storage
	[nc addObserver:self selector:@selector(liveWordCount:) name:@"KBTextStorageStatisticsDidChangeNotification" object:textStorage];
	//	for automatic backup upon quit
	[nc addObserver:self selector:@selector(backupDocumentAtQuitAction:) name:@"NSApplicationWillTerminateNotification" object:NULL];
    //	so can show very top of pageView when pageUp key is pressed
	[nc addObserver:self selector:@selector(scrollUpWhenAtBeginning:) name:@"NSTextViewDidChangeSelectionNotification" object:NULL];
	//	apply user Preferences 
	[self applyPrefs:self];
	[self setupToolbar];
	//	figure inital numbers
	[self liveWordCount:nil];
	//	zero out text string
	[loadedText release];
	loadedText = nil;
	val = nil;
	
	//	make this a pref? not currently used
	//	[[theScrollView window] center];
	
	//	set focus (otherwise, initial typing does nothing!)
	if (theScrollView)
	{
		[[theScrollView window] makeFirstResponder:[self firstTextView]];
		[[theScrollView window] setInitialFirstResponder:[self firstTextView]];
	}
}

-(BOOL)isFlipped
{
	return YES;
}

#pragma mark -
#pragma mark ---- saveToURL, Write & Read fileWrappers, Export HTML ----

- (BOOL)saveToURL:(NSURL *)absoluteURL 
		 ofType:(NSString *)typeName
		 forSaveOperation:(NSSaveOperationType)saveOperation
		 error:(NSError **)outError
{
	BOOL result;
	//	call super
	result = [super saveToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation error:outError];
	//	bookkeeping if save was successful
	if (result)
	{
		//	mark document as saved
		[self setIsDocumentSaved:YES];
		//	FIXME: use NSWindow's implementation of this??
		[self setDocEdited:NO];
		//	can't be lossy anymore because of write
		[self setLossy:NO];
		//	remember file mod date for check for external edit
		[self setFileModDate:[[[NSFileManager defaultManager] fileAttributesAtPath:[self fileName] 
					traverseLink:YES] fileModificationDate]];
		//	file was saved, so backup is necessary *IF* createDatedBackup==YES
		[self setNeedsDatedBackup:YES];
	}
	return result;
}

//	Cocoa does not write creator code and HFS filetype by default...override fileAttributesToWriteToURL to do this
- (NSDictionary *)fileAttributesToWriteToURL:(NSURL *)absoluteURL 
			ofType:(NSString *)typeName 
			forSaveOperation:(NSSaveOperationType)saveOperation 
			originalContentsURL:(NSURL *)absoluteOriginalContentsURL 
			error:(NSError **)outError 
{
	//	if a creator code was saved upon open, use it; otherwise, use: bEAN (which is registered with Apple) 
	NSMutableDictionary *fileAttributes = [[super fileAttributesToWriteToURL:absoluteURL
				ofType:typeName forSaveOperation:saveOperation
				originalContentsURL:absoluteOriginalContentsURL
				error:outError] mutableCopy];
	//	if HFSTypeCode exists in hfsFileAttributes dict (from opening file) and not currently involved in a Save As... operation, add original fileType code to file; else, give it a new appropriate one
	if (![[self hfsFileAttributes] fileHFSTypeCode]==0 && !(saveOperation==NSSaveAsOperation))
	{
		[fileAttributes setObject:[ NSNumber numberWithUnsignedInt:[[self hfsFileAttributes] fileHFSTypeCode] ] forKey:NSFileHFSTypeCode];
	}
	else
	{
		if ([typeName isEqualToString:RTFDoc])
			{ [fileAttributes setObject:[NSNumber numberWithUnsignedLong:'RTF '] forKey:NSFileHFSTypeCode]; }
		else if ([typeName isEqualToString:DOCDoc])
			{ [fileAttributes setObject:[NSNumber numberWithUnsignedLong:'W8BN'] forKey:NSFileHFSTypeCode]; }
		else if ([typeName isEqualToString:TXTDoc])
			{ [fileAttributes setObject:[NSNumber numberWithUnsignedLong:'TEXT'] forKey:NSFileHFSTypeCode]; }
		else
		{	
			//nothing 
		}
	}
	//	if HFSCreatorCode exists in hfsFileAttributes dict (from opening file) and not involved in a Save As... operation, add original code to file; otherwise, make creator code bEAN (=Bean's creator code)
	if (![[self hfsFileAttributes] fileHFSCreatorCode]==0 && !(saveOperation==NSSaveAsOperation))
	{
		[fileAttributes setObject:[ NSNumber numberWithUnsignedInt:[[self hfsFileAttributes] fileHFSCreatorCode] ] forKey:NSFileHFSCreatorCode];
	}
	//	but, if fileType is .doc, we make MS Word creator
	else if ([typeName isEqualToString:DOCDoc])
	{
		[fileAttributes setObject:[NSNumber numberWithUnsignedLong:'MSWD'] forKey:NSFileHFSCreatorCode];
	}
	//	for documents we create, we can strongly associate then with Bean in Launch Services by including Bean's creator code
	//	note: we DONT want .html or .webarchive to open automatically in Bean, but rather in Safari, etc.!
	else if (![typeName isEqualToString:HTMLDoc] 
				&& ![typeName isEqualToString:WebArchiveDoc] 
				&& ![typeName isEqualToString:TXTDoc]
				&& ![typeName isEqualToString:TXTwExtDoc])
	{
		[fileAttributes setObject:[NSNumber numberWithUnsignedInt:kMyAppCreatorCode] forKey:NSFileHFSCreatorCode]; // = bEAN
	}
	else
	{
		//no creator code, so .html, .webarchive & misc text files will open in Safari etc. and not Bean
	}
	return [fileAttributes autorelease];
}

// ***************** Write fileWrapper ********************

//	write fileWrapper to disk
- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError
{
	//	get a dictionary of the document-wide attributes for this file
	NSMutableDictionary *dict = [self fileDictionary];

	if ([typeName isEqualToString:RTFDDoc])
	{
		[dict setObject:NSRTFDTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
	}
	else if ([typeName isEqualToString:BeanDoc])
	{
		[dict setObject:NSRTFDTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
	}
	else if ([typeName isEqualToString:DOCDoc])
	{
		//	Apple's Word (.doc) converter appears to neither write nor read the pagesize and margins attributes.
		//	NOTE:Word 97 is an open specification I believe, so you would think this would work!
		[dict setObject:NSDocFormatTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
	}
	else if ([typeName isEqualToString:HTMLDoc])
	{
		[dict setObject:NSPlainTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
		//	text encoding should have been parsed out when opened; if not, use UTF-8 
		unsigned enc = [self docEncoding] ? [self docEncoding] : 4;
		[dict setObject:[NSNumber numberWithUnsignedInt:enc] forKey:NSCharacterEncodingDocumentAttribute];
	}
	else if ([typeName isEqualToString:TXTDoc])
	{
		[dict setObject:NSPlainTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
		
		//	use previous encoding if there is one
		if ([self docEncoding])
		{
			[dict setObject:[NSNumber numberWithUnsignedInt:[self docEncoding]] forKey:NSCharacterEncodingDocumentAttribute];
		}
		//	else default to UTF-8 (more 'compact' and universal than UTF-16 since UNIX and most HTML are UTF-8)
		else
		{
			//	note: OS X and Windows NT+ are UTF-16 internally, but that doesn't count for much in reading files
			//	also note: MS Word seems to read UTF-8 and UTF-16 with the same ease, but Write.exe and Notepad.exe are clueless
			[dict setObject:[NSNumber numberWithUnsignedInt:4] forKey:NSCharacterEncodingDocumentAttribute];
		
			/* 
			NOTE TO SELF:
			The following constants are provided by NSString as possible string encodings.
			NSASCIIStringEncoding = 1,
			NSNEXTSTEPStringEncoding = 2,
			NSJapaneseEUCStringEncoding = 3,
			NSUTF8StringEncoding = 4,			//std linux and HTML
			NSISOLatin1StringEncoding = 5,
			NSSymbolStringEncoding = 6,
			NSNonLossyASCIIStringEncoding = 7,
			NSShiftJISStringEncoding = 8,
			NSISOLatin2StringEncoding = 9,
			NSUnicodeStringEncoding = 10,		//std OS X
			NSWindowsCP1251StringEncoding = 11,
			NSWindowsCP1252StringEncoding = 12, //1252 is the common latin windows encoding
			NSWindowsCP1253StringEncoding = 13, 
			NSWindowsCP1254StringEncoding = 14, 
			NSWindowsCP1250StringEncoding = 15,
			NSISO2022JPStringEncoding = 21,
			NSMacOSRomanStringEncoding = 30,
			NSProprietaryStringEncoding = 65536
			*/
		}
	}
	else if ([typeName isEqualToString:XMLDoc])
	{
		[dict setObject:NSWordMLTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
	}
	else if ([typeName isEqualToString:RTFDoc])
	{
		[dict setObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
	}
#ifndef GNUSTEP
	else if ([typeName isEqualToString:WebArchiveDoc])
	{
		[dict setObject:NSWebArchiveTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
	}
	//	file type Text-You Provide Extension is written as UTF-8 plain text, which should work with ASCII and others
#endif
	else if ([typeName isEqualToString:TXTwExtDoc])
	{
		[dict setObject:NSPlainTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
		if ([self docEncoding])
		{
			[dict setObject:[NSNumber numberWithUnsignedInt:[self docEncoding]] forKey:NSCharacterEncodingDocumentAttribute];
		}
		else
		{
			//	default is UTF-8
			[dict setObject:[NSNumber numberWithUnsignedInt:4] forKey:NSCharacterEncodingDocumentAttribute];
		}
	}
	
	
	//	if .doc file was RTF in disguise (determined in readFromFileWrapper), save it as RTF
	if ([self isRTFForWord])
	{
		[dict setObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
	}
	
	//	the dictionary tells fileWrapperFromRange what file format to write the file in
	if ([typeName isEqualToString:RTFDDoc] || [typeName isEqualToString:BeanDoc])
	{
		return [textStorage RTFDFileWrapperFromRange:NSMakeRange(0,[textStorage length]) documentAttributes:dict];
	} 
	else
	{
		return [textStorage fileWrapperFromRange:NSMakeRange(0,[textStorage length]) documentAttributes:dict error:outError];
	}
	return nil;
}

//	reports on UTI of incoming file, used for instance in identifying .doc files without .doc extension
//	function by Kenny Leung, from CocoaBuilder.com
// ******************* UTI for file ********************

NSString *universalTypeForFile(NSString *filename)
{
#ifndef GNUSTEP
	OSStatus status;
	CFStringRef uti;
	FSRef fileRef;
	Boolean isDirectory;
	uti = NULL;
	status = FSPathMakeRef((UInt8 *)[filename fileSystemRepresentation], &fileRef,
						   &isDirectory);
	if ( status != noErr ) {
		return nil;
	}
	status = LSCopyItemAttribute(&fileRef, kLSRolesAll,
								 kLSItemContentType, (CFTypeRef *)&uti);
	if ( status != noErr ) {
		return nil;
	}
	return (NSString *)uti;
#else
	return nil;
#endif
}

// ******************* Read fileWrapper ********************

//	this method reads in the data for ALL filetypes readable by Bean
- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper 
			ofType:(NSString *)typeName
			error:(NSError **)outError
{
	//	note: RTFD is Bean's native format; .Bean format files are just RTFD with a '.bean' extension
	
	//	examine file's UTI
	BOOL forceDocFormat = NO;
	NSString *theFileName = [self fileName];
	NSString *theUTI = universalTypeForFile(theFileName);
	//	file's OS Code
	NSString *theFileType = nil;
	NSString *theFileApp = nil;
	[[NSWorkspace sharedWorkspace] getInfoForFile:[self fileName] application:&theFileApp type:&theFileType];
	
	//	if UTI says .doc but no extension, force .doc (10 July 2007 BH)
	if (([theUTI isEqualToString:@"com.microsoft.word.doc"] 
				|| [theFileType isEqualToString:@"'W8BN'"]) 
				&& ![typeName isEqualToString:DOCDoc])
	{
		[self setCurrentFileType:DOCDoc];
		[self setFileType:DOCDoc];
		forceDocFormat = YES;
	}
	//	if OS Type is RTF, but no extension, force .rtf
	else if ([theFileType isEqualToString:@"'RTF '"] && ![typeName isEqualToString:RTFDoc])
	{
		[self setCurrentFileType:RTFDoc];
		[self setFileType:RTFDoc];
	} 
	//	otherwise set currentFileType to typeName (which is based on extension)
	else
	{
		[self setCurrentFileType:typeName];
	}
	
	//	keep HFS file attributes around for adding to file after save (fileType, creatorCode)
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *thePath = nil;
	thePath = [self fileName];
	if ([fileManager isReadableFileAtPath:thePath])
	{
		NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:thePath traverseLink:YES];
		if (fileAttributes != nil)
		{
			[self setHfsFileAttributes:fileAttributes];
		}
	}	
	theFileName = nil;
	theUTI = nil;
	theFileType = nil;
	theFileApp = nil;
		
	//	close any untitled, unused docs before opening another one
	[self closeTheTransientDocument];
	
	//	if BEAN or RTFD, we load it
	if (([typeName isEqualToString:RTFDDoc] 
				|| [typeName isEqualToString:BeanDoc])
				//	to catch case where someone names a text file with an arbitrary (ie, wrong) extension such as .rtfd, which will cause Bean to crash when it tries to save the file (17 May 2007 BH)
				&& [[NSWorkspace sharedWorkspace] isFilePackageAtPath:[self fileName]] )
	{
		NSDictionary *docAttrs;
		loadedText = [[NSAttributedString alloc] initWithRTFDFileWrapper:fileWrapper documentAttributes:&docAttrs];
		if (loadedText) { [self updateDocumentAttributes:docAttrs]; }
		return YES;
	}
	//	check for other types of file packages (=folders) besides RTFD and BEAN and inform user that we don't read them
	if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:[self fileName]])
	{
		[self setCurrentFileType:@"invalidFileType"]; // this will create an alert and make document nil
		return YES;
	}
	//	if not BEAN or RTFD, load the remaining types
	else if ([typeName isEqualToString:RTFDoc] )
	{
		options = [NSDictionary dictionaryWithObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
	}
	else if ([typeName isEqualToString:DOCDoc] || forceDocFormat)
	{
		options = [NSDictionary dictionaryWithObject:NSDocFormatTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
	}
	else if ([typeName isEqualToString:HTMLDoc])
	{
		
		options = [NSDictionary dictionaryWithObject:NSPlainTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
		//	get the string from the HTML file so we can see if the encoding is specified
		NSData *textData = [[NSData alloc] initWithContentsOfFile:[self fileName]];
		NSString *theString = [[NSString alloc] initWithData:textData encoding:NSISOLatin1StringEncoding];
		NSScanner *seekCharset = [NSScanner scannerWithString:theString];
		NSStringEncoding encoding = 0;
		[seekCharset scanUpToString:@"charset=" intoString:NULL];
		//	this is the location of the 'name' of the encoding
		unsigned encStringLocation = [seekCharset scanLocation] + 8;
		//	if not specified in file, try UTF-8
		if ([seekCharset scanLocation]==[theString length])
		{
			//scanner reached end without finding 'charset' so we try UTF-8
			options = [NSDictionary  dictionaryWithObject:[NSNumber numberWithUnsignedInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentAttribute];
			[self setDocEncoding:NSUTF8StringEncoding];
			[self setDocEncodingString:@"Unicode (UTF-8)"];
		} 
		//	try to figure out which encoding is specified
		else
		{
			[seekCharset scanUpToString:[NSString stringWithFormat:@"%C", quote] intoString:NULL];
			//	this is the length of the 'name' of the encoding
			unsigned encStringLength = [seekCharset scanLocation] - encStringLocation;
			//	this is the name off the encoding
#ifndef GNUSTEP
			encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)[theString substringWithRange:NSMakeRange(encStringLocation,encStringLength)]));
			if (encoding && !(encoding==kCFStringEncodingInvalidId))
			{
				options = [NSDictionary  dictionaryWithObject:[NSNumber numberWithUnsignedInt:encoding] forKey:NSCharacterEncodingDocumentAttribute];
				[self setDocEncoding:encoding];
				NSString *setEncString = [NSString localizedNameOfStringEncoding:encoding];
				if (setEncString) { [self setDocEncodingString:setEncString]; }
			}
#endif
		}
		[textData release];
		[theString release];
	}
	else if ([typeName isEqualToString:TXTDoc] || [typeName isEqualToString:TXTwExtDoc])
	{
		//	plain text type document
		options = [NSDictionary dictionaryWithObject:NSPlainTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
		//	extract string from text file and try to determine the encoding
		//	note: we can determine UTF-16 (encoding=10) and UTF-8 with byte marker (encoding==4) with some certainty; if encoding cannot be determined ([self docEncoding=nil]), a sheet will be shown later asking user to specify it
		NSError *encError = nil;
		NSStringEncoding fileEncoding = 0.0;
		if ([[NSFileManager defaultManager] fileExistsAtPath:[self fileName]])
		{
			NSString *aString = [[NSString alloc] initWithContentsOfFile:[self fileName] usedEncoding:&fileEncoding error:&encError];
			[aString release];
			//	specify UTF-16 (=10) or UTF-8 (=4) if these types are determined
			if (fileEncoding==NSUTF8StringEncoding) //	=4
			{
				options = [NSDictionary  dictionaryWithObject:[NSNumber numberWithUnsignedInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentAttribute];
				[self setDocEncoding:NSUTF8StringEncoding];
				[self setDocEncodingString:@"Unicode (UTF-8)"];
			}
			else if (fileEncoding==NSUnicodeStringEncoding) //	=10
			{
				options = [NSDictionary  dictionaryWithObject:[NSNumber numberWithUnsignedInt:NSUnicodeStringEncoding] forKey:NSCharacterEncodingDocumentAttribute];
				[self setDocEncoding:NSUnicodeStringEncoding];
				[self setDocEncodingString:@"Unicode (UTF-16)"];
			}
			//	test whether file actually is UTF-8, just without unicode byte marker
			//	NOTE: we can't similarly test for UTF-16 because it will always return a string - but not always a meaningful one
			else if (fileEncoding==0)
			{
				NSData *textData = [[NSData alloc] initWithContentsOfFile:[self fileName]];
				NSString *string = [[NSString alloc] initWithData:textData encoding:NSUTF8StringEncoding];
				//	only well-formed UTF-8 will produce a string
				if (string)
				{ 
					options = [NSDictionary  dictionaryWithObject:[NSNumber numberWithUnsignedInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentAttribute];
					[self setDocEncoding:NSUTF8StringEncoding];
					[self setDocEncodingString:@"Unicode (UTF-8)"];
				}
				[textData release];
				[string release];
			}
		}
	}
	else if([typeName isEqualToString:XMLDoc])
	{
		options = [NSDictionary dictionaryWithObject:NSWordMLTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
	} 
#ifndef GNUSTEP	
	else if([typeName isEqualToString:WebArchiveDoc])
	{
		options = [NSDictionary dictionaryWithObject:NSWebArchiveTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
	} 
#endif
	/*
	//	this bit added to TXTDoc section so it can share the encoding guessing code there 
	else if ([typeName isEqualToString:TXTwExtDoc])
	{
		//	from Smultron, not adapted yet
		NSString *lookForEncodingInBytesString = [[NSString alloc] initWithString:[textData description]];
		
		if ([[lookForEncodingInBytesString substringWithRange:NSMakeRange(1,6)] isEqual:@"efbbbf"]) encoding = NSUTF8StringEncoding;
		else if ([[lookForEncodingInBytesString substringWithRange:NSMakeRange(1,4)] isEqual:@"feff"] || [[lookForEncodingInBytesString substringWithRange:NSMakeRange(1,4)] isEqual:@"fffe"]) encoding = NSUnicodeStringEncoding;
		[lookForEncodingInBytesString release];
		//	old code
		//	if file is text file with arbitrary extension (or any format Bean doesn't understand), treat as UTF-8 text file
		options = [NSDictionary dictionaryWithObject:NSPlainTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
		options = [NSDictionary  dictionaryWithObject:[NSNumber numberWithUnsignedInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentAttribute];
		[self setDocEncoding:NSUTF8StringEncoding];
		[self setDocEncodingString:@"Unicode (UTF-8)"];
	}
	*/

	// if filename has no extension, try reading as RTF string; if string is produced, set type as RTF (27 May 2007 BH)
	if ([[[self fileName] pathExtension] isEqualToString:@""])
	{
		NSDictionary *docAttrs;
		loadedText = [[NSAttributedString alloc] initWithRTF:[fileWrapper regularFileContents] documentAttributes:&docAttrs];
		if (loadedText)
		{
			[self updateDocumentAttributes:docAttrs];
			[self setCurrentFileType:RTFDoc];
			[self setFileType:RTFDoc];
			return YES;
		}
	}
	
	//	we invoke readFromData and then initWithData for all file types above -- except those with directory wrappers (ie, .RTFD & .BEAN) 
	if (options != nil)
	{
		// if plain text
		if ([[self currentFileType] isEqualToString:TXTDoc] 
					|| [[self currentFileType] isEqualToString:HTMLDoc]
					|| [[self currentFileType] isEqualToString:TXTwExtDoc]) //	added check for arbitrary ext. text files (22 May 2007 BH)  

		{
			//	if .txt or .html and encoding was sussed above, get as string using encoding
			if ([self docEncoding])
			{
				NSData *textData = [[NSData alloc] initWithContentsOfFile:[self fileName]];
				NSString *theString = [[NSString alloc] initWithData:textData encoding:[self docEncoding]];
				if (theString)
				{ 
					loadedText = [[NSAttributedString alloc] initWithString:theString];
				}
				//	if no string, may be bad/incorrect encoding; we notify user of (potential) problem and try to read file as 'plain text' below
				else
				{
					[self setDocEncoding:nil];
					[self setDocEncodingString:@"Unknown"];
				}
				[textData release];
				[theString release];
			}
			//	if no encoding yet; let Cocoa try to figure it out - but only .txt files, to screen out apps, Zips, tiffs, etc.
			else
			{
				if ([typeName isEqualToString:TXTDoc])
				{
					NSDictionary *docAttrs;
					loadedText = [[NSAttributedString alloc] initWithData:[fileWrapper regularFileContents] options:options documentAttributes:&docAttrs error:nil];
				}
			}
			if (loadedText)
			{ 
				return YES;
			}
		} 
		//	if not plain text
		else
		{
			NSDictionary *docAttrs;
			loadedText = [[NSAttributedString alloc] initWithData:[fileWrapper regularFileContents] options:options documentAttributes:&docAttrs error:nil];
			if (loadedText)
			{
				[self updateDocumentAttributes:docAttrs];
				return YES;
			}
		}
	}
	
	// still nothing? try to read as "RTF with .doc extension" file 
	if (!loadedText && [typeName isEqualToString:DOCDoc])
	{
		// .doc files don't always load since sometimes they are .rtf files in disguise, so check for this
		NSDictionary *docAttrs;
		loadedText = [[NSAttributedString alloc] initWithRTF:[fileWrapper regularFileContents] documentAttributes:&docAttrs];
		if (loadedText)
		{
			[self updateDocumentAttributes:docAttrs];
			[self setIsRTFForWord:YES];
			return YES;
		}
	}
	
	//	could not read the file - an alert will be generated and document set to nil
	[self setCurrentFileType:@"invalidFileType"];
	NSBeep();
	return YES;
}


// ******************* export to HTML ********************

-(IBAction)exportToHTML:(id)sender 
{
	//	this part creates a folder for the exported file index.html and the objects that go with it
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *theHTMLPath = [[self fileName] stringByDeletingPathExtension];
	int exportNumber = 0;
	NSError *theError = nil;
	
	//	we don't export images now, so this is unused
	//BOOL exportImageSuccess = YES;
		
	//	path of the HTML containing folder
	NSString *theHTMLFolderPath = [NSString stringWithFormat:@"%@%@", theHTMLPath, @" - html"];
	//	to avoid overwriting previous export, add sequential numbers to folder name
	while ([fm fileExistsAtPath:theHTMLFolderPath isDirectory:NULL] && exportNumber < 1000)
	{
		exportNumber = exportNumber + 1;
		theHTMLFolderPath = nil;
		theHTMLFolderPath = [NSString stringWithFormat:@"%@%@%i", theHTMLPath, @" - html", exportNumber];
	}
	[fm createDirectoryAtPath:theHTMLFolderPath attributes:nil];

	//if the folder was created, write the exported html file inside it
	if ([fm fileExistsAtPath:theHTMLFolderPath isDirectory:NULL])
	{
		NSError *outError = nil;
		//	get doc-wide dictionary and set type to HTML
		NSMutableDictionary *dict = [self fileDictionary];
		[dict setObject:NSHTMLTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
		//	create data object for HTML
		NSData *data = [[self textStorage] dataFromRange:NSMakeRange(0, [textStorage length]) documentAttributes:dict error:&outError];
		
		// below code removes extraneous path elements generated by Cocoa in HTML code for image URLs
		
		//	get html code as string from HTML data object
		NSString *htmlString = nil;
		htmlString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		//	to hold revised string after image paths are updated
		NSMutableString *newString = [[[NSMutableString alloc] initWithCapacity:[htmlString length]] autorelease];
		NSScanner *scanner = [NSScanner scannerWithString:htmlString];
		while (![scanner isAtEnd])
		{
			NSString *tempString = nil;
			[scanner scanUpToString:@"file:///" intoString:&tempString];
			if (tempString)
			{
				[newString appendString:tempString];
				unsigned scanLoc = nil;
				scanLoc = [scanner scanLocation];
				if ((scanLoc + 8) < [htmlString length])
				{
					[scanner setScanLocation:(scanLoc + 8)];
				}
			}
			tempString = nil;
		}
		if (newString)
		{
			//	path for index.html, the exported HTML file
			NSString *theHTMLPath = [NSString stringWithFormat:@"%@%@", theHTMLFolderPath, @"/index.html"];
			NSURL *theHTMLURL = [NSURL fileURLWithPath:theHTMLPath];
			//	write index.html file
			[newString writeToURL:theHTMLURL atomically:YES encoding:NSUTF8StringEncoding error:&theError];
			
			/*
			//	NOTE USED!
			//	write picture attachments to html export folder
			//	note: the scale of these pictures in a document is not the same as the scale when placed in HTML; rather than rescaling or whatever, just export the HTML and let the user drop the files into the HTML file's containing folder
			NSMutableAttributedString *theAttachmentString = [[NSMutableAttributedString alloc] initWithAttributedString:textStorage];
			NSRange strRange = NSMakeRange(0, [theAttachmentString length]);
			while (strRange.length > 0)
			{
				NSRange effectiveRange;
				id attr = [theAttachmentString attribute:NSAttachmentAttributeName atIndex:strRange.location effectiveRange:&effectiveRange];
				strRange = NSMakeRange(NSMaxRange(effectiveRange), NSMaxRange(strRange) - NSMaxRange(effectiveRange));
				if(attr)
				{
					NSTextAttachment *attachment = (NSTextAttachment *)attr;
					NSFileWrapper *fileWrapper = [attachment fileWrapper];
					NSString *fileWrapperPath = [fileWrapper filename];
					NSString *pictureExportPath = [NSString stringWithFormat:@"%@%@%@", theHTMLFolderPath, @"/", fileWrapperPath];
					//NSLog(pictureExportPath);
					BOOL success = YES;
					success = [fileWrapper writeToFile:pictureExportPath atomically:YES updateFilenames:YES];
					if (success==NO) exportImageSuccess = NO;
					attachment = nil;
					fileWrapper = nil;
					fileWrapperPath = nil;
					pictureExportPath = nil;
				}
			}			
			[theAttachmentString release];
			*/
		}
	}
	//there was an error in creating the export folder
	else
	{
		NSBeep();
	}
	//	error alert dialog
	if (![fm fileExistsAtPath:theHTMLFolderPath isDirectory:NULL] || !theError==nil)
	{
		NSString *anError = [theError localizedDescription];
		NSString *alertTitle = nil;
		if (theError)
		{
			alertTitle =  [NSString stringWithFormat:NSLocalizedString(@"Export to HTML failed: %@", @"alert title: Export to HTML failed: (localized reason for failure automatically inserted at runtime)"), anError];
		}
		else
		{
			alertTitle = NSLocalizedString(@"Export to HTML failed.", @"Export to HTML failed.");
		}
		[[NSAlert alertWithMessageText:alertTitle
						 defaultButton:NSLocalizedString(@"OK", @"OK")
					   alternateButton:nil
						   otherButton:nil
			 informativeTextWithFormat:NSLocalizedString(@"A problem prevented the document from being exported to HTML format.", @"alert text: A problem prevented the document from being exported to HTML format.")] runModal];
		alertTitle = nil;
	}
	
	/*
	else if (theError==nil && exportImageSuccess == NO)
	{
		[[NSAlert alertWithMessageText:NSLocalizedString(@"There was a problem exporting image files.", @"Title of alert indicating that there was a problem exporting image files.")
						 defaultButton:NSLocalizedString(@"OK", @"OK")
					   alternateButton:nil
						   otherButton:nil
			 informativeTextWithFormat:NSLocalizedString(@"You can manually drag image files from the Finder into the revealed HTML file's folder to solve the problem.", @"Text of alert indicating you can manually drag image files from the Finder into the revealed HTML file's folder to solve the problem.")] runModal];
	}
	*/
	
	else
	{
		//	show exported file in Finder for the user
		[[NSWorkspace sharedWorkspace] selectFile:theHTMLFolderPath inFileViewerRootedAtPath:nil];
	}
}

//	thanks to Keith Blount for figuring out how to inject encoded pictures into the RTF stream before saving the document and for BW for writing up the code...see EncodeRTFwithPictures for details
//	this same function is used for "Export to DOC (with Picures)" menu action, based on the tag of the sender
-(IBAction)saveRTFwithPictures:(id)sender
{
	NSString *formatStr = nil; //	for alert msgs
	NSString *extString = nil; //	extension for saved filename
	NSFileManager *fm = [NSFileManager defaultManager];
	//	.rtf
	if ([sender tag]==0)
	{
		extString = @".rtf";
		formatStr = NSLocalizedString(@"RTF with images", @"name of export format used in alert dialog upon failure to export: RTF with images");
	}
	//	.doc
	else
	{
		extString = @".doc";
		formatStr = NSLocalizedString(@"DOC with images" , @"name of export format used in alert dialog upon failure to export: DOC with images");
	}
	//	new filename to save to
	int exportFileNumber = 0;
	//	get path with extension removed, then add .rtf extension
	NSString *thePathMinusExtension = [[self fileName] stringByDeletingPathExtension];
	NSString *theExportPath = [NSString stringWithFormat:@"%@%@", thePathMinusExtension, extString];
	//	to avoid overwriting previous export, add sequential numbers to filename just before extension
	while ([fm fileExistsAtPath:theExportPath] && exportFileNumber < 1000)
	{
		exportFileNumber = exportFileNumber + 1;
		theExportPath = [NSString stringWithFormat:@"%@%@%i%@", 
					thePathMinusExtension, @" ", exportFileNumber, extString];
	}
	//	get string with pictures encoded in hex
	NSError *outError = nil;
	NSString *stringWithEncodedPics = nil;
	NSAttributedString *textString = nil;
	textString = [textStorage copy];
	//	note: this is a category on NSAttributedString, created by Keith Blount and coded by BW (EncodeRTFwithPictures)
	stringWithEncodedPics = [textString encodeRTFwithPictures];
	BOOL success = YES;
	success =[stringWithEncodedPics writeToURL:[NSURL fileURLWithPath:theExportPath] atomically:YES encoding:NSASCIIStringEncoding error:&outError];	
	[textString release];
	//	file was written out, so give OSType and Creator Code file attributes
	if (success)
	{
		NSDictionary *fileAttributes = [fm fileAttributesAtPath:theExportPath traverseLink:YES];
		NSMutableDictionary *newFileAttrs = [NSMutableDictionary dictionaryWithDictionary:fileAttributes];
		if (newFileAttrs)
		{
			//	OStype = rtf
			if ([sender tag]==0) { [newFileAttrs setObject:[NSNumber numberWithUnsignedLong:'RTF '] forKey:NSFileHFSTypeCode]; }
			//	OSType = doc
			else { [newFileAttrs setObject:[NSNumber numberWithUnsignedLong:'W8BN'] forKey:NSFileHFSTypeCode]; }
			//	creator = MS Word
			[newFileAttrs setObject:[NSNumber numberWithUnsignedLong:'MSWD'] forKey:NSFileHFSCreatorCode];
			//	if writing the changed attributes fails, it's not that important
			[fm changeFileAttributes:newFileAttrs atPath:theExportPath];
		}
		fileAttributes = nil;
	}
	
	//	error alert dialog
	if (!outError==nil)
	{
		NSString *errDesc = nil;
		errDesc = [outError localizedDescription];
		[[NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Export document to %@ format failed: %@", @"alert title: Export document to (localized format name inserted at runtime, ex: 'Doc with images') format failed: (localizedErrorDescription automatically inserted at runtime)"), formatStr, errDesc]
						 defaultButton:NSLocalizedString(@"OK", @"OK")
					   alternateButton:nil
						   otherButton:nil
			 informativeTextWithFormat:NSLocalizedString(@"A problem prevented the document from being exported.", @"alert text: A problem prevented the document from being exported.")] runModal];
		errDesc = nil;
	} else {
		//	show exported file in Finder for the user
		[[NSWorkspace sharedWorkspace] selectFile:theExportPath inFileViewerRootedAtPath:nil];
	}
	//	zero everything out
	formatStr = nil;
	extString = nil;
	theExportPath = nil;
	thePathMinusExtension = nil;
	textString = nil;
	stringWithEncodedPics = nil;
	outError = nil;
	exportFileNumber = 0;
}

//	checks if file has newer modification date than one from our last save 
- (BOOL)isEditedExternally
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self fileName]])
	{
		NSDate *curModDate = [self fileModDate];
		NSDate *newModDate = nil;
		newModDate = [[[NSFileManager defaultManager] fileAttributesAtPath:[self fileName] 
					traverseLink:YES] fileModificationDate];
		//	if new not-yet-saved document, then NOT externally edited
		if (![self isDocumentSaved])
		{
			return NO;
		}
		return [curModDate isEqual:newModDate] ? NO : YES;
	} 
	else
	{
		return NO;
	}
}

#pragma mark -
#pragma mark ---- Document-Wide Attributes, Preferences, fileDictionary ----

//	******************* Apply (and Supply) Document Attributes ********************
//	uses attributes from the read-in document, or supply defaults if needed

//	updates the document-wide attributes
-(void)updateDocumentAttributes:(NSDictionary *)docAttrsDict
{
	if (!docAttrsDict==nil && ![docAttrsDict isEqualTo:nil])
	{
		[docAttributes autorelease];
		docAttributes = [docAttrsDict copy];
	}
}

//	uses document-wide attributes updated in updateDocumentAttributes to set paper size, margins, etc.
-(void)setDocumentAttributes
{
	id val, paperSizeVal;
	//	get viewSize (window size)
	if (val = [docAttributes objectForKey:NSViewSizeDocumentAttribute]) 
	{
		[self setViewSize:[val sizeValue]];
	}
	
	//	get paperSize
	if (val = [docAttributes objectForKey:NSPaperSizeDocumentAttribute])
	{
		paperSizeVal = [docAttributes objectForKey:NSPaperSizeDocumentAttribute];
		[self setPaperSize:[paperSizeVal sizeValue]];
	}
	
	//zoom value
	if (val = [docAttributes objectForKey:NSViewZoomDocumentAttribute])
	{
		[theScrollView setScaleFactor:[val floatValue] / 100];
		[self updateZoomSlider];
	}
	
	//	get margins
	if (val = [docAttributes objectForKey:NSLeftMarginDocumentAttribute]) { [[self printInfo] setLeftMargin:[val floatValue]]; }
	if (val = [docAttributes objectForKey:NSRightMarginDocumentAttribute]) { [[self printInfo] setRightMargin:[val floatValue]]; }
	if (val = [docAttributes objectForKey:NSBottomMarginDocumentAttribute]) { [[self printInfo] setBottomMargin:[val floatValue]]; }
	if (val = [docAttributes objectForKey:NSTopMarginDocumentAttribute]) { [[self printInfo] setTopMargin:[val floatValue]]; }
	
	//	special case: document-wide attributes are not saved for the following formats, and cocoa defaults are weird, so we provide some default margins for these formats: Word, HTML, WebArchive, Text
	if ([docAttributes objectForKey:NSDocumentTypeDocumentAttribute]==NSDocFormatTextDocumentType || 
			[docAttributes objectForKey:NSDocumentTypeDocumentAttribute]==NSHTMLTextDocumentType ||
#ifndef GNUSTEP
			[docAttributes objectForKey:NSDocumentTypeDocumentAttribute]==NSWebArchiveTextDocumentType ||
#endif
			[docAttributes objectForKey:NSDocumentTypeDocumentAttribute]==NSPlainTextDocumentType)
	{
		[self setDefaultDocumentAttributes];
	}
	
	//	update printInfo's margins
	[self printInfoUpdated];
	
	//	get view type (mode) per NSViewModeDocumentAttribute: 0=continuous text; 1=page layout; 2=fit to width; 3=fit to page
	//	NOTE: Text Edit accepts int's higher than 1 and treats them as 1 (page layout)
	
	//	continuous text view
	if ([[docAttributes objectForKey:NSViewModeDocumentAttribute] intValue]==0 && ![self isTransientDocument])
	{
			[self setTheViewType:nil];
	}
	//	fit width
	else if ([[docAttributes objectForKey:NSViewModeDocumentAttribute] intValue]==2)
	{
		[theScrollView setIsFitWidth:YES];
		[theScrollView setIsFitPage:NO];
	}
	//	fit page
	else if ([[docAttributes objectForKey:NSViewModeDocumentAttribute] intValue]==3)
	{
		[theScrollView setIsFitWidth:NO];
		[theScrollView setIsFitPage:YES];
	}
	//	arbitrary zoom - neither fit width nor fit height
	else if ([[docAttributes objectForKey:NSViewModeDocumentAttribute] intValue]==1)
	{
		[theScrollView setIsFitWidth:NO];
		[theScrollView setIsFitPage:NO];
	} 
	//new doc - fit width
	else
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults boolForKey:@"prefUseFitWidth"])
		{
			[theScrollView setIsFitWidth:YES];
			[theScrollView setIsFitPage:NO];
		}
		else
		{
			[theScrollView setIsFitWidth:NO];
			[theScrollView setIsFitPage:NO];
		}
	}

	//	setReadOnly
	if (val = [docAttributes objectForKey:NSReadOnlyDocumentAttribute])
	{
		//	means we can look and we can save but we can't edit
		[self setReadOnlyDoc:YES];
		[[self firstTextView] setEditable:NO];
	}

	// the following code determines whether document is automatically overwritten later; for instance, Word docs created in Word are always lossy when opened in Bean, but Word docs created in Bean are not lossy, so we warn before overwriting in the first case (in the 'Save' routines), but not in the second case
	int wasConvertedVal;
	wasConvertedVal = [[docAttributes objectForKey:NSConvertedDocumentAttribute] intValue];
	// conversion may have been lossy 
	//	note: nil filename means was imported as Untitled so lossy conversion does not matter
	if (wasConvertedVal < 0 && ![self fileName]==nil) { [self setLossy:YES]; }
	// conversion was not lossy
	else if (wasConvertedVal > 0) { [self setLossy:NO]; }
	//	file was original format, or locked and imported as Untitled
	else { [self setLossy:NO]; }
	wasConvertedVal = 0;

	//get keyword array, remove and use cursorLocation, use document properties array
	if (val = [docAttributes objectForKey:NSKeywordsDocumentAttribute])
	{
		NSMutableArray *keywords = [NSMutableArray arrayWithCapacity:0];
		[keywords addObjectsFromArray:[NSArray arrayWithArray:val]];
		unsigned cnt = [keywords count];
		//	FIXME what if value for cursorLocation= is not an int? do check!
		while (cnt-- > 0)
		{
			NSString *keywordString = [[NSString alloc] initWithString:[keywords objectAtIndex:cnt]];
			if ([keywordString length] > 15)
			{
				//	searches for cursorLocation= string and if found retrieves the int and makes it the location of the selected range
				if ([keywordString length] > 14 && [[keywordString substringWithRange:NSMakeRange(0, 15)] isEqualToString:@"cursorLocation="])
				{
					//	intValue on a string returns 0 is not decimal text representation of number, which is OK for us
					int cursorLocation = [[keywordString substringFromIndex:15] intValue];
					if (cursorLocation > 0 && cursorLocation < ([textStorage length] + 1))
					{
						[[self firstTextView] setSelectedRange:NSMakeRange(cursorLocation, 0)];
					}
					[keywords removeObjectAtIndex:cnt];
				}
				//	searches for automaticBackup= string and if found set accessor to do it at document close
				if ([keywordString length] > 15 && [[keywordString substringWithRange:NSMakeRange(0, 16)] isEqualToString:@"automaticBackup="])
				{
					//	intValue should return 0 at bad info here, which just means to backup
					BOOL automaticBackup = [[keywordString substringFromIndex:16] intValue];
					if (automaticBackup == YES) { [self setCreateDatedBackup:YES]; }
					[keywords removeObjectAtIndex:cnt];
				}
				//	searches for shouldAutosave= string and if found set accessor to do it at document close
			if ([keywordString length] > 16 && [[keywordString substringWithRange:NSMakeRange(0, 17)] isEqualToString:@"autosaveInterval="])
			{
					//	intValue should return 0 at bad info here, which just means to backup
					int autosaveInterval = [[keywordString substringFromIndex:17] intValue];
					//	start autosave if interval is meaningful
					if (autosaveInterval > 0 && autosaveInterval < 61)
					{
						//autosaveInterval is number of minutes between autosaves
						[doAutosaveTextField setIntValue:autosaveInterval];
						[doAutosaveStepper setEnabled:NO];
						[doAutosaveTextField setEnabled:NO];
						[doAutosaveButton setEnabled:YES];
						[doAutosaveButton setState:NSOnState];
						[self setDoAutosave:YES];
						[self beginAutosavingDocument];
					}
					[keywords removeObjectAtIndex:cnt];
				}
			}
			[keywordString release];
		}
		[propsKeywords setObjectValue:keywords];
	}

	//	get document properties and load them into doc prop panel
	if (val = [docAttributes objectForKey:NSAuthorDocumentAttribute]) 
		{ [propsAuthor setStringValue:[docAttributes valueForKey:NSAuthorDocumentAttribute]]; }
	if (val = [docAttributes objectForKey:NSTitleDocumentAttribute]) 
		{ [propsTitle setStringValue:[docAttributes valueForKey:NSTitleDocumentAttribute]]; }
	if (val = [docAttributes objectForKey:NSCompanyDocumentAttribute]) 
		{ [propsCompany setStringValue:[docAttributes valueForKey:NSCompanyDocumentAttribute]]; }
	if (val = [docAttributes objectForKey:NSCopyrightDocumentAttribute]) 
		{ [propsCopyright setStringValue:[docAttributes valueForKey:NSCopyrightDocumentAttribute]]; }
	if (val = [docAttributes objectForKey:NSSubjectDocumentAttribute]) 
		{ [propsSubject setStringValue:[docAttributes valueForKey:NSSubjectDocumentAttribute]]; }
	if (val = [docAttributes objectForKey:NSCommentDocumentAttribute])
		{ [propsComment setStringValue:[docAttributes valueForKey:NSCommentDocumentAttribute]]; }
	if (val = [docAttributes objectForKey:NSEditorDocumentAttribute]) 
		{ [propsEditor setStringValue:[docAttributes valueForKey:NSEditorDocumentAttribute]]; }
	
	//	encoding is taken care of elsewhere for .txt and .html file, so we don't need this:
	//	[docAttributes objectForKey:NSCharacterEncodingDocumentAttribute];
}

// set margins when needed based on user Preferences
-(void)setDefaultDocumentAttributes
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//	get left margin from defaults in preferences
	float leftMargin = 0.0;
	leftMargin = [defaults boolForKey:@"prefIsMetric"] 
				? [[defaults valueForKey:@"prefDefaultLeftMargin"] floatValue] * 28.35 
				: [[defaults valueForKey:@"prefDefaultLeftMargin"] floatValue] * 72.0;
	if (leftMargin) { [printInfo setLeftMargin:leftMargin]; }
	else { [printInfo setLeftMargin:0.0]; }
	
	//	get right margin from defaults in preferences
	float rightMargin = 0.0;
	rightMargin = [defaults boolForKey:@"prefIsMetric"] 
				? [[defaults valueForKey:@"prefDefaultRightMargin"] floatValue] * 28.35 
				: [[defaults valueForKey:@"prefDefaultRightMargin"] floatValue] * 72.0;
	if (leftMargin) { [printInfo setRightMargin:rightMargin]; }
	else { [printInfo setRightMargin:0.0]; }

	//	get top margin from defaults in preferences
	float topMargin = 0.0;
	topMargin = [defaults boolForKey:@"prefIsMetric"] 
				? [[defaults valueForKey:@"prefDefaultTopMargin"] floatValue] * 28.35 
				: [[defaults valueForKey:@"prefDefaultTopMargin"] floatValue] * 72.0;
	if (topMargin) { [printInfo setTopMargin:topMargin]; }
	else { [printInfo setTopMargin:0.0]; }
	
	//	get bottom margin from defaults in preferences
	float bottomMargin = 0.0;
	bottomMargin = [defaults boolForKey:@"prefIsMetric"] 
				? [[defaults valueForKey:@"prefDefaultBottomMargin"] floatValue] * 28.35 
				: [[defaults valueForKey:@"prefDefaultBottomMargin"] floatValue] * 72.0;
	if (bottomMargin) { [printInfo setBottomMargin:bottomMargin]; }
	else { [printInfo setBottomMargin:0.0]; }
	
	//	can't save zoom factor with txt, html, doc so we just use fitWidth view
	[theScrollView setIsFitWidth:YES];
	[theScrollView setIsFitPage:NO];
	float scaleFactor = [[[theScrollView documentView] superview] frame].size.width / [[theScrollView documentView] frame].size.width;
	[theScrollView setScaleFactor:scaleFactor];
	[self updateZoomSlider];
}

// ******************* Apply Preferences ********************

//	retrieve saved user preferences from the Preferences window when a document loads
-(IBAction) applyPrefs:(id)sender 
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	PageView *pageView = [theScrollView documentView];
	NSTextView *textView = [self firstTextView];
	
	if ([defaults boolForKey:@"prefLiveWordCount"])
	{ 
		[self setShouldDoLiveWordCount:YES];
	}
	else 
	{
		[self setShouldDoLiveWordCount:NO];
		[liveWordCountField setTextColor:[NSColor darkGrayColor]];
		[liveWordCountField setObjectValue:NSLocalizedString(@"B  E  A  N", @"status bar label: B  E  A  N")];	
	}
	
	if ([defaults boolForKey:@"prefShowMarginGuides"]) 
	{
		if ([[theScrollView documentView] isKindOfClass:[PageView class]])
		{
			[pageView setShowMarginsGuide:YES];
		}
		[self setShowMarginsGuide:YES];
	} 
	else
	{
		if ([[theScrollView documentView] isKindOfClass:[PageView class]])
		{
			[pageView setShowMarginsGuide:NO];
		}
		[self setShowMarginsGuide:NO];
	}
	
	if ([defaults boolForKey:@"prefShowHorizontalScroller"]) 
	{
		[self setShouldShowHorizontalScroller:YES];
	} 
	else
	{
		[self setShouldShowHorizontalScroller:NO];
		[theScrollView setHasHorizontalScroller:NO]; 
	}
	
	// 11 June 2007 BH
	if ([defaults boolForKey:@"prefShowRuler"])
	{
		[self setAreRulersVisible:YES];
		[theScrollView setRulersVisible:YES];
	}
	else
	{
		[self setAreRulersVisible:NO];
		[theScrollView setRulersVisible:NO];
	}
	
	if ([defaults boolForKey:@"prefShowRulerWidgets"])
	{
		[layoutManager setShowRulerAccessories:YES];
	}
	else
	{
		[layoutManager setShowRulerAccessories:NO];
	}
	
	[self applyAltTextColors];
	if ([defaults boolForKey:@"prefUseAltColors"])
	{
		[self setShouldUseAltTextColors:YES];
		[self textColors:nil];
	}
	else
	{
		[self setShouldUseAltTextColors:NO];
		[self textColors:nil];
	}
	
	if ([defaults boolForKey:@"prefUseSpellcheck"])
	{
		[textView setContinuousSpellCheckingEnabled:YES];
	}
	else
	{
		[textView setContinuousSpellCheckingEnabled:NO];
	}

	//	continuous text view vs. layout mode 14 June 2007 BH
	//	bugfix: 7 Aug 2007 was reversing viewtype in document attribtues
	if (![defaults boolForKey:@"prefShowLayoutView"] && [self fileName]==nil)
	{
		[self setTheViewType:nil];
	}
	
	//	show invisible chars?
	if ([defaults boolForKey:@"prefShowInvisibles"])
	{ 
		[self toggleInvisiblesAction:nil];
	}

	//	absolutely don't want Smart Quotes substituted into HTML code or other types of code
	if (![[self fileType] isEqualToString:HTMLDoc] && ![[self fileType] isEqualToString:TXTwExtDoc])
	{
		//	this sets the unicode characters for smart quotes based on user selection in preferences, which can be changed on the fly as opposed to most other preferences, and saves type integer describing the type of quote marks so shouldChangeCharater knows about whether the languages is French (for example) which will affect the spacing of the smart quotes 22 Aug 2007 JH
		[self setSmartQuotesStyleAction:self];

		if ([defaults boolForKey:@"prefSmartQuotes"])
			{ [self setShouldUseSmartQuotes:YES]; }
		else
			{ [self setShouldUseSmartQuotes:NO]; }
	}
}

//	returns a dictionary of document-wide attributes, used when saving files
- (NSMutableDictionary *) fileDictionary
{
	float zoomValue = [zoomSlider floatValue];
	//	determine which view mode to be saved
	int beanViewMode;
	if (![self hasMultiplePages])
	{
		beanViewMode = 0; //continuous text mode
	}
	else
	{
		if ([theScrollView isFitWidth]) { beanViewMode = 2; } //fit width mode
		
		else if ([theScrollView isFitPage]) { beanViewMode = 3; } //fit page mode
		
		else { beanViewMode = 1; } //page layout mode
	}
	//	create a 'keyword' for saving the cursor location
	int cursorLoc = [[self firstTextView] selectedRange].location;
	NSString *cursorLocation = nil;
	if (cursorLoc > 0) { cursorLocation = [NSString stringWithFormat:@"cursorLocation=%i", cursorLoc]; }
	//	create a 'keyword' for saving key that tells whether to do automaticBackup at close
	NSString *automaticBackup = nil;
	if ([self createDatedBackup])
	{
		automaticBackup = @"automaticBackup=1"; //1 = YES, do backup
	}
	//	create a 'keyword' for saving whether to do Autosave
	NSString *autosaveInterval = nil;
	if ([self doAutosave])
	{
		autosaveInterval = [NSString stringWithFormat:@"autosaveInterval=%i", [doAutosaveTextField intValue]]; //YES, do Autosave with interval
	}
	//	make an array to hold keywords plus our special stuff
	NSMutableArray*	keywords = [NSMutableArray arrayWithCapacity:2];
	[keywords addObjectsFromArray: [propsKeywords objectValue]];
	if (cursorLocation) { [keywords addObject:cursorLocation]; }
	if (automaticBackup) { [keywords addObject:automaticBackup]; }
	if (autosaveInterval) { [keywords addObject:autosaveInterval]; }
	//	create document-wide attributes dictionary
	//	NOTE: for some reason, NSKeywordDocumentAttribute must go before the other 'string' property attrs -- not sure why...otherwise, nothing is saved under that keyword
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		[NSValue valueWithSize:[self theViewSize]], NSViewSizeDocumentAttribute, 
		[NSNumber numberWithInt:beanViewMode], NSViewModeDocumentAttribute,
		[NSValue valueWithSize:[self paperSize]], NSPaperSizeDocumentAttribute, 
		[NSNumber numberWithFloat:zoomValue * 100], NSViewZoomDocumentAttribute, 
		[NSNumber numberWithInt:[self readOnlyDoc] ? 1 : 0], NSReadOnlyDocumentAttribute, 
		[NSNumber numberWithFloat:[[self printInfo] leftMargin]], NSLeftMarginDocumentAttribute, 
		[NSNumber numberWithFloat:[[self printInfo] rightMargin]], NSRightMarginDocumentAttribute, 
		[NSNumber numberWithFloat:[[self printInfo] bottomMargin]], NSBottomMarginDocumentAttribute, 
		[NSNumber numberWithFloat:[[self printInfo] topMargin]], NSTopMarginDocumentAttribute,
		keywords, NSKeywordsDocumentAttribute,
		[propsAuthor stringValue], NSAuthorDocumentAttribute,
		[propsCompany stringValue], NSCompanyDocumentAttribute,
		[propsCopyright stringValue], NSCopyrightDocumentAttribute,
		[propsTitle stringValue], NSTitleDocumentAttribute,
		[propsSubject stringValue], NSSubjectDocumentAttribute,
		[propsComment stringValue], NSCommentDocumentAttribute,
		[propsEditor stringValue], NSEditorDocumentAttribute,
		/*
		NOTE: encoding is only used with .txt and .html file (see apple docs), so why include then in a dictionary for writing to a file? So we don't.
		//[NSNumber numberWithInt:[self fileEncoding], NSCharacterEncodingDocumentAttribute],
		*/
		nil];
	return dict;
}

#pragma mark -
#pragma mark ---- Initialize Text View, Encoding Stuff, Add and Remove Page Methods ----

// ******************* Initialize TextView ********************
// Initialise the first text view (these attributes will get shared across text views)

- (void)setupInitialTextViewSharedState
{
	NSTextView *textView = [self firstTextView];
	[textView setDelegate:self];
	[textView setSelectable:YES];
	[textView setEditable:YES];
	[textView setUsesFontPanel:YES];
	[textView setUsesRuler:YES];
	[textView setUsesFindPanel:YES];
	[textView setAllowsUndo:YES];
	[textView setAllowsDocumentBackgroundColorChange:NO];
	//	for new documents
	[textView setRichText:YES];
	[textView setImportsGraphics:YES];
	
	NSString *fType = [self currentFileType];
	//	Rich Text With Graphics
	if ([fType isEqualToString:RTFDDoc] 
				|| [fType isEqualToString:BeanDoc] 
				|| [fType isEqualToString:WebArchiveDoc])
	{
		[textView setRichText:YES];
		[textView setImportsGraphics:YES];
	} 
	//	Rich Text, No Graphics
	else if ([fType isEqualToString:DOCDoc]
				|| [fType isEqualToString:XMLDoc] 
				||  [fType isEqualToString:RTFDoc])
	{
			[textView setRichText:YES];
		[textView setImportsGraphics:NO];
	}
	//	Plain Text, No Graphics
	else if ([fType isEqualToString:TXTDoc] 
				|| [fType isEqualToString:HTMLDoc] 
				|| [fType isEqualToString:TXTwExtDoc])
	{
		[textView setRichText:NO];
		[textView setImportsGraphics:NO];
	}
}

//	if fileType is plain text, apply default plain text settings
-(void)plainTextSettings
{
	//	do this otherwise fontColorAttributes gets reset to black
	if ([self shouldUseAltTextColors]) { [self textColors:nil]; }
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//	retrieve the preferred font and size from user prefs
	NSString *plainTextFontName = [defaults valueForKey:@"prefPlainTextFontName"];
	float plainTextFontSize = [[defaults valueForKey:@"prefPlainTextFontSize"] floatValue];
	//	create that NSFont
	NSFont *aFont = [NSFont fontWithName:plainTextFontName size:plainTextFontSize];
	//	use system font on error
	if (aFont == nil) { aFont = [NSFont systemFontOfSize:[NSFont systemFontSize]]; }
	//	apply font attribute to textview (for new documents)
	[textStorage addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, [textStorage length])];
	//get paper size and figure textContainer size
	NSRect rect = NSZeroRect;
	rect.size = [printInfo paperSize];
	//	figure width of textContainer
	[self setViewWidth:(rect.size.width - [printInfo leftMargin]- [printInfo rightMargin])];
	//	figure height of textContainer
	[self setViewHeight:(rect.size.height - [printInfo topMargin] - [printInfo bottomMargin])];
	//	update PageView
	[self printInfoUpdated];
	plainTextFontName = nil;
	plainTextFontSize = 0.0;
	//	if encoding wasn't determined by OS X, so show sheet asking user to select encoding
	if (![self docEncoding] && ![[self currentFileType] isEqualToString:TXTwExtDoc])
	{
		[self performSelector:@selector(showEncodingSheet:) withObject:self afterDelay:0.0f];
	}
	
	//bug fix: without at least one attribute applied to the attributed string that represents the plain text string, the Inspector will treat the text attributes as 'float zero' and give crazy numbers, so we apply line spacing = 1.0, which was the default anyway (22 May 2007 BH)
	NSMutableParagraphStyle *theParagraphStyle = [textStorage attribute:NSParagraphStyleAttributeName 
				atIndex:0 effectiveRange:NULL];
	if (theParagraphStyle==nil) 
	{
		theParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	}
	else
	{
		theParagraphStyle = [[theParagraphStyle mutableCopyWithZone:[[self firstTextView] zone]]autorelease];
	}
	
	//	only apply default style from preferences to plain text (.txt) if box is checked 
	//	NOTE: for this, we ignore HTML and plain text with misc. extension files, since they are probably code of some sort
	if ([defaults boolForKey:@"prefApplyToText"] && [[self currentFileType] isEqualToString:TXTDoc])
	{
		//	get line spacing attribute from defaults in preferences
		switch ([defaults integerForKey:@"prefDefaultLineSpacing"]) //selectedTag binding
		{
			case 0: //single space
				[theParagraphStyle setLineHeightMultiple:1.0];
				break;
			case 2: //double space
				[theParagraphStyle setLineHeightMultiple:2.0];
				break;
			default: //1.5 space
				[theParagraphStyle setLineHeightMultiple:1.5];
				break;
		}
		//	get first line indent from defaults in preferences
		float firstLineIndent = 0.0;
		firstLineIndent = [defaults boolForKey:@"prefIsMetric"]
			? [[defaults valueForKey:@"prefDefaultFirstLineIndent"] floatValue] * 28.35 
			: [[defaults valueForKey:@"prefDefaultFirstLineIndent"] floatValue] * 72.0;
		if (firstLineIndent) [theParagraphStyle setFirstLineHeadIndent:firstLineIndent];
	} 
	//	if user prefs say to not add default style, just add one attribute to make sure all attributes are not default (==nil), which messes up inspector
	else
	{
		[theParagraphStyle setLineHeightMultiple:1.0];
	}
	//	make a dictionary of the attributes
	NSMutableDictionary *theTypingAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:theParagraphStyle, 
				NSParagraphStyleAttributeName, nil] autorelease];
	[textStorage addAttribute:NSParagraphStyleAttributeName value:theParagraphStyle range:NSMakeRange(0,[textStorage length])];
	[[self firstTextView] setTypingAttributes:theTypingAttributes];
	//	special case for text files because otherwise you end up widening window and then zooming out - 2 steps
	//	addendum: actually, it looks like we do the usual thing here; perhaps always should be second case for plain text?
	if ([defaults boolForKey:@"prefUseFitWidth"])
	{
		[theScrollView setIsFitWidth:YES];
		[theScrollView setIsFitPage:NO];
	}
	else
	{
		[theScrollView setIsFitWidth:NO];
		[theScrollView setIsFitPage:NO];
	}
	
}

#pragma mark -
#pragma mark ---- Encoding Methods ----

// ******************* Encoding Methods ********************

//	this (heavily modified) code is from TextEdit's EncodingManager.m
//	Return a sorted list of all available string encodings.
- (NSArray *)allAvailableStringEncodings {
#ifndef GNUSTEP
	NSMutableArray *allEncodings = nil;
	if (!allEncodings) {	// Build list of encodings, sorted, and including only those with human readable names
		const CFStringEncoding *cfEncodings = CFStringGetListOfAvailableEncodings();
		CFStringEncoding *tmp;
		int cnt, num = 0;
		while (cfEncodings[num] != kCFStringEncodingInvalidId) num++;	// Count
		tmp = malloc(sizeof(CFStringEncoding) * Num);
		memcpy(tmp, cfEncodings, sizeof(CFStringEncoding) * num);	// Copy the list
		allEncodings = [[NSMutableArray alloc] init];			// Now put it in an NSArray
		for (cnt = 0; cnt < num; cnt++)
		{
			NSStringEncoding nsEncoding = CFStringConvertEncodingToNSStringEncoding(tmp[cnt]);
			if (nsEncoding && [NSString localizedNameOfStringEncoding:nsEncoding])
			{
				NSMutableArray*	row = [NSMutableArray arrayWithCapacity:2];
				//the human-readable name
				[row addObject:[NSString localizedNameOfStringEncoding:nsEncoding]];
				//the int indicating the encoding
				[row addObject:[NSNumber numberWithUnsignedInt:nsEncoding]];
				[allEncodings addObject:row];
			}
		}
		free(tmp);
	}
	return [allEncodings autorelease];
#else
	return [NSArray array];
#endif
}

//	sort the encodings according to the human-readable name
int encSort(id array1, id array2, void *context)
{
	NSString *encName1 = [array1 objectAtIndex:0];
	NSString *encName2 = [array2 objectAtIndex:0];
	NSComparisonResult sortOrder = [encName1 caseInsensitiveCompare:encName2];
	return sortOrder;
}

-(IBAction)showEncodingSheet:(id)sender
{
	//	load popupButton menu with names of encodings (tag = NSStringEncoding)
	[encodingPopup removeAllItems];
	NSMenu *eMenu = [encodingPopup menu];
	//	get an array of objects, each of which is an array containing 1) encoding name string and 2) encoding name int
	NSArray *availableEncodings = [self allAvailableStringEncodings];
	//	sort the array
	NSArray *sortedEncodings; 
	//	these are references to the original array which increase the retain count; I assume they are released when the primary one is released
	sortedEncodings = [availableEncodings sortedArrayUsingFunction:encSort context:NULL]; //fixed double release 4 Aug 07 JH
	
	NSMenuItem *tempItem;
	int i;
	for (i = 0; i < [sortedEncodings count]; i++)
	{
		tempItem = [[NSMenuItem alloc] initWithTitle:[[sortedEncodings objectAtIndex:i] objectAtIndex:0]action:nil keyEquivalent:@""];
		[tempItem setTag:[[[sortedEncodings objectAtIndex:i] objectAtIndex:1] unsignedIntValue]];
		[tempItem setTarget:nil];
		unsigned enc = [[[sortedEncodings objectAtIndex:i] objectAtIndex:1] unsignedIntValue];
		if (!(enc==12 || enc==30)) { [eMenu addItem:tempItem]; } //special cases, see below
		[tempItem release];
		tempItem = nil;
	}
	//	place two popular encodings at top (add ISO-WinLatin?????)
	//	WinLatin-1
	NSString *localizedWinLatinName = [NSString localizedNameOfStringEncoding:NSWindowsCP1252StringEncoding]; //@"Western (Windows Latin 1)" = 12
	NSMenuItem *winLatinItem = [[NSMenuItem alloc] initWithTitle:localizedWinLatinName action:nil keyEquivalent:@""];
	[winLatinItem setTag:12];
	[winLatinItem setTarget:nil];
	[eMenu insertItem:winLatinItem atIndex:0];
	[winLatinItem release];
	//	MacRoman
	NSString *localizedMacRomanName = [NSString localizedNameOfStringEncoding:NSMacOSRomanStringEncoding]; //@"Western (Mac OS Roman)" = 30
	NSMenuItem *macRomanItem = [[NSMenuItem alloc] initWithTitle:localizedMacRomanName action:nil keyEquivalent:@""];
	[macRomanItem setTag:30];
	[macRomanItem setTarget:nil];
	[eMenu insertItem:macRomanItem atIndex:0];
	[encodingPopup selectItem:macRomanItem]; //make MacRoman the default
	[macRomanItem release];
	//	make cancellable after the first time shown (to allow cancel of change encoding...)
	if ([self docEncoding])
	{
		[encodingCancelButton setHidden:NO];
		[encodingOKButton setTitle:NSLocalizedString(@"Convert", @"button: Convert (translator: this button causes change of encoding of a plain text file)")];
	}
	//	show sheet which forces the user to choose an encoding for the text file, since apparently it could not be determined (with certainty) automatically
	[NSApp beginSheet:encodingSheet modalForWindow:docWindow modalDelegate:self didEndSelector:@selector(encodingSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
	[encodingSheet orderFront:nil];
	[self encodingPreviewAction:nil];
}

- (IBAction)closeEncodingSheet:(id)sender
{
	//	pass return code to delegate
	[NSApp endSheet:encodingSheet returnCode:1];
	[encodingSheet orderOut:sender];
}

- (IBAction)closeEncodingSheetWithCancel:(id)sender
{
	//	pass return code to delegate
	[NSApp endSheet:encodingSheet returnCode:0];
	[encodingSheet orderOut:sender];
}

-(IBAction)encodingSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	//	the user selected an encoding and pressed 'choose' (not 'cancel')
	if (returnCode==1)
	{
		//	if no encoding yet, use the one the user selected
		if (([[self currentFileType] isEqualToString:TXTDoc] 
					|| [[self currentFileType] isEqualToString:HTMLDoc]) 
					&& ![self docEncoding])
		{
			//	set doc encoding to equal item tag, which was NSStringEncoding id number
			[self setDocEncoding:[[encodingPopup selectedItem] tag]];
			[self setDocEncodingString:[[encodingPopup selectedItem] title]];
			NSError *encError = nil;
			NSString *aString = [[NSString alloc] initWithContentsOfFile:[self fileName] encoding:[self docEncoding] error:&encError];
			if (aString != nil)
			{
				[[layoutManager textStorage] replaceCharactersInRange:NSMakeRange(0,[[layoutManager textStorage] length]) withString:aString];
			}	
			[aString release];
			aString = nil;
			[self setDocEdited:NO];
			[[self undoManager] removeAllActions];
			[self plainTextSettings];
			//	alert user upon what is most likely an encoding error at this point
			if (encError)
			{
				NSString *docName = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"firstLevelOpenQuote", nil), [self displayName], NSLocalizedString(@"firstLevelCloseQuote", nil)]; 
				[alertSheet setMessageText:[NSString stringWithFormat:NSLocalizedString(@"The encoding chosen for the document %@ may not be appropriate.", @"alert title: The encoding chosen for the document (document name inserted at runtime--note: no space after variable)may not be appropriate."), docName]];
				[alertSheet setInformativeText:NSLocalizedString(@"Close the document and reopen it with another encoding.", @"alert text: Close the document and reopen it with another encoding.")];
				[alertSheet runModal];            		
			}
		}
		//	if there is already an encoding, convert to the encoding the user selected
		//	NOTE: nothing really happens to the attributed string, just [self docEncoding] is set for when the document is saved to file
		else
		{
			//	ask if user wants to backup the original document
			int choice = NSAlertDefaultReturn;
			NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Do you want to create a backup of the original document before changing the encoding?", @"alert title: Do you want to create a backup of the original document before changing the encoding?")];
			NSString *theInformativeString = NSLocalizedString(@"You might want to preserve the original in case of problems.", @"alert text: You might want to preserve the original in case of problems.");
			choice = NSRunAlertPanel(title, 
									 theInformativeString,
									 NSLocalizedString(@"Backup", @"button: Backup"),
									 nil, 
									 NSLocalizedString(@"Don\\U2019t Backup", @"button: Don't Backup"));
			if (choice==NSAlertDefaultReturn) { // 1
				[self backupDocumentAction:nil];
			} else if (choice==NSAlertOtherReturn) {
				//continue w/o backup
			}
			[[self undoManager] beginUndoGrouping];
			[[[self undoManager] prepareWithInvocationTarget:self] setDocEncoding:[self docEncoding]];
			[[[self undoManager] prepareWithInvocationTarget:self] setDocEncodingString:[self docEncodingString]];
			[[self undoManager] endUndoGrouping];
			[[self undoManager] setActionName:NSLocalizedString(@"Change Encoding", @"undo action: Change Encoding.")];
			[self setDocEncoding:[[encodingPopup selectedItem] tag]];
			[self setDocEncodingString:[[encodingPopup selectedItem] title]];
			[self setDocEdited:YES];
		}
	}
}

-(IBAction)changeEncodingAction:(id)sender
{
	//	get rid off the infoSheet before showing encoding sheet
	[NSApp endSheet:infoSheet];
	[infoSheet orderOut:sender];
	[self showEncodingSheet:nil];
}

-(IBAction)encodingPreviewAction:(id)sender
{
	//	Whenever the user selects an encoding from the popup button menu, the text file is reloaded with the encoding and displayed in a small text view 'preview' window on the sheet so the user can see whether the encoding is really appropriate.
	NSError *encError = nil;
	//	no encoding means just opening file (encoding not yet determined)
	if (![self docEncoding])
	{
		NSString *aString = [[NSString alloc] initWithContentsOfFile:[self fileName] encoding:[[encodingPopup selectedItem] tag] error:&encError];
		// string for preview
		if (aString != nil)
		{
			NSString *previewString = nil;
			//	if the string is long, just load about 5 pages worth
			if ([aString length] > 5000) { previewString = [NSString stringWithString:[aString substringWithRange:NSMakeRange(0, 5000)]]; } 
			else { previewString = [NSString stringWithString:aString]; }
			
			[[encodingPreviewTextView textStorage] replaceCharactersInRange:NSMakeRange(0,[[encodingPreviewTextView textStorage] length]) withString:previewString];
		}
		//	couldn't get a string for preview
		else
		{
			NSString *infoText = [NSString stringWithFormat:NSLocalizedString(@"The encoding \\U2018%@\\U2019 is not valid for this text. Please try another encoding.", @"The encoding '(localized encoding name automatically inserted at runtime)' is not valid for this text. Please try another encoding."), [[encodingPopup selectedItem] title]];
			[[encodingPreviewTextView textStorage] replaceCharactersInRange:NSMakeRange(0,[[encodingPreviewTextView textStorage] length]) withString:infoText];
		}
		[aString release];
		aString = nil;
	}
	//	encoding exists; we want to change it
	else
	{
		NSString *aString = [NSString stringWithString:[textStorage string]];
		if ([aString canBeConvertedToEncoding:[[encodingPopup selectedItem] tag]])
		{
			NSString *previewString = nil;
			
			//if the string is long, just load about 5 pages worth
			if ([aString length] > 5000) { previewString = [NSString stringWithString:[aString substringWithRange:NSMakeRange(0, 5000)]]; }
			else { previewString = [NSString stringWithString:aString]; }
			
			[[encodingPreviewTextView textStorage] replaceCharactersInRange:NSMakeRange(0,[[encodingPreviewTextView textStorage] length]) withString:previewString];
			[encodingOKButton setEnabled:YES];
		}
		else
		{
			NSString *infoText = [NSString stringWithFormat:NSLocalizedString(@"The encoding \\U2018%@\\U2019 is not valid for this text. Please try another encoding.", @"The encoding '(localized encoding name automatically inserted at runtime)' is not valid for this text. Please try another encoding."), [[encodingPopup selectedItem] title]];
			[[encodingPreviewTextView textStorage] replaceCharactersInRange:NSMakeRange(0,[[encodingPreviewTextView textStorage] length]) withString:infoText];
			[encodingOKButton setEnabled:NO];
		}
	}
}

#pragma mark -
#pragma mark ---- Add and Remove Page Methods ----

// ******************* Add and Remove Page Methods ********************

- (void)addPageWithFlag:(BOOL)isFirstPage
{
    NSTextContainer *textContainer;
	NSArray			*textContainers = [[self layoutManager] textContainers];
    PageView		*pageView = [theScrollView documentView];
		    
    //	figure size and position for textContainer
    NSRect frame = NSInsetRect([pageView bounds], 0.0, 0.0);
    frame.origin.x = [printInfo leftMargin] + [self pageSeparatorLength];
    frame.size.height = viewHeight;
    frame.size.width = viewWidth;
    
    //	create and configure NSTextContainer
    textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(frame.size.width, frame.size.height)];
    [textContainer setWidthTracksTextView:YES];
    [textContainer setHeightTracksTextView:YES];
	//	fix 'bug' where settings left margin to .5 yields .57, etc. (padding was being added)
	//	5 Oct 2007
	[textContainer setLineFragmentPadding:0.0];
	
	//pageCount is used just below to position the added textView/container; when switching view modes, we add the first multiple page view page before getting rid of the continuous text view (when isFirstPage flag is positive) to preserve the shared textView state, so we have to pretend the continuous view isn't there when adding the first page of the multiple page view.
	int pageCount = isFirstPage ? ([textContainers count] - 1) : [textContainers count] ; 
		
	//	create and configure NSTextView	
	NSTextView *textView = [[NSTextView alloc] initWithFrame:[self textRectForPageNumber:pageCount] textContainer:textContainer];
    [textView setMinSize:NSMakeSize(frame.size.width, frame.size.height)];
    [textView setMaxSize:NSMakeSize(frame.size.width, frame.size.height)];
    [textView setHorizontallyResizable:NO];
    [textView setVerticallyResizable:NO];
	
	if ([[theScrollView documentView] isKindOfClass:[PageView class]])
	{	
		//	add a 'page'
		[pageView addSubview:textView];
		[[self layoutManager] addTextContainer:textContainer];
		[pageView setNeedsDisplay:YES];
		//	recalculate and refresh image of pages on screen
		[pageView setNumberOfPages:[textContainers count]];
		[pageView recalculateFrame];
	}

	//	maintain ruler state
	if ([self areRulersVisible])
		[theScrollView setRulersVisible:YES];
	else
		[theScrollView setRulersVisible:NO];

	[textView release];
    [textContainer release];
	[self liveWordCount:nil];
}

- (void)removePage
{	
	NSArray			*textContainers = [[self layoutManager] textContainers];
    NSTextContainer *lastContainer = [textContainers lastObject];
    PageView		*pageView = [theScrollView documentView];
	
	[[lastContainer textView] removeFromSuperview];
	[[lastContainer layoutManager] removeTextContainerAtIndex:[textContainers count] - 1];
	[pageView setNumberOfPages:[textContainers count]];
	[pageView recalculateFrame];
	
	//	maintain ruler state
	if (areRulersVisible) {
		[theScrollView setRulersVisible:YES];
	} else {
		[theScrollView setRulersVisible:NO];
	}
	
	[pageView setNeedsDisplay:YES];
	[self liveWordCount:nil];
	
	textContainers = nil;
	lastContainer = nil;
	pageView = nil;
}


#pragma mark -
#pragma mark ---- textView & layoutManager delegate methods ----

//taken from TextEdit, basically
- (void)layoutManager:(NSLayoutManager *)lm	
			didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer
			atEnd:(BOOL)layoutFinishedFlag
{
    if (![self isTerminatingGracefully])
	{
		if ([self hasMultiplePages])
		{
			NSArray *containers = [layoutManager textContainers];
			// layout not finished or no final container, so add page
			if (!layoutFinishedFlag || (textContainer == nil))
			{
				NSTextContainer *lastContainer = [containers lastObject];
				// add a new page if the newly full container is the last container or non-existant.
				if ((textContainer == lastContainer) || (textContainer == nil))
				{
					//only if glyphs are laid in the last container (temporary solution for 3729692, until AppKit makes something better available.)
					if ([layoutManager glyphRangeForTextContainer:lastContainer].length > 0) { [self addPageWithFlag:NO]; }
				}
			}
			// layout is done and it all fit.  See if we can axe some pages.
			else
			{
				unsigned lastUsedContainerIndex = [containers indexOfObjectIdenticalTo:textContainer];
				unsigned numContainers = [containers count];
				while (++lastUsedContainerIndex < numContainers)
				{
					//bugfix: automatically removing pages because of resizing an image causes an objectAtIndex: out of bounds message (a page is created when an image at the bottom of one pages is sized too big, then that created page is removed when the image is resized small again)
					if (![imageSheet isVisible])
					{
						//NOTE: in certain instances, removing a page will give you an out of bounds error; for example: deleting text at the bottom of a page causing text on next page to be drawn to previous container and next page destroyed. This causes NSCFArray out of bounds error. Never could figure out why, but Text Edit sends the same message to the console, so I'm going to let it go.
						[self removePage];
					}
				}
			}
		}
		//	FIXME, but how?
		//	if we don't keep calling this, the temporary color attribute won't get set, although the layoutManager is aware when textViews are changed. Meh.
		[[self firstTextView] setDelegate:self];
		//	this tells Bean the document is no longer empty and should not be closed upon opening another doc
		if (isTransientDocument)
		{
			if ([[layoutManager textStorage] length] > 0) { [self setIsTransientDocument:NO]; }
		}
	}
}

//	this retains the typingAttributes, which are ordinarilly reset upon pasting an attachment (cos of a bug)
//	also fixes a bug with NSTextList which resets font to Lucida Grande
- (NSDictionary *)textView:(NSTextView *)aTextView
			shouldChangeTypingAttributes:(NSDictionary*)oldTypingAttributes
			toAttributes:(NSDictionary *)newTypingAttributes
{
	//	the if statement prevents an inserted text attachment from causing nil text attributes to follow
	if ([newTypingAttributes objectForKey:NSAttachmentAttributeName])
	{
		return oldTypingAttributes;
	}
	
	//	here we save the typingAttributes so that when an attachment is pasted in replaceCharactersInRange in the textStorage, it is overlaid first with the typingAttributes instead of nil attributes, which makes the inspector controls go crazy among other things
	if (![[textStorage oldAttributes] isEqualTo:newTypingAttributes])
	{
		[textStorage setOldAttributes:newTypingAttributes];
	}
	
	//	this is a fix for a bug in NSTextList #5065130 that causes font to be reset to Lucida Grande
	//	code is by Philip Dow (www.cocoabuilder.com 15 March 2007)

	NSParagraphStyle *paragraphStyle = [newTypingAttributes objectForKey:NSParagraphStyleAttributeName];
	
	if ( paragraphStyle != nil )
	{
		NSArray *textLists = [paragraphStyle textLists];
		if ( [textLists count] != 0 )
		{
			NSRange theSelectionRange = [[self firstTextView] selectedRange];
			if ( theSelectionRange.location >= 1 )
			{
				unichar aChar = [[[self firstTextView] string] characterAtIndex:theSelectionRange.location-1];
				if ( aChar == NSTabCharacter ) // -- and it seems to always be the case for the bug we're dealing with
				{
					NSFont *previousFont = [oldTypingAttributes objectForKey:NSFontAttributeName];
					if ( previousFont != nil )
					{
						NSMutableDictionary *betterAttributes = [[newTypingAttributes mutableCopyWithZone:[self zone]] autorelease];
						[betterAttributes setObject:previousFont forKey:NSFontAttributeName];
						return betterAttributes;
					}
				}
			}
		}
	}
	
	return newTypingAttributes;
	
	//	this was what we used to do (fix by Omni, refined by Keith Blount)...just here for historical purposes
	//	return [newTypingAttributes objectForKey:NSAttachmentAttributeName] ? oldTypingAttributes : newTypingAttributes;
}

- (BOOL)textView:(NSTextView *)textView 
			shouldChangeTextInRange:(NSRange)affectedCharRange
			replacementString:(NSString *)replacementString;
{
	//based on smart quote sample code is by Andrew C. Stone from the web article:
	//http:(removethis)//www.stone.com/The_Cocoa_Files/Smart_Quotes.html

	/* completely rewrote this delegate method to solve a number of bugs (redo in plain text docs wasn't working, typingAttributes
	were disappearing at the beginning of empty lines or empty docs); removed code extraneous to our purpose from the original code
	revised 9 June 2007 BH*/

	//	no replacementString means attributes change only, so skip the other stuff
	if (replacementString == nil) return YES;
	
	//	if typing smart quotes over smart quotes, can set up a loop that will crash Bean, so this (resurrected) code avoids the loop
	if (registerUndoThroughShouldChange)
	{
		[self setRegisterUndoThroughShouldChange:NO];
		return YES;
	}
	
	//	without resetting typingAttributes when isRichText==NO, you get no consistancy at all...why?
	//	19 July 2007 JH: this might be a symptom of a 'feature' of the text system--namely, that whenever you insert a character at the start of a paragraph, apparently even for plain text, insofar as the text object does plain text, the rest of the paragraphh adopts the paragraph attributes of the first character. If that object is, for instance, a drag'n'dropped image file, then there are NO attributes, which means you get nil for all the applied attribute values. Which is not good. Similarly, because NSText uses a mutable attributed string to hold it's contents, random strings inserted at the head of a paragraph will overlay their nil paragraph attributes onto the rest of the text in the paragraph.
	//	Text Edit and other NSText based apps all seem to do this, which I would consider undesirable behavior. IMHO, the desireable behavior would be, if the inserted character at the start of a paragraph has nil for attributes, it adopts those of the following character, then fixAttributesInRange is run to even out any problems. But perhaps Apple wanted to maintain a consistent behavior across the board.
	//	note: now that we've moved to textView:insertText instead of textStorage:replaceCharactersInRange, is this needed? 10 Sept 07 JH
	if (replacementString && ![[self firstTextView] isRichText])
	{
		if (replacementString) [[self firstTextView] setTypingAttributes:[self oldAttributes]];
	}
	
	// should we need to change the string to insert, use this mutable string to hold the new values:
	// if it's non-nil when we get done, we want to use *s instead of the replacementString!
	NSMutableString *s = nil;
	//	we need this info to deal with French (France) and French Canadian Smart Quotes
	int quoteTag = [self smartQuotesStyleTag];

	//we want to pass the undo straight through so that it is not altered by these lines of code 
	if (![[self undoManager] isUndoing])
	{
		// replacementString length == 1 could mean smartQuotes processing is needed
		if ([replacementString length]==1 && [self shouldUseSmartQuotes])
		{
			// this is what is in our text object before anything is added:
			NSString *text = [[textView textStorage] string];
			// We want to know if we are at the very first character:
			unsigned int textLength = [text length];
			unichar affectedChar;

			/********************** Smart Quotes Option 1: 3-WAY TOGGLE ****************************************/
			// 3 way toggle for quoation marks when one is typed over another:  plain -> open -> closed -> plain
			// this is where user needs, for instance, straight quotes instead of curvy to represent code, etc.
		
			unichar theReplacementChar = [replacementString characterAtIndex:0];
			if (affectedCharRange.length == 1) affectedChar = [text characterAtIndex:affectedCharRange.location];
			
			//	if a single quote is being typed over a single quote, or a double over a double, rotate the quote styles
			//	revised from previous method, which was causing a loop (insertText was calling shouldChange..., which was repeatedly using code below
			if (affectedCharRange.length == 1
						&& ((theReplacementChar == SINGLE_QUOTE
								&& (affectedChar == SINGLE_OPEN_QUOTE 
									|| affectedChar == SINGLE_CLOSE_QUOTE 
									|| affectedChar == SINGLE_QUOTE))

							|| (theReplacementChar == DOUBLE_QUOTE
								&& (affectedChar == DOUBLE_OPEN_QUOTE 
									|| affectedChar == DOUBLE_CLOSE_QUOTE 
									|| affectedChar == DOUBLE_QUOTE))))
			
			{
			
				// they had an open quote -> make it a closed one
				if (affectedChar == DOUBLE_OPEN_QUOTE || affectedChar == SINGLE_OPEN_QUOTE)
				{
					s = [NSString stringWithFormat:@"%C", theReplacementChar == DOUBLE_QUOTE ? DOUBLE_CLOSE_QUOTE : SINGLE_CLOSE_QUOTE];

				}
				// they had a closed quote -> make it straight
				else if (affectedChar == DOUBLE_CLOSE_QUOTE || affectedChar == SINGLE_CLOSE_QUOTE)
				{
					s = [NSString stringWithFormat:@"%C", theReplacementChar == DOUBLE_QUOTE ? DOUBLE_QUOTE : SINGLE_QUOTE];
				}
				// they had a straight quote -> make it open
				else if (affectedChar == SINGLE_QUOTE || affectedChar == DOUBLE_QUOTE)
				{
					s = [NSString stringWithFormat:@"%C", theReplacementChar == SINGLE_QUOTE ? SINGLE_OPEN_QUOTE : DOUBLE_OPEN_QUOTE];
				}
				//	we use this so that insertion of a smart quote below using insertText, which calls shouldChangeTextInRange to register the undo, does not call this very section of code again, which will cause a loop to occur, and cause Bean to crash 12 Sept 2007 JH
				[self setRegisterUndoThroughShouldChange:YES];
			}
			/********************** Smart Quotes Option 2: INSERT SMART QUOTES ****************************************/
			// otherwise check first char of replacement string
			else
			{
				NSCharacterSet *startSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
				unichar theChar = [replacementString characterAtIndex:0];
				unichar previousChar, c;

				// use preceding character to determine open or closed quote
				if (affectedCharRange.location == 0 || textLength==0) { previousChar = 0; } // first char
				else { previousChar = [text characterAtIndex:affectedCharRange.location - 1]; }

				// if STRAIGHT QUOTE , produce open or closed quote
				if ((theChar == SINGLE_QUOTE) || (theChar == DOUBLE_QUOTE))
				{

					if (previousChar == 0x00A0) //non-breaking space for French (special case) usually needs close quote 18 Aug 07
					{
						c = (theChar == SINGLE_QUOTE ? SINGLE_CLOSE_QUOTE : DOUBLE_CLOSE_QUOTE);
					}
					else if (previousChar == 0 
								|| [startSet characterIsMember:previousChar] 
								|| (previousChar == DOUBLE_OPEN_QUOTE && theChar == SINGLE_QUOTE) 
								|| (previousChar == SINGLE_OPEN_QUOTE && theChar == DOUBLE_QUOTE))
					{
						c = (theChar == SINGLE_QUOTE ? SINGLE_OPEN_QUOTE : DOUBLE_OPEN_QUOTE);
					}
					else
					{
						c = (theChar == SINGLE_QUOTE ? SINGLE_CLOSE_QUOTE : DOUBLE_CLOSE_QUOTE);
					}
					//string is Smart Quote for insertion later in method...
					s = [NSMutableString stringWithString:[NSString stringWithFormat:@"%C", c]];
				}
				//if French (France) or French Canadian smart quotes (and punctuation) selected, add the extra spacing French typography needs for ?!;: (yes, I know non-breaking spaces are not the same as the native partial cadratins)
				else if (quoteTag == 11)
				{
					switch (theChar) 
					{
						case 0x0021: //exclamation point
							{
								s = nil;
								s = [NSString stringWithFormat:@"%C%C", 0x00A0, theChar];
								break;
							}
						case 0x003F: //question mark
						{
							s = nil;
							s = [NSString stringWithFormat:@"%C%C", 0x00A0, theChar];
							break;
						}
						case 0x003A: //colon
						{
							s = nil;
							s = [NSString stringWithFormat:@"%C%C", 0x00A0, theChar];
							break;
						}
						case 0x003B: //semicolor
						{
							s = nil;
							s = [NSString stringWithFormat:@"%C%C", 0x00A0, theChar];
							break;
						}
						default:
							break;
					}
				}
				//	Canadian French just needs spacing for the :
				else if (quoteTag == 12)
				{
					if (theChar == 0x003A) //colon
					{
						s = nil;
						s = [NSString stringWithFormat:@"%C%C", 0x00A0, theChar];
					}
				}
				
			}
		}
		
		//	we insert s, the new Smart Quotes replacementString, here
		//	note: do nothing if 'straight' smart quotes (tag==1) since there is no need
		//	A. Stone says: 
		//	Ideally, this method [shouldChangeText...] would return the desired attributedString, but since it doesn't, we insert the changes directly
		
		if ( s && !([self smartQuotesStyleTag]==1) )
		{
			//	if French style smart quotes, insert non-breaking spaces (yes, I know they are not partial em-spaces, but they prevent inconvenient line breaks)
			if (quoteTag == 11 || quoteTag == 12)
			{
				unichar frChar = [s characterAtIndex:0];
				if (frChar == 0x00AB) // <<
				{
					s = nil;
					s = [NSString stringWithFormat:@"%C%C", 0x00AB, 0x00A0];
				}
				else if (frChar == 0x00BB) // >>
				{
					s = nil;
					s = [NSString stringWithFormat:@"%C%C", 0x00A0, 0x00BB];
				}
				frChar = nil;
			}
			
			// 25 Aug 2007 After studying the insertText method of NSTextView in GnuStep, which calls the sequence 1) shouldChangeTextInRange 2) replaceCharactersInRange 2) didChangeText which we do here, I decided to just use it; also, the problem of text being inserted into an empty textStorage and having no attributes is solved because NSTextView calls its own replaceCharactersInRange method which overlays its typing attributes, so the bugfix we added becomes unnecessary			
			[[self firstTextView] insertText:s];
			
			//zero out s
			s = nil;
			return NO;
		}
	}
	//this lets the text system insert the text as typed...
	return YES;
}

// manually changes straight quotes to smart quotes and vice versa
- (IBAction)convertQuotesAction:(id)sender
{
	NSString	*text = [[[self firstTextView] textStorage] string];
	NSArray		*selRanges = nil;
	NSValue		*rangeAsValue, *aRange, *bRange;
	
	if ([[self firstTextView] selectedRange].length==0)
	{
		bRange = [NSValue valueWithRange:NSMakeRange(0, [textStorage length])];
		selRanges = [NSArray arrayWithObject:bRange];
	}
	else
	{
		selRanges = [[self firstTextView] selectedRanges];
	}
	//	count selected ranges and add them
	NSEnumerator *rangeEnumerator = [selRanges objectEnumerator];
	unsigned int i;
	unichar c = nil;

	//	this prepares undo by feeding it strings to be inserted so that it will remember the changed ranges (we don't know what strings will be inserted at this point, but we do know the string lengths).
	NSEnumerator *rangeEnumerator2 = [selRanges objectEnumerator];
	NSMutableArray *replacementStrings = [NSMutableArray arrayWithCapacity:0];
	while ((aRange = [rangeEnumerator2 nextObject]) != nil)
	{
		[replacementStrings addObject:[[textStorage string] substringWithRange:[aRange rangeValue]]];
	}
	//	for undo
	//	perhaps change undo so it works through invocation?
	[[self firstTextView] shouldChangeTextInRanges:selRanges replacementStrings:replacementStrings];
	replacementStrings=nil;
	[[self undoManager] beginUndoGrouping];
	//	bracket for efficiency
	[textStorage beginEditing]; 
	
	while ((rangeAsValue = [rangeEnumerator nextObject]) != nil)
	{
		NSRange range = [rangeAsValue rangeValue];
		//	we have to send wordCountForString an attributed string because nextWordFromIndex only works on attributed strings
		NSString *rangeString = [[NSString alloc] initWithString:[text substringWithRange:range]];
		NSCharacterSet *startSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		
		for (i = 0; i < range.length; i++)
		{
			unichar theChar = [rangeString characterAtIndex:i];
			unichar previousChar;
			// find out the character which preceeds this one - context is everything!
			if(i == 0)
			{
				if (range.location == 0 || [text length]==0) { previousChar = 0; } //if first char
				else { previousChar = [text characterAtIndex:range.location - 1]; }
			} 
			else
			{
				previousChar = [text characterAtIndex:(range.location + i)-1];
			}	
			//	convert to smart quotes menu item
			if ([sender tag]==0)
			{
				// When we encounter a straight quote, we decide whether it should be open or closed:
				if ((theChar == SINGLE_QUOTE) || (theChar == DOUBLE_QUOTE)) 
				{
					if (previousChar == 0x00A0) //non-breaking space (Bean places this before closing quote for French smart quotes)
					{
						c = (theChar == SINGLE_QUOTE ? SINGLE_CLOSE_QUOTE : DOUBLE_CLOSE_QUOTE);
					}
					else if (previousChar == 0 || [startSet characterIsMember:previousChar] 
								|| (previousChar == DOUBLE_OPEN_QUOTE && theChar == SINGLE_QUOTE) 
								|| (previousChar == SINGLE_OPEN_QUOTE && theChar == DOUBLE_QUOTE))
					{
						c = (theChar == SINGLE_QUOTE ? SINGLE_OPEN_QUOTE : DOUBLE_OPEN_QUOTE);
					}
					else
					{
						c = (theChar == SINGLE_QUOTE ? SINGLE_CLOSE_QUOTE : DOUBLE_CLOSE_QUOTE);
					}
					
					if (c) [textStorage replaceCharactersInRange:NSMakeRange(range.location + i,1) withString:[NSString stringWithFormat:@"%C", c]];
					c = nil;
				}
			}
			//	convert to straight quotes menu action
			else
			{
				// When we encounter an open or close quote, we convert it to straight:
				if ((theChar == SINGLE_OPEN_QUOTE) || (theChar == SINGLE_CLOSE_QUOTE))
				{
					c = SINGLE_QUOTE;
				}
				if ((theChar == DOUBLE_OPEN_QUOTE) || (theChar == DOUBLE_CLOSE_QUOTE))
				{
					c = DOUBLE_QUOTE;
				}
				if (c) 
				{
					[textStorage replaceCharactersInRange:NSMakeRange(range.location + i,1) withString:[NSString stringWithFormat:@"%C", c]];
				}
				c = nil;
			}
		}
		[rangeString release];
	}
	//	close bracket
	[textStorage endEditing];
	[[self undoManager] endUndoGrouping];
	//	end undo setup
	[[self firstTextView] didChangeText];
	//	name undo action, based on tag of control
	[[self undoManager] setActionName:NSLocalizedString(@"Convert Quotes", @"undo action: Convert Quotes.")];
}

-(IBAction)setSmartQuotesStyleAction:(id)sender
{
	//	get user defaults for later
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int smartQuotesType = [defaults integerForKey:@"prefSmartQuotesStyleTag"]; 
	//	NOTE: initially I thought this should be set by localization, but this way user can switch from French to English easily, etc. Many Bean users seem to be bilingual.
	switch (smartQuotesType)
	{
		case 0: //curly
			SINGLE_OPEN_QUOTE = 0x2018;
			SINGLE_CLOSE_QUOTE = 0x2019;
			DOUBLE_OPEN_QUOTE = 0x201C;
			DOUBLE_CLOSE_QUOTE = 0x201D;
			break;
		case 3: //French (modern) note: this is not French :-(
			SINGLE_OPEN_QUOTE = 0x201C; //double-6 high
			SINGLE_CLOSE_QUOTE = 0x201D; //double-9 high
			DOUBLE_OPEN_QUOTE = 0x0AB; //outward pointing brackets
			DOUBLE_CLOSE_QUOTE = 0x00BB;
			break;		
		case 4: //German (modern), Danish, and Croatian
			SINGLE_OPEN_QUOTE = 0x203A; //inward pointing brackets
			SINGLE_CLOSE_QUOTE = 0x2039;
			DOUBLE_OPEN_QUOTE = 0x00BB;//inward pointing double brackets
			DOUBLE_CLOSE_QUOTE = 0x00AB;
			break;
		case 5: //French, Greek, Spanish, Albanian, Turkish, and Swiss OK! note: *NOT* French
			SINGLE_OPEN_QUOTE = 0x2039; //outward pointing brakets
			SINGLE_CLOSE_QUOTE = 0x203A;
			DOUBLE_OPEN_QUOTE = 0x00AB;//outward pointing double brackets
			DOUBLE_CLOSE_QUOTE = 0x00BB;
			break;
		case 6: //Bulgarian, Czech, German (old), Icelandic, Lithuanian, Slovak, Serbian, and Romanian
			SINGLE_OPEN_QUOTE = 0x201A; //low 9
			SINGLE_CLOSE_QUOTE = 0x2018; //high 6
			DOUBLE_OPEN_QUOTE = 0x201E;	//double low-9
			DOUBLE_CLOSE_QUOTE = 0x201C; //double high-6
			break;
		case 7: //Afrikaans, Dutch, Polish
			SINGLE_OPEN_QUOTE = 0x201A; //low 9
			SINGLE_CLOSE_QUOTE = 0x2019; //high 9
			DOUBLE_OPEN_QUOTE = 0x201E;	//double low-9
			DOUBLE_CLOSE_QUOTE = 0x201D; //double high-9
			break;
		case 8: //Finnish, Swedish
			SINGLE_OPEN_QUOTE = 0x2019; //high 9
			SINGLE_CLOSE_QUOTE = 0x2019; //high 9
			DOUBLE_OPEN_QUOTE = 0x201D;	//double high-9
			DOUBLE_CLOSE_QUOTE = 0x201D; //double high-9
			break;
		case 9: //Norwegian NOTE: French compatible!
			SINGLE_OPEN_QUOTE = 0x2018; //high 6
			SINGLE_CLOSE_QUOTE = 0x2019; //high 9
			DOUBLE_OPEN_QUOTE = 0x00AB;	//brackets
			DOUBLE_CLOSE_QUOTE = 0x00BB;
			break;
		case 10: //Chinese, Japanese
			SINGLE_OPEN_QUOTE = 0x300E; //square brakets
			SINGLE_CLOSE_QUOTE = 0x300F;
			DOUBLE_OPEN_QUOTE = 0x300C;
			DOUBLE_CLOSE_QUOTE = 0x300D;
			break;				
		case 11: //French - space for guillemets is added in shouldChangeTextInRange
			SINGLE_OPEN_QUOTE = 0x2018; //high 6
			SINGLE_CLOSE_QUOTE = 0x2019; //high 9
			DOUBLE_OPEN_QUOTE = 0x00AB; //left outward double bracket
			DOUBLE_CLOSE_QUOTE = 0x00BB; //right outward double bracket
			break;
		case 12: //Canadian French
			SINGLE_OPEN_QUOTE = 0x2018; //high 6
			SINGLE_CLOSE_QUOTE = 0x2019; //high 9
			DOUBLE_OPEN_QUOTE = 0x00AB; //left outward double bracket
			DOUBLE_CLOSE_QUOTE = 0x00BB; //right outward double bracket
			break;		
		default: //straight (dumb qutoes) style, which == tag 1
			SINGLE_OPEN_QUOTE = 0x0027;
			SINGLE_CLOSE_QUOTE = 0x0027;
			DOUBLE_OPEN_QUOTE = 0x0022;
			DOUBLE_CLOSE_QUOTE = 0x0022;
			break;
		}		
	//	update quotes style since this can be changed by the user on the fly 22 Aug 2007 JH
	[self setSmartQuotesStyleTag:smartQuotesType];
}

- (void)textView:(NSTextView *)view 
			doubleClickedOnCell:(id <NSTextAttachmentCell>)cell
			inRect:(NSRect)rect
			atIndex:(unsigned)charIndex{
	
	//	if it's a picture, open the image slider resizing sheet
	
	if ([[[cell attachment] fileWrapper] isRegularFile])
	{
		NSData *theData = [[[cell attachment] fileWrapper] regularFileContents];
		NSImage *anImage = nil;
		//	and make an NSImage from them
		if (theData)
		{
			anImage = [[NSImage alloc] initWithData:theData];
		}	
		if (anImage)
		{
			//	position cursor just before clicked attachment
			[[self firstTextView] setSelectedRange:NSMakeRange(charIndex, 1)];
			[self showResizeImageSheetAction:nil];
			//	will need this later if the user cancels the resize action
			[self setImageSize:[anImage size]];

		}
		[anImage release];
	}
	//	otherwise, open the file in an external editor (note: any changes made will be overwritten when file is saved in Bean)
	else
	{
		BOOL success = NO;
		NSFileWrapper *fWrap = nil;
		fWrap = [[cell attachment] fileWrapper];
		//	get fileName of fileAttachment icon
		NSString *name = [fWrap filename];
		//	get path to file
		NSString *thePath = [[[self fileURL] path] stringByAppendingPathComponent:name];
		//	try to open it
		if (name && ![name isEqualToString:@""])
		{
			success = [[NSWorkspace sharedWorkspace] openFile:thePath];
		}
		if (!success)
		{
			NSBeep();
		}
	}
}

- (NSArray *)textView:(NSTextView *)view 
			writablePasteboardTypesForCell:(id <NSTextAttachmentCell>)cell
			atIndex:(unsigned)charIndex
{
    return [NSArray arrayWithObjects: NSTIFFPboardType, NSPDFPboardType, NSPICTPboardType, NSStringPboardType, NSFileContentsPboardType, nil];
}

- (BOOL)textView:(NSTextView *)view 
			//	made change from this to line below just to get rid of compiler warning...not sure how to really fix it
			//			was: writeCell:(id <NSTextAttachmentCell>)cell   
			writeCell:(NSTextAttachmentCell *)cell
			atIndex:(unsigned)charIndex
			toPasteboard:(NSPasteboard *)pboard
			type:(NSString *)type
{
    BOOL success = NO;
	id wrapper = [[cell attachment] fileWrapper];
	NSString *name = [wrapper filename];
	if ([type isEqualToString:NSFilenamesPboardType] && ![name isEqualToString:@""])
	{
        NSString *fullPath = [[[self fileURL] path] stringByAppendingPathComponent:name];
        [pboard setPropertyList:[NSArray arrayWithObject:fullPath] forType:NSFilenamesPboardType];
        success = YES;
    }
	//	write pictures to pasteboard as TIFF so that they can be, e.g. opened in Preview with 'New from Clipboard'
	if ([type isEqualToString:NSTIFFPboardType])
	{
		NSData *tiffData;
		//	'image not found in protocols' > recast cell as class not protocol
		if ([[cell image] isValid])
		{
			NSImage *theImage = [cell image];
			tiffData = [theImage TIFFRepresentation];
			[pboard declareTypes:[NSArray arrayWithObjects:NSTIFFPboardType, nil] owner:nil];
			[pboard setData:tiffData forType:NSTIFFPboardType];
			success = YES;
		}
		else
		{
			NSBeep();
		}
	}
    return success;
}

// if the selected ranges changes to include a text selection, show the selected word and character count in the status bar with blue text
- (NSArray *)textView:(NSTextView *)aTextView
		willChangeSelectionFromCharacterRanges:(NSArray *)oldSelectedCharRanges
		toCharacterRanges:(NSArray *)newSelectedCharRanges
{
	NSRange firstRange = [[newSelectedCharRanges objectAtIndex:0] rangeValue];
	//	if there is selected text
	if (firstRange.length)
	{
		NSEnumerator *rangeEnumerator = [newSelectedCharRanges objectEnumerator];
		NSValue *rangeAsValue;
		unsigned wordCnt = 0;
		unsigned charCnt = 0;
		//	count words and characters in each selected range, adding totals as we go
		while ((rangeAsValue = [rangeEnumerator nextObject]) != nil)
		{
			NSRange range = [rangeAsValue rangeValue];
			//	we have to send wordCountForString an attributed string because nextWordFromIndex only works on attributed strings
			NSAttributedString *tempStr = [[NSAttributedString alloc] initWithString:[[textStorage string] substringWithRange:range]];
			wordCnt += [self wordCountForString:tempStr];
			charCnt += [tempStr length];
			tempStr = @"";
			[tempStr release];
		}
		//	change status bar to reflect selected word and character totals
		NSString *liveWordCountString = [ [NSString alloc] initWithFormat:@"%@ %@ %@ %@", 
					NSLocalizedString(@" Selected Words:", @"status bar label for number of words of selected text: Selected Words:"),
					[self thousandFormatedStringFromNumber:[NSNumber numberWithInt:wordCnt]],
					NSLocalizedString(@" Selected Characters:", @"status bar label for number of characters of selected text: Selected Characters:"),
					[self thousandFormatedStringFromNumber:[NSNumber numberWithInt:charCnt]] ];
		[liveWordCountField setStringValue:liveWordCountString];
		[liveWordCountString release];
		[liveWordCountField setTextColor:[NSColor blueColor]];
		
		wordCnt = nil;
		charCnt = nil;	
	}
	//	if no selected text but status text is blue (=showing selected range), then reset usual word count
	else if ([[liveWordCountField textColor] isEqualTo:[NSColor blueColor]] && !firstRange.length)
	{
		[self liveWordCount:nil];
	}
	//	return the usual info
	return newSelectedCharRanges;
}

#pragma mark -
#pragma mark ---- Update Word Count And Alt Colors Upon Text Change  ----

// ******************* Text Did Change Notification ********************

- (void)textDidChange:(NSNotification *)notification
{
	//	we use our own isDirty flag
	[self setDocEdited:YES];
	//only autosave if text did change since last autosave
	[self setNeedsAutosave:YES];
	
	//	update the 'alternate' text colors if needed (without this method the 'temporary' attributes don't always get applied)
	if ([self shouldUseAltTextColors]) [self updateAltTextColors];
	
	//	a fix for a problem that also occurs in TextEdit: erasing all text leaves empty containers that don't go away until you type again
	NSArray *containers = [layoutManager textContainers];
	if ([[layoutManager textStorage] length] == 0)
	{
		while ([containers count] > 1) 
		{
			[self removePage];
		}
	}
	
	//	save edit location for Find > Previous Edit menu action
	NSRange editLocation;
	editLocation = [[self firstTextView] selectedRange];
	[self setSavedEditLocation:(editLocation.location + editLocation.length)];
}

// ******************* Update Alt Text Colors ********************

//	recolor text with temporary attributes (alternate colors for display when editing)
- (void) updateAltTextColors
{
	if (!altTextColor)
	{
		//	gets released in dealloc method
		altTextColor = [[NSDictionary alloc] initWithObjectsAndKeys:[self textViewTextColor], NSForegroundColorAttributeName, nil];
	}
	[layoutManager addTemporaryAttributes:altTextColor forCharacterRange:NSMakeRange(0, [[[self firstTextView] textStorage] length])];
	[[self firstTextView] setBackgroundColor:textViewBackgroundColor];
}

// ******************* Live Word Count ********************

-(IBAction)liveWordCount:(id)sender
{
	if ([self shouldDoLiveWordCount])
	{
		//	live word count	
		numberOfWords = [textStorage wordCount];
		numberOfChars =  [textStorage length];
		NSString *liveWordCountString;
		if ([self hasMultiplePages])
		{
			int numPages =[[[self layoutManager] textContainers] count];
			liveWordCountString = [[NSString alloc] initWithFormat:@"%@ %@ %@ %@ %@ %i", NSLocalizedString(@"Words:", @"Status bar label for number of words in document: Words:"), [self thousandFormatedStringFromNumber:[NSNumber numberWithInt:numberOfWords]], NSLocalizedString(@" Characters:", @"status bar label for number of characters in document: Characters:"), [self thousandFormatedStringFromNumber:[NSNumber numberWithInt:numberOfChars]], NSLocalizedString(@" Pages:", @"status bar label for number of pages in document: Pages:"), numPages];
			/*
			liveWordCountString = [[NSString alloc] initWithFormat:@"%@ %@ %@ %@ %@ %i", NSLocalizedString(@"Words:", @"Status bar label for number of words in document: Words:"), [self formatForThousands:numberOfWords], NSLocalizedString(@" Characters:", @"status bar label for number of characters in document: Characters:"), [self formatForThousands:numberOfChars], NSLocalizedString(@" Pages:", @"status bar label for number of pages in document: Pages:"), numPages];
			*/
			numPages = nil;
		}
		else
		{
			liveWordCountString = [[NSString alloc] initWithFormat:@"%@ %@ %@ %@", 
						NSLocalizedString(@"Words:", @"Status bar label for number of words in document: Words:"),
						[self thousandFormatedStringFromNumber:[NSNumber numberWithInt:numberOfWords]],
						NSLocalizedString(@" Characters:", @"status bar label for number of characters in document: Characters:"),
						[self thousandFormatedStringFromNumber:[NSNumber numberWithInt:numberOfChars]]];
			/*
			liveWordCountString = [[NSString alloc] initWithFormat:@"%@ %@ %@ %@", NSLocalizedString(@"Words:", @"Status bar label for number of words in document: Words:"), [self formatForThousands:numberOfWords], NSLocalizedString(@" Characters:", @"status bar label for number of characters in document: Characters:"), [self formatForThousands:numberOfChars]];
			*/
		}
		[liveWordCountField setStringValue:liveWordCountString];
		[liveWordCountString release];
		numberOfWords = nil;
		numberOfChars = nil;
		[liveWordCountField setTextColor:[NSColor blackColor]];
	}
}

//	borrowed from Smultron!
- (NSString *)thousandFormatedStringFromNumber:(NSNumber *)number
{
	return [thousandFormatter stringFromNumber:number];
}

/*
//	borrowed from Smultron text editor...used in updateWordCount method 
-(NSString *)formatForThousands:(int)aNumber
{
	NSNumber *numberAsObject = [[NSNumber alloc] initWithInt:aNumber];
	NSMutableString *numberString = [[NSMutableString alloc] initWithString:[numberAsObject stringValue]];
	[numberAsObject release];
	int positionInString = [numberString length] - 3;
	while (positionInString > 0)
	{
		[numberString insertString:@"," atIndex:positionInString];
		positionInString -= 3;
	}
	return [numberString autorelease];
}
*/

#pragma mark -
#pragma mark ---- Window and Scroll Methods ----

// ******************* constrainScroll ********************
//	tries to keep the insertion point positioned about 2/3 legnth vertically below title bar in clipView; avoids problem of where you are always looking at very bottom of screen when typing
//	NOTE: only adjusts view when cursor index is at END of file and no control mask keys are being pressed; this prevents the jittery-ness that made it unuseable in pageview mode
-(void)constrainScrollWithForceFlag:(BOOL)forceFlag
{
	//	forceFlag causes constrainScroll when it wouldn't otherwise do all the work (such as when there's no change in the y coord)
	if ([self hasMultiplePages] && [[self firstTextView] selectedRange].location > 1)
	{
		//	determine position of lineFragment in documentView: we scrollToPoint to this point later
		NSEvent *theEvent = [NSApp currentEvent];
		NSRect lineFragRect;
		NSTextView *text = [self firstTextView];
		//	upon [return], figure location of lineFrag for empty line and scroll (added 10 June 2007 BH)
		if ([theEvent type]==NSKeyDown && [theEvent keyCode]==36)
		{
			lineFragRect = [[text layoutManager] lineFragmentRectForGlyphAtIndex:[text selectedRange].location + [text selectedRange].length - 2 effectiveRange:nil];
			lineFragRect.origin.y = lineFragRect.origin.y + lineFragRect.size.height;
		}
		//	otherwise, figure location of lineFrag for wrapped line and scroll
		else
		{
			lineFragRect = [[text layoutManager] lineFragmentRectForGlyphAtIndex:[text selectedRange].location + [text selectedRange].length - 1 effectiveRange:nil];
		}
		
		// don't constrain scroll if adding to a text list...causes scrollview to 'jump' 11 Oct 2007 JH
		NSParagraphStyle *paragraphStyle = [[[self firstTextView] typingAttributes] objectForKey:NSParagraphStyleAttributeName];
		if ( paragraphStyle != nil )
		{
			NSArray *textLists = [paragraphStyle textLists];
			if ( [textLists count] != 0 )
			{	
				return;
			}
		}	
		
		int	lineFragPosY = lineFragRect.origin.y;
		//	only constrains scroll if (lineFrag pos has change AND cursor is near end of text) OR doc has just been loaded but is not yet visible
		if ((!(lineFragPosY==[self lineFragPosYSave]) 
					&& [text selectedRange].location > ([[self textStorage] length] - 10)) 
					|| forceFlag) 
		{
			//	determine which text container contains insertion point (selectedRange)
			NSArray *containers = [[self layoutManager] textContainers];
			NSTextContainer *indexContainer = [[self layoutManager] textContainerForGlyphAtIndex:[text selectedRange].location - 1 effectiveRange:nil withoutAdditionalLayout:YES];
			int indexContainerNumber = [containers indexOfObjectIdenticalTo:indexContainer];
			//	out of bounds error (textContainer does not yet exist for unlaid out text)
			if (indexContainerNumber > [containers count]) return;
			//	get value of 1/2 of clipView height
			NSSize clipViewSize = [[[theScrollView documentView] superview] frame].size;
			int halfClipViewHeight = clipViewSize.height / 2; 
			//	figure new location for scrollToPoint...about 1/2 down from top of window
			//below line change 20 Aug 2007 by adding scaleFactor of view, which makes it work just right!
			//float theNewOriginY = lineFragPosY + (([printInfo paperSize].height + 15) * indexContainerNumber - 1) - halfClipViewHeight + 100;
			float theNewOriginY = lineFragPosY + (([printInfo paperSize].height + 15) * indexContainerNumber - 1) - halfClipViewHeight / [theScrollView scaleFactor] + 100;
			if (theNewOriginY < 0) theNewOriginY = 0;
			[[theScrollView contentView] scrollToPoint:NSMakePoint(0,theNewOriginY)];
			//	save for comparision above
			[self setLineFragPosYSave:lineFragPosY];
		}
	}
	//	adding space at the end of the textView/container/scrollView (and removing it for printing) would copy the 'center cursor at end' method above for the continuous textView, but it's a little more than I want to get into right now 
	//	NOTE: I believe the Japanese open source CotEditor (GPL) has some code that centers a continuous textView -- look at it.
	/*
	else
	{
		//	NOTE: this is exactly what we don't want -- it does not center when the cursor is at the end of the text, but always does when the cursor is not at the end of the text, which is the opposite of what the  above method does
		[[self firstTextView] centerSelectionInVisibleArea:nil];
	}
	*/
}


// ******************* Window Resize Delegate ********************
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	return proposedFrameSize;
}

//	adjusts zoom scale when 'Fit to Width' or 'Fit to Page' are active and window is changed
- (void)windowDidResize:(NSNotification *)aNotification
{
	//	refigure scaleFactor if program is in fitWidth/fitPage mode and window is resized
	if ([theScrollView isFitWidth] || [theScrollView isFitPage])
	{
		//	determine new scaleFactor and set it through scrollView
		float scaleFactor = [[[theScrollView documentView] superview] frame].size.width / [[theScrollView documentView] frame].size.width;
		[theScrollView setScaleFactor:scaleFactor];
		//	adjust zoomSlider for fitPage / fitScreen / clicked 'zoom' button changes 
		[self updateZoomSlider];
	}
	//	if window resized while in continuousTextView, rescale to fit clipView
	if (![self hasMultiplePages])
	{
		NSTextView *textView = [self firstTextView];
		NSRect frame = NSInsetRect([textView bounds], 0.0, 0.0);
		NSSize curDocFrameSize, newDocBoundsSize;
		NSView *clipView = [[[textView enclosingScrollView] documentView] superview];
		// Get the frame.  The frame must stay the same.
		curDocFrameSize = [clipView frame].size;
		// The new bounds will be frame divided by scale factor
		newDocBoundsSize.width = curDocFrameSize.width /[theScrollView scaleFactor];
		newDocBoundsSize.height = curDocFrameSize.height /[theScrollView scaleFactor];
		[clipView setBoundsSize:newDocBoundsSize];
		[textView setFrame:NSMakeRect(0.0, 0.0, (newDocBoundsSize.width), frame.size.height)];
		frame = NSZeroRect;
		[theScrollView setNeedsDisplay:YES];

	}
}

// ******************* Float Window Method ********************

//	make window float a la stickies ;)
- (IBAction)floatWindow:(id)sender
{
	if ([docWindow level] == NSFloatingWindowLevel)
	{
		[docWindow setLevel:NSNormalWindowLevel];
		if ([sender tag]==100) { [sender setState:0]; }
		[self setFloating:NO];
		[floatImage setHidden:YES];
	}
	else
	{
		[docWindow setLevel:NSFloatingWindowLevel];
		if ([sender tag]==100) { [sender setState:1]; }
		[self setFloating:YES];
		//	image in status bar hints that window is floating
		[floatImage setHidden:NO];
	}
}

#pragma mark -
#pragma mark ---- Menu Validation Methods ----

// ******************* Menu Validation ********************
//	arbitrary numbers to determine the state of the menu items whose titles change. Speeds up the validation...cos not zero. (trick from Text Edit)

#define TagForFirst 42
#define TagForSecond 43

void validateToggleItem(NSMenuItem *aCell, BOOL useFirst, NSString *first, NSString *second)
{
    if (useFirst)
	{
        if ([aCell tag] != TagForFirst)
		{
            [aCell setTitleWithMnemonic:first];
            [aCell setTag:TagForFirst];
        }
    } 
	else
	{
        if ([aCell tag] != TagForSecond)
		{
            [aCell setTitleWithMnemonic:second];
            [aCell setTag:TagForSecond];
        }
    }
}

//	menu validation
- (BOOL)validateMenuItem:(NSMenuItem *)userInterfaceItem
{
	PageView *pageView = [theScrollView documentView];
	SEL action = [userInterfaceItem action];
	/*
				Use this method to add images to menu items: e.g. paragraph alignment icons
				Note that doesn't work with std first responders, just IB actions
				if (action == @selector(getInfoSheet:)) {
					[userInterfaceItem setImage:[NSImage imageNamed:@"lilbean"]];
				}
	*/
	//	validate floatWindow
	if (action == @selector(floatWindow:))
	{
		([self isFloating]) ? [userInterfaceItem setState:1] : [userInterfaceItem setState:0];
    }
	//	validate setViewType
	else if (action == @selector(setTheViewType:))
	{
		validateToggleItem(userInterfaceItem, [self hasMultiplePages], 
			NSLocalizedString(@"Hide Layout", @"menu item: Hide page layout view."),
			NSLocalizedString(@"Show Layout", @"menu item: Show page layout view")); 
	}
	//	validate toggleBothRulers
	else if (action == @selector(toggleBothRulers:))
	{
		validateToggleItem(userInterfaceItem, [theScrollView rulersVisible], 
			NSLocalizedString(@"Hide Ruler", @"menu item: Hide the ruler"), 
			NSLocalizedString(@"Show Ruler", @"menu item: Show the ruler"));
	}
	//	validate showInspectorAction
	else if (action == @selector(showInspectorPanelAction:))
	{
		return YES;
	}
	//	validate getInfoSheet
	else if (action == @selector(getInfoSheet:))
	{
		if (![[NSApp keyWindow] isEqualTo:[theScrollView window]]) //another sheet is up
		{
			return NO;
		}
		else
		{
			return YES;
		}
	}
	//	validate defineWord
	else if (action == @selector(defineWord:))
	{
		if ([[textStorage string] length]==0) return NO;
		else return YES;
	}
	//	validate autocompleteAction
	else if (action == @selector(autocompleteAction:))
	{
		if ([[textStorage string] length]==0) return NO;
		else return YES;
	}
	//	validate save (because saving no text means saving no attributes, so 'empty' template is worthless)
	else if (action == @selector(saveTheDocument:) || action == @selector(saveDocumentAs:)) {
		if ([[textStorage string] length]==0) return NO;
		else return YES;
	}
	//	validate toggleInvisiblesAction
	else if (action == @selector(toggleInvisiblesAction:))
	{
		validateToggleItem(userInterfaceItem, [layoutManager showInvisibleCharacters],
			NSLocalizedString(@"Hide Invisibles", @"menu item: Hide Invisible Characters"), 
			NSLocalizedString(@"Show Invisibles", @"menu item: Show Invisible Characters"));
	}
	//	validate toggleMarginsAction
	else if (action == @selector(toggleMarginsAction:))
	{
		if (![self hasMultiplePages]) {
			return NO;
		} else {
			validateToggleItem(userInterfaceItem, [pageView showMarginsGuide], 
					NSLocalizedString(@"Hide Margins", @"menu item: Show the margin guide"),
					NSLocalizedString(@"Show Margins", @"menu item: Hide the margin guide"));
			return YES;
		}
	}
	//	validate zoomSelect
	else if (action == @selector(zoomSelect:))
	{
		if ([userInterfaceItem tag]==1)
		{
			[theScrollView isFitWidth] ?  [userInterfaceItem setState:1] : [userInterfaceItem setState:0]; 
		}
		if ([userInterfaceItem tag]==2)
		{
			[theScrollView isFitPage] ? [userInterfaceItem setState:1] : [userInterfaceItem setState:0]; 
		}
	}
	//	validate switchTextColors
	else if (action == @selector(switchTextColors:))
	{
		([self shouldUseAltTextColors]) ? [userInterfaceItem setState:1] : [userInterfaceItem setState:0];
	}
	//	backup enabled only if not empty and has name
	else if (action == @selector(backupDocumentAction:))
	{
		if (![self isTransientDocument] && [self isDocumentSaved])
		{
			return YES;
		} else {
			return NO;
		}
	}
	//	crude error checking routine to only show tab panel action if there is text or index is not at end of string, since these will mess up the method
	else if (action == @selector(showAddTabStopPanelAction:))
	{
		NSRange selRange = [[self firstTextView] selectedRange];
		if ([[textStorage string] length]==0 //no text 
				|| selRange.location==[[textStorage string] length] //at end
				|| ![[NSApp keyWindow] isEqualTo:[theScrollView window]] //another sheet is up
				|| [self readOnlyDoc]) 
		{
			return NO;
		}
		else
		{
			return YES;
		}
	}
	//	un-enable list modification if cursor not on list item
	else if (action == @selector(listItemIndent:) || action == @selector(listItemUnindent:))
	{
		//	prevent out of bounds exception
		if ([[self firstTextView] selectedRange].location==0
				|| [[self firstTextView] selectedRange].location==[textStorage length]) { return NO; }
		//	if cursor is located within a textList, enable menu items, then get paragraph style
		NSMutableParagraphStyle *theParagraphStyle = 
				[textStorage attribute:NSParagraphStyleAttributeName 
				atIndex:[[self firstTextView] selectedRange].location
				effectiveRange:NULL];
		if (theParagraphStyle==nil) { theParagraphStyle = [[theParagraphStyle mutableCopyWithZone:[[self firstTextView] zone]]autorelease]; }
		//	if a textList exists in the selected range, enable list indent methods in menu
		NSArray *theArray = [theParagraphStyle textLists];
		int theCount = [theArray count];
		return (theCount) ? YES : NO;
	}
	//	validate selectLiveWordCounting
	else if (action == @selector(selectLiveWordCounting:))
	{
		[self shouldDoLiveWordCount] ? [userInterfaceItem setState:1] : [userInterfaceItem setState:0];
    }
	//	determines if item on pboard is char or para style to paste and if so, enables menu and changes title
	else if (action == @selector(copyAndPasteFontOrRulerAction:))
	{
		NSPasteboard *fontPasteboard = [NSPasteboard pasteboardWithName:NSFontPboard];
		NSPasteboard *rulerPasteboard = [NSPasteboard pasteboardWithName:NSRulerPboard];
		//	paste font
		if ([userInterfaceItem tag]==2 && [fontPasteboard changeCount] > 0) 
		{
			return YES;
		}
		//	paste ruler
		else if ([userInterfaceItem tag]==3 && [rulerPasteboard changeCount] > 0)
		{
			return YES;
		}
		//	copy font; copy ruler; copy font/ruler
		else if ([userInterfaceItem tag]==0 
					 || [userInterfaceItem tag]==1 
					 || [userInterfaceItem tag]==4)
		{
			//avoid addAttribute:nil when isRichText==NO (27 May 2007 BH)
			if ([[self firstTextView] isRichText]) { return YES; }
			else { return NO; }
		}
		//	paste font/ruler
		else if ([userInterfaceItem tag]==5 && [rulerPasteboard changeCount] > 0 && [fontPasteboard changeCount] > 0)
		{
			return YES;
		}
		//	select by...various
		else if ( ( [textStorage length] == 0
					|| [[self firstTextView] selectedRange].location==[textStorage length] )
					&& ( [userInterfaceItem tag]==6
					|| [userInterfaceItem tag]==7
					|| [userInterfaceItem tag]==8
					|| [userInterfaceItem tag]==9
					|| [userInterfaceItem tag]==10
					|| [userInterfaceItem tag]==11 ) )
		{
			return NO;
		}
		else
		{
			return YES;
		}
	}
	//	change convertSmartQuotes menu action title depending on if there is a text selection (7 April 2007)
	else if (action == @selector(convertQuotesAction:))
	{
		//	active only if text length > 0
		if ([textStorage length] > 0 && ![self readOnlyDoc])
		{
			//	to Smart Quotes menu item
			if ([userInterfaceItem tag]==0)
			{
				//	disable Smart Quotes option if HTML (27 May 2007 BH)
				if ([[self fileType] isEqualToString:HTMLDoc]) 
				{
					return NO;
				}
				else
				{
					if ([[self firstTextView] selectedRange].length == 0)
					{
						//	convert whole text to Smart Quotes
						[userInterfaceItem setTitleWithMnemonic:NSLocalizedString(@"Text to Smart Quotes", @"menu item: Text to Smart Quotes (Convert all text in document to use Smart Quotes)")];
					}
					else
					{
						//	convert just selection to Smart Quotes
						[userInterfaceItem setTitleWithMnemonic:NSLocalizedString(@"Selection to Smart Quotes", @"menu item: (Convert selected text in document to use Smart Quotes)")];
					}
				}
			}
			//	to Straight Quotes
			else
			{
				if ([[self firstTextView] selectedRange].length == 0)
				{
					//	convert whole text to Straight Quotes
					[userInterfaceItem setTitleWithMnemonic:NSLocalizedString(@"Text to Straight Quotes", @"menu item: Text to Straight Quotes (Convert all text in document to use Straight Quotes)")];
				}
				else
				{
					//	convert selected text to Straight Quotes
					[userInterfaceItem setTitleWithMnemonic:NSLocalizedString(@"Selection to Straight Quotes", @"menu item: Selection to Straight Quotes (Convert selected text in document to use Straight Quotes)")];
				}
			return YES;
			}
		}
		else return NO;
	}	
	//	Smart Quotes menu action
	else if (action == @selector(useSmartQuotesAction:))
	{
		if ([[self currentFileType] isEqualToString:HTMLDoc] 
					|| [[self currentFileType] isEqualToString:TXTwExtDoc])
		{
			return NO;
		}
		else
		{
			[self shouldUseSmartQuotes] ? [userInterfaceItem setState:1] : [userInterfaceItem setState:0];
			return YES;
		}
	}
	//	list methods only work if selectedRange.legnth > 1
	else if (action == @selector(specialTextListAction:))
	{
		//NSTextList doesn't work with plain text, so added check 12 Oct 2007 JH
		return ([[self firstTextView] selectedRange].length > 1 && [[self firstTextView] isRichText]) ? YES : NO;
	}
	else if (action == @selector(insertDateTimeStamp:))
	{
		if (![self readOnlyDoc])
			return YES;
		else
			return NO;
	}
	//	don't allow export if file was never saved (no filename)
	else if (action == @selector(exportToHTML:))
	{
		if ([[self fileType] isEqualToString:HTMLDoc] || [self fileName]==nil) return NO;
	}
	//	don't allow export if file was never saved (no filename)
	else if (action == @selector(printDocument:) && [userInterfaceItem tag]==100)
	{
		if ([self fileName]==nil) return NO;
	}
	//	don't allow export if file was never saved (no filename)
	else if (action == @selector(saveRTFwithPictures:))
	{
		if ([self fileName]==nil || ![textStorage containsAttachments]) return NO;
	}
	else if (action == @selector(revertDocumentToSaved:))
	{
		if (![self isTransientDocument] && [self isDocumentSaved] && [self isDocumentEdited])
		{
			return YES;
		} else {
			return NO;
		}
	}
	//	no hyperlink possible for plain text
	else if (action == @selector(showLinkSheet:))
	{
		//added check for readOnly 11 Oct 2007
		if ([[self firstTextView] isRichText] && ![self readOnlyDoc])
		{
			return YES;
		} else {
			return NO;
		}
	}
	else if (action == @selector(restoreCursorLocationAction:))
	{
		if (!([self savedEditLocation]) || ([self savedEditLocation] == ([[self firstTextView] selectedRange].location + [[self firstTextView] selectedRange].length)))
			{ return NO; }
	}
	else if (action == @selector(inspectorSpacingAction:))
	{
		switch ([userInterfaceItem tag])
		{
			case 30:
				[userInterfaceItem setImage:[NSImage imageNamed:@"swatchX"]];
				break;
			case 31:
				[userInterfaceItem setImage:[NSImage imageNamed:@"swatchYellow"]];
				break;
			case 32:
				[userInterfaceItem setImage:[NSImage imageNamed:@"swatchOrange"]];
				break;
			case 33:
				[userInterfaceItem setImage:[NSImage imageNamed:@"swatchPink"]];
				break;
			case 34:
				[userInterfaceItem setImage:[NSImage imageNamed:@"swatchBlue"]];
				break;
			case 35:
				[userInterfaceItem setImage:[NSImage imageNamed:@"swatchGreen"]];
				break;
		}
	
		if ([userInterfaceItem tag] > 29)
		{
			if ([[self firstTextView] selectedRange].length > 0)
				return YES;
			else
				return NO;
		}
		else
		{
			if ([textStorage length] && ![self readOnlyDoc]) 
				return YES;
			else
				return NO;
		}
	}
	else if (action == @selector(sendToMail:))
	{
		if ([self fileName]) 
			return YES;
		else
			return NO;
	}
	else if (action == @selector(setPrintMargins:))
	{
		if ([self readOnlyDoc]) 
			return NO;
		else
			return YES;
	}
	else if (action == @selector(insertBreakAction:))
	{
		if ([self readOnlyDoc]) 
			return NO;
		else
			return YES;
	}
	else if (action == @selector(insertImageAction:))
	{
		if ([[self firstTextView] importsGraphics] && ![self readOnlyDoc]) 
			return YES;
		else
			return NO;
	}
	else if (action == @selector(showResizeImageSheetAction:))
	{
		if	(	[[self firstTextView] importsGraphics]
				&& [[textStorage attributedSubstringFromRange:[[self firstTextView] selectedRange]] containsAttachments]
				&& [[NSApp keyWindow] isEqualTo:[theScrollView window]] //another sheet is up
				&& ![self readOnlyDoc]
			) 
			return YES;
		else
			return NO;
	}
	//	propertiesSheetAction
	else if (action == @selector(propertiesSheetAction:))
	{
		if (
			[[self currentFileType] isEqualToString:HTMLDoc] 
			|| [[self currentFileType] isEqualToString:TXTwExtDoc]
			|| [[self currentFileType] isEqualToString:TXTDoc]
			|| ![[NSApp keyWindow] isEqualTo:[theScrollView window]] //another sheet is up
			)
		{	
			return NO;
		}
		else { return YES; }
	}
	/*
	 else if (action == @selector(alignLeft:)) {
		 [userInterfaceItem setImage:[NSImage imageNamed:@"TBCopyItemImage"]];
	}
	*/
	else
	{
       return [super validateUserInterfaceItem: userInterfaceItem];
	}
	return YES;
}

#pragma mark -
#pragma mark ---- Various Toggle UI Methods ----

// ******************* Toggle View Type ********************

//	switches between Page Layout view mode (a view with many text containers acting as 'pages') and Continuous Text view mode (a view with one container) 
- (IBAction)setTheViewType:(id)sender
{
	//	so we don't lose (reset) typingAttributes when containers are switched and there is no text to carry over attributes
	NSDictionary *storeTypingAttributes = nil; 
	if (![textStorage length])
	{
		storeTypingAttributes = [[self firstTextView] typingAttributes]; 
	}
	//	if continuous text view, change to multiple page text view
	if (![self hasMultiplePages])
	{
		[self setHasMultiplePages:YES];
		NSTextView *textView = [self firstTextView];
        PageView *pageView = [[PageView alloc] init];
		[theScrollView setDocumentView:pageView];
		if ([self showMarginsGuide]) [pageView setShowMarginsGuide:YES];
		//	get defaults
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		//	draw page shadow in pageView? (user can turn it off in prefs for slower machines)
		if ([defaults boolForKey:@"prefShowPageShadow"])
		{
			[pageView setShowPageShadow:YES];
		}
		else
		{
			[pageView setShowPageShadow:NO];
		}
		//	necessary?
		[pageView setPrintInfo:[self printInfo]];
        // Add the first new page before we remove the old container so we can avoid losing all the shared text view state.
		[self addPageWithFlag:YES];
		//	remove the continuous text view text container
		if (textView) { [[self layoutManager] removeTextContainerAtIndex:0]; }
		//	Bean becomes so sluggish as to be un-usable if you let the layoutManager repaginate in the background, so we layout the whole shmo
		[self doForegroundLayoutToCharacterIndex:INT_MAX];
		[pageView setNumberOfPages:[[layoutManager textContainers] count]];
		//	when the page view is init'd again, must inform it of alternate background color, which this does
		if ([self shouldUseAltTextColors]) { [self setShouldUseAltTextColors:YES]; }
		[pageView recalculateFrame];
		[self shouldShowHorizontalScroller] ? [theScrollView setHasHorizontalScroller:YES] : [theScrollView setHasHorizontalScroller:NO];
		//	maintain ruler state
		([self areRulersVisible]) ? [theScrollView setRulersVisible:YES] : [theScrollView setRulersVisible:NO];
		[theScrollView setBackgroundColor:[NSColor lightGrayColor]];
		[textView setBackgroundColor:[NSColor whiteColor]];
		[self constrainScrollWithForceFlag:YES];
		[pageView release]; //12 July 2007 BH (to balance alloc)
	}
	//if has multiple pages text view, change view type to continuous text view
	else
	{
		[self setHasMultiplePages:NO];
		NSSize size = [theScrollView contentSize];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(size.width, FLT_MAX)];
        NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, size.width, size.height) textContainer:textContainer];
		//	insert the single container as the first container in the layout manager before removing the existing pages in order to preserve the shared view state.
        [[self layoutManager] insertTextContainer:textContainer atIndex:0];
		//	remove text containers representing 'pages'
        if ([[theScrollView documentView] isKindOfClass:[PageView class]])
		{
			NSArray *textContainers = [[self layoutManager] textContainers];
            unsigned cnt = [textContainers count];
            while (cnt-- > 1)
			{
                [[self layoutManager] removeTextContainerAtIndex:cnt];
            }
        }
		//	setup continuous text view
        [textContainer setWidthTracksTextView:YES];
        [textContainer setHeightTracksTextView:NO];	
        [textView setHorizontallyResizable:NO];			
        [textView setVerticallyResizable:YES];
		[textView setAutoresizingMask:NSViewWidthSizable];
        [textView setMinSize:size];	
        [textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
		if ([self shouldUseAltTextColors])
		{
			[theScrollView setBackgroundColor:[self textViewBackgroundColor]];
		}
		else
		{
			[theScrollView setBackgroundColor:[NSColor whiteColor]];
		}
        //	the next line should cause the multiple page view to go away - to quote text edit 
        [theScrollView setDocumentView:textView];
        [theScrollView setHasHorizontalScroller:NO];
		[textView release];
        [textContainer release];
    }
	//	maintain ruler state
	([self areRulersVisible]) ? [theScrollView setRulersVisible:YES] : [theScrollView setRulersVisible:NO];
	//	make sure zoomSlider control reflects zoom scale of layout view
	[self zoomAction:zoomSlider]; 
	//	show the selected region
	[[self firstTextView] scrollRangeToVisible:[[self firstTextView] selectedRange]];
	//	set focus
	[[theScrollView window] makeFirstResponder:[self firstTextView]];
    [[theScrollView window] setInitialFirstResponder:[self firstTextView]];
	[[theScrollView verticalScroller] display]; //9 Sept 07 to fix disappearing pageUp/pageDown buttons
	[self liveWordCount:nil];
	if (storeTypingAttributes) [[self firstTextView] setTypingAttributes:storeTypingAttributes];
}

// ******************* Toggle Ruler Method ********************

-(IBAction)toggleBothRulers:(id)sender
{
	if ([theScrollView rulersVisible])
	{
		[theScrollView setRulersVisible:NO];
		[self setAreRulersVisible:NO];
	}
	else
	{
		[theScrollView setRulersVisible:YES];
		[self setAreRulersVisible:YES];
	}
}

// ******************* Toggle Color Methods ********************
//	Menu action changes from default white background and colored text to user-defined text color on top of user-defined background color. Basically, the idea is you can do white text on blue background type stuff, but there might be other uses for it advantages: 1) no psychological 'blank white sheet' stumbling block when beginning to write, 2) easier on the eyes over time, 3) 'customizable'
- (IBAction)textColors:(id)sender
{
	NSTextView *textView = [self firstTextView];
	// change to alt colors
	if ([self shouldUseAltTextColors])
	{
		//	if altTextColor is not already set, set it
		if (!altTextColor)
		{
			//gets released in dealloc method
			altTextColor = [[NSDictionary alloc] initWithObjectsAndKeys:[self textViewTextColor], NSForegroundColorAttributeName, nil];
		}
		//	set temp text attr to white
		[[textView layoutManager] addTemporaryAttributes:altTextColor 
					forCharacterRange:NSMakeRange(0, [[textView textStorage] length])]; 
		//	set background to alternateBackgroundColor
		[textView setBackgroundColor:[self textViewBackgroundColor]];
		//	this is necessary if user chooses gray-scale chooser from color panel ("no redComponent defined," etc errors)	
		NSColor *tvBackgroundColor = [[self textViewBackgroundColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		//	this part of the method (determining the color of the insertion point) is from TextForge.
		float darkness;
		darkness =	((222 * [tvBackgroundColor redComponent])
					+ (707 * [tvBackgroundColor greenComponent]) 
					+ (71 * [tvBackgroundColor blueComponent]))
					/ 1000;
		//	is light background
		if (darkness > 0.5)
		{
			[textView setInsertionPointColor:[NSColor blackColor]];
		}
		//	is dark background
		else
		{
			[textView setInsertionPointColor:[NSColor whiteColor]];
		}
		if (hasMultiplePages)
		{
			PageView *pageView = [theScrollView documentView];
			[pageView setNeedsDisplay:YES];
		}
		else
		{
			//	bug fix 4 Aug 2007 (white scroll view was visible when textView was zoomed out) 
			[theScrollView setBackgroundColor:[self textViewBackgroundColor]];
			[theScrollView setNeedsDisplay:YES];
		}
	}
	else
	{
		//	restore original, traditional NSTextView colors; remove temp color attr
		[[textView layoutManager] removeTemporaryAttribute:NSForegroundColorAttributeName 
											forCharacterRange:NSMakeRange(0, [[textView textStorage] length])];
		[textView setBackgroundColor:[NSColor whiteColor]];
		[textView setInsertionPointColor:[NSColor blackColor]];
		if (hasMultiplePages)
		{
			PageView *pageView = [theScrollView documentView];
			[pageView setNeedsDisplay:YES];
		}
		else
		{
			//	bug fix 4 Aug 2007 (white scroll view was visible when textView was zoomed out) 
			[theScrollView setBackgroundColor:[NSColor whiteColor]];
			[theScrollView setNeedsDisplay:YES];
		}
	}
}

//	store 'alternate' text colors for later when user decides to use them
-(void)applyAltTextColors
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
	NSData *dataAltTextColor = [defaults objectForKey:@"altTextColor"];
	NSColor *theTextColor = [NSUnarchiver unarchiveObjectWithData:dataAltTextColor];
	[self setTextViewTextColor:theTextColor];
	NSData *dataAltBackgroundColor = [defaults objectForKey:@"altBackgroundColor"];
	NSColor *theBackgroundColor = [NSUnarchiver unarchiveObjectWithData:dataAltBackgroundColor];
	[self setTextViewBackgroundColor:theBackgroundColor];
	dataAltTextColor = nil;
	dataAltBackgroundColor = nil;
}

// ******************* Toggle Show Alternate Text Colors ********************
//	action called by menu item
-(IBAction)switchTextColors:(id)sender
{
	if ([self shouldUseAltTextColors])
	{
		//alt colors are on; turn them off
		[self setShouldUseAltTextColors:NO];
	}
	else
	{
		//alt colors are off, get them and turn them on
		[self applyAltTextColors];
		[self setShouldUseAltTextColors:YES];
	}
	[self textColors:nil];
}

// ******************* Toggle Show Margin Guides ********************
-(IBAction)toggleMarginsAction:(id)sender
{
	PageView *pageView = [theScrollView documentView];
	//	we need an accessor in this class to remember setting because the pageView is created and destroyed each time setTheViewType is cycled, so BOOL is lost
	if ([self showMarginsGuide])
	{
		[pageView setShowMarginsGuide:NO];
		[self setShowMarginsGuide:NO];
	}
	else
	{
		[pageView setShowMarginsGuide:YES];
		[self setShowMarginsGuide:YES];
	}
	[pageView setNeedsDisplay:YES];
}

// ******************* toggle Show Invisible Characters method *******************

//	toggles edit mode in which returns, tabs, and spaces are visible in the text view
-(IBAction)toggleInvisiblesAction:(id)sender
{
	if ([[self layoutManager] showInvisibleCharacters])
	{
		[[self layoutManager] setShowInvisibleCharacters:NO];
		[[self firstTextView] setNeedsDisplay:YES];
		if ([self hasMultiplePages])
		{
			PageView *pageView = [theScrollView documentView];
			[pageView setNeedsDisplay:YES];
		}
	}
	else
	{
		[[self layoutManager] setShowInvisibleCharacters:YES];
		[[self firstTextView] setNeedsDisplay:YES];
		if ([self hasMultiplePages])
		{
			PageView *pageView = [theScrollView documentView];
			[pageView setNeedsDisplay:YES];
		}
	}
}

-(IBAction)useSmartQuotesAction:(id)sender
{
	if ([self shouldUseSmartQuotes])
	{
		[self setShouldUseSmartQuotes:NO];
	}
	else
	{
		[self setShouldUseSmartQuotes:YES];
	}
}

// toolbar action to toggle Font Panel in and out (toolbar items are actually supposed to have single, discrete actions and not toggle things, but oh well...) 
-(IBAction)showFontPanel:(id)sender
{
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFontPanel *fontPanel = [fontManager fontPanel:NO];

	if ([fontPanel isVisible]) 
	{
		[fontPanel orderOut:self];
		return;
	}
	[fontManager fontPanel:YES];
	[fontManager orderFrontFontPanel:nil];
}

#pragma mark -
#pragma mark ---- Statistics Sheet and Counting Methods  ----

// ******************* Statistics Sheet / Live Word Count Methods ********************

//	do counts, then show Statistics sheet
- (IBAction)getInfoSheet:(id)sender
{
	NSArray		*textContainers = [[self layoutManager] textContainers];
    NSTextView	*textView = [self firstTextView];
	NSString	*theString = [[[self layoutManager] textStorage] string];
	int	theStringLength = [[[[textView layoutManager] textStorage] string] length];
	int	charCnt = nil;
	int	wordCnt = nil;

	//	count Carriage Returns (Hard Returns), ie, 'newLineMarker' character
	unichar newLineUnichar = 0x000a;
	newLineChar = [[NSString alloc] initWithCharacters:&newLineUnichar length:1];
	//	note: actual lineCount is one less than the count of the items separated by the newLineChar
	int lineCount = [[theString componentsSeparatedByString:newLineChar] count];
	
	//	search string for Empty Paragraphs (two newLineChar's in a row)
	int charIndex = 0;
	int emptyParagraphCount = 0;
	int theFoundRangeLocation = 0;
	while (charIndex < theStringLength )
	{
		NSRange theFoundRange = [theString rangeOfString:[NSString stringWithFormat:@"%@%@", newLineChar, newLineChar] 
				options:nil range:NSMakeRange(charIndex,(theStringLength - charIndex))];
		theFoundRangeLocation = theFoundRange.location;
		if (theFoundRangeLocation < theStringLength)
		{
			emptyParagraphCount = emptyParagraphCount + 1;
			charIndex = theFoundRangeLocation + 1;
			theFoundRangeLocation = nil;
		}
		else
		{
			charIndex = theStringLength;
		}
	}
	//	add to empty paragraph count the CRs (with no text on the line) located at the very beginning and end of text
	if (theStringLength > 0 && [theString characterAtIndex:0]==newLineUnichar) 
			{ emptyParagraphCount = emptyParagraphCount + 1; }
	if (theStringLength > 0 && [theString characterAtIndex:theStringLength - 1]==newLineUnichar)
			{ emptyParagraphCount = emptyParagraphCount + 1; }
	
	//	release/zero some stuff
	charIndex = 0;
	[newLineChar release];
	newLineChar = nil;
	
	//	count 'Soft' Returns, ie line fragments created by wrapped text ('line count' in sheet) (this code is from Apple)
	unsigned numberOfLineFrags, index, numberOfGlyphs; 
	numberOfGlyphs = [[self layoutManager] numberOfGlyphs];
	NSRange lineRange;
	for (numberOfLineFrags = 0, index = 0; index < numberOfGlyphs; numberOfLineFrags++)
	{
		(void) [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
		index = NSMaxRange(lineRange);
	}
	
	//	now set the labels in the Statistics sheet
	
	//	new doc with no words = zero paragraphs and CRs
	if (theStringLength < 1)
	{ 	
		[lineCountField setIntValue:0];
		[paragraphCountField setIntValue:0];
	}
	else
	{
		// = number of CRs
		[lineCountField setStringValue:	[self thousandFormatedStringFromNumber:[NSNumber numberWithInt:lineCount - 1]]];

		// = number of CRs preceded by text (ie, paragraphs)
		[paragraphCountField setStringValue: [self thousandFormatedStringFromNumber:[NSNumber numberWithInt:lineCount - emptyParagraphCount]]];
	}
	
	//	get the word count
	
	//	wordCnt = [self wordCountForString:theString];
	wordCnt = [textStorage wordCount];
	//	character count
	
	//	NSLog([self thousandFormatedStringFromNumber:[NSNumber numberWithInt:theStringLength]]);
	
	[charCountField setStringValue:[self thousandFormatedStringFromNumber:[NSNumber numberWithInt:theStringLength]]];
		
	//	char count minus spaces
	[charCountMinusSpacesField setStringValue:[self thousandFormatedStringFromNumber:[NSNumber numberWithInt:theStringLength - [self whitespaceCountForString:theString]]]];
	//	word count
	[wordCountField setIntValue:wordCnt];
	[wordCountField setStringValue: [self thousandFormatedStringFromNumber:[NSNumber numberWithInt:wordCnt]]];
	//	page count
	if ([self hasMultiplePages])
	{ 
		[pageCountField setStringValue: [self thousandFormatedStringFromNumber:[NSNumber numberWithInt:[textContainers count]]]];
	}
	else
	{
		[pageCountField setStringValue:@"N/A"];
	}
	//	line fragment (soft return) count
	[lineFragCountField setStringValue: [self thousandFormatedStringFromNumber:[NSNumber numberWithInt:numberOfLineFrags]]];
	
	wordCnt = nil;
	charCnt = nil;	
	lineCount = nil;
	numberOfLineFrags = nil;
	emptyParagraphCount = nil;
	
	//	count selected text ranges and add them
	NSEnumerator *rangeEnumerator = [[textView selectedRanges] objectEnumerator];
	NSValue *rangeAsValue;
	while ((rangeAsValue = [rangeEnumerator nextObject]) != nil)
	{
		NSRange range = [rangeAsValue rangeValue];
		//	we have to send wordCountForString an attributed string because nextWordFromIndex only works on attributed strings
		NSAttributedString *tempStr = [[NSAttributedString alloc] initWithString:[theString substringWithRange:range]];
		wordCnt += [self wordCountForString:tempStr];
		charCnt += [tempStr length];
		tempStr = @"";
		[tempStr release];
	}

	//	selected range(s) character and word count
	[selWordCountField setStringValue: [self thousandFormatedStringFromNumber:[NSNumber numberWithInt:wordCnt]]];
	[selCharCountField setStringValue: [self thousandFormatedStringFromNumber:[NSNumber numberWithInt:charCnt]]];
	wordCnt = nil;
	charCnt = nil;	
	theStringLength = nil;
	
	if (![self fileName])
	{
		[revealFileInFinderButton setEnabled:NO];
		[lockedFileButton setEnabled:NO];
		[lockedFileLabel setTextColor:[NSColor darkGrayColor]];
	}
	else
	{
		[revealFileInFinderButton setEnabled:YES];
		[lockedFileButton setEnabled:YES];
		[lockedFileLabel setTextColor:[NSColor blackColor]];
	}
	
	//	enable backupAutomaticallyButton if not saved yet and fileType is not TXT, HTML, or WebArchive, which don't use (ie, save) keywords
	if (	[self fileName]
				&& (![[self fileType] isEqualToString:TXTDoc]
				&& ![[self fileType] isEqualToString:HTMLDoc]
				&& ![[self fileType] isEqualToString:WebArchiveDoc]
				&& ![[self fileType] isEqualToString:TXTwExtDoc])	)
	{
		[backupAutomaticallyButton setEnabled:YES];
		[backupAutomaticallyLabel setTextColor:[NSColor blackColor]];
		[self createDatedBackup] ? [backupAutomaticallyButton setState:NSOnState] : [backupAutomaticallyButton setState:NSOffState];
		[doAutosaveButton setEnabled:YES];
		if ([self doAutosave])
		{
			[doAutosaveButton setState:NSOnState];
			[doAutosaveTextField setEnabled:NO];
			[doAutosaveStepper setEnabled:NO];
			[doAutosaveLabel setTextColor:[NSColor lightGrayColor]];
		}
		else
		{
			[doAutosaveButton setState:NSOffState];
			[doAutosaveTextField setEnabled:YES];
			[doAutosaveStepper setEnabled:YES];
			[doAutosaveLabel setTextColor:[NSColor blackColor]];
		}
	}
	else
	{
		[backupAutomaticallyButton setState:NSOffState];
		[backupAutomaticallyButton setEnabled:NO];
		[backupAutomaticallyLabel setTextColor:[NSColor darkGrayColor]];
		[doAutosaveButton setState:NSOffState];
		[doAutosaveButton setEnabled:NO];
		[doAutosaveTextField setEnabled:YES];
		[doAutosaveStepper setEnabled:YES];
		[doAutosaveLabel setTextColor:[NSColor blackColor]];
	}
	
	//	see if the file is LOCKED and adjust button
	NSDictionary *theFileAttrs = [[NSFileManager defaultManager] fileAttributesAtPath:[self fileName] traverseLink:YES];
	([[theFileAttrs objectForKey:NSFileImmutable] boolValue])
				? [lockedFileButton setState:NSOnState] : [lockedFileButton setState:NSOffState];
		
	//	see if the document is READ ONLY and adjust the button
	([self readOnlyDoc]) ? [readOnlyButton setState:NSOnState] : [readOnlyButton setState:NSOffState];
	
	//	if text, show encoding and enable button to change encoding; else, unenable
	if ([[self currentFileType] isEqualToString:TXTDoc]
				|| [[self currentFileType] isEqualToString:HTMLDoc] 
				|| [[self currentFileType] isEqualToString:TXTwExtDoc])
	{
		[infoSheetEncodingBox setTitle:NSLocalizedString(@"Plain Text Encoding", @"get info label: Plain Text Encoding")];
		[infoSheetEncoding setObjectValue:[self docEncodingString]];
		[infoSheetEncodingButton setHidden:NO];
	}
	else
	{
		[infoSheetEncodingBox setTitle:NSLocalizedString(@"Document File Format", @"get info label: Document File Format")];
		//if ([self fileName]) { [infoSheetEncoding setObjectValue:[self fileType]]; }
		if ([self fileName]) { [infoSheetEncoding setObjectValue:NSLocalizedString([self fileType], @"this will translate automatically from file type name strings")]; }
		else { [infoSheetEncoding setObjectValue:NSLocalizedString(@"None (Unsaved Document)", @"get info label: None (Unsaved Document)")]; }
		[infoSheetEncodingButton setHidden:YES];
	}
	//	show the sheet
	[NSApp beginSheet:infoSheet modalForWindow:docWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
	[infoSheet orderFront:sender];
}

//show Properties sheet
- (IBAction)propertiesSheetAction:(id)sender
{	
	//	show the sheet
	[NSApp beginSheet:propertiesSheet modalForWindow:docWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
	[propertiesSheet orderFront:sender];
}

- (IBAction)closePropertiesSheet:(id)sender
{
	[NSApp endSheet:propertiesSheet];
	[propertiesSheet orderOut:sender];
}

- (IBAction)lockedFileButtonAction:(id)sender
{
	if ([self fileName])
	{
		int lockedState = [sender state];
		//	set locked state based on checkbox
		NSDictionary *unlockFileDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:lockedState] forKey:NSFileImmutable];
		[[NSFileManager defaultManager] changeFileAttributes:unlockFileDict atPath:[self fileName]];
		//	inform user that locked files cannot be saved to, but may be re-opened as templates
		NSDictionary *theFileAttrs = [[NSFileManager defaultManager] fileAttributesAtPath:[self fileName] traverseLink:YES];
		if ([[theFileAttrs objectForKey:NSFileImmutable] boolValue] == YES) //confirm file is now locked
		{
			NSString *docName = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"firstLevelOpenQuote", nil), [self displayName], NSLocalizedString(@"firstLevelCloseQuote", nil)]; 
			NSString *title = [NSString stringWithFormat:NSLocalizedString(@"The file %@ is now locked and may not be overwritten.", @"alert title: The file (name of file inserted at runtime) is now locked and may not be overwritten."), docName];
			NSString *infoText = NSLocalizedString(@"Close and reopen this document to create an \\U2018Untitled\\U2019 copy.", @"alert text: Close and reopen the document to create an 'Untitled' copy.");
			NSAlert *lockedFileAlert = [NSAlert alertWithMessageText:title defaultButton:NSLocalizedString(@"OK", @"OK") alternateButton:nil otherButton:nil
										   informativeTextWithFormat:infoText];
			[lockedFileAlert runModal];
		}
	}
}

- (IBAction)readOnlyButtonAction:(id)sender
{
	int readOnlyState = [sender state];
	//	set read only state based on checkbox
	[self setReadOnlyDoc:readOnlyState];
}

//	called from button in getInfo panel
- (IBAction)backupAutomaticallyAction:(id)sender
{
	if ([self createDatedBackup])
	{
		[self setCreateDatedBackup:NO];
	}
	else
	{
		[self setCreateDatedBackup:YES];
	}
	[self setDocEdited:YES];
}

- (IBAction)closeInfoSheet:(id)sender
{
	//	if autosaveInterval is not in acceptable range (1 min to 60 min), warn and don't close sheet
	if ([doAutosaveTextField intValue] < 1 || [doAutosaveTextField intValue] > 60)
	{
		[alertSheet setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Please input an Autosave interval.", @"alert title: Please input an Autosave interval.")]];
		[alertSheet setInformativeText:NSLocalizedString(@"At least 1 minute and no more than 60 minutes.", @"alert text: At least 1 minute and no more than 60 minutes. (alert title is: Please input an Autosave interval.)")];
		[alertSheet runModal];
		[doAutosaveTextField setIntValue:5];
	}
	//	else close sheet
	else
	{
	[NSApp endSheet:infoSheet];
	[infoSheet orderOut:sender];
	}
}

/*
//this is what we formerly used to count words; it produced good results, but its downside was that it
//		counted hyphenated, em-dashed, etc. phrases as one word; it would slow down and become annoying
//		around 1M words (it would only fire after two seconds of user non-activity to decrease the perception
//		of lag time) 
- (unsigned)wordCountForString:(NSString *)textString
{
	numberOfWords = 0;
	NSScanner *scanner = [NSScanner scannerWithString:textString];
	while (![scanner isAtEnd])
	{
		[scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
		if ([scanner scanCharactersFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet] intoString:nil])
			numberOfWords++;
	}
	return numberOfWords;
}
*/

//	from Keith Blount's KSWordCountingTextStorage - we use this for consistancy with the live word count
- (unsigned)wordCountForString:(NSAttributedString *)tmpString
{
	unsigned wc = 0;
	NSCharacterSet *lettersAndNumbers = [NSCharacterSet alphanumericCharacterSet];
	int index = 0;
	while (index < ([tmpString length]))
	{
		int newIndex = [tmpString nextWordFromIndex:index forward:YES];
		NSString *word = [[tmpString string] substringWithRange:NSMakeRange(index, newIndex-index)];
		// Make sure it is a valid word - ie. it must contain letters or numbers, otherwise don't count it
		if ([word rangeOfCharacterFromSet:lettersAndNumbers].location != NSNotFound)
			{ wc++; }
		index = newIndex;
	}
	return wc;
}

//	counts and returns the number of space characters
- (int)whitespaceCountForString:(NSString *)textString
{
	int stringLength = [textString length];
	int i, theCharacterCount;
	for (i = theCharacterCount = 0; i < stringLength; i++)
	{
		if ( [textString characterAtIndex:i]  == ' ') { theCharacterCount++; }
	}
	return theCharacterCount;
}	

// ******************* Turn Live Word Counting On and Off ********************

-(IBAction)selectLiveWordCounting:(id)sender
{
	if ([sender state]==NSOnState) 
	{
		[sender setState:NSOffState];
		[self setShouldDoLiveWordCount:NO];
		[liveWordCountField setTextColor:[NSColor darkGrayColor]];
		[liveWordCountField setObjectValue:NSLocalizedString(@"B  E  A  N", @"status bar label: B  E  A  N")];	
	}
	//	turn live word counting on
	else
	{ 
		[sender setState:NSOnState];
		[self setShouldDoLiveWordCount:YES];
		[liveWordCountField setTextColor:[NSColor blackColor]];
	}
}

-(IBAction)revealFileInFinder:(id)sender
{
	NSString *thePath = [self fileName];
	if (thePath) { [[NSWorkspace sharedWorkspace] selectFile:thePath inFileViewerRootedAtPath:nil]; }
}

//	determine if flagged as stationary pad in the Finder
-(BOOL)isStationaryPad:(NSString *)path
{
#ifndef GNUSTEP
	static kIsStationary = 0x0800;
	CFURLRef url;
	FSRef fsRef;
	FSCatalogInfo catInfo;
	BOOL success;
	url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)path, kCFURLPOSIXPathStyle, FALSE);
	if (!url) return NO;
	success = CFURLGetFSRef(url, &fsRef);
	CFRelease(url);
	//	catalog info from file system reference
	if (success && (FSGetCatalogInfo(&fsRef, kFSCatInfoFinderInfo, &catInfo, nil, nil, nil))==noErr) 
	//	isStationary status from catalog info
	return ((((FileInfo*)catInfo.finderInfo)->finderFlags & kIsStationary) == kIsStationary);
#endif
	return NO;
}

#pragma mark -
#pragma mark ---- Zoom (View Scale) Methods  ----

// ******************* User Changed View Slider ********************

//	when the view scale zoom slider is changed, this method adjusts the view(s) to match the control setting
-(IBAction)zoomSlider:(id)sender
{
	[self zoomAction:sender];
	//	fit to width and to page are turned off when zoom slider is used
	[theScrollView setIsFitWidth:NO];
	[theScrollView setIsFitPage:NO];
}

-(IBAction)zoomAction:(id)sender
{
	if (![self hasMultiplePages])
	{
		//	adjust continuous text view scale according to value from zoomSlider
		NSTextView *textView;
		textView = [self firstTextView];
		NSRect frame = NSInsetRect([textView bounds], 0.0, 0.0);
		NSSize curDocFrameSize, newDocBoundsSize;
		NSView *clipView = [[[textView enclosingScrollView] documentView] superview];
		// Get the frame.  The frame must stay the same.
		curDocFrameSize = [clipView frame].size;
		// The new bounds will be frame divided by scale factor
		newDocBoundsSize.width = curDocFrameSize.width /[[sender cell] floatValue];
		newDocBoundsSize.height = curDocFrameSize.height /[[sender cell] floatValue];
		[clipView setBoundsSize:newDocBoundsSize];
		frame.size.width = frame.size.width / [[sender cell] floatValue];
		[textView setFrame:NSMakeRect(0.0, 0.0, newDocBoundsSize.width, frame.size.height)];
		frame = NSZeroRect;
		//set focus
		[[[textView enclosingScrollView] window] makeFirstResponder:textView];
		[[[textView enclosingScrollView] window] setInitialFirstResponder:textView];
		// Show the selected region
		[[self firstTextView] scrollRangeToVisible:[[self firstTextView] selectedRange]];
	}
	else
	{
		//	layout view
		[theScrollView setScaleFactor:[[sender cell] floatValue]];
	}	
	//	set scaleFactor
	[theScrollView setScaleFactor:[[sender cell] floatValue]];
	//	adjust zoom % label
	[zoomAmt setIntValue:(100 * [[sender cell] floatValue])];
}


//	menu item action to set Fit To Page or Fit To Width in Page Layout Mode
-(IBAction)zoomSelect:(id)sender
{
	//	fit width was selected
	if ([sender tag] == 1)
	{ 
		//	change to layout view
		if (![self hasMultiplePages]) [self setTheViewType:nil];
		[theScrollView setIsFitWidth:YES];
		[theScrollView setIsFitPage:NO];
		//	scaleFactor doesn't matter here cos will be set to fit page
		[theScrollView setScaleFactor:2.0];
		//	update the zoomSlider for fit to page / fit to screen resizings
		[self updateZoomSlider];
	}
	//	fit page
	if ([sender tag] == 2)
	{
		//	change to layout view
		if (![self hasMultiplePages]) [self setTheViewType:nil];
		[theScrollView setIsFitWidth:NO];
		[theScrollView setIsFitPage:YES];
		//	scaleFactor doesn't matter here cos will be set to fit page
		[theScrollView setScaleFactor:2.0];
		//	update the zoomSlider for fit to page / fit to screen resizings
		[self updateZoomSlider];
	}
	//	custom
	if ([sender tag] == 0)
	{ 
		[zoomSlider setFloatValue:[theScrollView scaleFactor]];
		[theScrollView setIsFitWidth:NO];
		[theScrollView setIsFitPage:NO];
		//	update the zoomSlider
		float zoomValue = [zoomSlider floatValue];
		[theScrollView setScaleFactor:zoomValue];
		[zoomAmt setIntValue:(100 * zoomValue)];
		zoomValue = 0.0;
	}
}

//	called to make sure zoomSlider and zoomAmt label are up to date when scrollView is resized
-(void)updateZoomSlider
{
	[zoomSlider setFloatValue:[theScrollView scaleFactor]];
	float zoomValue = [zoomSlider floatValue];
	[zoomAmt setIntValue:(100 * zoomValue)];
	zoomValue = 0.0;
}

//	user selected 'zoom in' from view menu
-(IBAction)zoomInAction:(id)sender
{
	if ([zoomSlider floatValue] < 3.8) 
	{
		[zoomSlider setFloatValue:([zoomSlider floatValue] + .2)];
		[self zoomSlider:zoomSlider];
	}
	else
	{
		[zoomSlider setFloatValue:4.0];
		[self zoomSlider:zoomSlider];
	}
}
//	user selected 'zoom out' from view menu
-(IBAction)zoomOutAction:(id)sender
{
	if ([zoomSlider floatValue] > 0.2)
	{
		[zoomSlider setFloatValue:([zoomSlider floatValue] - .2)];
		[self zoomSlider:zoomSlider];
	}
	else
	{
		[zoomSlider setFloatValue:0.1];
		[self zoomSlider:zoomSlider];
	}
}

#pragma mark -
#pragma mark ---- Print Info Methods  ----

// ************************** Preparing To Print ***************************

//	below 'printInfo' methods are from TextEdit
- (void)printInfoUpdated
{
	unsigned cnt; 
	cnt = 0;
    PageView *pageView = [theScrollView documentView];
	//	remove all text containers on the theory that they will repopulate with correct sizes
	if ([[theScrollView documentView] isKindOfClass:[PageView class]])
	{
		NSArray *textContainers = [[self layoutManager] textContainers];
        unsigned cnt = [textContainers count];
        while (cnt-- > 1)
		{
			[self removePage];
		}
		if ([[[self layoutManager] textContainers] count]==1)
		{ 
			NSRect textFrame = [self textRectForPageNumber:0];
			NSTextContainer *textContainer = [textContainers objectAtIndex:0];
			[[textContainer textView] setFrame:textFrame];
			[textContainer setContainerSize:NSMakeSize(viewWidth, viewHeight)];
		}
		[pageView setPrintInfo:[self printInfo]];
		//	if a page is added or removed
		[pageView recalculateFrame];
		//	if the page size was changed
		[pageView setNeedsDisplay:YES]; 	
	}
	//	maintain ruler state
	(areRulersVisible) ? [theScrollView setRulersVisible:YES] : [theScrollView setRulersVisible:NO];
}

//	this sets the textContainer size for the pageView class
- (NSRect)textRectForPageNumber:(unsigned)pageNumber 
{	
	//	note:first page is 0
	NSRect rect = NSZeroRect;
	//	get current paper size
	rect.size = [printInfo paperSize];	
	[self setViewWidth:(rect.size.width - [printInfo leftMargin]- [printInfo rightMargin])];
	[self setViewHeight:(rect.size.height - [printInfo topMargin] - [printInfo bottomMargin])];
	NSRect textFrame = NSZeroRect;
	textFrame.origin.x = [printInfo leftMargin] + [self pageSeparatorLength];
	textFrame.origin.y = [self pageSeparatorLength] + [printInfo topMargin] + 
			(pageNumber * (viewHeight + [printInfo bottomMargin] + [self pageSeparatorLength]
			+ [printInfo topMargin])); 
	textFrame.size.height = viewHeight;
	textFrame.size.width = viewWidth;
	return textFrame;
}

//	from Text Edit
- (void)doForegroundLayoutToCharacterIndex:(unsigned)loc
{
    unsigned len;
	//	if no loc, layout whole doc
	if (loc==0) loc=INT_MAX; //INT_MAX;
    if (loc > 0 && (len = [[self textStorage] length]) > 0)
	{
        NSRange glyphRange;
        if (loc >= len) { loc = len - 1; }
        //	find out which glyph index the desired character index corresponds to
        glyphRange = [[self layoutManager] glyphRangeForCharacterRange:NSMakeRange(loc, 1) actualCharacterRange:NULL];
        if (glyphRange.location > 0)
		{
            //	now cause layout by asking a question which has to determine where the glyph is
            (void)[[self layoutManager] textContainerForGlyphAtIndex:glyphRange.location - 1 effectiveRange:NULL];
        }
    }
}


- (void)setPrintInfo:(NSPrintInfo *)anObject
{
    if (printInfo == anObject) return;
    [printInfo autorelease];
    printInfo = [anObject copyWithZone:[self zone]];
}

//	create and return the printInfo lazily
- (NSPrintInfo *)printInfo
{
    PageView *pageView = [theScrollView documentView];
	if (printInfo == nil)
	{
		[self setPrintInfo:[NSPrintInfo sharedPrintInfo]];
		[pageView setPrintInfo:[NSPrintInfo sharedPrintInfo]];
		[printInfo setHorizontalPagination:NSFitPagination];
		[printInfo setHorizontallyCentered:NO];
		[printInfo setVerticallyCentered:NO];
	}
	return printInfo;
}

- (NSSize)paperSize
{
    return [[self printInfo] paperSize];
}


- (void)setPaperSize:(NSSize)size
{
    [[self printInfo] setPaperSize:size];
}

// ******************* Page Layout (=paperSize) Methods ********************

- (void)doPageLayout:(id)sender
{
    NSPrintInfo *tempPrintInfo = [[[self printInfo] copy] autorelease];
    NSPageLayout *pageLayout = [NSPageLayout pageLayout];
	[pageLayout beginSheetWithPrintInfo:tempPrintInfo modalForWindow:[theScrollView window] 
				delegate:self
				didEndSelector:@selector(didEndPageLayout:returnCode:contextInfo:)
				contextInfo:(void *)tempPrintInfo];
}

- (void)didEndPageLayout:(NSPageLayout *)pageLayout returnCode:(int)result contextInfo:(void *)contextInfo
{
    NSPrintInfo *tempPrintInfo = (NSPrintInfo *)contextInfo;
    PageView *pageView = [theScrollView documentView];
	[self setPrintInfo:tempPrintInfo];
	[pageView setPrintInfo:tempPrintInfo];
	[self printInfoUpdated];
	[self doForegroundLayoutToCharacterIndex:INT_MAX];
}

// ******************* Print Margins Methods ********************

//	calls the margin dialog sheet and inserts the current values
- (void)setPrintMargins:(id)sender
{
    if(printInfo == nil) { [self printInfo]; }
    if(printMarginSheet == nil) { [NSBundle loadNibNamed:@"MarginSheet" owner:self]; }
	if(printMarginSheet != nil)
	{
		//	since MarginSheet is not loaded at document nib load time, can't use isCentimetersOrInches to load the label ahead of time
		//	centimeters is reported as 28.35 points per cm, but is float so can't do check on points==28.35; Using 30.0 should be safe. ;-/
		if ([self pointsPerUnitAccessor] < 30.0)
		{
			[measurementUnitTextField setObjectValue:NSLocalizedString(@"Margins (in Centimeters)", @"label in margins sheet: Margins (in Centimeters)")];
		}
		else
		{
			[measurementUnitTextField setObjectValue:NSLocalizedString(@"Margins (in Inches)", @"label in margins sheet: Margins (in Inches)")];	
		}
		float pointsPerUnit;
		pointsPerUnit = [self pointsPerUnitAccessor];
		[tfLeftMargin setFloatValue:[printInfo leftMargin]/pointsPerUnit];
		[tfRightMargin setFloatValue:[printInfo rightMargin]/pointsPerUnit]; 
		[tfTopMargin setFloatValue:[printInfo topMargin]/pointsPerUnit];
		[tfBottomMargin setFloatValue:[printInfo bottomMargin]/pointsPerUnit];
		[NSApp beginSheet:printMarginSheet 
				modalForWindow:[NSApp mainWindow]
				modalDelegate:nil
				didEndSelector:nil
				contextInfo:nil];
		pointsPerUnit = 0.0;
    }
}

-(IBAction)printMarginsWereSet:(id)sender
{
	[NSApp stopModal];
	PageView *pageView = [theScrollView documentView];
	float pointsPerUnit;
	pointsPerUnit = [self pointsPerUnitAccessor]; 
	//	change button was pressed, so change the margins
	if (![[sender cell] tag]==0)
	{
		//	this causes text fields with uncommited edits to try to validate them before focus leaves them 
		[printMarginSheet makeFirstResponder:printMarginSheet];
		//	input in text fields was validated, apply the margins
		if ([printMarginSheet firstResponder] == printMarginSheet)
		{
			//	record old margin settings in case undo margin change is called
			[[[self undoManager] prepareWithInvocationTarget:self] 
					undoChangeLeftMargin:[printInfo leftMargin]
					rightMargin:[printInfo rightMargin] 
					topMargin:[printInfo topMargin]
					bottomMargin:[printInfo bottomMargin]];
			[[self undoManager] setActionName:NSLocalizedString(@"Change Margins", @"undo action: Change Margins")];
			//	set printInfo properties
			[printInfo setLeftMargin:[tfLeftMargin floatValue]*pointsPerUnit];
			[printInfo setRightMargin:[tfRightMargin floatValue]*pointsPerUnit];
			[printInfo setTopMargin:[tfTopMargin floatValue]*pointsPerUnit];
			[printInfo setBottomMargin:[tfBottomMargin floatValue]*pointsPerUnit];
			//	also set in pageView for display
			if ([[theScrollView documentView] isKindOfClass:[PageView class]])
			{
				[pageView setTheLeftMargin:[tfLeftMargin floatValue]*pointsPerUnit];
				[pageView setTheRightMargin:[tfRightMargin floatValue]*pointsPerUnit];
				[pageView setTheTopMargin:[tfTopMargin floatValue]*pointsPerUnit];
				[pageView setTheBottomMargin:[tfBottomMargin floatValue]*pointsPerUnit];
			}
			[self printInfoUpdated];
			[self doForegroundLayoutToCharacterIndex:INT_MAX];
			pointsPerUnit = 0.0;
		}
		//a margin settings was < 0.1 or > 6.0 units (inches or cms)
		else
		{ 
			NSBeep();
			[rangeLabel setHidden:NO];
			return;
		}
	//	cancel was pressed, so we just reset things
	}
	else
	{
		//	stop editing any fields (otherwise won't be reset to current margins)
		[tfLeftMargin abortEditing];
		[tfRightMargin abortEditing];
		[tfTopMargin abortEditing];
		[tfBottomMargin abortEditing];
		//	reset the fields to match printInfo
		[tfLeftMargin setFloatValue:[printInfo leftMargin]/pointsPerUnit];
		[tfRightMargin setFloatValue:[printInfo rightMargin]/pointsPerUnit];  
		[tfTopMargin setFloatValue:[printInfo topMargin]/pointsPerUnit];
		[tfBottomMargin setFloatValue:[printInfo bottomMargin]/pointsPerUnit];
	}
	//	dismiss the sheet after margin changes appear on screen 
	[NSApp endSheet: printMarginSheet];
	[printMarginSheet orderOut:self];
}

//	undoes a change margin action
- (void)undoChangeLeftMargin:(int)theLeftMargin 
				 rightMargin:(int)theRightMargin 
				   topMargin:(int)theTopMargin
				bottomMargin:(int)theBottomMargin
{
	PageView *pageView = [theScrollView documentView];
	float pointsPerUnit;
	pointsPerUnit = [self pointsPerUnitAccessor]; 
	
	//	record old margin settings in case undo margin change is called
	[[[self undoManager] prepareWithInvocationTarget:self] 
				undoChangeLeftMargin:[printInfo leftMargin] 
				rightMargin:[printInfo rightMargin] 
				topMargin:[printInfo topMargin]
				bottomMargin:[printInfo bottomMargin]];
	[[self undoManager] setActionName:NSLocalizedString(@"Change Margins", @"undo action: Change Margins")];
	
	//	reset the sheet's fields to match printInfo
	[tfLeftMargin setFloatValue:theLeftMargin/pointsPerUnit];
	[tfRightMargin setFloatValue:theRightMargin/pointsPerUnit];  
	[tfTopMargin setFloatValue:theTopMargin/pointsPerUnit];
	[tfBottomMargin setFloatValue:theBottomMargin/pointsPerUnit];
	//	set printInfo properities
	[printInfo setLeftMargin:theLeftMargin];
	[printInfo setRightMargin:theRightMargin];
	[printInfo setTopMargin:theTopMargin];
	[printInfo setBottomMargin:theBottomMargin];
	//	also set in pageView for display
	[pageView setTheLeftMargin:theLeftMargin];
	[pageView setTheRightMargin:theRightMargin];
	[pageView setTheTopMargin:theTopMargin];
	[pageView setTheBottomMargin:theBottomMargin];
	//	update things
	[self printInfoUpdated];
	[self doForegroundLayoutToCharacterIndex:INT_MAX];
	pointsPerUnit = 0.0;
}  

#pragma mark -
#pragma mark ---- Print Method ----

// ******************* the print method *******************

//	prints directly from the scrollView's document view
- (void)printDocument:(id)sender
{
	//	if continuous text view, create pageView because we actually print from that view
	if (![self hasMultiplePages])
	{
		[self setShouldRestorePageViewAfterPrinting:YES];
		[self setTheViewType:nil];
	}
	else
	{
		[self setShouldRestorePageViewAfterPrinting:NO];
	}
	//	if alternate text colors in use, since we print directly from the pageView, change to standard colors before printing
	if ([[[self firstTextView] backgroundColor] isEqual:[self textViewBackgroundColor]])
	{
		//	get rid of temp color attributes
		[[self layoutManager] removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:NSMakeRange(0, [[[self firstTextView] textStorage] length])];
		//	set background color to white
		[[self firstTextView] setBackgroundColor:[NSColor whiteColor]]; 
		[[theScrollView documentView] setShouldUseAltTextColors:NO];
		[[theScrollView documentView] setNeedsDisplay:YES];
		[self setRestoreAltTextColors:YES];
	}
	//	if showing Invisible Characters, make them invisible again so they don't print, then restore them
	if ([[self layoutManager] showInvisibleCharacters])
	{
		[self setRestoreShowInvisibles:YES];
		[[self layoutManager] setShowInvisibleCharacters:NO];
		[[self firstTextView] setNeedsDisplay:YES];
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//printing of header and footers is always turned on, but pageView returns the header and footer strings only if user preferences say so
#ifndef GNUSTEP
	[defaults setValue:[NSNumber numberWithBool:YES] forKey:NSPrintHeaderAndFooter];
#endif
	//	print to PDF (if menu action sends proper tag)
	if ([sender tag]==100)
	{
		int exportFileNumber = 0;
		//	get path with extension removed, then add .pdf extension
		NSString *thePathMinusExtension = [[self fileName] stringByDeletingPathExtension];
		NSString *theExportPath = [NSString stringWithFormat:@"%@%@", thePathMinusExtension, @".pdf"];
		//	to avoid overwriting previous export, add sequential numbers to filename just before extension
		while ([[NSFileManager defaultManager] fileExistsAtPath:theExportPath] && exportFileNumber < 1000)
		{
			exportFileNumber = exportFileNumber + 1;
			theExportPath = [NSString stringWithFormat:@"%@%@%i%@", thePathMinusExtension, @" ", exportFileNumber, @".pdf"];
		}
		NSPrintInfo *pdfPrintInfo;
		NSPrintInfo *sharedInfo;
		NSMutableDictionary *sharedDict;
		NSPrintOperation *printOp;
		NSMutableDictionary *pdfPrintInfoDict;
		//	get shared info
		sharedInfo = [NSPrintInfo sharedPrintInfo];
		sharedDict = [sharedInfo dictionary];
		pdfPrintInfoDict = [NSMutableDictionary dictionaryWithDictionary:[printInfo dictionary]];
		//	change bits we'er interested in
		[pdfPrintInfoDict setObject:NSPrintSaveJob forKey:NSPrintJobDisposition];
		[pdfPrintInfoDict setObject:theExportPath forKey:NSPrintSavePath];
		pdfPrintInfo = [[NSPrintInfo alloc] initWithDictionary: pdfPrintInfoDict];
		[pdfPrintInfo setHorizontalPagination: NSAutoPagination];
		[pdfPrintInfo setVerticalPagination: NSAutoPagination];
		[pdfPrintInfo setVerticallyCentered:NO];
		printOp = [NSPrintOperation
					printOperationWithView:[theScrollView documentView]
					printInfo:pdfPrintInfo ];				
		[printOp setShowPanels:NO];
		[printOp runOperationModalForWindow:[ [theScrollView documentView] window]
					delegate:self
					didRunSelector:@selector(printOperationDidRun:success:contextInfo:) 
					contextInfo:NULL ];
		[pdfPrintInfo release]; //	12 July 2007 BH added to balance alloc
		//	show exported file in Finder for the user
		[[NSWorkspace sharedWorkspace] selectFile:theExportPath inFileViewerRootedAtPath:nil];
	}
	//	print to printer
	else
	{
	//	we print directly from the scrollView's documentView
	NSPrintOperation *op = [NSPrintOperation
				printOperationWithView:[theScrollView documentView]
				printInfo:[self printInfo] ];				
	[op	runOperationModalForWindow:[ [theScrollView documentView] window]
				delegate:self
				didRunSelector:@selector(printOperationDidRun:success:contextInfo:) 
				contextInfo:NULL ];
	}
}
 
- (void)printOperationDidRun:(NSPrintOperation *)printOperation
			success:(BOOL)success
			contextInfo:(void *)info
{
    if (!success)
	{
		//	error message here?
	}
	//	if we un-enabled alternate text display colors to print, so we restore them here
	if ([self restoreAltTextColors])
	{
		if (!altTextColor)
		{
			//gets released in dealloc method
			altTextColor = [[NSDictionary alloc] initWithObjectsAndKeys:[self textViewTextColor], NSForegroundColorAttributeName, nil];
		}
		//	set foreground to temp color
		[layoutManager addTemporaryAttributes:altTextColor forCharacterRange:NSMakeRange(0, [[[self firstTextView] textStorage] length])]; 
		//	set background to temp background color
		[[self firstTextView] setBackgroundColor:textViewBackgroundColor];
		[[theScrollView documentView] setShouldUseAltTextColors:YES];
		[[theScrollView documentView] setNeedsDisplay:YES];
		[self setRestoreAltTextColors:NO];
	}
	//	restore showing invisibles, if necessary
	if ([self restoreShowInvisibles])
	{
		[[self layoutManager] setShowInvisibleCharacters:YES];
		[[self firstTextView] setNeedsDisplay:YES];
		[self setRestoreShowInvisibles:NO];
	}
	//	if we switched to pageView in order to print from it, switch back to continuous textView
	if ([self shouldRestorePageViewAfterPrinting]) { [self setTheViewType:nil]; }
}

#pragma mark -
#pragma mark ---- Link Sheet Methods ----

// ******************* textView linkSheet action methods ********************

- (void)showLinkSheet:(id)sender
{
	//	load it if not already loaded
	if(linkSheet == nil)
	{
		[NSBundle loadNibNamed:@"LinkSheet" owner:self];
	}
	//	call up the sheet if it exits
	if(linkSheet != nil)
	{
		NSTextView *textView = [self firstTextView];
		//	if text was selected, link attributes will be added to that text; otherwise link itself will be inserted
		if (![textView selectedRange].length==0)
		{
			NSDictionary *theAttributes;
			NSObject *theLink;
			theAttributes = [[textView textStorage] attributesAtIndex:[textView selectedRange].location  effectiveRange:NULL];
			theLink = [theAttributes objectForKey: @"NSLink"]; //NSLinkAttributedName
			//	if a link previously exists, insert it into sheet for editing, etc.
			if (!theLink == nil)
			{
				//	create a string from the object's value
				NSString *theLinkString = [NSString stringWithFormat:@"%@", theLink];
				//	prune the prefix (http://  ...  file://   ...  mailto:) and insert remainder into textField
				[linkTextField setStringValue:[theLinkString substringFromIndex:7]];
				//	use prefix to determine which type of link to indicate
				NSString *theLinkPrefixString = [[theLinkString substringToIndex:4] lowercaseString];
				if ([theLinkPrefixString isEqualToString:@"http"])
				{
					[linkSelectMatrix selectCellWithTag:0];
					[linkPrefixTextField setStringValue:@"http://"];
				}
				else if ([theLinkPrefixString isEqualToString:@"file"])
				{
					[linkSelectMatrix selectCellWithTag:1];
					[linkPrefixTextField setStringValue:@"file://"];
				}
				else if ([theLinkPrefixString isEqualToString:@"mail"])
				{
					[linkSelectMatrix selectCellWithTag:2];
					[linkPrefixTextField setStringValue:@"mailto:"];
				}
				else
				{
					[linkSelectMatrix selectCellWithTag:3];
					[linkTextField setStringValue:theLinkString];
					[linkPrefixTextField setStringValue:@""];
				}
			}
			//	no link attribute exists in selected text
			else
			{
				//	select link style based on tag saved from previous sheet action (default = 0), since odds are that type will be the same
				switch ([self linkPrefixTag])
				{
					case 0: //web
						[linkPrefixTextField setStringValue:@"http://"];
						[linkSelectMatrix selectCellWithTag:[self linkPrefixTag]];
						break;
					case 1: //file
						[linkPrefixTextField setStringValue:@"file://"];
						[linkSelectMatrix selectCellWithTag:[self linkPrefixTag]];
						break;
					case 2: //email
						[linkPrefixTextField setStringValue:@"mailto:"];
						[linkSelectMatrix selectCellWithTag:[self linkPrefixTag]];
						break;
					case 3: //no prefix
						[linkPrefixTextField setStringValue:@""];
						[linkSelectMatrix selectCellWithTag:[self linkPrefixTag]];
						break;
				}
			}	
		}
		//	now call the linkSheet
		[NSApp beginSheet:linkSheet 
				modalForWindow:[NSApp mainWindow]
				modalDelegate:self
				didEndSelector:nil
				contextInfo:nil];
	}
}

-(IBAction)cancelLink:(id)sender
{
//	we now save the link type, so don't reset
//	[linkSelectMatrix selectCellWithTag:0];
//	[linkPrefixTextField setStringValue:@"http://"];
	[linkTextField setStringValue:@""];
	[NSApp endSheet: [sender window]];
	[[sender window] orderOut:self];
}

-(IBAction)selectLinkType:(id)sender
{
	switch ([sender selectedRow]) {
		case 0: //web
			[linkPrefixTextField setStringValue:@"http://"];
			[self setLinkPrefixTag:0];
			break;
		case 1: //file
			[linkPrefixTextField setStringValue:@"file://"];
			[self setLinkPrefixTag:1];
			break;
		case 2: //email
			[linkPrefixTextField setStringValue:@"mailto:"];
			[self setLinkPrefixTag:2];
			break;
		case 3: //no prefix
			[linkPrefixTextField setStringValue:@""];
			[self setLinkPrefixTag:3];
			break;
	}
}

-(IBAction)applyLink:(id)sender
{
	NSTextView	*textView = [self firstTextView];
    NSRange	selection;
	selection = [textView selectedRange];
    NSObject *linkObject;
    NSMutableDictionary *linkAttributes;

    //	apply link attribute only if there was something entered in the 'link' text field
	if (![[linkTextField stringValue] isEqualToString:@""])
	{
		NSString *theLinkDestination = [NSString stringWithFormat:@"%@%@", [linkPrefixTextField stringValue], [linkTextField stringValue]];
		linkObject = theLinkDestination;
		//	no link was input, so bail out
		if (linkObject == nil) return;
		//	for undo
		[textView shouldChangeTextInRange:[textView selectedRange] replacementString:nil];
		if (selection.length == 0)
		{
			//	we add a space that preserves the previous attributes so the new link will not spill into user's subsequent text input
			[textView insertText:[NSString stringWithFormat:@"%@%@",[linkTextField stringValue], @" "]];
			selection = NSMakeRange(selection.location,[[linkTextField stringValue] length]);
		}
		//	NSLinkAttributeName => the object
		linkAttributes = [NSMutableDictionary dictionaryWithObject: linkObject forKey: NSLinkAttributeName];
		//	add attributes to the selected range (not 'set' which erases other attributes)
		[[textView textStorage] addAttributes: linkAttributes  range: selection];
		//	end undo
		[textView didChangeText];
		//	name undo for menu
		[[self undoManager] setActionName:NSLocalizedString(@"Link", @"Undo action name: Link ( = create URL link)")];
	}
	//	we now save the link type in an accessor, so don't reset to default
	//	[linkSelectMatrix selectCellWithTag:0];
	//	[linkPrefixTextField setStringValue:@"http://"];
	//	to save the link type (the tag of the selected URL prefix)
	[self selectLinkType:linkSelectMatrix];
	[linkTextField setStringValue:@""];
	//	dismiss sheet
	[NSApp endSheet: [sender window]];
	[[sender window] orderOut:self];
}

// ******************* set view size from document wide defaults ********************

//	the 'viewSize is the window size; this is saved to document-wide attributes
- (NSSize)theViewSize
{
		return [NSScrollView contentSizeForFrameSize:[docWindow frame].size hasHorizontalScroller:[theScrollView hasHorizontalScroller] 
					hasVerticalScroller:[theScrollView hasVerticalScroller] borderType:[theScrollView borderType]];
}

//	set the 'viewSize' from saved doc attributes - really it represents the window size
- (void)setViewSize:(NSSize)size
{
	NSWindow *window = [theScrollView window];
	NSRect origWindowFrame = [window frame];
	NSSize scrollViewSize;
	scrollViewSize = [NSScrollView frameSizeForContentSize:size hasHorizontalScroller:[theScrollView hasHorizontalScroller] 
				hasVerticalScroller:[theScrollView hasVerticalScroller] borderType:[theScrollView borderType]];
	[window setContentSize:scrollViewSize];
	[window setFrameTopLeftPoint:NSMakePoint(origWindowFrame.origin.x, NSMaxY(origWindowFrame))];
}

#pragma mark -
#pragma mark ---- TextList Methods ----

// ******************* Text List Methods *******************

//	create a numbered and a bulleted list without having to go through the 'List Marker' panel
- (IBAction)listItemIndent:(id)sender
{
	//	causes indent of textList item only
	[[self firstTextView] moveToBeginningOfLine:sender];
	[[self firstTextView] insertTab:sender];
}

- (IBAction)listItemUnindent:(id)sender
{
	//	causes un-indent of textList item
	[[self firstTextView] moveToBeginningOfLine:sender];
	[[self firstTextView] insertBacktab:sender];
}

//	turn text paragraph(s) into list items with specified markers without user going through 'List Marker' panel
- (IBAction)specialTextListAction:(id)sender
{
	//	native List action is smarter, but less intuitive;
	//	note: this works on first selected range only (List... works on selectedRanges)
	NSTextList *theList;
	//	kind of marker
	if ([sender tag]==0) //bullet
	{
		theList = [[[NSTextList alloc] initWithMarkerFormat:@"{disc}" options:nil] autorelease];
	}
	else if ([sender tag]==1) //arabic number and dot
	{
		theList = [[[NSTextList alloc] initWithMarkerFormat:@"{decimal}." options:nil] autorelease];
	} 
	
	NSArray *theListArray = [NSArray arrayWithObjects:theList, nil];
	
	//FIXME: It'd be nice to create a ready-made MLA style outline, somehow
	//marker types:
	/*
	NSTextList *urList = [[[NSTextList alloc] initWithMarkerFormat:@"{upper-roman}." options:nil] autorelease];
	NSTextList *uaList = [[[NSTextList alloc] initWithMarkerFormat:@"{upper-alpha}." options:nil] autorelease];
	NSTextList *decList = [[[NSTextList alloc] initWithMarkerFormat:@"{decimal}." options:nil] autorelease];
	NSTextList *laList = [[[NSTextList alloc] initWithMarkerFormat:@"{lower-alpha}." options:nil] autorelease];
	NSTextList *dec2List = [[[NSTextList alloc] initWithMarkerFormat:@"({decimal})" options:nil] autorelease];
	NSTextList *la2List = [[[NSTextList alloc] initWithMarkerFormat:@"({lower-alpha})" options:nil] autorelease];
	//an array of marker types, forming an MLA-style outline
	NSArray *theListArray = [NSArray arrayWithObjects:urList, uaList, decList, laList, dec2List, la2List, urList, nil];
	*/
	
	//	set up tabStops for the list items
	float pointsPerUnit = [self pointsPerUnitAccessor];
	float tabValue1 = .15 * pointsPerUnit;  // Every cm or half inch
	float tabValue2 = .5 * pointsPerUnit;
	NSTextTab *tabStop1;
	NSTextTab *tabStop2;
	tabStop1 = [[[NSTextTab alloc] initWithType:NSLeftTabStopType location:tabValue1] autorelease]; 
	tabStop2 = [[[NSTextTab alloc] initWithType:NSLeftTabStopType location:tabValue2] autorelease]; 
	
	unsigned paragraphNumber;
	//	an array of NSRanges containing applicable (possibly grouped) whole paragraph boundaries
	NSArray *theRangesForChange = [[self firstTextView] rangesForUserParagraphAttributeChange];
	//	a range containing one or more paragraphs
	NSRange theCurrentRange;
	//	a range containing the paragraph of interest 
	NSRange theCurrentParagraphRange;
	//	figure effected range for undo
	int undoRangeIndex = [[self firstTextView] rangeForUserParagraphAttributeChange].location;
	int undoRangeLength = [[theRangesForChange objectAtIndex:([theRangesForChange count] - 1)] rangeValue].location
		+ [[theRangesForChange objectAtIndex:([theRangesForChange count] - 1)] rangeValue].length - undoRangeIndex;
	//	start undo setup
	if ([[self firstTextView] shouldChangeTextInRange:NSMakeRange(undoRangeIndex,undoRangeLength) replacementString:nil])
	{
		[textStorage beginEditing]; //bracket for efficiency
		//	iterate through ranges of paragraph groupings
		for (paragraphNumber = 0; paragraphNumber < [theRangesForChange count]; paragraphNumber++)
		{
			//	set range for first (or only) paragraph; index is needed to locate paragraph; length is not important
			//	note: function rangesForUserPargraphAttributeChange returns NSValues (objects), so we use rangeValue to get NSRange value
			theCurrentParagraphRange = [[theRangesForChange objectAtIndex:paragraphNumber] rangeValue];
			theCurrentRange = [[theRangesForChange objectAtIndex:paragraphNumber] rangeValue];
			//	now, step thru theCurrentRange paragraph by paragraph 
			while (theCurrentParagraphRange.location < (theCurrentRange.location + theCurrentRange.length))
			{
				//	get the actual paragraph range including length
				theCurrentParagraphRange = [[textStorage string] paragraphRangeForRange:NSMakeRange(theCurrentParagraphRange.location, 1)];
				//	get the paragraphStyle
				NSMutableParagraphStyle *theParagraphStyle = [textStorage attribute:NSParagraphStyleAttributeName atIndex:theCurrentParagraphRange.location effectiveRange:NULL];
				if (theParagraphStyle==nil)
				{
					theParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
				}
				else
				{
					theParagraphStyle = [[theParagraphStyle mutableCopyWithZone:[[self firstTextView] zone]]autorelease];
				}
				//	remove all tabStops from textList items
				[theParagraphStyle setTabStops:[NSArray arrayWithObjects:nil]];
				[theParagraphStyle setFirstLineHeadIndent:0.0];
				
				//	add new tabStops to paragraph
				//tabStop1 = [[NSTextTab alloc] initWithType:NSLeftTabStopType location:tabValue1 + [theParagraphStyle firstLineHeadIndent]]; ///
				//tabStop2 = [[NSTextTab alloc] initWithType:NSLeftTabStopType location:tabValue2 + [theParagraphStyle firstLineHeadIndent]]; ///

				[theParagraphStyle addTabStop:tabStop1];
				[theParagraphStyle addTabStop:tabStop2];
				
				//[tabStop1 release]; ///
				//[tabStop2 release]; ///
				
				//	add text list attribute to the current paragraphStyle
				[theParagraphStyle setTextLists:theListArray];
				
				//	add the paragraphStyle attribute to the current paragraph in textStorage
				[textStorage addAttribute:NSParagraphStyleAttributeName value:theParagraphStyle range:theCurrentParagraphRange];
				//	add style to the current typingAttributes
				NSDictionary *theAttributes = [[self firstTextView] typingAttributes];
				NSMutableDictionary *theTypingAttributes = [[theAttributes mutableCopy] autorelease];
				[theTypingAttributes setObject:theParagraphStyle forKey:NSParagraphStyleAttributeName];
				[[self firstTextView] setTypingAttributes:theTypingAttributes];
				
				//	make index the first letter of the next paragraph
				theCurrentParagraphRange = NSMakeRange((theCurrentParagraphRange.location + theCurrentParagraphRange.length),1);
			}
		}
		[textStorage endEditing]; //close bracket
		//end undo setup
		[[self firstTextView] didChangeText];
		//name undo action, based on tag of control
		[[self undoManager] setActionName:@"List"];
	}
	//	this nonsense appers to be necessary to actually get the textList to display! seems to be no simple way to do it
	NSRange theSelectedRange = [[self firstTextView] selectedRange];
	//	if you just cut and paste the whole thing, it doesn't work, so all minus 1 character
	[[self firstTextView] setSelectedRange:NSMakeRange(theSelectedRange.location, theSelectedRange.length - 1)];
	//	cut and paste causes the list markers to show up
	[[self firstTextView] cut:nil];
	[[self firstTextView] paste:nil];
	//	restore the previous selected range
	[[self firstTextView] setSelectedRange:theSelectedRange];
}

#pragma mark -
#pragma mark --- Presenting Errors ---

// ******************* Presenting Errors ********************

- (NSError *)willPresentError:(NSError *)error
{
	if ([[error domain] isEqualToString:NSCocoaErrorDomain])
	{
		NSString *errorString;
		int errorCode = [error code];
		
		NSString *docName = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"firstLevelOpenQuote", nil), [self displayName], NSLocalizedString(@"firstLevelCloseQuote", nil)]; 
		
		NSFileManager *fm = [NSFileManager defaultManager];
		//	range of cocoa errors possible when writing files
		if ( (errorCode >= 512 && errorCode <= 640 ) || errorCode==66062)
		{
			if (errorCode==NSFileWriteInvalidFileNameError)
			{
				errorString = [NSString stringWithFormat:NSLocalizedString(@"The document %@ could not be saved because the filename is not valid.", @"alert title: The document (document name inserted at runtime) could not be saved because the filename is not valid."), docName];
			}
			else if (errorCode==NSFileWriteOutOfSpaceError)
			{
				errorString = [NSString stringWithFormat:NSLocalizedString(@"The document %@ could not be saved due to lack of space.", @"alert title: The document (document name inserted at runtime) could not be saved due to lack of space."), docName];
			}
			else if (errorCode==NSFileWriteNoPermissionError)
			{
				errorString = [NSString stringWithFormat:NSLocalizedString(@"The document %@ could not be saved due to lack of permission to write the file.", @"alert title: The document (document name inserted at runtime) could not be saved due to lack of permission to write the file."), docName];
			}
			//	write error, so try to determine exact error
			else if (errorCode==NSFileWriteUnknownError)
			{
				//	folder not writable
				if 	(![fm isWritableFileAtPath:[[self fileName] stringByDeletingLastPathComponent]])
				{
					NSDictionary *theFolderAttrs = [fm fileAttributesAtPath:[[self fileName] stringByDeletingLastPathComponent] traverseLink:YES];
					//	error: containing folder is locked
					if ([[theFolderAttrs objectForKey:NSFileImmutable] boolValue] == YES) 
					{
						errorString = [NSString stringWithFormat:NSLocalizedString(@"The document %@ could not be saved because the containing folder is locked.", @"alert title: The document (document name inserted at runtime) could not be saved because the containing folder is locked."), docName];
					}
					//	some other problem writing to folder
					else 
					{
						errorString = [NSString stringWithFormat:NSLocalizedString(@"The document %@ could not be saved because of a problem writing to the folder.", @"alert title: The document (document name inserted at runtime) could not be saved because of a problem writing to the folder."), docName];
					}
				}
				else if (![fm isWritableFileAtPath:[self fileName]])
				{
					NSDictionary *theFileAttrs = [fm fileAttributesAtPath:[self fileName] traverseLink:YES];
					//	error: file is locked
					if ([[theFileAttrs objectForKey:NSFileImmutable] boolValue] == YES)
					{	
						errorString = [NSString stringWithFormat:NSLocalizedString(@"The document %@ could not be saved because the file is locked.", @"alert title: The document (document name inserted at runtime) could not be saved because the file is locked."), docName];						
					}
					//	unknown error
					else
					{
						errorString = [NSString stringWithFormat:NSLocalizedString(@"The document %@ could not be saved due to an unknown error.", @"alert title: The document (document name inserted at runtime) could not be saved due to an unknown error."), docName];
					}
				}
			//	determine kind of error (we know it's not a write error)
			}
			// error 66062 (not a compatible file format)
#ifndef GNUSTEP
			else if (errorCode==NSTextWriteInapplicableDocumentTypeError)
			{
				errorString = [NSString stringWithFormat:NSLocalizedString(@"The document %@ is not in a format that Bean can save.", @"alert title: The document (document name inserted at runtime)is not in a format that Bean can save."),docName];
			}
#endif
			//	unknown error
			else
			{
				errorString = [NSString stringWithFormat:NSLocalizedString(@"The document %@ could not be saved due to an unknown error.", @"alert title: The document (document name inserted at runtime) could not be saved due to an unknown error."), docName];
			}
			//	std dialog says "File Could not Be Saved" [OK]; we add more detail and a Save As option
			NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:4];
			[userInfo setObject:errorString forKey:NSLocalizedDescriptionKey];
			[userInfo setObject: NSLocalizedString(@"Try saving as another document to keep your changes.", @"alert text: Try saving as another document to keep changes. (alert shown upon failure to save document)")
						 forKey:NSLocalizedRecoverySuggestionErrorKey];
			[userInfo setObject:self forKey:NSRecoveryAttempterErrorKey];
			[userInfo setObject:[NSArray arrayWithObjects: NSLocalizedString(@"Save As...", @"button: Save As..."), 
						NSLocalizedString(@"Cancel", @"button: Cancel"), nil] forKey:NSLocalizedRecoveryOptionsErrorKey];
			NSError *newError = nil;
			newError = [[[NSError alloc] initWithDomain:[error domain] code:[error code] userInfo:userInfo] autorelease];
			return newError;
		}
	}
	return [super willPresentError:error];
}

- (void)attemptRecoveryFromError:(NSError *)error 
			optionIndex:(unsigned int)recoveryOptionIndex 
			delegate:(id)inDelegate 
			didRecoverSelector:(SEL)inDidRecoverSelector
			contextInfo:(void *)inContextInfo
{
	//	dismiss sheet
	NSWindow *sheet = [[[self firstTextView] window] attachedSheet]; 
	[NSApp endSheet:sheet];
	[sheet orderOut:nil];
	//	user picked 'Save As...' recovery
    if (recoveryOptionIndex == 0)
	{
		//	save old filename, use it to remind user of original name (via prepareSavePanel)
		[self setOriginalFileName:[[self fileName] lastPathComponent]];
		int newFileNumber = 0;
		NSString *thePathMinusExtension = [[self fileName] stringByDeletingPathExtension];
		NSString *thePathExtension = [[self fileName] pathExtension];
		//	for recovery from a save file error, attempt to save open document to a new filename using Save As...
		//	FIXME: what if there is no extension?
		NSString *theNewPath = [NSString stringWithFormat:@"%@%@.%@", thePathMinusExtension, 
					NSLocalizedString(@" copy", @"text to add into filename after initial name and before extension when user encounters an error saving the file and chooses to attempt to save as a renamed file, which is a ' copy'. (Note the space before the word ' copy'."), thePathExtension];
		while ([[NSFileManager defaultManager] fileExistsAtPath:theNewPath] && newFileNumber < 1000)
		{
			newFileNumber = newFileNumber + 1;
			theNewPath = [NSString stringWithFormat:@"%@%@%i%@%@", 
				thePathMinusExtension, @" ", newFileNumber, @".", thePathExtension];
		}
		[self setFileName:theNewPath];
		[self runModalSavePanelForSaveOperation:NSSaveAsOperation delegate:self didSaveSelector:@selector(document:didSaveAfterAlert:contextInfo:) contextInfo:nil];
	}
	else
		[self didPresentErrorWithRecovery:NO contextInfo:nil];
}

- (void)document:(NSDocument *)doc didSaveAfterAlert:(BOOL)didSave contextInfo:(void  *)contextInfo
{
	[self didPresentErrorWithRecovery:didSave contextInfo:nil];
}

- (void)didPresentErrorWithRecovery:(BOOL)didRecover contextInfo:(void *)contextInfo
{
    if (!didRecover)
		[self setDocEdited:YES];
}

#pragma mark -
#pragma mark --- Close Gracefully Methods ---

// ******************* Close the Window / the App Gracefully ********************

- (void)canCloseDocumentWithDelegate:(id)inDelegate 
			shouldCloseSelector:(SEL)inShouldCloseSelector
			contextInfo:(void *)inContextInfo
{
	//	if should createDatedBackup (prefs) AND not empty doc AND not unsaved doc AND doc was saved with changes, then back it up
	if ([self createDatedBackup] && ![self isTransientDocument] && ![self fileName]==nil && [self needsDatedBackup])
	{
		//	do backup
		BOOL success = [self backupDocument]; 
		if (success)
		{
			//	prevents multiple backups because of different notifications which might occur at close
			[self setCreateDatedBackup:NO];
		}
		else
		{
			//	don't try again; otherwise, user won't be able to close window
			[self setCreateDatedBackup:NO];
			[alertSheet setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Automatic backup of the document \\U201C%@\\U201D was not successful.", @"alert title: Automatic backup of the document (document name inserted at runtime) was not successful."), [self displayName]]];
			[alertSheet setInformativeText:NSLocalizedString(@"Try using the Finder to make a backup copy of this file. Deselect \\U2018Backup at close\\U2019 under \\U2018Get Info\\U2019 to disable automatic backup.", @"alert text: Try using the Finder to make a backup copy of this file. (translator: this alert is shown because automatic backup was not successful) Deselect 'Backup at close' under 'Get Info' to disable automatic backup.")];
			[alertSheet runModal];            		
		}
	}
		
	if (![self isDirty])
	{	
		//	if not edited, no need to save, so tell selector to close document
		[super canCloseDocumentWithDelegate:inDelegate 
					shouldCloseSelector:inShouldCloseSelector
					contextInfo:inContextInfo];
	}
	else
	{	
		//	typeDef to convey needed info as object to selector of canCloseWithDelegate via callback
		SelectorContextInfo *selectorContextInfo = malloc(sizeof(SelectorContextInfo));
		selectorContextInfo -> delegate = inDelegate;
		selectorContextInfo -> shouldCloseSelector = inShouldCloseSelector;
		selectorContextInfo -> contextInfo = inContextInfo;
		//	alert that doc has changed, save?
		NSString *title = nil;
		NSString *infoText = nil;
		infoText = NSLocalizedString(@"Your changes will be lost if you don\\U2019t save them.", @"alert text: Your changes will be lost if you don't save them.");
		NSString *docName = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"firstLevelOpenQuote", nil), [self displayName], NSLocalizedString(@"firstLevelCloseQuote", nil)]; 
		if ([self fileName])
		{
			title = [NSString stringWithFormat:NSLocalizedString(@"Do you want to save the changes you made in the document %@?", @"alert title: Do you want to save the changes you made in the document (name of document inserted at runtime -- nothing inserted if not named yet)?"), docName];
		}
		else
		{
			title = NSLocalizedString(@"Do you want to save the changes you made in this document?", @"alert title: Do you want to save the changes you made in this document?");
		}
		NSBeginAlertSheet(title, NSLocalizedString(@"Save", @"button: Save"), NSLocalizedString(@"Don\\U2019t Save", @"button: Don't Save"), NSLocalizedString(@"Cancel", @"button: Cancel"), docWindow, self, NULL, 
				@selector(canCloseAlertDidEnd:returnCode:contextInfo:), selectorContextInfo, infoText); 
	}
}

- (void)canCloseAlertDidEnd:(NSAlert *)alert 
			returnCode:(int)returnCode
			contextInfo:(void *)callBackInfo;
{

#define Save		NSAlertDefaultReturn
#define DontSave	NSAlertAlternateReturn
#define Cancel		NSAlertOtherReturn
	
	SelectorContextInfo *selectorContextInfo = callBackInfo; //	this is freed after the switch
	switch (returnCode)
	{
		case Save:
		{
			if ([self checkBeforeSaveWithContextInfo:callBackInfo isClosing:YES])
			{	
				//	success on save = can close; failure = cannot close
				[self saveDocumentWithDelegate:selectorContextInfo->delegate
							didSaveSelector:selectorContextInfo->shouldCloseSelector 
							contextInfo:selectorContextInfo->contextInfo];
			}
			else
			{
				//	return here to avoid freeing selectorContextInfo, which will be freed in checkBeforeSave...
				return;
			}
			break;
		}
		case Cancel:
		{
			//	send 'NO' callback to selector for canCloseWithDelegate (= don't close)
			void (*meth)(id, SEL, MyDocument *, BOOL, void*);
			meth = (void (*)(id, SEL, MyDocument *, BOOL, void*))[selectorContextInfo->delegate methodForSelector:selectorContextInfo->shouldCloseSelector];
			if (meth) { meth(selectorContextInfo->delegate, selectorContextInfo->shouldCloseSelector, self, NO, selectorContextInfo->contextInfo); }
			//	tell app to stop termination
			[NSApp replyToApplicationShouldTerminate:NSTerminateCancel];
			break;
		}
		case DontSave:
		{
			//	send 'YES' callback to selector for canCloseWithDelegate (= close without save)
			void (*meth)(id, SEL, MyDocument *, BOOL, void*);
			meth = (void (*)(id, SEL, MyDocument *, BOOL, void*))[selectorContextInfo->delegate methodForSelector:selectorContextInfo->shouldCloseSelector];
			if (meth)
				meth(selectorContextInfo->delegate, selectorContextInfo->shouldCloseSelector, self, YES, selectorContextInfo->contextInfo);
			break;
		}	
	}
	//	free memory
	free(selectorContextInfo);
}

- (BOOL)windowShouldClose:(id)sender
{
	//	indicates to repeating actions (such as word count) that they need to end immediately
	[self setIsTerminatingGracefully:YES];
	return YES;
}

-(void)windowWillClose:(NSNotification *)theNotification
{
	//	we invalidate timer here, or else dealloc doesn't get called (because the target of the timer
	//	is self (MyDocument), and so self is retained and never gets released (got that?)
	if (autosaveTimer)
	{
		[autosaveTimer invalidate];
		[autosaveTimer release];
		autosaveTimer = NULL;
	}
}

//	closes untitled, unused docs upon opening saved docs
- (void)closeTheTransientDocument
{
	NSArray *theDocuments = [[NSDocumentController sharedDocumentController] documents];
	NSEnumerator *e = [theDocuments objectEnumerator];
	MyDocument *theDocument;
	while (theDocument = [e nextObject])
	{
		//	close any transient (un-used) doc that isn't in the process of fading in
		if ([theDocument isTransientDocument]==YES)
		{
			[theDocument close];
		}
	}
}

#pragma mark -
#pragma mark ---- Backup, Autosave Methods ----

// ******************* Back Up the Doc Method *******************

//	this is done automatically at document close according to Preferences setting, or else at user discretion do as a menu action
-(IBAction)backupDocumentAction:(id)sender
{
	BOOL success = [self backupDocument];
	//	message that backup was not succcessful
	if (!success)
	{
		NSString *title = NSLocalizedString(@"The backup was not successful.", @"alert title: The backup was not successful. (alert shown upon failure of backup file save)");
		NSString *infoText = NSLocalizedString(@"A date-stamped backup copy of this document could not be created due to an unknown problem.", @"alert text: A date-stamped backup copy of this document could not be created due to an unknown problem.");
		NSBeginAlertSheet(title, NSLocalizedString(@"OK", @"OK"), nil, nil, [[self firstTextView] window], self, nil, nil, NULL, infoText, NULL);
	}
}

-(IBAction)backupDocumentAtQuitAction:(id)sender
{
	//if should createDatedBackup (prefs) AND not empty doc AND not unsaved doc AND doc was saved with changes, then back it up
	if ( [self createDatedBackup] 
				&& ![self isTransientDocument]
				&& ![self fileName]==nil
				&& [self needsDatedBackup] )
	{
		//	do backup
		BOOL success = [self backupDocument]; 
		if (success)
		{
			//	prevents multiple backups due to different notifications which occur at quit
			[self setCreateDatedBackup:NO];
		}
		else
		{
			//	prevents multiple backups due to different notifications which occur at quit
			[self setCreateDatedBackup:NO];
			[alertSheet setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Automatic backup of the document \\U201C%@\\U201D was not successful.", @"alert title: Automatic backup of the document (document name inserted at runtime) was not successful."), [self displayName]]];
			[alertSheet setInformativeText:NSLocalizedString(@"Try using the Finder to make a backup copy of this file. Deselect \\U2018Backup at close\\U2019 under \\U2018Get Info\\U2019 to disable automatic backup.", @"alert text: Try using the Finder to make a backup copy of this file. Deselect 'Backup at close' under 'Get Info' to disable automatic backup.")];
			[alertSheet runModal];            		
		}
	}
}

-(BOOL)backupDocument
{
	//	if file has been saved (changed) since opening, make a backup of this 'version' of the document
	BOOL success;
	//	using 10.1-3 style for NSDateFormatter
	int backupFileNumber = 1;
	//	create date string for date-stamp to add to backup filename
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] 
				initWithDateFormat:@"%1Y-%m-%d" allowNaturalLanguage:NO] autorelease];
	NSDate *today = [NSDate date];
	NSString *formattedDateString = [dateFormatter stringFromDate:today];
	//	FIXME: what if file has no extension?
	NSString *theExtension = [[self fileName] pathExtension];
	NSString *thePathMinusExtension = [[self fileName] stringByDeletingPathExtension];
	NSString *theBackupFilePath = [NSString stringWithFormat:@"%@%@%@%@%i%@%@", 
				thePathMinusExtension, @".", formattedDateString, @" ", backupFileNumber, @".", theExtension];
	NSURL *theBackupURL = [NSURL fileURLWithPath:theBackupFilePath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	//add sequential numbers to distinguish between backups done on the same date, so none are overwritten
	while ([fileManager fileExistsAtPath:theBackupFilePath] && backupFileNumber < 1000)
	{
		backupFileNumber = backupFileNumber + 1;
		theBackupFilePath = [NSString stringWithFormat:@"%@%@%@%@%i%@%@", 
					thePathMinusExtension, @".", formattedDateString, @" ", backupFileNumber, @".", theExtension];
		theBackupURL = [NSURL fileURLWithPath:theBackupFilePath];
	}
	NSString *theSource = [self fileName];
	if ([fileManager fileExistsAtPath:theSource])
	{
		//	duplicate the written-out representation and give it the backup filename
		success = [fileManager copyPath:theSource toPath:theBackupFilePath handler:nil];
	}
	//	unsuccessful backup is handled elsewhere
	return success;
}

// ******************* Autosave Methods ********************
- (void)beginAutosavingDocument
{
	int theAutosaveInterval = [doAutosaveTextField intValue] * 60; 
	//	if the interval passed by userDefaults was not valid (shouldn't happen, but you never know...)
	if (theAutosaveInterval <= 0 || theAutosaveInterval > 3600)
	{
		[self setDoAutosave:NO];
		[alertSheet setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Please input an Autosave interval.", @"alert title: Please input an Autosave interval.")]];
		[alertSheet setInformativeText:NSLocalizedString(@"At least 1 minute and no more than 60 minutes.", @"alert text: At least 1 minute and no more than 60 minutes. (alert title is: Please input an Autosave interval.)")];
		[alertSheet runModal];
		[doAutosaveButton setState:NSOffState];
		[doAutosaveTextField setIntValue:5];
		return;
	}
	[doAutosaveTextField setEnabled:NO];
	[doAutosaveStepper setEnabled:NO];
	[doAutosaveLabel setTextColor:[NSColor lightGrayColor]];
	//	autosaveTimer is declared in the header file
	if (!autosaveTimer)
	{
		autosaveTimer = [[NSTimer scheduledTimerWithTimeInterval:theAutosaveInterval target:self selector:@selector(autosaveDocument:) userInfo:nil repeats:YES] retain];
	}
}

- (void)autosaveDocument: (NSTimer *)theTimer
{
	/*
	Autosaves the document, with (Autosave) appended to fileName before the extension, at interval specified.
	Only writes out if changes exist since last autosave (via needsAutosave), irrespective of isDirty accessor. 
	Autosaved documents are never overwritten directly; there is no danger then of lossy docs being overwritten
	and information being lost, and there is no need to interrupt the user with warning dialogs. Also,
	this way, changes the user might not want to save in the original document are not saved without asking user.
	Note that subsequent autosaves overwrite this '(Autosaved)' file.
	*/
	
	//	docs that are transient
	if (isTransientDocument)
		return;
	//	if autosave is on (how we got here) and doc is edited (whether saved or not), do autosave
	if (![self fileName]==nil && [self needsAutosave]) {
		//	add '(Autosave)' to filename before extension and save to the same folder as the original file 
		//FIXME: what is there is no extension?
		NSString *theExtension = [[self fileName] pathExtension];
		NSString *thePathMinusExtension = [[self fileName] stringByDeletingPathExtension];
		NSString *autosaveFilenameSuffix = [NSString stringWithFormat:@"%@%@", @" ", NSLocalizedString(@"(Autosaved)", @"Suffix added to end of filename before extension indicating that file was autosaved.")];
		NSString *theAutosavePath = [NSString stringWithFormat:@"%@%@%@%@", thePathMinusExtension, autosaveFilenameSuffix, @".", theExtension];
		NSURL *theURL = [NSURL fileURLWithPath:theAutosavePath];
		NSError *theError = nil;
		[self writeToURL:theURL ofType:[self fileType] error:&theError];
		[self setNeedsAutosave:NO];
		
		//	error alert dialog
		if (!theError==nil) {
			//	turn autosave off so the problem does not repeat, then alert the user
			[autosaveTimer invalidate];
			[autosaveTimer release];
			autosaveTimer = NULL;
			[self setDoAutosave:NO];
			NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Autosave failed: %@", @"alert title: Autosave failed: (localized reason inserted here at runtime)."), [theError localizedDescription]];
			NSString *infoText = [NSString stringWithFormat:NSLocalizedString(@"A problem prevented the document \\U201C%@\\U201D from being autosaved. Autosave is now deactivated for this document so the problem does not repeat.", @"alert text: A problem prevented the document (document name inserted at runtime) from being autosaved. Autosave is now deactivated for this document so the problem does not repeat."), [theAutosavePath lastPathComponent]];
			NSBeginAlertSheet(title, NSLocalizedString(@"OK", @"OK"), nil, nil, [[self firstTextView] window], self, nil, nil, NULL, infoText, NULL);
		}
	}
}

-(IBAction)startAndStopAutosaveAction:(id)sender
{
	//	is autosaving, so stop autosave
	if (autosaveTimer)
	{
		[autosaveTimer invalidate];
		[autosaveTimer release];
		autosaveTimer = NULL;
		[self setDoAutosave:NO];
		[self setDocEdited:YES];
		[doAutosaveTextField setEnabled:YES];
		[doAutosaveStepper setEnabled:YES];
		[doAutosaveLabel setTextColor:[NSColor blackColor]];
	}
	//	start autosaving
	else
	{
		[self setDoAutosave:YES];
		[self setDocEdited:YES];
		[self beginAutosavingDocument];
	}
}

#pragma mark -
#pragma mark ---- Save Panels and Methods ----

// ******************* Save Panels and Methods *******************

- (BOOL)prepareSavePanel:(NSSavePanel *)sp
{
	[sp setDelegate:self]; // we nil this out in panel:isValidFilename
	[sp setCanSelectHiddenExtension:YES];
   	[sp setExtensionHidden:YES]; 
	//for testing purposes
	//[sp setAllowsOtherFileTypes:NO];
	
	//	if a locked file was opened as Untitled, show original name here as a reminder
	if ([self originalFileName])
	{
		[sp setMessage:[NSString stringWithFormat:NSLocalizedString(@"Original file was named: \\U201C%@\\U201D", @"message in Save File sheet, informing user: Original file was named: (original document name is inserted at runtime)."), [[self originalFileName]lastPathComponent]]];
	}
	
	//below adds a help button to the save panel (next to the formats popup list) which opens help on file formats//
	
	id(theView) = [sp accessoryView]; //view containing the format popup list
	NSRect theRect = [theView frame]; //size of that view
	//make it bigger to fit added button
	[theView setFrame:NSMakeRect(theRect.origin.x, theRect.origin.y, theRect.size.width + 50, theRect.size.height)];
	[theView setNeedsDisplay:YES];
	//position where to inject the help button
	NSRect helpButtonRect = NSMakeRect(theRect.origin.x + theRect.size.width -50, theRect.origin.y , 25, 25);
	//create the help button programmatically
	NSButton *helpButton = [[[NSButton alloc] initWithFrame: helpButtonRect] autorelease];
	[helpButton setToolTip:NSLocalizedString(@"Help with file formats", @"tooltip: Help with file formats (for a button which opens the help page for file formats)")];
	NSButtonCell *helpButtonCell = [[[NSButtonCell alloc] init] autorelease];
	[helpButtonCell setTitle:@""];
	[helpButtonCell setBezelStyle:NSHelpButtonBezelStyle];
	[helpButtonCell setTarget:self];
	[helpButtonCell setAction:@selector(displayHelp:)];
	[helpButton setEnabled:YES];
	[helpButton setTag:0];
	[helpButton setCell: helpButtonCell];
	[theView addSubview: helpButton];	
		
	return YES;
}

//	check filename supplied by user in Save Panel and warn user if there is a problem or inconsistancy
- (BOOL)panel:(id)sender isValidFilename:(NSString *)filename
{
	//	Bean would crash if a person opened a new doc, typed something, tried to close the window, was then prompted to save the doc, then saved it > CRASH! I did not realize the delegate would be retained, so we nil it out here 1 Sept 07 JH
	[sender setDelegate:nil];
	NSTextView *theTextView = [self firstTextView]; 
	NSString *theExtension = [[filename pathExtension] uppercaseString];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *docName = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"firstLevelOpenQuote", nil), [self displayName], NSLocalizedString(@"firstLevelCloseQuote", nil)]; 

	//	alert user that the containing FOLDER is LOCKED
	NSDictionary *theFolderAttrs = [fm fileAttributesAtPath:[filename stringByDeletingLastPathComponent] traverseLink:YES];
	if ([[theFolderAttrs objectForKey:NSFileImmutable] boolValue] == YES) {
		NSString *theFolderName = [[filename stringByDeletingLastPathComponent]lastPathComponent];
		NSString *title = [NSString stringWithFormat:NSLocalizedString(@"The folder \\U201C%@\\U201D is locked.", @"alert title: The folder (folder name inserted at runtime) is locked. (alert called when a save cannot proceed)"), theFolderName];
		NSString *theInformativeString = NSLocalizedString(@"Documents cannot be saved in a locked folder. Choose another location.", @"alert text: Documents cannot be saved in a locked folder. Choose another location.");
		NSAlert *lockedFolderAlert = [NSAlert alertWithMessageText:title defaultButton:NSLocalizedString(@"OK", @"OK") alternateButton:nil otherButton:nil
				informativeTextWithFormat:theInformativeString];
		[lockedFolderAlert runModal];
		return NO;
	}
	
	//	alert user that the file is LOCKED
	NSDictionary *theFileAttrs = [fm fileAttributesAtPath:filename traverseLink:YES];
	if ([[theFileAttrs objectForKey:NSFileImmutable] boolValue] == YES)
	{
		NSString *title = [NSString stringWithFormat:NSLocalizedString(@"The file %@ is locked.", @"alert title: The file is locked. (alert called when a save cannot proceed)"), docName];
		NSString *infoText = NSLocalizedString(@"Locked files cannot be overwritten. Save the document with a new name to keep your changes.", @"alert text: Locked files cannot be overwritten. Save the document with a new name to keep your changes.");
		NSAlert *lockedFileAlert = [NSAlert alertWithMessageText:title defaultButton:NSLocalizedString(@"OK", @"OK") alternateButton:nil otherButton:nil
									   informativeTextWithFormat:infoText];
		[lockedFileAlert runModal];
		return NO;
	}	
	
	//	if there are graphics but a graphics-capable format was not chosen, offer 'recovery' choice
	if ([theTextView importsGraphics] && [theTextView isRichText])
	{
		//	show alert if extension is RTF, DOC, or XML, or plain text, because they don't save images
		if ([textStorage containsAttachments]
					//	kosher for images
					&& ![theExtension isEqualToString:@"RTFD"] 
					&& ![theExtension isEqualToString:@"BEAN"]
					&& ![theExtension isEqualToString:@"WEBARCHIVE"]
					//	plain text is special case, handled later 
					&& ![theExtension isEqualToString:@"TXT"]
					//	these do not handle images, so we show alert (BUG FIX 17 May 2007 BH)
					&& ([theExtension isEqualToString:@"RTF"] 
					|| [theExtension isEqualToString:@"DOC"] 
					|| [theExtension isEqualToString:@"XML"]) )
		{
			int choice;
			NSString *docTitle = [self displayName];
			NSString *title = [NSString stringWithFormat:NSLocalizedString(@"The document \\U201C%@\\U201D contains images, but the selected file format does not support saving images.", @"alert title: The document contains images, but the selected file format does not support saving images."), docTitle];
			NSString *theInformativeString = NSLocalizedString(@"Choose \\U2018Save As...\\U2019 to select another format, or choose \\U2018Save Anyway\\U2019 to save without images and attachments.", @"alert text (shown upon attempt to save document with images to non-image capable format): Choose 'Save As...' to select another format, or choose 'Save Anyway' to save without images and attachments. (translator: the translation of Save Anyway needs to match the translation given to the key 'button: Save Anyway')");
			choice = NSRunAlertPanel(title, 
									theInformativeString,
									NSLocalizedString(@"Save As...", @"button: Save As..."),
									NSLocalizedString(@"Save Anyway", @"button: Save Anyway"),
									NSLocalizedString(@"Cancel", @"button: Cancel"));
			//	1: means save was cancelled so user can pick another file format
			if (choice==NSAlertDefaultReturn)
			{ 
				return NO;
			}
			//	-1: means user wanted to continue with save operation and lose graphics
			else if (choice==NSAlertAlternateReturn)
			{ 
				//	allow deletion of images even if isEditable is NO when saving to another format
				if (![[self firstTextView] isEditable]) { [[self firstTextView] setEditable:YES]; }
				int theLoc = [theTextView selectedRange].location;
				[theTextView selectAll:nil];
				[theTextView cut:nil];
				[theTextView setImportsGraphics:NO];
				[theTextView paste:nil];
				if (theLoc < [textStorage length])
				{ 
					[theTextView setSelectedRange:NSMakeRange(theLoc,0)];
					[theTextView scrollRangeToVisible:NSMakeRange(theLoc,0)];
				}
				//	restore isEditable
				if ([self readOnlyDoc]) { [[self firstTextView] setEditable:NO]; }				
			} 
			//	0: means user wants to not save and to dismiss the save panel
			else if (choice==NSAlertOtherReturn)
			{
				[sender cancel:nil]; 
				return NO;
			}
		}
	}
		
	//	if there are text attributes, but plain text format was chosen, offer user an option to choose another format so info is not lost

	//	here we look for a) rich text and b) the absence of all of Beans formats, which means .TXT (you provide extension) format (BUG FIX 17 May 2007 BH)
	if ( ([theTextView isRichText]==1 && [theExtension isEqualToString:@"TXT"]) 
				|| ([theTextView isRichText]==1
				&& ![theExtension isEqualToString:@"BEAN"] 
				&& ![theExtension isEqualToString:@"RTFD"]
				&& ![theExtension isEqualToString:@"WEBARCHIVE"]
				&& ![theExtension isEqualToString:@"RTF"] 
				&& ![theExtension isEqualToString:@"DOC"]
				&& ![theExtension isEqualToString:@"XML"]) )
	{
		int choice;
		//	altered alert dialog text to be less alarming (7 May 2007)
		NSString *title = NSLocalizedString(@"Save as plain text?", @"alert title: Save as plain text?");
		NSString *infoString = NSLocalizedString(@"Saving as plain text will cause text formatting, images and document properties to be discarded. Choose \\U2018Save As...\\U2019 to select another format, or choose \\U2018Save Anyway\\U2019 to save as plain text.", @"alert text: Saving as plain text will cause text formatting, images and document properties to be discarded. Choose 'Save As...' to select another format, or choose 'Save Anyway' to save as plain text. (translator: the translation of Save Anyway needs to match the translation given to the key 'button: Save Anyway')");
		choice = NSRunAlertPanel(title, 
								 infoString,
								 NSLocalizedString(@"Save As...", @"button: Save As..."), 	// ellipses
								 NSLocalizedString(@"Save Anyway", @"button: Save Anyway"), 
								 NSLocalizedString(@"Cancel", @"button: Cancel"));
		//	1 means save was cancelled so user can pick another file format
		if (choice==NSAlertDefaultReturn)
		{ 
			return NO;
		}
		// -1 means allow deletion of images even if isEditable is NO when saving to another format
		else if (choice==NSAlertAlternateReturn)
		{ 
			if (![[self firstTextView] isEditable])	{ [[self firstTextView] setEditable:YES]; }				
			int theLoc = [theTextView selectedRange].location;
			[theTextView selectAll:nil];
			[theTextView cut:nil];
			[theTextView setImportsGraphics:NO];
			[theTextView setRichText:NO];
			[theTextView pasteAsPlainText:nil];
			[theTextView setAlignment:NSNaturalTextAlignment];
			if (theLoc < [textStorage length])
			{ 
				[theTextView setSelectedRange:NSMakeRange(theLoc,0)];
				[theTextView scrollRangeToVisible:NSMakeRange(theLoc,0)];
			}
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			//	retrieve the default font and size from user prefs; add to dictionary
			NSString *fontName = [defaults valueForKey:@"prefPlainTextFontName"];
			float fontSize = [[defaults valueForKey:@"prefPlainTextFontSize"] floatValue];
			//	create NSFont from name and size
			NSFont *aFont = [NSFont fontWithName:fontName size:fontSize];
			//	use system font on error (Lucida Grande, it's nice)
			if (aFont == nil) aFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
			//	apply font attribute to textview (for new documents)
			NSRange theRangeValue = NSMakeRange(0, [textStorage length]);
			[textStorage addAttribute:NSFontAttributeName value:aFont range:theRangeValue];
			[textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:theRangeValue];
			[textStorage removeAttribute:NSBackgroundColorAttributeName range:theRangeValue];
			[textStorage removeAttribute:NSShadowAttributeName range:theRangeValue];
			//	11 June 2007 BH gets rid of tables attributes, etc.
			[textStorage removeAttribute:NSParagraphStyleAttributeName range:theRangeValue]; 
			//	add 'plain text' font style to the typingAttributes
			NSDictionary *theAttributes = [[self firstTextView] typingAttributes];
			NSMutableDictionary *theTypingAttributes = [[theAttributes mutableCopy] autorelease];
			if (aFont) { [theTypingAttributes setObject:aFont forKey:NSFontAttributeName]; }
			[[self firstTextView] setTypingAttributes:theTypingAttributes];
			//	restore isEditable
			if ([self readOnlyDoc]) { [[self firstTextView] setEditable:NO]; }		
		}
		//	0 means user want to not save and to dismiss the save panel
		else if (choice==NSAlertOtherReturn)
		{
			[sender cancel:nil];
			return NO;
		}
	}
	//	adjust textView to accomodate potential filetype
	if ([theExtension isEqualToString:@"RTFD"]
				|| [theExtension isEqualToString:@"BEAN"]
				|| [theExtension isEqualToString:@"WEBARCHIVE"])
	{
		//	rich text, with graphics
		[[self firstTextView] setRichText:YES];
		[[self firstTextView]  setImportsGraphics:YES];
	} 
	else if ([theExtension isEqualToString:@"DOC"]
				|| [theExtension isEqualToString:@"XML"]
				|| [theExtension isEqualToString:@"RTF"])
	{
		//	rich text, no graphics
		[[self firstTextView]  setRichText:YES];
		[[self firstTextView]  setImportsGraphics:NO];
	}
	else if ([theExtension isEqualToString:@"TXT"]
				|| [theExtension isEqualToString:@"HTML"])
	{
		//	plain text, no graphics
		[[self firstTextView]  setRichText:NO];
		[[self firstTextView]  setImportsGraphics:NO];
	}
	return YES;
}

//	called by the 'Save' menu item and Autosave method
-(IBAction)saveTheDocument:(id)sender
{
	if ([self fileName]==nil)
	{
		//	if no filename, call Save As and save the file
		[self runModalSavePanelForSaveOperation:NSSaveAsOperation delegate:NULL didSaveSelector:nil contextInfo:NULL];
		if ([self originalFileName])
		{
			[self setOriginalFileName:nil];
		}
	}
	else
	{
		//	else, just save the file
		if ([self checkBeforeSaveWithContextInfo:nil isClosing:NO])
		{
			[self saveDocument:nil];
		}
	}
}

-(BOOL)checkBeforeSaveWithContextInfo:(void *)contextInfo isClosing:(BOOL)isClosing
{
	NSString *docName = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"firstLevelOpenQuote", nil), [self displayName], NSLocalizedString(@"firstLevelCloseQuote", nil)]; 
	
	if ([self isLossy] || [self isEditedExternally])
	{	
		//	alert that imported doc has changed
		NSString *title;
		NSString *infoText;
		if ([self isLossy] && ![self isEditedExternally])
		{ 
			//	changes were made to a doc that was imported lossy AND has been externally edited
			if ([[self fileType] isEqualToString:DOCDoc])
			{
				title = [NSString stringWithFormat:NSLocalizedString(@"Overwriting the original %@ file may cause images and page/paragraph formatting to be lost. Overwrite?", @"alert title: Overwriting the original (filename extension inserted at runtime) file may cause images and page/paragraph formatting to be lost. Overwrite?"), [self fileType]];
				infoText = NSLocalizedString(@"You can save as another document to preserve the original.", @"alert text: You can save as another document to preserve the original.");
			//Bean cannot tell the difference between an .xml file it creates, and an original WordML file, so it warns each time about overwriting
			//FIXME: is there a better solution? Some internal .xml flag we can look for (such as 'enbedded attachments')? 31 May 2007 BH
			}
			else if ([[self fileType] isEqualToString:XMLDoc])
			{
				title = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to overwrite the original %@ file?", @"alert title (shown when saving to XML file format, since Bean can't tell native Bean XML from MS XML): Are you sure you want to overwrite the original (filename extension inserted at runtime) file?"), [self fileType]];
				infoText = NSLocalizedString(@"You can save as another document to preserve the original.", @"alert text: You can save as another document to preserve the original.");
			}
			else
			{
				title = [NSString stringWithFormat:NSLocalizedString(@"Overwriting the original %@ file may cause images to be lost. Overwrite?", @"alert title (when overwriting imported documents): Overwriting the original (file extension name inserted at runtime) file may cause images to be lost. Overwrite?"), [self fileType]];
				infoText = NSLocalizedString(@"You can save as another document to preserve the original.", @"alert text: You can save as another document to preserve the original.");
			}
		}
		else if (![self isLossy] && [self isEditedExternally])
		{
			title = [NSString stringWithFormat:NSLocalizedString(@"The file for the document %@ has been changed by another application since you opened or saved it. Overwrite?", @"alert title: The file for the document (document name inserted at runtime--no trailing space)has been changed by another application since you opened or saved it. Overwrite?"), docName];
			infoText = NSLocalizedString(@"You can save as another document to make sure no changes are lost.", @"text alert (shown when user tries to save a file that has been externally edited in another program): You can save as another document to make sure no changes are lost.");
		}
		else
		{
			title = [NSString stringWithFormat:NSLocalizedString(@"The document %@ was imported, and also has been changed by another application since you opened or saved it. Overwrite?", @"alert title: The document (document name inserted at runtime--no trailing space)was imported, and also has been changed by another application since you opened or saved it. Overwrite?"), docName];
			infoText = [NSString stringWithFormat:NSLocalizedString(@"Overwriting the original %@ file might cause images, formatting, and recent changes to be lost.", @"alert text: Overwriting the original (file extension name inserted at runtime) file might cause images, formatting, and recent changes to be lost."), [self fileType]];
		}
		//	!flag means doc is not closing, so we pass nil as contextInfo since no callback on canCloseWithDelegeate is needed
		if (!isClosing) { contextInfo = nil; }
		
		NSBeginAlertSheet(title, NSLocalizedString(@"Overwrite", @"button: Overwrite"), NSLocalizedString(@"Save As...", @"button: Save As..."), NSLocalizedString(@"Cancel", @"button: Cancel"), docWindow, self, NULL, 
						  @selector(lossyDocAlertDidEnd:returnCode:contextInfo:), contextInfo, infoText); 
		/*
		Returning 'no' means saving the doc is our responsibility now (because it failed the checkBeforeSave test).
				Problems will have to be presented post-attempted-save by willPresentErrors.
				Also, if isClosing is flagged, callback to canCloseWithDelegate SEL is now our job. 
		*/
		return NO;
	}
	
	//	if file or file package (=folder) is LOCKED, alert user and cancel any close command
	NSFileManager *fm = [NSFileManager defaultManager];
	NSDictionary *theFileAttrs = [fm fileAttributesAtPath:[self fileName] traverseLink:YES];
	if ([[theFileAttrs objectForKey:NSFileImmutable] boolValue] == YES)
	{
		NSString *title = [NSString stringWithFormat:NSLocalizedString(@"The document %@ could not be saved because the file is locked.", @"alert title: The document (document name inserted at runtime - notice no space between %@ and 'could') could not be saved because the file is locked."), docName];
		NSString *theInformativeString = NSLocalizedString(@"To keep your changes, save as a different document.", @"alert text: To keep your changes, save as a different document.");
		if (!isClosing)
		contextInfo = nil;
		NSBeginCriticalAlertSheet(title, NSLocalizedString(@"Save As...", @"button: Save As..."), NSLocalizedString(@"Unlock and Save", @"button: Unlock and Save"), NSLocalizedString(@"Cancel", @"button: Cancel"), docWindow, self, NULL, 
						  @selector(lockedDocAlertDidEnd:returnCode:contextInfo:), contextInfo, theInformativeString); 
		return NO;
	}
	return YES;
}

- (void)lossyDocAlertDidEnd:(NSAlert *)alert 
				 returnCode:(int)returnCode
				contextInfo:(void *)callBackInfo;
{
#define lossyOverwrite	NSAlertDefaultReturn
#define lossySaveAs		NSAlertAlternateReturn
#define lossyCancel		NSAlertOtherReturn

	//	each case has two possibilities, depending on whether we need to send a message to the canClose... delegate (ie, if callBackInfo exists) or not
	SelectorContextInfo *selectorContextInfo = callBackInfo;
	switch (returnCode)
	{
		case lossyOverwrite:
		{
			//	needs callback to canCloseWithDelegate, which passed callBackInfo
			if (callBackInfo)
			{
				//	success on save = can close; failure = cannot close
				[self saveDocumentWithDelegate:selectorContextInfo->delegate
							didSaveSelector:selectorContextInfo->shouldCloseSelector
							contextInfo:selectorContextInfo->contextInfo];
				//	for some reason, if save fails here [self isDocumentEdited] subsequently returns no and cmd-Q does not ask to save changes
				if (selectorContextInfo->shouldCloseSelector)
				{	
					[self setDocEdited:YES];
				}
			}
			else
			{
				[self saveDocument:nil];
			}
			break;
		}
		case lossyCancel:
		{
			//	=go back to editing, so send NO to canCloseWithDelegate callback, which passed callBackInfo
			if (callBackInfo)
			{ 
				//	send 'NO' callback to selector (= can close without save)
				void (*meth)(id, SEL, MyDocument *, BOOL, void*);
				meth = (void (*)(id, SEL, MyDocument *, BOOL, void*))[selectorContextInfo->delegate methodForSelector:selectorContextInfo->shouldCloseSelector];
				if (meth)
				{
					meth(selectorContextInfo->delegate, selectorContextInfo->shouldCloseSelector, self, NO, selectorContextInfo->contextInfo);
				}
			}
			//	=cancel with no callback needed (since check as not called from canCloseWithDelegate)
			else
			{
				//	nothing to do but return to editing
			}
			break;
		}	
		case lossySaveAs:
		{
			//	save old filename, use it to remind user of original name (via prepareSavePanel)
			if ([self fileName])
			{
				[self setOriginalFileName:[self fileName]];
			}
			[self setFileName:nil];
			[self setLossy:NO];
			[self setFileModDate:nil];
			//	sends callback to canCloseWithDelegate (success on save = can close; failure = cannot close)
			if (callBackInfo)
			{
				[self saveDocumentWithDelegate:selectorContextInfo->delegate
							didSaveSelector:selectorContextInfo->shouldCloseSelector 
							contextInfo:selectorContextInfo->contextInfo];
			}
			else
			{
				[self runModalSavePanelForSaveOperation:NSSaveAsOperation delegate:self didSaveSelector:@selector(document:didSaveAfterAlert:contextInfo:) contextInfo:nil];
			}
			[self setOriginalFileName:nil];
			break;
		}
	}
	//	free memory
	if (selectorContextInfo)
	{	
		free(selectorContextInfo);
	}
}

- (void)lockedDocAlertDidEnd:(NSAlert *)alert 
				 returnCode:(int)returnCode
				contextInfo:(void *)callBackInfo;
{

#define lockedSaveAs		NSAlertDefaultReturn
#define lockedUnlockAndSave	NSAlertAlternateReturn
#define lockedCancel		NSAlertOtherReturn

	//each case has two possibilities, depending on whether we need to send a message to the canClose... delegate (ie, if callBackInfo exists) or not
	SelectorContextInfo *selectorContextInfo = callBackInfo;
	switch (returnCode)
	{
		case lockedCancel:
		{
			//	=go back to editing, so send NO to canCloseWithDelegate callback, which passed callBackInfo
			if (callBackInfo)
			{ 
				//	send 'NO' callback to selector (= can close without save)
				void (*meth)(id, SEL, MyDocument *, BOOL, void*);
				meth = (void (*)(id, SEL, MyDocument *, BOOL, void*))[selectorContextInfo->delegate methodForSelector:selectorContextInfo->shouldCloseSelector];
				if (meth)
				{
					meth(selectorContextInfo->delegate, selectorContextInfo->shouldCloseSelector, self, NO, selectorContextInfo->contextInfo);
				}
			}
			break;
		}	
		case lockedSaveAs:
		{
			//	save old filename, use it to remind user of original name (via prepareSavePanel)
			if ([self fileName])
			{
				[self setOriginalFileName:[self fileName]];
			}
			[self setFileName:nil];
			[self setLossy:NO];
			[self setFileModDate:nil];
			//	sends callback to canCloseWithDelegate (success on save = can close; failure = cannot close)
			if (callBackInfo)
			{
				//	send 'NO' callback to selector (= can close without save)
				void (*meth)(id, SEL, MyDocument *, BOOL, void*);
				meth = (void (*)(id, SEL, MyDocument *, BOOL, void*))[selectorContextInfo->delegate methodForSelector:selectorContextInfo->shouldCloseSelector];
				if (meth)
				{
					meth(selectorContextInfo->delegate, selectorContextInfo->shouldCloseSelector, self, NO, selectorContextInfo->contextInfo);
				}
				[self runModalSavePanelForSaveOperation:NSSaveAsOperation delegate:self didSaveSelector:@selector(document:didSaveAfterAlert:contextInfo:) contextInfo:nil];
			}
			else
			{
				[self runModalSavePanelForSaveOperation:NSSaveAsOperation delegate:self didSaveSelector:@selector(document:didSaveAfterAlert:contextInfo:) contextInfo:nil];
			}
			[self setOriginalFileName:nil];
			break;
		}
		case lockedUnlockAndSave:
		{
			//	unlock file
			NSDictionary *unlockFileDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:NO] forKey:NSFileImmutable];
			if ([self fileName]) [[NSFileManager defaultManager] changeFileAttributes:unlockFileDict atPath:[self fileName]];
			[self setLossy:NO];
			//	sends callback to canCloseWithDelegate (success on save = can close; failure = cannot close)
			if (callBackInfo)
			{
				[self saveDocumentWithDelegate:selectorContextInfo->delegate
							didSaveSelector:selectorContextInfo->shouldCloseSelector 
							contextInfo:selectorContextInfo->contextInfo];
			}
			else
			{
				[self saveDocument:nil];
			}
		}
	}
	//	free memory
	if (selectorContextInfo)
		free(selectorContextInfo);
}

// ******************* Revert To Saved Method *******************
- (IBAction)revertDocumentToSaved:(id)sender
{
	//	ask if user wants to revert to the original document
	int choice = NSAlertDefaultReturn;
	NSString *title = NSLocalizedString(@"Revert document to saved version?", @"alert title: Revert document to saved version?");
	NSString *infoString = NSLocalizedString(@"You will lose unsaved changes.", @"alert text: You will lose unsaved changes.");
	choice = NSRunAlertPanel(	title,
							 infoString,
							 NSLocalizedString(@"Revert", @"button: Revert (translator: it means, revert document to previously saved version)"),
							 @"", 
							 NSLocalizedString(@"Don\\U2019t Revert", @"button: Don't Revert (to previously saved version)")	);
	 // 1 continue
	if (choice==NSAlertDefaultReturn)
	{
		//do nothing
	}
	//don't revert
	else if (choice==NSAlertOtherReturn)
	{
		return;
	}
	NSError *theError = nil;
	[self readFromURL:[self fileURL] ofType:[self fileType] error:&theError];
	if (loadedText != nil)
	{
		[[layoutManager textStorage] replaceCharactersInRange:NSMakeRange(0,[[layoutManager textStorage] length]) 
				withAttributedString:loadedText];
		[loadedText release];
		loadedText = nil;
	}
	[self setDocEdited:NO];
	[[self undoManager] removeAllActions];
	if ([[self currentFileType] isEqualToString:TXTDoc] 
				|| [[self currentFileType] isEqualToString:TXTwExtDoc])
	{
		[self plainTextSettings];
	}
}

#pragma mark -
#pragma mark ---- Inspector Methods ----

// ******************* Update Inspector *******************

//	Called upon NSApplicationDidUpdateNotification or, indirectly, by NSWindowDidBecomeMainNotification through forceUpdateInspectorController

//	Causes update of settings in Inspector to reflect text selection or typing attributes
- (void) updateInspectorController:(NSNotification *)notification
{
	//	pointers
	NSTextView			*textView = [self firstTextView];
	NSDictionary		*theAttributes;
	InspectorController	*ic = [InspectorController sharedInspectorController];

	//	update inspector in case documents switched focus and one was American while the other was metric
	[ic setPointsPerUnitAccessor:[self pointsPerUnitAccessor]];

	//	if NOT plain text, get the attributes
	
	if (![[self currentFileType] isEqualToString:TXTDoc] 
				&& ![[self currentFileType] isEqualToString:HTMLDoc] 
				&& ![[self currentFileType] isEqualToString:TXTwExtDoc])
	{

		//	get insertion point attributes (typingAttributes), which are 'potential' attributes for text at insertion point
		if ([textView selectedRange].length==0)
		{
			theAttributes = [textView typingAttributes];
		}
		//	get the attributes of the first character of the first selection
		else
		{
			theAttributes = [textStorage attributesAtIndex:[textView selectedRange].location effectiveRange:NULL];
		}
	} 
	
	//if plain text, avoid nil attributes by using addAttribute without actually changing anything
	
	else
	{
		if ([textStorage length]==0)
		{
			theAttributes = [textView typingAttributes];
		}
		else
		{
			int attributeLocation = nil;
			int textLength = [textStorage length];
			//	prevent out-of-bounds exception for attribute:atIndex: below
			if ([textView selectedRange].location==textLength && textLength > 0)
			{
				attributeLocation = [textView selectedRange].location - 1;
			}
			else
			{
				attributeLocation = [textView selectedRange].location;				
			}
			theAttributes = [textStorage attributesAtIndex:attributeLocation effectiveRange:NULL];
			attributeLocation = nil;
			textLength = nil;
		}
	}
	
	//	if there is a sheet displayed or something like that, we disable the inspector controls, since they wouldn't work anyway
		
	if (![[NSApp keyWindow] isEqualTo:[theScrollView window]] 
				&& ![[NSApp keyWindow] isEqualTo:[[InspectorController sharedInspectorController] window]] 
				&& ([[textView window] isMainWindow]) )
	{
		theAttributes = nil;
	}
	
	//	un-enable inspector controls (which would otherwise still appear functional) if there is no text
	
	if ([textStorage length] < 1) { theAttributes = nil; }
	
	//if attributes have changed since previous call or 'force flag' is up, update inspector
	
	if ((![theAttributes isEqual:[self oldAttributes]] 
				&& theAttributes !=[self oldAttributes]) 
				|| ![self shouldForceInspectorUpdate]==0)
	{
		float rightMarginToIndentFrom = [[self printInfo] paperSize].width - [[self printInfo] leftMargin] - [[self printInfo] rightMargin];
		[ic updateInspector:theAttributes theRightMarginValueToIndentFrom:rightMarginToIndentFrom isReadOnly:[self readOnlyDoc]];
	}
	
	//	bookkeeping
	[self setShouldForceInspectorUpdate:NO];
	[self setOldAttributes:theAttributes];

	//	used by following two blocks of code
	NSEvent *theEvent = [NSApp currentEvent];
	
	//	18 June 2007 so only this window responds!
	if ([theEvent window]==[textView window])
	{
		//	watches for mouse quadruple-click, and if so selects all text (=select all)
		if ([theEvent type]==NSLeftMouseUp && [theEvent clickCount]==5)
		{
			//	make sure it does not loop, that is, notification changes selection, which calls notification, etc.
			//	this: ([theEvent window]==[textView window]) makes sure input is from textView, not inspector, etc.  
			if ([textView selectedRange].length < [textStorage length] && ![textView selectedRange].length==0) \
			{
				[textView setSelectedRange:NSMakeRange(0,[textStorage length])];
			}
		}
		//	if not using the modifier keys (to scroll, etc.), we try to center the caret vertically in the window or page
		if ([self shouldConstrainScroll])
		{
			//test code - determine the unicode character(s) supplied by the keyDown event event
			/*
			if ([theEvent type]==NSKeyDown)
			{
				NSString *chars = [theEvent characters];
				int i, l = [chars length];
				for(i=0; i<l; i++)
				{
					unichar c = [chars characterAtIndex:i];
					//NSLog([NSString stringWithFormat:@"unichar: %i", c]);
				}
			}
			*/

			if ([theEvent type]==NSKeyDown
						&& !([theEvent modifierFlags] & NSFunctionKeyMask) 
						&& !([theEvent modifierFlags] & NSControlKeyMask) 
						&& !([theEvent modifierFlags] & NSAlternateKeyMask) 
						&& !([theEvent modifierFlags] & NSCommandKeyMask))
			{
				[self constrainScrollWithForceFlag:NO];
			}
		}
	}
	//	NOTE: I don't have a localized string I can use for placing 'READ ONLY' in the word count label
	//	so, sadly, I'm reverting to the 'silent fail' technic since NSBeep is really annoying
	/*
	//	beep if read only (not editable) upon keypress instead of silently fail to insert text
	//	bug fix: even non read-only docs were beeping, so added extra tests
	//	note: tried to do an alert message here, but got a SIGSEG violation (?)
	if ([self readOnlyDoc] && [[textView window] isMainWindow] && [[NSApp keyWindow] isEqualTo:[theScrollView window]])
	{
		if ([theEvent type]==NSKeyDown
			&& !([theEvent modifierFlags] & NSFunctionKeyMask) 
			&& !([theEvent modifierFlags] & NSControlKeyMask) 
			&& !([theEvent modifierFlags] & NSAlternateKeyMask) 
			&& !([theEvent modifierFlags] & NSCommandKeyMask))
		{
			NSBeep();
			NSSpeechSynthesizer *synth = [[NSSpeechSynthesizer alloc] init];
			[synth startSpeakingString:[NSString stringWithFormat:@"The document %@ is Read Only", [self displayName]]];
			[synth release];
		}		
	}
	*/
}


//	called upon NSWindowDidBecomeMainNotification to update inspector
- (void) forceUpdateInspectorController:(NSNotification *)notification
{
	NSTextView *textView = [self firstTextView];
	//	check if really isMainWindow (it's necessary)
	if (![[textView window] isMainWindow]) { return; }
	//	if so force inspector to update even if attr's didn't change
	[self setShouldForceInspectorUpdate:YES];
	[self updateInspectorController:nil];
	//	un-enable these buttons when window focus is lost
	[pageUpButton setEnabled:YES];
	[pageDownButton setEnabled:YES];
	
}

// ******************* Show Inspector Panel *******************

//	toggle inspector window in and out
- (IBAction)showInspectorPanelAction:(id)sender
{
	if ([[[InspectorController sharedInspectorController] window ] isVisible]) {
		[[[InspectorController sharedInspectorController] window ] orderOut:sender];
	}
	else
	{
		//	show inspector panel 
		[[InspectorController sharedInspectorController] showWindow:sender];
		[[[InspectorController sharedInspectorController] window ] orderFront:sender];
		//	causes inspector to update at the first change
		[self setShouldForceInspectorUpdate:YES];
	}
}

// ******************* Inspector Panel Actions  *******************

//	controls on the 'Inspector' adjust ruler (NSParagraphStyle) attributes and kerning
//	note: menu items Format > Line spacing > Single Space, etc. now use this method, so it's not exclusively for the Inspector anymore, despite the name!
- (IBAction)inspectorSpacingAction:(id)sender
{
	NSTextView *textView = [self firstTextView];
	NSNumber *theValue = nil;
	
	//	can't take floatValue of menuItem (which just triggers an action) so test for menuItem to avoid bad selector 
	if ([sender tag] < 20)
	{
		theValue = [NSNumber numberWithFloat:[[sender cell] floatValue]];
	}
	
	//	KERNING is a character attribute (NSKernAttributeName); we handle it separately from paragraph attribtutes below
	
	//tag = 11 belongs to 'default' kerning button
	if ([sender tag]==0 || [sender tag]==11)
	{
		NSEnumerator *e = [[textView selectedRanges] objectEnumerator];
		NSValue *theRangeValue;
		//	for selected ranges...
		while (theRangeValue = [e nextObject])
		{
			//tag=11 means 'default' button was pressed - set kerning attribute to 0.0 (= 100% on slider)
			if ([sender tag]==11) 
			{
				theValue = [NSNumber numberWithInt:0];
			}
			//setup undo
			[textView shouldChangeTextInRange:[theRangeValue rangeValue] replacementString:nil];
			//bracket for efficiency
			[textStorage beginEditing];
			if ([theValue floatValue] > 0)
			{
				theValue = [NSNumber numberWithFloat:[theValue floatValue]];
			}
			else if ([theValue floatValue] < 0)
			{
				theValue = [NSNumber numberWithFloat:[theValue floatValue] * .5];
			}
			//else, 0
			else
			{  
				theValue = [NSNumber numberWithInt:[theValue intValue]];
			}
			//	adjust text KERNING based on value from slider
			[textStorage addAttribute:NSKernAttributeName value:theValue range:[theRangeValue rangeValue]];
			//	also set the typing attributes, in case no text yet, or end of string text
			NSDictionary *theAttributes = [[self firstTextView] typingAttributes];
			NSMutableDictionary *theTypingAttributes = [[theAttributes mutableCopy] autorelease];
			[theTypingAttributes setObject:theValue forKey:NSKernAttributeName];
			[[self firstTextView] setTypingAttributes:theTypingAttributes];
			//	bracket for efficiency
			[textStorage endEditing];
			//	end undo
			[textView didChangeText];
			//	name undo for menu
			[[self undoManager] setActionName:NSLocalizedString(@"Character Spacing", @"undo action: (change) Character Spacing")];
		}
	}
	
	//	PARAGRAPH (RULER) ATTRIBUTES are all handled here
	
	else if ([sender tag] < 30)
	{
		//	pointers n things
		unsigned paragraphNumber;
		//	an array of NSRanges containing applicable (possibly grouped) whole paragraph boundaries
	    NSArray *theRangesForUserParagraphAttributeChange = [textView rangesForUserParagraphAttributeChange];
		//	a range containing one or more paragraphs
		NSRange theCurrentRange;
		//	a range containing the paragraph of interest 
		NSRange theCurrentParagraphRange;
		//	menuItems have the value hard-coded (as opposed to Inspector controls), so we test for menuItems here to avoid 'bad selector' (menuItems have a tag of > 19)
		if ([sender tag] < 20) theValue = [NSNumber numberWithFloat:[[sender cell] floatValue]];		
		//	tag==12 mean default button for line spacing was pressed, set to 0.0
		if ([sender tag]==12)
			theValue = [NSNumber numberWithInt:0];
		//	figure effected range for undo
		int undoRangeIndex = [textView rangeForUserParagraphAttributeChange].location;
		int undoRangeLength = [[theRangesForUserParagraphAttributeChange 
				objectAtIndex:([theRangesForUserParagraphAttributeChange count] - 1)] rangeValue].location
				+ [[theRangesForUserParagraphAttributeChange
				objectAtIndex:([theRangesForUserParagraphAttributeChange count] - 1)] rangeValue].length - undoRangeIndex;
		//	start undo setup
		if ([textView shouldChangeTextInRange:NSMakeRange(undoRangeIndex,undoRangeLength) replacementString:nil])
		{
			//iterate through ranges of paragraph groupings
			for (paragraphNumber = 0; paragraphNumber < [theRangesForUserParagraphAttributeChange count]; paragraphNumber++)
			{
				//set range for first (or only) paragraph; index is needed to locate paragraph; length is not important
				//note: function rangesForUserPargraphAttributeChange returns NSValues (objects), so we use rangeValue to get NSRange value
				theCurrentParagraphRange = [[theRangesForUserParagraphAttributeChange objectAtIndex:paragraphNumber] rangeValue];
				theCurrentRange = [[theRangesForUserParagraphAttributeChange objectAtIndex:paragraphNumber] rangeValue];
				//now, step thru theCurrentRange paragraph by paragraph
				[textStorage beginEditing]; //bracket for efficiency
				while (theCurrentParagraphRange.location < (theCurrentRange.location + theCurrentRange.length))
				{
					//get the actual paragraph range including length
					theCurrentParagraphRange = [[textStorage string] paragraphRangeForRange:NSMakeRange(theCurrentParagraphRange.location, 1)];
					//BH: don't really understand the next two lines, but it works in this order. Why wouldn't you allocate it, THEN set an attribute?
					NSMutableParagraphStyle *theParagraphStyle = [textStorage attribute:NSParagraphStyleAttributeName atIndex:theCurrentParagraphRange.location effectiveRange:NULL];
					if (theParagraphStyle==nil)
					{
						theParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
					}
					else
					{
						theParagraphStyle = [[theParagraphStyle mutableCopyWithZone:[textView zone]]autorelease];
					}
					//pointsPerUnit is used for paragraph indents (inches/cms > points)
					float pointsPerUnit;
					pointsPerUnit = [self pointsPerUnitAccessor];
					//change the attribute associated with the inspector control
					if ([sender tag]==1 || [sender tag]==12)
					{
						//	if line spacing, set setMinimumLineSpacing to 0.0 to allow spacing < default minimum (often = 1.5)
						[theParagraphStyle setMinimumLineHeight:0];
						//default line spacing button has tag=12; pulls default from user prefs 13 Aug 2007
						if ([sender tag]==12)
						{
							NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
							switch ([defaults integerForKey:@"prefDefaultLineSpacing"]) //selectedTag binding
							{
								case 0: //single space
									theValue = [NSNumber numberWithFloat:1.0];
									//[theParagraphStyle setLineHeightMultiple:1.0];
									break;
								case 2: //double space
									theValue = [NSNumber numberWithFloat:2.0];
									//[theParagraphStyle setLineHeightMultiple:2.0];
									break;
								default: //1.5 space
									theValue = [NSNumber numberWithFloat:1.5];
									//[theParagraphStyle setLineHeightMultiple:1.5];
									break;
							}
						}
						[theParagraphStyle setLineHeightMultiple:([theValue floatValue])]; 
					} else if ([sender tag]==2) {
						[theParagraphStyle setLineSpacing:([theValue floatValue])];
					} else if ([sender tag]==3) {
						[theParagraphStyle setParagraphSpacingBefore:([theValue floatValue])];
					} else if ([sender tag]==4) {
						[theParagraphStyle setParagraphSpacing:([theValue floatValue])];
					} else if ([sender tag]==5) {
						[theParagraphStyle setFirstLineHeadIndent:([theValue floatValue] * pointsPerUnit)];
					} else if ([sender tag]==6) {
						[theParagraphStyle setHeadIndent:([theValue floatValue] * pointsPerUnit)];
					} else if ([sender tag]==7) {
						float rightMarginToIndentFrom = [[self printInfo] paperSize].width - [[self printInfo] leftMargin] - [[self printInfo] rightMargin];
						[theParagraphStyle setTailIndent:(rightMarginToIndentFrom - ([theValue floatValue] * pointsPerUnit))];
					} else if ([sender tag]==8) {
						[theParagraphStyle setMinimumLineHeight:([theValue floatValue] * pointsPerUnit)];
					} else if ([sender tag]==9) {
						[theParagraphStyle setMaximumLineHeight:([theValue floatValue] * pointsPerUnit)];
					} else if ([sender tag]==10) {
						[theParagraphStyle setMaximumLineHeight:0.0];
						[theParagraphStyle setMinimumLineHeight:0.0];
					} else if ([sender tag]==20) { //line spacing menuItem actions
						[theParagraphStyle setLineHeightMultiple:1.0];
					} else if ([sender tag]==21) {
						[theParagraphStyle setLineHeightMultiple:1.5];
					} else if ([sender tag]==22) {
						[theParagraphStyle setLineHeightMultiple:2.0];
					}
					//	add the attributes to the current paragraph
					[textStorage addAttribute:NSParagraphStyleAttributeName value:theParagraphStyle range:theCurrentParagraphRange];
					//	make index (=location) the first letter of the next paragraph
					theCurrentParagraphRange = NSMakeRange((theCurrentParagraphRange.location + theCurrentParagraphRange.length),1);
				}
				//	close bracket
				[textStorage endEditing]; 
				//	end undo setup
				[textView didChangeText];
				//	name undo action, based on tag of control
				if ([sender tag]==1 || [sender tag]==12 || [sender tag]==10 || [sender tag]==20 
							|| [sender tag]==21 || [sender tag]==22 ) {
					[[self undoManager] setActionName:NSLocalizedString(@"Line Spacing", @"undo action: Line Spacing")];
				} else if ([sender tag]==2) {
					[[self undoManager] setActionName:NSLocalizedString(@"Inter-line Spacing", @"undo action: Inter-line Spacing")];
				} else if ([sender tag]==3) {
					[[self undoManager] setActionName:NSLocalizedString(@"Before Paragraph Spacing", @"undo action: Before Paragraph Spacing")];
				} else if ([sender tag]==4) {
					[[self undoManager] setActionName:NSLocalizedString(@"Paragraph Spacing", @"undo action: Paragraph Spacing")];
				} else if ([sender tag]==5 || [sender tag]==6 || [sender tag]==7) {
					[[self undoManager] setActionName:NSLocalizedString(@"Indent", @"undo action: Indent")];
				} else if ([sender tag]==8) {
					[[self undoManager] setActionName:NSLocalizedString(@"Minimum Line Spacing", @"undo action: Minimum Line Spacing")];
				} else if ([sender tag]==9) {
					[[self undoManager] setActionName:NSLocalizedString(@"Maximum Line Spacing", @"undo action: Maximum Line Spacing")];
				}	
			}
		}
	}
	//	HIGHLIGHTING is a character attribute (NSBackgroundAttributeName); we handle it separately from paragraph attribtutes
	
	//tag = 30 to 39 for highlighting and remove highlighting
	else if ([sender tag] > 29 && [sender tag] < 40) 
	{ 
		NSEnumerator *e = [[textView selectedRanges] objectEnumerator];
		NSColor *theColor = nil;
		NSValue *theRangeValue;
		//	for selected ranges...
		while (theRangeValue = [e nextObject])
		{
			//setup undo
			[textView shouldChangeTextInRange:[theRangeValue rangeValue] replacementString:nil];
			//bracket for efficiency
			[textStorage beginEditing];
			switch ([sender tag])
			{
			case 30: //remove background highlight color
				//nothing to do here
				break;
			case 31: //yellow
				theColor = [NSColor yellowColor];
				break;
			case 32: //orange
				theColor = [NSColor colorWithCalibratedRed:0.95 green:0.61 blue:0.13 alpha:1.0];
				break;
			case 33: //pink
				theColor = [NSColor colorWithCalibratedRed:0.92 green:0.58 blue:0.81 alpha:1.0];
				break;
			case 34: //blue
				theColor = [NSColor colorWithCalibratedRed:0.59 green:0.83 blue:0.95 alpha:1.0];
				break;
			case 35: //green
				theColor = [NSColor greenColor];
				break;
			}
			if ([sender tag]==30)
			{
				//	remove text HIGHLIGHTING
				[textStorage removeAttribute:NSBackgroundColorAttributeName range:[theRangeValue rangeValue]];
			}
			else
			{
				//	adjust text HIGHLIGHTING based on tag of menuItem
				[textStorage addAttribute:NSBackgroundColorAttributeName value:theColor range:[theRangeValue rangeValue]];
			}
			if ([sender tag] > 30)
			{
				//	also set the typing attributes, in case no text yet, or end of string text
				NSDictionary *theAttributes = [[self firstTextView] typingAttributes];
				NSMutableDictionary *theTypingAttributes = [[theAttributes mutableCopy] autorelease];
				[theTypingAttributes setObject:theColor forKey:NSBackgroundColorAttributeName];
				[[self firstTextView] setTypingAttributes:theTypingAttributes];
			}
			//	bracket for efficiency
			[textStorage endEditing];
			//	end undo
			[textView didChangeText];
			//	name undo for menu
			if ([sender tag] > 30)	{ [[self undoManager] setActionName:NSLocalizedString(@"Highlighting", @"undo action: Highlighting")]; } 
			else { [[self undoManager] setActionName:NSLocalizedString(@"Remove Highlighting", @"undo action: Remove highlighting")]; }
			theColor = nil;
		}
	}
}

// ******************* fontStylesAction *******************

//	NSPopupmenu from inspector allows user to choose font family varients, thus allowing more options than the traditional italic, bold, underline buttons (or less, sometimes)
//	NOTE: all selected ranges are converted to the choosen font; user can combine 'select by...' with this action to change diverse types of ranges, e.g., headers, etc.

-(IBAction) fontStylesAction:(id)sender
{
	NSTextView *textView = [self firstTextView];
	//	get current selection's attributes
	NSDictionary *theAttributes;
	if ([textView selectedRange].length==0)
	{
		//	get insertion point attributes (typingAttributes), which are 'potential' attributes
		theAttributes = [textView typingAttributes];
	}
	else
	{
		//	get the attributes of the first character of the first selection
		theAttributes = [textStorage attributesAtIndex:[textView selectedRange].location effectiveRange:NULL];
	}
	//	get current font
	NSFont *theCurrentFont = [theAttributes objectForKey: NSFontAttributeName];
	//	get current font's point size
	float currentPointSize = [theCurrentFont pointSize];
	//	get newly selected font name from popup button 
	NSString *theFontStyleName = [[sender selectedItem] title];
	//	create new font with newly selected font name and old selection's font size
	NSFont *theNewFont = [NSFont fontWithName:theFontStyleName size:currentPointSize];
	//	go through selected ranges and make changes
	if ([[self firstTextView] isRichText])
	{
		//	change selected ranges to use the new NSFontAttributeName
		NSEnumerator *e = [[textView selectedRanges] objectEnumerator];
		NSValue *theRange;
		//	for selected ranges...
		while (theRange = [e nextObject])
		{
			//	setup undo
			[textView shouldChangeTextInRange:[theRange rangeValue] replacementString:nil];
			//	add selected NSFont attribute to range
			[textStorage addAttribute:NSFontAttributeName value:theNewFont range:[theRange rangeValue]];
			//	end undo
			[textView didChangeText];
			//	name undo for menu
			[[self undoManager] setActionName:NSLocalizedString(@"Font Style", @"undo action: Font Style")];
			//	also set the typing attributes, in case no text yet, or end of string text
			//	NOTE: Apple docs say to do this - see 'setTypingAttributes' entry
			NSDictionary *theAttributes = [textView typingAttributes];
			NSMutableDictionary *theTypingAttributes = [[theAttributes mutableCopy] autorelease];
			[theTypingAttributes setObject:theNewFont forKey:NSFontAttributeName];
			[textView setTypingAttributes:theTypingAttributes];
		}
	}
	//	plain text, so change all text
	else
	{
		//	setup undo
		[textView shouldChangeTextInRange:NSMakeRange(0, [textStorage length]) replacementString:nil];
		//	add selected NSFont attribute to range
		[textStorage addAttribute:NSFontAttributeName value:theNewFont range:NSMakeRange(0, [textStorage length])];
		//	end undo
		[textView didChangeText];
		//	name undo for menu
		[[self undoManager] setActionName:NSLocalizedString(@"Font Style", @"undo action: Font Style")];
		//	also set the typing attributes, in case no text yet, or end of string text
		//	NOTE: Apple docs say to do this - see 'setTypingAttributes' entry
		NSDictionary *theAttributes = [textView typingAttributes];
		NSMutableDictionary *theTypingAttributes = [[theAttributes mutableCopy] autorelease];
		[theTypingAttributes setObject:theNewFont forKey:NSFontAttributeName];
		[textView setTypingAttributes:theTypingAttributes];
	}
}

-(IBAction) orderFrontStylesPanelAction:(id)sender
{
	//	show styles panel, until we can come up with something better
	[[NSFontManager sharedFontManager] orderFrontStylesPanel:nil];
	[self setShouldForceInspectorUpdate:YES];
}

#pragma mark -
#pragma mark ---- Styles: Copy, Paste, Select ----

// ******************* Styles copy and paste methods *******************

/*
based on sender tag; copys or pastes or selects text based on attributes
todo: selection panel with checkboxes for different types of matching selections;
	merge the resulting arrays of selected ranges (use NSUnionRange?)
*/
-(IBAction) copyAndPasteFontOrRulerAction:(id)sender
{
	//COPY FONTNAME+FONTSIZE STYLE TO PASTEBOARD 
	if ([sender tag]==0) 
	{
		if ([[[[self layoutManager] textStorage] string] length] > 0)
			[[self firstTextView] copyFont:nil];
	}
	//COPY RULER STYLE TO PASTEBOARD 
	else if ([sender tag]==1)
	{
		if ([[[[self layoutManager] textStorage] string] length] > 0)
			[[self firstTextView] copyRuler:nil];
	}
	//GOES THROUGH THE SELECTEDRANGES OF TEXT AND PASTES THE PASTEBOARD FONT STYLE
	else if ([sender tag]==2)
	{
		NSArray *theRangeArray = [[self firstTextView] selectedRanges];
		NSEnumerator *rangeEnumerator = [theRangeArray objectEnumerator];
		id aRange;
		while (aRange = [rangeEnumerator nextObject])
		{
			[[self firstTextView] setSelectedRange:[aRange rangeValue]];
			[[self firstTextView] pasteFont:nil];
		}
	}
	//GOES THROUGH THE SELECTEDRANGES OF TEXT AND PASTES THE PASTEBOARD RULER STYLE
	else if ([sender tag]==3)
	{
		NSArray *theRangeArray = [[self firstTextView] selectedRanges];
		NSEnumerator *rangeEnumerator = [theRangeArray objectEnumerator];
		id aRange;
		while (aRange = [rangeEnumerator nextObject])
		{
			[[self firstTextView] setSelectedRange:[aRange rangeValue]];
			[[self firstTextView] pasteRuler:nil];
		}
	}
	//COPY FONT AND RULER STYLES TO RESPECTIVE PASTEBOARDS
	else if ([sender tag]==4)
	{ 		
		if ([[[[self layoutManager] textStorage] string] length] > 0) {
			[[self firstTextView] copyFont:nil];
			[[self firstTextView] copyRuler:nil];
		}
	}
	//GOES THROUGH THE SELECTEDRANGES OF TEXT AND PASTES THE FONT AND RULER STYLE
	//		IN THE FONT AND RULER PASTEBOARD TO EACH WHOLE PARAGRAPH CONTAINING PART OF EACH RANGE
	else if ([sender tag]==5)
	{
		NSArray *theRangeArray = [[self firstTextView] selectedRanges];
		NSEnumerator *rangeEnumerator = [theRangeArray objectEnumerator];
		id aRange;
		while (aRange = [rangeEnumerator nextObject])
		{
			[[self firstTextView] setSelectedRange:[aRange rangeValue]];
			[[self firstTextView] selectParagraph:nil];
			[[self firstTextView] pasteFont:nil];
			[[self firstTextView] pasteRuler:nil];
		}
		[[self firstTextView] setSelectedRanges:theRangeArray];
	}
	//SELECT RANGES OF TEXT WHICH MATCH FONT STYLE (NAME AND SIZE) AT THE INDEX (ie, NSFontAttributeNameAttributeName)
	else if ([sender tag]==6)
	{ 
		NSTextView *theTextView = [self firstTextView];
		NSString *theString = [[[self layoutManager] textStorage] string];
		//make sure there is a font to match (not last character, not empty)
		if ([theTextView selectedRange].location==[theString length] || [theString length] < 1) {
			NSBeep();
			return;
		} 
		//get NSFontAttributeName at index
		NSDictionary *theAttributes = [[[self layoutManager] textStorage] attributesAtIndex:[theTextView selectedRange].location effectiveRange:NULL];
		NSFont *theFont = [theAttributes objectForKey: NSFontAttributeName];
		int theStringLength = [theString length];
		int charIndex = 0;
		BOOL rangeIsOpen = NO;
		NSRange theMatchingFontRange = NSMakeRange(0,0);
		NSMutableArray *theSelectionRangesArray = [NSMutableArray arrayWithCapacity:0];
		
		//interate through string, looking for ranges of text where NSFontAttributeName match the index
		while (charIndex < theStringLength)
		{
			NSDictionary *theIndexAttributes = [[[self layoutManager] textStorage] attributesAtIndex:charIndex effectiveRange:NULL];
			//matches...note index for creation of range and leave range 'open'
			if ([theFont isEqualTo:[theIndexAttributes objectForKey: NSFontAttributeName]] && rangeIsOpen==NO) {
				theMatchingFontRange = NSMakeRange(charIndex, 1);
				rangeIsOpen = YES;
			//matches and range is open so interate to next char
			} else if ([theFont isEqualTo:[theIndexAttributes objectForKey: NSFontAttributeName]] && rangeIsOpen==YES) {
				theMatchingFontRange.length = theMatchingFontRange.length + 1;		
			//doesn't match and range is open, so close range and note length
			} else if (![theFont isEqualTo:[theIndexAttributes objectForKey: NSFontAttributeName]] && rangeIsOpen==YES) {
				unichar newLineUnichar = 0x000a;
				newLineChar = [[[NSString alloc] initWithCharacters:&newLineUnichar length:1] autorelease];
				NSString *initialChar = [[[self textStorage] string] substringWithRange:NSMakeRange(theMatchingFontRange.location, 1)];
				if ([initialChar isEqualToString:newLineChar]) {
					//scooch range.location forward one character to avoid newLineChar, which will drag previous line
					//	into any paragraph attribute change, which we don't want
					if (theMatchingFontRange.length > 1) {
						theMatchingFontRange.location = theMatchingFontRange.location + 1;
						theMatchingFontRange.length = theMatchingFontRange.length - 1;
					}
				}
				[theSelectionRangesArray addObject:[NSValue valueWithRange:theMatchingFontRange]];
				rangeIsOpen = NO;
			}
			charIndex = charIndex++;
			//end of text and a range is still open, so close it
			if (charIndex == theStringLength && rangeIsOpen==YES) {
				[theSelectionRangesArray addObject:[NSValue valueWithRange:theMatchingFontRange]];
			}
		}
		//use array of ranges to select areas of text in textView	
		[theTextView setSelectedRanges:theSelectionRangesArray];
				
	}
	//SELECT BY PARAGRAPH STYLE (NSParagraphStyle) = SELECT BY RULER
	else if ([sender tag]==7)
	{
		NSParagraphStyle *theCurrentParagraphStyle = [textStorage attribute:NSParagraphStyleAttributeName 
																	atIndex:[[self firstTextView] selectedRange].location
																	effectiveRange:NULL];
		NSTextView *theTextView = [self firstTextView];
		NSArray *theParagraphArray = [[[self layoutManager] textStorage] paragraphs];
		NSRange theSubParagraphRange;
		int theSubRangeIndex = 0;
		NSEnumerator *paragraphEnumerator = [theParagraphArray objectEnumerator];
		NSMutableArray *theSelectionRangesArray = [NSMutableArray arrayWithCapacity:0];
		id aParagraph;
		//examine each paragraph
		while (aParagraph = [paragraphEnumerator nextObject])
		{
			NSParagraphStyle *theSubParagraphStyle = [aParagraph attribute:NSParagraphStyleAttributeName 
						atIndex:0
						longestEffectiveRange:&theSubParagraphRange
						inRange:NSMakeRange(0, [aParagraph length]) ];

			//if paragraphStyle matches index paragraphStyle, add paragraph to the array
			if ([theCurrentParagraphStyle isEqualTo:theSubParagraphStyle])
			{
				[theSelectionRangesArray addObject:[NSValue valueWithRange:NSMakeRange(theSubRangeIndex, theSubParagraphRange.length)]];
			}
			theSubRangeIndex = theSubRangeIndex + [aParagraph length];
		}
		//use array of ranges to select areas of text in textView	
		[theTextView setSelectedRanges:theSelectionRangesArray];
	}
	//SELECT RANGES OF TEXT WHICH MATCH THE FONTFAMILY AT THE INDEX, ie [aFont fontFamily]
	//SELECTION WILL INCLUDE INTALIC, BOLD, ETC FOR FONTFAMILYS WITH SEPARATE FONTS FOR THOSE STYLES
	else if ([sender tag]==8)
	{ 
		NSTextView *theTextView = [self firstTextView];
		NSString *theString = [[[self layoutManager] textStorage] string];
		//get NSFontAttributeName at index
		NSDictionary *theAttributes = [[[self layoutManager] textStorage] attributesAtIndex:[theTextView selectedRange].location effectiveRange:NULL];
		NSFont *theFont = [theAttributes objectForKey: NSFontAttributeName];
		NSString *theFontFamilyName = [theFont familyName];
		int theStringLength = [theString length];
		int charIndex = 0;
		BOOL rangeIsOpen = NO;
		NSRange theMatchingFontRange = NSMakeRange(0,0);
		NSMutableArray *theSelectionRangesArray = [NSMutableArray arrayWithCapacity:0];
		
		//interate through string, looking for ranges of text where NSFontAttributeName match the index
		while (charIndex < theStringLength)
		{
			NSDictionary *theIndexAttributes = [[[self layoutManager] textStorage] attributesAtIndex:charIndex effectiveRange:NULL];
			NSString *theCurrentFontFamilyName = [[theIndexAttributes objectForKey: NSFontAttributeName] familyName]; 
			
			//matches...note index for creation of range and leave range 'open'
			if ([theFontFamilyName isEqualTo:theCurrentFontFamilyName] && rangeIsOpen==NO)
			{
				theMatchingFontRange = NSMakeRange(charIndex, 1);
				rangeIsOpen = YES;
			}
			//matches and range is open so interate to next char
			else if ([theFontFamilyName isEqualTo:theCurrentFontFamilyName] && rangeIsOpen==YES)
			{
				theMatchingFontRange.length = theMatchingFontRange.length + 1;		
			}
			//doesn't match and range is open, so close range and note length
			else if (![theFontFamilyName isEqualTo:theCurrentFontFamilyName] && rangeIsOpen==YES)
			{
				unichar newLineUnichar = 0x000a;
				newLineChar = [[[NSString alloc] initWithCharacters:&newLineUnichar length:1] autorelease];
				NSString *initialChar = [[[self textStorage] string] substringWithRange:NSMakeRange(theMatchingFontRange.location, 1)];
				if ([initialChar isEqualToString:newLineChar])
				{
					//	scooch range.location forward one character to avoid newLineChar, which will drag previous line
					//	into any paragraph attribute change, which we don't want
					if (theMatchingFontRange.length > 1)
					{
						theMatchingFontRange.location = theMatchingFontRange.location + 1;
						theMatchingFontRange.length = theMatchingFontRange.length - 1;
					}
				}
				[theSelectionRangesArray addObject:[NSValue valueWithRange:theMatchingFontRange]];
				rangeIsOpen = NO;
			}
			charIndex = charIndex++;
			//end of text and a range is still open, so close it
			if (charIndex == theStringLength && rangeIsOpen==YES)
			{
				[theSelectionRangesArray addObject:[NSValue valueWithRange:theMatchingFontRange]];
			}
		}
		//use array of ranges to select areas of text in textView	
		[theTextView setSelectedRanges:theSelectionRangesArray];
	}
	//SELECT RANGES OF TEXT WHICH MATCH THE FONTSIZE AT THE INDEX, ie [aFont fontSize]
	else if ([sender tag]==9)
	{ 
		NSTextView *theTextView = [self firstTextView];
		NSString *theString = [[[self layoutManager] textStorage] string];
		//	get NSFontAttributeName at index
		NSDictionary *theAttributes = [[[self layoutManager] textStorage] attributesAtIndex:[theTextView selectedRange].location effectiveRange:NULL];
		NSFont *theFont = [theAttributes objectForKey: NSFontAttributeName];
		float indexPointSize = [theFont pointSize];
		int theStringLength = [theString length];
		int charIndex = 0;
		BOOL rangeIsOpen = NO;
		NSRange theMatchingFontRange = NSMakeRange(0,0);
		NSMutableArray *theSelectionRangesArray = [NSMutableArray arrayWithCapacity:0];
		
		//	interate through string, looking for ranges of text where NSFontAttributeName match the index
		while (charIndex < theStringLength)
		{
			NSDictionary *theIndexAttributes = [[[self layoutManager] textStorage] attributesAtIndex:charIndex effectiveRange:NULL];
			float currentPointSize = 0.0;
			currentPointSize = [[theIndexAttributes objectForKey: NSFontAttributeName] pointSize]; 
			//matches...note index for creation of range and leave range 'open'
			if (indexPointSize==currentPointSize && rangeIsOpen==NO)
			{
				theMatchingFontRange = NSMakeRange(charIndex, 1);
				rangeIsOpen = YES;
			}
			//matches and range is open so interate to next char
			else if (indexPointSize==currentPointSize && rangeIsOpen==YES)
			{
				theMatchingFontRange.length = theMatchingFontRange.length + 1;		
			}
			//doesn't match and range is open, so close range and note length
			else if (!(indexPointSize==currentPointSize) && rangeIsOpen==YES)
			{
				unichar newLineUnichar = 0x000a;
				newLineChar = [[[NSString alloc] initWithCharacters:&newLineUnichar length:1] autorelease];
				NSString *initialChar = [[[self textStorage] string] substringWithRange:NSMakeRange(theMatchingFontRange.location, 1)];
				if ([initialChar isEqualToString:newLineChar])
				{
					//scooch range.location forward one character to avoid newLineChar, which will drag previous line
					//	into any paragraph attribute change, which we don't want
					if (theMatchingFontRange.length > 1)\
					{
						theMatchingFontRange.location = theMatchingFontRange.location + 1;
						theMatchingFontRange.length = theMatchingFontRange.length - 1;
					}
				}
				[theSelectionRangesArray addObject:[NSValue valueWithRange:theMatchingFontRange]];
				rangeIsOpen = NO;
			}
			charIndex = charIndex++;
			//	end of text and a range is still open, so close it
			if (charIndex == theStringLength && rangeIsOpen==YES)
			{
				[theSelectionRangesArray addObject:[NSValue valueWithRange:theMatchingFontRange]];
			}
		}
		//	use array of ranges to select areas of text in textView	
		[theTextView setSelectedRanges:theSelectionRangesArray];
	}
	//SELECT RANGES OF TEXT WHICH MATCH FONT FOREGROUND COLOR AT THE INDEX (ie, NSForegroundColorAttributeName)
	else if ([sender tag]==10)
	{
		NSTextView *theTextView = [self firstTextView];
		NSString *theString = [[[self layoutManager] textStorage] string];
		//get NSFontAttributeName at index
		NSDictionary *theAttributes = [[[self layoutManager] textStorage] attributesAtIndex:[theTextView selectedRange].location effectiveRange:NULL];
		NSColor *theColor = [theAttributes objectForKey: NSForegroundColorAttributeName];
		int theStringLength = [theString length];
		int charIndex = 0;
		BOOL rangeIsOpen = NO;
		NSRange theMatchingFontRange = NSMakeRange(0,0);
		NSMutableArray *theSelectionRangesArray = [NSMutableArray arrayWithCapacity:0];
		
		//interate through string, looking for ranges of text where NSFontAttributeName match the index
		while (charIndex < theStringLength)
		{
			NSDictionary *theIndexAttributes = [[[self layoutManager] textStorage] attributesAtIndex:charIndex effectiveRange:NULL];
			//matches...note index for creation of range and leave range 'open'
			//NOTE that theColor doesn't work for blackColor; it becomes !theColor, so we check for that to account for the 'color black
			if (([theColor isEqualTo:[theIndexAttributes objectForKey: NSForegroundColorAttributeName]]  
					|| !theColor && ![theIndexAttributes objectForKey: NSForegroundColorAttributeName])
					&& rangeIsOpen==NO)
			{
				theMatchingFontRange = NSMakeRange(charIndex, 1);
				rangeIsOpen = YES;
			}
			//matches and range is open so interate to next char
			else if (([theColor isEqualTo:[theIndexAttributes objectForKey: NSForegroundColorAttributeName]] 
					|| !theColor && ![theIndexAttributes objectForKey: NSForegroundColorAttributeName]) 
					&& rangeIsOpen==YES)
			{
				theMatchingFontRange.length = theMatchingFontRange.length + 1;		
			}
			//doesn't match and range is open, so close range and note length
			else if ((![theColor isEqualTo:[theIndexAttributes objectForKey: NSForegroundColorAttributeName]] 
					|| !theColor && ![theIndexAttributes objectForKey: NSForegroundColorAttributeName])
					&& rangeIsOpen==YES)
			{
				unichar newLineUnichar = 0x000a;
				newLineChar = [[[NSString alloc] initWithCharacters:&newLineUnichar length:1] autorelease];
				NSString *initialChar = [[[self textStorage] string] substringWithRange:NSMakeRange(theMatchingFontRange.location, 1)];
				if ([initialChar isEqualToString:newLineChar])
				{
					//scooch range.location forward one character to avoid newLineChar, which will drag previous line into any paragraph attribute change, which we don't want
					if (theMatchingFontRange.length > 1)
					{
						theMatchingFontRange.location = theMatchingFontRange.location + 1;
						theMatchingFontRange.length = theMatchingFontRange.length - 1;
					}
				}
				[theSelectionRangesArray addObject:[NSValue valueWithRange:theMatchingFontRange]];
				rangeIsOpen = NO;
			}
			charIndex = charIndex++;
			//	end of text and a range is still open, so close it
			if (charIndex == theStringLength && rangeIsOpen==YES)
			{
				[theSelectionRangesArray addObject:[NSValue valueWithRange:theMatchingFontRange]];
			}
		}
		if ([theSelectionRangesArray count]==0)
		{
			// NSColor blackColor doesn't work with above routine, so we 
			[theTextView setSelectedRange:NSMakeRange(0, theStringLength)];
		}
		else
		{
			//use array of ranges to select areas of text in textView	
			[theTextView setSelectedRanges:theSelectionRangesArray];
		}
	}
	//SELECT RANGES OF TEXT WHICH MATCH HIGHLIGHT COLOR AT THE INDEX (ie, NSBackgroundColorAttributeName)
	else if ([sender tag]==11)
	{ 
		NSTextView *theTextView = [self firstTextView];
		NSString *theString = [[[self layoutManager] textStorage] string];
		//get NSFontAttributeName at index
		NSDictionary *theAttributes = [[[self layoutManager] textStorage] attributesAtIndex:[theTextView selectedRange].location effectiveRange:NULL];
		NSColor *theColor = [theAttributes objectForKey: NSBackgroundColorAttributeName];
		//NOTE: we can also match by lack of highlight
		int theStringLength = [theString length];
		int charIndex = 0;
		BOOL rangeIsOpen = NO;
		NSRange theMatchingFontRange = NSMakeRange(0,0);
		NSMutableArray *theSelectionRangesArray = [NSMutableArray arrayWithCapacity:0];
		
		//interate through string, looking for ranges of text where NSFontAttributeName match the index
		while (charIndex < theStringLength)
		{
			NSDictionary *theIndexAttributes = [[[self layoutManager] textStorage] attributesAtIndex:charIndex effectiveRange:NULL];
			//matches...note index for creation of range and leave range 'open'
			if (([theColor isEqualTo:[theIndexAttributes objectForKey: NSBackgroundColorAttributeName]]  
				 || !theColor && ![theIndexAttributes objectForKey: NSBackgroundColorAttributeName])
				 && rangeIsOpen==NO)
			{
				theMatchingFontRange = NSMakeRange(charIndex, 1);
				rangeIsOpen = YES;
			}
			//matches and range is open so interate to next char
			else if (([theColor isEqualTo:[theIndexAttributes objectForKey: NSBackgroundColorAttributeName]] 
						|| !theColor && ![theIndexAttributes objectForKey: NSBackgroundColorAttributeName]) 
						&& rangeIsOpen==YES)
			{
				theMatchingFontRange.length = theMatchingFontRange.length + 1;		
			}
			//doesn't match and range is open, so close range and note length
			else if ((![theColor isEqualTo:[theIndexAttributes objectForKey: NSBackgroundColorAttributeName]] 
						|| !theColor && ![theIndexAttributes objectForKey: NSBackgroundColorAttributeName])
						&& rangeIsOpen==YES)
			{
				unichar newLineUnichar = 0x000a;
				newLineChar = [[[NSString alloc] initWithCharacters:&newLineUnichar length:1] autorelease];
				NSString *initialChar = [[[self textStorage] string] substringWithRange:NSMakeRange(theMatchingFontRange.location, 1)];
				if ([initialChar isEqualToString:newLineChar])
				{
					//scooch range.location forward one character to avoid newLineChar, which will drag previous line into any paragraph attribute change, which we don't want
					if (theMatchingFontRange.length > 1)
					{
						theMatchingFontRange.location = theMatchingFontRange.location + 1;
						theMatchingFontRange.length = theMatchingFontRange.length - 1;
					}
				}
				[theSelectionRangesArray addObject:[NSValue valueWithRange:theMatchingFontRange]];
				rangeIsOpen = NO;
			}
			charIndex = charIndex++;
			//	end of text and a range is still open, so close it
			if (charIndex == theStringLength && rangeIsOpen==YES)
			{
				[theSelectionRangesArray addObject:[NSValue valueWithRange:theMatchingFontRange]];
			}
		}
		//	use array of ranges to select areas of text in textView	
		[theTextView setSelectedRanges:theSelectionRangesArray];
	}
}

#pragma mark-
#pragma mark ---- Toolbar Methods  ----

// ******************* NSToolbar Related Methods *******************

- (void) setupToolbar
{
    // Create a new toolbar instance, and attach it to our document window 
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: MyDocToolbarIdentifier] autorelease];
    // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults 
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
	[toolbar setShowsBaselineSeparator:YES];
    // We are the delegate
    [toolbar setDelegate:self];
    // Attach the toolbar to the document window 
    [docWindow setToolbar: toolbar];
}

- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted {
    // Required delegate method:  Given an item identifier, this method returns an item 
    // The toolbar will use this method to obtain toolbar items that can be displayed in the customization sheet, or in the toolbar itself 
    NSToolbarItem *toolbarItem = nil;
    
    if ([itemIdent isEqual: SaveDocToolbarItemIdentifier])
	{
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Save", @"toolbar label: Save")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Save", @"palette label: Save")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Save Document", @"tooltip: Save Document")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBSaveItemImage"]]; //
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(saveTheDocument:)];
	}
	else if ([itemIdent isEqual: LookUpInDictionaryItemIdentifier])
	{
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Define", @"toolbar label: Define")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Define", @"palette label: Define")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Define Word", @"tooltip: Define Word")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBDefineWord"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(defineWord:)];
	}
	else if ([itemIdent isEqual: UndoItemIdentifier])
	{
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Undo", @"toolbar label: undo")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"pallete label: Undo", @"pallete label: Undo")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Undo", @"tooltip: Undo")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBUndoItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(undoChange:)];
	}
	else if ([itemIdent isEqual: RedoItemIdentifier])
	{
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Redo", @"toolbar label: Redo")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Redo", @"palette label: Redo")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Redo", @"tooltip: Redo")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBRedoItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(redoChange:)];

	}
	else if ([itemIdent isEqual: FindItemIdentifier])
	{
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Find", @"toolbar label: Find")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Find", @"palette label: Find")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Find", @"tooltip: Find")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBFindItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		//tells performFindPanelAction to show find panel
		[toolbarItem setTag: NSFindPanelActionShowFindPanel];
		[toolbarItem setAction: @selector(performFind:)];
	}
	else if ([itemIdent isEqual: AlternateTextColorItemIdentifier])
	{
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Alt Colors", @"toolbar label: Alt Colors")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Alt Colors", @"palette label: Alt Colors")];
		
		// Set up a reasonable tooltip, and image
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Alternate Text Colors", @"tooltip: Alternate Text Colors")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBAltColorsItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(switchTextColors:)];
	}
	else if ([itemIdent isEqual: ShowInspectorItemIdentifier])
	{
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Inspector", @"toolbar label: Inspector")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Inspector", @"pallete label: Inspector")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Inspector", @"tooltip: Inspector")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBInspectorItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(showInspectorPanelAction:)];
	}
	else if ([itemIdent isEqual: ShowStatisticsItemIdentifier])
	{
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Get Info", @"toolbar label: Get Info")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Get Info", @"palette label: Get Info")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Get Info", @"tooltip: Get Info")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBStatisticsItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(getInfoSheet:)];
	}
	else if ([itemIdent isEqual: BackupItemIdentifier])
	{
			toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
			
			// Set the text label to be displayed in the toolbar and customization palette 
			[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Backup", @"toolbar label: Backup")];
			[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Backup", @"palette label: Backup")];
			
			// Set up a reasonable tooltip, and image 
			[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Date-stamped Backup", @"tooltip: Date-stamped Backup")];
			[toolbarItem setImage: [NSImage imageNamed: @"TBBackupItemImage"]];
			
			// Tell the item what message to send when it is clicked 
			[toolbarItem setTarget: self];
			[toolbarItem setAction: @selector(backupDocumentAction:)];
	}
	else if ([itemIdent isEqual: ToggleViewtypeItemIdentifier])
	{
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
		
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: View", @"toolbar label: View")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: View", @"palette label: View")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Toggle View Type", @"tooltip: Toggle View Type")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBLayoutItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(setTheViewType:)];
	}
	else if ([itemIdent isEqual: AutocompleteItemIdentifier])
	{
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
		
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Complete", @"toolbar label: Complete")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Complete", @"palette label: Complete")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Autocomplete", @"tooltip: Autocomplete")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBCompleteItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(autocompleteAction:)];
	}
	else if ([itemIdent isEqual: FloatWindowItemIdentifier])
	{
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
		
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Float", @"toolbar label: Float")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Float", @"palette label: Float")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Make Window Float", @"tooltip: Make Window Float")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBFloatItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(floatWindow:)];
		
	}
	else if ([itemIdent isEqual: CopyItemIdentifier])
	{
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
		
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Copy", @"toolbar label: Copy")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Copy", @"palette label: Copy")];
		
		// Set up a reasonable tooltip, and image
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Copy", @"tooltip: Copy")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBCopyItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(copyAction:)];
		
	}
	else if ([itemIdent isEqual: PasteItemIdentifier])
	{
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
		
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Paste", @"toolbar label: Paste")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Paste", @"palette label: Paste")];
		
		// Set up a reasonable tooltip, and image
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Paste", @"tooltip: Paste")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBPasteItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(pasteAction:)];
		
	}
	else if ([itemIdent isEqual: InsertPictureIdentifier])
	{
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
		
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Picture", @"toolbar label: Picture")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Picture", @"palette label: Picture")];
		
		// Set up a reasonable tooltip, and image
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Insert Picture", @"tooltip: Insert Picture")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBInsertPicture"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(insertImageAction:)];
		
	}
	else if ([itemIdent isEqual: ShowRulerItemIdentifier])
	{
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
		
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Ruler", @"toolbar label: Ruler")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Ruler", @"palette label: Ruler")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Ruler", @"tooltip: Ruler")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBRulerItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(toggleBothRulers:)];
		
	}
	else if ([itemIdent isEqual: ShowFontPanelItemIdentifier])
	{
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
		
		// Set the text label to be displayed in the toolbar and customization palette 
		[toolbarItem setLabel:NSLocalizedString(@"toolbar label: Fonts", @"toolbar label: Fonts")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"palette label: Fonts", @"palette label: Fonts")];
		
		// Set up a reasonable tooltip, and image 
		[toolbarItem setToolTip:NSLocalizedString(@"tooltip: Fonts", @"tooltip: Fonts")];
		[toolbarItem setImage: [NSImage imageNamed: @"TBShowFontPanelItemImage"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(showFontPanel:)];
	}	
	else
	{
		// itemIdent refered to a toolbar item that is not provided or supported by us or cocoa 
		// Returning nil will inform the toolbar this kind of item is not supported 
		toolbarItem = nil;
	}
    return toolbarItem;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
    // Required delegate method:  Returns the ordered list of items to be shown in the toolbar by default    
    // If during the toolbar's initialization, no overriding values are found in the user defaults, or if the
    // user chooses to revert to the default items this set will be used 
    return [NSArray arrayWithObjects:
			SaveDocToolbarItemIdentifier,
			NSToolbarPrintItemIdentifier,
			NSToolbarSeparatorItemIdentifier,
			UndoItemIdentifier,
			RedoItemIdentifier,
			NSToolbarSeparatorItemIdentifier,
			FindItemIdentifier,
			ToggleViewtypeItemIdentifier, 
			LookUpInDictionaryItemIdentifier, // = Define
			ShowStatisticsItemIdentifier, // = Get Info...
			ShowInspectorItemIdentifier,
			InsertPictureIdentifier,
			NSToolbarFlexibleSpaceItemIdentifier,
			NSToolbarCustomizeToolbarItemIdentifier,
			nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
    // Required delegate method:  Returns the list of all allowed items by identifier.  By default, the toolbar 
    // does not assume any items are allowed, even the separator.  So, every allowed item must be explicitly listed   
    // The set of allowed items is used to construct the customization palette 
    return [NSArray arrayWithObjects: 
			SaveDocToolbarItemIdentifier,
			BackupItemIdentifier,
			NSToolbarPrintItemIdentifier,
			CopyItemIdentifier,
			PasteItemIdentifier,
			UndoItemIdentifier,
			RedoItemIdentifier,
			FindItemIdentifier, 
			NSToolbarShowColorsItemIdentifier,
			ShowFontPanelItemIdentifier,
			NSToolbarCustomizeToolbarItemIdentifier, 
			NSToolbarFlexibleSpaceItemIdentifier,
			NSToolbarSpaceItemIdentifier,
			NSToolbarSeparatorItemIdentifier,
			ShowStatisticsItemIdentifier,
			ToggleViewtypeItemIdentifier, 
			AlternateTextColorItemIdentifier,
			ShowInspectorItemIdentifier,
			LookUpInDictionaryItemIdentifier,
			AutocompleteItemIdentifier,
			FloatWindowItemIdentifier,
			InsertPictureIdentifier,
			ShowRulerItemIdentifier,
			nil];
}

- (void) toolbarWillAddItem: (NSNotification *) notif
{
    // Optional delegate method:  Before an new item is added to the toolbar, this notification is posted.
    // This is the best place to notice a new item is going into the toolbar.  For instance, if you need to 
    // cache a reference to the toolbar item or need to set up some initial state, this is the best place 
    // to do it.  The notification object is the toolbar to which the item is being added.  The item being 
    // added is found by referencing the @"item" key in the userInfo 
    NSToolbarItem *addedItem = [[notif userInfo] objectForKey: @"item"];
	if ([[addedItem itemIdentifier] isEqual: NSToolbarPrintItemIdentifier]) {
		[addedItem setToolTip: NSLocalizedString(@"Print Your Document", @"tooltip: Print Your Document")];
		[addedItem setTarget: self];
    }
}  

- (void) toolbarDidRemoveItem: (NSNotification *) notification
{
    // Optional delegate method:  After an item is removed from a toolbar, this notification is sent.   This allows 
    // the chance to tear down information related to the item that may have been cached.   The notification object
    // is the toolbar from which the item is being removed.  The item being added is found by referencing the @"item"
    // key in the userInfo 
}

- (BOOL) validateToolbarItem: (NSToolbarItem *) toolbarItem
{
    BOOL enable = NO;
    if ([[toolbarItem itemIdentifier] isEqual: NSToolbarPrintItemIdentifier]) {
		enable = YES;
    } else if ([[toolbarItem itemIdentifier] isEqual: LookUpInDictionaryItemIdentifier]) {
		enable = [textStorage length]; 
    } else if ([[toolbarItem itemIdentifier] isEqual: SaveDocToolbarItemIdentifier]) {
		if ([textStorage length]==0)
			enable = NO;
		else
		// we return YES (ie  the button is enabled) only when the document is dirty and needs saving 
			enable = [self isDirty];
	} else if ([[toolbarItem itemIdentifier] isEqual: FindItemIdentifier]) {
		enable = YES;
	} else if ([[toolbarItem itemIdentifier] isEqual: UndoItemIdentifier]) {
		enable = [[self undoManager] canUndo];
	} else if ([[toolbarItem itemIdentifier] isEqual: RedoItemIdentifier]) {
		enable = [[self undoManager] canRedo];
	} else if ([[toolbarItem itemIdentifier] isEqual: AlternateTextColorItemIdentifier]) {
		enable = YES;
	} else if ([[toolbarItem itemIdentifier] isEqual: ShowInspectorItemIdentifier]) {
		enable = YES;
	} else if ([[toolbarItem itemIdentifier] isEqual: ToggleViewtypeItemIdentifier]) {
		enable = YES;
	} else if ([[toolbarItem itemIdentifier] isEqual: AutocompleteItemIdentifier]) {
		enable = [textStorage length];
	} else if ([[toolbarItem itemIdentifier] isEqual: FloatWindowItemIdentifier]) {
		enable = YES;
		if (![self isFloating])
		{
			[toolbarItem setImage: [NSImage imageNamed: @"TBFloatItemImage"]];
		}
		else
		{
			[toolbarItem setImage: [NSImage imageNamed: @"TBFloatItemImageActive"]];
		}
	} else if ([[toolbarItem itemIdentifier] isEqual: BackupItemIdentifier]) {
		if (![self isTransientDocument] && [self isDocumentSaved])
		{
			enable = YES;
		}
		else
		{
			enable = NO;
		}
	} else if ([[toolbarItem itemIdentifier] isEqual: ShowStatisticsItemIdentifier]) {
		enable = YES; 
	} else if ([[toolbarItem itemIdentifier] isEqual: PasteItemIdentifier]) { 
		enable = [[NSPasteboard pasteboardWithName:NSGeneralPboard] changeCount];
		//disable if read only doc 11 Oct 2007 JH
		if ([self readOnlyDoc]) enable = NO;
	} else if ([[toolbarItem itemIdentifier] isEqual: CopyItemIdentifier]) { 
		enable = [[self firstTextView] selectedRange].length;
	} else if ([[toolbarItem itemIdentifier] isEqual: InsertPictureIdentifier]) { 
		enable = [[self firstTextView] importsGraphics];
		//disable if read only doc 11 Oct 2007 JH
		if ([self readOnlyDoc]) enable = NO;
	} else if ([[toolbarItem itemIdentifier] isEqual: ShowRulerItemIdentifier]) { 
		enable = YES;
	} else if ([[toolbarItem itemIdentifier] isEqual: ShowFontPanelItemIdentifier]) { 
		enable = YES;
	}
	return enable;
}

- (IBAction)undoChange:(id)sender
{
	[[self undoManager] undo];	
}

- (IBAction)redoChange:(id)sender
{
	[[self undoManager] redo];	
}

- (IBAction)performFind:(id)sender
{
	[[self firstTextView] performFindPanelAction:sender];	
}

-(IBAction)autocompleteAction:(id)sender
{
	[[self firstTextView] complete:nil];
}

-(IBAction)copyAction:(id)sender
{
	[[self firstTextView] copy:nil];
}

-(IBAction)pasteAction:(id)sender
{
	[[self firstTextView] paste:nil];
}

#pragma mark -
#pragma mark ---- Insert Methods ----

// ******************* Insert Date/Time and Break Methods *******************

-(IBAction)insertDateTimeStamp:(id)sender
{
	NSDate *today = [NSDate date];
#ifndef GNUSTEP
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	int selLoc = [[self firstTextView] selectedRange].location;
	int selLen = [[self firstTextView] selectedRange].length;
	//	if insert date - long format menu item choosen
	if ([sender tag]==0)
	{
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterLongStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		NSString *formattedDateString = [NSString stringWithFormat:@"%@ ",[dateFormatter stringFromDate:today]];
		BOOL success = [[self firstTextView] shouldChangeTextInRange:NSMakeRange (selLoc, selLen)
				replacementString:formattedDateString];
		if (success)
		{
			[[self firstTextView] replaceCharactersInRange:NSMakeRange (selLoc, selLen) withString:formattedDateString];
			[[self undoManager] setActionName:NSLocalizedString(@"undo action: Insert Date", @"undo action: Insert Date")];
		}
		[dateFormatter release];
	}
	//	if insert date - short format menu item choosen
	else if ([sender tag]==1)
	{
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		NSString *formattedDateString = [NSString stringWithFormat:@"%@ ",[dateFormatter stringFromDate:today]];
		BOOL success = [[self firstTextView] shouldChangeTextInRange:NSMakeRange (selLoc, selLen)
				replacementString:formattedDateString];
		if (success)
		{
			[[self firstTextView] replaceCharactersInRange:NSMakeRange (selLoc, selLen) withString:formattedDateString];
			[[self undoManager] setActionName:NSLocalizedString(@"undo action: Insert Date", @"undo action: Insert Date")];
		}
		[dateFormatter release];
	}
	//	if insert time format menu item choosen
	else if ([sender tag]==2)
	{
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		NSString *formattedDateString = [NSString stringWithFormat:@"%@ ",[dateFormatter stringFromDate:today]];
		BOOL success = [[self firstTextView] shouldChangeTextInRange:NSMakeRange (selLoc, selLen)
				replacementString:formattedDateString];
		if (success)
		{
			[[self firstTextView] replaceCharactersInRange:NSMakeRange (selLoc, selLen) withString:formattedDateString];
			[[self undoManager] setActionName:NSLocalizedString(@"undo action:Insert Time", @"undo action: Insert Time")];
		}
		[dateFormatter release];
	}
	//	if insert date/time format menu item choosen
	else if ([sender tag]==3)
	{
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		NSString *formattedDateString = [NSString stringWithFormat:@"%@ ",[dateFormatter stringFromDate:today]];
		BOOL success = [[self firstTextView] shouldChangeTextInRange:NSMakeRange (selLoc, selLen)
				replacementString:formattedDateString];
		if (success)
		{
			[[self firstTextView] replaceCharactersInRange:NSMakeRange (selLoc, selLen) withString:formattedDateString];
			[[self undoManager] setActionName:NSLocalizedString(@"Insert Date/Time", @"undo action: Insert Date/Time")];
		}
		[dateFormatter release];
	}
	selLoc = nil;
	selLen = nil;
	//	update the 'alternate' text colors if needed (6 June 2007 BH)
	if ([self shouldUseAltTextColors]) { [self updateAltTextColors]; }
#endif

}

-(IBAction)insertBreakAction:(id)sender
{
	if ([sender tag]==0)
	{
		//	insert line break
		if ([[self firstTextView] shouldChangeTextInRange:[[self firstTextView] selectedRange] replacementString:nil])	
		{
			[[self firstTextView] insertLineBreak:sender];
		}
		//	register undo
		[[self firstTextView] didChangeText];
		//	name undo action, based on tag of control
		[[self undoManager] setActionName:NSLocalizedString(@"Line Break", @"undo action: Line Break")];
	}
	else if ([sender tag]==1)
	{
		//	insert new line (ie, paragraph break)
		if ([[self firstTextView] shouldChangeTextInRange:[[self firstTextView] selectedRange] replacementString:nil])	
		{
			[[self firstTextView] insertNewline:sender];
		}
		//	register undo
		[[self firstTextView] didChangeText];
		//	name undo action, based on tag of control
		[[self undoManager] setActionName:NSLocalizedString(@"New Line", @"undo action: New Line")];		
	}
	else if ([sender tag]==2)
	{
		//	insert page break
		if ([[self firstTextView] shouldChangeTextInRange:[[self firstTextView] selectedRange] replacementString:nil])	
		{
			[[self firstTextView] insertContainerBreak:sender];
		}
		//	register undo
		[[self firstTextView] didChangeText];
		//	name undo action, based on tag of control
		[[self undoManager] setActionName:NSLocalizedString(@"Page Break", @"undo action: Page Break")];
	}
	else if ([sender tag]==3) //insert non-breaking space (yes, I know, not a 'break', oh well).
	{
		//non-breaking space for avoiding inconvenient line breaks due to wrapping like 'I love MAC OS/n X'
		NSString *nonBreakingSpace = [NSString stringWithFormat:@"%C", 0x00A0];
		//textView has automatic undo
		[[self firstTextView] insertText:nonBreakingSpace];
	}
}

#pragma mark-
#pragma mark ---- Misc Methods ----

// ******************* Invert Selection Method *******************

//	selects all unselected text
-(IBAction)invertSelection:(id)sender
{
	NSMutableArray *theNewRanges = [NSMutableArray arrayWithCapacity:0];
	NSArray *theSelectedRanges = [[self firstTextView] selectedRanges];
	int objectNumber = 0;
	int theStringLength = [[[[self layoutManager] textStorage] string] length];
	NSRange aNewRange;
	NSRange theCurrentRange = [[theSelectedRanges objectAtIndex:objectNumber] rangeValue];
	NSRange theNextRange;
	//	if all text is selected, un-select all
	if (theCurrentRange.location + theCurrentRange.length == theStringLength && theCurrentRange.length > 0 && theCurrentRange.location == 0)
	{
		aNewRange = NSMakeRange(0, 0);
		[theNewRanges addObject:[NSValue valueWithRange:aNewRange]];
	}
	//	if no test is selected, select all
	else if (theCurrentRange.length==0 || theCurrentRange.location==theStringLength + 1)
	{
		aNewRange = NSMakeRange(0, theStringLength);
		[theNewRanges addObject:[NSValue valueWithRange:aNewRange]];
	}
	//	misc ranges of text
	else {
		//	if the location of the first range is > 0, create range for first section 
		if (theCurrentRange.location > 0 && theCurrentRange.length > 0)
		{
			aNewRange = NSMakeRange(0, theCurrentRange.location);
			[theNewRanges addObject:[NSValue valueWithRange:aNewRange]];
		}
		//account for ranges in-between
		while (objectNumber <= [theSelectedRanges count] - 2 && [theSelectedRanges count] > 1 )
		{
			theCurrentRange = [[theSelectedRanges objectAtIndex:objectNumber] rangeValue];
			if (objectNumber < [theSelectedRanges count]) {
				theNextRange = [[theSelectedRanges objectAtIndex:objectNumber + 1] rangeValue];
			}
			else
			{
				theNextRange.location = (theCurrentRange.location + theCurrentRange.length);
			}
			aNewRange = NSMakeRange(theCurrentRange.location + theCurrentRange.length, theNextRange.location - theCurrentRange.location - theCurrentRange.length);
			[theNewRanges addObject:[NSValue valueWithRange:aNewRange]];
			objectNumber = objectNumber + 1;
		}
		//	if the last selected range does not extend to end of the string, create a range for last section
		if (theCurrentRange.location + theCurrentRange.length < theStringLength)
		{
			theCurrentRange = [[theSelectedRanges objectAtIndex:objectNumber] rangeValue];
			int newLocation = theCurrentRange.location + theCurrentRange.length;
			aNewRange = NSMakeRange(newLocation, theStringLength - newLocation);
			[theNewRanges addObject:[NSValue valueWithRange:aNewRange]];
		}
	}
	//	first record undo
	[[[self undoManager] prepareWithInvocationTarget:self] undoInvertSelection:theSelectedRanges];
	[[self undoManager] setActionName:NSLocalizedString(@"Invert Selection", @"undo action: Invert Selection")];
	//	then change selected ranges to new ranges
	[[self firstTextView] setSelectedRanges:theNewRanges];
}

//the undo method for invertSelection
-(void)undoInvertSelection:(NSArray *)theOldRangesArray
{
	//	record undo innfo
	[[[self undoManager] prepareWithInvocationTarget:self] undoInvertSelection:[[self firstTextView] selectedRanges]];
	[[self undoManager] setActionName:NSLocalizedString(@"Invert Selection", @"undo action: Invert Selection")];
	//	then change selected ranges to old ranges
	[[self firstTextView] setSelectedRanges:theOldRangesArray];
}

// ******************* Add Aligned Tabstop Methods *******************

//	insert aligned tab stop at specified position in ruler
-(IBAction)showAddTabStopPanelAction:(id)sender
{
	[removeTabStopsButton setState:NSOffState];
	[NSApp beginSheet:tabStopPanel modalForWindow:docWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
	[tabStopPanel orderFront:sender];
}


-(IBAction)addTabStopAction:(id)sender
{
	//	if user supplied values out of bounds, reset the value and let them try again
	if (([tabStopValueField floatValue] <.1 && [removeTabStopsButton state]==NSOffState)
				|| [tabStopValueField floatValue] > ([printInfo paperSize].width - [printInfo leftMargin] - [printInfo rightMargin]))
	{
		[tabStopValueField setObjectValue:@"0.00"];
		[tabStopValueField selectText:nil];
		return;
	}
	//	values were OK, so dismiss the sheet
	[NSApp endSheet:tabStopPanel];
	[tabStopPanel orderOut:sender];
	//	if no text exists or index is at end of string, range error will result, so beep and bail out
	if ([[textStorage string] length]==0
				|| ([[self firstTextView] selectedRange].location==[[textStorage string] length]))
	{
		NSBeep();
		return;
	}
	//	set up a NSTextTab based on user supplied information 
	float pointsPerUnit = [self pointsPerUnitAccessor];
	float theTabValue = [tabStopValueField floatValue] * pointsPerUnit;  // Every cm or half inch
	NSTextTab *tabStop;
	int theAlignmentType = [[tabStopAlignmentButton cell] tag];

	if (theAlignmentType==1) {
		tabStop = [[[NSTextTab alloc] initWithType:NSLeftTabStopType location:theTabValue] autorelease]; 
	} else if (theAlignmentType==2) {
		tabStop = [[[NSTextTab alloc] initWithType:NSCenterTabStopType location:theTabValue] autorelease]; 
	} else if (theAlignmentType==3) {
		tabStop = [[[NSTextTab alloc] initWithType:NSRightTabStopType location:theTabValue] autorelease]; 
	} else if (theAlignmentType==4) {
		tabStop = [[[NSTextTab alloc] initWithType:NSDecimalTabStopType location:theTabValue] autorelease]; 
	}
	unsigned paragraphNumber;
	//	an array of NSRanges containing applicable (possibly grouped) whole paragraph boundaries
	NSArray *theRangesForChange = [[self firstTextView] rangesForUserParagraphAttributeChange];
	//	a range containing one or more paragraphs
	NSRange theCurrentRange;
	//	a range containing the paragraph of interest 
	NSRange theCurrentParagraphRange;
	//	figure effected range for undo
	int undoRangeIndex = [[self firstTextView] rangeForUserParagraphAttributeChange].location;
	int undoRangeLength = [[theRangesForChange objectAtIndex:([theRangesForChange count] - 1)] rangeValue].location
		+ [[theRangesForChange objectAtIndex:([theRangesForChange count] - 1)] rangeValue].length - undoRangeIndex;
	//	start undo setup
	if ([[self firstTextView] shouldChangeTextInRange:NSMakeRange(undoRangeIndex,undoRangeLength) replacementString:nil])
	{
		//	iterate through ranges of paragraph groupings
		for (paragraphNumber = 0; paragraphNumber < [theRangesForChange count]; paragraphNumber++) 
		{
			//	set range for first (or only) paragraph; index is needed to locate paragraph; length is not important
			//	note: function rangesForUserPargraphAttributeChange returns NSValues (objects), so we use rangeValue to get NSRange value
			theCurrentParagraphRange = [[theRangesForChange objectAtIndex:paragraphNumber] rangeValue];
			theCurrentRange = [[theRangesForChange objectAtIndex:paragraphNumber] rangeValue];
			//now, step thru theCurrentRange paragraph by paragraph 
			[textStorage beginEditing]; //bracket for efficiency
			while (theCurrentParagraphRange.location < (theCurrentRange.location + theCurrentRange.length))
			{
				//get the actual paragraph range including length
				theCurrentParagraphRange = [[textStorage string] paragraphRangeForRange:NSMakeRange(theCurrentParagraphRange.location, 1)];
				//get the paragraphStyle
				NSMutableParagraphStyle *theParagraphStyle = [textStorage attribute:NSParagraphStyleAttributeName atIndex:theCurrentParagraphRange.location effectiveRange:NULL];
				if (theParagraphStyle==nil)
				{
					theParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
				}
				else
				{
					theParagraphStyle = [[theParagraphStyle mutableCopyWithZone:[[self firstTextView] zone]]autorelease];
				}
				
				//	add tabStop to the current paragraphStyle
				
				//	remove all tabStops for paragraph if user requests
				//	NOTE: this can screw up textLists, which need at least two tabs for each line item
				if ([removeTabStopsButton state]) [theParagraphStyle setTabStops:[NSArray arrayWithObjects:nil]];
				//	add new tabStop to paragraph
				if ([tabStopValueField floatValue] > 0) [theParagraphStyle addTabStop:tabStop];
				
				//	add the paragraphStyle attribute to the current paragraph in textStorage
				[textStorage addAttribute:NSParagraphStyleAttributeName value:theParagraphStyle range:theCurrentParagraphRange];
				
				//	make index (=location) the first letter of the next paragraph
				theCurrentParagraphRange = NSMakeRange((theCurrentParagraphRange.location + theCurrentParagraphRange.length),1);
				
				NSArray *theMarkers = [[self layoutManager]
							rulerMarkersForTextView:[self firstTextView] 
							paragraphStyle:theParagraphStyle ruler:[theScrollView horizontalRulerView]];
				[[theScrollView horizontalRulerView] setMarkers:theMarkers];
				[theScrollView setRulersVisible:YES];
			}
			[textStorage endEditing]; //	close bracket
			//	end undo setup
			[[self firstTextView] didChangeText];
			//	name undo action, based on tag of control
			[[self undoManager] setActionName:NSLocalizedString(@"Tab Stop", @"undo action: Tab Stop")];
		}
	}
	[removeTabStopsButton setState:NSOffState];
}

-(IBAction)cancelAddTabStopAction:(id)sender
{
	[NSApp endSheet:tabStopPanel];
	[tabStopPanel orderOut:sender];
}

// ******************* Look Up Word in Dictionary Method *******************

//	Looks up selected word or word located by cursor in cocoa included Dictionary 
//	NOTE: there are limitations...no multiple word definitions and no capitalized words (like 'French'), which is a limitation of the 'dict' NSURL itself (case insensitive)
//	TODO: multiple word URLs (replace space character?)

- (IBAction)defineWord:(id)sender
{
	//	determine range for word to be defined
	NSRange wordRange;
	//	move index forward 1 char so 'nextWordFromIndex' doesn't look back to previous word when cursor is at index of first letter but only if index is less than string length (so not out of bounds)
	if ([[self firstTextView] selectedRange].location != [[[self textStorage] string] length])
	{
		wordRange.location = [textStorage nextWordFromIndex:([[self firstTextView] selectedRange].location + 1) forward:NO];
	}
	else
	{
		wordRange.location = [textStorage nextWordFromIndex:([[self firstTextView] selectedRange].location) forward:NO];
	}
	wordRange.length = [textStorage  nextWordFromIndex:[[self firstTextView] selectedRange].location forward:YES] - wordRange.location;
	//	determine string for word to define
	NSString *defineWordString = nil;
	defineWordString = [[textStorage string] substringWithRange:NSMakeRange(wordRange.location,wordRange.length)];
	//	remove punctuation, if necessary
	NSMutableCharacterSet *nonLetterCharacterSet = [[[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy] autorelease];
	[nonLetterCharacterSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
	int nonLetterLocation;
	nonLetterLocation = [defineWordString rangeOfCharacterFromSet:nonLetterCharacterSet].location;
	//	if punctuation etc. is found, trim it
	if (nonLetterLocation !=NSNotFound)
	{
		defineWordString = [defineWordString substringWithRange:NSMakeRange(0,nonLetterLocation)];
	}
	//	check spelling of word to define with sharedSpellChecker (loaded at didLoadNib) 
	NSRange misspelledWordRange = [spellChecker checkSpellingOfString:defineWordString startingAt:0 language:nil wrap:NO inSpellDocumentWithTag:nil wordCount:nil];
	//	if misspelled (so no definition through URL scheme is possible), alert user
	if (misspelledWordRange.length)
	{
		int choice = NSAlertDefaultReturn;
		NSString *title = [NSString stringWithFormat:NSLocalizedString(@"The word \\U2018%@\\U2019 may be misspelled.", @"alert tite: The word (word inserted at runtime) may be misspelled."), defineWordString];
		NSString *theInformativeString = [NSString stringWithFormat:NSLocalizedString(@"Do you want to check the spelling?", @"alert text: Do you want to check the spelling?")];
	    choice = NSRunAlertPanel(title, 
								 theInformativeString,
								 NSLocalizedString(@"button title: Check Spelling", @"button: Check Spelling"),
								 NSLocalizedString(@"button title: Open Dictionary", @"button: Open Dictionary"), 
								 NSLocalizedString(@"button title: Cancel", @"button: Cancel"));
		//	1 = call up the spell check panel, if user chooses
	    if (choice==NSAlertDefaultReturn)
		{
			[[self firstTextView] setSelectedRange:NSMakeRange(wordRange.location,wordRange.length)];
			[[self firstTextView] showGuessPanel:nil];
			[spellChecker spellingPanel];
			[spellChecker updateSpellingPanelWithMisspelledWord:defineWordString];
			return;
		}
		//	-1 = otherwise exit method and let user get back to work without trying the dictionary
		else if (choice==NSAlertOtherReturn)
		{
			return;
		}
		else if (choice==NSAlertAlternateReturn)
		{
			//just continue with dictionary
		}
	}
	//	make a 'dict' type URL to pass to the Dictionary.app 
	NSString *defineWordURLString = [NSString stringWithFormat:@"dict:///%@", defineWordString];
	[[NSWorkspace sharedWorkspace] launchApplication:@"Dictionary"];	
	[[NSWorkspace sharedWorkspace] launchApplication:@"Dictionary"];	
	NSArray *theURLArray = [NSArray arrayWithObject:[NSURL URLWithString:defineWordURLString]];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"dict:/// "]];	
	[[NSWorkspace sharedWorkspace] openURLs:theURLArray withAppBundleIdentifier:@"com.apple.Dictionary" options:nil additionalEventParamDescriptor:nil launchIdentifiers:nil];
}

-(IBAction)testMethod:(id)notification
{
	//test
}

-(IBAction)sendToMail:(id)notification
{
#ifndef GNUSTEP
	//	opens Mail.app with a new message, and inserts the documents saved file into body with brief description the description is so the person sending it knows what exactly it is!
	if ([self fileName])
	{
		NSDictionary* errorDict;
		NSAppleEventDescriptor* returnDescriptor = NULL;
		NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:
			
			[NSString stringWithFormat:
			@"\
			tell application \"Mail\"\n\
			activate\n\
			set bodyvar to \"Attached file name: %@\"\n\
			set the new_message to (make new outgoing message with properties {visible:true, content:\" \"})\n\
			tell the new_message\n\
			set the content to bodyvar\n\
			tell content\n\
			make new attachment with properties {file name:\"%@\"} at before the first character\n\
			end tell\n\
			end tell\n\
			end tell", [[self fileName] lastPathComponent], [self fileName]]
		];
			
		returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
		[scriptObject release];
	}
#endif
}

//	action for menu item: Find > Location of Last Edit
-(IBAction)restoreCursorLocationAction:(id)sender
{
	if ([self savedEditLocation] && [self savedEditLocation] < [textStorage length] + 1)
	{
		[[self firstTextView] setSelectedRange:NSMakeRange([self savedEditLocation], 0)];
		if ([self hasMultiplePages])
		{
			[self constrainScrollWithForceFlag:YES];
			[theScrollView reflectScrolledClipView:[theScrollView contentView]];
		}
		else
		{
			[[self firstTextView] centerSelectionInVisibleArea:self];
		}
	}
}

-(IBAction)windowResignedMain:(id)sender
{
	//	un-enable these buttons when window focus is lost
	[pageUpButton setEnabled:NO];
	[pageDownButton setEnabled:NO];
}


//hide control to change document background color in font panel (MyDocument is textView's delegate)
- (unsigned int)validModesForFontPanel:(NSFontPanel *)fontPanel
{
	return (NSFontPanelStandardModesMask ^ NSFontPanelDocumentColorEffectModeMask);
}

#pragma mark -
#pragma mark ---- Image/Size Actions ----
// ******************* Image/Size Actions ********************

-(IBAction)insertImageAction:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:YES];
	//image file types we can insert
	NSArray *fileTypes = [ NSArray arrayWithObjects:
				@"eps", @"ps", @"tiff", 
				@"tif", @"jpg", @"jpeg", @"gif", @"png", 
				@"pict", @"pic", @"pct", @"bmp", @"ico", 
				@"icns", @"psd", @"jp2", nil ];
	[openPanel beginSheetForDirectory:nil file:nil types:fileTypes modalForWindow:[NSApp mainWindow] 
				modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

//	called by insertImageAction - inserts images into RTFD and BEAN documents by placing a copy of the image file into the document's package (ie, folder)
- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	[NSApp endSheet:sheet];
	[sheet orderOut:nil];
	if (returnCode==NSOKButton)
	{
		//	go through chosen filenames
		NSEnumerator *enumerator = [[sheet filenames] objectEnumerator];
		NSString  *fName;
		NSFileWrapper *fWrap = nil;
		while (fName = [enumerator nextObject])
		{
			//	get the size of the image
			NSImage *img = [[[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:fName]]autorelease];
			if (img)
			{
				//	get firstLineIndent from user Prefs
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				float firstLineIndent = 0.0;
				firstLineIndent = [defaults boolForKey:@"prefIsMetric"]
					? [[defaults valueForKey:@"prefDefaultFirstLineIndent"] floatValue] * 28.35 
					: [[defaults valueForKey:@"prefDefaultFirstLineIndent"] floatValue] * 72.0;
				//	since the image was TOO BIG to display correctly, we resize it to fit the document in layout made
				if ([img size].width > ([printInfo paperSize].width - [printInfo leftMargin]- [printInfo rightMargin] - firstLineIndent))
				{
					//	size constraints
					float maxWidth = floor([printInfo paperSize].width - [printInfo leftMargin]- [printInfo rightMargin] - firstLineIndent - 5);
					//	adjust for gap due to line spacing 21 Aug 2007 JH
					float maxHeight = floor([printInfo paperSize].height - [printInfo topMargin]- [printInfo bottomMargin] - 5) * [defaults integerForKey:@"prefDefaultLineSpacing"];
					// determine scale factor needed to fit within size constraints.
					float widthScale = (float) maxWidth / (float) [img size].width;
					float heightScale = (float) maxHeight / (float) [img size].height;
					float scaleFactor = 1.0;
					scaleFactor = MIN(widthScale, heightScale);
					//	apply scaleFactor to width and height
					float newWidth = floor([img size].width * scaleFactor);
					float newHeight = floor([img size].height * scaleFactor);
					//	return file wrap containing image with new size (but without loss of resolution)
					fWrap = [self fileWrapperForImage:img withMaxWidth:newWidth withMaxHeight:newHeight];
					widthScale = 0.0;
					heightScale = 0.0;
					newWidth = 0.0;
					newHeight = 0.0;
					scaleFactor = 0.0;
					if (!fWrap) 
					{
						NSBeep();
						return;
					}
				}
				
				//	image size is OK so just make fileWrapper
				else
				{
					//	make a fileWrapper for the image
					fWrap = [[[NSFileWrapper alloc] initWithPath: fName] autorelease];
					//	name fileWrap with its original filename (if available)
					NSString *imgName = [fName lastPathComponent];
					[fWrap setFilename: imgName];
					[fWrap setPreferredFilename: imgName];
				}
				firstLineIndent = 0.0;
				
				//	make a text attachment and attach the fileWrapper
				NSTextAttachment *ta = [[[NSTextAttachment alloc] initWithFileWrapper: fWrap] autorelease];
				
				//	NOTE: Attachments inserted in nil text, or at the beginning of paragraphs, have nil attributes so we fix this in KBWordCountingTextStorage by overriding replaceCharactersInRange and adding the typingAttributes form the textView to the textAttachment; this also works for pasted graphics and drap'n'dropped graphics
				
				//	make an attributed string with the attachment attached
				NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:ta];						
				NSRange selRange = [[self firstTextView] selectedRange];
				//	NOTE: we could probably just use insertText here, but would not get a special undo action
				//	for undo
				if ([[self firstTextView] shouldChangeTextInRange:selRange replacementString:[attachmentString string]])
				{
					//	insert graphic
					//	note: replaceCharacters... has special code that prevents the attachments from nuking the paragraph attributes and from nuking the typingAttributes, which is why we use it instead of insertAttributedString: atIndex:
					[textStorage replaceCharactersInRange:NSMakeRange(selRange.location, 0) withAttributedString:attachmentString];
					//end undo
					[[self firstTextView] didChangeText];
					//name undo for menu
					[[self undoManager] setActionName:NSLocalizedString(@"Insert Graphic", @"undo action: Insert Graphic")];
				}
			}
		}
	}
}

//	prepares, then shows image resizing sheet
-(IBAction)showResizeImageSheetAction:(id)sender
{
	unsigned scanLoc = 0;
	//	if menu action (rather than user clicked on image cell), we find the closest selected attachment if there is one and make it alone the selected range
	if ([sender tag]==1)
	{
		NSString *stringToScan = [[textStorage string] substringWithRange:[[self firstTextView] selectedRange]];
		//	NSAttachmentCharacter = 0xfffc
		NSScanner *seekAttachment = [NSScanner scannerWithString:stringToScan];
		[seekAttachment scanUpToString:[NSString stringWithFormat:@"%C", NSAttachmentCharacter] intoString:NULL];
		scanLoc = [seekAttachment scanLocation];
		unsigned stringLength = [stringToScan length];
		if (scanLoc==stringLength)
		{
			NSBeep();
			return;
		}
		else
		{
			int locAttachment = [[self firstTextView] selectedRange].location + scanLoc;
			[[self firstTextView] setSelectedRange:NSMakeRange(locAttachment, 1)];
		}
	}
	// 25 Aug 2007 should not change read only doc
	if (![[self firstTextView] shouldChangeTextInRange:[[self firstTextView] selectedRange] replacementString:nil])
	{
		NSBeep();
		return;
	}
		
	//	get attachment at insertion point
	NSTextAttachment *ta = [ textStorage attribute:NSAttachmentAttributeName 
				atIndex:[[self firstTextView] selectedRange].location
				effectiveRange:NULL ];
	//	get cell image
	NSImage *image = nil;
	image = [self cellImageForAttachment:ta];
	//	adjust slider maxValue relative to print info page width and image width
	float maxValue = ([printInfo paperSize].width - [printInfo leftMargin]- [printInfo rightMargin]) / [image size].width;

	//	if width paper / width image < 1, (i.e., image is large in size), set maxValue = 1
	if (maxValue < 1.0) { maxValue = 1.0; }
	[imageSlider setMaxValue:maxValue];
	//	original image value = 1
	[imageSlider setObjectValue:[NSNumber numberWithFloat:1.0]];
	[imageSliderTextField setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Image Size: %.1f%%", @"Image Size: (number as percent is inserted here at runtime)"), [imageSlider floatValue] * 100]];
	//	show the image resizer sheet
	[NSApp beginSheet:imageSheet modalForWindow:docWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
	[imageSheet orderFront:nil];
}

-(IBAction)imageSliderAction:(id)sender
{
	//	get attachment at insertion point
	NSTextAttachment *ta = [ textStorage attribute:NSAttachmentAttributeName 
				atIndex:[[self firstTextView] selectedRange].location
				effectiveRange:NULL ];
	//	get image from attachmentCell
	NSImage *image = nil;
	image = [self cellImageForAttachment:ta];
	//	if [self imageSize] is not NSZeroSize, it's already been set to remember the size if the user cancels the resize, so leave it
	if (image && [self imageSize].height==NSZeroSize.height && [self imageSize].width==NSZeroSize.width)
	{
		//	remember the size for multipling by the slider value
		[self setImageSize:[image size]];
	}
	
	[image lockFocus];
	//	resize the cell image to show user what size saved picture will be (actual image in fileWrapper is not resized until the sheet is closed)
	[image setScalesWhenResized:YES];
	[image setSize: NSMakeSize(floor([self imageSize].width * [imageSlider floatValue]),floor([self imageSize].height * [imageSlider floatValue]))];
	[[self firstTextView] centerSelectionInVisibleArea:self];
	[image unlockFocus];
	[imageSliderTextField setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Image Size: %.1f%%", @"Image Size: (number as percent is inserted here at runtime)"), [imageSlider floatValue] * 100]];
	[layoutManager textContainerChangedGeometry:[[self firstTextView] textContainer]];
}

// action for when resizing control sheet is dismissed (image was resized or action was canceled)
-(IBAction)imageSheetCloseAction:(id)sender
{
	//	if cancel/escape chosen, return image cell to original size and dismiss panel 
	if (![sender tag])
	{
		//	get attachment at insertion point
		NSTextAttachment *ta = [ textStorage attribute:NSAttachmentAttributeName 
					atIndex:[[self firstTextView] selectedRange].location
					effectiveRange:NULL ];
		//	get image from attachmentCell
		NSImage *image = nil;
		image = [self cellImageForAttachment:ta];
		//	return imageCell size to it's original value; attached file was not yet changed
		if (image) { [image setSize:[self imageSize]]; }
		[layoutManager textContainerChangedGeometry:[[self firstTextView] textContainer]];
		//	zero it out
		[self setImageSize:NSZeroSize];
		//	dismiss sheet
		[NSApp endSheet:imageSheet];
		[imageSheet orderOut:sender];
		return;
	}
	//	get image from attachment to be replaced
	NSTextAttachment *ta = [textStorage attribute:NSAttachmentAttributeName
				atIndex:[[self firstTextView] selectedRange].location
				effectiveRange:NULL];				
	//	get fileWrapper contents
	NSData *theData = [[ta fileWrapper] regularFileContents];
	//	and make an NSImage from them
	NSImage *oldImage = nil;
	if (theData)
	{
		oldImage = [[[NSImage alloc] initWithData:theData]autorelease];
	}
	else 
	{
		NSBeep();
		return;
	}
	if (oldImage) 
	{
		NSFileWrapper *fw = nil;
		float maxHeight = floor([oldImage size].height * [imageSlider floatValue]);
		float maxWidth = floor([oldImage size].width * [imageSlider floatValue]);
		fw = [self fileWrapperForImage:oldImage  withMaxWidth:maxWidth withMaxHeight:maxHeight];
		if (!fw) 
		{
			NSBeep();
			return;
		}

		//	make an NSAttributedString holding the new attachment
		NSTextAttachment *newTa = [[NSTextAttachment alloc] initWithFileWrapper: fw];
		NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:newTa];

		//	insert it
		[[self firstTextView] shouldChangeTextInRange:[[self firstTextView] selectedRange] replacementString:[attachmentString string]];
		//	if we don't remind the old attachment of its size, the new attachment undo's to the old attachment, but the old attachment has the size of the new one -- why?
		[[self cellImageForAttachment:ta] setSize:[self imageSize]];
		//	replace old image attachment with new (ie, resized) image attachment
		[textStorage replaceCharactersInRange:[[self firstTextView] selectedRange] withAttributedString:attachmentString];
		[layoutManager textContainerChangedGeometry:[[self firstTextView] textContainer]];
		//	end undo
		[[self firstTextView] didChangeText];
		[[self undoManager] setActionName:NSLocalizedString(@"Resize Picture", @"undo action: Resize Picture")];
		//	clean up artifacts
		[theScrollView display];
		[[self firstTextView] setNeedsDisplay:YES];
		//	reset the imageSize accessor
		[self setImageSize:NSZeroSize];
		//	release objects
		[newTa release];
	}
	//	dismiss sheet
	[NSApp endSheet:imageSheet];
	[imageSheet orderOut:sender];
}

//	return a fileWrapper (or nil upon failure) for an image of adjusted size for the image passed in//
- (NSFileWrapper *)fileWrapperForImage:(NSImage *)anImage withMaxWidth:(float)newWidth withMaxHeight:(float)newHeight
{
	//So, turns out I way overthought the resizing an image method. Just get the rep and resize it. Yep.
/*
	//use ImageAdjuster class to adjust size of image using high quality scaling (based on Apple's ImageReducer code)
	
	ImageAdjuster *imageAdjuster = [[ImageAdjuster alloc] init];
	//feed it the image
	[imageAdjuster setInputImage:anImage];

	//feed it new size
	if (floor(pixelHeight)) [imageAdjuster setMaxPixelsHigh:pixelHeight];
	if (floor(pixelWidth)) [imageAdjuster setMaxPixelsWide:pixelWidth];

	NSImage *newImage = nil;
	//get the output image
	newImage = [imageAdjuster outputImage];
	[newImage lockFocus];
	//get an imageRep
	NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc]
			initWithFocusedViewRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height)] autorelease];

	//test code
	//might try to get this to work at some point to retain vectorishness of an image
	//NSData *data = [newImage dataWithPDFInsideRect:NSMakeRect(0,0, [newImage size].width, [newImage size].height)];
	
	[newImage unlockFocus];
	[imageAdjuster release];
	NSData *data = nil;
  
*/
	// msg on cocoabuilder.com by Todd Heberlein on Tue Dec 09 2003 helped me with this
	NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData: [anImage TIFFRepresentation]];
    [rep TIFFRepresentation];  // flush
    [rep setSize:NSMakeSize(newWidth, newHeight)];  // reset the size
    NSData *data = [rep representationUsingType:NSTIFFFileType properties:nil];

	//	get jpeg data from imageRep
	if (rep)
	{
		NSDictionary *compression = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.8] forKey:NSImageCompressionFactor];
		data = [rep representationUsingType:NSJPEGFileType properties:compression];
		/* test code
		note: not used; jpeg seems sufficient
		NSDictionary *compression = [NSDictionary dictionaryWithObject:@"NSTIFFCompressionLZW" forKey:NSImageCompressionMethod];
		data = [rep representationUsingType:NSTIFFFileType properties:compression];
		*/
	}
	else
	{
		//	failed
		NSBeep();
		return nil;
	}
		//	create new fileWrapper to hold new image
	NSFileWrapper *fw = [[[NSFileWrapper alloc] initRegularFileWithContents: data] autorelease];
		//	come up with a name for the file
	NSString *imgPathName = [anImage name];
	if( !imgPathName )
		imgPathName = @"image";
		//	a fileWrapper must have a path!
	imgPathName = [imgPathName stringByAppendingPathExtension: @"jpg"];
	[fw setFilename: imgPathName];
	[fw setPreferredFilename: imgPathName];
	return fw;
}

//	9 July 2007 BH recast theImageCell as id to get rid of 'Not part of protocol' compiler warning for [attachmentCell image]
- (NSImage *)cellImageForAttachment:(NSTextAttachment *)attachment
{
	id theImageCell = nil;
	theImageCell = [attachment attachmentCell] ;
	BOOL success = [[theImageCell image] isValid];
	if (success) return [theImageCell image];
	else return nil;
}

- (IBAction)displayHelp:(id)sender
{
	if ([sender tag]==0)
	{
		[[NSHelpManager sharedHelpManager] openHelpAnchor:@"FORMATS" inBook:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"]];
	}
	else
	{
		//nothing else yet
	}
}




//	this method checks for a newer version of Bean available for download on the web at www.bean-osx.com by comparing Bean's x.x.x style version number to the one stored in an xml file on the web.
//	based on UpdateCheckTest code created by Karl Moskowski on 08/01/07, which I don't think works, see notes
//	NB: this ties us down to the x.x.x version style numbering, which isn't a bad thing

-(IBAction) checkForUpdate:(id) sender
{
#ifndef GNUSTEP
#define versionIsCurrent 0
#define versionIsNotCurrent 1
#define versionIsNewerThanLatestAvailable 2
	
	int resultOfCheckForUpdate = 0;
	BOOL shouldKeepChecking = YES;
	NSError *theError;
	NSXMLDocument *xmlDoc = nil;
	
	//	NOTE: NSURL this was reading an on-disk cache of the URL and would never indicate when an update was needed, so we use NSURLRequest instead so we can control the cache policy
	// theURL = [[NSURL alloc] initWithScheme:@"http" host:@"www.bean-osx.com" path:@"/releases/availableVersion.xml"];

	//	for testing using on-disk XML file
	//	NSURL *theURL = [NSURL fileURLWithPath:@"//Users/JH/Documents/Cocoa/BeanWeb/BeanMirror/releases/availableVersion.xml"];
	
	//	set up request
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.bean-osx.com/releases/availableVersion.xml"]
				cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
		
	//	retrieve XML version doc over web
	xmlDoc = [[NSXMLDocument alloc] 
				initWithData: [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil] 
				options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) 
				error:&theError];
	
	//	couldn't get latest version number
	if ((theError != nil && [theError code] == -1014) || !xmlDoc)
	{
		NSString *vaTitle = NSLocalizedString(@"Sorry, Bean was unable to check for a newer version.", @"alert title: Sorry, Bean was unable to check for a newer version.");
		NSString *vaText = NSLocalizedString(@"Perhaps you are not connected to the internet?\rYou can check for a newer version at this address in your web browser: www.bean-osx.com", @"alert text: Perhaps you are not connected to the internet?\rYou can check for a newer version at this address in your web browser: www.bean-osx.com");
		NSRunAlertPanel(vaTitle, vaText, NSLocalizedString(@"OK", @"OK"), nil, nil);
	}

	//	compare the latest version number to the version number of the one we have here
	else
	{
		//	get the version numbers as strings
		NSString *availableVersion = [[[xmlDoc nodesForXPath:@"./data/availableVersion" error:&theError] objectAtIndex:0] stringValue];
		NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		
		//	for testing
		//NSLog([NSString stringWithFormat:@"a:%@, c:%@", availableVersion, currentVersion]);
		
		//turn the version numbers into arrays
		NSMutableArray *availableVersionArray = [NSMutableArray arrayWithCapacity:3];
		NSMutableArray *currentVersionArray = [NSMutableArray arrayWithCapacity:3];
		
		//	build the array for (newest) availableVersion
		NSScanner *scanner = [NSScanner scannerWithString:availableVersion];
		while (![scanner isAtEnd])
		{
			NSString *tempString = nil;
			[scanner scanUpToString:@"." intoString:&tempString];
			if (tempString)
			{
				[availableVersionArray addObject:[NSNumber numberWithInt:[tempString intValue]]];
				unsigned scanLoc = nil;
				scanLoc = [scanner scanLocation];
				if ((scanLoc + 1) < [availableVersion length])
				{
					[scanner setScanLocation:(scanLoc + 1)];
				}
			}
			tempString = nil;
		}
		scanner = nil;
		
		//	build the array for currentVersion (the one we have)
		scanner = [NSScanner scannerWithString:currentVersion];
		while (![scanner isAtEnd])
		{
			NSString *tempString = nil;
			[scanner scanUpToString:@"." intoString:&tempString];
			if (tempString)
			{
				[currentVersionArray addObject:[NSNumber numberWithInt:[tempString intValue]]];
				unsigned scanLoc = nil;
				scanLoc = [scanner scanLocation];		
				if ((scanLoc + 1) < [availableVersion length])
				{
					[scanner setScanLocation:(scanLoc + 1)];
				}
			}
			tempString = nil;
		}
		
		//	step through arrays, comparing numbers; higher 'availableVersion' numbers means update available
		int i = 0;
		for (i = 0; i < [availableVersionArray count]; i++)
		{
			if (shouldKeepChecking==YES)
			{
				int avNum = [[availableVersionArray objectAtIndex:i] intValue];
				int cvNum = [[currentVersionArray objectAtIndex:i] intValue];
				
				//for testing
				//NSLog([NSString stringWithFormat:@"a:%i c:%i", avNum, cvNum]);
				
				if (avNum > cvNum)
				{
					resultOfCheckForUpdate = versionIsNotCurrent;
					shouldKeepChecking = NO;
				}
				else if (avNum < cvNum)
				{
					resultOfCheckForUpdate = versionIsNewerThanLatestAvailable;
					shouldKeepChecking = NO;
				}
				else //	are equal
				{
					resultOfCheckForUpdate = versionIsCurrent;
				}
				avNum = 0;
				cvNum = 0;
			}
		}
		
		//	inform user
		if (resultOfCheckForUpdate == versionIsNotCurrent)
		{
			
			if (NSRunInformationalAlertPanel (NSLocalizedString(@"An updated version of Bean is available.", @"alert title: An updated version of Bean is available."),
						[NSString stringWithFormat:NSLocalizedString(@"Version %@ is available (you have %@). Do you want to visit the download web page?", @"alert text: Version %@ is available (you have %@). Do you want to visit the download web page? (translator: retain the order of the version numbers)"), availableVersion, currentVersion],
						NSLocalizedString(@"Yes", @"Yes"),
						NSLocalizedString(@"No", @"No"),
						nil ) 
						== NSAlertDefaultReturn)
			{
				NSURL *beanURL = [[NSURL alloc] initWithScheme:@"http" host:@"www.bean-osx.com" path:@"/index.html"];
				[[NSWorkspace sharedWorkspace] openURL:beanURL];
				[beanURL release];
			}	
			return;
		}
		else if (resultOfCheckForUpdate == versionIsNewerThanLatestAvailable)
		{
			NSRunAlertPanel(NSLocalizedString(@"You appear to have a preview of the next version of Bean.", @"alert title: You appear to have a preview of the next version of Bean."), @"", NSLocalizedString(@"OK", @"OK"), nil, nil);
		}
		else
		{
			NSRunAlertPanel([NSString stringWithFormat:NSLocalizedString(@"This version of Bean (%@) is current.", @"alert title: This version of Bean (version number inserted at runtime) is current."), currentVersion], @"", NSLocalizedString(@"OK", @"OK"), nil, nil);
		}
	}
	[xmlDoc release];
	theError = nil;
	xmlDoc = nil;
#endif
}

//	kind of worthless method that moves first page up to very tippy top when up arrow is pressed
-(IBAction) scrollUpWhenAtBeginning:(id)sender
{
	NSRange selRange = [[self firstTextView] selectedRange];
	if ([self hasMultiplePages] && selRange.location == 0 && selRange.length == 0)
	{
		[[self firstTextView] scrollPageUp:nil];
	}
}

/*
//	this code doesn't reliably work, because the keyboard layout sometimes isn't set by OS X until after document is loaded!
-(void)checkKeyboardLayoutName
{
	KeyboardLayoutRef   keyLayout = nil; //
	NSString			*keyboardLayoutName = nil; //prevent error
	KLGetCurrentKeyboardLayout(&keyLayout);
	if (keyLayout) KLGetKeyboardLayoutProperty(keyLayout, kKLName, (const void **) &keyboardLayoutName);
	//	Bean's special handling of ' and " causes Ranier Brockerhoff's "U.S. - International" keyboard layout not to work
	if ([keyboardLayoutName isEqualToString:@"U.S. - International"])
	{
		//[alertSheet setMessageText:[NSString stringWithFormat:@"Smart Quotes has been turned off."]];
       	//[alertSheet setInformativeText:@"Smart Quotes is incompatible with the U.S. - International keyboard layout and has been turned off."];
		//[alertSheet runModal];
		[self setShouldUseSmartQuotes:NO];
	} 
}
*/


//	delegate method of NSTextStorage sent after change is made but before any processing is done to the mutable attributed string
//	if a smart quote (') is sandwiched between two letters, substitute an apostrophe if it isn't one already (as in English)
//	this is because we can't determine if the user meant apostrophe or smart quote (e.g. guillemet) until the next character is entered
//	another explanation:
//	user might have typed an apostrophe that Bean made into a smart quote, but it really should have been an apostrophe
//	example >>Wie geht>ts?<< should become >>Wie geht's?<<
//	note: doesn't catch case of final apostrophe
- (void)textStorageWillProcessEditing:(NSNotification *)aNotification
{
	int quoteTag = [self smartQuotesStyleTag];
	// types of smart quotes where this can happen (ignore others which already use 'apostrophe' for smart quote)
	if ([self shouldUseSmartQuotes] && quoteTag > 2 && quoteTag < 7)
	{

		int rLoc = [[self firstTextView] selectedRange].location;
		int rLen = [[self firstTextView] selectedRange].length;
		int tLen = [textStorage length];
			
		if (rLoc - 1 < tLen && rLoc > 0 && tLen > 2) // prevent out of bounds; rLoc > 0 added 10 Sept 2007 JH 
		{
			unichar q = [[textStorage string] characterAtIndex:rLoc - 1];
			//smart quote characters that might actually need to be apostrophes
			if ((q == 0x201D && quoteTag==3) //double high 9 
						|| (q == 0x2039 && quoteTag==4) //left pointing single guillemet
						|| (q == 0x203A && quoteTag==5) //right pointing single guillemet
						|| (q == 0x2018 && quoteTag==6)) //single high 6
			{
				//if (rLoc > 0) //prevent out of bounds //moved to previous if statement
				{
					//string version of this mutable attributed class
					NSString *s = nil;
					s = [textStorage string];
					
					unichar p = [s characterAtIndex:rLoc - 2];
					//if previous character was alphanumeric
					if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:p])
					{
						if (rLoc + rLen < tLen) //prevent out of bounds
						{
							unichar f = [s characterAtIndex:rLoc ];
							{
								//if following character is alphanumeric
								if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:f])
								{
									//substitute an apostrophe for the smart quote
									[textStorage replaceCharactersInRange:NSMakeRange(rLoc - 1, 1) 
												withAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%C", 0x2019]
												attributes:oldAttributes] ];
								}
							}
						}
					}
					s = nil;
				}
			}
			q = nil;
		}	
	}
}


#pragma mark -
#pragma mark ---- Accessors ----
// ******************* Accessors ********************

- (JHLayoutManager *)layoutManager {
	return layoutManager;
}

- (KBWordCountingTextStorage *)textStorage {
	return textStorage;
}

- (NSTextView *)firstTextView {
	return [layoutManager firstTextView];
}

-(void)setCurrentFileType:(NSString*)typeName {
	[typeName retain];
	[currentFileType release];
	currentFileType = typeName;
}

-(NSString *)currentFileType {
	return currentFileType;
}

-(void)setOriginalFileName:(NSString*)aFileName {
	[aFileName retain];
	[originalFileName release];
	originalFileName = aFileName;
}

-(NSString *)originalFileName {
	return originalFileName;
}

- (void)setBackgroundColor:(NSColor *)color {
	NSColor *aBackgroundColor;
	[color retain];
	[aBackgroundColor release];
	aBackgroundColor = color;
	// background color of all text views
	NSArray *textContainers = [[self layoutManager] textContainers];
	NSEnumerator *e = [textContainers objectEnumerator];
	NSTextView *tv;
	while (tv = [e nextObject])
		[tv setBackgroundColor:aBackgroundColor];
}

- (void)setTextViewTextColor:(NSColor*)aColor {
	[aColor retain];
	[textViewTextColor release];
	textViewTextColor = aColor;
}

- (void)setTextViewBackgroundColor:(NSColor*)aColor {
	[aColor retain];
	[textViewBackgroundColor release];
	textViewBackgroundColor = aColor;
}

-(NSColor *)textViewTextColor {
	return textViewTextColor;
}

-(NSColor *)textViewBackgroundColor {
	return textViewBackgroundColor;
}

- (void)setViewWidth:(float)width
{
	viewWidth = width;
}

- (float)viewWidth
{
	return viewWidth;
}

- (void)setViewHeight:(float)height
{
	viewHeight = height;
}

- (float)viewHeight
{
	return viewHeight;
}

- (BOOL)isFloating {
	return isFloating;
}

- (void)setFloating:(BOOL)flag {
	isFloating = flag;
}

- (BOOL)shouldUseAltTextColors {
	return shouldUseAltTextColors;
}

- (void)setShouldUseAltTextColors:(BOOL)flag {
	shouldUseAltTextColors = flag;
	if ([self hasMultiplePages]) {
		PageView *pageView = [theScrollView documentView];
		[pageView setShouldUseAltTextColors:flag];
		[pageView setTextViewBackgroundColor:[self textViewBackgroundColor]];
		[pageView setNeedsDisplay:YES];
	}
}

- (BOOL)restoreAltTextColors {
	return restoreAltTextColors;
}

- (void)setRestoreAltTextColors:(BOOL)flag {
	restoreAltTextColors = flag;
}

- (BOOL)restoreShowInvisibles {
	return restoreShowInvisibles;
}

- (void)setRestoreShowInvisibles:(BOOL)flag {
	restoreShowInvisibles = flag;
}

- (BOOL)shouldDoLiveWordCount {
	return shouldDoLiveWordCount;
}

- (void)setShouldDoLiveWordCount:(BOOL)flag {
	shouldDoLiveWordCount = flag;
}

-(BOOL)hasMultiplePages {
	return hasMultiplePages;
}

-(void)setHasMultiplePages:(BOOL)flag {
	hasMultiplePages = flag;
}

-(BOOL)isRTFForWord {
	return isRTFForWord;
}

-(void)setIsRTFForWord:(BOOL)flag {
	isRTFForWord = flag;
}

-(float)pageSeparatorLength {
	return 15.0;
}

- (BOOL)areRulersVisible {
	return areRulersVisible;
}

- (void)setAreRulersVisible:(BOOL)flag {
	areRulersVisible = flag;
}

- (BOOL)isTerminatingGracefully {
	return isTerminatingGracefully;
}

- (void)setIsTerminatingGracefully:(BOOL)flag {
	isTerminatingGracefully = flag;
}

- (BOOL)isTransientDocument {
	return isTransientDocument;
}

- (void)setIsTransientDocument:(BOOL)flag {
	isTransientDocument = flag;
}

- (BOOL)shouldRestorePageViewAfterPrinting {
	return shouldRestorePageViewAfterPrinting;
}

- (void)setShouldRestorePageViewAfterPrinting:(BOOL)flag {
	shouldRestorePageViewAfterPrinting = flag;
}

- (BOOL)shouldShowHorizontalScroller {
	return shouldShowHorizontalScroller;
}

- (void)setShouldShowHorizontalScroller:(BOOL)flag {
	shouldShowHorizontalScroller = flag;
}

- (BOOL)isDirty {
	return isDirty;
}

- (void)setDocEdited:(BOOL)flag {
	[docWindow setDocumentEdited:flag];
	/*
	close window button does close window even when dirty dot is showing, e.g. 
	after change of encoding variable (i.e. when no actual change to
	text object is ocurring). Grrr! So implementing an 'isDirty' flag.
	*/
	isDirty = flag;
}

- (BOOL)createDatedBackup {
	return createDatedBackup;
}

//	is YES when automaticBackup=YES keyword is found in keywords of document
- (void)setCreateDatedBackup:(BOOL)flag {
	createDatedBackup = flag;
}

- (BOOL)needsDatedBackup {
	return needsDatedBackup;
}

//	is YES when automaticBackup=YES keyword is found in keywords of document
- (void)setNeedsDatedBackup:(BOOL)flag {
	needsDatedBackup = flag;
}

- (BOOL)doAutosave {
	return doAutosave;
}

- (void)setDoAutosave:(BOOL)flag {
	doAutosave = flag;
}

- (BOOL)shouldCheckForGraphics {
	return shouldCheckForGraphics;
}

- (void)setShouldCheckForGraphics:(BOOL)flag {
	shouldCheckForGraphics = flag;
}

- (BOOL)showMarginsGuide {
	return showMarginsGuide;
}

-(NSDictionary *)oldAttributes {
	return oldAttributes;
}
- (void)setOldAttributes:(NSDictionary*)someAttributes {
	[someAttributes retain];
	[oldAttributes release];
	oldAttributes = someAttributes;
}

//	saves HFSFileAttributes so they can be written back after file is saved
-(NSDictionary *)hfsFileAttributes {
	return hfsFileAttributes;
}
- (void)setHfsFileAttributes:(NSDictionary*)newAttributes {
	[newAttributes retain];
	[hfsFileAttributes release];
	hfsFileAttributes = newAttributes;
}

//	we need this accessor in MyDocument to track this because similar pageView accessor is destroyed when pageView is destroyed during switch to continuous textview
- (void)setShowMarginsGuide:(BOOL)flag {
	showMarginsGuide = flag;
}

- (BOOL)shouldForceInspectorUpdate {
	return shouldForceInspectorUpdate;
}

- (void)setShouldForceInspectorUpdate:(BOOL)flag {
	shouldForceInspectorUpdate = flag;
}
	
-(void)isCentimetersOrInches {
	//use Inches as object
	NSString *measurementUnits = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleMeasurementUnits"];	
	if ([@"Inches" isEqual:measurementUnits])
	{
		//	72 points per inch
		[self setPointsPerUnitAccessor:72.0];
		[tabStopValueLabel setObjectValue:NSLocalizedString(@"(Inches from left margin)", @"(Inches from left margin)")];	
	}
	else
	{
		//	28.35 points per cm (NOTE: RTF uses twips, and 20 twips = 1 point)
		[self setPointsPerUnitAccessor:28.35];
		[tabStopValueLabel setObjectValue:NSLocalizedString(@"(Centimeters from left margin)", @"(Centimeters from left margin)")];	
	}
}

- (float)pointsPerUnitAccessor {
	return pointsPerUnitAccessor;
}

- (void)setPointsPerUnitAccessor:(float)points {
	pointsPerUnitAccessor = points;
}

- (BOOL)isDocumentSaved {
	return isDocumentSaved;
}

- (void)setIsDocumentSaved:(BOOL)flag {
	isDocumentSaved = flag;
}
	
- (BOOL)isLossy {
	return isLossy;
}

- (void)setLossy:(BOOL)flag {
	isLossy = flag;
}

- (void)setLineFragPosYSave:(int)lineFragPosY
{
	lineFragPosYSave = lineFragPosY;
}

- (float)lineFragPosYSave
{
	return lineFragPosYSave;
}

//from Text Edit
- (void)setFileModDate:(NSDate *)date {
	if (![date isEqualTo:fileModDate]) {
		[fileModDate autorelease];
		fileModDate = [date copy];
	}
}

- (NSDate *)fileModDate {
	return fileModDate;
}

- (BOOL)readOnlyDoc {
	return readOnlyDoc;
}

//	if stationary pad finder bit is YES, make it not editable
- (void)setReadOnlyDoc:(BOOL)flag {
	[[self firstTextView] setEditable:!flag];
	readOnlyDoc = flag;
}

- (void)setDocEncoding:(unsigned int)newDocEncoding
{
	docEncoding = newDocEncoding;
}

- (unsigned int)docEncoding
{
	return docEncoding;
}

-(void)setDocEncodingString:(NSString*)anEncodingString {
	[anEncodingString retain];
	[docEncodingString release];
	docEncodingString = anEncodingString;
}

-(NSString *)docEncodingString {
	return docEncodingString;
}

- (void)setShouldConstrainScroll:(BOOL)toConstrainScrollOrNotToConstrainScroll
{
	shouldConstrainScroll = toConstrainScrollOrNotToConstrainScroll;
}

- (BOOL)shouldConstrainScroll
{
	return shouldConstrainScroll;
}

- (void)setSavedEditLocation:(unsigned int)editLocationToSave
{
	savedEditLocation = editLocationToSave;
}

- (unsigned int)savedEditLocation
{
	return savedEditLocation;
}

- (BOOL)shouldUseSmartQuotes {
	return shouldUseSmartQuotes;
}

- (void)setShouldUseSmartQuotes:(BOOL)flag {
	shouldUseSmartQuotes = flag;
}

- (BOOL)registerUndoThroughShouldChange {
	return registerUndoThroughShouldChange;
}

- (void)setRegisterUndoThroughShouldChange:(BOOL)flag {
	registerUndoThroughShouldChange = flag;
}

//	autosaves document only if changes have been maded since last autosave (this is the accessor)
- (BOOL)needsAutosave {
	return needsAutosave;
}

- (void)setNeedsAutosave:(BOOL)flag {
	needsAutosave = flag;
}

//	holds original size values for image
- (NSSize)imageSize {
	return imageSize;
}

- (void)setImageSize:(NSSize)size {
	imageSize = size;
}

- (void)setSmartQuotesStyleTag:(unsigned int)theTag
{
	smartQuotesStyleTag = theTag;
}

- (unsigned int)smartQuotesStyleTag
{
	return smartQuotesStyleTag;
}

- (void)setLinkPrefixTag:(unsigned int)theTag
{
	linkPrefixTag = theTag;
}

- (unsigned int)linkPrefixTag
{
	return linkPrefixTag;
}

//	this is just a generic header for sections and methods - copy and paste!
/*
#pragma mark -
#pragma mark ---- Styles: Copy, Paste, Select ----

// ******************** Styles copy and paste methods *******************
*/

@end

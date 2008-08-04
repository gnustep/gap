/*
 Subclass: PrefWindowController.m
 Controls default font and text color changes in the preferences window

 Created 11 JUL 2006.
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


#import "PrefWindowController.h"

#define RICH_TEXT_IS_TARGET YES
#define PLAIN_TEXT_IS_TARGET NO

@implementation PrefWindowController

#pragma mark -
#pragma mark ---- Init, awakeFromNib Methods ----
//revised 17 DEC 2006 bh JH

+ (void)initialize
{
	self = [super init];
	//the path points to a plist file inside the app's resource folder that has factory defaults
	NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
	//create a dictionary containing the defaults
	NSDictionary *theDefaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
	if (theDefaults) {
		//register them with NSUserDefaults
		[[NSUserDefaults standardUserDefaults] registerDefaults:theDefaults];
		//tell the controller they are the initial values (for first launch of app)
		[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:theDefaults];
		//apply preference settings immediately, without a 'save' button (won't apply to open docs, though)
		[[NSUserDefaultsController sharedUserDefaultsController] setAppliesImmediately:YES];
	}
}

//	automatically a shared instance?
/*
+(PrefWindowController*)sharedInstance
{
	return sharedInstance ? sharedInstance : [[self alloc] init];
}

-(id)init {
	if (sharedInstance) {
		[self dealloc];
	}
	else {
		sharedInstance = [super init];
	}
	return sharedInstance;
}
*/

- (void)awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//show the alternate colors in the example text field, if we're using them
	if ([defaults boolForKey:@"prefUseAltColors"])
	{
		[richTextColorTextField setTextColor:[altTextColorWell color]];
		[richTextColorTextField setBackgroundColor:[altBackgroundColorWell color]];
		[plainTextColorTextField setTextColor:[altTextColorWell color]];
		[plainTextColorTextField setBackgroundColor:[altBackgroundColorWell color]];
	}
	//load rich text font's displayName and size into label from prefs
	[richTextFontNameField setStringValue:[NSString stringWithFormat:@"%@ %@ pt.", 
			[[NSFont fontWithName:[defaults objectForKey:@"prefRichTextFontName"]
			size:[defaults floatForKey:@"prefRichTextFontSize"]] displayName],
			[defaults stringForKey:@"prefRichTextFontSize"]]];
	//load plain text font's displayName and size into label from prefs
	[plainTextFontNameField setStringValue:[NSString stringWithFormat:@"%@ %@ pt.", 
			[[NSFont fontWithName:[defaults objectForKey:@"prefPlainTextFontName"]
			size:[defaults floatForKey:@"prefPlainTextFontSize"]] displayName],
			[defaults stringForKey:@"prefPlainTextFontSize"]]];
	
	//is system preference set to metric or U.S. units?
	NSString *measurementUnits = [defaults objectForKey:@"AppleMeasurementUnits"];

	//update the units label in the defaults pane of Preferences
	//this value can change in convertUnits method; it is not dependent on the system defaults and can be set independently 
	if ([defaults boolForKey:@"prefIsMetric"])
	{
		[defaultUnitsTextField setObjectValue:NSLocalizedString(@"(centimeters)", @"(centimeters)")];
	}
	else
	{
		[defaultUnitsTextField setObjectValue:NSLocalizedString(@"(inches)", @"(inches)")];
	}
	
	//set initial values for defaults from user defaults
	[defaultFirstLineIndentTextField setFloatValue:[defaults floatForKey:@"prefDefaultFirstLineIndent"]];
	[defaultFirstLineIndentStepper setFloatValue:[defaults floatForKey:@"prefDefaultFirstLineIndent"]];
	[defaultTopMarginTextField setFloatValue:[defaults floatForKey:@"prefDefaultTopMargin"]];
	[defaultLeftMarginTextField setFloatValue:[defaults floatForKey:@"prefDefaultLeftMargin"]];
	[defaultRightMarginTextField setFloatValue:[defaults floatForKey:@"prefDefaultRightMargin"]];
	[defaultBottomMarginTextField setFloatValue:[defaults floatForKey:@"prefDefaultBottomMargin"]];
	
	//accessor: do OS X system preferences indicate metric or US units as the current user preference?
	if ([@"Inches" isEqual:measurementUnits]) 
		{ [self setIsMetric:NO]; }
	else 
		{ [self setIsMetric:YES]; }

	//if system pref is metric but loaded values are not, convert them to metric
	if ([self isMetric] && ![defaults boolForKey:@"prefIsMetric"])
	{
		[defaultIsMetric setState:NSOnState];
		[self convertToMetric];
		[self applyChangesAction:nil];
	}
	//if system pref is U.S. units but loaded values are metric, convert them to U.S. units
	if (![self isMetric] && [defaults boolForKey:@"prefIsMetric"])
	{
		[defaultIsMetric setState:NSOffState];
		[self convertToUS];
		[self applyChangesAction:nil];
	}
	
	//get names of possible file formats and load them into popup button in general pane
	NSArray *docTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDocumentTypes"];
	NSMutableDictionary *docType = nil;
	NSEnumerator *enumerator = [docTypes objectEnumerator];
	[defaultSaveFormatPopupButton removeAllItems];
	while (docType = [enumerator nextObject])
	{
		NSString *formatName = nil;
		formatName = [docType valueForKey: @"CFBundleTypeName"];
		//Web Page (.html) is Viewer only (not Editor), so it's omitted from list by Cocoa
		if ([[docType valueForKey: @"CFBundleTypeRole"] isEqualToString:@"Editor"] && formatName)
		{
			[defaultSaveFormatPopupButton addItemWithTitle:NSLocalizedString(formatName, @"localization for file type name from infoplist.strings")];
		}
		docType = nil;
		formatName = nil;
	}
	int formatIndex = nil;
	//this binding is done manually since we create the popup's items from scratch
	formatIndex = [[defaults objectForKey:@"prefDefaultSaveFormatIndex"] intValue];
	//select item based on saved user defaults
	if (formatIndex < [docTypes count])
	{
		[defaultSaveFormatPopupButton selectItemAtIndex:formatIndex];
	}
}

#pragma mark -
#pragma mark ---- Change and View Default Font Methods ----

//this action calls up the font panel
- (IBAction)changeFontAction:(id)sender {
	NSString *fontName;
	int fontSize;
	//get font name and size from user defaults
	NSDictionary *values = [[NSUserDefaultsController sharedUserDefaultsController] values];
	if ([sender tag]==0) { //==rich text
		fontName = [values valueForKey:@"prefRichTextFontName"];
		fontSize = [[values valueForKey:@"prefRichTextFontSize"] floatValue];
		//this determines what target is of fontManager font change
		[self setRichOrPlain:RICH_TEXT_IS_TARGET];
	} else { //tag==1==plain text
		fontName = [values valueForKey:@"prefPlainTextFontName"];
		fontSize = [[values valueForKey:@"prefPlainTextFontSize"] floatValue];
		[self setRichOrPlain:PLAIN_TEXT_IS_TARGET];
	}
	//create NSFont from name and size; initialize font panel with it
    NSFont *font = [NSFont fontWithName:fontName size:fontSize];
	//on error, set to default system font
	if (font == nil) font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
	//set window as firstResponder so we get changeFont: messages
	[prefWindow makeFirstResponder:prefWindow];
	[[NSFontManager sharedFontManager] setSelectedFont:font isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}

//method called by font panel when a new font is selected
- (IBAction)changeFont:(id)sender
{
	NSString *ptString = NSLocalizedString(@"pt.", @"name of 'points' unit to indicate size unit of fonts in fonts Preferences pane");
	//get selected font
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFont *selectedFont = [fontManager selectedFont];
	if (selectedFont == nil)
		selectedFont = [NSFont systemFontOfSize:[NSFont systemFontSize]]; //default on error
	NSFont *panelFont = [fontManager convertFont:selectedFont];
	//get and store details of selected font
	NSNumber *fontSize = [NSNumber numberWithFloat:[panelFont pointSize]];	
	id defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];
	//rich text if target of changeFont action
	if ([self richOrPlain]==RICH_TEXT_IS_TARGET) {
		//save font into user defaults
		[defaults setValue:[panelFont fontName] forKey:@"prefRichTextFontName"];
		[defaults setValue:fontSize forKey:@"prefRichTextFontSize"];
		//show a label for the rich text font
		[richTextFontNameField setStringValue:[NSString stringWithFormat:@"%@ %.0f %@", 
				[panelFont displayName], [panelFont pointSize], ptString]];
	}
	//plain text is target of changeFont action
	else { 
		//save font into user defaults
		[defaults setValue:[panelFont fontName] forKey:@"prefPlainTextFontName"];
		[defaults setValue:fontSize forKey:@"prefPlainTextFontSize"];
		//show a label for the plain text font
		[plainTextFontNameField setStringValue:[NSString stringWithFormat:@"%@ %.0f %@",
				[panelFont displayName], [panelFont pointSize], ptString]];
	}
	ptString = nil;
}

#pragma mark -
#pragma mark ---- Misc Other Methods ----

//called by change of color wells
- (IBAction) changeColorExampleAction:(id)sender
{
	//foreground
	if ([sender tag]==0) {
		[richTextColorTextField setTextColor:[sender color]];
		[plainTextColorTextField setTextColor:[sender color]];
	}
	//background
	else {
		[richTextColorTextField setBackgroundColor:[sender color]];
		[plainTextColorTextField setBackgroundColor:[sender color]];
	}
	[prefWindow makeFirstResponder:sender];
}

//called when user chooses alternate colors as default; sets the example field colors
- (IBAction) useAltColorsAction:(id)sender
{
	//not using alternate colors
	if ([sender state]==0) {
		[richTextColorTextField setTextColor:[NSColor blackColor]];
		[richTextColorTextField setBackgroundColor:[NSColor whiteColor]];
		[plainTextColorTextField setTextColor:[NSColor blackColor]];
		[plainTextColorTextField setBackgroundColor:[NSColor whiteColor]];
	} 
	//use alternate colors
	else { 
		[richTextColorTextField setTextColor:[altTextColorWell color]];
		[richTextColorTextField setBackgroundColor:[altBackgroundColorWell color]];
		[plainTextColorTextField setTextColor:[altTextColorWell color]];
		[plainTextColorTextField setBackgroundColor:[altBackgroundColorWell color]];
	}
}

-(IBAction)applyChangesAction:(id)sender
{
	//this causes text fields with uncommited edits to try to validate them before focus leaves them 
	[[self window] makeFirstResponder:[self window]];
	//input in text fields was validated, because focus left them and was put on window, so save defaults
	if ([[self window] firstResponder] == [self window])
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSNumber *firstLineIndent = [NSNumber numberWithFloat:[defaultFirstLineIndentTextField floatValue]];
		[defaults setObject:firstLineIndent forKey:@"prefDefaultFirstLineIndent"];
		NSNumber *topMargin = [NSNumber numberWithFloat:[defaultTopMarginTextField floatValue]];
		[defaults setObject:topMargin forKey:@"prefDefaultTopMargin"];
		NSNumber *leftMargin = [NSNumber numberWithFloat:[defaultLeftMarginTextField floatValue]];
		[defaults setObject:leftMargin forKey:@"prefDefaultLeftMargin"];
		NSNumber *rightMargin = [NSNumber numberWithFloat:[defaultRightMarginTextField floatValue]];
		[defaults setObject:rightMargin forKey:@"prefDefaultRightMargin"];
		NSNumber *bottomMargin = [NSNumber numberWithFloat:[defaultBottomMarginTextField floatValue]];
		[defaults setObject:bottomMargin forKey:@"prefDefaultBottomMargin"];
		NSNumber *boolMetric = [NSNumber numberWithBool:[defaultIsMetric state]];
		//force save of this bool because otherwise it is not updated soon enough by bindings for when MyDocument
		//			needs it after conversion of units
		[defaults setObject:boolMetric forKey:@"prefIsMetric"];
		[applyChangesButton setEnabled:NO];
	}
	//otherwise, user will hear a beep and cursor will stay focused in field that needs better input 
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	//enables the 'save changes' button when there has been a change made to the textfields in the defaults preference panes
	[applyChangesButton setEnabled:YES];
}

- (IBAction)enableChangeButtonAction:(id)sender
{
	//20 June 2007 added because you could change firstLineIndent amount using stepper and never be prompted to save changes
	//defaultFirstLineIndentTextField is now tied to prefDefaultFirstLineIndent also
	//enables the 'save changes' button when there has been a change made to the textfields in the defaults preference panes
	[applyChangesButton setEnabled:YES];
}


-(void)convertToMetric
{
	float toMetric = 72.0 / 28.35;
	[defaultUnitsTextField setObjectValue:NSLocalizedString(@"(centimeters)", @"(centimeters)")];
	[defaultTopMarginTextField setFloatValue:[defaultTopMarginTextField floatValue] * toMetric];
	[defaultLeftMarginTextField setFloatValue:[defaultLeftMarginTextField floatValue] * toMetric];
	[defaultRightMarginTextField setFloatValue:[defaultRightMarginTextField floatValue] * toMetric];
	[defaultBottomMarginTextField setFloatValue:[defaultBottomMarginTextField floatValue] * toMetric];
	[defaultFirstLineIndentTextField setFloatValue:[defaultFirstLineIndentTextField floatValue] * toMetric];
	[defaultFirstLineIndentStepper setFloatValue:[defaultFirstLineIndentStepper floatValue] * toMetric];
}

-(void)convertToUS
{
	 float toUS = 28.35 / 72.0;
	 [defaultUnitsTextField setObjectValue:NSLocalizedString(@"(inches)", @"(inches)")];
	 [defaultTopMarginTextField setFloatValue:[defaultTopMarginTextField floatValue] * toUS];
	 [defaultLeftMarginTextField setFloatValue:[defaultLeftMarginTextField floatValue] * toUS];
	 [defaultRightMarginTextField setFloatValue:[defaultRightMarginTextField floatValue] * toUS];
	 [defaultBottomMarginTextField setFloatValue:[defaultBottomMarginTextField floatValue] * toUS];
	 [defaultFirstLineIndentTextField setFloatValue:[defaultFirstLineIndentTextField floatValue] * toUS];
	 [defaultFirstLineIndentStepper setFloatValue:[defaultFirstLineIndentStepper floatValue] * toUS];
}

-(IBAction)useMetricAction:(id)sender
{
	//state of button has already changed at this point, so change units to match state of button!`1q2
	if ([defaultIsMetric state]==NSOffState) [self convertToUS];
	else [self convertToMetric];
	[self applyChangesAction:nil];
}

- (IBAction)closeAction:(id)sender
{
	[prefWindow performClose:nil];
}

-(IBAction)selectDefaultSaveFormatAction:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber *theIndex = nil;
	theIndex = [NSNumber numberWithInt:[defaultSaveFormatPopupButton indexOfItem:[defaultSaveFormatPopupButton selectedItem]]];
	[defaults setValue:theIndex forKey:@"prefDefaultSaveFormatIndex"];
}

//indicates whether richText example or plainText example is the target of a changeFont action
- (BOOL)richOrPlain {
	return richOrPlain;
}

- (void)setRichOrPlain:(BOOL)flag {
	richOrPlain = flag;
}

//defaults use metric or U.S. units?
- (BOOL)isMetric {
	return isMetric;
}

- (void)setIsMetric:(BOOL)flag {
	isMetric = flag;
}


@end

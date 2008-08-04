/*
  InspectorController.m
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

#import "InspectorController.h"

@implementation InspectorController

#pragma mark -
#pragma mark ---- Shared Instance, Init, Dealloc ----

+ (id)sharedInspectorController
{
    static InspectorController *_sharedInspectorController = nil;

    if (!_sharedInspectorController) {
        _sharedInspectorController = [[InspectorController alloc] init];
    }
    return _sharedInspectorController;
}

- (id)init
{
    self = [self initWithWindowNibName:@"Inspector"];
    if (self) {
        needsUpdate = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark -
#pragma mark ---- Window Controller Methods ----

- (void)setMainWindow:(NSWindow *)mainWindow
{
    NSWindowController *controller = [mainWindow windowController];
	//un-enables the inspector controls while no doc is open
    if (controller && [controller isKindOfClass:[NSWindowController class]]) {
        _inspectingTextView = [(NSWindowController *)controller document]; 
    } else {
        _inspectingTextView = nil;
	    [self updateInspector:nil theRightMarginValueToIndentFrom:0.0 isReadOnly:NO];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self setMainWindow:[NSApp mainWindow]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowResigned:) name:NSWindowDidResignMainNotification object:nil];
	//so inspector won't disappear behind main window
	[(NSPanel *)[self window] setFloatingPanel:YES];
    //so inspector won't steal focus from main window
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
	//saves the inspector panel's position for positioning at startup
	[self setWindowFrameAutosaveName:@"SpacingInspector"];
}

- (void)mainWindowChanged:(NSNotification *)notification
{
	[self setMainWindow:[notification object]];
}

- (void)mainWindowResigned:(NSNotification *)notification
{
    [self setMainWindow:nil];
}

#pragma mark -
#pragma mark ---- Update Inspector ----

- (void)updateInspector:(NSDictionary *)theAttributes theRightMarginValueToIndentFrom:(float)theRightMarginValue isReadOnly:(BOOL)isReadOnly
{
/*
This method udpates the Inspector to reflect the values of either the typing attributes	if no text is selected, or of the first character of the first range of selected text
Note: we un-enable controls (but still show values) if isReadOnly 11 Oct 2007 JH 
*/
	//if no values for text, reflect that
	if (!theAttributes)
	{
		[characterSpacingSlider setEnabled:NO];
		[characterSpacingTextField setEnabled:NO];
	    [characterSpacingStepper setEnabled:NO];
		[characterSpacingSlider setIntValue:0];
		[characterSpacingStepper setIntValue:0];
		[characterSpacingTextField setStringValue:@" "];
		[characterSpacingDefaultButton setEnabled:NO];
		[multipleSpacingSlider setEnabled:NO];
		[multipleSpacingStepper setEnabled:NO];
		[multipleSpacingTextField setEnabled:NO];
		[multipleSpacingSlider setIntValue:0];
		[multipleSpacingStepper setIntValue:0];
		[multipleSpacingTextField setObjectValue:@" "];
		[multipleSpacingDefaultButton setEnabled:NO];
		[interlineSpacingSlider setEnabled:NO];
		[interlineSpacingStepper setEnabled:NO];
		[interlineSpacingTextField setEnabled:NO];
		[interlineSpacingSlider setIntValue:0];
		[afterParagraphSpacingStepper setIntValue:0];
		[afterParagraphSpacingTextField setObjectValue:@" "];
		[afterParagraphSpacingSlider setEnabled:NO];
		[afterParagraphSpacingStepper setEnabled:NO];
		[afterParagraphSpacingTextField setEnabled:NO];
		[afterParagraphSpacingSlider setIntValue:0];
		[afterParagraphSpacingStepper setIntValue:0];
		[afterParagraphSpacingTextField setObjectValue:@" "];
		[beforeParagraphSpacingSlider setEnabled:NO];
		[beforeParagraphSpacingStepper setEnabled:NO];
		[beforeParagraphSpacingTextField setEnabled:NO];
		[beforeParagraphSpacingSlider setIntValue:0];
		[beforeParagraphSpacingStepper setIntValue:0];
		[beforeParagraphSpacingTextField setObjectValue:@" "];
		[firstLineIndentTextField setEnabled:NO];
		[firstLineIndentStepper setEnabled:NO];
		[firstLineIndentTextField setObjectValue:@" "];
		[firstLineIndentStepper setIntValue:0];
		[headIndentTextField setEnabled:NO];
		[headIndentStepper setEnabled:NO];
		[headIndentTextField setObjectValue:@" "];
		[headIndentStepper setIntValue:0];
		[tailIndentTextField setEnabled:NO];
		[tailIndentStepper setEnabled:NO];
		[tailIndentTextField setObjectValue:@" "];
		[tailIndentStepper setIntValue:0];
		[alignmentLeftButton setEnabled:NO];
		[alignmentRightButton setEnabled:NO];
		[alignmentCenterButton setEnabled:NO];
		[alignmentJustifyButton setEnabled:NO];
		[minLineHeightTextField setEnabled:NO];
		[maxLineHeightTextField setEnabled:NO];
		[minLineHeightStepper setEnabled:NO];
		[maxLineHeightStepper setEnabled:NO];
		[highlightYellowButton setEnabled:NO];
		[highlightOrangeButton setEnabled:NO];
		[highlightPinkButton setEnabled:NO];
		[highlightBlueButton setEnabled:NO];
		[highlightGreenButton setEnabled:NO];
		[highlightRemoveButton setEnabled:NO];
		[forceLineHeightDefaultButton setEnabled:NO];
	}
	//get paragraph attribute values from dictionary passed from MyDocument
	else
	{
		//NSParagraphStyle stores all 'attributes' dealing with font and paragraph 
		NSParagraphStyle *theCurrentStyle = [theAttributes objectForKey:NSParagraphStyleAttributeName];
		
		//for MULTIPLE LINE HEIGHTS
		NSNumber *theMultipleValue;
		theMultipleValue = [NSNumber numberWithFloat:[theCurrentStyle lineHeightMultiple]];
		//avoid float and it's 'errors'
		if ([theCurrentStyle lineHeightMultiple]==0) theMultipleValue = [NSNumber numberWithInt:0];
		[multipleSpacingSlider setEnabled:YES];
		[multipleSpacingStepper setEnabled:YES];
		[multipleSpacingTextField setEnabled:YES];
		[multipleSpacingDefaultButton setEnabled:YES];
		//set control values
		[multipleSpacingSlider setObjectValue:theMultipleValue];
		[multipleSpacingStepper setObjectValue:theMultipleValue];
		[multipleSpacingTextField setObjectValue:theMultipleValue];
		
		//for LEADING (inter-line spacing)
		NSNumber *theInterlineValue;
		theInterlineValue = [NSNumber numberWithFloat:[theCurrentStyle lineSpacing]];
		//avoid float and it's 'errors'
		if ([theCurrentStyle lineSpacing]==0) theInterlineValue = [NSNumber numberWithInt:0]; 
		[interlineSpacingSlider  setEnabled:YES];
		[interlineSpacingStepper  setEnabled:YES];
		[interlineSpacingTextField  setEnabled:YES];
		[interlineSpacingSlider setObjectValue:theInterlineValue];
		[interlineSpacingStepper setObjectValue:theInterlineValue];
		[interlineSpacingTextField setObjectValue:theInterlineValue];
	
		//for AFTER PARAGRAPH SPACING
		//this is totally separate from the MULTIPLE LINE HEIGHT attribute
		NSNumber *theAfterParagraphSpacingValue;
		theAfterParagraphSpacingValue = [NSNumber numberWithFloat:[theCurrentStyle paragraphSpacing]];
		//avoid float and it's 'errors'
		if ([theCurrentStyle paragraphSpacing]==0) theAfterParagraphSpacingValue = [NSNumber numberWithInt:0];
		[afterParagraphSpacingSlider  setEnabled:YES];
		[afterParagraphSpacingStepper  setEnabled:YES];
		[afterParagraphSpacingTextField  setEnabled:YES];
		[afterParagraphSpacingSlider setObjectValue:theAfterParagraphSpacingValue];
		[afterParagraphSpacingStepper setObjectValue:theAfterParagraphSpacingValue];
		[afterParagraphSpacingTextField setObjectValue:theAfterParagraphSpacingValue];
		
		//for BEFORE PARAGRAPH SPACING
		//this is totally separate from the MULTIPLE LINE HEIGHT attribute
		NSNumber *theBeforeParagraphSpacingValue;
		theBeforeParagraphSpacingValue = [NSNumber numberWithFloat:[theCurrentStyle paragraphSpacingBefore]];
		//avoid float and it's 'errors'
		if ([theCurrentStyle paragraphSpacingBefore]==0) theBeforeParagraphSpacingValue = [NSNumber numberWithInt:0]; 
		[beforeParagraphSpacingSlider  setEnabled:YES];
		[beforeParagraphSpacingStepper  setEnabled:YES];
		[beforeParagraphSpacingTextField  setEnabled:YES];
		[beforeParagraphSpacingSlider setObjectValue:theBeforeParagraphSpacingValue];
		[beforeParagraphSpacingStepper setObjectValue:theBeforeParagraphSpacingValue];
		[beforeParagraphSpacingTextField setObjectValue:theBeforeParagraphSpacingValue];												

		//indent is in points, so adjust to cm or inches for the controls
		float pointsPerUnit;
		pointsPerUnit = [self pointsPerUnitAccessor];
		
		//for FIRST LINE INDENT for paragraph
		float theFirstLineIndentValue;
		theFirstLineIndentValue = [theCurrentStyle firstLineHeadIndent];
		//avoid float and it's problems
		if ([theCurrentStyle firstLineHeadIndent]==0) theFirstLineIndentValue = 0.0;
		[firstLineIndentTextField setEnabled:YES];
		[firstLineIndentStepper setEnabled:YES];
		[firstLineIndentTextField setFloatValue:theFirstLineIndentValue/pointsPerUnit];
		[firstLineIndentStepper setFloatValue:theFirstLineIndentValue/pointsPerUnit];

		//for HEAD (LEFT) INDENT for paragraph
		float theHeadIndentValue;
		theHeadIndentValue = [theCurrentStyle headIndent];
		//avoid float and it's problems
		if ([theCurrentStyle headIndent]==0) theHeadIndentValue = 0.0;
		[headIndentTextField setEnabled:YES];
		[headIndentStepper setEnabled:YES];
		[headIndentTextField setFloatValue:theHeadIndentValue/pointsPerUnit];
		[headIndentStepper setFloatValue:theHeadIndentValue/pointsPerUnit];

		//for TAIL (RIGHT) INDENT for paragraph
		float theTailIndentValue;
		theTailIndentValue = [theCurrentStyle tailIndent];
		//avoid float and it's problems
		if ([theCurrentStyle tailIndent]==0) theTailIndentValue = 0.0;
		[tailIndentTextField setEnabled:YES];
		[tailIndentStepper setEnabled:YES];
		//	the tail, or right, value is actually the measure in pts that the text extends past the left indent,
		//but our controls show how far from the right margin in inches/cms the text is, so we do some math to 
		//adjust the values to display on the controls
		if (theTailIndentValue==0.0) theTailIndentValue = theRightMarginValue;
		[tailIndentTextField setFloatValue:(theRightMarginValue - theTailIndentValue)/pointsPerUnit];
		[tailIndentStepper setFloatValue:(theRightMarginValue - theTailIndentValue)/pointsPerUnit];

		//for MIN LINE SPACING for paragraph; 0 = no line height limits
		float theMinLineSpacingValue;
		theMinLineSpacingValue = [theCurrentStyle minimumLineHeight];
		//avoid float and it's problems
		if ([theCurrentStyle minimumLineHeight]==0) theMinLineSpacingValue = 0.0;
		[minLineHeightTextField setEnabled:YES];
		[minLineHeightStepper setEnabled:YES];
		[minLineHeightTextField setFloatValue:theMinLineSpacingValue/pointsPerUnit];
		[minLineHeightStepper setFloatValue:theMinLineSpacingValue/pointsPerUnit];
		
		//for MAX LINE SPACING for paragraph; 0 = no line height limits
		float theMaxLineSpacingValue;
		theMaxLineSpacingValue = [theCurrentStyle maximumLineHeight];
		//avoid float and it's problems
		if ([theCurrentStyle maximumLineHeight]==0) theMaxLineSpacingValue = 0.0;
		[maxLineHeightTextField setEnabled:YES];
		[maxLineHeightStepper setEnabled:YES];
		[forceLineHeightDefaultButton setEnabled:YES];
		[maxLineHeightTextField setFloatValue:theMaxLineSpacingValue/pointsPerUnit];
		[maxLineHeightStepper setFloatValue:theMaxLineSpacingValue/pointsPerUnit];
		
		//for paragraph alignment
		[alignmentLeftButton setEnabled:YES];
		[alignmentRightButton setEnabled:YES];
		[alignmentCenterButton setEnabled:YES];
		[alignmentJustifyButton setEnabled:YES];
		int theAlignment = [theCurrentStyle alignment];
		if (theAlignment==0 || theAlignment==4) { //left alignment
			[alignmentLeftButton setBordered:YES];
			[alignmentRightButton setBordered:NO];
			[alignmentCenterButton setBordered:NO];
			[alignmentJustifyButton setBordered:NO];
		} else if (theAlignment==1) { //right alignment
			[alignmentLeftButton setBordered:NO];
			[alignmentRightButton setBordered:YES];
			[alignmentCenterButton setBordered:NO];
			[alignmentJustifyButton setBordered:NO];
		} else if (theAlignment==2) { //centered alignment
			[alignmentLeftButton setBordered:NO];
			[alignmentRightButton setBordered:NO];
			[alignmentCenterButton setBordered:YES];
			[alignmentJustifyButton setBordered:NO];
		} else if (theAlignment==3) { //justified alignment
			[alignmentLeftButton setBordered:NO];
			[alignmentRightButton setBordered:NO];
			[alignmentCenterButton setBordered:NO];
			[alignmentJustifyButton setBordered:YES];
		}
		
		//	for KERNING (character spacing)
		NSNumber *theKernValue = [theAttributes objectForKey:NSKernAttributeName];
		//	adjust to match MyDocument action
		if ([theKernValue floatValue] < 0)
		{
			theKernValue = [NSNumber numberWithFloat:[theKernValue floatValue] * 2];
		}
		
		//adjust kerning value to reflect scale of control settings (0 to 400%; 100% is default)
		[characterSpacingSlider setEnabled:YES];
		[characterSpacingTextField setEnabled:YES];
		[characterSpacingStepper setEnabled:YES];
		[characterSpacingDefaultButton setEnabled:YES];
		//set values for controls from attributes from textView
		[characterSpacingSlider setObjectValue:theKernValue];
		[characterSpacingStepper setObjectValue:theKernValue];
		[characterSpacingTextField setFloatValue:[characterSpacingSlider floatValue]];
		
		//for FONT FAMILY TRAITS (font:styles NSPopupMenu) 
		[fontStylesMenu setEnabled:YES];
		//get the name of the selected font or the font at the insertion point
		NSFont *theFont = [theAttributes objectForKey:NSFontAttributeName];
		//get the name of that font's font family
		NSString *theFamilyName = [theFont familyName];
		//get available fonts within family as 'traits'
		NSArray *theFamilyTraits = [[NSFontManager sharedFontManager] availableMembersOfFontFamily:theFamilyName];
		//each item is a subArray containing displayName, traitName, and two other things
		NSArray *singleTraitArray; 
		//clear the styles menu
		[fontStylesMenu removeAllItems];
		//load the styles menu with available styles
		int index = 0;
		/*
		How this works: we set the attributedTitle of the NSMenuItem to an attributed string representing the name of the NSFont with the NSFontNameAttribute set to the NSFont, so that we can graphically represent the font trait item as well as to pass it through to the action in MyDocument, since [[sender cell] attributedTitle] will identify the font selected
		*/
		if (![theFont displayName]==nil)
		{
			//show current font in text selection in NSPopupButton's cell
			[fontStylesMenu addItemWithTitle:[theFont displayName]];
		}
		else
		{
			//shouldn't happen
			[fontStylesMenu addItemWithTitle:@" "];
		}
		NSEnumerator *e = [theFamilyTraits objectEnumerator];
		while (singleTraitArray = [e nextObject])
		{
			//	second item of availableMemberOfFontFamily is 'trait' name, ex: Italic Bold
			[fontStylesMenu addItemWithTitle:[singleTraitArray objectAtIndex:1]];
			
			//	create an attributed string with name of font and font applied to the string
			NSAttributedString*	fontTraitAttrString = [[[NSAttributedString alloc] initWithString:[singleTraitArray objectAtIndex:1] attributes: [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:[singleTraitArray objectAtIndex:0] size:12], NSFontAttributeName, nil]] autorelease];
			//	set the attributed title to the attributed string
			[[fontStylesMenu itemAtIndex:index + 1] setAttributedTitle:fontTraitAttrString];
			//	the title is overridden by the attributed title; we use it to pass the fontName along to MyDocument
			[[fontStylesMenu itemAtIndex:index + 1] setTitle:[singleTraitArray objectAtIndex:0]];
			index = index + 1;
		}
		[highlightYellowButton setEnabled:YES];
		[highlightOrangeButton setEnabled:YES];
		[highlightPinkButton setEnabled:YES];
		[highlightBlueButton setEnabled:YES];
		[highlightGreenButton setEnabled:YES];
		[highlightRemoveButton setEnabled:YES];		
	}
	//if [MyDocument isReadOnly] then un-enable controls
	if (isReadOnly)
	{
		[fontStylesMenu setEnabled:NO];
		[characterSpacingSlider setEnabled:NO];
		[characterSpacingTextField setEnabled:NO];
	    [characterSpacingStepper setEnabled:NO];
		[characterSpacingDefaultButton setEnabled:NO];
		[multipleSpacingSlider setEnabled:NO];
		[multipleSpacingStepper setEnabled:NO];
		[multipleSpacingTextField setEnabled:NO];
		[multipleSpacingDefaultButton setEnabled:NO];
		[interlineSpacingSlider setEnabled:NO];
		[interlineSpacingStepper setEnabled:NO];
		[interlineSpacingTextField setEnabled:NO];
		[afterParagraphSpacingSlider setEnabled:NO];
		[afterParagraphSpacingStepper setEnabled:NO];
		[afterParagraphSpacingTextField setEnabled:NO];
		[beforeParagraphSpacingSlider setEnabled:NO];
		[beforeParagraphSpacingStepper setEnabled:NO];
		[beforeParagraphSpacingTextField setEnabled:NO];
		[firstLineIndentTextField setEnabled:NO];
		[firstLineIndentStepper setEnabled:NO];
		[headIndentTextField setEnabled:NO];
		[headIndentStepper setEnabled:NO];
		[tailIndentTextField setEnabled:NO];
		[tailIndentStepper setEnabled:NO];
		[alignmentLeftButton setEnabled:NO];
		[alignmentRightButton setEnabled:NO];
		[alignmentCenterButton setEnabled:NO];
		[alignmentJustifyButton setEnabled:NO];
		[minLineHeightTextField setEnabled:NO];
		[maxLineHeightTextField setEnabled:NO];
		[minLineHeightStepper setEnabled:NO];
		[maxLineHeightStepper setEnabled:NO];
		[highlightYellowButton setEnabled:NO];
		[highlightOrangeButton setEnabled:NO];
		[highlightPinkButton setEnabled:NO];
		[highlightBlueButton setEnabled:NO];
		[highlightGreenButton setEnabled:NO];
		[highlightRemoveButton setEnabled:NO];
		[forceLineHeightDefaultButton setEnabled:NO];
	}
}

//MyDocument notifies the inspector upon updateInspector whether document which gained
//			focus uses American measurement units or metric
- (float)pointsPerUnitAccessor {
	return pointsPerUnitAccessor;
}

- (void)setPointsPerUnitAccessor:(float)points {
	pointsPerUnitAccessor = points;
}

- (BOOL)acceptsFirstResponder
{ 
	return YES;
}

@end

/*
  InspectorController.h
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


#import <AppKit/AppKit.h>

@interface InspectorController : NSWindowController
{
	NSTextView *_inspectingTextView;
	//IBOutlet InspectorController *inspectorController;
	IBOutlet NSPanel *inspectorPanel;
	IBOutlet NSSlider *characterSpacingSlider;
	IBOutlet NSTextField *characterSpacingTextField;
	IBOutlet NSStepper *characterSpacingStepper;
	IBOutlet NSButton *characterSpacingDefaultButton;
	IBOutlet NSSlider *interlineSpacingSlider;
	IBOutlet NSTextField *interlineSpacingTextField;
	IBOutlet NSStepper *interlineSpacingStepper;
	IBOutlet NSSlider *multipleSpacingSlider;
	IBOutlet NSTextField *multipleSpacingTextField;
	IBOutlet NSStepper *multipleSpacingStepper;
	IBOutlet NSButton *multipleSpacingDefaultButton;
	IBOutlet NSSlider *afterParagraphSpacingSlider;
	IBOutlet NSTextField *afterParagraphSpacingTextField;
	IBOutlet NSStepper *afterParagraphSpacingStepper;
	IBOutlet NSSlider *beforeParagraphSpacingSlider;
	IBOutlet NSTextField *beforeParagraphSpacingTextField;
	IBOutlet NSStepper *beforeParagraphSpacingStepper;
	IBOutlet NSTextField *firstLineIndentTextField;
	IBOutlet NSStepper *firstLineIndentStepper;
	IBOutlet NSTextField *headIndentTextField;
	IBOutlet NSStepper *headIndentStepper;
	IBOutlet NSTextField *tailIndentTextField;
	IBOutlet NSStepper *tailIndentStepper;
	IBOutlet NSTextField *indentLabelTextField;
	IBOutlet NSButton *alignmentLeftButton;
	IBOutlet NSButton *alignmentRightButton;
	IBOutlet NSButton *alignmentCenterButton;
	IBOutlet NSButton *alignmentJustifyButton;
	IBOutlet NSButton *traitsBoldButton;
	IBOutlet NSButton *traitsItalicButton;
	IBOutlet NSTextField *minLineHeightTextField;
	IBOutlet NSTextField *maxLineHeightTextField;
	IBOutlet NSStepper *minLineHeightStepper;
	IBOutlet NSStepper *maxLineHeightStepper;
	IBOutlet NSPopUpButton *fontStylesMenu;
	IBOutlet NSButton *highlightYellowButton;
	IBOutlet NSButton *highlightOrangeButton;
	IBOutlet NSButton *highlightPinkButton;
	IBOutlet NSButton *highlightBlueButton;
	IBOutlet NSButton *highlightGreenButton;
	IBOutlet NSButton *highlightRemoveButton;
	IBOutlet NSButton *forceLineHeightDefaultButton;
	float pointsPerUnitAccessor;
	BOOL needsUpdate;
}

+ (id)sharedInspectorController;
- (BOOL)acceptsFirstResponder;
- (void)updateInspector:(NSDictionary *)theAttributes theRightMarginValueToIndentFrom:(float)theRightMarginValue isReadOnly:(BOOL)isReadOnly;
- (float)pointsPerUnitAccessor;
- (void)setPointsPerUnitAccessor:(float)points;

@end
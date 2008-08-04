/*
 Subclass: PrefWindowController.h
 Controls default font and text color changes in the preferences window

 Created 11 JUL 2006 by JH
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


#import <Cocoa/Cocoa.h>

@interface PrefWindowController : NSWindowController
{
	IBOutlet id prefWindow;
	IBOutlet id richTextColorTextField;
	IBOutlet id plainTextColorTextField;
    IBOutlet id altTextColorWell;
    IBOutlet id altBackgroundColorWell;
	IBOutlet id plainTextFontNameField;
	IBOutlet id richTextFontNameField;
	IBOutlet id defaultTopMarginTextField;
	IBOutlet id defaultLeftMarginTextField;
	IBOutlet id defaultRightMarginTextField;
	IBOutlet id defaultBottomMarginTextField;
	IBOutlet id defaultUnitsTextField;
	IBOutlet id defaultFirstLineIndentTextField;
	IBOutlet id defaultFirstLineIndentStepper;
	IBOutlet id defaultIsMetric;
	IBOutlet id applyChangesButton;
	IBOutlet id defaultSaveFormatPopupButton;
	BOOL richOrPlain;
	BOOL isMetric;
}

//fonts pane
- (IBAction)changeFontAction:(id)sender;
- (IBAction)changeFont:(id)sender;
- (IBAction)useAltColorsAction:(id)sender;
- (BOOL)richOrPlain;
- (void)setRichOrPlain:(BOOL)flag;
//defaults pane
- (BOOL)isMetric;
- (void)setIsMetric:(BOOL)flag;
- (IBAction)applyChangesAction:(id)sender;
- (void)convertToMetric;
- (void)convertToUS;
- (IBAction)useMetricAction:(id)sender;
- (IBAction)enableChangeButtonAction:(id)sender;
//general page
-(IBAction)selectDefaultSaveFormatAction:(id)sender;
//misc
- (IBAction)closeAction:(id)sender;

@end

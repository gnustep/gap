/*
 PageView.h
 Bean

 Created by James Hoover on 7/11/06.
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
#import "JHScrollView.h"
#import <Foundation/NSGeometry.h>

@interface PageView : NSView
{
    //object pointers
	NSColor *backgroundColor;
	NSColor *textViewBackgroundColor;
    NSAttributedString *pageFooter;
    NSPrintInfo *printInfo;
    id delegate;
	//IBOutlets
	IBOutlet NSWindow *docWindow;
    //vars
	int numberOfPages;
    float theLeftMargin;
    float theRightMargin;
    float theTopMargin;
    float theBottomMargin;
	float pageSeparatorLength;
    //BOOLS
	BOOL shouldUseAltTextColors;
	BOOL showMarginsGuide;
	BOOL showRulerWidgets;
	BOOL shouldSetupRuler;
	BOOL showPageShadow;
}

//text and background colors
- (void)setBackgroundColor:(NSColor *)color;
- (NSColor *)backgroundColor;
- (void)setShouldUseAltTextColors:(BOOL)flag ;
- (BOOL)shouldUseAltTextColors;
- (void)setTextViewBackgroundColor:(NSColor*)aColor;
- (NSColor *)textViewBackgroundColor;

//setup, calculate views
- (void)recalculateFrame;
- (int)numberOfPages;
- (void)setNumberOfPages:(int)newNumberOfPages;
- (float)pageSeparatorLength;
- (IBAction)applyPrefsPageView:(id)sender;

//print info
- (void)setPrintInfo:(NSPrintInfo *)anObject;
- (NSPrintInfo *)printInfo;
- (NSSize)documentSizeInPage;

//margins
- (float)theLeftMargin;
- (void)setTheLeftMargin:(float)newLeftMargin;
- (float)theRightMargin;
- (void)setTheRightMargin:(float)newRightMargin;
- (float)theTopMargin;
- (void)setTheTopMargin:(float)newTopMargin;
- (float)theBottomMargin;
- (void)setTheBottomMargin:(float)newBottomMargin;

//toggle view elements
- (BOOL)showMarginsGuide;
- (void)setShowMarginsGuide:(BOOL)flag;
- (BOOL)showPageShadow;
- (void)setShowPageShadow:(BOOL)flag;
	
//control ruler
- (BOOL)showRulerWidgets;
- (void)setShowRulerWidgets:(BOOL)flag;
- (BOOL)shouldSetupRuler;
- (void)setShouldSetupRuler:(BOOL)flag;

//for header and footer (future use)
	//- (NSAttributedString *)pageFooter;
	//- (NSAttributedString *)pageHeader;

@end

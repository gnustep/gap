/*
 PageView.m
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

#import "PageView.h"

#define SKT_RULER_MARKER_THICKNESS 12.0
#define SKT_RULER_ACCESSORY_THICKNESS 0.0

@implementation PageView

#pragma mark -
#pragma mark ---- Init, Dealloc, awakeFromNib ----

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame]) {
		delegate = self; 
        [self setBackgroundColor:[NSColor lightGrayColor]];	
        [self setPrintInfo:[NSPrintInfo sharedPrintInfo]];
		[self setNumberOfPages:1];
		[self setShowPageShadow:YES];
    }
    return self;
}

- (void)dealloc
{
	[backgroundColor release];
	[super dealloc];
}

-(BOOL)isFlipped
{
	return YES;
}

-(BOOL)isOpaque
{
	return YES;
}

- (void)awakeFromNib
{
	// Make sure scroll view has same colour as our background
	if ([self enclosingScrollView] && backgroundColor)
	[[self enclosingScrollView] setBackgroundColor:[NSColor lightGrayColor]]; //backgroundColor];
	//set up ruler view
	NSScrollView *theScrollView = [self enclosingScrollView];
	[theScrollView setHasHorizontalRuler:YES];
	[theScrollView setHasVerticalRuler:NO];
	//conpensate ruler for page position offset
	NSRulerView *xruler = [theScrollView horizontalRulerView];
	[xruler setOriginOffset:[self pageSeparatorLength]];
	NSRulerView *yruler = [theScrollView verticalRulerView];
	[yruler setOriginOffset:[self pageSeparatorLength]];
	[self setShouldSetupRuler:YES];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:@"prefShowPageShadow"]) {
		[self setShowPageShadow:YES];
	} else {
		[self setShowPageShadow:NO];
	}
	
}

#pragma mark -
#pragma mark ---- Accessors ----

- (void)setBackgroundColor:(NSColor *)color
{
	[color retain];
	[backgroundColor release];
	backgroundColor = color;
}

- (NSColor *)backgroundColor
{
	return backgroundColor;
}

- (void)setTextViewBackgroundColor:(NSColor*)aColor
{
	[aColor retain];
	[textViewBackgroundColor release];
	textViewBackgroundColor = aColor;
}

-(NSColor *)textViewBackgroundColor
{
	return textViewBackgroundColor;
}

- (int)numberOfPages
{
	return numberOfPages;
}

-(void)setNumberOfPages:(int)newNumberOfPages
{
    numberOfPages = newNumberOfPages;
}

- (void)setShouldUseAltTextColors:(BOOL)flag
{
	shouldUseAltTextColors = flag;
}

- (BOOL)shouldUseAltTextColors
{
	return shouldUseAltTextColors;
}

- (float)theLeftMargin
{
	return theLeftMargin;
}

-(void)setTheLeftMargin:(float)newLeftMargin
{
	[printInfo setLeftMargin:newLeftMargin];
	theLeftMargin = newLeftMargin;
}

- (float)theRightMargin
{
	return theRightMargin;
}

-(void)setTheRightMargin:(float)newRightMargin
{
	[printInfo setRightMargin:newRightMargin];
	theRightMargin = newRightMargin;
}

- (float)theTopMargin
{
	return theTopMargin;
}

-(void)setTheTopMargin:(float)newTopMargin
{
	[printInfo setTopMargin:newTopMargin];
	theTopMargin = newTopMargin;
}

- (float)theBottomMargin
{
	return theBottomMargin;
}

-(void)setTheBottomMargin:(float)newBottomMargin {
	[printInfo setBottomMargin:newBottomMargin];
	theBottomMargin = newBottomMargin;
}

-(float)pageSeparatorLength {
	return 15.0;
}

- (BOOL)showMarginsGuide {
	return showMarginsGuide;
}
- (void)setShowMarginsGuide:(BOOL)flag {
	showMarginsGuide = flag;
}

- (BOOL)showRulerWidgets {
	return showRulerWidgets;
}

- (void)setShowRulerWidgets:(BOOL)flag {
	showRulerWidgets = flag;
}

- (BOOL)shouldSetupRuler {
	return shouldSetupRuler;
}

- (void)setShouldSetupRuler:(BOOL)flag {
	//yes means initially set up ruler, no means no need
	shouldSetupRuler = flag;
}

- (BOOL)showPageShadow {
	return showPageShadow;
}

- (void)setShowPageShadow:(BOOL)flag {
	//yes means initially set up ruler, no means no need
	showPageShadow = flag;
}

#pragma mark -
#pragma mark ---- Recalculate Frame  ----

- (void)recalculateFrame {
//upon adding or removing pages
    NSSize paperSize = [printInfo paperSize];
    NSRect newFrame = [self frame];
    //set frame height and add a bit for clearance at bottom
    newFrame.size.height = [self numberOfPages] * (paperSize.height + [self pageSeparatorLength]) + 30;
    newFrame.size.width = paperSize.width + (2 * [self pageSeparatorLength]);
    [self setFrame:newFrame];	
    [self setBoundsSize:[self frame].size];
}

#pragma mark -
#pragma mark ---- NSView Overrides ----

- (void)drawRect:(NSRect)rect
{
	if ([[NSGraphicsContext currentContext] isDrawingToScreen]) {
	    
		//draw GRAY BACKGROUND on which 'pages' rest in multiple page view mode
		[backgroundColor set];
		[NSBezierPath fillRect:rect];														

#ifndef GNUSTEP		
		if ([self showPageShadow])
		{
			//CREATE SHADOW
			NSShadow *theShadow = [[NSShadow alloc] init]; 
			//set shadow (for page rect)
			[theShadow setShadowOffset:NSMakeSize(0.0, 0.0)]; 
			[theShadow setShadowBlurRadius:12.0]; 
			//use a partially transparent color for shapes that overlap.
			[theShadow setShadowColor:[[NSColor darkGrayColor] colorWithAlphaComponent:0.7]]; 
			[theShadow set];
			//release shadow
			[theShadow release]; 
		}
#endif		
		//get paper size
		NSSize paperSize = [printInfo paperSize];
		
		//DRAW PAGE				
		unsigned cnt;
		for (cnt = 0; cnt <= ([self numberOfPages] - 1); cnt++) 
		{ 
			//determine paper size
			NSRect pageRect = NSZeroRect;
			pageRect.size = [printInfo paperSize];
			pageRect.origin = ([self frame].origin);
			pageRect.origin.x = [self pageSeparatorLength];
			pageRect.origin.y = [self pageSeparatorLength] + cnt * (paperSize.height + [self pageSeparatorLength]);
			//fills margin of page drawn on screen (around text container) with appropriate color
			(shouldUseAltTextColors) ? [[self textViewBackgroundColor] set] : [[NSColor whiteColor] set];
			NSRectFill(pageRect);
			
			//20 June 2007 if user prefs indicate that pageShadow is not being drawn, we draw a rectangle around page instead
			if (![self showPageShadow])
			{
				[[NSColor darkGrayColor] set];
				[NSBezierPath setDefaultLineWidth:0.5];
				[NSBezierPath strokeRect:pageRect];
			}
			
			//draws MARGINS GUIDE (a light frame just outside editable text area)
			if ([self showMarginsGuide]) {
				NSRect frame = NSZeroRect;
				frame.size = [printInfo paperSize];
				//arbitrarily added 2 so that left margin text wouldn't visually butt up against margin guide
				frame.origin.x = [printInfo leftMargin] + [self pageSeparatorLength] - 2;
				frame.origin.y = [self pageSeparatorLength] + [printInfo topMargin] 
						+ (cnt * (([printInfo paperSize].height) + [self pageSeparatorLength])); 
				frame.size.height = [printInfo paperSize].height - [printInfo topMargin] - [printInfo bottomMargin];
				//arbitrarily added 4 so that right margin text wouldn't visually butt up against margin guide
				frame.size.width = [printInfo paperSize].width - [printInfo leftMargin]- [printInfo rightMargin] + 4;
				if (shouldUseAltTextColors) {
					//this is necessary if user chooses gray-scale chooser from color panel ("no redComponent defined," etc errors)	
					NSColor *tvBackgroundColor = [[self textViewBackgroundColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
					//determines the color of the margin guide (light vs. dark) -- from TextForge source code
					float darkness;
					darkness = ((222 * [tvBackgroundColor redComponent]) 
							+ (707 * [tvBackgroundColor greenComponent]) 
							+ (71 * [tvBackgroundColor blueComponent])) / 1000;
					if (darkness > 0.5) {
						[[NSColor darkGrayColor] set];
					} else {
						[[NSColor lightGrayColor] set];
					}
				} else {
					[[NSColor darkGrayColor] set];
				}
				frame = NSInsetRect(frame, -1.0, -1.0);
				NSFrameRectWithWidth(frame, 0.3);
			}
		}
		//this draws PAGE COUNT on view just above each page
		for (cnt = 0; cnt <= ([self numberOfPages] - 1); cnt++)
		{
			NSString *pageCount = nil;
			
			//dont show the pageCount for page 1 & 2 because, until whole just-opened
			//		doc is fully laid out, numbers here won't be accurate
			//	I'm not sure what this commented out stuff was about; fixed label for localization 4 Sept 2007 JH
			//if ([self numberOfPages] > 2) { 
				pageCount = [[NSString alloc] initWithFormat:@"%@ %i", NSLocalizedString(@"Page ", @"layout view label: Page_"), cnt + 1];
			//} else {
			//	pageCount = [[NSString alloc] initWithFormat:@"%@ %i", @"Page ", cnt + 1];
			//}
			[self lockFocus];
			NSPoint theTextPos;
			//pos for page count
			theTextPos = NSMakePoint(5 + [self pageSeparatorLength], [self pageSeparatorLength] 
									+ cnt * ((paperSize.height) + [self pageSeparatorLength]) - 18);
			//pos for shadow for page count label
			NSMutableDictionary *theTextAttrs;
			theTextAttrs = [[NSMutableDictionary alloc] init];
			NSFont *aFont = [NSFont fontWithName: @"Arial" size: 12];
			//use system font on error (Lucida Grande, it's nice)
			if (aFont == nil) aFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
			//Macs without Arial would complain of nil object, so added error code (17 May 2007 BH)
			if (aFont) [theTextAttrs setObject: aFont forKey: NSFontAttributeName];
			//draw shadow for page count label (6 July 2007 BH)
			
			//CREATE SHADOW (if page shadow is off, this just makes the page count more visible
			//			doesn't seem to slow down the scroll or display like the page shadow does
#ifndef GNUSTEP
			if (![self showPageShadow])
			{
				NSShadow *theShadow = [[NSShadow alloc] init]; 
				//set shadow (for page rect)
				[theShadow setShadowOffset:NSMakeSize(0.0, 0.0)]; 
				[theShadow setShadowBlurRadius:8.0]; 
				//use a partially transparent color for shapes that overlap.
				[theShadow setShadowColor:[[NSColor darkGrayColor] colorWithAlphaComponent:0.9]]; 
				[theShadow set];
				//release shadow
				[theShadow release]; 
			}
#endif			
			//draw page count label
			[theTextAttrs setObject: [NSColor whiteColor] forKey:NSForegroundColorAttributeName];
			[pageCount drawAtPoint:theTextPos withAttributes:theTextAttrs];
									
			[theTextAttrs release];
			[pageCount release];
			[self unlockFocus];
		}
		//tweak the appearance of the ruler
		NSScrollView *theScrollView = [self enclosingScrollView];
		NSRulerView *xruler = [[self enclosingScrollView] horizontalRulerView];
		//conpensate ruler for page position offset
		[xruler setOriginOffset:[self pageSeparatorLength]];
		NSRulerView *yruler = [theScrollView verticalRulerView];
		[yruler setOriginOffset:[self pageSeparatorLength]];
		//either show the ruler widgets or not, depending on prefs; if changed, refresh display; ruler is setup once only
		/*		
		//revised: we do this now in JHLayoutManager rulerAccessoryViewForTextView, either returning the accessoryView
		//			or not depending on Preferences
		if ([self shouldSetupRuler]) {
			[self setShouldSetupRuler:NO];
			[[xruler accessoryView] removeFromSuperview];
			[xruler setRuleThickness: 18.0];
			[xruler setReservedThicknessForMarkers:SKT_RULER_MARKER_THICKNESS];
			[xruler setReservedThicknessForAccessoryView:SKT_RULER_ACCESSORY_THICKNESS];//1
			[[self enclosingScrollView] display];
		}
		*/	
	}
}

#pragma mark -
#pragma mark ---- setPrintInfo, printInfo Methods ----

- (void)setPrintInfo:(NSPrintInfo *)anObject
{
	//updates page size or margins once settings are changed
    if (printInfo != anObject) {
        [printInfo autorelease];
        printInfo = [anObject copy];
        [self recalculateFrame];
        [self setNeedsDisplay:YES];	//because the page size or margins might change
    }
}

- (NSPrintInfo *)printInfo
{
    return printInfo;
}

#pragma mark -
#pragma mark ---- Print Methods ----

//these override methods belong in the subclass from which the print view is generated
//these two methods were lifted from Text Edit for GnuStep code (=Text Edit 4.0 for NextStep)
- (NSRect)documentRectForPageNumber:(unsigned)pageNumber {	/* First page is page 0, of course! */
	NSRect rect = NSZeroRect;
	rect.size = [printInfo paperSize];
	rect.origin = [self frame].origin;
	rect.origin.y += ((rect.size.height + [self pageSeparatorLength]) * pageNumber) + [self pageSeparatorLength];
	rect.origin.x += [printInfo leftMargin] + [self pageSeparatorLength];
	rect.origin.y += [printInfo topMargin];
	rect.size = [self documentSizeInPage];
	return rect;
}

- (NSSize)documentSizeInPage {
    NSSize paperSize = [printInfo paperSize];
    paperSize.width -= ([printInfo leftMargin] + [printInfo rightMargin]);
    paperSize.height -= ([printInfo topMargin] + [printInfo bottomMargin]);
    return paperSize;
}

- (BOOL)knowsPageRange:(NSRangePointer)aRange
{
    aRange->length = numberOfPages; 
	return YES;
}

- (NSRect)rectForPage:(int)page
{
    return [self documentRectForPageNumber:page-1];  //our pages numbers start from 0; the kit's from 1
}


//print page numbers in footer according to a user preference
- (NSAttributedString *)pageFooter
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//	retrieve the default as to whether to print std header/footer
	if ([[defaults valueForKey:@"prefPrintFooter"] boolValue])
	{
		return [super pageFooter];
	}
	else
	{
		return nil;
	}
}

//print title and date in header according to a user preference
- (NSAttributedString *)pageHeader
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//	retrieve the default as to whether to print std header/footer
	if ([[defaults valueForKey:@"prefPrintHeader"] boolValue])
	{
		return [super pageHeader];
	}
	else
	{
		return nil;
	}
	
}


#pragma mark -
#pragma mark ---- Apply Preference to PageView ----

//triggered from MyDocument; PageView needs to know this to update the display correctly
-(IBAction)applyPrefsPageView:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:@"prefShowMarginGuides"]) {
		[self setShowMarginsGuide:YES];
	} else {
		[self setShowMarginsGuide:NO];
	}
}

@end

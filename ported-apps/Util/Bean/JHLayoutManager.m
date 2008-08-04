/*
 Subclass: JHLayoutManager.m
	adds 'showInvisibles' to layout manager

 Revised 30 DEC 2006 by JH
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
 
//---------------------------------------------------------------------------------------------------------------------------//
// this subclass is based on a code solution given by Peter Borg (see cocoabuilder.com Jan 3 2005) and Smultron also uses it //
// 20 June 2007																												 //
//---------------------------------------------------------------------------------------------------------------------------//

#import "JHLayoutManager.h"

#define SKT_RULER_MARKER_THICKNESS 12.0
#define SKT_RULER_ACCESSORY_THICKNESS 0.0

@implementation JHLayoutManager

-(id)init
{
	if (self = [super init])
	{
		unichar spaceUnichar = 0x00B7;
		spaceCharacter = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%C", spaceUnichar]];
		unichar tabUnichar = 0x2192;
		tabCharacter = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%C", tabUnichar]];
		unichar newLineUnichar = 0x21B5;
		newLineCharacter = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%C", newLineUnichar]];
		//	= unicode form feed char (see cocoa: insertContainerBreak)
		unichar newPageUnichar = 0x23AE; 
		newPageCharacter = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%C", newPageUnichar]];
		[self setShowInvisibleCharacters:NO];
		[self setShowRulerAccessories:NO];
	}
	return self;
}

-(void)dealloc
{
	[attributes release];
	[spaceCharacter release];
	[tabCharacter release];
	[newLineCharacter release];
	[newPageCharacter release];
	attributes = nil;
	spaceCharacter = nil;
	tabCharacter = nil;
	newLineCharacter = nil;
	newPageCharacter = nil;
	[super dealloc];
}

- (void)drawGlyphsForGlyphRange:(NSRange)glyphRange atPoint:(NSPoint)containerOrigin
{
	//for blue colored invisibles
	NSDictionary *theNewAttributes =  [NSDictionary dictionaryWithObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];

	if ([self showInvisibleCharacters])
	{
		completeString = [[self textStorage] string];
		lengthToRedraw = NSMaxRange(glyphRange);	
		
		for (index = glyphRange.location; index < lengthToRedraw; index++)
		{
			characterToCheck = [completeString characterAtIndex:index];
			
			int theIndexToCheck = index; 
			if (theIndexToCheck > 0) theIndexToCheck = index - 1; 
			
			NSDictionary *currentAttributes = [[self textStorage] attributesAtIndex:theIndexToCheck effectiveRange:NULL];
			NSFont *theFont = [currentAttributes objectForKey: NSFontAttributeName];
			float pointSize = [theFont pointSize];
			//space character
			if (characterToCheck == ' ')
			{
				pointToDrawAt = [self locationForGlyphAtIndex:index];
				glyphFragment = [self lineFragmentRectForGlyphAtIndex:index effectiveRange:NULL];
				pointToDrawAt.x += glyphFragment.origin.x + .5;
				pointToDrawAt.y = glyphFragment.origin.y + (glyphFragment.size.height) - (pointSize * .5) - 9;
				[spaceCharacter drawAtPoint:pointToDrawAt withAttributes:theNewAttributes];
			}
			//tab character
			else if (characterToCheck == '\t')
			{
				pointToDrawAt = [self locationForGlyphAtIndex:index];
				glyphFragment = [self lineFragmentRectForGlyphAtIndex:index effectiveRange:NULL];
				pointToDrawAt.x += glyphFragment.origin.x + 1;
				pointToDrawAt.y = glyphFragment.origin.y + (glyphFragment.size.height) - (pointSize * .5) - 9;
				[tabCharacter drawAtPoint:pointToDrawAt withAttributes:theNewAttributes];
			}
			//return character
			else if (characterToCheck == '\n' 
					 || characterToCheck == '\r'
					 || characterToCheck == 0x2028
					 || characterToCheck == 0x2029)
			{
				pointToDrawAt = [self locationForGlyphAtIndex:index];
				glyphFragment = [self lineFragmentRectForGlyphAtIndex:index effectiveRange:NULL];
				pointToDrawAt.x += glyphFragment.origin.x;
				pointToDrawAt.y = glyphFragment.origin.y + (glyphFragment.size.height) - (pointSize * .5) - 9;
				[newLineCharacter drawAtPoint:pointToDrawAt withAttributes:theNewAttributes];
			}
			//page break character
			else if (characterToCheck == 0x000c)
			{
				pointToDrawAt = [self locationForGlyphAtIndex:index];
				glyphFragment = [self lineFragmentRectForGlyphAtIndex:index effectiveRange:NULL];
				pointToDrawAt.x += glyphFragment.origin.x - 2;
				pointToDrawAt.y = glyphFragment.origin.y + (glyphFragment.size.height) - (pointSize * .5) - 9;
				[newPageCharacter drawAtPoint:pointToDrawAt withAttributes:theNewAttributes];
				/*
				FIXME:
				What I would really like here is something that forces the line to return in continuous
				text view mode (which it doesn't) when the pagebreak character is encountered, and then 
				redraws the text appropriately. As it is now, it DOES show a 'return' (a new line) 
				at the page break, but then the previous line also shows up above, so it's in two places.
				You can force it to redraw, but then it's all on one line. You can force it to redraw all
				the time when it comes to a page break using the code below, but then 1) it's all on one 
				line -- not what I want, and 2) it's really slow in big docs because it's always redrawing
				*/
				/*
				NSRange aRange = NSMakeRange(glyphRange.location, glyphRange.length);
				NSRange anotherRange;
				[self invalidateLayoutForCharacterRange:aRange isSoft:YES actualCharacterRange:&anotherRange];
				*/
			}
		
		}
    } 
    [super drawGlyphsForGlyphRange:glyphRange atPoint:containerOrigin];
}

-(void)setShowInvisibleCharacters:(BOOL)flag
{
	showInvisibleCharacters = flag;
}

-(BOOL)showInvisibleCharacters
{
	return showInvisibleCharacters;
}

-(void)setShowRulerAccessories:(BOOL)flag
{
	showRulerAccessories = flag;
}

-(BOOL)showRulerAccessories
{
	return showRulerAccessories;
}

- (NSView *)rulerAccessoryViewForTextView:(NSTextView *)view paragraphStyle:(NSParagraphStyle *)style ruler:(NSRulerView *)ruler enabled:(BOOL)isEnabled
{
	//	3 July 2007 formerly, widgets would show or not depending on the NSUserDefault showRulerWidgets ...now we use an accessor to set the initial state and maintain it, since Preferences are for settings for 'new documents' only BH
	//	show ruler widgets
	if ([self showRulerAccessories])
	{
		NSView *accessory = [super rulerAccessoryViewForTextView:view paragraphStyle:style ruler:ruler enabled:isEnabled];
		if  (ruler) [ruler display];
		return accessory;
	}
	else
	{
		//	adjust size of accessoryView, otherwise you get a big empty space
		[ruler setRuleThickness: 18.0];
		[ruler setReservedThicknessForMarkers:SKT_RULER_MARKER_THICKNESS];
		[ruler setReservedThicknessForAccessoryView:SKT_RULER_ACCESSORY_THICKNESS];
		//	hide ruler widgets
		return nil;
	}
}

@end

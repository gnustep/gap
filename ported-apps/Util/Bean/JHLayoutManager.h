/*
 Subclass: JHLayoutManager.h
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


//based on a code solution posted by Peter Borg (see cocoabuilder.com Jan 3 2005)
//20 June 2007 CocoaBuilder.com defunct, but same info on developer.Apple.com lists 

#import <Cocoa/Cocoa.h>

@interface JHLayoutManager : NSLayoutManager 
{
	
	NSUserDefaults *defaults;
	NSMutableDictionary *attributes;
	NSString *spaceCharacter;
	NSString *tabCharacter;
	NSString *newLineCharacter;
	NSString *newPageCharacter;
	NSString *completeString;
	unichar characterToCheck;
	NSPoint pointToDrawAt;
	NSRect glyphFragment;
	float defaultPointSize;
	unsigned int lengthToRedraw;
	unsigned int index;
	// "cache" this setting to improve speed, slightly...
	BOOL showInvisibleCharacters;
	BOOL showRulerAccessories;
}

-(void)setShowInvisibleCharacters:(BOOL)flag;
-(BOOL)showInvisibleCharacters;
-(void)setShowRulerAccessories:(BOOL)flag;
-(BOOL)showRulerAccessories;

@end

/*
 *  Controller.m: Controller Object of Gomoku.app
 *
 *  Copyright (c) 2000 Nicola Pero <n.pero@mi.flashnet.it>
 *  
 *  Author: Nicola Pero
 *  Date: April, September 2000
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include "Controller.h"
#include "Board.h"

@interface DifficultyPanel : NSPanel
{
  MainBoard *board;
}
- (id) initWithBoard: (MainBoard *)b;
- (void) changeLevel: (id)sender;
@end

@implementation DifficultyPanel
- (id) initWithBoard: (MainBoard *)b
{
  NSBox *box;
  NSBox *box_b;
  NSMatrix *matrix;
  NSButtonCell *cell;
  NSRect winFrame;

  board = b;

  cell = [[NSButtonCell alloc] init];
  [cell setButtonType: NSRadioButton];
  [cell setBordered: NO];
  [cell setImagePosition: NSImageLeft]; 
  
  matrix = [[NSMatrix alloc] initWithFrame: NSZeroRect
				 mode: NSRadioModeMatrix
				 prototype: cell
				 numberOfRows: 6
				 numberOfColumns: 1];   
  
  [matrix setIntercellSpacing: NSMakeSize (0, 4) ];
  [matrix setTarget: self];
  [matrix setAutosizesCells: NO];
  [matrix setTarget: self];
  [matrix setAction: @selector(changeLevel:)];
  
  cell = [matrix cellAtRow: 0 column: 0];
  [cell setTitle: _(@"Level 0 (Trivial)")];
  [cell setTag: 0];
  cell = [matrix cellAtRow: 1 column: 0];
  [cell setTitle: _(@"Level 1 (Beginner)")];
  [cell setTag: 1];
  cell = [matrix cellAtRow: 2 column: 0];
  [cell setTitle: _(@"Level 2 (Easy)")];
  [cell setTag: 2];
  cell = [matrix cellAtRow: 3 column: 0];
  [cell setTitle: _(@"Level 3 (Medium)")];
  [cell setTag: 3];
  cell = [matrix cellAtRow: 4 column: 0];
  [cell setTitle: _(@"Level 4 (Advanced)")];
  [cell setTag: 4];
  cell = [matrix cellAtRow: 5 column: 0];
  [cell setTitle: _(@"Level 5 (Difficult)")];
  [cell setTag: 5];

  [matrix selectCellWithTag: [board difficultyLevel]];
  
  [matrix sizeToFit];
  
  box = [NSBox new];
  [box setTitle: _(@"Choose Difficulty Level:")];
  [box setTitlePosition: NSAtTop];
  [box setBorderType: NSGrooveBorder];
  [box addSubview: matrix];
  RELEASE (matrix);
  [box sizeToFit];
  [box setAutoresizingMask: (NSViewWidthSizable | NSViewHeightSizable)];

  box_b = [NSBox new];
  [box_b setTitlePosition: NSNoTitle];
  [box_b setBorderType: NSNoBorder];
  [box_b addSubview: box];
  RELEASE (box);
  [box_b sizeToFit];
  [box_b setAutoresizingMask: (NSViewWidthSizable | NSViewHeightSizable)];

  winFrame.size = [box_b frame].size;
  winFrame.origin = NSMakePoint (100, 100);

  // Now we can make the window of the exact size 
  self = [[isa alloc] initWithContentRect: winFrame
		     styleMask: (NSTitledWindowMask 
				 | NSClosableWindowMask 
				 | NSMiniaturizableWindowMask)
		      backing: NSBackingStoreBuffered
		      defer: YES];
  [self setTitle: _(@"Difficulty level Panel")];
  [self setReleasedWhenClosed: NO];
  [self setContentView: box_b];
  RELEASE (box_b);
  [self changeLevel: matrix];
  return self;
}

- (void) changeLevel: (id)sender
{
  int level = [[sender selectedCell] tag];
  
  [board setDifficultyLevel: level];
  
  [[NSUserDefaults standardUserDefaults] setInteger: level 
					 forKey: @"DifficultyLevel"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation Controller

+ new: (int) cnt
{
    return [[self alloc] init: cnt];
}

- init: (int) cnt
{
  NSMatrix *matrix;
  NSRect winFrame;
  NSImageCell *cell;
  int level;
  
  cell = [[NSCell alloc] init];
  AUTORELEASE (cell);
  [cell setBordered: NO];
  [cell setBezeled: NO];
  [cell setEditable: NO];
  [cell setSelectable: NO];
  [cell setImage: [NSImage imageNamed: @"Empty"]];

  matrix = [[NSMatrix alloc] initWithFrame: NSZeroRect
			     mode: NSTrackModeMatrix 
			     prototype: cell
			     numberOfRows: cnt 
			     numberOfColumns: cnt];
  AUTORELEASE (matrix);
  [matrix setIntercellSpacing: NSMakeSize (0, 0)];
  [matrix setAutoresizingMask: NSViewNotSizable];
  [matrix sizeToFit];


  winFrame.size = [matrix frame].size;
  winFrame.origin = NSMakePoint (100, 100);

  self = [super initWithContentRect: winFrame
		styleMask: (NSTitledWindowMask | NSClosableWindowMask 
			    | NSMiniaturizableWindowMask)
		backing: NSBackingStoreBuffered
		defer: YES];
  [self setTitle: _(@"Gomoku Game")];
  [self setReleasedWhenClosed: NO];
  [self setContentView: matrix];

  board = [[MainBoard alloc] initWithMatrix: matrix];
  [matrix setTarget: self];
  [matrix setAction: @selector (userMove:)];

  level = [[NSUserDefaults standardUserDefaults] 
	    integerForKey: @"DifficultyLevel"];
  if (level >= 0 && level <= 5)
    {
      [board setDifficultyLevel: level];
    }
  
  return self;
}

-(void) dealloc
{
  TEST_RELEASE (diffPanel);
  RELEASE (board);
  [super dealloc];
}

- (void) applicationDidFinishLaunching: (NSNotification *)aNotification;
{
  [self center];
  [self orderFront: self];
}

- (void) runDifficultyLevelPanel: (id) sender
{
  if (diffPanel == nil)
    {
      diffPanel = [[DifficultyPanel alloc] initWithBoard: board];
    }
  
  [diffPanel orderFront: self];
}

- (void) newGame: (id) sender
{
  [self orderFront: self];
  [board newGame];
}

- (void) userMove: (id) sender
{
  if ([sender isKindOfClass: [NSMatrix class]])
    {
      [board userMoveInRow: [(NSMatrix *)sender selectedRow]
	     column: [(NSMatrix *)sender selectedColumn]];
    }
}

@end


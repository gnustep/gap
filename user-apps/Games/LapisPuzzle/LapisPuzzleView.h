/*
 * LapisPuzzleView.h

 * Copyright (C) 2004 Banlu Kemiyatorn.
 * July 19, 2004
 * Written by Banlu Kemiyatorn <object at gmail dot com>
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.

 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
 */

#ifndef CalendarEventView_h
#define CalendarEventView_h

#include <Foundation/NSCalendarDate.h>
#include <AppKit/AppKit.h>
#include "LapisPuzzle.h"

typedef enum _LPUnitColorType
{
	LP_COLOR_BLUE,
	LP_COLOR_RED,
	LP_COLOR_GREEN,
	LP_COLOR_YELLOW,
	LP_COLOR_ALL
} LPUnitColorType;

typedef enum _LPDirType
{
	LP_MOVE_UP, // for sokoban mode
	LP_MOVE_LEFT,
	LP_MOVE_RIGHT,
	LP_MOVE_DOWN,
	LP_MOVE_FALL,
	LP_MOVE_CW,
	LP_MOVE_CCW
} LPDirType;

@class LPUnit;

@protocol LPUnitOwner
- (NSSize) gridSize;
/*
- (unsigned int) numberOfSteps;
- (BOOL) unit:(LPUnit *)sender
 canMoveToDir:(LPDirType)dir;
 */
@end

@interface LPUnit:NSObject
{
	id <LPUnitOwner> __owner;
	LPUnitColorType _color;
	LPDirType _d;
	BOOL _isBlowing;

@public
	float alpha; //hack
}

- (float) alpha;
- (void) setAlpha:(float)a;
- (id) initWithOwner:(id <LPUnitOwner>)owner
			   color:(LPUnitColorType)color
				   X:(int)x
				   Y:(int)y;
- (BOOL) attachUnit:(LPUnit *)anotherUnit;
- (BOOL) attachUnit:(LPUnit *)anotherUnit
		inDirection:(LPDirType)dir;
- (void) setX:(unsigned int)x
			Y:(unsigned int)y;
- (void) moveToDir:(LPDirType)dir;
- (void) round;
- (void) explode; // release self
- (void) drawRect:(NSRect)rect;
- (LPUnitColorType) unitColor;
- (BOOL) isBlowing;
- (void) blow;
- (void) setUnitColor:(LPUnitColorType)color;
- (int) rows;
- (int) columns;
@end

@interface LPJewelUnit:LPUnit
{
	int _x;
	int _y;
	int _rows;
	int _columns;
	float z;
}
- (id) initWithOwner:(id <LPUnitOwner>)owner
			   color:(LPUnitColorType)color
				   X:(int)x
				   Y:(int)y;

- (int) X;
- (int) Y;
- (float) phase;
@end

@interface LPSparkerUnit:LPJewelUnit
{
}
@end

@interface LPStoneUnit:LPJewelUnit
{
	int _count;
	/*
	NSMutableAttributedString *str[6];
	NSSize strSize[6];
	*/
}
@end

@interface LPGroupUnit:LPUnit <LPUnitOwner>
{
	LPDirType _laydir;
	NSArray *_units;
}

- (id) initWithOwner:(id <LPUnitOwner>)owner
			   atoms:(NSArray *)unitList;
- (int) X;
- (int) Y;
@end

@class LapisPuzzleView;

typedef enum _LPResultType
{
	LP_RESULT_REQUEST,
	LP_RESULT_GAMEOVER
} LPResultType;

@protocol LPViewOwner
- (void) lapisPuzzleView:(LapisPuzzleView *)sender
 didFinishUnitWithResult:(LPResultType)result;
@end

#define LP_FALLING_ITEMS 2
@interface LapisPuzzleView:NSView
{
	BOOL _gameOver;
	id <LPViewOwner> __owner;

	float _stepHeight;
	float _stepWidth;
	int _stepsInUnit;
	NSImage *_background;

	int _numberOfRows;
	int _numberOfColumns;

	id __currentUnit;

	NSMutableArray *_units;
	NSMutableArray *_blowing;

	int chain;
	int stone;
	int trip;
	int chaintrip;
	int maxchain;
	BOOL _useAI;
	BOOL _lockControl;
}

- (void) gameOver;

- (void) addJewelUnit;
- (void) round;


- (void) explodeUnit:(LPUnit *)unit; //unit retain;array remove;unit explode
@end

@interface LapisNextView:LapisPuzzleView
@end

#endif

/* 
   Project: Sudoku
   SudokuView.h

   Copyright (C) 2007-2011 The Free Software Foundation, Inc

   Author: Marko Riedel

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "Sudoku.h"

#define FIELD_DIM   54
#define FONT_SIZE   36
#define MARKUP_SIZE 10

@interface SudokuView : NSView
{
  Sudoku *sdk;
}

- initWithFrame:(NSRect)frame;
- (Sudoku *)sudoku;

- reset;
- loadSolution;

- (void)drawMarkupAtX:(int)x andY:(int)y;
- (void)drawString:(char *)str atX:(int)x andY:(int)y color:(NSColor *)col;
- (void)drawRect:(NSRect)rect;

- (void)mouseDown:(NSEvent *)theEvent;

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender;
- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender;

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender;


@end

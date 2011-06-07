/* 
   Project: Sudoku
   Document.h

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
#import <AppKit/NSDocument.h>
#import <AppKit/NSWindowController.h>

@class Sudoku;
@class SudokuView;

#define DOCTYPE  @"sudoku"

@interface Document : NSDocument
{
    SudokuView *sdkview;
    NSArray *lines;
}

- init;

- (NSData *)dataRepresentationOfType:(NSString *)aType;
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType;

- (void)makeWindowControllers;
- (void)windowControllerDidLoadNib:(NSWindowController *)aController;

- (Sudoku *)sudoku;
- (SudokuView *)sudokuView;

- resetPuzzle:(id)sender;
- solvePuzzle:(id)sender;


@end

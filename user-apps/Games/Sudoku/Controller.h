/* 
   Project: Sudoku
   Controller.h

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

#import "SudokuView.h"

typedef enum {
  MENU_NEW_20CLUES = 20,
  MENU_NEW_25CLUES = 25,
  MENU_NEW_30CLUES = 30,
  MENU_NEW_35CLUES = 35,
  MENU_NEW_48CLUES = 48,
  MENU_NEW_60CLUES = 60,
  MENU_NEW_70CLUES = 70,
} MENU_NEW;

@interface Controller: NSObject
{
    NSPanel *palette;
    NSPanel *enterPanel;
    SudokuView *sdkview;
}

- makeInputPanel;

- newPuzzle:(id)sender;

- actionEnter:(id)sender;
- actionReset:(id)sender;
- actionCancel:(id)sender;

- enterPuzzle:(id)sender;

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- makeDigitPalette;

@end


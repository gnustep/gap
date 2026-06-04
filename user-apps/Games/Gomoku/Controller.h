/*
 *  Controller.h: Controller Object of Gomoku.app
 *
 *  Copyright (c) 2000 Nicola Pero <n.pero@mi.flashnet.it>
 *  
 *  Author: Nicola Pero
 *  Date: April 2000
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

#ifndef INCLUDE_CONTROLLER_H
#define INCLUDE_CONTROLLER_H

#include "Board.h"
@class DifficultyPanel;

@interface Controller : NSWindow
{
  MainBoard *board;
  DifficultyPanel *diffPanel;
}

+ new: (int) cnt;
- init: (int) cnt;
- (void) applicationDidFinishLaunching: (NSNotification *)aNotification;
- (void) runDifficultyLevelPanel: (id)sender;
- (void) newGame: (id)sender;
@end

#endif

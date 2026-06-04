/*
 *  Board.h: Interface and declarations for the Board Class 
 *  of the GNUstep Gomoku game
 *
 *  Copyright (c) 2000 Nicola Pero <n.pero@mi.flashnet.it>
 *  
 *  Author: Nicola Pero
 *  Date: May 2000
 *
 *  Author: David Relson 
 *  Date: September 2000, modified for boards of arbitrary size
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

#ifndef INCLUDE_BOARD_H
#define INCLUDE_BOARD_H

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#ifndef GNUSTEP
# include "GNUstep.h"
#endif

/* 
 * BOARD 
 * The board has size rows and size columns.  
 */

/* 
 * These values describe the content of a board square.  A real board
 * square in the map may only contain 1 or 2 or 4.  In the strategy
 * engine we can | these values together to describe more vaguely a
 * board square (what I would call a 'generalized' board square).  Eg,
 * 6 means 'human OR computer', while 3 means 'void OR human'.  */
enum {
  nothing  = 1,
  human    = 2,
  computer = 4
};
typedef int tile;

/*
 * Compare two tiles (works with generalized tiles)
 */
#define COMPARE_TILE &

/*
 * We use 'patterns' to implement computer strategy.  A pattern is a
 * sequence of n 'generalized' tiles.  `n` is called the length of the
 * pattern.  */

/*
 * The central part of the engine looks in the board for a certain
 * pattern and returns a struct of the following type, describing
 * where the pattern was found.  */
typedef struct 
{
  /* Where the first point of the pattern is */
  int startRow;
  int startColumn;
  /* Direction: To move to next tile of the pattern, you add
   * directionRow to row and directionColumn to column.  So, (1, 0)
   * means from N to S, (0, 1) means from W to E, (1, 1) means from NW
   * to SE, (1, -1) means from NE to SW.  Other values are never
   * used. */
  int directionRow; 
  int directionColumn;
} patternPosition;
/* 
 * If no matches were found, startRow == -1 is returned 
 */
#define PATTERN_FOUND(X) (X.startRow != -1)

/*
 * Object representing a board (useful for computations and strategy
 * matters to create boards different from the real one) */
@interface Board : NSObject
{
  /* Difficulty level, between 0 and 5 */
  int difficultyLevel;

  /* The board */
  int   size;
  tile  *board;

  /* The board constants: if all else fails, higher levels prefer
     positions in the board with higher boardConstants.  boardConstants 
     are constant for a given size. */
  int *boardConstants;
  
  /* Last performed move, or -1 if none */
  int last_move_col;
  int last_move_row;
}
// Initialize, reset, set level
+ newWithRows:  (int)cnt;
- initWithRows: (int)cnt;
- (void) initBoardConstants;
- (void) reset;
- (void) setDifficultyLevel: (int)i;
- (int) difficultyLevel;
// Return YES if the board tile in (row i, column j) is free (that is,
// the user can move there); NO otherwise.
- (tile) tileInRow: (int)i  column: (int)j;
- (void) setTile: (tile)t inRow: (int)i column: (int)j;
// Return YES if the pattern t if in position pos of the board.
- (BOOL) isPattern: (const tile *)t
	    length: (int)e
	inPosition: (patternPosition)pos;
// The central part of the engine - see above for comments
// t *must* be of type const tile[], of length e
- (patternPosition) scanBoardForPattern: (const tile *)t
				 length: (int)e;
// Strategy
- (float) powerOfSquareInRow: (int)row column: (int)column;
// Perform a computer move
- (void) performComputerMove;
// This is the main Strategy Engine
- (BOOL) computerMoveInCrowdedPlace;
- (BOOL) computerOrHumanWinNext;
/* Last row and column computer moved to */
- (int) lastRow;
- (int) lastColumn;
@end

@interface MainBoard : NSObject
{
  /* YES if game is active, NO if not */
  BOOL isGameActive;

  /* Difficulty level, between 0 and 5 */
  int difficultyLevel;  

  /* The number of turns played.  When it exceeds (size * size) / 2, 
     the game ends [Quits] */
  int turnsPlayed;

  /* The main (real) board */
  int    size;
  Board *board;

  /* Our screen representation */
  NSMatrix *matrix;
}
// Initialization depends on the GUI used
- (id) initWithMatrix: (NSMatrix *)matrix;
/*
 * * The main event routine should report user input 
 * with the following methods.  
 *
 */
// Reset the game board and starts a new game.  Usually invoked when
// the user presses 'NewGame' or similar.  
- (void) newGame;
// Return YES if the board tile in (row i, column j) is free (that is,
// the user can move there); NO otherwise.
- (BOOL) isFreeRow: (int) i  column: (int) j;
// Enter a user move in (row i, column j).  If the tile is not free,
// do nothing.  Otherwise, place a user tile in that position, check
// if user has won, otherwise do a computer move, and check if
// computer has won.
- (void) userMoveInRow: (int) i  column: (int) j;
// Change difficulty level.  
// Valid levels are between 0 and 5.
// It can be safely changed while the game is running; 
// an higher difficulty level will use a better algorithm to 
// compute computer moves.
- (void) setDifficultyLevel: (int) i;
// Return current difficultyLevel
- (int) difficultyLevel;
/* 
 * Methods used to display the board. 
 * Override/rewrite the following methods (and the initWithMatrix: 
 * method) to port the game to another GUI framework.  
 */
// Change contents of (row i, column j) to display tile t (which can
// be nothing, computer or human, see enum above)
- (void) setTile: (tile) t
	   inRow: (int) i  
	  column: (int) j;
// Change contents of (row i, column j) to display a winning tile of
// type t (which can be nothing, computer or human, see enum above).
// This is invoked when one the two players win, to highlight the
// winning combination.
- (void) setWinningTile: (tile) t
		  inRow: (int) i
		 column: (int) j;
// Display an alert to the user through a pop up panel; typically
// invoked as: [self panel: @"Game Over" info: @"Human won"];
- (void) panel: (NSString *)s
	  info: (NSString *)t;
@end

#endif

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "tile.h"
#import "tilepair.h"

#define GAME_STATE_RUNNING     1
#define GAME_STATE_PAUSED      0

@interface GSBoard : NSView
{
  NSUserDefaults *defaults;
  NSMutableArray *scores;
  NSArray *iconsNamesRefs;
  NSMutableArray *tiles;
  GSTile *firstTile, *secondTile;
  NSTextField *timeField;
  NSTimer *tmr;
  int seconds, minutes;
  BOOL hadEndOfGame;
  NSMutableArray *undoArray;
  int gameState;
  int numScoresToKeep;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)newGame;
- (void)undo;
- (void)timestep:(NSTimer *)t;
- (int)prepareTilesToRemove:(GSTile *)clickedTile;
- (void)removeCurrentTiles;
- (BOOL)findPathBetweenTiles;
- (BOOL)findSimplePathFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2;
- (BOOL)canMakeLineFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2;
- (void)unSetCurrentTiles;
- (void)pause;
- (void)getHint;
- (void)verifyEndOfGame;
- (void)endOfGame;
- (NSArray *)tilesAtXPosition:(int)xpos;
- (NSArray *)tilesAtYPosition:(int)ypos;
- (GSTile *)tileAtxPosition:(int)xpos yPosition:(int)ypos;
- (int)gameState;
- (NSMutableArray *)scores;

@end


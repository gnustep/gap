#ifndef TILE_H
#define TILE_H

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

@class GSBoard;

@interface GSTile : NSView
{	
	NSImage *icon;
	NSString *iconName, *iconSelName;
	int group;
	NSNumber *rndpos;
	GSBoard *theBoard;
	BOOL isSelect, isActive, isBorderTile;
	int px, py;
}

- (id)initOnBoard:(GSBoard *)aboard 
			 iconRef:(NSString *)ref 
			 	group:(int)grp
			  rndpos:(int)rnd
	  isBorderTile:(BOOL)btile;
- (void)setPositionOnBoard:(int)x posy:(int)y;	
- (void)select;
- (void)hightlight;
- (void)unselect;
- (void)deactivate;
- (void)activate;
- (BOOL)isSelect;
- (BOOL)isActive;
- (BOOL)isBorderTile;
- (int)group;
- (NSNumber *)rndpos;
- (int)px;
- (int)py;

@end

#endif // TILE_H


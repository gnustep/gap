#include <AppKit/AppKit.h>
#include "AppController.h"
#include "StoneUI.h"
#include "Player.h"

@implementation AppController

- (void) applicationWillFinishLaunching: (NSNotification*)aNotification
{
	/* add human player */
	NSMutableDictionary *playerinfo = [NSMutableDictionary dictionary];
	Player *player;

	player = [Player new];
	[playerinfo setObject:@"Human Player"
				   forKey:@"Name"];
	[playerinfo setObject:AUTORELEASE([[NSImage alloc] initWithContentsOfFile:@"man_icon.png"])
				   forKey:@"Image"];
	[player setInfo:playerinfo];
	[playerController addPlayer:player];
	RELEASE(player);


	playerinfo = [NSMutableDictionary dictionary];
	player = [Player new];
	[playerinfo setObject:@"GNU Go"
				   forKey:@"Name"];
	[playerinfo setObject:AUTORELEASE([[NSImage alloc] initWithContentsOfFile:@"machine_icon.png"])
				   forKey:@"Image"];
	[player setInfo:playerinfo];
	[playerController addPlayer:player];
	RELEASE(player);

	NSLog(@"load clock");
	[NSBundle loadNibNamed:@"Clock"
					 owner:self];
	NSLog(@"load clock %@",clockController);
}

- (void) applicationDidFinishLaunching: (NSNotification*)aNotification
{
}

- (void) orderFrontInfoPanel: (id)sender
{
	[prefPanel center];
	[prefPanel orderFront: self];
}

- (void) orderFrontPlayerPanel: (id)sender
{
	[playerPanel center];
	[playerPanel orderFront: self];
}

- (void) orderFrontClockPanel: (id)sender
{
	[clockController orderFrontClockPanel:sender];
}


@end


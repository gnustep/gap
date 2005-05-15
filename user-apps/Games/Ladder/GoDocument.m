#include "GoDocument.h"
#include "GNUGoPlayer.h"

@implementation GoDocument

- (id) init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

- (void) awakeFromNib
{
	_players[BlackPlayerType] = [Player new];
	_players[WhitePlayerType] = [GNUGoPlayer new];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(turnBegin:)
												 name:GameTurnDidBeginNotification
											   object:[_board go]];
}

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:GameDidBecomeMainNotification
														object:[_board go]];
	NSLog(@"%@ %d", [_board go],[[_board go] retainCount]);;
}

- (void) windowDidResignMain: (NSNotification*)aNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:GameDidResignMainNotification
														object:[_board go]];
}

- (void) turnBegin:(NSNotification *)notification
{
	Go *go = [notification object];
	PlayerColorType turn = [go turn];
	[_players[turn] playGo:go
			  forColorType:turn];
}

- (void) playerShouldPutStoneAtLocation:(GoLocation)location
{
	Go *go = [_board go];
	PlayerColorType turn = [go turn];

	[_players[turn] playGo:go
	  withStoneOfColorType:turn
				atLocation:location];
}

- (void) dealloc
{
	NSLog(@"dealloc GoDocument %@ %d",self,[_board retainCount]);
//	RELEASE(_board);
	[super dealloc];
	NSLog(@"done degodoc");
}

/*
- (NSFileWrapper *)fileWrapperRepresentationOfType:(NSString *)type
{
	if ([type isEqualToString:@"sgf"])
	{
	}
	else
	{
		return [super fileWrapperRepresentationOfType:type];
	}
}
*/

- (NSString *) windowNibName
{
	return @"GoDocument";
}

//- (void) windowControllerDidLoadNib:(NSWindowController *) aController

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
	return nil;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	return YES;
}

- (void) setPlayer:(Player *)player
	  forColorType:(PlayerColorType)color
{
	ASSIGN(_players[color], player);
}

@end

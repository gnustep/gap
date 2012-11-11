/*
   Project: MPDCon

   Copyright (C) 2012

   Author: Sebastian Reitenbach

   Created: 2012-10-31

   Playlist Inspector

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#include <AppKit/AppKit.h>
#include "PlaylistInspector.h"
#include "SongRatingCell.h"
#include "Strings.h"
#include "CollectionController.h"

@implementation PlaylistInspector

+ (id) sharedPlaylistInspector
{
  static PlaylistInspector *_sharedPlaylistInspector = nil;

  if (! _sharedPlaylistInspector) {
      _sharedPlaylistInspector = 
	[[PlaylistInspector allocWithZone: [self zone]] init];
  }

  return _sharedPlaylistInspector;
}

- (id) init
{
  self = [self initWithWindowNibName: @"PlaylistInspector"];

  if (self)
    {
      [self setWindowFrameAutosaveName: @"PlaylistInspector"];
      defaults = [NSUserDefaults standardUserDefaults];
    }

  mpdController = [MPDController sharedMPDController];
  playlistController = [PlaylistController sharedPlaylistController];
  threadlock = [NSLock new];

  return self;
}

- (void) dealloc
{
  RELEASE(minRatingCol);
  RELEASE(maxRatingCol);
  RELEASE(defaults);
  RELEASE(threadlock);

  [super dealloc];
}

/* GUI methods */
- (void) awakeFromNib
{
  NSNotificationCenter *defCenter;

  SongRatingCell *minRatingCell;
  SongRatingCell *maxRatingCell;

  ASSIGN(minRatingCol, [minRatingStars tableColumnWithIdentifier: @"minrating"]);
  ASSIGN(maxRatingCol, [maxRatingStars tableColumnWithIdentifier: @"maxrating"]);
  [minRatingStars setAutosaveName: @"MinRatingStarsTable"];
  [minRatingStars setAutosaveTableColumns: YES];
  [minRatingStars setHeaderView: nil];
  [minRatingStars setTarget:self];
  [maxRatingStars setAutosaveName: @"MaxRatingStarsTable"];
  [maxRatingStars setAutosaveTableColumns: YES];
  [maxRatingStars setHeaderView: nil];
  [maxRatingStars setTarget:self];

  defCenter = [NSNotificationCenter defaultCenter];
  [defCenter addObserver: self
                selector: @selector(songChanged:)
                    name: SongChangedNotification
                  object: nil];
  [defCenter addObserver: self
                selector: @selector(playlistChanged:)
                    name: PlaylistChangedNotification
                  object: nil];

  minRatingCell = [[SongRatingCell alloc] init];
  maxRatingCell = [[SongRatingCell alloc] init];
  [minRatingCol setDataCell:minRatingCell];
  [maxRatingCol setDataCell:maxRatingCell];

  [randomPlaylistFeed setState: [defaults integerForKey: @"RandomPlaylistFeed"]];
  [ratingBasedFeed setState: [defaults integerForKey: @"RatingBasedFeed"]];
  [nrNewSongs setStringValue:  [NSString stringWithFormat:@"%i", [defaults integerForKey: @"NrOfFutureSongs"]]];
  [nrPlayedSongs setStringValue: [NSString stringWithFormat:@"%i", [defaults integerForKey: @"NrOfOldSongsToKeep"]]];

  if (![randomPlaylistFeed state])
    {
      [nrNewSongs setEditable: NO];
      [nrPlayedSongs setEditable: NO];
      [ratingBasedFeed setEnabled:NO];
      // the stuff below doesn't work like expected, also setEnabled: NO doesn't seem to work either
      [minRatingCell setEditable: NO];
      [maxRatingCell setEditable: NO];
    }
  else
    {
      if (![ratingBasedFeed state])
	{
          // the stuff below doesn't work like expected, also setEnabled: NO doesn't seem to work either
          [minRatingCell setEditable: NO];
          [maxRatingCell setEditable: NO];
	}
    }

  [self updatePlaylistInspector];
}

- (void) nrOfFutureSongsChanged: (id) sender
{
  [defaults setInteger: [nrNewSongs integerValue] forKey:@"NrOfFutureSongs"];
  [defaults synchronize];
}
- (void) nrOfOldSongsToKeepChanged: (id) sender
{
  [defaults setInteger: [nrPlayedSongs integerValue] forKey:@"NrOfOldSongsToKeep"];
  [defaults synchronize];
}
- (void) randomPlaylistFeedStateChanged: (id) sender
{
  [defaults setInteger: [randomPlaylistFeed state] forKey:@"RandomPlaylistFeed"];
  [defaults synchronize];
  if ([randomPlaylistFeed state])
    {
      [nrNewSongs setEditable: YES];
      [nrPlayedSongs setEditable: YES];
      [ratingBasedFeed setEnabled:YES];
      if ([ratingBasedFeed state])
        {
//          [minRatingCell setEditable: YES];
//          [maxRatingCell setEditable: YES];
        }
    }
  else
    {
      [nrNewSongs setEditable: NO];
      [nrPlayedSongs setEditable: NO];
      [ratingBasedFeed setEnabled:NO];
      // the stuff below doesn't work like expected, also setEnabled: NO doesn't seem to work either
//      [minRatingCell setEditable: NO];
//      [maxRatingCell setEditable: NO];
    }
}
- (void) ratingBasedFeedStateChanged: (id) sender
{
  [defaults setInteger: [ratingBasedFeed state] forKey:@"RatingBasedFeed"];
  [defaults synchronize];
  // the disabling is not working, they seem to be always enabled
  if ([ratingBasedFeed state])
    {
//      [minRatingCell setEditable: YES];
//      [maxRatingCell setEditable: YES];
    }
  else
    {
//      [minRatingCell setEditable: NO];
//      [maxRatingCell setEditable: NO];
    }
}


/* the delegate methods */
- (void) songChanged:(NSNotification *)aNotif
{
  [self updateCurrentSongNr];
  [self startPlaylistUpdateThread];
}

- (void) playlistChanged:(NSNotification *)aNotif
{
  [self updatePlaylistInfo];
  [self startPlaylistUpdateThread];
}

- (void) updateCurrentSongNr
{
  [currentSongNr setStringValue:[NSString stringWithFormat:@"%i", [mpdController getCurrentSongNr]]];
}

- (void) updatePlaylistInfo
{
  [playlistPlayingTime setStringValue: [playlistController playlistLength]];
  [nrOfSongsInPlaylist setStringValue: [NSString stringWithFormat:@"%i", [mpdController getPlaylistLength]]];
  [self updateCurrentSongNr];
}



- (void) updatePlaylistInspector
{
  [minRatingStars reloadData];
  [maxRatingStars reloadData];
  [playlistPlayingTime setStringValue: [playlistController playlistLength]];
  [currentSongNr setStringValue:[NSString stringWithFormat:@"%i", [mpdController getCurrentSongNr]]];
  [nrOfSongsInPlaylist setStringValue: [NSString stringWithFormat:@"%i", [mpdController getPlaylistLength]]];
  return;
}

- (NSInteger) numberOfRowsInTableView: (NSTableView *)tableView
{
    return 1;
}

-          (id) tableView: (NSTableView *) tableView
objectValueForTableColumn: (NSTableColumn *) tableColumn
		      row: (NSInteger) row
{
  NSString *identifier;

  identifier = [tableColumn identifier];

  if ([identifier isEqual:@"minrating"])
    {
      return [NSNumber numberWithInteger: 
	[defaults integerForKey: @"RandomPlaylistMinRating"]?[defaults integerForKey: @"RandomPlaylistMinRating"]:0];
    }
  else
    {
      return [NSNumber numberWithInteger: 
	[defaults integerForKey: @"RandomPlaylistMaxRating"]?[defaults integerForKey: @"RandomPlaylistMaxRating"]:5];
    }
}

// method below doesn't get called, its actually intended
// to disable the editing of the rating stars...
- (BOOL) tableView: (NSTableView *)
shouldEditTableColumn: (NSTableColumn *)aTableColumn
	       row:(int)rowIndex
{
NSLog(@"shouldEditTableColumn got called!!");
  if ([randomPlaylistFeed state] && [ratingBasedFeed state]) 
    {
      return YES;
    }
  else
    {
      return NO;
    }
}


-(void) tableView: (NSTableView *) aTableView
   setObjectValue: (id) anObj
   forTableColumn: (NSTableColumn *) aTableColumn
              row: (NSInteger) rowIndex
{
    if (aTableColumn == minRatingCol) {
        /* We can't keep that as an assertion now, as it can easily fail when
         * the broken GNUstep NSTableView lets you edit the string value for the cell.
         */
        if ([anObj isKindOfClass: [NSNumber class]] == NO) {
            NSLog(@"Warning: %@ is not a number value.", anObj);
        }
	[defaults setInteger: [anObj intValue] forKey:@"RandomPlaylistMinRating"];
    } else if (aTableColumn == maxRatingCol) {
        /* We can't keep that as an assertion now, as it can easily fail when
         * the broken GNUstep NSTableView lets you edit the string value for the cell.
         */
        if ([anObj isKindOfClass: [NSNumber class]] == NO) {
            NSLog(@"Warning: %@ is not a number value.", anObj);
        }
	[defaults setInteger: [anObj intValue] forKey:@"RandomPlaylistMaxRating"];
    }
    [defaults synchronize];
}

// Thread stuff to update the playlist in the background
- (void) playlistUpdateThread
{
  NSAutoreleasePool *pool;
  NSArray * allSongs;
  NSArray * currentPlaylist;
  NSInteger diffOldSongs, diffFutureSongs;

  if (![threadlock tryLock])
    {
      return;
    }

  pool = [NSAutoreleasePool new];
  currentPlaylist = [[NSArray alloc] init];
  allSongs = [[NSArray alloc] init];
  currentPlaylist = [mpdController getPlaylist];
  allSongs = [[CollectionController sharedCollectionController] getAllTracks];

  diffFutureSongs = [nrOfSongsInPlaylist integerValue] - 
				[currentSongNr integerValue];
  if (diffFutureSongs < [nrNewSongs integerValue])
    {
	NSInteger i;
	for (i=0;i<[nrNewSongs integerValue] - diffFutureSongs;i++)
	  {
	    BOOL newAdded = NO;
	    while (newAdded != YES)
	      {
	        NSString *trackFilename;
		NSEnumerator *playlistEnumerator;
		PlaylistItem *plItem;
		BOOL alreadyExists = NO;
	        NSUInteger random = arc4random() % [allSongs count];
	        trackFilename = [[allSongs objectAtIndex: random] getPath];
		// now check if the new song is already in the playlist
		playlistEnumerator = [currentPlaylist objectEnumerator];
		while ((plItem = [playlistEnumerator nextObject]))
		  {
		    if ([trackFilename isEqual: [plItem getPath]])
		      {
			alreadyExists = YES;
			break;
		      }
		  }
		if (alreadyExists == YES)
		  {
		    continue;
		  }
		[mpdController addTrack:trackFilename];
		newAdded = YES;
	      }
	  }
    }
  
  diffOldSongs = [currentSongNr integerValue] - [nrPlayedSongs integerValue];
  if (diffOldSongs > 0)
    {
      NSRange songRange = NSMakeRange(0, diffOldSongs - 1);
      [mpdController removeSongRange:songRange];
    }
  [threadlock unlock];
  [pool release];
}

- (BOOL) startPlaylistUpdateThread
{
  [NSThread detachNewThreadSelector: @selector (playlistUpdateThread)
                           toTarget: self
                         withObject: nil];
  return YES;
}


@end

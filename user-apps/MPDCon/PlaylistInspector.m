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
  if ((self = [self initWithWindowNibName: @"PlaylistInspector"]) != nil)
    {
      [self setWindowFrameAutosaveName: @"PlaylistInspector"];
      defaults = [NSUserDefaults standardUserDefaults];
      mpdController = [MPDController sharedMPDController];
      playlistController = [PlaylistController sharedPlaylistController];
      threadlock = [NSLock new];
    }
  return self;
}

- (void) dealloc
{
  [minRatingCol release];
  [maxRatingCol release];
  [defaults release];
  [threadlock release];

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
  [includeUnratedSongs setState: [defaults integerForKey: @"IncludeUnratedSongs"]];
  [nrNewSongs setStringValue:  [NSString stringWithFormat:@"%"PRIiPTR, [defaults integerForKey: @"NrOfFutureSongs"]?
		[defaults integerForKey: @"NrOfFutureSongs"]:20]];
  [nrPlayedSongs setStringValue: [NSString stringWithFormat:@"%"PRIiPTR, [defaults integerForKey: @"NrOfOldSongsToKeep"]?
		[defaults integerForKey: @"NrOfOldSongsToKeep"]:20]];

  if (![randomPlaylistFeed state])
    {
      [nrNewSongs setEditable: NO];
      [nrPlayedSongs setEditable: NO];
      [nrOfNewSongsText setEnabled: NO];
      [nrOfPlayedSongsText setEnabled: NO];
      [ratingBasedFeed setEnabled:NO];
      [minRatingText setEnabled: NO];
      [maxRatingText setEnabled: NO];
      [includeUnratedSongs setEnabled:NO];
      // the stuff below doesn't work like expected, also setEnabled: NO doesn't seem to work either
      [minRatingCell setEditable: NO];
      [maxRatingCell setEditable: NO];
    }
  else
    {
      if (![ratingBasedFeed state])
	{
          // the stuff below doesn't work like expected
	  // also setEnabled: NO doesn't seem to work either
          [minRatingText setEnabled: NO];
          [maxRatingText setEnabled: NO];
          [minRatingCell setEditable: NO];
          [maxRatingCell setEditable: NO];
          [includeUnratedSongs setEnabled:NO];
	}
    }
  [self updatePlaylistInspector];
  RELEASE(minRatingCell);
  RELEASE(maxRatingCell);
}

- (void) nrOfFutureSongsChanged: (id) sender
{
  [defaults setInteger: [nrNewSongs integerValue] forKey:@"NrOfFutureSongs"];
  [defaults synchronize];
  [self sendRandomPlaylistFeedDefaultsChangedNotification];
}
- (void) nrOfOldSongsToKeepChanged: (id) sender
{
  [defaults setInteger: [nrPlayedSongs integerValue] forKey:@"NrOfOldSongsToKeep"];
  [defaults synchronize];
  [self sendRandomPlaylistFeedDefaultsChangedNotification];
}
- (void) randomPlaylistFeedStateChanged: (id) sender
{
  [defaults setInteger: [randomPlaylistFeed state] forKey:@"RandomPlaylistFeed"];
  [defaults synchronize];
  [self sendRandomPlaylistFeedDefaultsChangedNotification];
  if ([randomPlaylistFeed state])
    {
      [nrNewSongs setEditable: YES];
      [nrPlayedSongs setEditable: YES];
      [nrOfNewSongsText setEnabled: YES];
      [nrOfPlayedSongsText setEnabled: YES];
      [ratingBasedFeed setEnabled:YES];
      if ([ratingBasedFeed state])
        {
          [minRatingStars setEnabled: YES];
          [maxRatingStars setEnabled: YES];
          [minRatingText setEnabled: YES];
          [maxRatingText setEnabled: YES];
          [includeUnratedSongs setEnabled:YES];
        }
    }
  else
    {
      [nrNewSongs setEditable: NO];
      [nrPlayedSongs setEditable: NO];
      [nrOfNewSongsText setEnabled: NO];
      [nrOfPlayedSongsText setEnabled: NO];
      [ratingBasedFeed setEnabled:NO];
      // the stuff below doesn't work like expected, also setEnabled: NO doesn't seem to work either
      [maxRatingStars setEnabled: NO];
      [minRatingStars setEnabled: NO];
      [minRatingText setEnabled: NO];
      [maxRatingText setEnabled: NO];
      [includeUnratedSongs setEnabled:NO];
    }
}
- (void) ratingBasedFeedStateChanged: (id) sender
{
  [defaults setInteger: [ratingBasedFeed state] forKey:@"RatingBasedFeed"];
  [defaults synchronize];
  [self sendRandomPlaylistFeedDefaultsChangedNotification];
  // the disabling is not working, they seem to be always enabled
  if ([ratingBasedFeed state])
    {
      [maxRatingStars setEnabled: YES];
      [minRatingStars setEnabled: YES];
      [minRatingText setEnabled: YES];
      [maxRatingText setEnabled: YES];
      [includeUnratedSongs setEnabled:YES];
    }
  else
    {
      [maxRatingStars setEnabled: NO];
      [minRatingStars setEnabled: NO];
      [minRatingText setEnabled: NO];
      [maxRatingText setEnabled: NO];
      [includeUnratedSongs setEnabled:NO];
    }
}

- (void) includeUnratedSongsChanged: (id) sender
{
  [defaults setInteger: [includeUnratedSongs state] forKey:@"IncludeUnratedSongs"];
  [defaults synchronize];
  [self sendRandomPlaylistFeedDefaultsChangedNotification];
}

/* the delegate methods */
- (void) songChanged:(NSNotification *)aNotif
{
  [self updateCurrentSongNr];
}

- (void) playlistChanged:(NSNotification *)aNotif
{
  [self updatePlaylistInfo];
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
	[defaults integerForKey: @"RandomPlaylistMinRating"]];
    }
  else
    {
      return [NSNumber numberWithInteger: 
	[defaults integerForKey: @"RandomPlaylistMaxRating"]?[defaults integerForKey: @"RandomPlaylistMaxRating"]:5];
    }
}

// method below doesn't get called, its actually intended
// to disable the editing of the rating stars...
- (BOOL) tableView: (NSTableView *) tableView
shouldEditTableColumn: (NSTableColumn *)aTableColumn
	       row:(NSInteger)rowIndex
{
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
    [self sendRandomPlaylistFeedDefaultsChangedNotification];
}

- (void) sendRandomPlaylistFeedDefaultsChangedNotification
{
  NSNotification *aNotif;
  aNotif = [NSNotification notificationWithName:
			RandomPlaylistFeedDefaultsChangedNotification
                        object: nil];
  [[NSNotificationCenter defaultCenter]
    postNotification: aNotif];
}
@end

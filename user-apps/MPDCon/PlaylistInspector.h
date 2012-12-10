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
#include "MPDController.h"
#include "PlaylistController.h"

@interface PlaylistInspector : NSWindowController
{
  IBOutlet NSTableView *maxRatingStars;
  IBOutlet NSTableView *minRatingStars;

  id currentSongNr;
  id nrOfSongsInPlaylist;
  id nrNewSongs;
  id nrPlayedSongs;
  id playlistPlayingTime;
  id randomPlaylistFeed;
  id ratingBasedFeed;

  MPDController *mpdController;
  PlaylistController *playlistController;
  NSTableColumn *minRatingCol;
  NSTableColumn *maxRatingCol;
  NSUserDefaults *defaults;
  NSLock *threadlock;
}
+ (id) sharedPlaylistInspector;

- (void) updateCurrentSongNr;
- (void) updatePlaylistInfo;
- (void) updatePlaylistInspector;
- (void) songChanged:(NSNotification *)aNotif;

// Gui Methods
- (void) nrOfFutureSongsChanged: (id)sender;
- (void) nrOfOldSongsToKeepChanged: (id)sender;
- (void) randomPlaylistFeedStateChanged: (id)sender;
- (void) ratingBasedFeedStateChanged: (id)sender;
- (void) sendRandomPlaylistFeedDefaultsChangedNotification;
@end

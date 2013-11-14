/*
   Project: MPDCon

   Copyright (C) 2012

   Author: sebastian Reitenbach

   Created: 2012-09-02

   Lyrics Inspector

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
#include "SongInspector.h"
#include "PlaylistItem.h"

@implementation SongInspector
+ (id) sharedSongInspector
{
  static SongInspector *_sharedSongInspector = nil;

  if (! _sharedSongInspector) {
      _sharedSongInspector = [[SongInspector allocWithZone: [self zone]] init];
  }

  return _sharedSongInspector;
}

- (id) init
{
  if ((self = [self initWithWindowNibName: @"SongInspector"]) != nil)
    {
      [self setWindowFrameAutosaveName: @"SongInspector"];
      mpdController = [MPDController sharedMPDController];
    }
  return self;
}

/* GUI methods */
- (void) awakeFromNib
{
  NSNotificationCenter *defCenter;
  defCenter = [NSNotificationCenter defaultCenter];
  [defCenter addObserver: self
                selector: @selector(songChanged:)
                    name: SongChangedNotification
                  object: nil];

  [self updateSongInfo];
}

/* the delegate methods */
- (void) songChanged:(NSNotification *)aNotif
{
  [self updateSongInfo];
}

- (void) updateSongInfo
{
  PlaylistItem *currentSong;

  currentSong = [mpdController getCurrentSong];

  [artist setStringValue:[currentSong getArtist]];
  [title setStringValue:[currentSong getTitle]];
  [album setStringValue:[currentSong getAlbum]];
  [genre setStringValue:[currentSong getGenre]];
  [track setStringValue:[currentSong getTrackNr]];
  [filename setStringValue:[currentSong getPath]];
  [date setStringValue:[currentSong getDate]];
  [composer setStringValue:[currentSong getComposer]];
  [performer setStringValue:[currentSong getPerformer]];
  [disc setStringValue:[currentSong getDisc]];
  [comment setStringValue:[currentSong getComment]];
}

@end

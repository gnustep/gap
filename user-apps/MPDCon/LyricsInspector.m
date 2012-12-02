/*
   Project: MPDCon

   Copyright (C) 2012

   Author: Sebastian Reitenbach

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
#include "LyricsInspector.h"
#include "PlaylistItem.h"

@implementation LyricsInspector

/* --------------------------
   - Initialization Methods -
   --------------------------*/
+ (id) sharedLyricsInspector
{
  static LyricsInspector *_sharedLyricsInspector = nil;

  if (! _sharedLyricsInspector) {
      _sharedLyricsInspector = [[LyricsInspector allocWithZone: [self zone]] init];
  }

  return _sharedLyricsInspector;
}

- (id) init
{
  self = [self initWithWindowNibName: @"LyricsInspector"];

  if (self) {
      [self setWindowFrameAutosaveName: @"LyricsInspector"];
  }
  mpdController = [MPDController sharedMPDController];

  return self;
}

- (void) dealloc
{
  RELEASE(lyricsURL);

  [super dealloc];
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

  [self updateLyrics];
}



/* the method behind the button */
- (void) openURL: (id)sender
{
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: lyricsURL]];
}

/* the delegate methods */
- (void) songChanged:(NSNotification *)aNotif
{
  [self updateLyrics];
}

- (void) updateLyrics
{
  PlaylistItem *currentSong;
  NSDictionary *lyrics;

  currentSong = [mpdController getCurrentSong];
  [artist setStringValue:[currentSong getArtist]];
  [title setStringValue:[currentSong getTitle]];

  lyrics = [currentSong getLyrics];
  [lyricsText setStringValue: [lyrics objectForKey:@"lyricsText"]];
  lyricsURL = [[lyrics objectForKey:@"lyricsURL"] copy];

  return;
}
@end

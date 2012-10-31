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
#include "Strings.h"

@implementation PlaylistInspector

+ (id) sharedPlaylistInspector
{
  static PlaylistInspector *_sharedPlaylistInspector = nil;

  if (! _sharedPlaylistInspector) {
      _sharedPlaylistInspector = [[PlaylistInspector allocWithZone: [self zone]] init];
  }

  return _sharedPlaylistInspector;
}

- (id) init
{
  self = [self initWithWindowNibName: @"PlaylistInspector"];

  if (self) {
      [self setWindowFrameAutosaveName: @"PlaylistInspector"];
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

  [self updatePlaylistInspector];
}

/* the delegate methods */
- (void) songChanged:(NSNotification *)aNotif
{
  [self updatePlaylistInspector];
}

- (void) updatePlaylistInspector
{
  // nothing yet
  return;
}


@end

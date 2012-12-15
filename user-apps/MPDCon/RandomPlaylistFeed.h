/*
   Project: MPDCon

   Copyright (C) 2012

   Author: Sebastian Reitenbach

   Created: 2012-10-31

   Random playlist feeder

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
#import "MPDController.h"

@interface RandomPlaylistFeed: NSObject
{
  NSUserDefaults *defaults;
  BOOL randomPlaylistFeed;
  BOOL ratingBasedFeed;
  BOOL includeUnratedSongs;
  NSInteger nrNewSongs;
  NSInteger nrPlayedSongs;
  NSInteger maxRating;
  NSInteger minRating;
  NSLock *threadLock;

  // stuff needed for the thread to connect to the MPD Server
  MPDController *threadMPDController;
  NSString *host;
  NSString *port;
  NSString *pword;
  NSString *tout;
}
- (void) updateDefaults:(NSNotification *)aNotif;
- (void) songChanged:(NSNotification *)aNotif;
- (void) playlistUpdateThread;
@end

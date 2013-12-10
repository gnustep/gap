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

#import "RandomPlaylistFeed.h"
#import "MPDController.h"
#import "Strings.h"

#if defined(NEED_BSD_H)
#include <bsd/bsd.h>
#endif

@implementation RandomPlaylistFeed
- (id) init
{
  NSNotificationCenter *defCenter;

  if ((self = [super init]) != nil)
    {
      defaults = [NSUserDefaults standardUserDefaults];
      defCenter = [NSNotificationCenter defaultCenter];
      [defCenter addObserver: self
                selector: @selector(songChanged:)
                    name: SongChangedNotification
                  object: nil];
      [defCenter addObserver: self
                selector: @selector(updateDefaults:)
                    name: RandomPlaylistFeedDefaultsChangedNotification
                  object: nil];
      threadLock = [NSLock new];
      [self updateDefaults: nil];
      // setup the connection to MPD for the thread
      threadMPDController = [[MPDController alloc] init];

      host = [[NSUserDefaults standardUserDefaults]
           objectForKey: @"mpdHost"];
      port = [[NSUserDefaults standardUserDefaults]
           objectForKey: @"mpdPort"];
      tout = [[NSUserDefaults standardUserDefaults]
           objectForKey: @"mpdTimeout"];
      pword = nil;
      if ([[NSUserDefaults standardUserDefaults]
                integerForKey: @"usePassword"] != 0)
        {
          pword = [[NSUserDefaults standardUserDefaults]
                objectForKey: @"mpdPassword"];
        }
      [threadMPDController connectToServer:host
	  			      port:port
			          password:pword
			           timeout:tout];
      [self songChanged:nil];
    }
  return self;
}

- (void) dealloc
{
  [defaults release];
  [threadLock release];
  [threadMPDController release];
  [host release];
  [port release];
  [pword release];
  [tout release];
  [super dealloc];
}

// Notification methods
- (void) updateDefaults:(NSNotification *)aNotif
{
  randomPlaylistFeed = [defaults boolForKey: @"RandomPlaylistFeed"];  
  ratingBasedFeed = [defaults boolForKey: @"RatingBasedFeed"];
  includeUnratedSongs = [defaults boolForKey: @"IncludeUnratedSongs"];
  nrNewSongs =  [defaults integerForKey: @"NrOfFutureSongs"] ? 
		[defaults integerForKey: @"NrOfFutureSongs"]:20;
  nrPlayedSongs = [defaults integerForKey: @"NrOfOldSongsToKeep"] ?
		[defaults integerForKey: @"NrOfOldSongsToKeep"]:20;
  maxRating = [defaults integerForKey: @"RandomPlaylistMaxRating"] ? 
		[defaults integerForKey: @"RandomPlaylistMaxRating"]:5;
  minRating = [defaults integerForKey: @"RandomPlaylistMinRating"];
}

- (void) songChanged:(NSNotification *)aNotif
{
  if ([defaults integerForKey: @"RandomPlaylistFeed"])
    {
  [NSThread detachNewThreadSelector: @selector (playlistUpdateThread)
                           toTarget: self
                         withObject: nil];
    }
}

- (void) playlistUpdateThread
{
  NSAutoreleasePool *pool;
  NSArray *allSongs;
  NSArray *currentPlaylist;
  int diffOldSongs, diffFutureSongs;
  int nrOfSongsInPlaylist, currentSongNr;

  if (![threadLock tryLock])
    {
      return;
    }

  pool = [NSAutoreleasePool new];
  currentPlaylist = [[threadMPDController getPlaylist] copy];
  allSongs = [[threadMPDController getAllTracksWithMetadata: NO] copy];
  nrOfSongsInPlaylist = [threadMPDController getPlaylistLength];
  currentSongNr = [threadMPDController getCurrentSongNr];

  if (!allSongs)
    {
      NSLog(@"unable to get allSongs from the Collection!!!");
      [threadLock unlock];
      [allSongs release];
      [currentPlaylist release];
      [pool release];
      return;
    }
  diffFutureSongs = nrOfSongsInPlaylist - currentSongNr;
  if (diffFutureSongs < nrNewSongs)
    {
        int i;
        for (i=0;i<nrNewSongs - diffFutureSongs;i++)
          {
            BOOL newAdded = NO;
            while (newAdded != YES)
              {
                NSString *trackFilename;
                NSEnumerator *playlistEnumerator;
                PlaylistItem *plItem;
                BOOL addThisTrack = YES;
                NSUInteger random = arc4random() % [allSongs count];
                trackFilename = [[[allSongs objectAtIndex: random] getPath] copy];

                // now check if the new song is already in the playlist
                playlistEnumerator = [currentPlaylist objectEnumerator];
                while ((plItem = [playlistEnumerator nextObject]))
                  {
                     if ([trackFilename isEqual: [plItem getPath]])
                       {
                         addThisTrack = NO;
			 RELEASE(trackFilename);
                         break;
                       }
                  }
		if (addThisTrack == YES && ratingBasedFeed == YES)
		  {
		     NSInteger rating;
		     PlaylistItem *newItem;
	             newItem = [[PlaylistItem alloc] init];
		     [newItem setPath:trackFilename];
		     rating = [newItem getRating];
                     if (rating < minRating || rating > maxRating)
		       {
		         if (rating == 0 && includeUnratedSongs == YES)
			   {
			     addThisTrack = YES;
			   }
			 else
			   {
			     addThisTrack = NO;
			   }
		       }
		     [newItem release];
		  }
                if (addThisTrack == NO)
                  {
                    continue;
                  }
                [threadMPDController addTrack:trackFilename];
	        RELEASE(trackFilename);
                newAdded = YES;
              }
          }
    }
 
  diffOldSongs = currentSongNr - nrPlayedSongs;
  if (diffOldSongs > 0)
    {
      NSRange songRange = NSMakeRange(0, diffOldSongs - 1);
      [threadMPDController removeSongRange:songRange];
    }
  [allSongs autorelease];
  [currentPlaylist autorelease];
  [pool release];
  [threadLock unlock];
}

@end

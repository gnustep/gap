/*
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-14 11:37:03 +0200 by flip

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

#include <unistd.h>
#include "MPDController.h"

/* ---------------------
   - Private Interface -
   ---------------------*/
@interface MPDController(Private)

- (BOOL) _doConnect;
- (BOOL) _checkConnection;

- (PlaylistItem *) _getPlaylistItemForSong: (const struct mpd_song *)anSong;

int _stringSort(id string1, id string2, void *context);
@end

@implementation MPDController

/* --------------------------
   - Initialization Methods -
   --------------------------*/

+ (id) sharedMPDController
{
  static MPDController *_sharedMPDController = nil;

  if (! _sharedMPDController) 
    {
      _sharedMPDController = [[MPDController allocWithZone: [self zone]] init];
    }

  return _sharedMPDController;
}

- (void) dealloc
{
  mpd_connection_free(mpdConnection);

  RELEASE(host);
  RELEASE(port);
  RELEASE(password);
  RELEASE(timeout);

  [super dealloc];
}

/* ----------------------
   - Connection Methods -
   ----------------------*/

- (BOOL) connectToServer: (NSString *)hostName 
                    port: (NSString *)portNr 
                password: (NSString *)pword
                 timeout: (NSString *)tout
{
  if ((hostName) && (portNr) && (tout)) {
      BOOL didConnect;

      if (host) {
	  RELEASE(host);
      }
      if (port) {
	  RELEASE(port);
      }
      if (password) {
	  RELEASE(password);
      }
      if (port) {
	  RELEASE(timeout);
      }
      host = [hostName copy];
      port = [portNr copy];
      password = [pword copy];
      timeout = [tout copy];
    
      didConnect = [self _doConnect];
      return didConnect;
  } else {
      return NO;
  }
}

/* ----------------
   - Play Methods -
   ----------------*/

- (void) play
{
  [self playSong: -1];
}

- (void) playSong: (int)theSong
{
  struct mpd_status *mpdStatus;

  if (![self _checkConnection]) {
      return;
  }
  if (theSong != -1) {
    mpd_send_play_pos(mpdConnection, theSong);
  } else {

    mpdStatus = mpd_run_status(mpdConnection);
    if (mpdStatus != NULL) {
      if(mpd_status_get_state(mpdStatus) == MPD_STATE_STOP) {
        mpd_send_play(mpdConnection);
      } else {
        mpd_send_toggle_pause(mpdConnection);
      }
      mpd_response_finish(mpdConnection);
      mpd_status_free(mpdStatus);
    }
  }
}

- (void) stop
{
  struct mpd_status *mpdStatus;

  if (! [self _checkConnection]) 
    {
      return;
    }

  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) {
    if((mpd_status_get_state(mpdStatus) == MPD_STATE_PLAY) || 
      (mpd_status_get_state(mpdStatus) == MPD_STATE_PAUSE)) {
        mpd_send_stop(mpdConnection);
        mpd_response_finish(mpdConnection);
    }
    mpd_status_free(mpdStatus);
  }
}

- (void) prev
{
  struct mpd_status *mpdStatus;
  
  if (! [self _checkConnection]) 
    {
      return;
    }
  
  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) {
    if((mpd_status_get_state(mpdStatus) == MPD_STATE_PLAY) || 
      (mpd_status_get_state(mpdStatus) == MPD_STATE_PAUSE)) {
        mpd_send_previous(mpdConnection);
        mpd_response_finish(mpdConnection);
    }
    mpd_status_free(mpdStatus);
  }
}

- (void) next
{
  struct mpd_status *mpdStatus;
  
  if (! [self _checkConnection]) 
    {
      return;
    }

  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) {
    if((mpd_status_get_state(mpdStatus) == MPD_STATE_PLAY) || 
      (mpd_status_get_state(mpdStatus) == MPD_STATE_PAUSE)) {
        mpd_send_next(mpdConnection);
        mpd_response_finish(mpdConnection);
    }
    mpd_status_free(mpdStatus);
  }
}

- (void) toggleShuffle
{
  struct mpd_status *mpdStatus;
  
  if (! [self _checkConnection]) 
    {
      return;
  }
    
  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) {
    mpd_send_random(mpdConnection, (mpd_status_get_random(mpdStatus) == 0) ? 1 : 0);
    mpd_response_finish(mpdConnection);
    mpd_status_free(mpdStatus);
  }
}

- (void) toggleRepeat
{
  struct mpd_status *mpdStatus;
  
  if (! [self _checkConnection]) 
    {
      return;
    }

  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) {
    mpd_send_repeat(mpdConnection, (mpd_status_get_repeat(mpdStatus) == 0) ? 1 : 0);
    mpd_response_finish(mpdConnection);
    mpd_status_free(mpdStatus);
  }
}

- (void) seekToTime: (int)time
{
  struct mpd_status *mpdStatus;
  
  if (! [self _checkConnection]) 
    {
      return;
    }
  
  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) { 
    if ((mpd_status_get_state(mpdStatus) == MPD_STATE_PLAY) 
      || (mpd_status_get_state(mpdStatus) == MPD_STATE_PAUSE)) {
        mpd_send_seek_pos(mpdConnection, mpd_status_get_song_pos(mpdStatus), time);
        mpd_response_finish(mpdConnection);
    }
  mpd_status_free(mpdStatus);
  }
}

- (void) setVolume: (int)volume
{
  if (! [self _checkConnection]) 
    {
      return;
    }
  
  mpd_send_set_volume(mpdConnection, volume);
  
  mpd_response_finish(mpdConnection);
}

- (void) setCrossfade: (int)cfTime
{
  if (! [self _checkConnection])
    {
      return;
    }

  mpd_send_crossfade(mpdConnection, cfTime);
  mpd_response_finish(mpdConnection);
}

/* -----------------------
   - Information Methods -
   -----------------------*/

- (int) getState
{
  int state;
  struct mpd_status *mpdStatus;

  if (! [self _checkConnection]) {
      return state_NOCONN;
  }
  mpdStatus = mpd_run_status(mpdConnection);

  if (mpdStatus != NULL) {
    switch (mpd_status_get_state(mpdStatus)) {
      case MPD_STATE_UNKNOWN:
        state = state_UNKNOWN;
        break;
      case MPD_STATE_STOP:
        state = state_STOP;
        break;
      case MPD_STATE_PLAY:
        state = state_PLAY;
        break;
      case MPD_STATE_PAUSE:
        state = state_PAUSE;
        break;
    }
    mpd_status_free(mpdStatus);
  } else {
    state = state_UNKNOWN;
  }
  
  mpd_response_finish(mpdConnection);

  return state;
}

- (BOOL) isRandom
{
  BOOL random;
  struct mpd_status *mpdStatus;

  if (! [self _checkConnection]) {
      return NO;
  }
  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) {
    if ((mpd_status_get_random(mpdStatus)) == 1) {
      random = YES;
    } else {
      random = NO;
    }
    mpd_response_finish(mpdConnection);
    mpd_status_free(mpdStatus);
  }

  return random;
}

- (BOOL) isRepeat
{
  BOOL repeat;
  struct mpd_status *mpdStatus;

  if (! [self _checkConnection]) {
      return NO;
  }
  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) {
    if (mpdStatus && (mpd_status_get_repeat(mpdStatus)) == 1) {
      repeat = YES;
    } else {
      repeat = NO;
    }
    mpd_response_finish(mpdConnection);
    mpd_status_free(mpdStatus);
  }
  
  return repeat;
}

- (int) getVolume
{
  int volume = 0;
  struct mpd_status *mpdStatus;

  if (! [self _checkConnection]) {
      return 0;
  }

  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) {
    volume = mpd_status_get_volume(mpdStatus);
    mpd_response_finish(mpdConnection);
    mpd_status_free(mpdStatus);
  }
  
  return volume;
}

- (int) getCrossfade
{
  int cfTime = 0;
  struct mpd_status *mpdStatus;

  if (! [self _checkConnection]) {
      return 0;
  }

  mpdStatus = mpd_run_status(mpdConnection);

  if (mpdStatus != NULL) {
    cfTime = mpd_status_get_crossfade(mpdStatus);
    mpd_status_free(mpdStatus);
  }

  return cfTime;
}

- (StatisticsItem *) getStatistics
{
  struct mpd_stats *mpdStats;
  StatisticsItem *statItem;

  if (! [self _checkConnection]) {
      return nil;
  }

  mpdStats = mpd_run_stats(mpdConnection);
  if (mpdStats != NULL) {
    statItem = [[StatisticsItem alloc] init];

    [statItem setNumberOfArtists: mpd_stats_get_number_of_artists(mpdStats)];
    [statItem setNumberOfAlbums: mpd_stats_get_number_of_albums(mpdStats)];
    [statItem setNumberOfSongs: mpd_stats_get_number_of_songs(mpdStats)];
    [statItem setUptime: mpd_stats_get_uptime(mpdStats)];
    [statItem setDbUpdatetime: mpd_stats_get_db_update_time(mpdStats)];
    [statItem setPlaytime: mpd_stats_get_play_time(mpdStats)];
    [statItem setDbPlaytime: mpd_stats_get_db_play_time(mpdStats)];

    mpd_stats_free(mpdStats);
    mpd_response_finish(mpdConnection);
    return AUTORELEASE(statItem);
  } else {
    return nil;
  }

}

/* ---------------------
   - Playlist Commands -
   ---------------------*/

- (PlaylistItem *) getCurrentSong
{
  struct mpd_status *mpdStatus;
  PlaylistItem *currSong;

  if (! [self _checkConnection]) {
      return nil;
  }

  if (!mpd_command_list_begin(mpdConnection, true) ||
    !mpd_send_status(mpdConnection) ||
    !mpd_send_current_song(mpdConnection) ||
    !mpd_command_list_end(mpdConnection)) {
      return nil;
  }

  mpdStatus = mpd_recv_status(mpdConnection);
  if (mpdStatus == NULL) {
    return nil;
  }

  if(mpd_status_get_state(mpdStatus) == MPD_STATE_PLAY ||
     mpd_status_get_state(mpdStatus) == MPD_STATE_PAUSE) 
    {
	  struct mpd_song *mpdSong;

	  if (!mpd_response_next(mpdConnection)) {
	    return nil;
	  }
	  mpdSong = mpd_recv_song(mpdConnection);
	  
	  currSong = RETAIN([self _getPlaylistItemForSong: mpdSong]);
	  
	  [currSong setElapsedTime: mpd_status_get_elapsed_time(mpdStatus)];
	  [currSong setTotalTime: mpd_status_get_total_time(mpdStatus)];
	  mpd_song_free(mpdSong);
      
      mpd_response_finish(mpdConnection);
    } 
  
  mpd_status_free(mpdStatus);

  if (currSong)
    {
      return AUTORELEASE(currSong);
    }
  else
    {
      return nil;
    }
}

- (int) getCurrentSongNr
{
  int songNr;
  struct mpd_status *mpdStatus;

  if (! [self _checkConnection]) 
    {
      return -1;
    }
  
  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) {
    songNr = mpd_status_get_song_pos(mpdStatus)+1;

    mpd_response_finish(mpdConnection);
    mpd_status_free(mpdStatus);
  }

  return songNr;
}

- (int) getPlaylistLength
{
  int length = 0;
  struct mpd_status *mpdStatus;

  if (! [self _checkConnection]) {
      return 0;
  }

  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) { 
    length = mpd_status_get_queue_length(mpdStatus);
    mpd_response_finish(mpdConnection);
    mpd_status_free(mpdStatus);
  }
  
  return length;
}

- (NSArray *) getPlaylist
{
  NSMutableArray *playlist;
  struct mpd_status *mpdStatus;

  if (! [self _checkConnection]) {
      return nil;
  }
  if(!mpd_send_list_queue_meta(mpdConnection)) {
    return nil;
  }
  struct mpd_song *mpdSong;
  playlist = [[NSMutableArray alloc] init];
  
  while((mpdSong = mpd_recv_song(mpdConnection)) != NULL) {
	  PlaylistItem *tmpSong;

	  tmpSong = RETAIN([self _getPlaylistItemForSong: mpdSong]);
	  [playlist addObject: tmpSong];
	  RELEASE(tmpSong);	
          mpd_song_free(mpdSong);
  }
  
  mpd_response_finish(mpdConnection);
  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) {
    currPlaylistVersion = mpd_status_get_queue_version(mpdStatus);
    mpd_response_finish(mpdConnection);
    mpd_status_free(mpdStatus);
  } else {
    currPlaylistVersion = 0;
  }
  return AUTORELEASE(playlist);
}

- (BOOL) playlistChanged
{

  BOOL changed = NO;
  struct mpd_status *mpdStatus;

  if (! [self _checkConnection]) {
      return NO;
  }

  mpdStatus = mpd_run_status(mpdConnection);
  if (mpdStatus != NULL) {
    unsigned int version = 0;
    version = mpd_status_get_queue_version(mpdStatus);
    mpd_response_finish(mpdConnection);
    mpd_status_free(mpdStatus);
    if (version != currPlaylistVersion) {
      changed = YES;
    } else {
      changed = NO;
    }
  }
  return changed;
}

- (void) shuffleList
{
  if (! [self _checkConnection]) {
      return;
  }
  mpd_run_shuffle(mpdConnection);
}

- (void) clearPlaylist
{
  if (! [self _checkConnection]) {
      return;
  }
  mpd_run_clear(mpdConnection);
}

- (void) removeSong: (int)song
{
  if (! [self _checkConnection]) {
      return;
  }
  mpd_run_delete(mpdConnection, song);
}

- (void) addTrack: (NSString *)file
{
  if (! [self _checkConnection]) {
      return;
  }
  mpd_run_add(mpdConnection, [file UTF8String]);
}

- (void) moveSongNr: (int)song1 to: (int)song2
{
  if (! [self _checkConnection]) {
      return;
  }
  mpd_run_move(mpdConnection, song1, song2);
}

- (void) moveSongWithID: (int)song1 to: (int)song2
{
  if (! [self _checkConnection]) {
      return;
  }
  mpd_run_move_id(mpdConnection, song1, song2);
}

- (NSArray *) getAllPlaylists
{
  NSMutableArray *tmpArray;
  struct mpd_entity *mpdInfoEntity;

  if (! [self _checkConnection]) {
      return nil;
  }
  mpd_send_list_playlists(mpdConnection);

  tmpArray = [[NSMutableArray alloc] init];

  while((mpdInfoEntity = mpd_recv_entity(mpdConnection))) {
    if(mpd_entity_get_type(mpdInfoEntity) == MPD_ENTITY_TYPE_PLAYLIST) {
      const struct mpd_playlist *mpdPlaylist = mpd_entity_get_playlist(mpdInfoEntity);
      [tmpArray addObject: [NSString stringWithUTF8String: mpd_playlist_get_path(mpdPlaylist)]];
    }
    mpd_entity_free(mpdInfoEntity);
  }
  mpd_response_finish(mpdConnection);
  
  return AUTORELEASE(tmpArray);
  
}

- (void) loadPlaylist: (NSString *)title
{
  if (! [self _checkConnection]) {
      return;
  }
  mpd_run_load(mpdConnection, [title cString]);
}

- (void) savePlaylist: (NSString *)title
{
  if (! [self _checkConnection]) {
      return;
  }
  mpd_run_save(mpdConnection, [title cString]);
}

- (void) removePlaylist: (NSString *)title
{
  if (! [self _checkConnection]) {
      return;
  }
  mpd_run_rm(mpdConnection, [title cString]);
}


/* -----------------------
   - Collection Commands -
   -----------------------*/

- (NSArray *) getAllArtists
{
  NSMutableArray *allArtists;
  struct mpd_pair *pair;

  if (! [self _checkConnection]) {
      return nil;
  }
  mpd_search_db_tags(mpdConnection, MPD_TAG_ARTIST);
  mpd_search_commit(mpdConnection);

  allArtists = [[NSMutableArray alloc] init];

  while ((pair = mpd_recv_pair_tag(mpdConnection, MPD_TAG_ARTIST)) != NULL) 
    {
      [allArtists addObject: pair->value ?[NSString stringWithUTF8String: pair->value]:@""];
      mpd_return_pair(mpdConnection, pair);
    }

  mpd_response_finish(mpdConnection);
  return [AUTORELEASE(allArtists) sortedArrayUsingFunction: _stringSort 
		                                   context: NULL];
}

- (NSArray *) getAllAlbums
{
  NSMutableArray *allAlbums;
  struct mpd_pair *pair;

  if (! [self _checkConnection]) {
      return nil;
  }
  mpd_search_db_tags(mpdConnection, MPD_TAG_ALBUM);
  mpd_search_commit(mpdConnection);

  allAlbums = [[NSMutableArray alloc] init];

  while ((pair = mpd_recv_pair_tag(mpdConnection, MPD_TAG_ALBUM)) != NULL) {
      [allAlbums addObject: [NSString stringWithUTF8String: pair->value]];
      free(pair);
  }

  mpd_response_finish(mpdConnection);
  return [AUTORELEASE(allAlbums) sortedArrayUsingFunction: _stringSort 
		                                  context: NULL];
}

- (NSArray *) getAllTracks
{
  NSMutableArray *allTracks;
  struct mpd_entity *mpdEntity;

  if (! [self _checkConnection]) {
      return nil;
  }

  allTracks = [[NSMutableArray alloc] init];
  mpd_send_list_all_meta(mpdConnection, NULL);
  while ((mpdEntity = mpd_recv_entity(mpdConnection)) != NULL) { 
    if (mpd_entity_get_type(mpdEntity) == MPD_ENTITY_TYPE_SONG) {
	  const struct mpd_song *mpdSong;
	  PlaylistItem *tmpSong;

	  mpdSong = mpd_entity_get_song(mpdEntity);

	  tmpSong = RETAIN([self _getPlaylistItemForSong: mpdSong]);

	  [allTracks addObject: tmpSong];
	  
	  RELEASE(tmpSong);
    }
  }
  mpd_response_finish(mpdConnection);
  return AUTORELEASE(allTracks);

}

- (NSArray *) getAlbumsForArtist: (NSString *)artist
{
#warning FIXME getAllAlbumsForArtist
return nil;
/* 
  NSMutableArray *allAlbums;
  char *albumName;

  if (! [self _doConnect]) 
    {
      return nil;
    }


  mpd_sendListCommand(mpdConnection, MPD_TAG_ALBUM, [artist UTF8String]);

  if (! [self _checkConnection]) 
    {
      return nil;
    }

  allAlbums = [[NSMutableArray alloc] init];

  while ((albumName = mpd_getNextAlbum(mpdConnection)) != NULL) 
    {
      [allAlbums addObject: [NSString stringWithUTF8String: albumName]];
      free(albumName);
    }
  
  mpd_response_finish(mpdConnection);

  return [AUTORELEASE(allAlbums) sortedArrayUsingFunction: _stringSort 
		                                  context:NULL];
*/

}

- (NSArray *) getAllTracksForArtist: (NSString *)artist
{
#warning FIXME getAllTracksForArtist

return nil;

/*
  NSMutableArray *allTracks;
  struct mpd_entity *mpdInfoEntity;
  
  if (! [self _doConnect]) 
    {
      return nil;
    }

  mpd_sendFindCommand(mpdConnection, MPD_TAG_ARTIST, [artist UTF8String]);

  if (! [self _checkConnection]) 
    {
      return nil;
    }

  allTracks = [[NSMutableArray alloc] init];

  while((mpdInfoEntity = mpd_recv_entity(mpdConnection))) 
    {
      if(mpd_entity_get_type(mpdInfoEntity) == MPD_ENTITY_TYPE_SONG) 
	{
	  const struct mpd_song *mpdSong;
	  PlaylistItem *tmpSong;
	  
	  mpdSong = mpd_entity_get_song(mpdInfoEntity);

	  tmpSong = RETAIN([self _getPlaylistItemForSong: mpdSong]);
      
	  [allTracks addObject: tmpSong];

	  RELEASE(tmpSong);
	}
      mpd_entity_free(mpdInfoEntity);
    }
  
  mpd_response_finish(mpdConnection);
  
  return AUTORELEASE(allTracks);

*/
}

- (NSArray *) getAllTracksForArtist: (NSString *)artist 
                              album: (NSString *)album
{
  NSArray *tmpArray;
  NSMutableArray *allTracks;
  int i;

  tmpArray = RETAIN([self getAllTracksForArtist: artist]);

  if (! tmpArray) {
      return nil;
  }

  allTracks = [[NSMutableArray alloc] init];

  for (i = 0; i < [tmpArray count]; i++) {
      if ([[[tmpArray objectAtIndex: i] getAlbum] isEqual: album]) {
	  [allTracks addObject: [tmpArray objectAtIndex: i]];
      }
  }
  
  RELEASE(tmpArray);
  return AUTORELEASE(allTracks);
}

- (NSArray *) getAllTracksForAlbum: (NSString *)album
{

#warning FIXME getAllTracksForAlbum

return nil;
/*
  NSMutableArray *allTracks;
  struct mpd_entity *mpdInfoEntity;

  if (! [self _doConnect])
    {
      return nil;
    }

  mpd_sendFindCommand(mpdConnection, MPD_TAG_ALBUM, [album UTF8String]);

  if (! [self _checkConnection]) 
    {
      return nil;
    }

  allTracks = [[NSMutableArray alloc] init];

  while((mpdInfoEntity = mpd_recv_entity(mpdConnection))) 
    {
      if(mpd_entity_get_type(mpdInfoEntity) == MPD_ENTITY_TYPE_SONG) 
	{
	  const struct mpd_song *mpdSong;
	  PlaylistItem *tmpSong;
	  
	  mpdSong = mpd_entity_get_song(mpdInfoEntity);

	  tmpSong = RETAIN([self _getPlaylistItemForSong: mpdSong]);

	  [allTracks addObject: tmpSong];
	  
	  RELEASE(tmpSong);
	}
      mpd_entity_free(mpdInfoEntity);
    }
  
  mpd_response_finish(mpdConnection);

  return AUTORELEASE(allTracks);;
*/
}

- (void) updateCollection
{
  if (! [self _checkConnection]) {
      return;
  }

  mpd_send_update(mpdConnection, "");
  mpd_response_finish(mpdConnection);
}
@end

/* -------------------
   - Private Methods -
   -------------------*/

@implementation MPDController(Private)
- (BOOL) _doConnect 
{
  char *mpdHost;
  int mpdPort;
  unsigned int mpdTimeout;

  mpdHost = (char *)[host cString];
  mpdPort = (int) [port floatValue];
  mpdTimeout = (unsigned int) [timeout intValue];
  mpdConnection = mpd_connection_new(mpdHost, mpdPort, mpdTimeout);
  if (mpdConnection == NULL) {
    NSLog(@"Cannot connect to server: Out of memory");
    return NO;
  }
  
  if (password) {
    mpd_send_password(mpdConnection, (char *)[password cString]);
    mpd_response_finish(mpdConnection);
  }

  if (mpd_connection_get_error(mpdConnection) != MPD_ERROR_SUCCESS) {
    [[NSNotificationCenter defaultCenter] postNotification: 
	     [NSNotification notificationWithName: DidNotConnectNotification 
					   object: [NSString stringWithUTF8String: 
					       mpd_connection_get_error_message(mpdConnection)]]];
    mpd_connection_clear_error(mpdConnection);
    return NO;
  } else {
    [[NSNotificationCenter defaultCenter] postNotification: 
	     [NSNotification notificationWithName: DidConnectNotification object: nil]];
    return YES;
  }
}

- (BOOL) _checkConnection
{
  if (mpd_connection_get_error(mpdConnection) != MPD_ERROR_SUCCESS) {
    if (mpd_connection_get_error(mpdConnection) == MPD_ERROR_TIMEOUT) {
      // we are trying to reconnect here
      // _doConnect will send the notification if it also fails
      mpd_response_finish(mpdConnection);
      mpd_connection_clear_error(mpdConnection);
      mpd_connection_free(mpdConnection);
      if ([self _doConnect]) {
        return YES;
      }
    } else {
      mpd_response_finish(mpdConnection);
      [[NSNotificationCenter defaultCenter] postNotification: 
	     [NSNotification notificationWithName: DidNotConnectNotification 
			                   object: [NSString stringWithUTF8String: 
							       mpd_connection_get_error_message(mpdConnection)]]];
      mpd_connection_clear_error(mpdConnection);
      mpd_response_finish(mpdConnection);
    }
    return NO;
  } else {
    mpd_response_finish(mpdConnection);
    return YES;
  }
}

- (PlaylistItem *) _getPlaylistItemForSong: (const struct mpd_song *)anSong
{
  PlaylistItem *plItem;
  const char *songArtist = mpd_song_get_tag(anSong,MPD_TAG_ARTIST,0);
  const char *songTitle = mpd_song_get_tag(anSong,MPD_TAG_TITLE,0);
  const char *songAlbum = mpd_song_get_tag(anSong,MPD_TAG_ALBUM,0);
  const char *songTrackNr = mpd_song_get_tag(anSong,MPD_TAG_TRACK,0);
  const char *songGenre = mpd_song_get_tag(anSong,MPD_TAG_GENRE,0);

  plItem = [[PlaylistItem alloc] init];

  if (songArtist == NULL) {
      [plItem setArtist: _(@"Unknown Artist")];
  } else {
      [plItem setArtist: [NSString stringWithUTF8String: songArtist]];
  }

  if (songTitle == NULL) {
      [plItem setTitle: _(@"Unknown Title")];
  } else {
      [plItem setTitle: [NSString stringWithUTF8String: songTitle]];
  }
  
  if (songAlbum == NULL) {
      [plItem setAlbum: _(@"Unknown Album")];
  } else {
      [plItem setAlbum: [NSString stringWithUTF8String: songAlbum]];
  }

  if (songGenre == NULL) {
      [plItem setGenre: _(@"Unknown Genre")];
  } else {
      [plItem setGenre: [NSString stringWithUTF8String: songGenre]];
  }
  
  [plItem setPath: [NSString stringWithUTF8String: mpd_song_get_uri(anSong)]];

  if (songTrackNr == NULL) {
      [plItem setTrackNr: @""];
  } else {
      [plItem setTrackNr: [NSString stringWithUTF8String: songTrackNr]];
  }

  [plItem setTotalTime: mpd_song_get_duration(anSong)];

  [plItem setID: mpd_song_get_id(anSong)];
  [plItem setPos: mpd_song_get_pos(anSong)];
  return AUTORELEASE(plItem);
}

int _stringSort(id string1, id string2, void *context)
{
  NSString *str1, *str2;

  str1 = (NSString *) string1;
  str2 = (NSString *) string2;

  return [str1 caseInsensitiveCompare: str2];
}
@end

/*
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-14 11:53:40 +0200 by flip

   PlaylistItem

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

#ifndef _PCAPPPROJ_PLAYLISTITEM_H_
#define _PCAPPPROJ_PLAYLISTITEM_H_

#import <Foundation/Foundation.h>
#import "SQLiteAdaptor.h"

@interface PlaylistItem : NSObject
{
  NSString *artist;
  NSString *title;
  NSString *album;
  NSString *genre;
  NSString *trackNr;
  NSString *path;
  NSString *comment;
  NSString *date;
  NSString *composer;
  NSString *performer;
  NSString *disc;

  int elapsedTime;
  int totalTime;
  SQLiteAdaptor *MPDConDB;
  
  int ID;
  int pos;
}

// Accessor Methods
- (NSString *) getArtist;
- (void) setArtist: (NSString *)newArtist;
- (NSString *) getTitle;
- (void) setTitle: (NSString *)newTitle;
- (NSString *) getAlbum;
- (void) setAlbum: (NSString *)newAlbum;
- (NSString *) getGenre;
- (void) setGenre: (NSString *)newGenre;
- (NSString *) getComment;
- (void) setComment: (NSString *)newComment; 
- (NSString *) getDate;
- (void) setDate: (NSString *) newDate;
- (NSString *) getComposer;
- (void) setComposer: (NSString *) newComposer;
- (NSString *) getPerformer;
- (void) setPerformer: (NSString *) newPerformer;
- (NSString *) getDisc;
- (void) setDisc: (NSString *) newDisc;
- (NSString *) getTrackNr;
- (void) setTrackNr: (NSString *)newNr;
- (int) getElapsedTime;
- (void) setElapsedTime: (int)newTime;
- (int) getTotalTime;
- (void) setTotalTime: (int)newTime;
- (NSString *) getPath;
- (void) setPath: (NSString *)newPath;
- (int) getID;
- (void) setID: (int) newID;
- (int) getPos;
- (void) setPos: (int) newPos;
- (NSUInteger) getRating;
- (void) setRating: (NSUInteger)newRating;
- (NSDictionary *) getLyrics;
- (void) setLyrics: (NSString *) lyricsText withURL: (NSString *)lyricsURL;
@end

#endif


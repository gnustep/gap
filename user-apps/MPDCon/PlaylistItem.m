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

#include "PlaylistItem.h"

@interface PlaylistItem(Private)
static NSString* SongRatingStorageDirectory = nil;
-(NSString *)_getSongRatingsFileName;
-(NSDictionary *)_loadRatings;
-(NSUInteger)_getRatingForPlaylistItemWithPath:(NSString *)_path;
-(void)_saveRating: (NSUInteger) _rating forPlaylistItemWithPath:(NSString *)_path;
@end

@implementation PlaylistItem(Private)
/**
 * Converts a string to a string that's usable as a file system name. This is done
 * by removing several forbidden characters, only leaving the allowed ones. (A helper method)
 * The function is stolen from RSSKit
 */
NSString* _playlistItemPathToRatingKey( NSString* aString )
{
    NSScanner* scanner = [NSScanner scannerWithString: aString];
    NSMutableString* string = AUTORELEASE([[NSMutableString alloc] init]);
    NSCharacterSet* allowedSet = [NSCharacterSet alphanumericCharacterSet];

    do {
        NSString* nextPart;
        BOOL success;

        // discard any unknown characters
        if ([scanner scanUpToCharactersFromSet: allowedSet intoString: NULL] == YES) {
            [string appendString: @"_"];
        } 
        
        // scan known characters...
        success = [scanner scanCharactersFromSet: allowedSet intoString: &nextPart];

        // ...and add them to the string
        if (success == YES) {
            [string appendString: nextPart];
        } 
    } while ([scanner isAtEnd] == NO);

    return [NSString stringWithString: string];
}

-(NSString *)_getSongRatingsFileName
{
  if (SongRatingStorageDirectory == nil)
    { 
      NSFileManager* manager;
      BOOL isDir, exists;
      NSString *storagePath;

      storagePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
      storagePath = [storagePath stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
      storagePath = [NSString stringWithFormat:@"%@", storagePath]; 

      ASSIGN(SongRatingStorageDirectory, storagePath);

      manager = [NSFileManager defaultManager];

      exists = [manager fileExistsAtPath: SongRatingStorageDirectory isDirectory: &isDir];

      if (exists)
	{
	  if (isDir == NO)
	    {
              [[NSException exceptionWithName: @"SongRatingsStorageDirectoryIsNotADirectory"	
	                               reason:@"The storage directory for song ratings is not a directory."
			             userInfo: nil] raise];
	    }
        }
      else
        {
	  if ([manager createDirectoryAtPath: SongRatingStorageDirectory
	  			  attributes: nil] == NO)
	    {
	      [[NSException exceptionWithName: @"SongRatingsStorageDirectoryCreationFailed"
				       reason: @"Creation of the storage directory for song ratings failed."
				     userInfo: nil] raise];
	    }

        }
    }  
  return [NSString stringWithFormat:@"%@/SongRatings.plist", SongRatingStorageDirectory];
}

-(NSDictionary *)_loadRatings
{
  NSString *errorDesc = nil;
  NSString *songRatingsFileName;
  NSPropertyListFormat format;

  songRatingsFileName = [self _getSongRatingsFileName];

  if (![[NSFileManager defaultManager] fileExistsAtPath:songRatingsFileName])
    {
      // there are no ratings saved yet
NSLog(@"_loadRatings: No ratings in songRatingsFileName: %@ YET, returning 0", songRatingsFileName);
      return 0;

    }

  NSData *songRatingsXML = [[NSFileManager defaultManager] contentsAtPath:songRatingsFileName];
  NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                        propertyListFromData:songRatingsXML
                            mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                      format:&format
                            errorDescription:&errorDesc];
  if (!temp)
    {
      NSLog(@"Error reading song ratings: %@, format: %d", errorDesc, format);
    } 

  return temp;
}

-(NSUInteger)_getRatingForPlaylistItemWithPath:(NSString *)_path
{
  NSDictionary *ratings;
NSLog(@"_getRatingForPlaylistItemWithPath: %@", _path);
  ratings = [self _loadRatings];
NSLog(@"returning the rating: %i", [[ratings objectForKey:_playlistItemPathToRatingKey(_path)] unsignedIntegerValue]);
  return [[ratings objectForKey:_playlistItemPathToRatingKey(_path)] unsignedIntegerValue];
}

-(void)_saveRating: (NSUInteger) _rating forPlaylistItemWithPath:(NSString *)_path
{
  NSMutableDictionary *ratings;
  NSString *error;
  NSString *songRatingsFileName;
NSLog(@"_saveRating: %i forPlaylistItemWithPath: %@ (%@)", _rating, _path, _playlistItemPathToRatingKey(_path));
  ratings = [[NSMutableDictionary alloc] init];
  [ratings addEntriesFromDictionary:[self _loadRatings]];
  if (_rating == 0)
    {
      [ratings removeObjectForKey: _playlistItemPathToRatingKey(_path)];
    }
  else
    {
      [ratings setObject: [NSNumber numberWithUnsignedInteger:_rating] forKey: _playlistItemPathToRatingKey(_path)];
    }

  songRatingsFileName = [self _getSongRatingsFileName];

  NSData *ratingsData = [NSPropertyListSerialization dataFromPropertyList:ratings
					format:NSPropertyListXMLFormat_v1_0
					errorDescription:&error];

  if (ratingsData)
    {
       [ratingsData writeToFile:songRatingsFileName atomically:YES];
    }
  else
    {
      NSLog(@"%@", error);
      [error release];
    }
}

@end

@implementation PlaylistItem

/* --------------------------
   - Initialization Methods -
   --------------------------*/

- (void) dealloc
{
  RELEASE(artist);
  RELEASE(title);
  RELEASE(album);
  RELEASE(genre);
  RELEASE(trackNr);
  RELEASE(path);
  RELEASE(comment);
  RELEASE(composer);
  RELEASE(date);
  RELEASE(performer);
  RELEASE(disc);

  [super dealloc];
}

/* --------------------
   - Accessor Methods -
   --------------------*/

- (NSString *) getArtist
{
  return artist;
}

- (void) setArtist: (NSString *)newArtist
{
  AUTORELEASE(artist);
  artist = [newArtist copy];
}

- (NSString *) getAlbum
{
  return album;
}

- (void) setAlbum: (NSString *)newAlbum
{
  AUTORELEASE(album);
  album = [newAlbum copy];
}

- (NSString *) getGenre
{
  return genre;
}

- (void) setGenre: (NSString *)newGenre
{
  AUTORELEASE(genre);
  genre = [newGenre copy];
}

- (NSString *) getTitle
{
  return title;
}

- (void) setTitle: (NSString *)newTitle
{
  AUTORELEASE(title);
  title = [newTitle copy];
}

- (NSString *) getTrackNr
{
  return trackNr;
}

- (void) setTrackNr: (NSString *)newNr
{
  AUTORELEASE(trackNr);
  trackNr = [newNr copy];
}

- (NSString *) getComment
{
  return comment;
}

- (void) setComment: (NSString *)newComment
{
  AUTORELEASE(comment);
  comment = [newComment copy];
}

- (NSString *) getComposer
{
  return composer;
}

- (void) setComposer: (NSString *)newComposer
{
  AUTORELEASE(composer);
  composer = [newComposer copy];
}

- (NSString *) getDate
{
  return date;
}

- (void) setDate: (NSString *)newDate
{
  AUTORELEASE(date);
  date = [newDate copy];
}

- (NSString *) getPerformer
{
  return performer;
}

- (void) setPerformer: (NSString *)newPerformer
{
  AUTORELEASE(performer);
  performer = [newPerformer copy];
}

- (NSString *) getDisc
{
  return disc;
}

- (void) setDisc: (NSString *)newDisc
{
  AUTORELEASE(disc);
  disc = [newDisc copy];
}

- (int) getElapsedTime
{
  return elapsedTime;
}

- (void) setElapsedTime: (int)newTime
{
  elapsedTime = newTime;
}

- (int) getTotalTime
{
  return totalTime;
}

- (void) setTotalTime: (int)newTime
{
  totalTime = newTime;
}

- (NSString *) getPath
{
  return path;
}

- (void) setPath: (NSString *)newPath
{
  AUTORELEASE(path);
  path = [newPath copy];
}

- (void) setRating: (NSUInteger)newRating
{
NSLog(@"The Rating is set!!!");
  [self _saveRating: newRating forPlaylistItemWithPath:path];
  rating = newRating;
}

- (NSUInteger) getRating
{
NSLog(@"getRating");
  return [self _getRatingForPlaylistItemWithPath:path];
}
 
- (void) setID: (int) newID
{
  ID = newID;
}

- (int) getID
{
  return ID;
}

- (void) setPos: (int) newPos
{
  pos = newPos;
}

- (int) getPos
{
  return pos;
}
@end

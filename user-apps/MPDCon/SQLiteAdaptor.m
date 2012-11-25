/*
   Project: MPDCon

   Copyright (C) 2012 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2012-11-11 11:11:38 +0100 by sebastia

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

#import "SQLiteAdaptor.h"

@interface SQLiteAdaptor(Private)
static NSString* SongRatingStorageDirectory = nil;
-(NSString *)_getMPDConDBName;
@end

@implementation SQLiteAdaptor(Private)
-(NSString *)_getMPDConDBName
{
  if (SongRatingStorageDirectory == nil)
    {
      NSFileManager* manager;
      BOOL isDir, exists;
      NSString *storagePath;

      storagePath = [NSSearchPathForDirectoriesInDomains
		(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
      storagePath = [storagePath stringByAppendingPathComponent:
		[[NSProcessInfo processInfo] processName]];
      storagePath = [NSString stringWithFormat:@"%@", storagePath];
      ASSIGN(SongRatingStorageDirectory, storagePath);

      manager = [NSFileManager defaultManager];
      exists = [manager fileExistsAtPath: SongRatingStorageDirectory
		isDirectory: &isDir];
      if (exists)
	{
	  if (isDir == NO)
	    {
	      [[NSException exceptionWithName: 
			@"SongRatingStorageDirectoryIsNotADirectory"
				       reason:
			@"The storage directory for song ratings is not a directory."
				     userInfo: nil] raise];
	    }
	}
      else
	{
	  if ([manager createDirectoryAtPath: SongRatingStorageDirectory
				  attributes: nil] == NO)
	    {
	      [[NSException exceptionWithName:
			@"SongRatingsStorageDirectoryCreationFailed"
				       reason:
			@"Creation of the storage directory for song ratings failed."
				     userInfo: nil] raise];
	    }
	}
    }
  return [NSString stringWithFormat:@"%@/MPDCon.sqlite3", SongRatingStorageDirectory];
}
@end

@implementation SQLiteAdaptor
+ (id) sharedSQLiteAdaptor
{
  static SQLiteAdaptor *_sharedSQLiteAdaptor = nil;

  if (! _sharedSQLiteAdaptor)
    {
      _sharedSQLiteAdaptor = [[SQLiteAdaptor allocWithZone: [self zone]] init];
    }
  return _sharedSQLiteAdaptor;
}

- (id) init
{
  NSUserDefaults *defs;

  defs = [NSUserDefaults standardUserDefaults];
  [defs registerDefaults:
    [NSDictionary dictionaryWithObjectsAndKeys:
      [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionaryWithObjectsAndKeys:
          [self _getMPDConDBName], @"Database",
          @"", @"User",
          @"", @"Password",
          @"SQLite", @"ServerType",
          nil],
        @"MPDCon",
        nil],
      @"SQLClientReferences",
      nil]
  ];
  MPDConDB = RETAIN([SQLClient clientWithConfiguration: nil name: @"MPDCon"]);
  //[MPDConDB setDurationLogging: 0];
  [MPDConDB execute: @"CREATE TABLE IF NOT EXISTS SongRatings ( "
                @"fileName CHAR(1024) PRIMARY KEY, "
                @"rating INTEGER)",
                nil];
  [MPDConDB execute: @"CREATE TABLE IF NOT EXISTS SongLyrics ( "
                @"fileName CHAR(1024) PRIMARY KEY, "
                @"lyricsText CHAR(1024), ",
                @"lyricsURL CHAR(1024) )",
                nil];
  
  return self;
}

- (void) dealloc
{
  [MPDConDB disconnect];
  [MPDConDB release];
  [super dealloc];
}

- (void) setRating: (NSUInteger) rating forFile: (NSString *) fileName
{
  NSString *quotedFileName, *query;

  // the following doesn't seem to work, but the line after it does the trick!
  //quotedFileName = [MPDConDB quoteString:fileName];
  quotedFileName = [fileName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
  query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO \
		SongRatings(fileName, rating) values('%@', %u)", quotedFileName, rating];
  [MPDConDB execute: query, nil];
}
- (NSUInteger) getRatingForFile: (NSString *) fileName
{
  NSString *quotedFileName, *query;
  NSMutableArray *records;
  SQLRecord      *record;
  NSInteger rating = 0;

  // the following doesn't work, but the line after it does the trick
  //quotedFileName = [MPDConDB quoteString:fileName];
  quotedFileName = [fileName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
  query = [NSString stringWithFormat:@"SELECT rating FROM SongRatings WHERE fileName='%@'", quotedFileName];
  records = [MPDConDB query: query, nil];

  // we search for the primary key, so we should find exactly one
  if ([records count] == 1)
    { 
      record = [records objectAtIndex:0]; 
      rating = [[record objectAtIndex:0] unsignedIntegerValue];
    }
  return rating;
}
- (NSArray *) getFilesForRatingsInRange: (NSRange) range
{
  NSArray * ratingsArray;

  ratingsArray = [[NSArray alloc] init];

  return ratingsArray;
}

- (void) setLyrics: (NSString *) lyricsText withURL: (NSString *) lyricsURL forFile: (NSString *) fileName
{
  NSString *quotedFileName, *quotedText, *quotedURL;
  NSString *query;

  quotedFileName = [fileName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
  quotedText = [lyricsText stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
  quotedURL = [lyricsURL stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

  query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO \
		SongLyrics(fileName, lyricsText, lyricsURL) values('%@', '%@', '%@')",
		quotedFileName, quotedText, quotedURL];	

  [MPDConDB execute: query, nil];
}
- (NSDictionary *) getLyricsForFile: (NSString *) fileName
{
  NSString  *quotedFileName, *quotedText, *quotedURL;
  NSString  *query;
  NSMutableArray *records;
  SQLRecord *record;
  NSString *lyricsText, *lyricsURL;
  NSDictionary *result = nil;
  
  quotedFileName = [fileName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

  query = [NSString stringWithFormat:@"SELECT lyricsText, lyricsURL FROM SongLyrics \
					WHERE fileName='%@'", quotedFileName];
		
  records = [MPDConDB query: query, nil];

  // we search for the primary key, so we should find exactly one
  if ([records count] == 1)
    {
      record = [records objectAtIndex:0];
      quotedText = [record objectAtIndex:0];
      quotedURL = [record objectAtIndex:1];
      lyricsText = [quotedText stringByReplacingOccurrencesOfString:@"''" withString:@"'"]; 
      lyricsURL = [quotedURL stringByReplacingOccurrencesOfString:@"''" withString:@"'"]; 
      result = [NSDictionary dictionaryWithObjectsAndKeys: lyricsText, @"lyricsText", 
		lyricsURL, @"lyricsURL", nil];
    }
  return result;
}

@end

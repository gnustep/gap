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

#ifndef _SQLITEADAPTOR_H_
#define _SQLITEADAPTOR_H_

#import <Foundation/Foundation.h>
#import <SQLClient/SQLClient.h>

@interface SQLiteAdaptor : NSObject
{
  SQLClient *MPDConDB;
}
+ (id) sharedSQLiteAdaptor;

// Song ratings related methods
- (void) setRating: (NSUInteger) rating forFile: (NSString *) fileName;
- (NSUInteger) getRatingForFile: (NSString *) fileName;
- (NSArray *) getFilesForRatingsInRange: (NSRange) range;

// Lyrics related methods
- (void) setLyrics: (NSString *) lyricsText withURL: (NSString *) lyricsURL forFile: (NSString *) fileName;
- (NSDictionary *) getLyricsForFile: (NSString *) fileName;

@end

#endif // _SQLITEADAPTOR_H_


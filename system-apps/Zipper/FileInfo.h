/*

  FileInfo.h
  Zipper

  Copyright (C) 2012 Free Software Foundation, Inc

  Authors: Dirk Olmes <dirk@xanthippe.ping.de>

  This application is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details

 */

#import <Foundation/NSObject.h>

@class NSString, NSCalendarDate, NSNumber;

@interface FileInfo : NSObject
{
  @private
    NSString *_path;
    NSString *_filename;
    NSCalendarDate  *_date;
    NSNumber *_size;
    NSString *_ratio;
}

+ (FileInfo *)newWithPath:(NSString *)path date:(NSCalendarDate *)date size:(NSNumber *)size;
+ (FileInfo *)newWithPath:(NSString *)path date:(NSCalendarDate *)date size:(NSNumber *)size 
	ratio:(NSString *)ratio;

- (id)initWithPath:(NSString *)path date:(NSCalendarDate *)date size:(NSNumber *)size
	ratio:(NSString *)ratio;
- (NSString *)path;
// returns the complete path that's build from [self path] and [self filename]
- (NSString *)fullPath;
- (NSString *)filename;
- (NSCalendarDate *)date;
- (NSNumber *)size;
- (NSString *)ratio;

- (NSComparisonResult)comparePathAscending:(id)other;
- (NSComparisonResult)comparePathDescending:(id)other;
- (NSComparisonResult)compareSizeAscending:(id)other;
- (NSComparisonResult)compareSizeDescending:(id)other;
- (NSComparisonResult)compareFilenameAscending:(id)other;
- (NSComparisonResult)compareFilenameDescending:(id)other;
- (NSComparisonResult)compareDateAscending:(id)other;
- (NSComparisonResult)compareDateDescending:(id)other;
- (NSComparisonResult)compareRatioAscending:(id)other;
- (NSComparisonResult)compareRatioDescending:(id)other;

@end

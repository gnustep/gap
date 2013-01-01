/*

  AceArchive.m
  Zipper

  Copyright (C) 2012 Free Software Foundation, Inc

  Authors: Sebastian Reitenbach <sebastia@l00-bugdead-prods.de>

  This application is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details

 */

#import <Foundation/Foundation.h>
#import "AceArchive.h"
#import "FileInfo.h"
#import "NSString+Custom.h"
#import "Preferences.h"
#import "NSArray+Custom.h"
#import "common.h"

static NSData *_magicBytes;

@interface AceArchive (PrivateAPI)
- (NSData *)dataByRunningAce;
@end

@implementation AceArchive : Archive

/**
 * register our supported file extensions with our superclass.
 */
+ (void)initialize
{
	// ace has "**ACE**" on the 7. char
	char aceBytes[] = { 0xea, 0x60 };
	_magicBytes = [[NSData dataWithBytes:aceBytes length:2] retain];
	
	[self registerFileExtension:@"ace" forArchiveClass:self];
}

+ (NSString *)unarchiveExecutable
{
	return [Preferences unaceExecutable];
}

/**
 * ace archives <em>do</em> contain info about compression ratio.
 */
+ (BOOL)hasRatio;
{
	return YES;
}

+ (ArchiveType)archiveType
{
	return ACE;
}

+ (NSData *)magicBytes
{
	return _magicBytes;
}

//------------------------------------------------------------------------------
// expanding the archive
//------------------------------------------------------------------------------
- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path
{
	//FileInfo *fileInfo;
	NSMutableArray *args;
	
	args = [NSMutableArray array];
	if (usePathInfo)
	  {
	    [args addObject:@"x"];
	  }
	else
	  {
	    [args addObject:@"e"];
	  }

	[args addObject:@"-y"];
	[args addObject:[self path]];
	
	// this doesn't work with unace, either extract
	// whole archive, or nothing
	/* if (files != nil)
	{
		NSEnumerator *cursor = [files objectEnumerator];
		while ((fileInfo = [cursor nextObject]) != nil)
		{
			[args addObject:[fileInfo fullPath]];
		}
	} */
	
	// there is no parameter allowing to specify destination dir
	return [self runUnarchiverWithArguments:args inDirectory:path];
}

- (NSArray *)listContents
{
	NSUInteger lineCount, i;
	NSString *path = nil;
    
    NSMutableArray *results = [NSMutableArray array];
    NSData *data = [self dataByRunningAce];
    NSString *string = [[[NSString alloc] initWithData:data 
		encoding:NSASCIIStringEncoding] autorelease];
    NSArray *lines = [string componentsSeparatedByString:@"\n"];

    // take out first 8 lines (header) and last 2 lines (footer)
    lines = [lines subarrayWithRange:NSMakeRange(8, [lines count] - 8)];
    lines = [lines subarrayWithRange:NSMakeRange(0, [lines count] - 3)];

	lineCount = [lines count];
	for (i = 0; i < lineCount; i++)
	  {
            NSString *line = nil;
	    NSArray *components;
	    NSString *date, *ratio;
	    int length;
	    NSCalendarDate *calendarDate;
	    FileInfo *info;

	    line = [lines objectAtIndex:i];
	    components = [[line componentsSeparatedByString:@"|"] arrayByRemovingEmptyStrings];
	    path = [components objectAtIndex:5];
	    length = [[components objectAtIndex:2] intValue];
	    ratio = [components objectAtIndex:4];

	    date = [components objectAtIndex:0];
	    date = [NSString stringWithFormat:@"%@ %@", date, [components objectAtIndex:1]];
        		calendarDate = [NSCalendarDate dateWithString:date 
					calendarFormat:@"%d.%m.%y %H:%M"];

			info = [FileInfo newWithPath:path date:calendarDate 
				size:[NSNumber numberWithInt:length] ratio:ratio];
	        	[results addObject:info];
	}
    return results;
}
@end

//------------------------------------------------------------------------------
// private API
//------------------------------------------------------------------------------
@implementation AceArchive (PrivateAPI)
- (NSData *)dataByRunningAce
{
	// Args for unace:
	// v	view verbose contents of archive, verbose is needed to
	//	see the directory structure 

	NSArray *args = [NSArray arrayWithObjects:@"v", [self path], nil];
	return [self dataByRunningUnachiverWithArguments:args];
}

@end

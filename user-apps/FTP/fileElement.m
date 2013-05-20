/*
 Project: FTP

 Copyright (C) 2005-2013 Riccardo Mottola

 Author: Riccardo Mottola

 Created: 2005-04-18

 Single element of a file listing

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
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "fileElement.h"


@implementation FileElement

- (void)dealloc
{
  [fileName release];
  [filePath release];
  [super dealloc];
}

/*
 initialize a file element using attrbutes of NSFileManager
 */
- (id)initWithPath:(NSString *)path andAttributes:(NSDictionary *)attribs
{
  self = [super init];
  if (self)
    {
      size = [attribs fileSize];
      modifDate = [[attribs objectForKey:NSFileModificationDate] retain];
      if ([attribs fileType] == NSFileTypeDirectory)
        isDir = YES;
      else
        isDir = NO;
      isLink = NO;
      filePath = [path retain];
      fileName = [[filePath lastPathComponent] retain];
    }
  return self;
}

/* as a parser aid, check if a string is a month */
- (int)checkMonth: (NSString *)token
{
  if ([token compare:@"Jan" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 1;
    
  if ([token compare:@"Feb" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 2;
    
  if ([token compare:@"Mar" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 3;
    
  if ([token compare:@"Apr" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 4;
    
  if ([token compare:@"May" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 5;
    
  if ([token compare:@"Jun" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 6;
    
  if ([token compare:@"Jul" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 7;
    
  if ([token compare:@"Aug" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 8;
    
  if ([token compare:@"Sep" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 9;
    
  if ([token compare:@"Oct" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 10;
    
  if ([token compare:@"Nov" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 11;
    
  if ([token compare:@"Dec" options:NSCaseInsensitiveSearch ] == NSOrderedSame)
    return 12;
    
  return 0;
}

/*
 tries to parse a single line of LIST
 currently unix-style results will work, like

 drwx------  22 multix  staff   704 Apr  2 14:46 Documents

 or these where one of user/group are omitted
 drwxr-xr-x   8 users     4096 Apr 15 19:58 Documents
 
 inital blocks can be omitted, like:
 drwx------  multix  staff   704 Apr  2 14:46 Documents
 
 user/group could be numerical
 drwx------  22 4567  120   704 Apr  2 14:46 Documents
 
 the hour time could be the year
 drwx------  22 multix  staff   704 Apr  2 2005 Documents
 
 the filename could contain one or more spaces
 -rw-r--r--   1 multix  staff     0 May 25 10:08 test file
 
 the filesize can be zero..
 
 it will skip a line that is not considered meaningful, like:
 total 74184 (typical from Unix ls -l)
 and return nil.
 
 some attempt at scanning OS400 / i5 ftp listings is attempted too,
 those are in the style of:
 SVIFELMA        32768 02/05/07 15:32:42 *FILE      INSOLUTO
 SVIFELMA                                *MEM       INSOLUTO.INSOLUTO

 the feof line is ignored
 
 */
- (id)initWithLsLine :(char *)line
{
  NSString       *fullLine;
  NSMutableArray *splitLine;
  unichar        ch;
  unsigned       elementsFound;
  NSCharacterSet *whiteSet;
  unsigned       lineLen;
  NSRange        searchRange;
  NSRange        tokenEnd;
  NSRange        tokenRange;
  BOOL           foundStandardMonth;
  BOOL           foundOneBeforeMonth;
  long long      tempLL;
  
  self = [super init];
  if (self)
    {
      // typical Unix end of listing
      if (strstr(line, "total") == line)
        return nil;
    
    // typical IBM OS400 end of listing
    if (strstr(line, "feof") == line)
        return nil;

    fileName = nil;
    filePath = nil;
    linkTargetName = nil;
    isLink = NO;
    isDir = NO;
    size = 0;
    modifDate = nil;
    
    whiteSet = [NSCharacterSet whitespaceCharacterSet];
    splitLine = [NSMutableArray arrayWithCapacity:5];
    fullLine = [NSString stringWithCString:line];
    lineLen = [fullLine length];
    ch = [fullLine characterAtIndex:0];
    if (ch == '-' || ch == 'd' || ch == 'l')
    {
        // this is a unix-like listing
        unsigned cursor;

        // file permissions block
        cursor = 0;
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
        tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);
        
        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;
        
        // typically links - user - group - size
        
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
        tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
//        NSLog(@"second token: %@ %@", NSStringFromRange(tokenEnd), NSStringFromRange(tokenRange));
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);
        
        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;
            
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
        tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
//        NSLog(@"third token: %@ %@", NSStringFromRange(tokenEnd), NSStringFromRange(tokenRange));
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);
        
        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;
        
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
        tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
//        NSLog(@"fourth token: %@ %@", NSStringFromRange(tokenEnd), NSStringFromRange(tokenRange));
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);
        
        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;
        
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
        tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
//        NSLog(@"fifth token: %@ %@ %@", NSStringFromRange(tokenEnd), NSStringFromRange(tokenRange), [fullLine substringWithRange:tokenRange]);
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);
        foundOneBeforeMonth = [self checkMonth:[splitLine objectAtIndex:4]];
        
        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;
        
        // typically month
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
        tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
//        NSLog(@"sixth token: %@ %@ %@", NSStringFromRange(tokenEnd), NSStringFromRange(tokenRange), [fullLine substringWithRange:tokenRange]);
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);
        foundStandardMonth = [self checkMonth:[splitLine objectAtIndex:5]];
        
        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;
        
        // typically day of the month
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
        tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
//        NSLog(@"seventh token: %@ %@ %@", NSStringFromRange(tokenEnd), NSStringFromRange(tokenRange), [fullLine substringWithRange:tokenRange]);
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);
        
        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;
        
        // typically year or hour
        // but it could be fileName already
        if (foundStandardMonth)
        {
            searchRange = NSMakeRange(cursor, lineLen-cursor);
            tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
            tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
	    //            NSLog(@"eighth token: %@ %@ %@", NSStringFromRange(tokenEnd), NSStringFromRange(tokenRange), [fullLine substringWithRange:tokenRange]);
            [splitLine addObject:[fullLine substringWithRange:tokenRange]];
            cursor = NSMaxRange(tokenEnd);
        
            while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
                cursor++;
        }
        
        // typically the filename
        if (cursor < lineLen)
        {
            tokenRange = NSMakeRange(cursor, lineLen-cursor);
	    //            NSLog(@"last token: %@ %@ %@", NSStringFromRange(tokenEnd), NSStringFromRange(tokenRange), [fullLine substringWithRange:tokenRange]);
            [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        }
        
        elementsFound = [splitLine count];
        
        // copy back the found data
        if (foundStandardMonth && elementsFound == 9)
        {
	  NSRange linkArrowRange;

            // everything is fine and ok, we have a full-blown listing and parsed it well;            
            isDir = NO;
            if ([[splitLine objectAtIndex:0] characterAtIndex:0] == 'd')
                isDir = YES;
            [[NSScanner scannerWithString: [splitLine objectAtIndex:4]] scanLongLong:&tempLL];
	    if (tempLL > 0)
	      size = (unsigned long long)tempLL;
	    else
	      size = 0;
	    linkArrowRange = [[splitLine objectAtIndex:8] rangeOfString: @" -> "];
	    if (linkArrowRange.location == NSNotFound)
	      {
		fileName = [[splitLine objectAtIndex:8] retain];
	      }
	    else
	      {
                isLink = YES;
		size = 0;
		fileName = [[[splitLine objectAtIndex:8] substringToIndex: linkArrowRange.location] retain];
		linkTargetName = [[[splitLine objectAtIndex:8] substringFromIndex: linkArrowRange.location+linkArrowRange.length] retain];
		NSLog(@"we have a link (1) %@", linkTargetName);
	      }
        }
	else if (foundOneBeforeMonth && elementsFound == 8)
        {
	  NSRange linkArrowRange;

            // we miss the link count or user probably
            isDir = NO;
            if ([[splitLine objectAtIndex:0] characterAtIndex:0] == 'd')
                isDir = YES;
            [[NSScanner scannerWithString: [splitLine objectAtIndex:3]] scanLongLong:&tempLL];
	    if (tempLL > 0)
	      size = (unsigned long long)tempLL;
	    else
	      size = 0;
            linkArrowRange = [[splitLine objectAtIndex:7] rangeOfString: @" -> "];
	    if (linkArrowRange.location == NSNotFound)
	      {
		fileName = [[splitLine objectAtIndex:7] retain];
	      }
	    else
	      {
                isLink = YES;
		size = 0;
		fileName = [[[splitLine objectAtIndex:7] substringToIndex: linkArrowRange.location] retain];
		linkTargetName = [[[splitLine objectAtIndex:7] substringFromIndex: linkArrowRange.location+linkArrowRange.length] retain];
		NSLog(@"we have a link (2) %@", linkTargetName);
	      }
        } else
            return nil;
        
    } else if ((fullLine != NULL) && ([fullLine rangeOfString: @"*FILE"].location != NSNotFound))
    {
        // maybe it is an IBM AS400 / i5 style line
	// this is an IBM listing, having the *FILE element
        unsigned cursor;

        // username block
        cursor = 0;
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
        tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);

        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;

    	// file size        
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
    	tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);

        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;

    	// date     
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
    	tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);

        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;

    	// time       
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
    	tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);

        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;

    	// record type       
        searchRange = NSMakeRange(cursor, lineLen-cursor);
        tokenEnd = [fullLine rangeOfCharacterFromSet:whiteSet options:0 range:searchRange];
    	tokenRange = NSMakeRange(cursor, tokenEnd.location-cursor);
        [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        cursor = NSMaxRange(tokenEnd);

        while ([fullLine characterAtIndex:cursor] == ' ' && cursor <= lineLen)
            cursor++;

    	// file name    
        // typically the filename
        if (cursor < lineLen)
        {
            tokenRange = NSMakeRange(cursor, lineLen-cursor);
            [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        }

    	// everything is fine and ok, we have a full-blown listing and parsed it well;            
        isDir = NO; /* OS400 is not hierarchical */
        [[NSScanner scannerWithString: [splitLine objectAtIndex:1]] scanLongLong:&tempLL];
	if (tempLL > 0)
	  size = (unsigned long long)tempLL;
	else
	  size = 0;
        fileName = [[splitLine objectAtIndex:5] retain];

    } else
    {
	/* we don't know better */
	return nil;
    }
    
    /* let's ignore the current and the parent directory some servers send over... */
    if([fileName isEqualToString:@"."])
        return nil;
    else if([fileName isEqualToString:@".."])
        return nil;

    if (isLink)
      {
	NSLog(@"size: %llu", size);
	NSLog(@"filename: %@", fileName);
      }
    }
  return self;
}

/* accessors */
- (NSString *)name
{
  return self->fileName;
}

- (NSString *)path
{
  
  return self->filePath;
}

- (NSString *)linkTargetName
{
  return self->linkTargetName;
}

- (BOOL)isDir
{
  return isDir;
}

- (BOOL)isLink
{
  return isLink;
}

- (unsigned long long)size
{
  return size;
}


@end

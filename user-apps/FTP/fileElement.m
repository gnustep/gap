/*
 Project: FTP

 Copyright (C) 2005 Riccardo Mottola

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


@implementation fileElement

- (void)dealloc
{
    [filename release];
    [super dealloc];
}

/*
 initialize a file element using attrbutes of NSFileManager
 */
- (id)initWithFileAttributes :(NSString *)fname :(NSDictionary *)attribs
{
    [super init];

    size = [attribs fileSize];
    modifDate = [[attribs objectForKey:NSFileModificationDate] retain];
    if ([attribs fileType] == NSFileTypeDirectory)
        isDir = YES;
    else
        isDir = NO;
    filename = [fname retain];
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
    

    [super init];

    if (strstr(line, "total") == line)
        return nil;
    
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
//            NSLog(@"last token: %@ %@", NSStringFromRange(tokenEnd), NSStringFromRange(tokenRange));
            [splitLine addObject:[fullLine substringWithRange:tokenRange]];
        }
        
        elementsFound = [splitLine count];
        
        // copy back the found data
        if (foundStandardMonth && elementsFound == 9)
        {
            // everything is fine and ok, we have a full-blown listing and parsed it well;            
            isDir = NO;
            if ([[splitLine objectAtIndex:0] characterAtIndex:0] == 'd')
                isDir = YES;
            [[NSScanner scannerWithString: [splitLine objectAtIndex:3]] scanLongLong:&size];
            filename = [[splitLine objectAtIndex:8] retain];
        } else if (foundOneBeforeMonth && elementsFound == 8)
        {
            // we miss the link count or user probably
            isDir = NO;
            if ([[splitLine objectAtIndex:0] characterAtIndex:0] == 'd')
                isDir = YES;
            [[NSScanner scannerWithString: [splitLine objectAtIndex:2]] scanLongLong:&size];
            filename = [[splitLine objectAtIndex:7] retain];
        } else
            return nil;
        
    }
    
    /* let's ignore the current and the parent directory some servers send over... */
    if([filename isEqualToString:@"."])
        return nil;
    else if([filename isEqualToString:@".."])
        return nil;

    return self;
}

/* accessors */
- (NSString *)filename
{
    return self->filename;
}

- (BOOL)isDir
{
    return isDir;
}

- (unsigned long long)size
{
    return size;
}


@end

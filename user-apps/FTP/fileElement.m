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
 Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
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

/*
 tries to parse a single line of LIST
 currently unix-style results will work, like

 drwx------  22 multix  staff   704 Apr  2 14:46 Documents

 or these where one of user/group are omitted
 drwxr-xr-x   8 users     4096 Apr 15 19:58 Documents

 it will skip a line that is not considered meaningful, like:
 total 74184 (typical from Unix ls -l)
 and return nil.
 */
- (id)initWithLsLine :(char *)line
{
    char *sep;
    char *curr;
    BOOL foundSize;

    [super init];

    if (strstr(line, "total") == line)
        return nil;

    curr = line;
    sep = strchr(curr, ' ');
    if (sep)
    {
        if (curr[0] == 'd')
            isDir = YES;
        else
            isDir = NO;
    } else
        return self;
    curr = sep;
    
    while (*curr == ' ')
        curr++;
    sep = strchr(curr, ' ');
    if (sep)
    {
        // blocks ?
    } else
        return self;
    curr = sep;
    
    while (*curr == ' ')
        curr++;
    sep = strchr(curr, ' ');
    if (sep)
    {
        // user name (but it may be missing and be a group)
    } else
        return self;
    curr = sep;
    
    while (*curr == ' ')
        curr++;
    sep = strchr(curr, ' ');
    if (sep)
    {
        // group (could be already the size, we check)
        NSScanner *scan;
        scan = [NSScanner scannerWithString:[NSString stringWithCString:curr length:(sep-curr)]];
        foundSize = [scan scanLongLong:&size];
    } else
        return self;
    curr = sep;

    if (!foundSize)
    {
        while (*curr == ' ')
            curr++;
        sep = strchr(curr, ' ');
        if (sep)
        {
            NSScanner *scan;
            scan = [NSScanner scannerWithString:[NSString stringWithCString:curr length:(sep-curr)]];
            foundSize = [scan scanLongLong:&size];
        }
        curr = sep;
    }
    
    while (*curr == ' ')
        curr++;
    sep = strchr(curr, ' ');
    if (sep)
    {
        //month
    }
    curr = sep;
    
    while (*curr == ' ')
        curr++;
    sep = strchr(curr, ' ');
    if (sep)
    {
        //day
    }
    curr = sep;
    
    while (*curr == ' ')
        curr++;
    sep = strchr(curr, ' ');
    if (sep)
    {
        // hour or year
        NSString *tempStr;
        tempStr = [NSString stringWithCString:curr length:(sep-curr)];
//        year = [tempStr intValue];
//        NSLog(@"year: %d", [self year]);
    }
    curr = sep;
    while (*curr == ' ')
        curr++;

    filename = [[NSString stringWithCString:curr] retain];
//    NSLog(@"file name: %@", [self filename]);

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

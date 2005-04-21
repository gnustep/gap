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
    [self->filename release];
    [super dealloc];
}

- (id)initWithFileStats :(char *)fname :(struct stat)fSt
{
    [super init];
    
    self->filename = [[NSString stringWithCString:fname] retain];
    
    if ((fSt.st_mode & S_IFMT) == S_IFDIR)
    {    
        self->isDir = YES;
        self->size = 0;
    } else
    {
        self->isDir = NO;
        self->size = fSt.st_size;
    }
    
    return self;
}

- (id)initWithLsLine :(char *)line
{
    char *sep;
    char *curr;

    [super init];

    NSLog (@"fEl: |%s|", line);
    curr = line;
    sep = strchr(curr, ' ');
    if (sep)
    {
        if (*sep == 'd')
            self->isDir = YES;
        else
            self->isDir = NO;
    } else
        return self;
    curr = sep;
    while (*curr == ' ')
        curr++;
    sep = strchr(curr, ' ');
    if (sep)
    {
        // 
    } else
        return self;
    curr = sep;
    while (*curr == ' ')
        curr++;
    sep = strchr(curr, ' ');
    if (sep)
    {
        // user name
    } else
        return self;
    curr = sep;
    while (*curr == ' ')
        curr++;
    sep = strchr(curr, ' ');
    if (sep)
    {
        // group
    } else
        return self;
    curr = sep;
    while (*curr == ' ')
        curr++;
    sep = strchr(curr, ' ');
    if (sep)
    {
        NSString *tempStr;
        tempStr = [NSString stringWithCString:curr length:(sep-curr)];
        self->size = [tempStr intValue];
        NSLog(@"size: %ld", [self size]);
    }
    curr = sep;
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
        //hour
    }
    curr = sep;
    while (*curr == ' ')
        curr++;
    sep = strchr(curr, ' ');
    if (sep)
    {
        NSString *tempStr;
        tempStr = [NSString stringWithCString:curr length:(sep-curr)];
        self->year = [tempStr intValue];
        NSLog(@"year: %d", [self year]);
    }
    curr = sep;
    while (*curr == ' ')
        curr++;

    self->filename = [[NSString stringWithCString:curr] retain];
    NSLog(@"file name: %@", [self filename]);

    
    return self;
}

/* accessors */
- (NSString *)filename
{
    return self->filename;
}

- (BOOL)isDir
{
    return self->isDir;
}

- (long int)size
{
    return self->size;
}

- (int) year
{
    return self->year;
}

- (int) month
{
    return self->month;
}

- (int) day
{
    return self->day;
}

- (int)hour
{
    return self->hour;
}

- (int)min
{
    return self->min;
}

@end

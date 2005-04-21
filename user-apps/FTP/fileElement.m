//
//  fileElement.m
//  FTP
//
//  Created by Riccardo Mottola on Mon Apr 18 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

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
    
    curr = line;
    sep = strchr(curr, '\t');
    if (sep)
    {
        self->filename = [[NSString stringWithCString:curr length:(sep-curr)] retain];
    }
    NSLog (@"%s", line);
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

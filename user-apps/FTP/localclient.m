/*
   Project: FTP

   Copyright (C) 2005 Riccardo Mottola

   Author: Riccardo Mottola

   Created: 2005-04-09

   Local filesystem class

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

#include <sys/types.h>
#include <dirent.h>
#include <stdlib.h>

#import "localclient.h"
#import "fileElement.h"

@implementation localclient

- (id)init
{
    if (!(self = [super init]))
        return nil;
    homeDir = [NSHomeDirectory() retain];
    return self;
}

/* RM fixme: when do we release workingDir ? */
- (void)dealloc
{
    [homeDir release];
    [super dealloc];
}


/* RM : fixme put in a better max path limit */
/* path could be malloced form the correct strlen? */
/* all this should be rewritten using NSFileManager */
- (NSArray *)dirContents
{
    struct dirent   *dp;
    DIR             *dfd;
    NSMutableArray  *listArr;
    fileElement     *aFile;
    struct stat     fileStats;
    char            filePath[4096];
    char            path[4096];
	
    [self->workingDir getCString:path];

    /* create an array with a reasonable starting size */
    listArr = [NSMutableArray arrayWithCapacity:5];

    if ((dfd = opendir(path)) == NULL)
    {
        fprintf(stderr, "Can't open dir: %s\n", path);
        return NULL;
    }

    /* read the directory entries */
    while ((dp = readdir(dfd)) != NULL)
    {
        if (strcmp(dp->d_name, "."))
        {
            strcpy(filePath, path);
            strcat(filePath, dp->d_name);
            stat(filePath, &fileStats);
            aFile = [[fileElement alloc] initWithFileStats:dp->d_name :fileStats];
            [listArr addObject:aFile];
        }
    }
    return [NSArray arrayWithArray:listArr];
}

- (NSString *)homeDir
{
    return homeDir;
}

@end

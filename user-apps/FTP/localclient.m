/*
   Project: FTP

   Copyright (C) 2005 Free Software Foundation

   Author: Riccardo,,,

   Created: 2005-04-09 18:01:07 +0200 by multix

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

#import "localclient.h"

@implementation localclient

- (NSArray *)getDirList:(char *)path
{
    struct dirent *dp;
    DIR *dfd;
    NSMutableArray     *listArr;

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
            [listArr addObject:[NSString stringWithCString:dp->d_name]];
        }
    }
    return [NSArray arrayWithArray:listArr];
}

@end

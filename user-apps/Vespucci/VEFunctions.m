/*
 Project: Vespucci
 VEFunctions.m

 Utility Functions

 Copyright (C) 2008

 Author: Ing. Riccardo Mottola, Dr. H. Nikolaus Schaller

 Created: 2008-01-25

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


#import "VEFunctions.h"


NSString *canonicizeUrl (NSString *urlStr)
{
    NSString *canonicizedUrl;

    canonicizedUrl = nil;
    if ([urlStr hasPrefix:@"http://"] ||
        [urlStr hasPrefix:@"https://"] ||
        [urlStr hasPrefix:@"file://"]
        )
    {
        canonicizedUrl = [NSString stringWithString:urlStr];
    } else
    {
        if ([urlStr hasPrefix:@"www"])
        {
            canonicizedUrl = [@"http://" stringByAppendingString:urlStr];
        } else if ([urlStr hasPrefix:@"/"])
        {
            canonicizedUrl = [@"file://" stringByAppendingString:urlStr];
        } else {
            canonicizedUrl = [@"http://" stringByAppendingString:urlStr];
        }
    }
    return canonicizedUrl;
}
/*

  NSString+Custom.m
  Zipper

  Copyright (C) 2012-2017 Free Software Foundation, Inc

  Authors: Dirk Olmes <dirk@xanthippe.ping.de>
           Riccardo Mottola <rm@gnu.org>

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
#import "NSString+Custom.h"

@implementation NSString (Convenience)

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_9)
- (BOOL)containsString:(NSString *)string
{
    return (([self rangeOfString:string]).length > 0);
}
#endif

- (BOOL)isEmpty
{
    return [self isEqual:@""];
}

- (NSString *)stringByRemovingWhitespaceFromBeginning
{
    NSCharacterSet *whitespaceSet = nil;
    NSScanner *theScanner = nil;

    whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
    theScanner = [NSScanner scannerWithString:self];

	// do not skip automatically over any chars
	[theScanner setCharactersToBeSkipped:nil];

	// skip all blanks from beginning
	[theScanner scanCharactersFromSet:whitespaceSet intoString:NULL];

	return [self substringFromIndex:[theScanner scanLocation]];
}

@end

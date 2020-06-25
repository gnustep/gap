/*
    This file is part of HelpViewer (http://www.roard.com/helpviewer)
    Copyright (C) 2003 Nicolas Roard (nicolas@roard.com)
                  2020 Riccardo Mottola <rm@gnu.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#include "ModNSString.h"

@implementation NSDecimalNumber (String)
- (NSString*) stringValue
{
  return [NSString stringWithFormat: @"%d", (int)[self doubleValue]];
}
@end

@implementation NSString (Trim)
+ (NSString*) trimString: (NSString*) str
{
    NSMutableString* ret = [[NSMutableString alloc] initWithString: @""];
    NSString* spaceChar = [NSString stringWithString: @" "];
    NSString* EOLChar = [NSString stringWithString: @"\n"];
    NSString* TabChar = [NSString stringWithString: @"\t"];

    BOOL space = YES;
    NSUInteger i;

    for (i = 0; i < [str length]; i++)
    {
	NSString* current = [str substringWithRange: NSMakeRange (i,1)];
	if ([current isEqualToString: spaceChar])
	{
	    if (!space) 
	    {
		[ret appendString: current];
		space = YES;
	    }
	}
	else if ([current isEqualToString: EOLChar]) {}
	else if ([current isEqualToString: TabChar])
	{
	    if (!space)
	    {
		[ret appendString: @" "];
		space = YES;
	    }
	}
	else
	{
	    [ret appendString: current];
	    space = NO;
	}
    }

    //NSLog (@"trimmed string : <%@> ", ret);
    return AUTORELEASE(ret);
}
@end

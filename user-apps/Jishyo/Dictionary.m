/*
	Dictionary.m - Dictionary class for Jishyo.app
	Copyright (C) 2005, Rob Burns
	May 30, 2005

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
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02111, USA.
*/

#ifdef __APPLE__
#include "GNUstep.h"
#endif

#include "Dictionary.h"
#include "xjdic.h"

@implementation Dictionary

- (void) dealloc
{
	[super dealloc];
}

// FIXME Should initialize more than one dictionary

- (id) init
{
	NSString *path = [[NSBundle mainBundle] resourcePath];
	NSString *temp = nil;

	if ((self=[super init]))
	{
		temp = [path stringByAppendingPathComponent: @"edict"];	
		[temp getCString: Dnamet[0]];
		temp = [path stringByAppendingPathComponent: @"edict.xjdx"];
		[temp getCString: XJDXnamet[0]];

		// temp = [path stringByAppendingPathComponent: @"kanjidict"];	
		// [temp getCString: Dnamet[1]];
		// temp = [path stringByAppendingPathComponent: @"kanjidict.xjdx"];
		// [temp getCString: XJDXnamet[1]];
	
		DicSet();
		return self;
	}

	return nil;
}

- (void) setCallback: (SEL)aSelector target: (id)target
{
	_returnResult = aSelector;
	_target = target;
}

// FIXME Should search more than one dictionary

- (void) searchForWord: (NSString *)aString
{
	// dummy implementation that assumes 1 dictionary
	[self searchForWord: (NSString *)aString inDict: 0];
}

/*
	the following function prototype is listed here, so I can remember
	what all the parameters are.

	void xjdserver (int type, int dic_no, long index_posn, int sch_str_len,
      unsigned char *sch_str, int *sch_resp, long *res_index,
      int *hit_posn, int *res_len, unsigned char *res_str,
      long *dic_loc );
*/

- (void) searchForWord: (NSString *)aString inDict: (int)dNum
{
	NSString *result;
	long loc = 0;	
	unsigned char schString[13];
	unsigned char resString[512];
	int resCode = XJ_OK;
	long resIndex = 0;
	int resLen = 0;
	long dicLoc = 0;
	int offset=0;

	// [aString getCString: schString];
 
	NSLog(@"this is it -> %@", aString);
 
	[[aString dataUsingEncoding: NSJapaneseEUCStringEncoding] getBytes: schString];

	printf("blah blah .. %s\n", schString);
  
	xjdserver (XJ_FIND, dNum, loc, slencal(strlen(schString), schString), schString, 
		&resCode, &resIndex, &offset, &resLen, resString, &dicLoc);

	loc = resIndex;

	while(resCode == XJ_OK)
	{
		if (offset != 0)
		{
			loc++;
			xjdserver (XJ_ENTRY, dNum, loc, strlen(schString), schString, 
				&resCode, &resIndex, &offset, &resLen, resString, &dicLoc);
		}

		result = [[NSString alloc] 
  			initWithData: [NSData dataWithBytes: resString length: resLen] 
			encoding: NSJapaneseEUCStringEncoding];

		[_target performSelector: _returnResult withObject: result];

		RELEASE(result);
	}
}

@end


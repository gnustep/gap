/***************************************************************************
                                Functions.m
                          -------------------
    begin                : Sat Apr  5 22:21:33 CST 2003
    copyright            : (C) 2005 by Andrew Ruder
                         : (C) 2015 The GNUstep Application Project
    email                : aeruder@ksu.edu
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#import "TalkSoup.h"
#import "TalkSoupPrivate.h"

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSScanner.h>
#import <Foundation/NSAttributedString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSRange.h>

#include <stdarg.h>

static NSDictionary *mappings = nil;

static void build_mappings(void)
{
	[mappings release];
	mappings = [[NSDictionary dictionaryWithObjectsAndKeys:
	  IRCColorWhite, _l(@"white"),
	  IRCColorBlack, _l(@"black"),
	  IRCColorBlue, _l(@"blue"),
	  IRCColorGreen, _l(@"green"),
	  IRCColorRed, _l(@"red"),
	  IRCColorMaroon, _l(@"maroon"), 
	  IRCColorMagenta, _l(@"magenta"),
	  IRCColorOrange, _l(@"orange"),
	  IRCColorYellow, _l(@"yellow"),
	  IRCColorLightGreen, _l(@"light green"),
	  IRCColorTeal, _l(@"teal"),
	  IRCColorLightCyan, _l(@"light cyan"),
	  IRCColorLightBlue, _l(@"light blue"),
	  IRCColorLightMagenta, _l(@"light magenta"),
	  IRCColorLightGrey, _l(@"light grey"),
	  IRCColorGrey, _l(@"grey"), nil] retain];
}

NSString *IRCColorFromUserColor(NSString *string)
{
	id x;
	if (!mappings) build_mappings();

	string = [string lowercaseString];	
	x = [mappings objectForKey: string];
	
	if ([string hasPrefix: _l(@"custom")])
	{
		int r,g,b;
		id scan;
		
		scan = [NSScanner scannerWithString: string];
		[scan scanUpToCharactersFromSet: [NSCharacterSet whitespaceCharacterSet]
		  intoString: 0];
		
		[scan scanInt: &r];
		[scan scanInt: &g];
		[scan scanInt: &b];
		
		r = r % 1001;
		g = g % 1001;
		b = b % 1001;
		
		return [NSString stringWithFormat: @"IRCColorCustom %d %d %d",
		  r, g, b];
	}
	
	return x;
}

NSArray *PossibleUserColors(void)
{
	if (!mappings) build_mappings();

	return [mappings allKeys];
}
	
static NSArray *get_first_word(NSString *arg)
{
	NSRange aRange;
	NSString *first, *rest;
	id white = [NSCharacterSet whitespaceCharacterSet];

	arg = [arg stringByTrimmingCharactersInSet: white];
	  
	if ([arg length] == 0)
	{
		return [NSArray arrayWithObjects: nil];
	}

	aRange = [arg rangeOfCharacterFromSet: white];

	if (aRange.location == NSNotFound && aRange.length == 0)
	{
		return [NSArray arrayWithObjects: arg, nil];
	}
	
	rest = [[arg substringFromIndex: aRange.location]
	  stringByTrimmingCharactersInSet: white];
	
	first = [arg substringToIndex: aRange.location];

	return [NSArray arrayWithObjects: first, rest, nil];
}

@implementation NSString (Separation)
- (NSArray *)separateIntoNumberOfArguments: (int)num
{
	NSMutableArray *array = [[NSMutableArray new] autorelease];
	id object;
	NSString *string = self;
	
	if (num == 0)
	{
		return [NSArray arrayWithObject: string];
	}
	if (num == 1)
	{
		return [NSArray arrayWithObject: [string 
		  stringByTrimmingCharactersInSet: 
		    [NSCharacterSet whitespaceCharacterSet]]];
	}
	if (num == 2)
	{
		return get_first_word(string);
	}
	
	while (num != 1)
	{
        unsigned temp;
		object = get_first_word(string);
		temp = [object count];
		switch(temp)
		{
			case 0:
				return [NSArray arrayWithObjects: nil];
			case 1:
				[array addObject: [object objectAtIndex: 0]];
				return array;
			case 2:
				string = [object objectAtIndex: 1];
				[array addObject: [object objectAtIndex: 0]];
				if (num > 0) num--;
		}
	}
	[array addObject: string];
	return array;
}
@end

@implementation NSMutableAttributedString (AttributesAppend)
- (void)addAttributeIfNotPresent: (NSString *)name value: (id)aVal
   withRange: (NSRange)aRange
{
	NSRange effect;
	NSDictionary *aDict;
	NSMutableDictionary *aDict2;
	
	if ([self length] == 0) return;
	
	[self beginEditing];
	
	aDict = [self attributesAtIndex: aRange.location effectiveRange: &effect];
	
	while (1)
	{
		if (![aDict objectForKey: name])
		{
			if (effect.location + effect.length > aRange.location + aRange.length)
			{
				effect.length = aRange.location + aRange.length - effect.location;
			}
				
			aDict2 = [NSMutableDictionary dictionaryWithDictionary: aDict];
			[aDict2 setObject: aVal forKey: name];
			[self setAttributes: aDict2 range: effect];
		}
		effect.location = effect.location + effect.length;
		if (effect.location < aRange.length + aRange.location)
		{
			aDict = [self attributesAtIndex: effect.location 
			  effectiveRange: &effect];
		}
		else
		{
			break;
		}
	}
	
	[self endEditing];
}
- (void)replaceAttribute: (NSString *)name withValue: (id)aVal
   withValue: (id)newVal withRange: (NSRange)aRange
{
	NSRange effect;
	NSDictionary *aDict;
	NSMutableDictionary *aDict2;
	
	if ([self length] == 0) return;
	
	[self beginEditing];
	
	aDict = [self attributesAtIndex: aRange.location effectiveRange: &effect];
	
	while (1)
	{
		if ([[aDict objectForKey: name] isEqual: aVal])
		{
			if (effect.location + effect.length > aRange.location + aRange.length)
			{
				effect.length = aRange.location + aRange.length - effect.location;
			}
				
			aDict2 = [NSMutableDictionary dictionaryWithDictionary: aDict];
			[aDict2 setObject: newVal forKey: name];
			[self setAttributes: aDict2 range: effect];
		}
			
		effect.location = effect.location + effect.length;
		if (effect.location < aRange.length + aRange.location)
		{
			aDict = [self attributesAtIndex: effect.location 
			  effectiveRange: &effect];
		}
		else
		{
			break;
		}
	}
	
	[self endEditing];
}
- (void)setAttribute: (NSString *)name toValue: (id)aVal
   inRangesWithAttribute: (NSString *)name2 matchingValue: (id)aVal2
   withRange: (NSRange)aRange
{
	NSRange effect;
	NSDictionary *aDict;
	NSMutableDictionary *aDict2;
	id temp;
	
	if ([self length] == 0) return;
	if (!name2) return;
	
	[self beginEditing];
	
	aDict = [self attributesAtIndex: aRange.location effectiveRange: &effect];
	
	while (1)
	{
		temp = [aDict objectForKey: name2];
		if ([temp isEqual: aVal2] || temp == aVal2)
		{
			if (effect.location + effect.length > aRange.location + aRange.length)
			{
				effect.length = aRange.location + aRange.length - effect.location;
			}
				
			aDict2 = [NSMutableDictionary dictionaryWithDictionary: aDict];
			[aDict2 setObject: aVal forKey: name];
			[self setAttributes: aDict2 range: effect];
		}
			
		effect.location = effect.location + effect.length;
		if (effect.location < aRange.length + aRange.location)
		{
			aDict = [self attributesAtIndex: effect.location 
			  effectiveRange: &effect];
		}
		else
		{
			break;
		}
	}
	
	[self endEditing];
}
- (void)setAttribute: (NSString *)name toValue: (id)aVal
   inRangesWithAttributes: (NSArray *)name2 matchingValues: (NSArray *)aVal2
   withRange: (NSRange)aRange
{
	NSRange effect;
	NSDictionary *aDict;
	NSMutableDictionary *aDict2;
	id temp;
	id object1;
	id object2;
	BOOL doIt;
	NSEnumerator *iter1;
	NSEnumerator *iter2;
	
	if ([self length] == 0) return;
	
	[self beginEditing];
	
	aDict = [self attributesAtIndex: aRange.location effectiveRange: &effect];
	
	while (1)
	{
		iter1 = [name2 objectEnumerator];
		iter2 = [aVal2 objectEnumerator];
		doIt = YES;
		while ((object1 = [iter1 nextObject]) && (object2 = [iter2 nextObject]))
		{
			temp = [aDict objectForKey: object1];
			if (![temp isEqual: object2] && (temp || 
			  ![object2 isKindOfClass: [NSNull class]]))
			{
				doIt = NO;
				break;
			}
		}
		if (doIt)
		{
			if (effect.location + effect.length > aRange.location + aRange.length)
			{
				effect.length = aRange.location + aRange.length - effect.location;
			}
				
			aDict2 = [NSMutableDictionary dictionaryWithDictionary: aDict];
			[aDict2 setObject: aVal forKey: name];
			[self setAttributes: aDict2 range: effect];
		}
			
		effect.location = effect.location + effect.length;
		if (effect.location < aRange.length + aRange.location)
		{
			aDict = [self attributesAtIndex: effect.location 
			  effectiveRange: &effect];
		}
		else
		{
			break;
		}
	}
	
	[self endEditing];
}
@end

static NSCharacterSet *wildcardCharacters = nil;
static NSCharacterSet *normalCharacters = nil;

@implementation NSString (IRCWildcards)
- (BOOL)matchesIRCWildcard: (NSString *)wildcard
{
  NSScanner *scanner = [NSScanner scannerWithString: wildcard];
  NSString *read;
  unichar special;
  NSString *left = self;

  if (!wildcardCharacters)
    {
      wildcardCharacters = [[NSCharacterSet characterSetWithCharactersInString: @"*?"] retain];
      normalCharacters = [[wildcardCharacters invertedSet] retain];
    }
  while (![scanner isAtEnd])
    {
      unsigned charsskip;
      unsigned charsleft;

      if (![scanner scanUpToCharactersFromSet: wildcardCharacters intoString: &read])
	read = @"";
      charsskip = [read length];
      if (charsskip && ![left hasPrefix: read])
	return NO;
      left = [left substringFromIndex: charsskip];
      charsleft = [left length];
      if ([scanner isAtEnd])
	{
	  /* If we have chars left and we are at the wc end, oops */
	  if (charsleft > 0) return NO;
	  return YES;
	}

      /* Next char is a wildcard */
      special = [wildcard characterAtIndex: charsskip];
      wildcard = [wildcard substringFromIndex: charsskip + 1];
      [scanner setScanLocation: [scanner scanLocation] + 1];
      if (special == '*')
	{
	  unsigned j;
	  if ([scanner isAtEnd]) /* Last char is an asterick? that matches */
	    return YES;
	  for (j = 0; j <= charsleft; j++)
	    {
	      /* Look for a recursive match to work */
	      if ([[left substringFromIndex: j] matchesIRCWildcard: wildcard])
		return YES;
	    }
	  return NO;
	}

      /* We are doing a question mark, if we have a char left, keep going */
      if (charsleft == 0)
	return NO;
      else
	left = [left substringFromIndex: 1];
    }
  return ([left length] == 0) ? YES : NO;
}
@end

NSMutableAttributedString *BuildAttributedString(id aObject, ...)
{
	va_list ap;
	NSMutableAttributedString *str;
	id objects;
	id keys;
	int state = 0;
	NSMutableAttributedString *newstr = nil;
	int x;
	int y;
	
	if (aObject == nil) return 
	  [[[NSMutableAttributedString alloc] initWithString: @""] autorelease];
	
	objects = [NSMutableArray new];
	keys = [NSMutableArray new];
	
	str = [[[NSMutableAttributedString alloc] initWithString: @""] autorelease];
	va_start(ap, aObject);
	
	do
	{
		if (state != 0)
		{
			if (state == 1)
			{
				[keys addObject: aObject];
				state = 2;
			}
			else if (state == 2)
			{
				[objects addObject: aObject];
				state = 0;
			}
		}
		else
		{
			if ([aObject isKindOfClass: [NSNull class]])
			{
				state = 1;
			}
			else
			{
				if ([aObject isKindOfClass: [NSAttributedString class]])
				{
					newstr = [[NSMutableAttributedString alloc] 
					  initWithAttributedString: aObject];
				}
				else
				{
					newstr = [[NSMutableAttributedString 
					  alloc] initWithString: [aObject description]];
				}
				
				if (newstr)
				{
					y = [objects count];
					for (x = 0; x < y; x++)
					{
						[newstr addAttributeIfNotPresent: [keys objectAtIndex: x]
						  value: [objects objectAtIndex: x] withRange:
						   NSMakeRange(0, [newstr length])];
					}
					[objects removeAllObjects];
					[keys removeAllObjects];
					[str appendAttributedString: newstr];
					[newstr release];
				}
			}
		}
	} while ((aObject = va_arg(ap, id)));

	va_end(ap);
	[objects release];
	[keys release];
	
	return str;
}

NSMutableAttributedString *BuildAttributedFormat(id aObject, ...)
{
	va_list ap;
	NSMutableAttributedString *str;
	NSString *format;
	NSRange range;
	NSRange tmpr;
	int len;
	id tmp = nil;
	
	str = [[[NSMutableAttributedString alloc] initWithString: @""] autorelease];

	if (aObject == nil) return str;

	if ([aObject isKindOfClass: [NSString class]])
	{
		aObject = [[[NSAttributedString alloc]
		  initWithString: aObject] autorelease];
	}
	else if (![aObject isKindOfClass: [NSAttributedString class]])
	{
		return str;
	}	
	
	va_start(ap, aObject);
	
	format = [aObject string];
	range.location = 0;
	range.length = len = [format length];
	
	while ((int)range.location < len)
	{
		tmpr = [format rangeOfString: @"%@" options: 0 range: range];
		
		if (tmpr.location == NSNotFound)
		{
			[str appendAttributedString: [aObject attributedSubstringFromRange: range]];
			return str;
		}
		else
		{
			NSRange oldRange = range;
			
			range.location = tmpr.location + 2;
			range.length = len - range.location;
			
			tmpr.length = tmpr.location - oldRange.location;
			tmpr.location = oldRange.location;
			
			[str appendAttributedString: [aObject attributedSubstringFromRange: tmpr]];
			tmp = va_arg(ap, id);
			if (tmp == nil)
			  {
			    tmp = [[[NSAttributedString alloc] initWithString:@""] autorelease];
			  }
			else if ([tmp isKindOfClass: [NSString class]])
			{
				tmp = [[[NSAttributedString alloc] initWithString:
				  tmp] autorelease];
			}
			else if (![tmp isKindOfClass: [NSAttributedString class]])
			{
				tmp = [[[NSAttributedString alloc] initWithString:
				  [tmp description]] autorelease];
			}
			
			[str appendAttributedString: tmp];
		}
	}	
	va_end(ap);
	
	return str;
}

NSArray *IRCUserComponents(NSAttributedString *from)
{
	NSArray *components = [[from string] componentsSeparatedByString: @"!"];
	NSAttributedString *string1, *string2;
	NSRange aRange = {0, 0};
	
	if (from)
	{	
		aRange.location = 0;
		aRange.length = [(NSString *)[components objectAtIndex: 0] length];
	
		string1 = [from attributedSubstringFromRange: aRange];
	
		aRange.location = aRange.length + 1;
	}
	else
	{
		string1 = [[[NSAttributedString alloc] initWithString: @""] autorelease];
	}
	
	if (((int)[from length] - (int)aRange.location) <= 0)
	{
		string2 = [[[NSAttributedString alloc] initWithString: @""] autorelease];
	}
	else
	{
		aRange.length = [from length] - aRange.length - 1;
		string2 = [from attributedSubstringFromRange: aRange];
	}
	
	return [NSArray arrayWithObjects: string1, string2, nil];
}

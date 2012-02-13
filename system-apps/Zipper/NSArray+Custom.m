#import <Foundation/Foundation.h>
#import "NSArray+Custom.h"

@implementation NSArray (Custom)

- (NSArray *)arrayByRemovingEmptyStrings;
{
	NSMutableArray *retValue;
	NSEnumerator *cursor;
	id element;
	
	retValue = [NSMutableArray array];
	cursor = [self objectEnumerator];
	while ((element = [cursor nextObject]) != nil)
	{
		if ([element isKindOfClass:[NSString class]])
		{
			if ([element isEqual:@""] == NO)
			{
				[retValue addObject:element];
			}
		}
		else
		{
			[retValue addObject:element];
		}
	}
	
	return [[retValue copy] autorelease];
}

@end

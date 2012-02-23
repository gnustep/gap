#import <Foundation/Foundation.h>
#import "NSObject+Custom.h"

@implementation NSObject (Custom)

- (void)methodIsAbstract:(SEL)selector;
{
    [NSException raise:NSInternalInconsistencyException 
		format:@"*** No concrete implementation for selector '%@' in class %@. Abstract definition must be overriden.", 
		NSStringFromSelector(selector), NSStringFromClass(isa)];
}

@end

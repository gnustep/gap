#import <Foundation/Foundation.h>
#import "NSString+Custom.h"

@implementation NSString (Convenience)

- (BOOL)containsString:(NSString *)string
{
    return (([self rangeOfString:string]).length > 0);
}

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

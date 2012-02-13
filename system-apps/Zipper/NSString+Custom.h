#import <Foundation/Foundation.h>

@interface NSString (Convenience)

- (BOOL)containsString:(NSString *)string;
- (BOOL)isEmpty;
- (NSString *)stringByRemovingWhitespaceFromBeginning;

@end

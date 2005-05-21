#include <AppKit/AppKit.h>
#include "Go.h"

@interface StoneUI : Stone
{
	NSPoint position;
	NSImage *_cache;
}

- (void) drawWithRadius:(float)radius
				atPoint:(NSPoint)p;
- (void) drawIndicatorWithRadius:(float)radius
						 atPoint:(NSPoint)p
						   alpha:(float)alpha;
- (NSPoint) position;
- (void) setPosition:(NSPoint)p;
- (void) centerAttributedString:(NSMutableString *)attrstr
						toPoint:(NSPoint) p
					 withRadius:(float)radius;
@end

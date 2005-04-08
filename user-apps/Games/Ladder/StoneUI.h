#include <AppKit/AppKit.h>
#include "Go.h"

@interface StoneUI : Stone
{
	NSPoint position;
	NSImage *_cache;
}
- (void) drawWithRadius:(float)radius
				atPoint:(NSPoint)p;
- (void) xdrawWithRadius:(float)radius
				atPoint:(NSPoint)p;
- (NSPoint) position;
- (void) setPosition:(NSPoint)p;
@end

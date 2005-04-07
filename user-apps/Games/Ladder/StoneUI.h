#include <AppKit/AppKit.h>
#include "Go.h"

@interface StoneUI : Stone
{
	NSPoint position;
	NSImage *_cache;
}
- (void) drawWithRadius:(float)radius;
- (void) drawShadowWithRadius:(float)radius;
- (NSPoint) position;
- (void) setPosition:(NSPoint)p;
@end

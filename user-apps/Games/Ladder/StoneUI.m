#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#include "StoneUI.h"
#include <math.h>

#define RFACTOR 9.0
#define CELLSIZE 1.0
#define RADIUS (CELLSIZE/2)
#define CACHE_FACTOR 2.5
#define SHIFT_FACTOR 1.5


static NSMapTable *_whiteCacheMap;
static NSMapTable *_blackCacheMap;
static NSMapTable *_shadeCacheMap;

static inline NSSize __image_size_for_radius(float radius)
{
	radius = floor(radius); // just to reduce math problem in -art
	return NSMakeSize(radius * CACHE_FACTOR, radius * CACHE_FACTOR);
}

@interface StoneUICache : NSImage
{
	PlayerColorType _stoneColor;
}
+ (id) stoneImageWithRadius:(float)radius
				  colorType:(PlayerColorType)playerColorType;
- (id) initWithRadius:(float)radius
			colorType:(PlayerColorType)playerColorType;
@end

@implementation StoneUICache

static void __draw_shadow_with_radius(NSGraphicsContext *ctxt, float radius)
{
	DPSnewpath(ctxt);

	float bs = CELLSIZE;
	float a = 0.3;

	float r = RADIUS - RADIUS/RFACTOR;

	DPSgsave(ctxt);
	DPStranslate(ctxt, RADIUS/10,-RADIUS/10);
	[[NSColor blackColor] set];
	r = (RADIUS - RADIUS/25);
	DPSmoveto(ctxt, r, 0);
	DPSarc(ctxt, 0, 0, r, 0, 360);
	while (r > (RADIUS/radius)*2)
	{
		r -= RADIUS/radius;
		DPSarcn(ctxt, 0, 0, r, 360, 0);
		a = a * 1.50;
		if (a > 1) a = 1;
		DPSsetalpha(ctxt, a/4);
		DPSfill(ctxt);
		DPSmoveto(ctxt, r, 0);
		DPSarc(ctxt, 0, 0, r, 0, 360);
	}
	DPSfill(ctxt);
	DPSgrestore(ctxt);
}

static void __draw_white_with_radius(NSGraphicsContext *ctxt, float radius)
{
	float bs = CELLSIZE;
	float rd = RADIUS - RADIUS/RFACTOR;
	float a,b,c,ct;

	[[NSColor blackColor] set];
	DPSmoveto(ctxt, rd, 0);
	DPSarc(ctxt, 0, 0, rd, 0, 360);
	DPSfill(ctxt );

	DPSnewpath(ctxt);

	[[NSColor whiteColor] set];
	rd = RADIUS - RADIUS/RFACTOR;

	ct = 0;
	DPSmoveto(ctxt, rd, 0);
	DPSarc(ctxt, 0, 0, rd, 0, 360);
	DPSsetlinewidth(ctxt, RADIUS/25);
	while (rd > 0)
	{
		rd -= RADIUS/(radius*2);
		ct -= RADIUS/(radius*6);

		DPSarcn(ctxt, ct, -ct, rd - RADIUS/25, 360, 0);

		b = rd/(bs/2 - RADIUS/25);
		b = sqrt(1 - b * b);
		DPSsetalpha(ctxt, b);

		DPSfill(ctxt);
		DPSmoveto(ctxt, ct + rd, -ct);
		DPSarc(ctxt, ct, -ct, rd, 0, 360);
		a += a * 0.15;
	}
	DPSfill(ctxt);
}

static void __draw_black_with_radius(NSGraphicsContext *ctxt, float radius)
{
	float bs = CELLSIZE;
	float ct;
	float rd = RADIUS - RADIUS/RFACTOR;
	float a,b;
	[[NSColor blackColor] set];
	DPSmoveto(ctxt, rd, 0);
	DPSarc(ctxt, 0, 0, rd, 0, 360);
	DPSfill(ctxt);

	[[NSColor darkGrayColor] set];

	DPSsetalpha(ctxt, 1 - rd/RADIUS);
	DPSsetlinewidth(ctxt, RADIUS/10);
	DPSnewpath(ctxt);
	DPSmoveto(ctxt, rd, 0);
	DPSarc(ctxt, 0, 0, rd, 0, 360);
	while (rd > 0)
	{
		rd -= RADIUS/radius;

		DPSarcn(ctxt, 0, 0, rd, 360, 0);
		DPSstroke(ctxt);
		DPSfill(ctxt);
		DPSsetalpha(ctxt, 1 - rd/RADIUS);
		DPSmoveto(ctxt, rd, 0);
		DPSarc(ctxt, 0, 0, rd, 0, 360);
	}
	DPSfill(ctxt);
	DPSnewpath(ctxt);


	[[NSColor whiteColor] set];
	rd = RADIUS - RADIUS/RFACTOR;
	a = 0.1;

	ct = 0;
	DPSmoveto(ctxt, rd, 0);
	DPSarc(ctxt, 0, 0, rd, 0, 360);
	while (rd > (RADIUS/radius))
	{
		float z;

		rd -= RADIUS/radius;
		ct -= RADIUS/(radius * 3);

		DPSarcn(ctxt, ct, -ct, rd, 360, 0);
		z = 1 - (rd/(RADIUS - RADIUS/RFACTOR));
		if (z > 1) z = 1;
		DPSsetalpha(ctxt, z * 0.2);
		DPSfill(ctxt);
		DPSmoveto(ctxt, ct + rd, -ct);
		DPSarc(ctxt, ct, -ct, rd, 0, 360);
	}
	DPSfill(ctxt);
}

+ (void) initialize
{
	_whiteCacheMap = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonRetainedObjectMapValueCallBacks, 20);
	_blackCacheMap = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonRetainedObjectMapValueCallBacks, 20);
	_shadeCacheMap = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonRetainedObjectMapValueCallBacks, 20);

}

+ (StoneUICache *) stoneImageWithRadius:(float)radius
							  colorType:(PlayerColorType)playerColorType
{
	return AUTORELEASE([[self alloc] initWithRadius:radius
										  colorType:playerColorType]);
}

- (id) initWithRadius:(float)radius
			colorType:(PlayerColorType)playerColorType
{
	NSNumber *v = [NSNumber numberWithFloat:radius];
	NSMapTable *table;
	NSGraphicsContext *ctxt=GSCurrentContext();

	StoneUICache *cache;

	if (playerColorType == WhitePlayerType)
	{
		table = _whiteCacheMap;
	}
	else if (playerColorType == BlackPlayerType)
	{
		table = _blackCacheMap;
	}
	else
	{
		table = _shadeCacheMap;
	}
	cache = NSMapGet(table, v);

	if (cache != nil)
	{
		_stoneColor = -1;
		AUTORELEASE(self);
		return RETAIN(cache);
	}

//	NSDebugLog(@"generate %p cache for %@ with radius %g",self ,color == BlackStone?@"black":@"white", radius);

	_stoneColor = playerColorType;
	[self initWithSize:__image_size_for_radius(radius)];

	/* generate cache */

	[self lockFocus];
	DPSgsave(ctxt);

	DPStranslate(ctxt, radius * CACHE_FACTOR / 2, radius * CACHE_FACTOR / 2);
	DPSscale(ctxt, radius/RADIUS,radius/RADIUS);
	__draw_shadow_with_radius(ctxt, radius);
	if (playerColorType == WhitePlayerType)
	{
		__draw_white_with_radius(ctxt, radius);
	}
	else if (playerColorType == BlackPlayerType)
	{
		__draw_black_with_radius(ctxt, radius);
	}

	DPSgrestore(ctxt);
	[self unlockFocus];

	NSMapInsert(table, v, self);

	return self;
}

- (void) dealloc
{
	NSMapTable *table;
	NSMapEnumerator men;
	NSValue *vsize = nil;
	id image;
	if (_stoneColor == WhitePlayerType)
	{
		table = _whiteCacheMap;
	}
	else if (_stoneColor == BlackPlayerType)
	{
		table = _blackCacheMap;
	}
	else if (_stoneColor == EmptyPlayerType)
	{
		table = _shadeCacheMap;
	}
	else
	{
		[super dealloc];
		return;
	}

	men = NSEnumerateMapTable(table);
	while (NSNextMapEnumeratorPair(&men, (void **)&vsize, (void **)&image))
	{
		if (image == self)
		{
			NSMapRemove(table, vsize);
			break;
		}
	}
	NSEndMapTableEnumeration(&men);
	[super dealloc];
}
@end

@implementation StoneUI

- (NSPoint) position
{
	return position;
}

- (void) setPosition:(NSPoint)p
{
	position = p;
}

- (id) init
{
	[self setPosition:NSMakePoint((random()%20)/10.0 - 1.0,(random()%20)/10.0 - 1.0)];
	return self;
}

- (void) dealloc
{
	RELEASE(_cache);
	[super dealloc];
}

- (void) centerAttributedString:(NSMutableString *)attrstr
						toPoint:(NSPoint) p
					 withRadius:(float)radius
{
	float f = (radius/RFACTOR)/SHIFT_FACTOR;
	[attrstr drawAtPoint: NSMakePoint(position.x * f + p.x, position.y * f + p.y)];
}

- (void) drawIndicatorWithRadius:(float)radius
						 atPoint:(NSPoint)p
						   alpha:(float)alpha
{
	NSGraphicsContext *ctxt=GSCurrentContext();
	float f = (radius/RFACTOR)/SHIFT_FACTOR;
	int i;
	float a,rad,g;

	rad = radius * 2;

	DPSgsave(ctxt);
	a = 0.05 * alpha;
	g = 0.05 * alpha;

	for (i = 0; i < 8; i++,rad*= 0.9, a+= g, g*=0.8)
	{
		if (a > 1.0)
		{
			a = 1.0;
		}
		DPSnewpath(ctxt);
		[[NSColor colorWithDeviceRed:1.0
							   green:1.0
								blue:0.7
							   alpha:a] set];
		DPSarc(ctxt,position.x * f + p.x, position.y * f + p.y, rad, 0, 360);
		DPSarcn(ctxt,position.x * f + p.x, position.y * f + p.y, rad * 0.8, 360, 0);
		DPSfill(ctxt);
	}
	if (a > 1.0)
	{
		a = 1.0;
	}
	DPSnewpath(ctxt);
	DPSsetalpha(ctxt, a);
	DPSarc(ctxt,position.x * f + p.x, position.y * f + p.y, rad, 0, 360);
	DPSfill(ctxt);

	DPSgrestore(ctxt);
}

- (void) drawWithRadius:(float)radius
				atPoint:(NSPoint)p
{
	float f = (radius/RFACTOR)/SHIFT_FACTOR;

	ASSIGN(_cache, [StoneUICache stoneImageWithRadius:radius
											colorType:_colorType]);

	[_cache compositeToPoint:NSMakePoint(-radius * CACHE_FACTOR/2 + position.x * f + p.x, -radius * CACHE_FACTOR/2 + position.y * f + p.y)
				   operation:NSCompositeSourceAtop];
}

@end


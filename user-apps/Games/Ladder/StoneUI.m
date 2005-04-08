#include "StoneUI.h"
#include <math.h>

#define RFACTOR 9.0
#define CELLSIZE 1.0
#define RADIUS (CELLSIZE/2)
#define CACHE_FACTOR 2.5
#define SHIFT_FACTOR 1.5


static NSMapTable *_whiteCacheMap;
static NSMapTable *_blackCacheMap;

static inline NSSize __image_size_for_radius(float radius)
{
	radius = roundf(radius); // just to reduce math problem in -art
	return NSMakeSize(radius * CACHE_FACTOR, radius * CACHE_FACTOR);
}

@interface StoneUICache : NSImage
{
	StoneColor _stoneColor;
}
+ (id) stoneImageWithRadius:(float)radius
				 stoneColor:(StoneColor)color;
- (id) initWithRadius:(float)radius
		   stoneColor:(StoneColor)color;
@end

@implementation StoneUICache

static void __draw_shadow_with_radius(float radius)
{
	PSnewpath();

	float bs = CELLSIZE;
	float a = 0.3;

	float r = RADIUS - RADIUS/RFACTOR;

	PSgsave();
	PStranslate(RADIUS/10,-RADIUS/10);
	[[NSColor blackColor] set];
	r = (RADIUS - RADIUS/25);
	PSmoveto(r, 0);
	PSarc(0, 0, r, 0, 360);
	while (r > (RADIUS/radius)*2)
	{
		r -= RADIUS/radius;
		PSarcn(0, 0, r, 360, 0);
		a = a * 1.50;
		if (a > 1) a = 1;
		PSsetalpha(a/4);
		PSfill();
		PSmoveto(r, 0);
		PSarc(0, 0, r, 0, 360);
	}
	PSfill();
	PSgrestore();
}

static void __draw_white_with_radius(float radius)
{
	float bs = CELLSIZE;
	float rd = RADIUS - RADIUS/RFACTOR;
	float a,b,c,ct;

	[[NSColor blackColor] set];
	PSmoveto(rd, 0);
	PSarc(0, 0, rd, 0, 360);
	PSfill();

	PSnewpath();

	[[NSColor whiteColor] set];
	rd = RADIUS - RADIUS/RFACTOR;

	ct = 0;
	PSmoveto(rd, 0);
	PSarc(0, 0, rd, 0, 360);
	PSsetlinewidth(RADIUS/25);
	while (rd > 0)
	{
		rd -= RADIUS/(radius*2);
		ct -= RADIUS/(radius*6);

		PSarcn(ct, -ct, rd - RADIUS/25, 360, 0);

		b = rd/(bs/2 - RADIUS/25);
		b = sqrt(1 - b * b);
		PSsetalpha(b);

		PSfill();
		PSmoveto(ct + rd, -ct);
		PSarc(ct, -ct, rd, 0, 360);
		a += a * 0.15;
	}
	PSfill();
}

static void __draw_black_with_radius(float radius)
{
	float bs = CELLSIZE;
	float ct;
	float rd = RADIUS - RADIUS/RFACTOR;
	float a,b;
	[[NSColor blackColor] set];
	PSmoveto(rd, 0);
	PSarc(0, 0, rd, 0, 360);
	PSfill();

	[[NSColor darkGrayColor] set];

	PSsetalpha(1 - rd/RADIUS);
	PSsetlinewidth(RADIUS/10);
	PSnewpath();
	PSmoveto(rd, 0);
	PSarc(0, 0, rd, 0, 360);
	while (rd > 0)
	{
		rd -= RADIUS/radius;

		PSarcn(0, 0, rd, 360, 0);
		PSstroke();
		PSfill();
		PSsetalpha(1 - rd/RADIUS);
		PSmoveto(rd, 0);
		PSarc(0, 0, rd, 0, 360);
	}
	PSfill();
	PSnewpath();


	[[NSColor whiteColor] set];
	rd = RADIUS - RADIUS/RFACTOR;
	a = 0.1;

	ct = 0;
	PSmoveto(rd, 0);
	PSarc(0, 0, rd, 0, 360);
	while (rd > (RADIUS/radius))
	{
		float z;

		rd -= RADIUS/radius;
		ct -= RADIUS/(radius * 3);

		PSarcn(ct, -ct, rd, 360, 0);
		z = 1 - (rd/(RADIUS - RADIUS/RFACTOR));
		if (z > 1) z = 1;
		PSsetalpha(z * 0.2);
		PSfill();
		PSmoveto(ct + rd, -ct);
		PSarc(ct, -ct, rd, 0, 360);
	}
	PSfill();
}

+ (void) initialize
{
	_whiteCacheMap = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonRetainedObjectMapValueCallBacks, 20);
	_blackCacheMap = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonRetainedObjectMapValueCallBacks, 20);
}

+ (StoneUICache *) stoneImageWithRadius:(float)radius
				 stoneColor:(StoneColor)color
{
	return AUTORELEASE([[self alloc] initWithRadius:radius
										 stoneColor:color]);
}

- (id) initWithRadius:(float)radius
		   stoneColor:(StoneColor)color
{
	NSNumber *v = [NSNumber numberWithFloat:radius];
	NSMapTable *table;

	StoneUICache *cache;

	if (color == WhiteStone)
	{
		table = _whiteCacheMap;
	}
	else
	{
		table = _blackCacheMap;
	}
	cache = NSMapGet(table, v);

	if (cache != nil)
	{
		_stoneColor = -1;
		AUTORELEASE(self);
		return RETAIN(cache);
	}

//	NSLog(@"generate %p cache for %@ with radius %g",self ,color == BlackStone?@"black":@"white", radius);

	_stoneColor = color;
	[self initWithSize:__image_size_for_radius(radius)];

	/* generate cache */

	[self lockFocus];
	PSgsave();

	PStranslate(radius * CACHE_FACTOR / 2, radius * CACHE_FACTOR / 2);
	PSscale(radius/RADIUS,radius/RADIUS);
	__draw_shadow_with_radius(radius);
	if (color == WhiteStone)
	{
		__draw_white_with_radius(radius);
	}
	else
	{
		__draw_black_with_radius(radius);
	}

	PSgrestore();
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
	if (_stoneColor == WhiteStone)
	{
		table = _whiteCacheMap;
	}
	else if (_stoneColor == BlackStone)
	{
		table = _blackCacheMap;
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


- (void) drawWithRadius:(float)radius
				atPoint:(NSPoint)p
{
	float f = (radius/RFACTOR)/SHIFT_FACTOR;

	ASSIGN(_cache, [StoneUICache stoneImageWithRadius:radius
										   stoneColor:_color]);

	[_cache compositeToPoint:NSMakePoint(-radius * CACHE_FACTOR/2 + position.x * f + p.x, -radius * CACHE_FACTOR/2 + position.y * f + p.y)
				   operation:NSCompositeSourceAtop];
}

@end


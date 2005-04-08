#include "StoneUI.h"
static NSMapTable *_whiteCacheMap;
static NSMapTable *_blackCacheMap;

@interface StoneUICache : NSImage
@end

@implementation StoneUICache
- (void) dealloc
{
	NSMapTable *table;
	NSMapEnumerator * men;
	NSNumber *radius = nil;
	id image;
	if (_color == WhiteStone)
	{
		table = _whiteCacheMap;
	}
	else
	{
		table = _blackCacheMap;
	}
	NSEnumerateMapTable(table);
	while (NSNextMapEnumeratorPair(&men, (void **)&radius, (void **)&image))
	{
		if (image == self)
		{
			break;
		}
	}
	NSMapRemove(table, radius);
	NSLog(@"dealloc %@",self);
	[super dealloc];
}
@end

@interface StoneUI (Private)
- (void) prepareImageCacheWithRadius:(float)radius;
- (void) drawShadowWithRadius:(float)radius;
- (void) drawWhiteWithRadius:(float)radius;
- (void) drawBlackWithRadius:(float)radius;
@end

#define RFACTOR 9.0
#define CELLSIZE 1.0
#define RADIUS (CELLSIZE/2)
#define CACHE_FACTOR 2.5
#define SHIFT_FACTOR 1.5


@implementation StoneUI

+ (void) initialize
{
	_whiteCacheMap = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonRetainedObjectMapValueCallBacks, 20);
	_blackCacheMap = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonRetainedObjectMapValueCallBacks, 20);
}


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

- (void) prepareImageCacheWithRadius:(float)radius
{
	NSNumber *v = [[NSNumber alloc] initWithFloat:radius];
	NSImage *cache;
	NSMapTable *table;
	AUTORELEASE(v);

	radius = roundf(radius); // just to reduce math problem in -art

	if (_color == WhiteStone)
	{
		table = _whiteCacheMap;
	}
	else
	{
		table = _blackCacheMap;
	}
	cache = NSMapGet(table, v);

	if (cache == nil)
	{
		/* generate cache */
		cache = AUTORELEASE([[StoneUICache alloc] initWithSize:NSMakeSize(radius * CACHE_FACTOR, radius * CACHE_FACTOR)]);
		[cache lockFocus];
		PSgsave();
		PStranslate(radius * CACHE_FACTOR / 2, radius * CACHE_FACTOR / 2);
		PSscale(radius/RADIUS,radius/RADIUS);
		[self drawShadowWithRadius:radius];
		if (_color == WhiteStone)
		{
			[self drawWhiteWithRadius:radius];
		}
		else
		{
			[self drawBlackWithRadius:radius];
		}
		PSgrestore();
		[cache unlockFocus];
		NSMapInsert(table, v, cache);
		NSLog(@"gen cache");
	}

	ASSIGN(_cache, cache);
}


- (void) drawWithRadius:(float)radius
				atPoint:(NSPoint)p
{
	float f = (radius/RFACTOR)/SHIFT_FACTOR;

	[self prepareImageCacheWithRadius:radius];

	[_cache compositeToPoint:NSMakePoint(-radius * CACHE_FACTOR/2 + position.x * f + p.x, -radius * CACHE_FACTOR/2 + position.y * f + p.y)
				   operation:NSCompositeSourceAtop];
}

- (void) drawShadowWithRadius:(float)radius
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

@end

@implementation StoneUI (Private)

- (void) drawWhiteWithRadius:(float)radius
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

- (void) drawBlackWithRadius:(float)radius
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
@end

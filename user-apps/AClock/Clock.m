/*
 Project: AClock
 Clock.m

 Copyright (C) 2003-2017 GNUstep Application Project

 Author: Alexander Malmberg
         Banlu Kemiyatorn 
         Gürkan Sengün
         Ing. Riccardo Mottola <rm@gnu.org>

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */

#include <math.h>
#include <string.h>

#import <AppKit/AppKit.h>
#import <GNUstepBase/GNUstep.h>
#import "Clock.h"
#import "NSColorExtensions.h"

#ifndef PI
#define PI 3.1415926535897932384626434
#endif



@implementation Clock
static NSUserDefaults *defaults;
static NSArray *numArray[2];
static NSImage *cuckoo[20];
static NSArray *dayWeek;

static NSImage *
NewBitmapBackedImage(NSSize size)
{
	NSBitmapImageRep *rep;
	NSImage *image;
	NSInteger pixelsWide = ceil(size.width);
	NSInteger pixelsHigh = ceil(size.height);

	if (pixelsWide < 1)
		pixelsWide = 1;
	if (pixelsHigh < 1)
		pixelsHigh = 1;

	rep = [[NSBitmapImageRep alloc]
		initWithBitmapDataPlanes:NULL
		pixelsWide:pixelsWide
		pixelsHigh:pixelsHigh
		bitsPerSample:8
		samplesPerPixel:4
		hasAlpha:YES
		isPlanar:NO
		colorSpaceName:NSDeviceRGBColorSpace
		bytesPerRow:0
		bitsPerPixel:0];

	if (rep == nil)
		return [[NSImage alloc] initWithSize:size];

	memset([rep bitmapData], 0, [rep bytesPerRow] * pixelsHigh);
	[rep setSize:size];

	image = [[NSImage alloc] initWithSize:size];
	[image addRepresentation:rep];
	RELEASE(rep);

	return image;
}

+ (void) initialize
{
	int i;
	numArray[0] = [NSArray arrayWithObjects:@"XII",@"I",@"II",@"III",@"IV",@"V",@"VI",@"VII",@"VIII",@"IX",@"X",@"XI",nil];
	numArray[1] = [NSArray arrayWithObjects:@"12",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",nil];
	RETAIN(numArray[0]);
	RETAIN(numArray[1]);

	dayWeek = [NSArray arrayWithObjects:@"su",@"mo",@"tu",@"we",@"th",@"fr",@"sa", nil];
	RETAIN(dayWeek);

	defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"1.0 0 0" forKey:@"SecondHandColor"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"1.0 1.0 1.0" forKey:@"FaceColor"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"0.3 0.3 0.3" forKey:@"MarksColor"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"0 0 0" forKey:@"HandsColor"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"0 0 0" forKey:@"FrameColor"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"0.5" forKey:@"FaceTransparency"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"YES" forKey:@"Shadow"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"YES" forKey:@"ShowsAMPM"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"YES" forKey:@"Second"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"0" forKey:@"NumberType"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"NO" forKey:@"EvenIStopTheClockItTellsTheRightTimeTwiceADay"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:0.0] forKey:@"AlarmInterval"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"NO" forKey:@"ShowsArc"]];
	[self setCellClass: [NSActionCell class]];

	for (i = 0; i < 20; i++)
	{
		NSString *imageName;
		imageName = [NSString stringWithFormat:@"cuckoo%d.png", i];
		cuckoo[19 - i] = RETAIN([NSImage imageNamed:imageName]);
	}
}



/** Internally used functions/methods **/

-(void) _frameChanged
{
	NSRect r=[self bounds];
	double max;

	max=r.size.width;
	if (r.size.height<max)
		max=r.size.height;

	radius=max/2-2;

	center.x=r.origin.x+r.size.width/2;
	center.y=r.origin.y+r.size.height/2;

	if (radius>35)
		base_width=radius/35;
	else
		base_width=1.2;

	radius = radius-base_width;

        ASSIGN(font, [NSFont boldSystemFontOfSize:radius/5]);

	DESTROY(_cacheFrame);
	DESTROY(_cacheMark);
}

-(void) _invalidateFrameCache
{
	DESTROY(_cacheFrame);
}

-(void) _invalidateMarkCache
{
	DESTROY(_cacheMark);
}


/** NSView/-gui 'interface' **/

- initWithFrame: (NSRect)frame
{

	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];

	cstate = -1;

	if (!(self=[super initWithFrame: frame])) return nil;

	faceColor = RETAIN([NSColor colorFromStringRepresentation:[defaults objectForKey: @"FaceColor"]]);
	frameColor = RETAIN([NSColor colorFromStringRepresentation:[defaults objectForKey: @"FrameColor"]]);
	marksColor = RETAIN([NSColor colorFromStringRepresentation:[defaults objectForKey: @"MarksColor"]]);
	handsColor = RETAIN([NSColor colorFromStringRepresentation:[defaults objectForKey: @"HandsColor"]]);
	secHandColor = RETAIN([NSColor colorFromStringRepresentation:[defaults objectForKey: @"SecondHandColor"]]);

	arcColor = RETAIN([NSColor colorWithCalibratedRed: 1.0
			green: 0.4
			blue: 0.4
			alpha: 1.0]);
	
	showsAMPM=[defaults boolForKey:@"ShowsAMPM"];
	numberType=[defaults integerForKey:@"NumberType"];
	shadow=[defaults boolForKey:@"Shadow"];
	second=[defaults boolForKey:@"Second"];
/*	easter=[defaults boolForKey:@"EvenIStopTheClockItTellsTheRightTimeTwiceADay"];*/
	faceTrans = [defaults floatForKey:@"FaceTransparency"];

	_timeZone = RETAIN([NSTimeZone systemTimeZone]);
	_tzv = [_timeZone secondsFromGMT];

	handsTime=0;
	showsArc = [defaults boolForKey:@"ShowsArc"];
	alarmInterval = [[defaults objectForKey:@"AlarmInterval"] doubleValue];

	[self _frameChanged];

	return self;
}

-(void) dealloc
{
  RELEASE(faceColor);
  RELEASE(frameColor);
  RELEASE(marksColor);
  RELEASE(handsColor);
  RELEASE(secHandColor);
  RELEASE(arcColor);
  RELEASE(font);
  RELEASE(_date);
  RELEASE(_timeZone);
  RELEASE(_cacheFrame);
  RELEASE(_cacheMark);
  [super dealloc];
}

-(void) setFrame: (NSRect)f
{
	[super setFrame: f];
	[self _frameChanged];
}

-(void) setFaceColor: (NSColor *)c
{
  if (faceColor != c)
    {
      ASSIGN(faceColor, c);
      [self _invalidateFrameCache];
      [self setNeedsDisplay:YES];
    }
}

-(int) numberType
{
	return numberType;
}
-(void) setNumberType: (int)i
{
  numberType = i;
  [self _invalidateMarkCache];
  [self setNeedsDisplay:YES];
}

-(void) setMarksColor: (NSColor *)c
{
  if (marksColor != c)
    {
      ASSIGN(marksColor, c);
      [self _invalidateMarkCache];
      [self setNeedsDisplay:YES];
    }
}
-(NSColor *) marksColor
{
  return marksColor;
}


-(void) setFaceTransparency:(float)v
{
  faceTrans = v;
  [self _invalidateFrameCache];
  [self setNeedsDisplay:YES];
}

-(void) setFrameColor: (NSColor *)c
{
  if (frameColor != c)
    {
      ASSIGN(frameColor, c);
      [self _invalidateFrameCache];
      [self setNeedsDisplay:YES];
    }
}

-(void) setHandsColor: (NSColor *)c
{
  if (handsColor != c)
    {
      ASSIGN(handsColor, c);
      [self _invalidateFrameCache];
      [self setNeedsDisplay:YES];
    }
}
-(void) setSecondHandColor:(NSColor *)c
{
  if (secHandColor != c)
    {
      ASSIGN(secHandColor, c);
      [self _invalidateFrameCache];
      [self setNeedsDisplay:YES];
    }
}
-(void) setShowsAMPM:(BOOL)ampm
{
  showsAMPM = ampm;
  [self _invalidateMarkCache];
  [self setNeedsDisplay:YES];
}

-(void) setShadow:(BOOL)sh
{
  shadow = sh;
  [self _invalidateFrameCache];
  [self _invalidateMarkCache];
  [self setNeedsDisplay:YES];
}

- (BOOL) shadow
{
	return shadow;
}

-(void) setSecond:(BOOL)sh
{
	second = sh;
	[self setNeedsDisplay:YES];
}
- (BOOL) second
{
	return second;
}

-(NSColor *) faceColor
{
	return faceColor;
}
-(NSColor *) frameColor
{
	return frameColor;
}
-(NSColor *) handsColor
{
	return handsColor;
}
-(NSColor *)secondHandColor
{
	return secHandColor;
}

-(BOOL) showsAMPM
{
	return showsAMPM;
}

-(float) faceTransparency
{
	return faceTrans;
}
-(NSFont *)font
{
	return font;
}
-(void) setFont:(NSFont *)newfont
{
  if (font != newfont)
    {
      ASSIGN(font, newfont);
      [self _invalidateMarkCache];
      [self setNeedsDisplay:YES];
    }
}

-(BOOL) isOpaque
{
	return NO;
}

- (void) setAlarmIntervalUsingEvent: (NSEvent*)event;
{
	double a1,a2;
	NSPoint p = [self convertPoint: [event locationInWindow] fromView:nil];
	unsigned int mf = [event modifierFlags];
	id target;
	SEL action;
	p.x -= center.x;
	p.y -= center.y;

	a1 = 450 - fmod(handsTime, 43200.)/120.;
	a2 = atan(p.y/p.x)/(2 * M_PI) * 360;

	if (p.x < 0)
	{
		a2 += 180;
	}
	else if (p.y < 0)
	{
		a2 += 360;
	}

	if (mf & NSShiftKeyMask)
	{
		a1 -= rint(a2/30.) * 30.;
	}
	else if (mf & NSControlKeyMask)
	{
		a1 -= a2 - remainder(a2 - a1, 30.);
	}
	else a1 -= a2;

	a1 = a1 * 120 + handsTime;

	if (fabs(a1 - handsTime) < 20)
		a1 = handsTime + 10;

	[self setAlarmInterval:a1];
	target = [_cell target];
	action = [_cell action];
	[self sendAction: action to: target];
}


- (void) mouseDown:(NSEvent *)event
{
	id target = [_cell target];
	SEL action = [_cell action];
	[self setShowsArc:!showsArc];
	[self sendAction: action to: target];
}

- (void) mouseDragged: (NSEvent *)event
{
	id target = [_cell target];
	SEL action = [_cell action];
	[self setAlarmIntervalUsingEvent:event];
	[self setShowsArc:YES];
	[self sendAction: action to: target];
}

- (void) mouseUp:(NSEvent *)event
{
	id target = [_cell target];
	SEL action = [_cell action];
	[self sendAction: action to: target];

	[defaults setObject:[NSNumber numberWithDouble:alarmInterval] forKey:@"AlarmInterval"];
	[defaults setObject:showsArc?@"YES":@"NO" forKey:@"ShowsArc"];
	[defaults synchronize];
}

/*
- (void)mouseDragged:(NSEvent *)event
{
//	NSLog(@"%@", [self target]);

//	NSLog(@"down %g", atan(p.y/p.x)/(2 * M_PI) * 360);

	[self setNeedsDisplay:YES];

}
*/

-(void) drawRect: (NSRect)r
{
	if (radius<5)
		return;



	/* no cache window, create one */
	if (_cacheFrame == nil)
	{
		_cacheFrame = NewBitmapBackedImage(_bounds.size);

		if ([[_cacheFrame representations] count] > 0)
			[_cacheFrame lockFocusOnRepresentation:[[_cacheFrame representations] objectAtIndex:0]];
		else
			[_cacheFrame lockFocus];
		{
			NSBezierPath *bzp;
		  
			/* draw date */
			if (_date != nil)
			{
				NSMutableAttributedString *str;
				NSSize strSize;
				NSColor* white = [NSColor colorWithDeviceRed:1.
                                                                       green:1.
                                                                        blue:1.
                                                                       alpha:0.7];

				str = [[NSMutableAttributedString alloc]
					initWithString:[NSString stringWithFormat:@"%lu",(unsigned long)[_date dayOfMonth]]];
				[str addAttribute:NSForegroundColorAttributeName
							value:white
							range:NSMakeRange(0,[str length])];
				[str addAttribute:NSFontAttributeName
							value:[NSFont boldSystemFontOfSize:radius/3]
							range:NSMakeRange(0,[str length])];
				strSize = [str size];
				[str drawAtPoint:NSMakePoint(3, 0)];
				[str addAttribute:NSForegroundColorAttributeName
							value:[NSColor blackColor]
							range:NSMakeRange(0,[str length])];
				[str drawAtPoint:NSMakePoint(2, 1)];
				RELEASE(str);

				str = [[NSMutableAttributedString alloc]
					initWithString:[dayWeek objectAtIndex:[_date dayOfWeek]]];
				[str addAttribute:NSForegroundColorAttributeName
							value:white
							range:NSMakeRange(0,[str length])];
				[str addAttribute:NSFontAttributeName
							value:[NSFont boldSystemFontOfSize:radius/3]
							range:NSMakeRange(0,[str length])];
				strSize = [str size];
				[str drawAtPoint:NSMakePoint(2, NSHeight(_bounds) - strSize.height)];
				[str addAttribute:NSForegroundColorAttributeName
							value:[NSColor blackColor]
							range:NSMakeRange(0,[str length])];
				[str drawAtPoint:NSMakePoint(1, NSHeight(_bounds) - strSize.height + 1)];
				RELEASE(str);
			}

			/* draw face */
			bzp = [NSBezierPath bezierPath];
			[[faceColor colorWithAlphaComponent:faceTrans] set];
			[bzp setLineWidth:base_width];
			[bzp moveToPoint:NSMakePoint(center.x+radius, center.y)];
			[bzp appendBezierPathWithArcWithCenter:center radius:radius startAngle:0 endAngle:360];
			[bzp fill];


			/* draw frame and frame shadow */
			bzp = [NSBezierPath bezierPath];
			[frameColor set];
			[bzp setLineWidth:base_width*2];
			[bzp moveToPoint:NSMakePoint(center.x+radius, center.y)];
			[bzp appendBezierPathWithArcWithCenter:center radius:radius startAngle:0 endAngle:360];
			[bzp closePath];
			[bzp stroke];

			if (shadow)
			{
				bzp = [NSBezierPath bezierPath];
				[[[NSColor blackColor] colorWithAlphaComponent:0.4] set];
				[bzp setLineWidth:base_width*1.5];
				[bzp moveToPoint:NSMakePoint(center.x+radius, center.y)];
				[bzp appendBezierPathWithArcWithCenter:NSMakePoint(center.x + 0.5*base_width, center.y-0.5*base_width) radius:radius startAngle:0 endAngle:360];
				[bzp closePath];
				[bzp stroke];

				bzp = [NSBezierPath bezierPath];
				[[[NSColor whiteColor] colorWithAlphaComponent:0.3] set];
				[bzp setLineWidth:base_width*1.0];
				[bzp moveToPoint:NSMakePoint(center.x+radius, center.y)];
				[bzp appendBezierPathWithArcWithCenter:NSMakePoint(center.x - 0.5*base_width, center.y + 0.5*base_width) radius:radius startAngle:0 endAngle:360];
				[bzp closePath];
				[bzp stroke];
				[[NSColor whiteColor] set];
			}

		}
		[_cacheFrame unlockFocus];

	}

	if (_cacheMark == nil)
	{
		_cacheMark = NewBitmapBackedImage(_bounds.size);

		/* print numbers and draw mark */

		if ([[_cacheMark representations] count] > 0)
			[_cacheMark lockFocusOnRepresentation:[[_cacheMark representations] objectAtIndex:0]];
		else
			[_cacheMark lockFocus];
		if (shadow)
		{
			NSColor* black = [NSColor colorWithDeviceRed:0.  green:0. blue:0. alpha:0.2];
			[black set];

			/* print AM PM */
			if (showsAMPM)
			{
				NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
					initWithString:(handsTime - 86400 * floor(handsTime/86400))/3600 >= 12?@"PM":@"AM"];
				NSSize strSize;
				[str addAttribute:NSForegroundColorAttributeName
							value:black
							range:NSMakeRange(0,[str length])];
				[str addAttribute:NSFontAttributeName
							value:font
							range:NSMakeRange(0,[str length])];
				strSize = [str size];
				[str drawAtPoint:NSMakePoint(center.x - strSize.width/2 +1, center.y - radius * 0.71 + strSize.height/2 -1)];
				RELEASE(str);
			}


			{
				int i;
				double a,x,y;

				[black set];

				if (numberType != 0 && radius >= 27)
					for (i=0;i<60;i++)
					{
						if (i%5)
						{
                                                 	NSBezierPath *bzp;
                                                  
							a=i/60.0*2*PI;
							x=sin(a);
							y=cos(a);
                                                        bzp = [NSBezierPath bezierPath];
                                                        [bzp appendBezierPathWithArcWithCenter:NSMakePoint(center.x+x*radius*0.90 +1,center.y+y*radius*0.90 -1) radius:0.5*base_width startAngle:0 endAngle:360];
                                                        [bzp fill];
						}
					}

				for (i=0;i<12;i++)
				{
					a=i/12.0*2*PI;
					x=sin(a);
					y=cos(a);

					if (numberType != 0)
					{
                                                NSBezierPath *bzp;
                                                
                                                bzp = [NSBezierPath bezierPath];
                                                [bzp moveToPoint:NSMakePoint(center.x+x*radius*0.95 +1,center.y+y*radius*0.95 -1)];
                                                [bzp lineToPoint:NSMakePoint(center.x+x*radius*0.83 +1,center.y+y*radius*0.83 -1)];
                                                [bzp stroke];
					}

					if (numberType == 1)
					{
						NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
							initWithString:[numArray[1] objectAtIndex:i]];
						NSSize size;
						[str addAttribute:NSForegroundColorAttributeName
									value:black
									range:NSMakeRange(0,[str length])];
						[str addAttribute:NSFontAttributeName
									value:font
									range:NSMakeRange(0,[str length])];
						size = [str size];
						[str drawAtPoint:NSMakePoint(center.x+x*radius*0.7 - size.width/2 +1, center.y+y*radius*0.7 - size.height/2 -1)];
						RELEASE(str);

					}
					else if (numberType == 0)
					{
						NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
							initWithString:[numArray[0] objectAtIndex:i]];
						NSSize size;
						[str addAttribute:NSForegroundColorAttributeName
									value:black
									range:NSMakeRange(0,[str length])];
						[str addAttribute:NSFontAttributeName
									value:font
									range:NSMakeRange(0,[str length])];
						size = [str size];
						[str drawAtPoint:NSMakePoint(center.x+x*radius*0.80 - size.width/2.5 +1, center.y+y*radius*0.80 - size.height/2 -1)];
						RELEASE(str);
					}

				}
			}
		} /* done shadow */

		{

			/* print AM PM */
			if (showsAMPM)
			{
				NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
					initWithString:(handsTime - 86400 * floor(handsTime/86400))/3600 >= 12?@"PM":@"AM"];
				NSSize strSize;
				[str addAttribute:NSForegroundColorAttributeName
							value:marksColor
							range:NSMakeRange(0,[str length])];
				[str addAttribute:NSFontAttributeName
							value:font
							range:NSMakeRange(0,[str length])];
				strSize = [str size];
				[str drawAtPoint:NSMakePoint(center.x - strSize.width/2, center.y - radius * 0.71 + strSize.height/2)];
				RELEASE(str);
			}


			{
				int i;
				double a,x,y;

				[marksColor set];

				if (numberType != 0 && radius >= 27)
					for (i=0;i<60;i++)
					{
						if (i%5)
						{
                                                        NSBezierPath *bzp;
                                                        
							a=i/60.0*2*PI;
							x=sin(a);
							y=cos(a);
                                                        bzp = [NSBezierPath bezierPath];
                                                        [bzp appendBezierPathWithArcWithCenter:NSMakePoint(center.x+x*radius*0.90,center.y+y*radius*0.90) radius:0.5*base_width startAngle:0 endAngle:360];
                                                        [bzp fill];
						}
					}

				for (i=0;i<12;i++)
				{
					NSColor* tmpC;

					a=i/12.0*2*PI;
					x=sin(a);
					y=cos(a);

					if ((_date != nil) && [_date monthOfYear]%12 == i)
					{
						tmpC = secHandColor;
					}
					else tmpC = marksColor;

					[tmpC set];

					if (numberType != 0)
					{
                                                NSBezierPath *bzp;
                                                
                                                bzp = [NSBezierPath bezierPath];
                                                [bzp moveToPoint:NSMakePoint(center.x+x*radius*0.95,center.y+y*radius*0.95)];
                                                [bzp lineToPoint:NSMakePoint(center.x+x*radius*0.83,center.y+y*radius*0.83)];
                                                [bzp stroke];
					}


					if (numberType == 1)
					{
						NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
							initWithString:[numArray[1] objectAtIndex:i]];
						NSSize size;
						[str addAttribute:NSForegroundColorAttributeName
									value:tmpC
									range:NSMakeRange(0,[str length])];
						[str addAttribute:NSFontAttributeName
									value:font
									range:NSMakeRange(0,[str length])];
						size = [str size];
						[str drawAtPoint:NSMakePoint(center.x+x*radius*0.7 - size.width/2, center.y+y*radius*0.7 - size.height/2)];
						RELEASE(str);

					}
					else if (numberType == 0)
					{
						NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
							initWithString:[numArray[0] objectAtIndex:i]];
						NSSize size;
						[str addAttribute:NSForegroundColorAttributeName
									value:tmpC
									range:NSMakeRange(0,[str length])];
						[str addAttribute:NSFontAttributeName
									value:font
									range:NSMakeRange(0,[str length])];
						size = [str size];
						[str drawAtPoint:NSMakePoint(center.x+x*radius*0.80 - size.width/2.5, center.y+y*radius*0.80 - size.height/2)];
						RELEASE(str);
					}

				}
			}

		}
		[_cacheMark unlockFocus];
	}

	[_cacheFrame drawInRect:[self bounds]
		fromRect:NSMakeRect(0, 0, [_cacheFrame size].width, [_cacheFrame size].height)
		operation:NSCompositeSourceOver
		fraction:1.0];


/*
	if ((handsTime - 86400 * floor(handsTime/86400))/3600 > 12);
	{
	}
	*/

	/* draw arc */
	if (showsArc)
	{
		double a1,a2;
		double r1;
                NSBezierPath *abzp;

		a1 = 90 - (handsTime - 43200 * floor(handsTime/43200))/43200 * 360;
		a2 = 90 - (alarmInterval - 43200 * floor(alarmInterval/43200))/43200 * 360;
		r1=radius * 0.8;

		abzp = [NSBezierPath bezierPath];

		if (a2 < a1)
		{
			a2 += 360;
		}

		[abzp setLineWidth:radius*0.4* (0.1 + (a2-a1)/400)];

		[[NSColor colorWithDeviceHue: 0.5 - (a2 - a1)/720
			saturation:0.1 + (a2 - a1)/400
			brightness:0.8
			alpha:faceTrans + 0.7] set];

		[abzp appendBezierPathWithArcWithCenter:center radius:r1 startAngle:a2 endAngle:a1];
		[abzp stroke];
	}

	[_cacheMark drawInRect:[self bounds]
		fromRect:NSMakeRect(0, 0, [_cacheMark size].width, [_cacheMark size].height)
		operation:NSCompositeSourceOver
		fraction:1.0];


	{
		double hours,minutes,seconds;
		double a,x,y;
		NSBezierPath *hbzp;

		/* Shadows */

		if (shadow)
		{
                        NSBezierPath *sbzp;
                        
			[[[NSColor blackColor] colorWithAlphaComponent: 0.3] set];

			if (second)
			{
				seconds=handsTime-60*floor(handsTime/60);
				seconds/=60;
				a=seconds*2*PI;
				x=sin(a);
				y=cos(a);

                                sbzp = [NSBezierPath bezierPath];
                                [sbzp setLineWidth: base_width*0.8];
                                [sbzp moveToPoint:NSMakePoint(center.x+x*radius*0.89 +base_width*1.0,center.y+y*radius*0.89 -1.5*base_width)];

				seconds=handsTime-60*floor(handsTime/60)+30;
				seconds/=60;
				a=seconds*2*PI;
				x=sin(a);
				y=cos(a);

                                [sbzp lineToPoint:NSMakePoint(center.x+x*radius*0.30 +base_width*1.0,center.y+y*radius*0.30 -1.5*base_width)];
                                [sbzp stroke];
                                
                                sbzp = [NSBezierPath bezierPath];
                                [sbzp setLineWidth:base_width];
                                [sbzp appendBezierPathWithArcWithCenter:NSMakePoint(center.x +base_width*1.0, center.y -1.5*base_width) radius:1.5*base_width startAngle:0 endAngle:360];
                                [sbzp fill];
			}
			else
			{
                                sbzp = [NSBezierPath bezierPath];
                                [sbzp setLineWidth:base_width];
                                [sbzp appendBezierPathWithArcWithCenter:NSMakePoint(center.x +base_width*1.0, center.y -1.5*base_width) radius:1.5*base_width startAngle:0 endAngle:360];
                                [sbzp fill];
			}

			minutes=handsTime-3600*floor(handsTime/3600);
			minutes/=3600;
			a=minutes*2*PI;
			x=sin(a);
			y=cos(a);

                        sbzp = [NSBezierPath bezierPath];               
                        [sbzp setLineWidth:base_width];
                        [sbzp moveToPoint:NSMakePoint(center.x +base_width*1.0, center.y -1.5*base_width)];
                        [sbzp lineToPoint:NSMakePoint(center.x+x*radius*0.89 +base_width*1.0,center.y+y*radius*0.89 -1.5*base_width)];
                        [sbzp stroke];


			hours=handsTime-43200*floor(handsTime/43200);
			hours/=3600*12;
			if (hours>=1) hours-=1;
			a=hours*2*PI;
			x=sin(a);
			y=cos(a);

                        sbzp = [NSBezierPath bezierPath];
                        [sbzp setLineWidth:base_width*1.5];
                        [sbzp moveToPoint:NSMakePoint(center.x +base_width*1.0, center.y -1.5*base_width)];
                        [sbzp lineToPoint:NSMakePoint(center.x+x*radius*0.5 +base_width*1.0,center.y+y*radius*0.5 -1.5*base_width)];
                        [sbzp setLineCapStyle:NSRoundLineCapStyle];
                        [sbzp stroke];

			/** done Shadow **/
		}

		[handsColor set];
		minutes=handsTime-3600*floor(handsTime/3600);
		minutes/=3600;
		a=minutes*2*PI;
		x=sin(a);
		y=cos(a);
                
		hbzp = [NSBezierPath bezierPath];
		[hbzp setLineWidth:base_width];
		[hbzp moveToPoint:center];
		[hbzp lineToPoint:NSMakePoint(center.x+x*radius*0.89,center.y+y*radius*0.89)];
		[hbzp stroke];


		hours=handsTime-43200*floor(handsTime/43200);
		hours/=3600*12;
		if (hours>=1) hours-=1;
		a=hours*2*PI;
		x=sin(a);
		y=cos(a);

		hbzp = [NSBezierPath bezierPath];
		[hbzp setLineWidth:base_width*1.5];
		[hbzp moveToPoint:center];
		[hbzp lineToPoint:NSMakePoint(center.x+x*radius*0.5,center.y+y*radius*0.5)];
		[hbzp setLineCapStyle:NSRoundLineCapStyle];
		[hbzp stroke];

		if (second)
		{
			NSBezierPath *shbzp;

			shbzp = [NSBezierPath bezierPath];
                        [shbzp setLineWidth:base_width];
			[secHandColor set];
			seconds=handsTime-60*floor(handsTime/60);
			seconds/=60;
			a=seconds*2*PI;
			x=sin(a);
			y=cos(a);

			[shbzp setLineWidth:base_width*0.8];
			[shbzp moveToPoint:NSMakePoint(center.x+x*radius*0.89,center.y+y*radius*0.89)];

			seconds=handsTime-60*floor(handsTime/60)+30;
			seconds/=60;
			a=seconds*2*PI;
			x=sin(a);
			y=cos(a);

			
			[shbzp lineToPoint:NSMakePoint(center.x+x*radius*0.30,center.y+y*radius*0.30)];
			[shbzp stroke];
			
			shbzp = [NSBezierPath bezierPath];
                        [shbzp setLineWidth:base_width];
			[shbzp appendBezierPathWithArcWithCenter:center radius:1.5*base_width startAngle:0 endAngle:360];
			[shbzp fill];
		}
		else
		{
			NSBezierPath *shbzp;
                        
                        shbzp = [NSBezierPath bezierPath];
                        [shbzp setLineWidth:base_width];
			[shbzp appendBezierPathWithArcWithCenter:center radius:1.5*base_width startAngle:0 endAngle:360];
			[shbzp fill];
		}

	}

	if (cstate != -1)
	{
		[cuckoo[cstate] compositeToPoint:NSMakePoint(-1,12)
							   operation:NSCompositeSourceOver];
	}
}

- (void) setCuckooState:(int)st
{
	if (st != cstate)
	{
		cstate = st;
		[self setNeedsDisplay:YES];
	}
}

-(NSImage *) imageRepresentation
{
	NSBitmapImageRep *rep;
	NSGraphicsContext *context;
	NSGraphicsContext *oldContext;
	NSImage *image;
	NSSize size;
	NSInteger pixelsWide;
	NSInteger pixelsHigh;

	size = [self bounds].size;
	pixelsWide = ceil(size.width);
	pixelsHigh = ceil(size.height);
	if (pixelsWide < 1)
		pixelsWide = 1;
	if (pixelsHigh < 1)
		pixelsHigh = 1;

	rep = [[NSBitmapImageRep alloc]
		initWithBitmapDataPlanes:NULL
		pixelsWide:pixelsWide
		pixelsHigh:pixelsHigh
		bitsPerSample:8
		samplesPerPixel:4
		hasAlpha:YES
		isPlanar:NO
		colorSpaceName:NSDeviceRGBColorSpace
		bytesPerRow:0
		bitsPerPixel:0];

	if (rep == nil)
		return nil;

	memset([rep bitmapData], 0, [rep bytesPerRow] * pixelsHigh);
	[rep setSize:size];

	context = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
	oldContext = [NSGraphicsContext currentContext];
	[NSGraphicsContext setCurrentContext:context];
	[self drawRect:[self bounds]];
	[context flushGraphics];
	[NSGraphicsContext setCurrentContext:oldContext];

	image = AUTORELEASE([[NSImage alloc] initWithSize:size]);
	[image addRepresentation:rep];
	RELEASE(rep);

	return image;
}

-(NSData *) TIFFRepresentation
{
	NSBitmapImageRep *rep;
	NSGraphicsContext *context;
	NSGraphicsContext *oldContext;
	NSData *data;
	NSSize size;
	NSInteger pixelsWide;
	NSInteger pixelsHigh;

	size = [self bounds].size;
	pixelsWide = ceil(size.width);
	pixelsHigh = ceil(size.height);
	if (pixelsWide < 1)
		pixelsWide = 1;
	if (pixelsHigh < 1)
		pixelsHigh = 1;

	rep = [[NSBitmapImageRep alloc]
		initWithBitmapDataPlanes:NULL
		pixelsWide:pixelsWide
		pixelsHigh:pixelsHigh
		bitsPerSample:8
		samplesPerPixel:4
		hasAlpha:YES
		isPlanar:NO
		colorSpaceName:NSDeviceRGBColorSpace
		bytesPerRow:0
		bitsPerPixel:0];

	if (rep == nil)
		return nil;

	memset([rep bitmapData], 0, [rep bytesPerRow] * pixelsHigh);
	[rep setSize:size];

	context = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
	oldContext = [NSGraphicsContext currentContext];
	[NSGraphicsContext setCurrentContext:context];
	[self drawRect:[self bounds]];
	[context flushGraphics];
	[NSGraphicsContext setCurrentContext:oldContext];

	data = [rep representationUsingType:NSTIFFFileType properties:nil];
	RETAIN(data);
	RELEASE(rep);

	return AUTORELEASE(data);
}


/** Public interface **/

-(BOOL) showsArc
{
	return showsArc;
}


-(void) setShowsArc: (BOOL)s
{
	s=!!s;
	if (s==showsArc)
		return;
	showsArc=s;
	[self setNeedsDisplay: YES];
}

- (void) setTimeZone:(NSTimeZone *)tz
{
  if (_timeZone != tz)
    {
      ASSIGN(_timeZone, tz);
    }
	_tzv = [tz secondsFromGMT];
	[self setNeedsDisplay: YES];
}

- (NSTimeZone *) timeZone
{
	return _timeZone;
}

- (void) setDate:(NSCalendarDate *)date
{
  if (_date != date)
    {
      ASSIGN(_date, date);
    } 

	handsTime = [date timeIntervalSinceReferenceDate] + _tzv;
	[self _invalidateFrameCache];
	[self _invalidateMarkCache];

	/*
	if (easter)
	{
		[self translateOriginToPoint:center];
		[self rotateByAngle:6 * (time-handsTime)];
		[self translateOriginToPoint:NSMakePoint(-center.x,-center.y)];
	}
	*/

	[self setNeedsDisplay: YES];
}

- (NSCalendarDate *) date
{
	return _date;
}

-(double) handsTime
{
	return handsTime;
}

-(void) setHandsTime: (double)time
{
	double oldHandsTime = handsTime;

	handsTime=time;

	if ((int)floor(fmod(oldHandsTime, 86400.) / 43200.)
	    != (int)floor(fmod(handsTime, 86400.) / 43200.))
	{
		[self _invalidateMarkCache];
	}

	if (handsTime > alarmInterval)
	{
		id target = [_cell target];
		SEL action = [_cell action];
		if (showsArc)
		{
			[self sendAction: action to: target];
		}
		[self setAlarmInterval: alarmInterval];
	}


	[self setNeedsDisplay: YES];
}

-(void) setHandsTimeNoAlarm: (double)time
{
	double oldHandsTime = handsTime;

	handsTime=time;

	if ((int)floor(fmod(oldHandsTime, 86400.) / 43200.)
	    != (int)floor(fmod(handsTime, 86400.) / 43200.))
	{
		[self _invalidateMarkCache];
	}

	[self setAlarmInterval: alarmInterval];
}


-(double) alarmInterval
{
	return alarmInterval;
}

-(void) setAlarmInterval: (double)time
{
	alarmInterval = floor(handsTime / 43200) * 43200 + fmod(time, 43200.);

	if (alarmInterval < handsTime) alarmInterval += 43200;

	if (showsArc)
	{
		[self setNeedsDisplay: YES];
	}
}


@end


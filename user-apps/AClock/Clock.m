/*
 Project: AClock
 Clock.m

 Copyright (C) 2003-2014 GNUstep Application Project

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
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <math.h>

#import <AppKit/AppKit.h>
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

+ (void) initialize
{
	int i;
	numArray[0] = [NSArray arrayWithObjects:@"XII",@"I",@"II",@"III",@"IV",@"V",@"VI",@"VII",@"VIII",@"IX",@"X",@"XI",nil];
	numArray[1] = [NSArray arrayWithObjects:@"12",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",nil];
	[numArray[0] retain];
	[numArray[1] retain];

	dayWeek = [NSArray arrayWithObjects:@"su",@"mo",@"tu",@"we",@"th",@"fr",@"sa", nil];
	[dayWeek retain];

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
		cuckoo[19 - i] = [[NSImage imageNamed:[NSString stringWithFormat:@"cuckoo%d.png",i]] retain];
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

        [font release];
	font = [[NSFont boldSystemFontOfSize:radius/5] retain];

	[_cacheFrame release];
	[_cacheMark release];
}


/** NSView/-gui 'interface' **/

- initWithFrame: (NSRect)frame
{

	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];

	cstate = -1;

	if (!(self=[super initWithFrame: frame])) return nil;

	faceColor = [[NSColor colorFromStringRepresentation:[defaults objectForKey: @"FaceColor"]] retain];
	frameColor =[[NSColor colorFromStringRepresentation:[defaults objectForKey: @"FrameColor"]] retain];
	marksColor = [[NSColor colorFromStringRepresentation:[defaults objectForKey: @"MarksColor"]] retain];
	handsColor =[[NSColor colorFromStringRepresentation:[defaults objectForKey: @"HandsColor"]] retain];
	secHandColor =[[NSColor colorFromStringRepresentation:[defaults objectForKey: @"SecondHandColor"]] retain];

	arcColor =
		[[NSColor colorWithCalibratedRed: 1.0
			green: 0.4
			blue: 0.4
			alpha: 1.0] retain];
	
	showsAMPM=[defaults boolForKey:@"ShowsAMPM"];
	numberType=[defaults integerForKey:@"NumberType"];
	shadow=[defaults boolForKey:@"Shadow"];
	second=[defaults boolForKey:@"Second"];
/*	easter=[defaults boolForKey:@"EvenIStopTheClockItTellsTheRightTimeTwiceADay"];*/
	faceTrans = [defaults floatForKey:@"FaceTransparency"];

	_timeZone = [[NSTimeZone systemTimeZone] retain];
	_tzv = [_timeZone secondsFromGMT];

	handsTime=0;
	showsArc = [defaults boolForKey:@"ShowsArc"];
	alarmInterval = [[defaults objectForKey:@"AlarmInterval"] doubleValue];

	[self _frameChanged];

	return self;
}

-(void) dealloc
{
  [faceColor release];
  [frameColor release];
  [marksColor release];
  [handsColor release];
  [arcColor release];
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
      [faceColor release];
      faceColor = [c retain];
      [_cacheFrame release];
      _cacheFrame = nil;
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
  [_cacheMark release];
  _cacheMark = nil;
  [self setNeedsDisplay:YES];
}

-(void) setMarksColor: (NSColor *)c
{
  if (marksColor != c)
    {
      [marksColor release];
      marksColor = [c retain];
      [_cacheMark release];
      _cacheMark = nil;
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
  [_cacheFrame release];
  _cacheFrame = nil;
  [self setNeedsDisplay:YES];
}

-(void) setFrameColor: (NSColor *)c
{
  if (frameColor != c)
    {
      [frameColor release];
      frameColor = [c retain];
      [_cacheFrame release];
      _cacheFrame = nil;
      [self setNeedsDisplay:YES];
    }
}

-(void) setHandsColor: (NSColor *)c
{
  if (handsColor != c)
    {
      [handsColor release];
      handsColor = [c retain];
      [_cacheFrame release];
      _cacheFrame = nil;
      [self setNeedsDisplay:YES];
    }
}
-(void) setSecondHandColor:(NSColor *)c
{
  if (secHandColor != c)
    {
      [secHandColor release];
      secHandColor = [c retain];
      [_cacheFrame release];
      _cacheFrame = nil;
      [self setNeedsDisplay:YES];
    }
}
-(void) setShowsAMPM:(BOOL)ampm
{
  showsAMPM = ampm;
  [_cacheMark release];
  _cacheMark = nil;
  [self setNeedsDisplay:YES];
}
-(void) setShadow:(BOOL)sh
{
  shadow = sh;
  [_cacheFrame release];
  _cacheFrame = nil;
  [_cacheMark release];
  _cacheMark = nil;
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
      [font release];
      font = [newfont retain];
      [_cacheMark release];
      _cacheMark = nil;
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
	NSGraphicsContext *ctxt=GSCurrentContext();
	/*
	BOOL smoothSeconds = [defaults boolForKey: @"SmoothSeconds"];
	*/

	if (radius<5)
		return;

	DPSsetlinewidth(ctxt,base_width);


	/* no cache window, create one */
	if (_cacheFrame == nil)
	{
		_cacheFrame = [[NSImage alloc] initWithSize:_bounds.size];

		[_cacheFrame lockFocus];
		ctxt=GSCurrentContext();
		{

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
			}

			/* draw face */
			[faceColor set];
			DPSgsave(ctxt);
			DPSsetalpha(ctxt, faceTrans);
			DPSmoveto(ctxt,center.x+radius,center.y);
			DPSarc(ctxt,center.x,center.y,radius,0,360);
			DPSfill(ctxt);
			DPSgrestore(ctxt);

			/* draw frame and frame shadow */
			[frameColor set];
			DPSsetlinewidth(ctxt, base_width*2);
			DPSmoveto(ctxt,center.x+radius,center.y);
			DPSarc(ctxt,center.x,center.y,radius,0,360);
			DPSclosepath(ctxt);
			DPSstroke(ctxt);

			if (shadow)
			{
				DPSgsave(ctxt);
				[[NSColor blackColor] set];
				DPSsetlinewidth(ctxt, base_width*1.5);
				DPSsetalpha(ctxt,0.4);
				DPSmoveto(ctxt,center.x+radius,center.y);
				DPSarc(ctxt,center.x + 0.5*base_width,center.y-0.5*base_width,radius,0,360);
				DPSclosepath(ctxt);
				DPSstroke(ctxt);
				DPSgrestore(ctxt);

				[[NSColor whiteColor] set];
				DPSgsave(ctxt);
				DPSsetlinewidth(ctxt, base_width*1.0);
				DPSsetalpha(ctxt,0.3);
				DPSmoveto(ctxt,center.x+radius,center.y);
				DPSarc(ctxt,center.x - 0.5*base_width,center.y + 0.5*base_width,radius,0,360);
				DPSclosepath(ctxt);
				DPSstroke(ctxt);
				DPSgrestore(ctxt);
			}

		}
		[_cacheFrame unlockFocus];
		ctxt=GSCurrentContext();

	}

	if (_cacheMark == nil)
	{
		_cacheMark = [[NSImage alloc] initWithSize:_bounds.size];

		/* print numbers and draw mark */

		[_cacheMark lockFocus];
		ctxt=GSCurrentContext();
		if (shadow)
		{
			NSColor* black = [NSColor colorWithDeviceRed:0.  green:0. blue:0. alpha:0.2];
			DPSgsave(ctxt);
			DPStranslate(ctxt, 1.0, -1.0);
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
				[str drawAtPoint:NSMakePoint(center.x - strSize.width/2, center.y - radius * 0.8 + strSize.height/2)];
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
							a=i/60.0*2*PI;
							x=sin(a);
							y=cos(a);
							DPSarc(ctxt,center.x+x*radius*0.90,center.y+y*radius*0.90,0.5*base_width,0,360);
							DPSfill(ctxt);
						}
					}

				for (i=0;i<12;i++)
				{
					a=i/12.0*2*PI;
					x=sin(a);
					y=cos(a);

					if (numberType != 0)
					{
						DPSmoveto(ctxt,center.x+x*radius*0.95,center.y+y*radius*0.95);
						DPSlineto(ctxt,center.x+x*radius*0.83,center.y+y*radius*0.83);
						DPSstroke(ctxt);
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
						[str drawAtPoint:NSMakePoint(center.x+x*radius*0.7 - size.width/2, center.y+y*radius*0.7 - size.height/2)];
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
						[str drawAtPoint:NSMakePoint(center.x+x*radius*0.80 - size.width/2.5, center.y+y*radius*0.80 - size.height/2)];
						RELEASE(str);
					}

				}
			}

			DPSgrestore(ctxt);
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
				[str drawAtPoint:NSMakePoint(center.x - strSize.width/2, center.y - radius * 0.8 + strSize.height/2)];
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
							a=i/60.0*2*PI;
							x=sin(a);
							y=cos(a);
							DPSarc(ctxt,center.x+x*radius*0.90,center.y+y*radius*0.90,0.5*base_width,0,360);
							DPSfill(ctxt);
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
						DPSmoveto(ctxt,center.x+x*radius*0.95,center.y+y*radius*0.95);
						DPSlineto(ctxt,center.x+x*radius*0.83,center.y+y*radius*0.83);
						DPSstroke(ctxt);
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
		ctxt=GSCurrentContext();
	}

	[_cacheFrame compositeToPoint:NSZeroPoint
		operation:NSCompositeSourceAtop];


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

		a1 = 90 - (handsTime - 43200 * floor(handsTime/43200))/43200 * 360;
		a2 = 90 - (alarmInterval - 43200 * floor(alarmInterval/43200))/43200 * 360;
		r1=radius * 0.8;

		DPSnewpath(ctxt);

		if (a2 < a1)
		{
			a2 += 360;
		}

		DPSsetlinewidth(ctxt,radius*0.4* (0.1 + (a2-a1)/400));

		[[NSColor colorWithDeviceHue: 0.5 - (a2 - a1)/720
			saturation:0.1 + (a2 - a1)/400
			brightness:0.8
			alpha:faceTrans + 0.7] set];

		DPSarc(ctxt,center.x,center.y,r1,a2,a1);
		DPSstroke(ctxt);
	}

	[_cacheMark compositeToPoint:NSZeroPoint
		operation:NSCompositeSourceAtop];

	DPSsetlinewidth(ctxt,base_width);



	{
		double hours,minutes,seconds;
		double a,x,y;

		/* Shadows */

		if (shadow)
		{
			DPSgsave(ctxt);
			DPStranslate(ctxt, base_width*1.0, -1.5*base_width);
			[[NSColor blackColor] set];
			DPSsetalpha(ctxt, 0.3);

			if (second)
			{
				seconds=handsTime-60*floor(handsTime/60);
				/*
				if (smoothSeconds == NO)
					seconds = floor(seconds);
					*/
				seconds/=60;
				a=seconds*2*PI;
				x=sin(a);
				y=cos(a);

				DPSsetlinewidth(ctxt,base_width*0.8);
				DPSmoveto(ctxt,center.x+x*radius*0.89,center.y+y*radius*0.89);

				seconds=handsTime-60*floor(handsTime/60)+30;
				/*
				if (smoothSeconds == NO)
					seconds = floor(seconds);
					*/
				seconds/=60;
				a=seconds*2*PI;
				x=sin(a);
				y=cos(a);

				DPSlineto(ctxt,center.x+x*radius*0.30,center.y+y*radius*0.30);
				DPSstroke(ctxt);

				DPSarc(ctxt,center.x,center.y,1.5*base_width,0,360);
				DPSfill(ctxt);
			}
			else
			{
				DPSarc(ctxt,center.x,center.y,1.5*base_width,0,360);
				DPSfill(ctxt);
			}

			minutes=handsTime-3600*floor(handsTime/3600);
			minutes/=3600;
			a=minutes*2*PI;
			x=sin(a);
			y=cos(a);

			DPSsetlinewidth(ctxt,base_width);
			DPSmoveto(ctxt,center.x,center.y);
			DPSlineto(ctxt,center.x+x*radius*0.89,center.y+y*radius*0.89);
			DPSstroke(ctxt);

			hours=handsTime-43200*floor(handsTime/43200);
			hours/=3600*12;
			if (hours>=1) hours-=1;
			a=hours*2*PI;
			x=sin(a);
			y=cos(a);

			DPSsetlinewidth(ctxt,base_width*1.5);
			DPSsetlinecap(ctxt,1);
			DPSmoveto(ctxt,center.x,center.y);
			DPSlineto(ctxt,center.x+x*radius*0.5,center.y+y*radius*0.5);
			DPSstroke(ctxt);
			DPSsetlinecap(ctxt,0);

			DPSgrestore(ctxt);

			/** done Shadow **/
		}

		[handsColor set];
		minutes=handsTime-3600*floor(handsTime/3600);
		minutes/=3600;
		a=minutes*2*PI;
		x=sin(a);
		y=cos(a);

		DPSsetlinewidth(ctxt,base_width);
		DPSmoveto(ctxt,center.x,center.y);
		DPSlineto(ctxt,center.x+x*radius*0.89,center.y+y*radius*0.89);
		DPSstroke(ctxt);

		hours=handsTime-43200*floor(handsTime/43200);
		hours/=3600*12;
		if (hours>=1) hours-=1;
		a=hours*2*PI;
		x=sin(a);
		y=cos(a);


		DPSsetlinewidth(ctxt,base_width*1.5);
		DPSsetlinecap(ctxt,1);
		DPSmoveto(ctxt,center.x,center.y);
		DPSlineto(ctxt,center.x+x*radius*0.5,center.y+y*radius*0.5);
		DPSstroke(ctxt);
		DPSsetlinecap(ctxt,0);

		if (second)
		{
			[secHandColor set];
			seconds=handsTime-60*floor(handsTime/60);
			/*
			if (smoothSeconds == NO)
				seconds = floor(seconds);
				*/
			seconds/=60;
			a=seconds*2*PI;
			x=sin(a);
			y=cos(a);

			DPSsetlinewidth(ctxt,base_width*0.8);
			DPSmoveto(ctxt,center.x+x*radius*0.89,center.y+y*radius*0.89);

			seconds=handsTime-60*floor(handsTime/60)+30;
			/*
			if (smoothSeconds == NO)
				seconds = floor(seconds);
				*/
			seconds/=60;
			a=seconds*2*PI;
			x=sin(a);
			y=cos(a);

			DPSlineto(ctxt,center.x+x*radius*0.30,center.y+y*radius*0.30);
			DPSstroke(ctxt);

			DPSarc(ctxt,center.x,center.y,1.5*base_width,0,360);
			DPSfill(ctxt);
		}
		else
		{
			DPSarc(ctxt,center.x,center.y,1.5*base_width,0,360);
			DPSfill(ctxt);
		}

	}

	if (cstate != -1)
	{
		[cuckoo[cstate] compositeToPoint:NSMakePoint(-1,12)
							   operation:NSCompositeSourceAtop];
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
      [_timeZone release];
	   _timeZone = [tz retain];
    }
	_tzv = [tz secondsFromGMT];
	[self setNeedsDisplay: YES];
}

- (NSTimeZone *) timeZone
{
	return _timeZone;
}

- (void) setDate:(NSDate *)date
{
  if (_date != date)
    {
      [_date release];
      _date = [date retain];
    } 

	handsTime = [date timeIntervalSinceReferenceDate] + _tzv;
	[_cacheFrame release];
	[_cacheMark release];

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

- (NSDate *) date
{
	return _date;
}

-(double) handsTime
{
	return handsTime;
}

-(void) setHandsTime: (double)time
{
	handsTime=time;

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
	handsTime=time;

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


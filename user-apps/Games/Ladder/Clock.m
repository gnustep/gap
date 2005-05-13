/*
copyright 2003 Alexander Malmberg <alexander@malmberg.org>
*/

#include "Clock.h"
#include <AppKit/AppKit.h>

#include <math.h>
#ifndef PI
#define PI 3.1415926535897932384626434
#endif

#include <AppKit/NSColor.h>
#include <AppKit/DPSOperators.h>
#include <AppKit/GSDisplayServer.h>


@implementation Clock
static NSUserDefaults *defaults;
static NSArray *numArray[2];

+ (void) initialize
{
	numArray[0] = [NSArray arrayWithObjects:@"XII",@"I",@"II",@"III",@"IV",@"V",@"VI",@"VII",@"VIII",@"IX",@"X",@"XI",nil];
	numArray[1] = [NSArray arrayWithObjects:@"12",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",nil];
	RETAIN(numArray[0]);
	RETAIN(numArray[1]);

	defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"1.0 0 0" forKey:@"SecondHandColor"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"1.0 1.0 1.0" forKey:@"FaceColor"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"0.3 0.3 0.3" forKey:@"MarksColor"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"0 0 0" forKey:@"HandsColor"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"0 0 0" forKey:@"FrameColor"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"0.5" forKey:@"FaceTransparency"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"YES" forKey:@"Shadow"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"YES" forKey:@"ShowAMPM"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"YES" forKey:@"Second"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"0" forKey:@"NumberType"]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"NO" forKey:@"EvenIStopTheClockItTellsTheRightTimeTwiceADay"]];
	[self setCellClass: [NSActionCell class]];
}



/** Internally used functions/methods **/

static double wrap_time(double time)
{
	int i;
	i=floor(time/1440);
	return time-i*1440;
}


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


/** NSView/-gui 'interface' **/

-(void) setDayColor: (NSColor *)c
{
	ASSIGN(dayColor, c);
}

- initWithFrame: (NSRect)frame
{

	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];

	if (!(self=[super initWithFrame: frame])) return nil;

	ASSIGN(faceColor,[NSColor colorFromString:[defaults objectForKey: @"FaceColor"]]);
	ASSIGN(frameColor,[NSColor colorFromString:[defaults objectForKey: @"FrameColor"]]);
	ASSIGN(marksColor,[NSColor colorFromString:[defaults objectForKey: @"MarksColor"]]);
	ASSIGN(handsColor,[NSColor colorFromString:[defaults objectForKey: @"HandsColor"]]);
	ASSIGN(secHandColor,[NSColor colorFromString:[defaults objectForKey: @"SecondHandColor"]]);

	ASSIGN(arcColor,
		[NSColor colorWithCalibratedRed: 1.0
			green: 0.4
			blue: 0.4
			alpha: 1.0]);
	
	showAMPM=[defaults boolForKey:@"ShowAMPM"];
	numberType=[defaults integerForKey:@"NumberType"];
	shadow=[defaults boolForKey:@"Shadow"];
	second=[defaults boolForKey:@"Second"];
	faceTrans = [defaults floatForKey:@"FaceTransparency"];

	ASSIGN(_timeZone,[NSTimeZone systemTimeZone]);
	_tzv = [_timeZone secondsFromGMT];

	handsTime=0;
	arcStartTime=arcEndTime=0;
	showsArc=NO;

	[self _frameChanged];

	return self;
}

-(void) dealloc
{
	DESTROY(faceColor);
	DESTROY(frameColor);
	DESTROY(marksColor);
	DESTROY(handsColor);
	DESTROY(arcColor);
	[super dealloc];
}

-(void) setFrame: (NSRect)f
{
	[super setFrame: f];
	[self _frameChanged];
}

-(void) setFaceColor: (NSColor *)c
{
	ASSIGN(faceColor, c);
	DESTROY(_cacheFrame);
}

-(int) numberType
{
	return numberType;
}
-(void) setNumberType: (int)i
{
	numberType = i;
	DESTROY(_cacheMark);
}

-(void) setMarksColor: (NSColor *)c
{
	ASSIGN(marksColor, c);
	DESTROY(_cacheMark);
}
-(NSColor *) marksColor
{
	return marksColor;
}


-(void) setFaceTransparency:(float)v
{
	faceTrans = v;
	DESTROY(_cacheFrame);
}

-(void) setFrameColor: (NSColor *)c
{
	ASSIGN(frameColor, c);
	DESTROY(_cacheFrame);
}

-(void) setHandsColor: (NSColor *)c
{
	ASSIGN(handsColor, c);
}
-(void) setSecondHandColor:(NSColor *)c
{
	ASSIGN(secHandColor, c);
}
-(void) setShowAMPM:(BOOL)ampm
{
	showAMPM = ampm;
}
-(void) setShadow:(BOOL)sh
{
	shadow = sh;
	DESTROY(_cacheFrame);
	DESTROY(_cacheMark);
}
- (BOOL) shadow
{
	return shadow;
}
-(void) setSecond:(BOOL)sh
{
	second = sh;
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

-(BOOL) showAMPM
{
	return showAMPM;
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
	ASSIGN(font,newfont);
	DESTROY(_cacheMark);
}

- (void) setArcEndTimeToPoint:(NSPoint)p
{
	double a1,a2;
	p.x -= center.x;
	p.y -= center.y;

	a1 = 450 - (arcStartTime - 43200 * floor(arcStartTime/43200))/43200 * 360;
	a2 = atan(p.y/p.x)/(2 * M_PI) * 360;

	if (p.x < 0)
	{
		a2 += 180;
	}
	else if (p.y < 0)
	{
		a2 += 360;
	}


	[self setArcEndTime:(a1 - a2) *  120 + arcStartTime];
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
	[self setArcEndTimeToPoint:[self convertPoint:[event locationInWindow] fromView:nil]];
	[self setShowsArc:YES];
	[self sendAction: action to: target];
}

- (void) mouseUp:(NSEvent *)event
{
	id target = [_cell target];
	SEL action = [_cell action];
	[self sendAction: action to: target];
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
	id defaults = [NSUserDefaults standardUserDefaults];
	/*
	BOOL smoothSeconds = [defaults boolForKey: @"SmoothSeconds"];
	*/

	if (radius<5)
		return;

	DPSsetlinewidth(ctxt,base_width);

	/* alarm */
	if (arcStartTime > arcEndTime)
	{
		id target = [_cell target];
		SEL action = [_cell action];
		if (showsArc)
		{
			[self sendAction: action to: target];
		}
		[self setArcEndTime: arcEndTime];
	}


	/* no cache window, create one */
	if (_cacheFrame == nil)
	{
		_cacheFrame = [[NSImage alloc] initWithSize:_bounds.size];

		[_cacheFrame lockFocus];

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

		[_cacheFrame unlockFocus];

		NSLog(@"create frame cache");
	}

	if (_cacheMark == nil)
	{
		_cacheMark = [[NSImage alloc] initWithSize:_bounds.size];

		/* print numbers and draw mark */

		[_cacheMark lockFocus];

		/* print AM PM */
		if (showAMPM)
		{
			NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
				initWithString:(handsTime - 86400 * floor(handsTime/86400))/3600 >= 12?@"PM":@"AM"];
			[str addAttribute:NSForegroundColorAttributeName
				value:marksColor
				range:NSMakeRange(0,[str length])];
			[str addAttribute:NSFontAttributeName
				value:font
				range:NSMakeRange(0,[str length])];
			NSSize strSize = [str size];
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
					[str addAttribute:NSForegroundColorAttributeName
						value:marksColor
						range:NSMakeRange(0,[str length])];
					[str addAttribute:NSFontAttributeName
						value:font
						range:NSMakeRange(0,[str length])];
					NSSize size = [str size];
					[str drawAtPoint:NSMakePoint(center.x+x*radius*0.7 - size.width/2, center.y+y*radius*0.7 - size.height/2)];
					RELEASE(str);

					if (dayColor && i == (int)[_date monthOfYear])
					{
						DPSgsave(ctxt);
						DPSsetalpha(ctxt,0.7);
						DPSarc(ctxt,center.x+x*radius*0.7,center.y+y*radius*0.7,3*base_width,0,360);
						DPSstroke(ctxt);
						DPSgrestore(ctxt);
					}

				}
				else if (numberType == 0)
				{
					NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
						initWithString:[numArray[0] objectAtIndex:i]];
					[str addAttribute:NSForegroundColorAttributeName
						value:marksColor
						range:NSMakeRange(0,[str length])];
					[str addAttribute:NSFontAttributeName
						value:font
						range:NSMakeRange(0,[str length])];
					NSSize size = [str size];
					[str drawAtPoint:NSMakePoint(center.x+x*radius*0.80 - size.width/2.5, center.y+y*radius*0.80 - size.height/2)];
					RELEASE(str);
				}

			}
		}

		[_cacheMark unlockFocus];
		NSLog(@"create mark cache");
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
		double a1,a2,x,y;
		double r1;

//		[arcColor set];

/*
		{
			hours=handsTime-43200*floor(handsTime/43200);
			hours/=3600*12;
			if (hours>=1) hours-=1;
			a=hours*2*PI;
			x=sin(a);
			y=cos(a);
		}
		*/

		a1 = 90 - (arcStartTime - 43200 * floor(arcStartTime/43200))/43200 * 360;
		a2 = 90 - (arcEndTime - 43200 * floor(arcEndTime/43200))/43200 * 360;

		//a2=90-arcEndTime/60/12*360;

/*
		x=sin(a2) * radius * 0.4;
		y=cos(a2) * radius * 0.4;
		*/

		r1=radius * 0.8;

		/*
		x=cos(a2/360*2*PI)*r1;
		y=sin(a2/360*2*PI)*r1;
		*/

		DPSnewpath(ctxt);
/*
		DPSmoveto(ctxt,center.x,center.y+r1);
		*/
//		DPSlineto(ctxt,center.x,center.y);

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

/*
			{
				int x2,y2;
				float f;
				f=0.06;
				DPSmoveto(ctxt,center.x,center.y);
				x2=sin(a+PI/2)*radius*f+center.x+x/2*radius*0.5;
				y2=cos(a+PI/2)*radius*f+center.y+y/2*radius*0.5;
				DPScurveto(ctxt,
						x2,y2,x2,y2,
						center.x+x*radius*0.5,center.y+y*radius*0.5);
				x2=-sin(a+PI/2)*radius*f+center.x+x/2*radius*0.5;
				y2=-cos(a+PI/2)*radius*f+center.y+y/2*radius*0.5;
				DPScurveto(ctxt,
						x2,y2,x2,y2,
						center.x,center.y);
				DPSfill(ctxt);

			}
			*/

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

/*
		{
			int x2,y2;
			float f;
			f=0.06;
			DPSmoveto(ctxt,center.x,center.y);
			x2=sin(a+PI/2)*radius*f+center.x+x/2*radius*0.5;
			y2=cos(a+PI/2)*radius*f+center.y+y/2*radius*0.5;
			DPScurveto(ctxt,
					x2,y2,x2,y2,
					center.x+x*radius*0.5,center.y+y*radius*0.5);
			x2=-sin(a+PI/2)*radius*f+center.x+x/2*radius*0.5;
			y2=-cos(a+PI/2)*radius*f+center.y+y/2*radius*0.5;
			DPScurveto(ctxt,
					x2,y2,x2,y2,
					center.x,center.y);
			DPSfill(ctxt);
			
		}
		*/
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


	if (dayColor)
	{
		NSMutableAttributedString *str;
		NSSize strSize;

		[dayColor set];
		DPSarc(ctxt,center.x,center.y,radius/3,0,360);
		DPSsetalpha(ctxt, 0.5);
		DPSfill(ctxt);


		/*
		DPSgsave(ctxt);
		DPSnewpath(ctxt);
		DPSarc(ctxt,center.x,center.y,radius/4,0,360);
		DPSclosepath(ctxt);
		*/
		str = [[NSMutableAttributedString alloc]
			initWithString:[NSString stringWithFormat:@"%d",[_date dayOfMonth]]];
		[str addAttribute:NSForegroundColorAttributeName
					value:faceColor
					range:NSMakeRange(0,[str length])];
		[str addAttribute:NSFontAttributeName
					value:[NSFont boldSystemFontOfSize:radius/2.5]
					range:NSMakeRange(0,[str length])];
		strSize = [str size];
		DPSsetalpha(ctxt,0.1);
		[str drawAtPoint:NSMakePoint(center.x - strSize.width/2, center.y - strSize.height/2)];
		RELEASE(str);
		/*
		DPSgrestore(ctxt);
		*/

		/*
		NSCalendarDate *date;

		date = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[_date timeIntervalSinceReferenceDate] + _tzv];
		*/

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
	ASSIGN(_timeZone,tz);
	_tzv = [tz secondsFromGMT];
	[self setNeedsDisplay: YES];
}

- (NSTimeZone *) timeZone
{
	return _timeZone;
}

- (void) setDate:(NSDate *)date
{
	ASSIGN(_date, date);
	handsTime = [date timeIntervalSinceReferenceDate] + _tzv;

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

	if (
			((time - 86400 * floor(time/86400))/3600 >= 12 ? YES : NO) !=
			((handsTime - 86400 * floor(handsTime/86400))/3600 >= 12 ? YES : NO)
	   )
	{
		DESTROY(_cacheMark);
	}

	handsTime=time;

	[self setNeedsDisplay:YES];

}

- (BOOL) isOpaque
{
	  return NO;
}

-(double) arcStartTime
{
	return arcStartTime;
}

-(double) arcEndTime
{
	return arcEndTime;
}

-(void) setArcStartTime: (double)time
{
	if (time==arcStartTime)
		return;
	arcStartTime=time;

	if (showsArc)
		[self setNeedsDisplay: YES];
}

-(void) setArcEndTime: (double)time
{
	arcEndTime=time;

	/* FIXME oh please learn math :P */
	while (arcEndTime > arcStartTime)
	{
		arcEndTime -= 3600 * 12;
	}
	while (arcEndTime <= arcStartTime)
	{
		arcEndTime += 3600 * 12;
	}
	
	if (showsArc)
		[self setNeedsDisplay: YES];
}


@end


/*
copyright 2003 Alexander Malmberg <alexander@malmberg.org>
*/

#ifndef Clock_h
#define Clock_h

#include <AppKit/NSControl.h>

@class NSColor;

@interface Clock : NSControl
{
	int cstate;
	NSColor *faceColor,*frameColor,*marksColor,*handsColor,*arcColor,*secHandColor,*dayColor;

	NSImage *_cacheFrame;
	NSImage *_cacheMark;

	float faceTrans;
	BOOL showsArc;
	BOOL showsAMPM;
	BOOL shadow;
	BOOL second;
	BOOL showDate;

	NSFont *font;

/*	BOOL easter;*/

	NSCalendarDate *_date;

	NSTimeZone *_timeZone;
	NSTimeInterval _tzv;

	int numberType;

	/* Calculated values used when drawing. */
	double handsTime,alarmInterval;
	double radius;
	double base_width;
	NSPoint center;
	BOOL inView;
}

/*
TODO?
-(NSColor *) arcColor;
-(void) setArcColor: (NSColor *)c;*/

- (void) setTimeZone:(NSTimeZone *)tz;
- (NSTimeZone *) timeZone;
- (void) setDate:(NSDate *)date;
- (NSDate *) date;

/* move a clock to CSClockView and put these theming method into subclass */

-(NSColor *) marksColor;
-(NSColor *) faceColor;
-(NSColor *) frameColor;
-(NSColor *) handsColor;
-(NSColor *) secondHandColor;
-(BOOL) showsAMPM;
-(BOOL) shadow;
-(float) faceTransparency;
-(NSFont *)font;
-(void) setFont:(NSFont *)newfont;

-(int) numberType;
-(void) setNumberType: (int)i;
-(void) setMarksColor: (NSColor *)c;
-(void) setFaceColor: (NSColor *)c;
-(void) setFaceTransparency:(float)v;
-(void) setFrameColor: (NSColor *)c;
-(void) setHandsColor: (NSColor *)c;
-(void) setSecondHandColor: (NSColor *)c;
-(void) setShowsAMPM:(BOOL)ampm;
-(void) setShadow:(BOOL)sh;
-(void) setSecond:(BOOL)sh;
-(BOOL) second;

-(BOOL) showsArc;
-(void) setShowsArc: (BOOL)s;

-(double) handsTime;
-(void) setHandsTime: (double)time;

-(double) alarmInterval;
-(void) setAlarmInterval: (double)time;
-(void) setHandsTimeNoAlarm: (double)time;

@end

#endif


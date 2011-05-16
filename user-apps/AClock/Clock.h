/*
 Project: AClock
 Clock.h

 Copyright (C) 2003-2011 GNUstep Application Project

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

#import <Foundation/Foundation.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSControl.h>

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
-(void) setCuckooState:(int)st;

@end


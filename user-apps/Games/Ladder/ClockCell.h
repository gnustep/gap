#ifndef ClockCell
#define CLOCKCELL_H

#include <AppKit/NSActionCell.h>

/*
@interface ClockStyle : NSObject
{
	NSColor *faceColor,*frameColor,*marksColor,*handsColor,*arcColor,*secHandColor,*dayColor;

	NSImage *_cacheFrame;
	NSImage *_cacheMark;
	NSSize _clockSize;
}
@end
*/

typedef struct _ClockNumberType
{
	RomanNumberType;
	ArabicNumberType;
	NoNumberType;
} ClockNumberType;

@interface ClockArc : NSObject
{
	@public
	NSCalendarDate *arcStart;
	NSTimeInterval arcInterval;
	NSColor * color;
}
@end

@interface ClockCell : NSActionCell <NSCoding>
{
	NSColor *faceColor,*frameColor,*marksColor,*handsColor,*arcColor,*secHandColor,*dayColor;

	NSImage *_cacheFrame;
	NSImage *_cacheMark;

	float faceTrans;
	BOOL showsArc;
	BOOL showAMPM;
	BOOL shadow;
	BOOL second;

	NSFont *font;

	NSCalendarDate *_date;
	NSArray *_arcList;

	BOOL alarming;
	int numberType;

	/* Calculated values used when drawing. */
	NSTimeInterval handsTime,arcStartTime,arcEndTime;
	double radius;
	double base_width;
	NSPoint center;

}

/* time */
- (void) setCalendarDate:(NSCalendarDate *)calendarDate;
- (NSCalendarDate *) calendarDate;
- (void) 


/* styles 
 * move to color dict

-(NSColor *) marksColor;
-(NSColor *) faceColor;
-(NSColor *) frameColor;
-(NSColor *) handsColor;
-(NSColor *) secondHandColor;
-(BOOL) showAMPM;
-(BOOL) shadow;
-(float) faceTransparency;
-(NSFont *)font;
-(void) setFont:(NSFont *)newfont;

-(ClockNumberType) numberType;
-(void) setNumberType: (ClockNumberType)numberType;

-(void) setMarksColor: (NSColor *)c;
-(void) setFaceColor: (NSColor *)c;
-(void) setFaceTransparency:(float)v;
-(void) setFrameColor: (NSColor *)c;
-(void) setHandsColor: (NSColor *)c;
-(void) setSecondHandColor: (NSColor *)c;
-(void) setShowAMPM:(BOOL)ampm;
-(void) setShadow:(BOOL)sh;
-(void) setSecond:(BOOL)sh;
-(void) setDayColor: (NSColor *)c;
-(BOOL) second;

*/



-(BOOL) showsArc;
-(void) setShowsArc: (BOOL)s;

@end

#endif /* CLOCKCELL_H */

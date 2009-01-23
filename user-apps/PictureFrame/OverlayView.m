/* OverlayView

  Written: Adam Fedor <fedor@qwest.net>
  Date: May 2007
*/
#import <AppKit/AppKit.h>
#import "OverlayView.h"
#import "PhotoController.h"
#import "PreferencesController.h"
#import "GNUstep.h"
#include <math.h>

#define dfltmgr [NSUserDefaults standardUserDefaults]

/* Define locations and sizes in terms of percent of the size of the frame */
/* Return a decent font size */
static int
p2f(double perc, NSRect frame)
{
  int fsize = perc * NSHeight(frame);
  /* Make it even */
  fsize = 2*ceil((double)fsize/2);
  if (fsize < 12)
    fsize = 12;
  return fsize;
}
static int
p2h (double perc, NSRect frame)
{
  return perc * NSHeight(frame);
}
static int
p2w (double perc, NSRect frame)
{
  return perc * NSWidth(frame);
}

@implementation NSBezierPath(RoundedRectangle)

+ (NSBezierPath *) bezierPathWithRoundedRect: (NSRect) aRect cornerRadius: (double) radius
{
  NSBezierPath* path = [self bezierPath];
  radius = MIN(radius, 0.5f * MIN(NSWidth(aRect), NSHeight(aRect)));
  NSRect rect = NSInsetRect(aRect, radius, radius);
  [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect)) radius:radius startAngle:180.0 endAngle:270.0];
  [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMinY(rect)) radius:radius startAngle:270.0 endAngle:360.0];
  [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius:radius startAngle:  0.0 endAngle: 90.0];
  [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) radius:radius startAngle: 90.0 endAngle:180.0];
  [path closePath];
  return path;
}

@end

@implementation OverlayView

- (id) initWithFrame: (NSRect)frame 
{
  self = [super initWithFrame:frame];
  timer = [NSTimer scheduledTimerWithTimeInterval: 60
                                           target: self
                                         selector: @selector(updateOverlay:)
                                         userInfo: nil
                                          repeats: YES];
  RETAIN(timer);  
  [self updateOverlay: self];
  return self;
}

- (void) dealloc
{
  [timer invalidate];
  RELEASE(timer);
  RELEASE(weatherView);
  TEST_RELEASE(clock);
  [super dealloc];
}

- (NSView *) weatherViewWithFrame: (NSRect)rect
{
  if (weatherView == nil)
    {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource: @"SimpleWeather" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath: bundlePath]; 
    if (bundle)
      {
      weatherView = [(NSView *)[[bundle principalClass] alloc] initWithFrame: rect];
      [[PreferencesController sharedPreferences] addPreferenceController: 
	  [weatherView preferenceController]];
      }
    
    }
  return weatherView;
}

- (void) updateOverlay: sender
{
  int info;

  info = [dfltmgr integerForKey: DOverlayInfo];
  if ((info & INFO_WEATHER) && [self superview])
    {
      NSRect srect = [self frame];
      srect = NSMakeRect(NSHeight(srect), 0, NSWidth(srect)-2*NSHeight(srect), 
			 NSHeight(srect));
      [self weatherViewWithFrame: srect];
      if ([weatherView superview] == nil)
	{
	  NSLog(@"Adding weatherView");
	  [self addSubview: weatherView];
	}
    }
  else if (weatherView && [weatherView superview])
    {
      NSLog(@"Removing weatherView");
      [weatherView removeFromSuperview];
    }

  [[self superview] setNeedsDisplay: YES];
}

- (NSString *) photoInfo
{
  int i;
  NSView *view;
  NSArray *views;
  NSDictionary *photoDir;
  NSString *str, *album, *comment;
  NSCalendarDate *date;
  NSTimeInterval created;
  view = [self superview];
  if (view == nil)
    return nil;
  
  views = [view subviews];
  for (i = 0; i < [views count]; i++)
    {
      view = [views objectAtIndex: i];
      if (view != self && [view respondsToSelector: @selector(currentPhotoInfo)])
	break;
      view = nil;
    }
  
  photoDir = [[PhotoController sharedPhotoController] currentPhotoInfo];
  if ([photoDir objectForKey: @"DateAsTimerInterval"])
    {
      created = [[photoDir objectForKey: @"DateAsTimerInterval"] doubleValue];
      date = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate: created];
      [date setCalendarFormat: @"%b,%d %Y"];
    }
  else
    date = nil;
  album = [[PhotoController sharedPhotoController] currentAlbum];
  if (album == nil)
    album = @"";
  comment = [photoDir objectForKey: @"Comment"];
  if (comment == nil)
    comment = @"";
  if (date)
    str = [NSString stringWithFormat: _(@"Photo: %@\nDate: %@\nAlbum: %@\n%@"),
	   [[photoDir objectForKey: @"ImagePath"] lastPathComponent],
		  date, album, comment];
  else
    str = [NSString stringWithFormat: _(@"Photo: %@\nDate: \nAlbum: %@\n%@"),
	   [[photoDir objectForKey: @"ImagePath"] lastPathComponent],
		  album, comment];
  return str;
}

- (void) drawDigitalClock: (NSRect)rect
{
  NSString *string;
  NSCalendarDate *date;
  NSDictionary *fdict;
  NSFont *font;
  NSString *fname = [dfltmgr objectForKey: DFontName];
  if (fname == nil)
    fname = @"Helvetica";
  font = [NSFont fontWithName: fname size: p2f(0.4, rect)];

  date = [NSCalendarDate calendarDate];
  [date setCalendarFormat: @"%I:%M\n  %p"];
  string = [NSString stringWithString: [date description]];
  fdict = [NSDictionary dictionaryWithObjectsAndKeys: font, 
			NSFontAttributeName, 
		        [NSColor colorWithCalibratedWhite: 1.0 alpha: 1.0], 
			NSForegroundColorAttributeName,
			nil];
  [string drawInRect: rect withAttributes: fdict];
}

- (void) drawSmallDigitalClock: (NSRect)rect
{
  NSString *string;
  NSCalendarDate *date;
  NSDictionary *fdict;
  NSFont *font;
  NSString *fname = [dfltmgr objectForKey: DFontName];
  if (fname == nil)
    fname = @"Helvetica";
  font = [NSFont fontWithName: fname size: p2f(0.9, rect)];
  
  date = [NSCalendarDate calendarDate];
  [date setCalendarFormat: @"%I:%M%p"];
  string = [NSString stringWithString: [date description]];
  fdict = [NSDictionary dictionaryWithObjectsAndKeys: font, 
    NSFontAttributeName, 
    [NSColor colorWithCalibratedWhite: 1.0 alpha: 1.0], 
    NSForegroundColorAttributeName,
    nil];
  [string drawInRect: rect withAttributes: fdict];
}

- (void) drawDigitalDate: (NSRect)rect
{
  NSString *string;
  NSCalendarDate *date;
  NSDictionary *fdict;
  NSFont *font;
  NSString *fname = [dfltmgr objectForKey: DFontName];
  if (fname == nil)
    fname = @"Helvetica";
  font = [NSFont fontWithName: fname size: p2f(0.9, rect)];

  date = [NSCalendarDate calendarDate];
  [date setCalendarFormat: @"%b %d"];
  string = [NSString stringWithString: [date description]];
  fdict = [NSDictionary dictionaryWithObjectsAndKeys: font, 
			NSFontAttributeName, 
		        [NSColor colorWithCalibratedWhite: 1.0 alpha: 1.0], 
			NSForegroundColorAttributeName,
			nil];
  [string drawInRect: rect withAttributes: fdict];
}

- (void) drawRect: (NSRect)rect 
{
  int info;
  NSBezierPath *bpath;
  NSString *string;
  NSRect srect;
  NSDictionary *fdict;
  NSFont *font;
  NSString *fname;
  int clock_type;

  info = [dfltmgr integerForKey: DOverlayInfo];
  if (info == 0)
    return;

  rect = [self frame];
  if ((info & INFO_PHOTO) == 0 && (info & INFO_WEATHER) == 0)
    {
      rect.size.width = NSHeight(rect);      
    }
  else if ((info & INFO_PHOTO) == 0 )
    {
      rect.size.width = NSWidth(rect) - 1.5*NSHeight(rect);      
    }
  else if ((info & INFO_CLK1) == 0 && (info & INFO_CLK2) == 0 
	   && (info & INFO_WEATHER) == 0)
    {
      rect.origin.x = NSWidth(rect) - 1.5*NSHeight(rect);
      rect.size.width = 1.5*NSHeight(rect);
    }
  
  /* Draw the border */
  rect = NSInsetRect(rect, 2, 2);
  bpath = [NSBezierPath bezierPathWithRoundedRect: rect 
				     cornerRadius: p2h(0.1, rect)];
  [[NSColor colorWithCalibratedWhite: 0.3 alpha: 0.5] set];
  [bpath fill];
  [[NSColor colorWithCalibratedWhite: 1.0 alpha: 0.8] set];
  [bpath setLineWidth: 4];
  [bpath stroke];
  rect = NSInsetRect(rect, 2, 2);
  
  /* Draw the clock */
  clock_type = (info & MAX_CLK);
  srect = rect;
  if (clock_type == 1)
    {
      srect.size.width = 2*NSHeight(srect);
      srect.origin.y += NSHeight(srect)*0.2;
      srect.size.height *= 0.8;
      [self drawDigitalClock: srect];
    }
  else if (clock_type >= 2)
    {
      srect.size.width = NSHeight(srect);
      srect.origin.y += NSHeight(srect)*0.2;
      srect.size.height *= 0.8;
      if (clock == nil)
	{
	  clock = [[ClockView alloc] initWithFrame: srect];
	}
      [clock animateOneFrame];
    }
  srect = rect;
  if (clock_type == 1 || clock_type == 2)
    {
      srect = NSMakeRect(NSHeight(srect)*0.2, NSMinY(srect), 
			 NSHeight(srect), NSHeight(srect)*0.2);
      [self drawDigitalDate: srect];
    }
  else if (clock_type == 3)
    {
      srect = NSMakeRect(NSHeight(srect)*0.2, NSMinY(srect), 
			 NSHeight(srect), NSHeight(srect)*0.2);
      [self drawSmallDigitalClock: srect];
    }

  /* Weather will get drawn by WeatherView */

  /* Draw photograph info */
  if ((info & INFO_PHOTO))
    {
      fname = [dfltmgr objectForKey: DFontName];
      if (fname == nil)
	fname = @"Helvetica";
      font = [NSFont fontWithName: fname size: p2f(0.1, rect)];
      srect = rect;
      /* If we have the full frame, draw into the left side */
      if (NSMinX(rect) < 20)
	srect = NSMakeRect(NSWidth(srect)*0.80+NSMinX(srect), 
			   NSMinY(srect), NSWidth(srect)*0.20, 
			   NSHeight(srect));
      fdict = [NSDictionary dictionaryWithObjectsAndKeys: font, 
			    NSFontAttributeName, 
		           [NSColor colorWithCalibratedWhite: 1.0 alpha: 1.0], 
			    NSForegroundColorAttributeName,
			    nil];
      string = [self photoInfo];
      if (string)
	[string drawInRect: srect withAttributes: fdict];
    }
}

@end

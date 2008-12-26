/* PictureFrameController

  Written: Adam Fedor <fedor@qwest.net>
  Date: May 2007
*/
#import <AppKit/AppKit.h>
#import <Foundation/NSString.h>
#import <Foundation/NSUserDefaults.h>
#ifndef GNUSTEP
#import "DBOverlayWindow.h"
#endif
#import "PictureFrameController.h"
#import "PreferencesController.h"
#import "PhotoController.h"
#import "GNUstep.h"
#include <signal.h>
#include <math.h>

#define DEFAULT_SPEED 60
#define dfltmgr [NSUserDefaults standardUserDefaults]

NSString *DIsRunningPID = @"IsRunningPID";
NSString *DUserStop = @"UserStop";

void
handle_user_stop(int sig)
{
  NSDictionary *dict;
  NSEnumerator *denum;
  NSString *str;
  NSUserDefaults *mgr = dfltmgr;
  id obj;

  fprintf(stdout, "*** Caught signal SIGUSR1\n");
  NS_DURING
  str = [NSHomeDirectory() stringByAppendingPathComponent: @"frame.plist"];
  str = [NSString stringWithContentsOfFile: str];
  if (str == nil)
    return;
  dict = [str propertyListFromStringsFileFormat];
  if (dict == nil)
    return;
  denum = [dict keyEnumerator];
  fprintf(stdout, "    Updating defaults...\n");
  while ((str = [denum nextObject]))
    {
      obj = [dict objectForKey: str];
      [mgr setObject: obj forKey: str];
    }
  NS_HANDLER
    NSLog(@"EXCEPTION while updating defaults: %@",localException);
  NS_ENDHANDLER
  fprintf(stdout, "    Done.\n");
}

void
handle_user_term(int sig)
{
  fprintf(stdout, "*** Caught signal SIGTERM\n");
  fprintf(stdout, "       Quiting application\n");
  [NSApp terminate: nil];
}

@interface UserInfoView : NSView
{
  NSString *displayString;
}
- (void) setDisplayString: (NSString *)string;
@end

@implementation UserInfoView

- (void) setDisplayString: (NSString *)string
{
  ASSIGN(displayString, string);
}

- (void) drawRect: (NSRect)rect 
{
  NSString *fname;
  NSDictionary *fdict;
  NSFont *font;
  NSBezierPath *bpath;
  
  bpath = [NSBezierPath bezierPathWithRoundedRect: rect cornerRadius: 0.10 * NSHeight(rect)];
  [[NSColor colorWithCalibratedWhite: 0.3 alpha: 0.5] set];
  [bpath fill];

  float fsize = NSHeight(rect) * 0.6;
  fname = [dfltmgr objectForKey: DFontName];
  if (fname == nil)
    fname = @"Helvetica";
  font = [NSFont fontWithName: fname size: fsize];

  fdict = [NSDictionary dictionaryWithObjectsAndKeys: font, 
			NSFontAttributeName, 
		        [NSColor colorWithCalibratedWhite: 1.0 alpha: 1.0], 
			NSForegroundColorAttributeName,
			nil];
  [displayString drawInRect: rect withAttributes: fdict];
}
@end


@implementation PictureFrameController

- (IBAction)showPreferences:(id)sender
{
  [[PreferencesController sharedPreferences] showPreferences: self];
}

- (void) dealloc
{
  [dfltmgr setInteger: 0 forKey: DIsRunningPID];
  [self stopTimer];
#ifndef GNUSTEP
  [pWindow removeChildWindow: overlayWindow];
  RELEASE(overlayWindow);
#endif
  RELEASE(pWindow);
  RELEASE(currentFrame);
  [super dealloc];
}

- (void) startRunning
{
  int process = [[NSProcessInfo processInfo] processIdentifier];
  [dfltmgr setInteger: process forKey: DIsRunningPID];
  [dfltmgr setBool: NO forKey: DUserStop];
  [self createPictureWindow];
  [self startTimer];
}

- (void) stopRunning
{
  [self stopTimer];
  [dfltmgr setInteger: 0 forKey: DIsRunningPID];
}

- (void) applicationDidFinishLaunching: (NSNotification *)notification
{
  signal(SIGUSR1, handle_user_stop);
  signal(SIGTERM, handle_user_term);
  monitor = YES;
  heatIndex = 0;
  [self startRunning];
}

- (void) applicationWillTerminate: (NSNotification *)notification
{
  [self stopRunning];
}

- (void) createPictureWindow
{
  int full_screen, mask;
  NSRect frame;
  int store = NSBackingStoreRetained;

  if (pWindow)
    {
      [currentFrame release];
      currentFrame = nil;
      [pWindow orderOut: self];
      [pWindow release];
      pWindow = nil;
    }

  full_screen = [dfltmgr integerForKey: DFullScreen];
  if (full_screen)
    {
      frame = [[NSScreen mainScreen] frame];
      mask = NSBorderlessWindowMask;
    }
  else
    {
      frame = NSMakeRect(100, 100, 800, 600);
      mask = NSTitledWindowMask;
    }
  
  if (currentFrame == nil)
    {
      NSRect rect = frame;
      rect.origin = NSZeroPoint;
      currentFrame = [[PhotoController alloc] initWithFrame: rect];
    }

  // create the window...
  store = NSBackingStoreBuffered;
  pWindow = [[PictureWindow alloc] initWithContentRect: frame
				     styleMask: mask
				     backing: store
				     defer: NO];

  // set some attributes...
  [pWindow setAutodisplay: YES];
  [pWindow makeFirstResponder: pWindow];
  [pWindow setExcludedFromWindowsMenu: YES];
  [pWindow setBackgroundColor: [NSColor blackColor]];
  [pWindow setOneShot:YES];
  [pWindow setDelegate: self];

  // set up the backing store...
  if (store == NSBackingStoreBuffered)
    {
      [pWindow useOptimizedDrawing: YES];
      [pWindow setDynamicDepthLimit: YES];
    }

  if (full_screen)
    [pWindow setLevel: NSScreenSaverWindowLevel];

  // load the view from the currently active module, if
  // there is one...
  if (currentFrame)
    {
      [[pWindow contentView] addSubview: [currentFrame displayView]];
    }
  
  /* Make sure defaults are set */
  [PreferencesController sharedPreferences];
  
  if (full_screen)
    [NSCursor hide];
  else
    [NSCursor unhide];
  [pWindow makeKeyAndOrderFront: self];
  [self runAnimation: nil];
}

- (void) showUserInfoView: sender
{
  if (userInfoView == nil)
    {
      NSPoint mid;
      NSRect frect = [pWindow frame];
      mid.x = NSWidth(frect)/2;
      mid.y = NSHeight(frect)/2;
      frect = NSMakeRect(mid.x*0.7, mid.y*0.9, mid.x*0.5, mid.y*0.2);
      userInfoView = [[UserInfoView alloc] initWithFrame: frect];
    }
  if ([userInfoView superview] == nil)
    {
      [[pWindow contentView] addSubview: userInfoView];
      if (userTimer == nil)
	{
	  userTimer = [NSTimer scheduledTimerWithTimeInterval: 5
		       target: self
		       selector: @selector(removeUserInfoView:)
		       userInfo: nil
		       repeats: NO];
	  RETAIN(userTimer);
	}
    }
}

- (void) removeUserInfoView: sender
{
  BOOL powerOff;
  [userInfoView removeFromSuperview];
  DESTROY(userTimer);
  powerOff = [dfltmgr boolForKey: DUserStop];
  if (powerOff)
    {
      system("/usr/local/bin/poweroff");
      [NSApp terminate: self];
    }
}

- (void) monitorComputer
{
  NSTask *pipeTask;
  NSPipe *newPipe;
  NSFileHandle *readHandle;
  NSData *inData;
 
  if (monitor == NO)
    return;

  pipeTask = [[NSTask alloc] init];
  newPipe = [NSPipe pipe];
  readHandle = [newPipe fileHandleForReading];
  
  NS_DURING
    [pipeTask setStandardOutput:newPipe];
    [pipeTask setLaunchPath: @"acpi"];
    [pipeTask setArguments: [NSArray arrayWithObjects: @"-t", nil]];
    [pipeTask launch];
    [pipeTask waitUntilExit];
  
    if ((inData = [readHandle availableData]) && [inData length]) 
      {
	double temperature;
	NSString *tstr;
	NSString *str = [[NSString alloc] initWithData: inData
					      encoding: NSASCIIStringEncoding];
	NSScanner *scn = [NSScanner scannerWithString: str];
	tstr = [NSString string];
	[scn scanUpToString: @"Thermal" intoString: NULL];
	[scn scanUpToString: @"," intoString: NULL];
	[scn scanString: @"," intoString: NULL];
	temperature = 0;
	if ([scn scanDouble: &temperature])
	  {
	    if (temperature > 55)
	      NSLog(@"Temperature: %g", temperature);
	    if (temperature > 59)
	      heatIndex++;
	    else if (temperature < 50)
	      heatIndex--;
	    if (heatIndex < 0)
	      heatIndex = 0;
	    if (heatIndex > 10)
	      {
		/* Turn Machine off... */
		[self showUserInfoView: self];
		[(UserInfoView *)userInfoView 
		  setDisplayString: @"Too Hot! Turning Off"];
		[dfltmgr setBool: YES forKey: DUserStop];
	      }
	  }
      }
  NS_HANDLER
    /* Failed, possible as this command doesn't exist. Don't try again */
    NSLog(@"NSTask failed to monitor via acpi");
    monitor = NO;
  NS_ENDHANDLER
  [pipeTask release];
}

- (void) keyDown: (NSEvent*)theEvent
{
  NSString *characters = [theEvent characters];
  unichar  character = 0;
  unichar  offchar, infochar, backchar, downchar, upchar, togchar;
  NSUserDefaults *mgr = dfltmgr;

  if ([characters length] > 0)
    {
      character = [characters characterAtIndex: 0];
    }
  offchar = [[mgr objectForKey: DOffKey] characterAtIndex: 0];
  infochar = [[mgr objectForKey: DInfoKey] characterAtIndex: 0];
  backchar = [[mgr objectForKey: DBackKey] characterAtIndex: 0];
  downchar = [[mgr objectForKey: DSpeedDownKey] characterAtIndex: 0];
  upchar = [[mgr objectForKey: DSpeedUpKey] characterAtIndex: 0];
  togchar = [[mgr objectForKey: DToggleScreenKey] characterAtIndex: 0];
  
  [self showUserInfoView: self];
  if (character == offchar)
    {
      /* Turn Machine off... */
      [(UserInfoView *)userInfoView setDisplayString: @"Power Off"];
      [mgr setBool: YES forKey: DUserStop];
    }
  else if (character == infochar)
    {
      int info = [mgr integerForKey: DOverlayInfo];
      info++;
      if (info > MAX_INFO)
	info = 0;
      [mgr setBool: (info) ? YES : NO forKey: DShowOverlay];
      [mgr setInteger: info forKey: DOverlayInfo];
      if (info)
        [self showOverlay];
      else
        [self removeOverlay];
  
      [(UserInfoView *)userInfoView setDisplayString: 
			  [NSString stringWithFormat: @"Info: %d", info]];
      [[PreferencesController sharedPreferences] loadValues: self];
    }
  else if (character == backchar)
    {
      [(UserInfoView *)userInfoView setDisplayString: @"Previous"];
      [currentFrame reverseStep];
    }
  else if (character == downchar || character == upchar)
    {
      int speed = [mgr integerForKey: DSpeed];
      if (character == downchar)
	speed /= sqrt(2);
      else
	speed *= sqrt(2);
      if (speed < 2)
	speed = 2;
      [mgr setInteger: speed forKey: DSpeed];
      [(UserInfoView *)userInfoView setDisplayString: 
			[NSString stringWithFormat: @"Delay: %d", speed]];
      [[PreferencesController sharedPreferences] loadValues: self];
    }
  else if (character == togchar)
    {
    int full_screen = [mgr integerForKey: DFullScreen];
    [mgr setInteger: 1-full_screen forKey: DFullScreen];
    [(UserInfoView *)userInfoView setDisplayString: @"Toggle Screen"];
    /* Need to recreate the window */
      [self stopTimer];
    [self createPictureWindow];
      [self startTimer];
    }
  else if (character == ',')
    {
      [self showPreferences: self];
    }
  [[pWindow contentView] display];

}

- (void) showOverlay
{
#ifdef GNUSTEP
  if (overlayView == nil)
    {
      NSRect rect = [[pWindow contentView] frame];
      rect.size.height = MIN(160, rect.size.height/4);
      overlayView = [[OverlayView alloc] initWithFrame: rect];
    }
  if ([overlayView superview] == nil)
    [[pWindow contentView] addSubview: overlayView];
#else
  if (overlayWindow == nil)
    {
      NSView *overlayView;
      NSRect rect = [[pWindow contentView] frame];
      rect.size.height = MIN(160, rect.size.height/4);
      overlayView = [[OverlayView alloc] initWithFrame: rect];
      AUTORELEASE(overlayView);
      rect = [pWindow frame];
      rect.size.height = MIN(160, rect.size.height/4);
      overlayWindow = [[DBOverlayWindow alloc] initWithContentRect: rect
							 styleMask: NSBorderlessWindowMask
							   backing: NSBackingStoreBuffered
							     defer: NO];
      [[overlayWindow contentView] addSubview: overlayView];
      [pWindow addChildWindow: overlayWindow ordered: NSWindowAbove];
    }
  [overlayWindow orderFront: self];
#endif
}

- (void) removeOverlay
{
#ifdef GNUSTEP
  if ([overlayView superview])
    [overlayView removeFromSuperview];
#else
  [overlayWindow orderOut: self];
#endif
}

// timer managment
- (void) startTimer
{
  runSpeed = [dfltmgr floatForKey: DSpeed];
  NS_DURING
    if (runSpeed <= 0)
      runSpeed = [currentFrame animationDelayTime];
  NS_HANDLER
    NSLog(@"EXCEPTION: %@", localException);
  NS_ENDHANDLER
  if (runSpeed <= 0)
    runSpeed = DEFAULT_SPEED;

  if (timer)
    [self stopTimer];

  timer = [NSTimer scheduledTimerWithTimeInterval: runSpeed
		       target: self
		       selector: @selector(runAnimation:)
		       userInfo: nil
		       repeats: YES];
  RETAIN(timer);
}

- (void) stopTimer
{
  if (timer != nil)
    {
      [timer invalidate];
      RELEASE(timer);
      timer = nil;
    }
}

- (void) runAnimation: (NSTimer *)atimer
{
  BOOL request;
  NSTimeInterval newSpeed;
  if (!pWindow)
    {
      return;
    }

  NS_DURING
    [currentFrame oneStep];
  NS_HANDLER
    NSLog(@"EXCEPTION while in running animation: %@",localException);
  NS_ENDHANDLER

  /* Check if we're supposed to do something or if the defaults have changed */
  newSpeed = [dfltmgr floatForKey: DSpeed];
  if (newSpeed != runSpeed)
    {
      [self stopTimer];
      [self startTimer];
    }
  request = [dfltmgr boolForKey: DShowOverlay];
  if (request)
    {
      [self showOverlay];
    }
  else
    [self removeOverlay];
  [self monitorComputer];
}

- (void) changeFont: (id)sender
{
  NSLog(@"Picture Frame got change font");
  [[PreferencesController sharedPreferences] changeFont: sender];
}

@end


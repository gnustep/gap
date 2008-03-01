/* 
   Project: batmon

   Copyright (C) 2005-2008 GNUstep Application Project

   Author: Riccardo Mottola
   FreeBSD support by Chris B. Vetter

   Created: 2005-06-25 21:06:19 +0200 by multix
   
   Application Controller

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
#import "AppController.h"



@implementation AppController

+ (void)initialize
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];


  /*
   * Register your app's defaults here by adding objects to the
   * dictionary, eg
   *
   * [defaults setObject:anObject forKey:keyForThatObject];
   *
   */
  
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
  [[NSUserDefaults standardUserDefaults] synchronize];


}

- (id)init
{
    if ((self = [super init]))
    {
        NSMutableParagraphStyle *style;
	NSFont *font;

        batModel = [[BatteryModel alloc] init];
        style = [[NSMutableParagraphStyle alloc] init];
    	[style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    	
	font = [NSFont systemFontOfSize:9.0];
	stateStrAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
        font, NSFontAttributeName,
        style, NSParagraphStyleAttributeName, nil] retain];
    }
    return self;
}

- (void)dealloc
{
    [stateStrAttributes release];
    [super dealloc];
}

- (void)awakeFromNib
{
    NSTimer *timer;

    [[NSApp mainMenu] setTitle:@"batmon"];
    [self updateInfo:nil];
  
    if (YES)
    {
        NSLog(@"app initialized, setting timer");
        timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateInfo:) userInfo:nil repeats:YES];
        [timer fire];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotif
{
}

- (BOOL)applicationShouldTerminate:(id)sender
{
  return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotif
{
}

- (BOOL)application:(NSApplication *)application openFile:(NSString *)fileName
{
}

- (void)showPrefPanel:(id)sender
{
}



- (void)getInfo
{

}

#define HEIGHT 47
#define WIDTH  20
- (void)drawImageRep
{
    NSBezierPath *bzp;
    NSMutableString *str;
    char *cStr;

    [[NSColor blackColor] set];
    bzp = [NSBezierPath bezierPath];
    [bzp appendBezierPathWithRect: NSMakeRect(0, 1, WIDTH, HEIGHT)];
    [bzp stroke];
    
    bzp = [NSBezierPath bezierPath];
    if ([batModel remainingCapacity] < [batModel warningCapacity])
       [[NSColor redColor] set];
    else
       [[NSColor whiteColor] set];
    [bzp appendBezierPathWithRect: NSMakeRect(0+1, 1+1, WIDTH - 2, ([batModel chargePercent]/100) * HEIGHT -2)];
    [bzp fill];

    cStr = calloc(4, sizeof(char));
    sprintf(cStr, "%2.0f%%", [batModel chargePercent]);
    str = [NSMutableString stringWithCString:cStr];
    [str drawAtPoint: NSMakePoint(WIDTH + 5 , 1) withAttributes:stateStrAttributes];
    free(cStr);
}

- (void)drawIcon
{
    NSImageRep *rep;
    NSImage    *icon;
    
    icon = [[NSImage alloc] initWithSize: NSMakeSize(48, 48)];
    rep = [[NSCustomImageRep alloc]
            initWithDrawSelector: @selector(drawImageRep)
            delegate:self];
    [rep setSize: NSMakeSize(48, 48)];
    [icon addRepresentation: rep];
    [NSApp setApplicationIconImage:icon];
}


- (IBAction)updateInfo:(id)sender
{
    float lifeVal;
    float timeRem;

    [batModel update];

    /* main window */
    timeRem = [batModel timeRemaining];
    hours = timeRem;
    mins = (int)((timeRem - (float)hours) * 60);

    [voltage setStringValue:[NSString stringWithFormat:@"%3.2f V", [batModel volts]]];
    [presentCap setStringValue:[NSString stringWithFormat:@"%3.2f Wh", [batModel remainingCapacity]]];
    [level setDoubleValue:[batModel chargePercent]];
    [percent setStringValue:[NSString stringWithFormat:@"%3.1f%", [batModel chargePercent]]];
    [rate setStringValue:[NSString stringWithFormat:@"%3.2f W", [batModel watts]]];
    [amperage setStringValue:[NSString stringWithFormat:@"%3.2f A", [batModel amps]]];
    if (timeRem >= 0)
        [timeLeft setStringValue:[NSString stringWithFormat:@"%dh %d\'", hours, mins]];
    else
        [timeLeft setStringValue:@"unknown"];
    [chState setStringValue:[batModel state]];

    /* info window */
    lifeVal = [batModel lastCapacity]/[batModel designCapacity];
    [lifeGauge setDoubleValue:lifeVal*100];
    [lifeGaugePercent setStringValue:[NSString stringWithFormat:@"%3.1f%", lifeVal*100]];
    [designCap setStringValue:[NSString stringWithFormat:@"%3.2f Wh", [batModel designCapacity]]];
    [lastFullCharge setStringValue:[NSString stringWithFormat:@"%3.2f Wh", [batModel lastCapacity]]];
    [battType setStringValue:[batModel batteryType]];

    [self drawIcon];
}


- (IBAction)showBattInfo:(id)sender
{
    [infoWin makeKeyAndOrderFront:self];
}


@end

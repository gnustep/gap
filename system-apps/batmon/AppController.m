/* 
   Project: batmon

   Copyright (C) 2005 Riccardo Mottola

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

#if defined(freebsd) || defined( __FreeBSD__ )
#  include <fcntl.h>
#  include <sys/ioctl.h>
#  include <dev/acpica/acpiio.h>
#  define ACPIDEV	"/dev/acpi"
#endif

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
#if defined(linux)
  NSFileManager       *fm;
  NSArray             *dirNames;
  NSEnumerator        *en;
  NSString            *dirName;
  BOOL                done;
  FILE                *stateFile;
  char                presentStr[16];
  char                line[128];
#endif /* linux */

  if ((self = [super init]))
    {
#if defined(linux)
  /* look for a battery */
  NSLog(@"look for a present battery");
  fm = [NSFileManager defaultManager];
  dirNames = [fm directoryContentsAtPath:@"/proc/acpi/battery"];
  if (dirNames != nil)
  {
     done = NO;
     en = [dirNames objectEnumerator];
     while (done == NO)
     {
        dirName = [en nextObject];
        if (dirName != nil)
        {
           /* scan for the first present battery */
           dirName = [[NSString stringWithString:@"/proc/acpi/battery"] stringByAppendingPathComponent:dirName];
           [dirName getCString:batteryStatePath0];
           strcat(batteryStatePath0, "/state");
           NSLog(@"checking: %s", batteryStatePath0);
           stateFile = fopen(batteryStatePath0, "r");
           if (stateFile != NULL)
           {
              [self readLine :stateFile :line];
              sscanf(line, "present: %s", presentStr);
              if (!strcmp(presentStr, "yes"))
              {
                 done = YES;
                 NSLog(@"found it!: %@", dirName);
                 [dirName getCString:batteryInfoPath0];
                 strcat(batteryInfoPath0, "/info");
              }
              fclose(stateFile);
           }           
        } else
        {
           done = YES;
        }
     }
  }
#endif /* linux */
    }
  return self;
}

- (void)dealloc
{
  [super dealloc];
  if (chargeState != nil)
        [chargeState release];
  if (batteryType != nil)
        [batteryType release];
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

- (void)readLine :(FILE *)f :(char *)l
{
    int ch;
    
    ch = fgetc(f);
    while (ch != EOF && ch != '\n')
    {
        *l = ch;
        l++;
        ch = fgetc(f);
    }
    *l = '\0';
}


- (void)getInfo
{
#if defined(freebsd) || defined( __FreeBSD__ )
  
  union acpi_battery_ioctl_arg
    battio;
  int
    acpifd;
  BOOL
    charged = YES;
  
  battio.unit = 0;
  
  acpifd = open(ACPIDEV, O_RDWR);
  if (acpifd == -1) acpifd = open(ACPIDEV, O_RDONLY);
  if (acpifd == -1) return;
  if( -1 == ioctl(acpifd, ACPIIO_CMBAT_GET_BIF, &battio) ) return;

  desCap = (float)battio.bif.dcap / 1000;	// design capacity
  lastCap = (float)battio.bif.lfcap / 1000;	// last full capacity

  if( -1 == ioctl(acpifd, ACPIIO_CMBAT_GET_BST, &battio) ) return;
  close(acpifd);

  currCap = (float)battio.bst.cap / 1000;	// remaining capacity
  volts = (float)battio.bst.volt / 1000;	// present voltage
  watts = (float)battio.bst.rate / 1000;	// present rate
  amps = watts / volts;
  
  batteryType = @"";
  if( ACPI_BATT_STAT_NOT_PRESENT != battio.bst.state )
  {
    NSString *status = nil;

    if( battio.bst.state & ACPI_BATT_STAT_CRITICAL )
      batteryType = @"CRITICAL ";		// could be complementary!
    
    if( battio.bst.state & ACPI_BATT_STAT_MAX )
      status = @"Charged";
    if( battio.bst.state & ACPI_BATT_STAT_CHARGING )
      status = @"Charging";
    if( battio.bst.state & ACPI_BATT_STAT_DISCHARG )
      status = @"Discharging";

    batteryType = [NSString stringWithFormat: @"%@%@", batteryType, status];
  }
  else
    batteryType = @"Missing";

  chargeState = [NSString stringWithString: batteryType];
  batteryType = [NSString stringWithFormat: @"%s", battio.bif.type];
  
  //
  // Note: I cannot really tell whether the calculation is correct because
  //       my laptop's battery is kinda screwed up...
  //
  if( [chargeState isEqualToString: @"Charged"] )
  {
    chargePercent = 100;
    timeRemaining = 0;
  }
  else if( battio.bst.state & ACPI_BATT_STAT_CHARGING )
  {
    timeRemaining = (lastCap-currCap) / watts;
    chargePercent = currCap/lastCap*100;
  }
  else
  {
    timeRemaining = currCap / watts;
    chargePercent = currCap/lastCap*100;
  }
  
#elif defined(linux)

    char infoFilePath[1024];
    char stateFilePath[1024];
    FILE *stateFile;
    FILE *infoFile;
    char line[128];
    
    char presentStr[16];
    char stateStr[16];
    char chStateStr[16];
    char rateStr[16];
    char capacityStr[16];
    char voltageStr[16];
    int  rateVal;
    int  capacityVal;
    int  voltageVal;
    int  warnVal;

    char present2Str[16];
    char desCapStr[16];
    char lastCapStr[16];
    char batTypeStr[16];
    char warnCapStr[16];

    

    stateFile = fopen(batteryStatePath0, "r");
    assert(stateFile != NULL);

    [self readLine :stateFile :line];
    sscanf(line, "present: %s", presentStr);
    [self readLine :stateFile :line];
    sscanf(line, "capacity state: %s", stateStr);
    [self readLine :stateFile :line];
    sscanf(line, "charging state: %s", chStateStr);
    [self readLine :stateFile :line];
    sscanf(line, "present rate: %s mW", rateStr);
    [self readLine :stateFile :line];
    sscanf(line, "remaining capacity: %s mWh", capacityStr);
    [self readLine :stateFile :line];
    sscanf(line, "present voltage: %s mV", voltageStr);
    fclose(stateFile);

    rateVal = atoi(rateStr);
    capacityVal = atoi(capacityStr);
    voltageVal = atoi(voltageStr);

    infoFile = fopen(batteryInfoPath0, "r");
    assert(infoFile != NULL);

    [self readLine :infoFile :line];
    sscanf(line, "present: %s", present2Str);
    [self readLine :infoFile :line];
    sscanf(line, "design capacity: %s", desCapStr);
    [self readLine :infoFile :line];
    sscanf(line, "last full capacity: %s", lastCapStr);
    [self readLine :infoFile :line]; // battery technology
    [self readLine :infoFile :line]; // design voltage
    [self readLine :infoFile :line]; //design capacity warning
    sscanf(line, "design capacity warning: %s", warnCapStr);
    [self readLine :infoFile :line];    
    [self readLine :infoFile :line];
    [self readLine :infoFile :line];
    [self readLine :infoFile :line];
    [self readLine :infoFile :line];
    [self readLine :infoFile :line];
    sscanf(line, "battery type: %s", batTypeStr);
    if (batteryType != nil)
        [batteryType release];
    batteryType = [[NSString stringWithCString:batTypeStr] retain];

    fclose(infoFile);

    watts = (float)rateVal / 1000;

    // a sanity check, a laptop won't consume 1000W
    // necessary since sometimes ACPI returns bogus stuff

    if (watts > 1000)
        watts = 0;
    volts = (float)voltageVal / 1000;
    amps = watts / volts;
    desCap = (float)atoi(desCapStr)/1000;
    lastCap = (float)atoi(lastCapStr)/1000;
    currCap = capacityVal / 1000;
    warnCap = (float)atoi(warnCapStr)/1000;

    if (chargeState != nil)
        [chargeState release];
    chargeState = [[NSString stringWithCString:chStateStr] retain];

    if (!strcmp(chStateStr, "charged"))
    {
        chargePercent = 100;
        timeRemaining = 0;
    } else if (!strcmp(chStateStr, "charging"))
    {
        if (watts > 0)
            timeRemaining = (lastCap-currCap) / watts;
        else
            timeRemaining = -1;
        chargePercent = currCap/lastCap*100;
    } else
    {
        if (watts > 0)
            timeRemaining = currCap / watts;
        else
            timeRemaining = -1;
        chargePercent = currCap/lastCap*100;
    }

#endif /* OS */
}

#define HEIGHT 47
#define WIDTH  20
- (void)drawImageRep
{
    NSBezierPath *bzp;

    [[NSColor blackColor] set];
    bzp = [NSBezierPath bezierPath];
    [bzp appendBezierPathWithRect: NSMakeRect(0, 1, WIDTH, HEIGHT)];
    [bzp stroke];
    
    bzp = [NSBezierPath bezierPath];
    if (currCap < warnCap)
       [[NSColor redColor] set];
    else
       [[NSColor whiteColor] set];
    [bzp appendBezierPathWithRect: NSMakeRect(0+1, 1+1, WIDTH - 2, (chargePercent/100) * HEIGHT -2)];
    [bzp stroke];  
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

    [self getInfo];

    /* main window */
    hours = (int)floor(timeRemaining);
    mins = (int)((timeRemaining - (float)hours) * 60);

    [voltage setStringValue:[NSString stringWithFormat:@"%3.2f V", volts]];
    [presentCap setStringValue:[NSString stringWithFormat:@"%3.2f Wh", currCap]];
    [level setDoubleValue:chargePercent];
    [percent setStringValue:[NSString stringWithFormat:@"%3.1f%", chargePercent]];
    [rate setStringValue:[NSString stringWithFormat:@"%3.2f W", watts]];
    [amperage setStringValue:[NSString stringWithFormat:@"%3.2f A", amps]];
    if (timeRemaining >= 0)
        [timeLeft setStringValue:[NSString stringWithFormat:@"%dh %d\'", hours, mins]];
    else
        [timeLeft setStringValue:@"unknown"];
    [chState setStringValue:chargeState];

    /* info window */
    lifeVal = lastCap/desCap;
    [lifeGauge setDoubleValue:lifeVal*100];
    [lifeGaugePercent setStringValue:[NSString stringWithFormat:@"%3.1f%", lifeVal*100]];
    [designCap setStringValue:[NSString stringWithFormat:@"%3.2f Wh", desCap]];
    [lastFullCharge setStringValue:[NSString stringWithFormat:@"%3.2f Wh", lastCap]];
    [battType setStringValue:batteryType];

    [self drawIcon];
}


- (IBAction)showBattInfo:(id)sender
{
    [infoWin makeKeyAndOrderFront:self];
}


@end

/* 
   Project: batmon

   Copyright (C) 2005 Riccardo Mottola

   Author: Riccardo Mottola

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
  [[NSApp mainMenu] setTitle:@"batmon"];
    [self updateInfo:nil];
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

    char present2Str[16];
    char desCapStr[16];
    char lastCapStr[16];
    char batTypeStr[16];

    

    stateFile = fopen("/proc/acpi/battery/BAT0/state", "r");
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

    infoFile = fopen("/proc/acpi/battery/BAT0/info", "r");
    assert(infoFile != NULL);

    [self readLine :infoFile :line];
    sscanf(line, "present: %s", present2Str);
    [self readLine :infoFile :line];
    sscanf(line, "design capacity: %s", desCapStr);
    [self readLine :infoFile :line];
    sscanf(line, "last full capacity: %s", lastCapStr);
    [self readLine :infoFile :line];
    [self readLine :infoFile :line];
    [self readLine :infoFile :line];    
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
    volts = (float)voltageVal / 1000;
    amps = watts / volts;
    desCap = (float)atoi(desCapStr)/1000;
    lastCap = (float)atoi(lastCapStr)/1000;
    currCap = capacityVal / 1000;

    if (chargeState != nil)
        [chargeState release];
    chargeState = [[NSString stringWithCString:chStateStr] retain];

    NSLog(@"state %s", presentStr);
    NSLog(@"state %s", stateStr);
    NSLog(@"ch state %s", chStateStr);
    NSLog(@"rate: %s, %d", rateStr, rateVal);
    NSLog(@"cap: %s %d", capacityStr, capacityVal);
    NSLog(@"volt: %s %f", voltageStr, volts);
    NSLog(@"amps: %f", amps);
    NSLog(@"des cap: %f", desCap);
    NSLog(@"last capg: %f", lastCap);
    NSLog(@"time remaining: %f", timeRemaining);

    if (!strcmp(chStateStr, "charged"))
    {
        chargePercent = 100;
        timeRemaining = 0;
    } else if (!strcmp(chStateStr, "charging"))
    {
        timeRemaining = (lastCap-currCap) / watts;
        chargePercent = currCap/lastCap*100;
    } else
    {
        timeRemaining = currCap / watts;
        chargePercent = currCap/lastCap*100;
    }
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
    [timeLeft setStringValue:[NSString stringWithFormat:@"%dh %d\'", hours, mins]];
    [chState setStringValue:chargeState];

    /* info window */
    lifeVal = lastCap/desCap;
    [lifeGauge setDoubleValue:lifeVal*100];
    [lifeGaugePercent setStringValue:[NSString stringWithFormat:@"%3.1f%", lifeVal*100]];
    [designCap setStringValue:[NSString stringWithFormat:@"%3.2f Wh", desCap]];
    [lastFullCharge setStringValue:[NSString stringWithFormat:@"%3.2f Wh", lastCap]];
    [battType setStringValue:batteryType];
}

- (IBAction)showBattInfo:(id)sender
{
    [infoWin makeKeyAndOrderFront:self];
}


@end

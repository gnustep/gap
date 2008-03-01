/*
   Project: batmon

   Copyright (C) 2006-2008 GNUstep Application Project

   Author: Riccardo Mottola 

   Created: 2006-01-14 23:58:48 Riccardo Mottola

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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#if defined(freebsd) || defined( __FreeBSD__ )
#  include <fcntl.h>
#  include <sys/ioctl.h>
#  include <dev/acpica/acpiio.h>
#  define ACPIDEV	"/dev/acpi"
#endif


#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSFileManager.h>

#import "BatteryModel.h"

@implementation BatteryModel

- (void)_readLine :(FILE *)f :(char *)l
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
        	  [self _readLine :stateFile :line];
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

- (void)deallo
{
  if (chargeState != nil)
        [chargeState release];
  if (batteryType != nil)
        [batteryType release];
  [super dealloc];

}


- (void) update
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

    [self _readLine :stateFile :line];
    sscanf(line, "present: %s", presentStr);
    [self _readLine :stateFile :line];
    sscanf(line, "capacity state: %s", stateStr);
    [self _readLine :stateFile :line];
    sscanf(line, "charging state: %s", chStateStr);
    [self _readLine :stateFile :line];
    sscanf(line, "present rate: %s mW", rateStr);
    [self _readLine :stateFile :line];
    sscanf(line, "remaining capacity: %s mWh", capacityStr);
    [self _readLine :stateFile :line];
    sscanf(line, "present voltage: %s mV", voltageStr);
    fclose(stateFile);

    rateVal = atoi(rateStr);
    capacityVal = atoi(capacityStr);
    voltageVal = atoi(voltageStr);

    infoFile = fopen(batteryInfoPath0, "r");
    assert(infoFile != NULL);

    [self _readLine :infoFile :line];
    sscanf(line, "present: %s", present2Str);
    [self _readLine :infoFile :line];
    sscanf(line, "design capacity: %s", desCapStr);
    [self _readLine :infoFile :line];
    sscanf(line, "last full capacity: %s", lastCapStr);
    [self _readLine :infoFile :line]; // battery technology
    [self _readLine :infoFile :line]; // design voltage
    [self _readLine :infoFile :line]; //design capacity warning
    sscanf(line, "design capacity warning: %s", warnCapStr);
    [self _readLine :infoFile :line];    
    [self _readLine :infoFile :line];
    [self _readLine :infoFile :line];
    [self _readLine :infoFile :line];
    [self _readLine :infoFile :line];
    [self _readLine :infoFile :line];
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

- (float)volts
{
    return volts;
}

- (float)amps
{
    return amps;
}

- (float)watts
{
    return watts;
}

- (float)timeRemaining
{
    return timeRemaining;
}

- (float)remainingCapacity
{
    return currCap;
}

- (float)warningCapacity
{
    return warnCap;
}

- (float)lastCapacity
{
    return lastCap;
}

- (float)designCapacity
{
    return desCap;
}

- (float)chargePercent
{
    return chargePercent;
}

- (NSString *)state
{
    return chargeState;
}

- (NSString *)batteryType
{
    return batteryType;
}


@end

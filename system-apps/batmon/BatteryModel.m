/*
   Project: batmon

   Copyright (C) 2006-2013 GNUstep Application Project

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
#  include <unistd.h>
#  include <stdint.h>
#  include <fcntl.h>
#  include <sys/ioctl.h>
#  include <dev/acpica/acpiio.h>
#  define ACPIDEV	"/dev/acpi"
#endif

#if defined (linux)
#define DEV_SYS_POWERSUPPLY  @"/sys/class/power_supply"
#define DEV_PROC_PMU  @"/proc/pmu"
#endif

#if defined(__APPLE__)
#  include <stdio.h>
#endif

#if defined(netbsd) || defined(__NetBSD__)
#include <paths.h>  /* path for the system devices */
#include <fcntl.h>  /* open */
#include <unistd.h>
#include <sys/envsys.h>
#include <prop/proplib.h> /* psd property dictionaries */
#endif

#if defined(openbsd) || defined(__OpenBSD__)
#include <unistd.h>
#include <fcntl.h>  /* open */
#include <sys/ioctl.h>
#include <machine/apmvar.h>
#define APMDEV "/dev/apm"
#endif

#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSException.h>

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
      useWattHours= YES;
      
      isCharging = NO;
      batteryManufacturer = nil;
      
#if defined(linux)
      useACPIproc = NO;
      useACPIsys  = NO;
      useAPM      = NO;
      usePMU      = NO;

      /* look for a battery */
      NSLog(@"looking for ACPI...");
      fm = [NSFileManager defaultManager];
      dirNames = [fm directoryContentsAtPath:DEV_SYS_POWERSUPPLY];
      if (dirNames != nil)
        {
	  done = NO;
	  en = [dirNames objectEnumerator];
	  while (done == NO)
	    {
	      dirName = [en nextObject];
	      if (dirName != nil)
		{
		  NSString *presentFileName;
		  FILE *presentFile;

		  /* scan for the first present battery */
		  presentFileName = [dirName stringByAppendingPathComponent:@"present"];

		  [[DEV_SYS_POWERSUPPLY stringByAppendingPathComponent:presentFileName] getCString:batteryStatePath0];
		  NSLog(@"/sys checking: %s", batteryStatePath0);
		      presentFile = fopen(batteryStatePath0, "r");
		      if (presentFile != NULL)
			{
			  [self _readLine :presentFile :line];
			  if (!strcmp(line, "1"))
			    {
			      done = YES;
			      NSLog(@"/sys: found it!: %@", [DEV_SYS_POWERSUPPLY stringByAppendingPathComponent:dirName]);
                              batterySysAcpiString = [[DEV_SYS_POWERSUPPLY stringByAppendingPathComponent:dirName] retain];
			    }
			  fclose(presentFile);
			  useACPIsys = YES;
			}           
		} else
		{
		  done = YES;
		}
	    }
	} else
	{
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
			      NSLog(@"/proc found it!: %@", dirName);
			      [dirName getCString:batteryInfoPath0];
			      strcat(batteryInfoPath0, "/info");
			    }
			  fclose(stateFile);
			  useACPIproc = YES;
			}           
		    } else
		    {
		      done = YES;
		    }
		}
	    } else
	    {
	      /* no acpi, but maybe apm */
	      if([fm fileExistsAtPath:@"/proc/apm"] == YES)
		{
		  NSLog(@"found apm");
		  useAPM = YES;
		  strcpy(apmPath, "/proc/apm");
		}
	      else
		{
		  dirNames = [fm directoryContentsAtPath:DEV_PROC_PMU];
		  if (dirNames != nil)
		    {
		      NSLog(@"Found PMU");
		      usePMU = YES;
		      useWattHours = NO;
		    }
		}
	    }
	}
      
#endif /* linux */
      [self updatePlatformSpecific];
    }
  return self;

}

- (void)dealloc
{
  if (batteryType != nil)
        [batteryType release];
  [super dealloc];
}


- (void) update
{
#if defined(freebsd) || defined( __FreeBSD__ )
  
  union acpi_battery_ioctl_arg battio;
  int acpifd;
  
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
  amps = 0;
  if (volts)
    amps = watts / volts;
  
  batteryType = @"";
  if( ACPI_BATT_STAT_NOT_PRESENT != battio.bst.state )
    {
      isCritical = NO;
      if( battio.bst.state & ACPI_BATT_STAT_CRITICAL )
        isCritical = YES;     

      if( battio.bst.state == 0 )
        batteryState = BMBStateHigh;
      else if( battio.bst.state & ACPI_BATT_STAT_CHARGING )
        batteryState = BMBStateCharging;
      else if( battio.bst.state & ACPI_BATT_STAT_DISCHARG )
        batteryState = BMBStateDischarging;
      else if (battio.bst.state & ACPI_BATT_STAT_INVALID )
        batteryState = BMBStateUnknown;
      else
        batteryState = BMBStateUnknown;

      batteryType = [NSString stringWithFormat: @"%s", battio.bif.type];
    }
  else
    {
      batteryState = BMBStateMissing;
      batteryType = @"Missing";
    }

  if( batteryState == BMBStateHigh )
    {
      timeRemaining = 0;
      chargePercent = currCap/lastCap*100;
      isCharging = YES;
    }  
  else if( batteryState == BMBStateCharging )
    {
      timeRemaining = (lastCap-currCap) / watts;
      chargePercent = currCap/lastCap*100;
      isCharging = YES;
    }
  else if( batteryState == BMBStateDischarging )
    {
      timeRemaining = currCap / watts;
      chargePercent = currCap/lastCap*100;
      isCharging = NO;
    }
#elif defined(netbsd) || defined (__NetBSD__)
  int		sysmonfd; /* fd of /dev/sysmon */
  int rval;
  prop_dictionary_t bsd_dict;
  NSString *string;
  NSDictionary *dict;
  char *cStr;
  NSEnumerator *enum1;
  id obj1;
  NSDictionary *acpibat0;
  NSMutableDictionary *batDict;
  NSDictionary *chargeDict;
  NSString *valueStr;
  float chargeRate, dischargeRate;

  /* Open the device in ro mode */
  if ((sysmonfd = open(_PATH_SYSMON, O_RDONLY)) == -1)
    NSLog(@"Error opening device: %s", _PATH_SYSMON);

  rval = prop_dictionary_recv_ioctl(sysmonfd,
				    ENVSYS_GETDICTIONARY,
				    &bsd_dict);
  if (rval)
    {
      NSLog(@"Error: %s", strerror(rval));
      return;
    }
  
  cStr = prop_dictionary_externalize(bsd_dict);
  string = [NSString stringWithCString: cStr];
  dict = [string propertyList];
  if (dict == nil)
    {
      NSLog(@"Could not parse dictionary");
      return;
    }

  acpibat0 = [dict objectForKey: @"acpibat0"];
  //NSLog(@"acpibat0: %@", acpibat0);
  batDict = [NSMutableDictionary dictionaryWithCapacity: 3];
  enum1 = [acpibat0 objectEnumerator];
  while ((obj1 = [enum1 nextObject]))
    {
      //      NSLog(@"--->%@", obj1);
      if ([obj1 isKindOfClass: [NSDictionary class]])
	{
	  NSString *descriptionKey;

	  descriptionKey = [obj1 objectForKey:@"description"];
	  //	  NSLog(@"key-----> %@", descriptionKey);
	  if (descriptionKey)
	    [batDict setObject: obj1 forKey: descriptionKey];
	}
      else
	NSLog(@"not a dict");

    }
  //NSLog(@"battery dictionary: %@", batDict);
  (void)close(sysmonfd);

  valueStr = [[batDict objectForKey: @"voltage"] objectForKey: @"cur-value"];
  if (valueStr)
    volts = [valueStr floatValue] / 1000000;
  NSLog(@"voltage: %@ %f", valueStr, volts);

  valueStr = [[batDict objectForKey: @"design cap"] objectForKey: @"cur-value"];
  if (valueStr)
    {
      if ([[[batDict objectForKey: @"design cap"] objectForKey: @"type"] isEqualToString: @"Ampere hour"])
	{
	  useWattHours = NO;
	}
      else if ([[[batDict objectForKey: @"design cap"] objectForKey: @"type"] isEqualToString: @"Watt hour"])
	{
	  useWattHours = YES;
	}
      desCap = [valueStr floatValue] / 1000000;
    }
  NSLog(@"design cap: %@ %f", valueStr, desCap);

  chargeDict = [batDict objectForKey: @"charge"];
  valueStr = [chargeDict objectForKey: @"critical-capacity"];
  if (valueStr)
    {
      critCap = [valueStr floatValue] / 1000000;
    }
  NSLog(@"crit cap: %@ %f", valueStr, critCap);
  valueStr = [chargeDict objectForKey: @"warning-capacity"];
  if (valueStr)
    {
      warnCap = [valueStr floatValue] / 1000000;
    }
  NSLog(@"warn cap: %@ %f", valueStr, warnCap);
  valueStr = [[batDict objectForKey: @"last full cap"] objectForKey: @"cur-value"];
  if (valueStr)
    lastCap = [valueStr floatValue] / 1000000;
  NSLog(@"last full cap: %@, %f", valueStr, lastCap);

  valueStr = [[batDict objectForKey: @"charge rate"] objectForKey: @"cur-value"];
  chargeRate = 0;
  if (valueStr)
    chargeRate = [valueStr floatValue] / 1000000;
  NSLog(@"charge rate: %@ %f", valueStr, chargeRate);

  valueStr = [[batDict objectForKey: @"discharge rate"] objectForKey: @"cur-value"];
  dischargeRate = 0;
  if (valueStr)
    dischargeRate = [valueStr floatValue] / 1000000;
  NSLog(@"discharge rate: %@ %f", valueStr, dischargeRate);

  valueStr = [[batDict objectForKey: @"charge"] objectForKey: @"cur-value"];
  if (valueStr)
    currCap = [valueStr floatValue] / 1000000;
  NSLog(@"charge: %@, %f", valueStr, currCap);

  valueStr = [[batDict objectForKey: @"charging"] objectForKey: @"cur-value"];
  NSLog(@"charging: %@", valueStr);
  NSLog(@"currCap %f, lastCap %f, amps %f", currCap, lastCap,amps);
  if ([valueStr intValue] == 0)
    {
      amps = dischargeRate;
      isCharging = NO;
      if (amps > 0)
	timeRemaining = currCap / amps;
      else
	timeRemaining = -1;
      chargePercent = currCap/lastCap*100;
      batteryState = BMBStateDischarging;
    }
  else
    {
      amps = chargeRate;
      isCharging = YES;
      if (amps > 0)
	timeRemaining = (lastCap-currCap) / amps;
      else
	timeRemaining = -1;
      chargePercent = currCap/lastCap*100;
      batteryState = BMBStateCharging;
    }
  watts = amps * volts;

  /* sanitize */
  if (critCap > warnCap)
    critCap = warnCap;
  if (critCap == 0)
    {
      if (warnCap > 0)
        critCap = warnCap;
      else
        critCap = desCap / 100;
    }
      
  isCritical = NO;
  if (currCap <= critCap)
    isCritical = YES;

#elif defined(openbsd) || defined(__OpenBSD__)
  int apmfd;
  struct apm_power_info apmPwInfo;
  BOOL validBattery;

  apmfd = open(APMDEV, O_RDONLY);
  if (apmfd == -1)
    return;

  if( -1 == ioctl(apmfd, APM_IOC_GETPOWER, &apmPwInfo) )
    return;

  isCharging = NO;
  validBattery = YES;
  if (APM_BATT_HIGH == apmPwInfo.battery_state)
    batteryState = BMBStateHigh;
  else if (APM_BATT_LOW == apmPwInfo.battery_state)
    {
      batteryState = BMBStateLow;
    }
  else if (APM_BATT_CRITICAL == apmPwInfo.battery_state)
    {
      batteryState = BMBStateCritical;
      isCritical = YES;
    }
  else if (APM_BATT_CHARGING == apmPwInfo.battery_state)
    {
      batteryState = BMBStateCharging;
      isCharging = YES;
    }
  else if (APM_BATTERY_ABSENT == apmPwInfo.battery_state)
    {
      batteryState = BMBStateMissing;
      validBattery = NO;
    }
  else
    {
      batteryState = BMBStateUnknown;;
      validBattery = NO;
    }

  if (APM_AC_ON == apmPwInfo.ac_state)
    isCharging = YES;

  /* we expect time in hours */
  if (validBattery)
    {
      timeRemaining = (float)apmPwInfo.minutes_left / 60;
      chargePercent = (float)(int)apmPwInfo.battery_life;

      /* sanity checks */
      if (isCharging && timeRemaining > 100)
	timeRemaining = 0;
      if (chargePercent > 100)
	chargePercent = 100;
      else if (chargePercent < 0)
	chargePercent = 0;

      if (timeRemaining < 0)
	timeRemaining = 0;
    }
  else
    {
      chargePercent = 0;
      timeRemaining= 0;
    }

  close(apmfd);

#else
  [self updatePlatformSpecific];

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
  NSString *s;

  switch(batteryState)
    {
    case BMBStateUnknown:
      s = @"Unknown";
      break;
    case BMBStateCharging:
      s = @"Charging";
      break;
    case BMBStateDischarging:
      s = @"Discharging";
      break;
    case BMBStateHigh:
      s = @"High";
      break;
    case BMBStateLow:
      s = @"Low";
      break;
    case BMBStateCritical:
      s = @"Critical";
      break;
    case BMBStateFull:
      s = @"Full";
      break;
    case BMBStateMissing:
      s = @"Missing";
      break;
    default:
      NSLog(@"Unrecognized battery state");
      s = @"Unrecognized";
      break;
    }
  return s;
}

- (NSString *)batteryType
{
    return batteryType;
}

- (NSString *)manufacturer
{
  return batteryManufacturer;
}

- (BOOL)isCritical
{
#if defined(linux)
  if(useACPIsys || useACPIproc)
  {
    return  [self remainingCapacity] < [self warningCapacity];
  } else if (useAPM)
  {
    return isCritical;
  } else
#endif
  return isCritical;
}

- (BOOL)isCharging
{
  return isCharging;
}

- (BOOL)isUsingWattHours
{
  return useWattHours;
}

@end

#if defined(linux)
#include "BatteryModel-Linux.m"
#endif

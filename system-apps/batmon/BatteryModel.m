/*
   Project: batmon

   Copyright (C) 2006-2011 GNUstep Application Project

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
#  include <stdint.h>
#  include <fcntl.h>
#  include <sys/ioctl.h>
#  include <dev/acpica/acpiio.h>
#  define ACPIDEV	"/dev/acpi"
#endif

#if defined (linux)
#define DEV_SYS_POWERSUPPLY  @"/sys/class/power_supply"
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
      useACPIproc = NO;
      useACPIsys  = NO;
      useAPM      = NO;
      useWattHours= YES;
      
      isCharging = NO;
      batteryManufacturer = nil;
      
#if defined(linux)
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
	    }
	}
      
#endif /* linux */
    }
  return self;

}

- (void)dealloc
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
  
  // CBV
  // Note: I cannot really tell whether the calculation is correct because
  //       my laptop's battery is kinda screwed up...
  //
  if( [chargeState isEqualToString: @"Charged"] )
  {
    chargePercent = 100;
    timeRemaining = 0;
    isCharging = YES;
  }
  else if( battio.bst.state & ACPI_BATT_STAT_CHARGING )
  {
    timeRemaining = (lastCap-currCap) / watts;
    chargePercent = currCap/lastCap*100;
    isCharging = YES;
  }
  else
  {
    timeRemaining = currCap / watts;
    chargePercent = currCap/lastCap*100;
    isCharging = NO;
  }
#elif defined(netbsd) || defined (__NetBSD__)
  int		sysmonfd; /* fd of /dev/sysmon */
  int rval;
  prop_dictionary_t bsd_dict;
  prop_object_iterator_t iter_dev;
  prop_object_t obj;
  

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
  
  /* iterate and look for batteries */
  iter_dev = prop_dictionary_iterator(bsd_dict);
  while ((obj = prop_object_iterator_next(iter_dev)) != NULL)
    {
      prop_object_t obj_dev;
      prop_array_t acpi_array;
      prop_object_iterator_t dev_iter;

      acpi_array = prop_dictionary_get_keysym(bsd_dict, obj);
      if (prop_object_type(acpi_array) != PROP_TYPE_ARRAY)
	{
	  NSLog(@"not an array");
	  continue;
	}

      dev_iter = prop_array_iterator(acpi_array);
      while ((obj_dev = prop_object_iterator_next(dev_iter)) != NULL)
	{
	  prop_object_t obj_devp;
	  obj_devp = prop_dictionary_get(obj_dev, "device-properties");

	  if (obj_devp != nil)
	    {
	      char* dev_class;

	      prop_dictionary_get_cstring(obj_devp, "device-class", &dev_class);
	      if (dev_class != NULL)
		{
		  //		  NSLog(@"class: %s", dev_class);
		  if (strcmp(dev_class, "battery"))
		    {
		      NSLog(@"Battery !");		      
		    }
		}
	      
	    }
	  else
	    {
	      prop_object_iterator_t iter_props;
	      prop_string_t p_str;
	      char str[ENVSYS_DESCLEN];


	      p_str = prop_dictionary_get(obj_dev, "description");
	      if (p_str != NULL)
		{
		  strcpy(str, prop_string_cstring_nocopy(p_str));
		  NSLog(@"description: %s", str);
		}
	      p_str = prop_dictionary_get(obj_dev, "type");
	      if (p_str != NULL)
		{
		  strcpy(str, prop_string_cstring_nocopy(p_str));	
		  NSLog(@"type %s", str);
		}
	      p_str = prop_dictionary_get(obj_dev, "state");
	      if (p_str != NULL)
		{
		  strcpy(str, prop_string_cstring_nocopy(p_str));	
		  NSLog(@"state %s", str);
		}
		    
		      
	    }
	}
      prop_object_iterator_release(dev_iter);
    }
  prop_object_iterator_release(iter_dev);
  (void)close(sysmonfd);
#elif defined(linux)

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
    char warnCapStr[16];

    if (useACPIsys)
      {
	NSString *ueventFileName;
        NSMutableDictionary *ueventDict;
        NSString *lineStr;
        NSRange  sepRange;
	NSString *valueStr;
	NSString *keyStr;

	NSLog(@"reading %@", batterySysAcpiString);

	ueventFileName = [batterySysAcpiString stringByAppendingPathComponent:@"uevent"];

        [ueventFileName getCString:batteryStatePath0];
        stateFile = fopen(batteryStatePath0, "r");
        NSAssert(stateFile != NULL, @"ACPI - /sys: state file shall not be NULL");

        ueventDict = [[NSMutableDictionary alloc] initWithCapacity: 4];

        [self _readLine :stateFile :line];
	lineStr = [NSString stringWithCString: line];
	while ([lineStr length] > 0)
	  {
	    
	    sepRange = [lineStr rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString:@"="]];
	    if (sepRange.location != NSNotFound)
	      {
		keyStr = [lineStr substringToIndex: sepRange.location];
		valueStr = [lineStr substringFromIndex: sepRange.location+1];
		[ueventDict setObject: valueStr forKey: keyStr];
	      }
	    [self _readLine :stateFile :line];
	    lineStr = [NSString stringWithCString: line];
	  }


        NSLog(@"%@", ueventDict);


        amps = [[ueventDict objectForKey:@"POWER_SUPPLY_CURRENT_NOW"] floatValue] / 1000000;
	volts = [[ueventDict objectForKey:@"POWER_SUPPLY_VOLTAGE_NOW"] floatValue] / 1000000;
	if ([ueventDict objectForKey:@"POWER_SUPPLY_POWER_NOW"] == nil)
	  watts = volts*amps;
	else
	  watts = [[ueventDict objectForKey:@"POWER_SUPPLY_POWER_NOW"] floatValue] / 1000000;


	if ([ueventDict objectForKey:@"POWER_SUPPLY_ENERGY_FULL_DESIGN"] != nil)
	  {
	    desCap = [[ueventDict objectForKey:@"POWER_SUPPLY_ENERGY_FULL_DESIGN"] floatValue] / 1000000;
	    lastCap = [[ueventDict objectForKey:@"POWER_SUPPLY_ENERGY_FULL"] floatValue] / 1000000;
	    currCap = [[ueventDict objectForKey:@"POWER_SUPPLY_ENERGY_NOW"] floatValue] / 1000000;
	  }
	else
	  {
            desCap = [[ueventDict objectForKey:@"POWER_SUPPLY_CHARGE_FULL_DESIGN"] floatValue] / 1000000;
	    lastCap = [[ueventDict objectForKey:@"POWER_SUPPLY_CHARGE_FULL"] floatValue] / 1000000;
	    currCap = [[ueventDict objectForKey:@"POWER_SUPPLY_CHARGE_NOW"] floatValue] / 1000000;
	    useWattHours = NO;
	  }
	warnCap = 0; //fixme

        chargeState = (NSString *)[ueventDict objectForKey:@"POWER_SUPPLY_STATUS"];
        batteryType = (NSString *)[ueventDict objectForKey:@"POWER_SUPPLY_TECHNOLOGY"];
	batteryManufacturer = (NSString *)[ueventDict objectForKey:@"POWER_SUPPLY_MANUFACTURER"];

        isCharging = NO;
        if ([chargeState isEqualToString:@"Charging"])
	  {
	    if (useWattHours)
	      {
	        if (amps > 0)
	          timeRemaining = (lastCap-currCap) / watts;
	        else
	          timeRemaining = -1;
	      }
	    else
	      {
	        if (watts > 0)
	          timeRemaining = (lastCap-currCap) / amps;
	        else
	          timeRemaining = -1;
	      }
	    chargePercent = currCap/lastCap*100;
	    isCharging = YES;
	  }
	else if ([chargeState isEqualToString:@"Discharging"])
	  {
	    if (useWattHours)
	      {
	        if (amps > 0)
	          timeRemaining = currCap / watts;
	        else
	          timeRemaining = -1;
	      }
	    else
	      {
	        if (watts > 0)
	          timeRemaining = currCap / amps;
	        else
	          timeRemaining = -1;
	      }
	    chargePercent = currCap/lastCap*100;
	  }
	else if ([chargeState isEqualToString:@"Charged"] || [chargeState isEqualToString:@"Full"])
	  {
	    chargePercent = 100;
	    timeRemaining = 0;
	    isCharging = YES;
	  }
	else if ([chargeState isEqualToString:@"Unknown"])
	  {
       	    timeRemaining = 0;
	    if (amps == 0)
	      {
		chargePercent = 100;
		isCharging = YES;
	      }
	  }
      }
    else if (useACPIproc)
      {
	stateFile = fopen(batteryStatePath0, "r");
	NSAssert(stateFile != NULL, @"ACPI - /proc: state file shall not be NULL");

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
	NSAssert(infoFile != NULL, @"ACPI - /proc: info file shall not be NULL");

	[self _readLine :infoFile :line];
	sscanf(line, "present: %s", present2Str);
	[self _readLine :infoFile :line];
	sscanf(line, "design capacity: %s", desCapStr);
	[self _readLine :infoFile :line];
	sscanf(line, "last full capacity: %s", lastCapStr);
	[self _readLine :infoFile :line]; // battery technology
	[self _readLine :infoFile :line]; // design voltage
	[self _readLine :infoFile :line]; // design capacity warning
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
	    isCharging = YES;
	  } else if (!strcmp(chStateStr, "charging"))
	  {
	    if (watts > 0)
	      timeRemaining = (lastCap-currCap) / watts;
	    else
	      timeRemaining = -1;
	    chargePercent = currCap/lastCap*100;
	    isCharging = YES;
	  } else
	  {
	    if (watts > 0)
	      timeRemaining = currCap / watts;
	    else
	      timeRemaining = -1;
	    chargePercent = currCap/lastCap*100;
	    isCharging = NO;
	  }
      }
    else if (useAPM)
      {
	char drvVersionStr[16];
	char apmBiosVersionStr[16];
	char apmBiosFlagsStr[16];
	char acLineStatusStr[16];
	char battStatusStr[16];
	int  battStatusInt;
	char battFlagsStr[16];
	char percentStr[16];
	char timeRemainingStr[16];
	char timeUnitStr[16];
	BOOL percentIsInvalid;

	percentIsInvalid = NO;
	stateFile = fopen(apmPath, "r");
	NSAssert(stateFile != NULL, @"APM - state file shall not be null");


	[self _readLine :stateFile :line];
	NSLog(@"line: %s", line);
	sscanf(line, "%s %s %s %s %s %s %s %s %s", drvVersionStr, apmBiosVersionStr, apmBiosFlagsStr, acLineStatusStr, battStatusStr, battFlagsStr, percentStr, timeRemainingStr, timeUnitStr);

	if (percentStr != NULL && strlen(percentStr) > 0)
	  {
	    if (percentStr[strlen(percentStr)-1] == '%')
	      percentStr[strlen(percentStr)-1] = '\0';
	    NSLog(@"%s %s %s", drvVersionStr, apmBiosVersionStr, percentStr);
    
	    chargePercent = (float)atof(percentStr);
	    if (chargePercent > 100)
	      chargePercent = 100;
	    if (chargePercent < 0)
	      {
		chargePercent = 0;
		percentIsInvalid = YES;
	      }
	    NSLog(@"percent %f", chargePercent);
	  }

	if (battStatusStr != NULL && strlen(battStatusStr) > 0)
	  {
	    if (battStatusStr[3] == '0')
	      battStatusInt = 0;
	    else if (battStatusStr[3] == '1')
	      battStatusInt = 1;
	    else if (battStatusStr[3] == '2')
	      battStatusInt = 2;
	    else if (battStatusStr[3] == '3')
	      battStatusInt = 3;
	    else if (battStatusStr[3] == '4')
	      battStatusInt = 4;
	    else
	      battStatusInt = -1;

	    isCharging = NO;
	    if (battStatusInt == 0)
	      chargeState = @"High";
	    else if (battStatusInt == 1)
	      chargeState = @"Low";
	    else if (battStatusInt == 2)
	      chargeState = @"Critical";
	    else if (battStatusInt == 3)
	      {
		chargeState = @"Charging";
		isCharging = YES;
	      } else if (battStatusInt == 4)
	      chargeState = @"Not present";
	    else
	      chargeState = @"Unknown";


	    if (percentIsInvalid)
	      {
		NSLog(@"Battery percent information is invalid.");

		if (battStatusInt == 0)
		  chargePercent = 75;
		else if (battStatusInt == 1)
		  chargePercent = 25;
		else if (battStatusInt == 2)
		  chargePercent = 5;
		else if (battStatusInt == 3)
		  chargePercent = 100;
		else if (battStatusInt == 4)
		  chargePercent = 0;
		else
		  chargePercent = 0;
	      }
	    NSLog(@"percent %f", chargePercent);
	  }
    
	fclose(stateFile);
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

- (NSString *)manufacturer
{
  return batteryManufacturer;
}

- (BOOL)isCritical
{
  if(useACPIsys || useACPIproc)
  {
    return  [self remainingCapacity] < [self warningCapacity];
  } else if (useAPM)
  {
    return[chargeState isEqualToString:@"Critical"];
  } else
    return NO;
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

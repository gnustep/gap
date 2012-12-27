/*

  Preferences.h
  Zipper

  Copyright (C) 2012 Free Software Foundation, Inc

  Authors: Dirk Olmes <dirk@xanthippe.ping.de>
           Riccardo Mottola <rm@gnu.org>

  This application is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details

 */

#import <Foundation/NSObject.h>

#define PREF_KEY_TAR @"TarExecutable"
#define PREF_KEY_ZIP @"ZipExecutable"
#define PREF_KEY_UNZIP @"UnzipExecutable"
#define PREF_KEY_SEVEN_ZIP @"7ZipExecutable"
#define PREF_KEY_RAR @"RarExecutable"
#define PREF_KEY_LHA @"LhaExecutable"
#define PREF_KEY_LZX @"LzxExecutable"
#define PREF_KEY_GZIP @"GzipExecutable"
#define PREF_KEY_GUNZIP @"GunzipExecutable"
#define PREF_KEY_BZIP2 @"Bzip2Executable"
#define PREF_KEY_BUNZIP2 @"Bunzip2Executable"
#define PREF_KEY_UNARJ @"UnarjExecutable"
#define PREF_KEY_UNACE @"UnaceExecutable"
#define PREF_KEY_ZOO @"ZooExecutable"
#define PREF_KEY_XZ @"XzExecutable"
#define PREF_KEY_BSD_TAR @"BSDTar"
#define PREF_KEY_OPEN_DIR @"LastOpenDirectory"
#define PREF_KEY_EXTRACT_DIR @"LastExtractDirectory"
#define PREF_KEY_DEFAULT_OPEN_APP @"DefaultOpenApp"

@interface Preferences : NSObject
{
}

+ (void)usePreferences:(NSDictionary *)newPrefs;

/**
 * Default accessors. These methods try to find the executable but return
 * <code>nil</code> if nothing could be found.
 */
+ (NSString *)tarExecutable;
+ (NSString *)zipExecutable;
+ (NSString *)unzipExecutable;
+ (NSString *)sevenZipExecutable;
+ (NSString *)rarExecutable;
+ (NSString *)lhaExecutable;
+ (NSString *)lzxExecutable;
+ (NSString *)gzipExecutable;
+ (NSString *)gunzipExecutable;
+ (NSString *)bzip2Executable;
+ (NSString *)bunzip2Executable;
+ (NSString *)unarjExecutable;
+ (NSString *)unaceExecutable;
+ (NSString *)zooExecutable;
+ (NSString *)xzExecutable;

/**
 * Setters for the various executables. All expect a full path to the executable and raise 
 * exceptions if a wrong value was specified.
 */
+ (void)setTarExecutable:(NSString *)newTar;
+ (void)setZipExecutable:(NSString *)newZip;
+ (void)setUnzipExecutable:(NSString *)newUnzip;
+ (void)setSevenZipExecutable:(NSString *)new7zip;
+ (void)setRarExecutable:(NSString *)newRar;
+ (void)setLhaExecutable:(NSString *)newLha;
+ (void)setLzxExecutable:(NSString *)newLzx;
+ (void)setGzipExecutable:(NSString *)newGzip;
+ (void)setGunzipExecutable:(NSString *)newGzip;
+ (void)setBzip2Executable:(NSString *)newGzip;
+ (void)setBunzip2Executable:(NSString *)newGzip;
+ (void)setUnarjExecutable:(NSString *)newGzip;
+ (void)setUnaceExecutable:(NSString *)newGzip;
+ (void)setZooExecutable:(NSString *)newGzip;
+ (void)setXzExecutable:(NSString *)newGzip;

+ (BOOL)isBsdTar;
+ (void)setIsBsdTar:(BOOL)flag;

+ (NSString *)lastOpenDirectory;
+ (void)setLastOpenDirectory:(NSString *)path;

+ (NSString *)lastExtractDirectory;
+ (void)setLastExtractDirectory:(NSString *)path;

+ (NSString *)compressionArgumentForFile:(NSString *)fileName;
+ (NSString *)defaultOpenApp;
+ (void)setDefaultOpenApp:(NSString *)path;

+ (void)save;
		
@end

#import <Foundation/Foundation.h>
#import "Preferences.h"
#import "NSFileManager+Custom.h"

#define X_MISSING_PREF @"MissingPreferenceException"
#define X_WRONG_PREF @"WrongPreferenceException"

@interface Preferences (PrivateAPI)
+ (NSString *)stringForKey:(NSString *)key;
+ (BOOL)boolForKey:(NSString *)key;
+ (void)checkExecutable:(NSString *)executable withName:(NSString *)name;
@end

/**
 * This class encapsulates the access to the app's preferences. It faciliates providing a
 * Dictionary that will be used instead of NSUserDefaults and searching the PATH environment
 * variable.
 */
@implementation Preferences : NSObject

/**
 * To faciliate unit testing it's possible to provide the Preferences class with an NSDictionary
 * that makes up the preferences.
 */
static NSDictionary *_replacementPrefs = nil;

/**
 * Additional Preferences loaded from PropertyList file
 */
static NSDictionary *_plistPrefs;

/**
 * This is the mapping between file extensions and tar's extract option. This option differs
 * from platform to platform. In order to encapsulate this, Preferences manages this mapping
 * and clients can ask for a compression argument with <code>compressionArgumentForFile:</code>
 */
static NSMutableDictionary *_extensionMapping = nil;

+ (void)initialize
{
	NSString *path;
	
	if (_extensionMapping == nil)
	{
		_extensionMapping = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
			@"", @"tar",
			@"-z", @"gz",
			@"-z", @"tgz",
			@"-j", @"bz2",
			nil] retain];
	}
	
	// see if there's a property list containing preferences to use
	path = [[NSBundle bundleForClass:self] pathForResource:@"DefaultPreferences" ofType:@"plist"];
	if (path != nil)
	{
		_plistPrefs = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
	}
}

+ (void)usePreferences:(NSDictionary *)newPrefs;
{
	ASSIGN(_replacementPrefs, newPrefs);
}

+ (NSString *)tarExecutable;
{
	NSString *tar = [self stringForKey:PREF_KEY_TAR];
	if (tar == nil)
	{
		// search the PATH
		tar = [[NSFileManager defaultManager] locateExecutable:@"tar"];
	}
	return tar;
}

+ (void)setTarExecutable:(NSString *)newTar
{
	if (newTar != nil)
	{
		[[NSUserDefaults standardUserDefaults] setObject:newTar forKey:PREF_KEY_TAR];
	}
}

+ (BOOL)isBsdTar;
{
	return [self boolForKey:PREF_KEY_BSD_TAR];
}

+ (void)setIsBsdTar:(BOOL)flag
{
	[[NSUserDefaults standardUserDefaults] setBool:flag forKey:PREF_KEY_BSD_TAR];
	if (flag == YES)
	{
		// on BSD tar also uses -z for extracting .bz archives
		[_extensionMapping setObject:@"-z" forKey:@"bz2"];
	}
	else
	{
		[_extensionMapping setObject:@"-j" forKey:@"bz2"];
	}
}

+ (NSString *)zipExecutable;
{
	NSString *zip = [self stringForKey:PREF_KEY_ZIP];
	if (zip == nil)
	{
		zip = [[NSFileManager defaultManager] locateExecutable:@"unzip"];
	}
	return zip;
}

+ (void)setZipExecutable:(NSString *)newZip
{
	if (newZip != nil)
	{
		[[NSUserDefaults standardUserDefaults] setObject:newZip forKey:PREF_KEY_ZIP];
	}
}

+ (NSString *)sevenZipExecutable;
{
	NSString *zip = [self stringForKey:PREF_KEY_SEVEN_ZIP];
	if (zip == nil)
	{
		zip = [[NSFileManager defaultManager] locateExecutable:@"7z"];

        // corner case: only 7za may be available on the system
        if (zip == nil)
        {
            zip = [[NSFileManager defaultManager] locateExecutable:@"7za"];
        }
	}
	return zip;
}

+ (void)setSevenZipExecutable:(NSString *)new7zip
{
	if (new7zip != nil)
	{
		[[NSUserDefaults standardUserDefaults] setObject:new7zip forKey:PREF_KEY_SEVEN_ZIP];
	}
}

+ (NSString *)rarExecutable;
{
	NSString *rar = [self stringForKey:PREF_KEY_RAR];
	if (rar == nil)
	{
		rar = [[NSFileManager defaultManager] locateExecutable:@"rar"];
	}
	return rar;
}

+ (void)setRarExecutable:(NSString *)newRar;
{
	if (newRar != nil)
	{
		[[NSUserDefaults standardUserDefaults] setObject:newRar forKey:PREF_KEY_RAR];
	}
}

+ (NSString *)lhaExecutable
{
	NSString *lha = [self stringForKey:PREF_KEY_LHA];
	if (lha == nil)
	{
		lha = [[NSFileManager defaultManager] locateExecutable:@"lha"];
	}
	return lha;
}

+ (void)setLhaExecutable:(NSString *)newLha;
{
	if (newLha != nil)
	{
		[[NSUserDefaults standardUserDefaults] setObject:newLha forKey:PREF_KEY_LHA];
	}
}

+ (NSString *)lzxExecutable
{
	NSString *lzx = [self stringForKey:PREF_KEY_LZX];
	if (lzx == nil)
	{
		lzx = [[NSFileManager defaultManager] locateExecutable:@"unlzx"];
	}
	return lzx;
}

+ (void)setLzxExecutable:(NSString *)newLzx;
{
	if (newLzx != nil)
	{
		[[NSUserDefaults standardUserDefaults] setObject:newLzx forKey:PREF_KEY_LZX];
	}
}

+ (NSString *)gzipExecutable
{
	NSString *gzip = [self stringForKey:PREF_KEY_GZIP];
	if (gzip == nil)
	{
		gzip = [[NSFileManager defaultManager] locateExecutable:@"gzip"];
	}
	return gzip;
}

+ (void)setGzipExecutable:(NSString *)newGzip
{
	if (newGzip != nil)
	{
		[[NSUserDefaults standardUserDefaults] setObject:newGzip forKey:PREF_KEY_GZIP];
	}
}

+ (NSString *)lastOpenDirectory
{
	return [self stringForKey:PREF_KEY_OPEN_DIR];
}

+ (void)setLastOpenDirectory:(NSString *)path;
{
	[[NSUserDefaults standardUserDefaults] setObject:path forKey:PREF_KEY_OPEN_DIR];
}

+ (NSString *)lastExtractDirectory;
{
	return [self stringForKey:PREF_KEY_EXTRACT_DIR];
}

+ (void)setLastExtractDirectory:(NSString *)path;
{
	[[NSUserDefaults standardUserDefaults] setObject:path forKey:PREF_KEY_EXTRACT_DIR];
}

+ (NSString *)compressionArgumentForFile:(NSString *)fileName
{
	if (fileName != nil)
	{
		return [_extensionMapping objectForKey:[fileName pathExtension]];
	}
	return nil;
}

/**
 * Returns the name of the app that will be used to open files that don't have a
 * pathExtension.
 */
+ (NSString *)defaultOpenApp;
{
	return [self stringForKey:PREF_KEY_DEFAULT_OPEN_APP];
}

+ (void)setDefaultOpenApp:(NSString *)path;
{
	[[NSUserDefaults standardUserDefaults] setObject:path forKey:PREF_KEY_DEFAULT_OPEN_APP];
}

+ (void)save
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

//------------------------------------------------------------------------------
// private API
//------------------------------------------------------------------------------
+ (NSString *)stringForKey:(NSString *)key;
{
	NSString *value;
	
	if (_replacementPrefs != nil)
	{
		return [_replacementPrefs objectForKey:key];
	}
	
	value = [[NSUserDefaults standardUserDefaults] stringForKey:key];
	if ((value == nil) && (_plistPrefs != nil))
	{
		value = [_plistPrefs objectForKey:key];
	}
	return value;
}

+ (BOOL)boolForKey:(NSString *)key
{
	if (_replacementPrefs != nil)
	{
		NSString *value = [_replacementPrefs objectForKey:key];
		return [value isEqual:@"YES"];
	}
	return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

@end

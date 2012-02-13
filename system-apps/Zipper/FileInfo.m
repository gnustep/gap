#import <Foundation/Foundation.h>
#import "FileInfo.h"
#import "NSString+Custom.h"

@interface FileInfo (PrivateAPI)
- (NSComparisonResult)negateComparisonResult:(NSComparisonResult)result;
- (void)extractFilenameAndPathFromString:(NSString *)string;
@end

@implementation FileInfo : NSObject

+ (FileInfo *)newWithPath:(NSString *)path date:(NSCalendarDate *)date size:(NSNumber *)size
{
	return [[[FileInfo alloc] initWithPath:path date:date size:size ratio:nil] autorelease];
}

+ (FileInfo *)newWithPath:(NSString *)path date:(NSCalendarDate *)date size:(NSNumber *)size 
	ratio:(NSString *)ratio;
{
	return [[[FileInfo alloc] initWithPath:path date:date size:size ratio:ratio] autorelease];
}

- (id)initWithPath:(NSString *)path date:(NSCalendarDate *)date size:(NSNumber *)size
	ratio:(NSString *)ratio
{
    [super init];
	
	[self extractFilenameAndPathFromString:path];
	ASSIGN(_date, date);
	ASSIGN(_size, size);
	ASSIGN(_ratio, ratio);
    return self;
}

- (void)dealloc
{
	[_path release];
	[_filename release];
	[_date release];
	[_size release];
	[_ratio release];
	[super dealloc];
}

- (void)extractFilenameAndPathFromString:(NSString *)string;
{
	NSScanner *scanner;
	NSString *path = string;
	
	// tar files can contain symlinks that have to be handled special
	if ([string containsString:@"->"])
	{
		NSScanner *scanner = [NSScanner scannerWithString:string];
		[scanner scanUpToString:@"->" intoString:&path];
	}

	_filename = [[path lastPathComponent] retain];
	// path is all that's before the filename
	scanner = [NSScanner scannerWithString:path];
	[scanner setCharactersToBeSkipped:nil];
	[scanner scanUpToString:_filename intoString:&_path];
	[_path retain];
}

- (NSString *)path
{
	return _path;
}

- (NSString *)filename
{
	return _filename;
}

- (NSString *)fullPath
{
	if ([self path] != nil)
	{
		return [[self path] stringByAppendingString:[self filename]];
	}
	return [self filename];
}

- (NSCalendarDate *)date
{
	return _date;
}

- (NSNumber *)size
{
	return _size;
}

- (NSString *)ratio;
{
	return _ratio;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: 0x%d '%@' '%@' %@ \"%@\">", [self class], self, 
		[self filename], [self path], [self size], [self date]];
}

//------------------------------------------------------------------------------
// compare methods
//------------------------------------------------------------------------------
- (NSComparisonResult)negateComparisonResult:(NSComparisonResult)result
{
	if (result == NSOrderedAscending)
	{
		return NSOrderedDescending;
	}
	else if (result == NSOrderedDescending)
	{
		return NSOrderedAscending;
	}
	return result;
}

- (NSComparisonResult)comparePathAscending:(id)other
{
	NSComparisonResult result = NSNotFound;
	
	if ([other isKindOfClass:[FileInfo class]])
	{
		if ([self path] == nil)
		{
			return NSOrderedAscending;
		}
		if ([other path] == nil)
		{
			// elements with no path should be listed first
			return NSOrderedDescending;		
		}
				
		// when comparing files by path, consider the filename also if the
		// paths are equal
		result = [[self path] compare:[other path]];
		if (result == NSOrderedSame)
		{
			result = [self compareFilenameAscending:other];
		}
		return result;
	}

	[NSException raise:@"CannotCompareException" 
		format:@"cannot compare a FileInfo instance with an instance of %@", [other class]];
	// this code is never reached, just shut up the compiler
	return NSNotFound;
}

- (NSComparisonResult)comparePathDescending:(id)other
{
	return [self negateComparisonResult:[self comparePathAscending:other]];	
}

- (NSComparisonResult)compareSizeAscending:(id)other
{
	if ([other isKindOfClass:[FileInfo class]])
	{
		return [[self size] compare:[other size]];
	}

	[NSException raise:@"CannotCompareException" 
		format:@"cannot compare a FileInfo instance with an instance of %@", [other class]];
	// this code is never reached, just shut up the compiler
	return NSNotFound;
}

- (NSComparisonResult)compareSizeDescending:(id)other
{
	return [self negateComparisonResult:[self compareSizeAscending:other]];
}

- (NSComparisonResult)compareFilenameAscending:(id)other
{
	if ([other isKindOfClass:[FileInfo class]])
	{
		// comare filenames case-insensitive to ensure absolute ordering by alphabet
		return [[self filename] compare:[other filename] options:NSCaseInsensitiveSearch];
	}
	
	[NSException raise:@"CannotCompareException" 
		format:@"cannot compare a FileInfo instance with an instance of %@", [other class]];
	// this code is never reached, just shut up the compiler
	return NSNotFound;	
}

- (NSComparisonResult)compareFilenameDescending:(id)other
{
	return [self negateComparisonResult:[self compareFilenameAscending:other]];
}

- (NSComparisonResult)compareDateAscending:(id)other
{
	if ([other isKindOfClass:[FileInfo class]])
	{
		return [[self date] compare:[other date]];
	}

	[NSException raise:@"CannotCompareException" 
		format:@"cannot compare a FileInfo instance with an instance of %@", [other class]];
	// this code is never reached, just shut up the compiler
	return NSNotFound;
}

- (NSComparisonResult)compareDateDescending:(id)other
{
	return [self negateComparisonResult:[self compareDateAscending:other]];
}

- (NSComparisonResult)compareRatioAscending:(id)other;
{
	if ([other isKindOfClass:[FileInfo class]])
	{
		return [[self ratio] compare:[other ratio]];
	}

	[NSException raise:@"CannotCompareException" 
		format:@"cannot compare a FileInfo instance with an instance of %@", [other class]];
	// this code is never reached, just shut up the compiler
	return NSNotFound;
}

- (NSComparisonResult)compareRatioDescending:(id)other;
{
	return [self negateComparisonResult:[self compareRatioAscending:other]];
}

@end

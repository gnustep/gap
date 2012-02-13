#import <Foundation/NSObject.h>

@class NSString, NSCalendarDate, NSNumber;

@interface FileInfo : NSObject
{
  @private
	NSString *_path;
	NSString *_filename;
    NSCalendarDate  *_date;
    NSNumber *_size;
	NSString *_ratio;
}

+ (FileInfo *)newWithPath:(NSString *)path date:(NSCalendarDate *)date size:(NSNumber *)size;
+ (FileInfo *)newWithPath:(NSString *)path date:(NSCalendarDate *)date size:(NSNumber *)size 
	ratio:(NSString *)ratio;

- (id)initWithPath:(NSString *)path date:(NSCalendarDate *)date size:(NSNumber *)size
	ratio:(NSString *)ratio;
- (NSString *)path;
// returns the complete path that's build from [self path] and [self filename]
- (NSString *)fullPath;
- (NSString *)filename;
- (NSCalendarDate *)date;
- (NSNumber *)size;
- (NSString *)ratio;

- (NSComparisonResult)comparePathAscending:(id)other;
- (NSComparisonResult)comparePathDescending:(id)other;
- (NSComparisonResult)compareSizeAscending:(id)other;
- (NSComparisonResult)compareSizeDescending:(id)other;
- (NSComparisonResult)compareFilenameAscending:(id)other;
- (NSComparisonResult)compareFilenameDescending:(id)other;
- (NSComparisonResult)compareDateAscending:(id)other;
- (NSComparisonResult)compareDateDescending:(id)other;
- (NSComparisonResult)compareRatioAscending:(id)other;
- (NSComparisonResult)compareRatioDescending:(id)other;

@end

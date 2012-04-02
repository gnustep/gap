// ADVCFConverter.h (this is -*- ObjC -*-)
// 
// Author: Björn Giesler <giesler@ira.uka.de>
// 
// Address Book Framework for GNUstep
// 



#import <Addresses/ADConverter.h>


@interface ADVCFConverter: NSObject<ADInputConverting,ADOutputConverting>
{
  NSString *_str;
  NSMutableString *_out;
  BOOL _input;
  int _idx;
}

/* ADInputConverting */
- initForInput;
- (BOOL) useString: (NSString*) str;
- (ADRecord*) nextRecord;

/* ADOutputConverting */
- initForOutput;
- (BOOL) canStoreMultipleRecords;
- (void) storeRecord: (ADRecord*) record;
- (NSString*) string;
@end


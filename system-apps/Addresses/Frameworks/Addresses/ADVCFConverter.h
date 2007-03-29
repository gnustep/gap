// ADVCFConverter.h (this is -*- ObjC -*-)
// 
// \author: Björn Giesler <giesler@ira.uka.de>
// 
// Address Book Framework for GNUstep
// 
// $Author: rmottola $
// $Locker:  $
// $Revision: 1.1 $
// $Date: 2007/03/29 22:36:04 $

#ifndef ADVCFCONVERTER_H
#define ADVCFCONVERTER_H

/* system includes */
#include <Addresses/ADConverter.h>

/* my includes */
/* (none) */

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

#endif /* ADVCFCONVERTER_H */

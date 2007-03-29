// ADPListConverter.h (this is -*- ObjC -*-)
// 
// \author: Björn Giesler <giesler@ira.uka.de>
// 
// Address Book Framework for GNUstep
// 
// $Author: rmottola $
// $Locker:  $
// $Revision: 1.1 $
// $Date: 2007/03/29 22:36:04 $

#ifndef ADPLISTCONVERTER_H
#define ADPLISTCONVERTER_H

/* system includes */
#include <Addresses/ADConverter.h>

/* my includes */
/* (none) */

@interface ADPListConverter: NSObject<ADInputConverting>
{
  BOOL _done;
  id _plist;
}
- initForInput;
- (BOOL) useString: (NSString*) str;
- (ADRecord*) nextRecord;
@end

#endif /* ADPLISTCONVERTER_H */

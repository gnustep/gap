// ADMultiValue.h (this is -*- ObjC -*-)
// 
// \author: Björn Giesler <giesler@ira.uka.de>
// 
// Address Book Framework for GNUstep
// 
// $Author: rmottola $
// $Locker:  $
// $Revision: 1.3 $
// $Date: 2012/03/26 16:50:28 $

#ifndef ADMULTIVALUE_H
#define ADMULTIVALUE_H

/* system includes */
#import <Foundation/Foundation.h>

/* my includes */
#include <Addresses/ADTypedefs.h>

@interface ADMultiValue : NSObject <NSCopying, NSMutableCopying>
{
  NSString *_primaryId;
  ADPropertyType _type;
  NSMutableArray *_arr;
}

- (NSUInteger) count;

- (id) valueAtIndex: (NSUInteger) index;
- (NSString*) labelAtIndex: (NSUInteger) index;
- (NSString*) identifierAtIndex: (NSUInteger) index;
    
- (NSUInteger) indexForIdentifier: (NSString*) identifier;

- (NSString*) primaryIdentifier;
    
- (ADPropertyType) propertyType;
@end

@interface ADMultiValue(AddressesExtensions)
- (id) initWithMultiValue: (ADMultiValue*) mv;
- (id) initWithType: (ADPropertyType) type;
- (NSArray*) contentArray;
@end

@interface ADMutableMultiValue: ADMultiValue
{
  int _nextId;
}

- (NSString*) addValue: (id) value
	     withLabel: (NSString*) label;
- (NSString *) insertValue: (id) value
		 withLabel: (NSString*) label
		   atIndex: (int) index;
- (BOOL) removeValueAndLabelAtIndex: (int) index;
- (BOOL) replaceValueAtIndex: (int) index
		   withValue: (id) value;    
- (BOOL) replaceLabelAtIndex: (int) index
		   withLabel: (NSString*) label;

- (BOOL)setPrimaryIdentifier:(NSString *)identifier;
@end

@interface ADMutableMultiValue(AddressesExtensions)
- (BOOL) addValue: (id) value
	withLabel: (NSString*) label
       identifier: (NSString*) identifier;
@end
#endif /* ADMULTIVALUE_H */

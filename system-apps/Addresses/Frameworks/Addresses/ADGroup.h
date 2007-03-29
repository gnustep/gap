// ADGroup.h (this is -*- ObjC -*-)
// 
// \author: Björn Giesler <giesler@ira.uka.de>
// 
// Address Book Framework for GNUstep
// 
// $Author: rmottola $
// $Locker:  $
// $Revision: 1.1 $
// $Date: 2007/03/29 22:36:04 $

#ifndef ADGROUP_H
#define ADGROUP_H

/* system includes */
#include <Addresses/ADRecord.h>
#include <Addresses/ADPerson.h>
#include <Addresses/ADTypedefs.h>
#include <Addresses/ADSearchElement.h>

/* my includes */
/* (none) */

@interface ADGroup: ADRecord
- (NSArray*) members;
- (BOOL) addMember: (ADPerson*) person;
- (BOOL) removeMember: (ADPerson*) person;

- (NSArray*) subgroups;
- (BOOL) addSubgroup: (ADGroup*) group;
- (BOOL) removeSubgroup: (ADGroup*) group;
- (NSArray*) parentGroups;

- (BOOL) setDistributionIdentifier: (NSString*) identifier
		       forProperty: (NSString*) property
			    person: (ADPerson*) person;
- (NSString*) distributionIdentifierForProperty: (NSString*) property
					 person: (ADPerson*) person;

+ (int) addPropertiesAndTypes: (NSDictionary*) properties;
+ (int) removeProperties: (NSArray*) properties;
+ (NSArray*) properties;
+ (ADPropertyType) typeOfProperty: (NSString*) property;

+ (ADSearchElement*) searchElementForProperty: (NSString*) property
				       label: (NSString*) label
					 key: (NSString*) key
				       value: (id) value
				  comparison: (ADSearchComparison) comparison;
@end

#endif /* ADGROUP_H */

// ADTypedefs.h (this is -*- ObjC -*-)
// 
// \author: Björn Giesler <giesler@ira.uka.de>
// 
// Address Book Framework for GNUstep
// 
// $Author: rmottola $
// $Locker:  $
// $Revision: 1.1 $
// $Date: 2007/03/29 22:36:04 $

#ifndef CTYPEDEFS_H
#define CTYPEDEFS_H

/* system includes */
/* (none) */

/* my includes */
/* (none) */

#define ADMultiValueMask        0x100

typedef enum {
  ADErrorInProperty           = 0x0,
  ADStringProperty            = 0x1,
  ADIntegerProperty           = 0x2,
  ADRealProperty              = 0x3, // NOT SUPPORTED!
  ADDateProperty              = 0x4,
  ADArrayProperty             = 0x5,
  ADDictionaryProperty        = 0x6,
  ADDataProperty              = 0x7,
  ADMultiStringProperty       = ADMultiValueMask | ADStringProperty,
  ADMultiIntegerProperty      = ADMultiValueMask | ADIntegerProperty,
  ADMultiRealProperty         = ADMultiValueMask | ADRealProperty,
  ADMultiDateProperty         = ADMultiValueMask | ADDateProperty,
  ADMultiArrayProperty        = ADMultiValueMask | ADArrayProperty,
  ADMultiDictionaryProperty   = ADMultiValueMask | ADDictionaryProperty,
  ADMultiDataProperty         = ADMultiValueMask | ADDataProperty
} ADPropertyType;

// ================================================================
//      Search APIs
// ================================================================

typedef enum {
  ADEqual,
  ADNotEqual,
  ADLessThan,
  ADLessThanOrEqual,
  ADGreaterThan,
  ADGreaterThanOrEqual,
  ADEqualCaseInsensitive,
  ADContainsSubString,
  ADContainsSubStringCaseInsensitive,
  ADPrefixMatch,
  ADPrefixMatchCaseInsensitive
} ADSearchComparison;

typedef enum {
  ADSearchAnd,
  ADSearchOr
} ADSearchConjunction;

typedef int ADImageTag;

typedef enum {
  ADScreenNameLastNameFirst = 0,
  ADScreenNameFirstNameFirst = 1
} ADScreenNameFormat; // EXTENSION

#endif /* CTYPEDEFS_H */

// ADEnvelopeAddressBook.h (this is -*- ObjC -*-)
// 
// \author: Björn Giesler <giesler@ira.uka.de>
// 
// Address Book Framework for GNUstep
// 
// $Author: rmottola $
// $Locker:  $
// $Revision: 1.1 $
// $Date: 2007/03/29 22:36:04 $

#ifndef ADENVELOPEADDRESSBOOK_H
#define ADENVELOPEADDRESSBOOK_H

/* system includes */
#include <Addresses/ADAddressBook.h>

/* my includes */
/* (none) */

@interface ADEnvelopeAddressBook: ADAddressBook
{
  NSMutableArray *_books;
  ADAddressBook *_primary;
  BOOL _merge;
}
  
+ (ADAddressBook*) sharedAddressBook;

- initWithPrimaryAddressBook: (ADAddressBook*) book;

- (BOOL) addAddressBook: (ADAddressBook*) book;
- (BOOL) removeAddressBook: (ADAddressBook*) book;

- (void) setPrimaryAddressBook: (ADAddressBook*) book;
- (ADAddressBook*) primaryAddressBook;
- (NSEnumerator*) addressBooksEnumerator;

- (void) setMergesAddressBooks: (BOOL) merge;
- (BOOL) mergesAddressBooks;
@end

#endif /* ADENVELOPEADDRESSBOOK_H */

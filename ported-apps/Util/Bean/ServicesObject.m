/*
 ServicesObject.m
 Bean
 
 Copyright (c) 2007 James Hoover
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "ServicesObject.h"
#import "MyDocument.h"

@implementation ServicesObject

static id sharedInstance = nil;

//singleton
+ (ServicesObject *)sharedInstance
{ 
	if (sharedInstance == nil) { 
		sharedInstance = [[self alloc] init];
	} 
	return sharedInstance; 
} 

- (id)init 
{
    if (sharedInstance) {
        [self dealloc];
    } else {
        sharedInstance = [super init];
    }
    return sharedInstance;
}

//this is based on Text Edit and Smultron! 25 May 2007 BH
- (void)openSelectionInBean:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error {
	BOOL success = NO;
	NSError *anError = nil;
	NSArray *types = nil;
	NSString *preferredType = nil;
	//[NSApp activateIgnoringOtherApps:YES];
	//opens a new document (whose id is returned as document)
	MyDocument *document = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:&anError];
	if (!document) {
		(void)NSRunAlertPanel(NSLocalizedString(@"Bean Service Failed.", @"alert title (indicating error during Open Selection service): Bean Service Failed"),
							  NSLocalizedString(@"\\U2018New Document Containing Selection\\U2019 failed because a new document could not be created.", @"alert text: 'New Document Containing Selection' failed because a new document could not be created."),
							  NSLocalizedString(@"OK", @"OK"), nil, nil);
	}
	if (anError) {
		NSLog(@"Bean Services failed to open a new Bean document.");
	} else {
		types = [pboard types];
		preferredType = [[document firstTextView] preferredPasteboardTypeFromArray:types restrictedToTypesFromArray:nil];
		if (preferredType) {
			//this retrieves text from pasteboard and inserts it into the newly opened Bean document
			success = [[document firstTextView] readSelectionFromPasteboard:pboard type:preferredType];
		}
		if (!success) {
			(void)NSRunAlertPanel(NSLocalizedString(@"'Open Selection' failed", @"alert title (when Bean Service supposed to open selected text in a new Bean document fails): 'Open Selection' failed."),
								  NSLocalizedString(@"The Bean Service \\U2018New Document Containing Selection\\U2019 failed.", @"alert text: The Bean Service 'New Document Selection' failed."),
								  NSLocalizedString(@"OK", @"OK"), nil, nil);
		}
	}
	document = nil;
	anError = nil;
	types = nil;
	preferredType = nil;
	return;	
}

/*
-(void)openSelectionInBean {
	NSError *anError = nil;
	MyDocument *document = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:&anError];
	[[document firstTextView] insertText:@"Hi matey!"];
}
*/


@end

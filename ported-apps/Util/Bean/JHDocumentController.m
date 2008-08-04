/* 
JHDocumentController.m
Bean

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

#import "JHDocumentController.h"

@implementation JHDocumentController

static JHDocumentController *sharedInstance = nil;

//	note: init stuff is from TextForge; wasn't sure how to subclass NSDocumentController//

+(JHDocumentController*)sharedInstance
{
	return sharedInstance ? sharedInstance : [[self alloc] init];
}

-(id)init
{
	if (sharedInstance)
	{
		[self dealloc];
	}
	else
	{
		sharedInstance = [super init];
	}
	return sharedInstance;
}

-(void)dealloc
{
	[super dealloc];
}

//	change the initial save type based on user default in the Preferences pane
- (NSString *)defaultType
{
	//	20 Aug 07 changed to work with localization JH
	//	subclassing NSDocumentController and adding this method means we do not have to use the undocumented NSDocument method changeSaveType, although that would have been easier 11 July 2007 BH
	//	we need non-localized file type name, which is used as the key to look up the extension for default file type in info.plist
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *type = nil;
	int formatIndex = nil;

	//	get index of default save format from popup in Preferences from user defaults
	formatIndex = [[defaults objectForKey:@"prefDefaultSaveFormatIndex"] intValue];
	//	get array of doc type dictionaries from info.plist in bundle
	NSArray *docTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDocumentTypes"];
	//	get doc type with matching index (list is populated from array in order of array in info.plist, so should work)
	id defaultDocType = [docTypes objectAtIndex:formatIndex];

	//	get the string name for the doc type from the dictionary for the doc type
	type = [defaultDocType objectForKey: @"CFBundleTypeName"];
	//	return the string of the doc type, which NSDocument uses as a key for the default save doc type
	if (type) { return type; }
	//	if there's a problem, get the super's default save type, which is always the first type in the info.plist file
	else { return [super defaultType]; }
}	

//	changes smart quotes style for all documents
-(IBAction)setSmartQuotesStyleInAllDocuments:(id)sender
{
	NSEnumerator *enumerator = [[self documents] objectEnumerator];
	id document;
	while (document = [enumerator nextObject])
	{
		[document setSmartQuotesStyleAction:nil];
	}
}

@end

/*
    This file is part of HelpViewer (http://www.roard.com/helpviewer)
    Copyright (C) 2003      Nicolas Roard (nicolas@roard.com)
                  2020-2024 Riccardo Mottola <rm@gnu.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the
    Free Software Foundation, Inc.  
    31 Milk Street #960789 Boston, MA 02196 USA
*/

#ifdef GNUSTEP
#import <GNUstepBase/GNUstep.h>
#else
#import "GNUstep.h"
#endif

#import <AppKit/NSCell.h> 

#import "mainWindowController.h"
#import "Section.h"

@implementation MainWindowController

- (id) initWithTextView: (NSTextView*) _text andBrowserView:(NSBrowser*) browser
{
  if ((self = [super init]))
    {
      resultTextView = [_text retain];
      resultOutlineView = [browser retain];

      [resultTextView setDelegate: self];
      [resultTextView setTextContainerInset: NSMakeSize (8,8)];
	
      [resultOutlineView setDelegate: self];
      [resultOutlineView setAllowsMultipleSelection: NO];
      [resultOutlineView setCellClass: [BrowserCell class]];
      [resultOutlineView setAction: @selector(browserClick:)];
      [resultOutlineView setTarget: self];
      //[resultOutlineView setDataSource: self];


      //handler = RETAIN ([XMLHandler new]);
      handler = [HandlerStructureXLP new];
	
      [handler setTextView: resultTextView];

      id TextFormatter = [[TextFormatterXLP alloc] init];
      [TextFormatter setTextView: resultTextView];
      [Section setTextFormatter: TextFormatter];
      [TextFormatter release];
    }
  return self;
}

- (void) print: (id) sender
{
  [[NSPrintOperation printOperationWithView: resultTextView] runOperation];
}

- (BOOL) loadFile: (NSString*) fileName 
{
  BOOL ret = NO;

  ASSIGN (handler, [HandlerStructureXLP new]);

  NSBundle* Bundle = [NSBundle bundleWithPath: fileName];
  [Section setBundle: Bundle];
  [handler setPath: [Bundle pathForResource: @"main" ofType: @"xlp"]];
  [handler parse];

/*
    string = [handler getPart: 0];
    Part* currentPage = [handler getPage: 0];

    if ([handler title] != nil)
    {
    	[window setTitle: [handler title]];
    }
    
    //NSLog (@"string : %@", string);
    //NSLog (@"currentPage : %@", currentPage);
    if ((string != nil) && (currentPage != nil))
    {
	[currentPage addSubviewsToView: resultTextView];
	[[resultTextView textStorage] setAttributedString: string];
	[resultOutlineView reloadData];
	ret = YES;
    }
    else 
    {
	NSLog (@"no parts !!!");
    }
 */
  NSLog (@"loadFile : %@", fileName);
  [resultOutlineView reloadColumn: 0];
  [resultOutlineView selectRow:0 inColumn:0];
  [self browserClick: resultOutlineView];
    
  return ret;
}

- (void) setWindow: (id) win
{
  window = win;
}


- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
  NSInteger ret = 0;

  if (column == 0) // First column
    {
      Section* section = [handler sections];
      ret = (NSInteger)[[section subs] count];
    }	
  else
    {
      id cell = [sender selectedCellInColumn: column -1];
      ret = (NSInteger)[[[(BrowserCell*)cell section] subs] count];
    }

  return ret;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
  Section* sub = nil;

  [cell setLeaf: YES];

  //NSLog (@"browser:willDisplayCell:atRow:%dcolumn:%d",row,column);

  if (column == 0) // First column
    {
      Section* section = [handler sections];
      sub = [[section subs] objectAtIndex: row];
    }
  else
    {
      BrowserCell *cell = [sender selectedCellInColumn: column -1];
      sub = [[[(BrowserCell*)cell section] subs] objectAtIndex: row];
    }

  if (sub != nil)
    {
      id subs = [sub subs];
      if ((subs != nil) && ([subs count] > 0))
	{
	  [cell setLeaf: NO];
	}
      [cell setSection: sub];
      [cell setStringValue: [sub header]];

      if ([sub loaded] == NO)
	{
	  //NSLog (@"not loaded : %@", [sub header]);
	  [cell setImage: [NSImage imageNamed: @"notloaded.tiff"]];
	  //[cell setLeaf: NO];
	  //[sub load];
	}
      else
	{
	  if (([sub type] == SECTION_TYPE_PLAIN)
	      || ([sub type] == SECTION_TYPE_CHAPTER))
	    {
	      //NSLog (@"chapter : %@", [sub header]);
	      [cell setImage: [NSImage imageNamed: @"chapter.tiff"]];
	    }
	  else if ([sub type] == SECTION_TYPE_PART)
	    {
	      //NSLog (@"chapter : %@", [sub header]);
	      [cell setImage: [NSImage imageNamed: @"part.tiff"]];
	    }
	}
		
      //NSLog (@"sub : %@", [sub header]);
    }
  else
    {
      //NSLog (@"sub == nil");
      [cell setStringValue: @"ERROR"];
    }
  //NSLog (@"fin de browser:willDisplayCell:atRow:%dcolumn:%d",row,column);
}

- (void) browserClick: (id) sender
{
  Section* sub = [(BrowserCell *)[sender selectedCell] section];

  if (sub != nil)
    {
      //NSLog (@"browserClick");
      if ([sub loaded] == NO)
	{
	  [sub load];
	  [resultOutlineView reloadColumn: [resultOutlineView lastColumn]];
	  [resultOutlineView selectRow: [resultOutlineView selectedRowInColumn: [resultOutlineView lastColumn]]
			      inColumn: [resultOutlineView lastColumn]];
	}
			
      if (([sub type] == SECTION_TYPE_PLAIN)
	  || ([sub type] == SECTION_TYPE_CHAPTER))
	{
	  // We have a "new" page, so we replace the entire text 
	  // NSLog (@"on a une nouvelle page ...");
	  id str = [sub contentWithLevel: 0];
	  // NSLog (@"on a recu : %@ et on va le mettre dans le textview", str);
	  [str retain];
	  [[resultTextView textStorage] setAttributedString: str];
	  [str release];
	}
      else if ([sub type] == SECTION_TYPE_NORMAL)
	{
	  // We should select the right position in the textview
	  // (ie, point the user to the right section)
	}
      [resultOutlineView reloadColumn: [resultOutlineView lastColumn]];
    }
  //NSLog (@"FIN browserClick");
}
		   
- (void) dealloc
{
  NSLog (@"=== dealloc mainWindowController ===");
  RELEASE ((NSObject*)handler);
  RELEASE (resultTextView);
  RELEASE (resultOutlineView);
  [super dealloc];
}

@end

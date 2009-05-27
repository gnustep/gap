/*
 *  GSPdf.m: Principal Class  
 *  of the GNUstep GSPdf application
 *
 *  Copyright (c) 2002-2009 GNUstep Application Project
 *  
 *  Author: Riccardo Mottola
 *  Copyright (c) 2002 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: August 2001
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GSPdf.h"
#import "PSDocument.h"
#import "GSPdfDocument.h"
#import "GSPdfDocWin.h"
#import "GSConsole.h"
#import "Functions.h"

#define MAXPAGES 9999
#define GHOSTVIEW_PATH_KEY @"GhostViewPath"

static GSPdf *gspdf = nil;

@implementation GSPdf

+ (void)initialize
{
  static BOOL initialized = NO;
	
  if (initialized == YES)
    {
      return;
    }
	
  initialized = YES;
}

+ (GSPdf *)gspdf
{
  if (gspdf == nil)
    {
      gspdf = [[GSPdf alloc] init];
    }	
  return gspdf;
}

- (void)dealloc
{
  RELEASE (documents);
  RELEASE (workPath);
  RELEASE (paperSizes);
  RELEASE (gsConsole);
  RELEASE (processId);

  [gvPath release];

  [super dealloc];
}

- (id)init
{
  self = [super init];

  if (self)
    {		
      processId = RETAIN([NSNumber numberWithInt: [[NSProcessInfo processInfo] processIdentifier]]);
      pageIdentifier = 0;
      documents = [[NSMutableArray alloc] initWithCapacity: 1];
      ASSIGN (workPath, NSHomeDirectory());
      gsConsole = [GSConsole new];
      nc = [NSNotificationCenter defaultCenter];
    }

  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSUserDefaults *defaults;
  NSString *gvPathStr;
  NSString *path = [[NSBundle mainBundle] pathForResource: @"papersizes" ofType: @"plist"];
  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];

  if (dict && [dict objectForKey: @"papersizes"])
    {
      NSArray *names;
      NSMenu *menu;
      int i;
		
      ASSIGN (paperSizes, [dict objectForKey: @"papersizes"]);
      names = [paperSizes allKeys];		
      menu = [[[NSApp mainMenu] itemWithTitle: NSLocalizedString(@"Document", @"")] submenu];
      menu = [[menu itemWithTitle: NSLocalizedString(@"Page Size", @"")] submenu];
		
      for (i = 0; i < [names count]; i++)
	{
	  addItemToMenu(menu, [names objectAtIndex: i], @"", @"setPaperSize:", @"");
	}

    }
  else
    {
      paperSizes = [NSDictionary new];
    }

  defaults = [NSUserDefaults standardUserDefaults];
  gvPathStr = [defaults stringForKey:GHOSTVIEW_PATH_KEY];
  if (gvPathStr == nil)
    gvPathStr = @"/usr/bin/gv";

  gvPath = [[NSString stringWithString:gvPathStr] retain];
}

- (BOOL)application:(NSApplication *)app openFile:(NSString *)filename
{
  return [self openDocumentForPath: filename];
}

- (BOOL)applicationShouldTerminate:(NSApplication *)app 
{
  int i;

  for (i = 0; i < [documents count]; i++)
    {
      GSPdfDocument *doc = [documents objectAtIndex: i];
      BOOL isPdf = [doc isPdf];
				
      [doc clearTempFiles];
		
      if (isPdf) {
	[[NSFileManager defaultManager] removeFileAtPath: [doc myPath] 
					handler: nil];		
      }
    }	

  return YES;
}

- (BOOL)openDocumentForPath:(NSString *)path
{
  GSPdfDocument *doc = [[GSPdfDocument alloc] initForPath: path];

  if (doc)
    {
      [documents addObject: doc];
      RELEASE (doc);
      ASSIGN (workPath, [path stringByDeletingLastPathComponent]);
      return YES;
    }	
  return NO;
}

- (void)openFile:(id)sender
{
  NSOpenPanel *openPanel;
  int result;

  openPanel = [NSOpenPanel openPanel];
  [openPanel setTitle: @"open"];	
  [openPanel setAllowsMultipleSelection: NO];
  [openPanel setCanChooseFiles: YES];
  [openPanel setCanChooseDirectories: NO];

  result = [openPanel runModalForDirectory: workPath file: nil 
		      types: [NSArray arrayWithObjects: @"ps", @"PS", @"eps", @"EPS", @"pdf", @"PDF", nil]];

  if(result != NSOKButton)
    {
      return;
    }
	
  [self openDocumentForPath: [openPanel filename]];
}

- (void)documentHasClosed:(GSPdfDocument *)doc
{
  [doc clearTempFiles];
  [documents removeObject: doc];
}

- (NSDictionary *)uniquePageIdentifier
{
  NSString *tempName = [NSString stringWithFormat: @"gspdf_%@_%i", [processId stringValue], pageIdentifier];	
  NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent: tempName];
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: 1];

  [dict setObject: [tempPath stringByAppendingPathExtension: @"ps"] forKey: @"pspath"];
  [dict setObject: [tempPath stringByAppendingPathExtension: @"tiff"] forKey: @"tiffpath"];
  [dict setObject: [tempPath stringByAppendingPathExtension: @"dsc"] forKey: @"dscpath"];

  pageIdentifier++;
  if (pageIdentifier >= MAXPAGES)
    {
      pageIdentifier = 0;
    }
	
  return dict;
}

- (NSDictionary *)paperSizes
{
  return paperSizes;
}

- (GSConsole *)console
{
  return gsConsole;
}

- (void)showConsole:(id)sender
{
  [[gsConsole window] orderFrontRegardless];
}

- (IBAction)showPrefPanel:(id)sender
{
  [gvPathField setStringValue:gvPath];
  [prefPanel makeKeyAndOrderFront:self];
}

- (IBAction)prefSave:(id)sender
{
  NSUserDefaults *defaults;
  NSString *gvPathStr;

  defaults = [NSUserDefaults standardUserDefaults];
  gvPathStr = [gvPathField stringValue];
  if (gvPathStr != nil)
    {
      [defaults setObject:gvPathStr forKey:GHOSTVIEW_PATH_KEY];
      gvPath = gvPathStr;
    }

  [prefPanel performClose:nil];
}

- (IBAction)prefCancel:(id)sender
{
  [prefPanel performClose:nil];
}

- (IBAction)chooseGVPath:(id)sender
{
  NSOpenPanel *openPanel;
  int result;

  openPanel = [NSOpenPanel openPanel];
  [openPanel setTitle: @"Select executable"];	
  [openPanel setAllowsMultipleSelection: NO];
  [openPanel setCanChooseFiles: YES];
  [openPanel setCanChooseDirectories: NO];

  result = [openPanel runModalForDirectory: workPath file: nil 
		      types: nil];

  if(result != NSOKButton)
    {
      return;
    }
  [gvPathField setStringValue:[openPanel filename]];
  NSLog(@"path %@", [openPanel filename]);
}

- (void)runInfoPanel:(id)sender
{
  [NSApp orderFrontStandardInfoPanel:self];
}

- (BOOL)windowShouldClose:(id)sender
{
  return YES;
}

- (NSString *)gvPath
{
  return gvPath;
}


@end

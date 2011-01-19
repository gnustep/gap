/*
 Project: Graphos
 GRDocument.m

 Copyright (C) 2000-2010 GNUstep Application Project

 Author: Enrico Sersale (original implementation)
 Author: Ing. Riccardo Mottola

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "GRDocument.h"

@implementation GRDocument

- (id)init
{
    [super init];
    if (self)
    {        
        docView = [[GRDocView alloc] initWithFrame: NSMakeRect(0,0,0,0)];
    }
    return self;
}

- (NSString *) windowNibName
{
    return @"GRDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    NSPrintInfo *p;

    [super windowControllerDidLoadNib:aController];
    if (aController == [[self windowControllers] objectAtIndex: 0])
    {
      NSScrollView *sv;
      NSClipView *cv;

      sv = [[[[aController window] contentView] subviews] objectAtIndex: 0];
      [sv setDocumentView: docView];
      cv = [sv contentView];
      [cv scrollToPoint: NSMakePoint(0, NSMaxY([docView bounds]))];
    }
    
    
    /* initialize the image view to the default size if possible */
    p = [self printInfo];
    if (p != nil)
        [docView updatePrintInfo: p];
    else
        NSLog(@"printInfo nil!");
    
    /* set undo levels */
    [[self undoManager] setLevelsOfUndo:1];

}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    return [[[docView objectDictionary] description] dataUsingEncoding: NSASCIIStringEncoding];
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    NSString *tmp = [[[NSString alloc] initWithData: data
                                           encoding: NSASCIIStringEncoding] autorelease];

    if( [aType isEqualToString: @"graphos design"] && tmp != nil )
    {
        if( [tmp rangeOfString: @"<?xml"].length > 0 )
        {
            tmp = [[[NSString alloc] initWithData: data
                                         encoding: NSUTF8StringEncoding] autorelease];
        }
        return [docView createObjectsFromDictionary: [tmp propertyList]];
    }
    return NO;
}

- (GRDocView *)docView
{
  return docView;
}


- (void)printShowingPrintPanel:(BOOL)flag
{
    NSPrintOperation *op;
    
    op = [NSPrintOperation printOperationWithView:docView
                                        printInfo:[self printInfo]];
    [op setShowPanels:flag];
    [op runOperationModalForWindow:[[[self windowControllers] objectAtIndex: 0] window]
                          delegate:nil
                    didRunSelector:NULL 
                       contextInfo:nil];    
}

/**
 * after the page layout is changed, update the view
 */
- (void)setPrintInfo:(NSPrintInfo *)printInfo
{
    [super setPrintInfo: printInfo];
    [docView updatePrintInfo: printInfo];
}

/**
 * overridden so to allow changing the page layout
 */
- (BOOL)shouldChangePrintInfo:(NSPrintInfo *)newPrintInfo
{
    return YES;
}
      
@end

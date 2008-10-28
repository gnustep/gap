//
//  FSInspection.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 30-JAN-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSInspection.m,v 1.1 2008/10/28 13:10:28 hns Exp $

#import "FlexiSheet.h"
#import "FSInspection.h"

@implementation FSDocument (FSInspectable)

- (NSString*)paneIdentifier
{
    return @"Document";
}

@end


@implementation FSWindowController (FSInspectable)

- (NSString*)paneIdentifier
{
    return @"View";
}

@end


@implementation FSTable (FSInspectable)

- (NSString*)paneIdentifier
{
    return @"Table";
}

@end


@implementation FSKeyGroup (FSInspectable)

- (NSString*)paneIdentifier
{
    return @"Item";
}

@end


@implementation FSKey (FSInspectable)

- (NSString*)paneIdentifier
{
    return @"Item";
}

@end


@implementation FSValue (FSInspectable)

- (NSString*)paneIdentifier
{
    return @"Value";
}

@end


@implementation FSSelection (InspectingAttributes)

- (NSString*)paneIdentifier
{
    return @"Cell";
}

@end


@implementation FSController (HeaderInspection)

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
    return 0; //[[[self currentDocument] headers] count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column
{
    [cell setLoaded:YES];
    [cell setLeaf:YES];
    //[cell setStringValue:[[[[self currentDocument] headers] objectAtIndex:row] name]];
}

@end

NSString* FSSelectionDidChangeNotification    = @"FSSelectionDidChange";
NSString* FSSelectionInfo                     = @"FSSelection";
NSString* FSWorksheetInfo                     = @"FSWorksheet";
NSString* FSTableviewInfo                     = @"FSTableview";
NSString* FSInspectorNeedsUpdateNotification  = @"FSInspectorNeedsUpdate";

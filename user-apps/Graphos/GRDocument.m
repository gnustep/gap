//
//  MyDocument.m
//  Draw
//
//  Created by Riccardo Mottola on Fri Aug 05 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#import "GRDocument.h"

@implementation GRDocument

- (id)init
{
    [super init];
    if (self)
    {
        NSLog(@"initing document");
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
    [super windowControllerDidLoadNib:aController];
    if (aController == [[self windowControllers] objectAtIndex: 0])
    {
        NSScrollView *sv = [[[[aController window] contentView] subviews] objectAtIndex: 0];
        [sv setDocumentView: docView];
    }
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    return [[[docView objectDictionary] description] dataUsingEncoding: NSASCIIStringEncoding];
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    NSString *tmp = [[[NSString alloc] initWithData: data
                                           encoding: NSASCIIStringEncoding] autorelease];

    if( [aType isEqualToString: @"gdr"] && tmp != nil )
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

@end

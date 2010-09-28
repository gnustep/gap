/*
 project: vespucci
 vedocumentcontroller.m

 copyright (c) 2008-2010

 author: Ing. Riccardo Mottola

 Created: 2008-01-23

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


#import "VEDocumentController.h"
#import "VEDocument.h"


@implementation VEDocumentController


- (id)openUntitledDocumentOfType:(NSString *)docType display:(BOOL)display
{
    VEDocument *doc;
    NSString *hp;

    doc = [super openUntitledDocumentOfType:docType display:display];
    hp = [doc homePage];
    if (hp != nil)
        [doc loadUrl:[NSURL URLWithString:hp]];
    return doc;
}

- (id)openDocumentWithContentsOfFile:(NSString *)fileName display:(BOOL)flag
{
    NSURL *url;

    if (!([fileName hasPrefix:@"http://"] || [fileName hasPrefix:@"https://"] || [fileName hasPrefix:@"file://"]))
      url = [NSURL fileURLWithPath: fileName];
    else
      url = [NSURL URLWithString:fileName];

    return [self openDocumentWithContentsOfURL: url display: flag];
} 

- (id)openDocumentWithContentsOfURL:(NSURL *)aURL display:(BOOL)flag
{
    VEDocument *doc;
    VEDocumentController *dc;
    NSArray *winArray;
    NSWindow *topWindow;

    NSLog(@"openDocWithURL: %@", [aURL absoluteURL]);
    
    /* check if there is a current document open which is empty and reuse it
        else create a new document */
    /* we use orderedWindows because orderedDocuments is not implemented in GNUstep */
    dc = [VEDocumentController sharedDocumentController];
    doc = nil;
    topWindow = nil;
    winArray = [[NSApplication sharedApplication] orderedWindows];
    if ([winArray count] > 0)
      topWindow = [winArray objectAtIndex:0];
    if (topWindow != nil)
        doc = [self documentForWindow:topWindow];
    NSLog(@"[openURL] current loaded url in document: %@", [doc loadedUrl]);
    if (doc != nil)
    {
        if (([doc loadedUrl] != nil) && [[doc loadedUrl] length] > 0)
            doc = [dc openUntitledDocumentOfType:@"HTML Document" display:YES];
    } else {
        doc = [dc openUntitledDocumentOfType:@"HTML Document" display:YES];
        NSAssert(doc != nil, @"openDocWithURL: document can't be nil here");
    }
    
    [doc  loadUrl:aURL];
    return doc;
}


@end

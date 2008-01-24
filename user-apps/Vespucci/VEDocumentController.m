/*
 Project: Vespucci
 VEDocumentController.m

 Copyright (C) 2008

 Author: Ing. Riccardo Mottola

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
    VEDocument *doc;
    NSString *urlStr;

    urlStr = [@"file://" stringByAppendingString:fileName];

    /* check if there is a current document open which is empty and reuse it
        else create a new document */
    doc = [self currentDocument];
    NSLog(@"current loaded url in document: %@", [doc loadedUrl]);
    if (doc != nil)
    {
        if (([doc loadedUrl] != nil) && [[doc loadedUrl] length] > 0)
            doc = [super openDocumentWithContentsOfFile:fileName display:flag];
    } else {
        doc = [super openDocumentWithContentsOfFile:fileName display:flag];
    }
    
    [doc  loadUrl:[NSURL URLWithString:urlStr]];
    return doc;
}


@end

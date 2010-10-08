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

- (BOOL) readFromURL: (NSURL*)url ofType: (NSString*)type
{
  VEDocument *doc;

  if (url != nil)
    {
      doc = [[VEDocument alloc] initWithContentsOfURL: url ofType:type error:nil];
      if (doc != nil)
	return YES;
    }
  return NO;
}

@end

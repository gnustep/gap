/*
 Project: Graphos
 GRTextEditor.h

 Copyright (C) 2000-2013 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
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


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GRText.h"
#import "GRTextEditorView.h"
#import "GRObjectEditor.h"

@interface GRTextEditor : GRObjectEditor
{
    NSWindow *myWindow;
    GRTextEditorView *myView;
    BOOL isSelect;
}

- (GRTextEditorView *)editorView;

- (void)setPoint:(NSPoint)p
    withString:(NSString *)string
    attributes:(NSDictionary *)attributes;

/** runs the editor window in a modal loop and gets the return value like an Alert Panel */
- (int)runModal;

@end

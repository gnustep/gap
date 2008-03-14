/*
 Project: Graphos
 GRPropsEditor.h

 Copyright (C) 2000-2008 GNUstep Application Project

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

@class GRDocView;

@interface GRPropsEditor : NSView
{
    GRDocView *docview;
    int result;

    NSButton *stkButt;
    NSTextField *stkLabel;
    NSTextField *stkCyanLabel, *stkMagentaLabel, *stkYellowLabel, *stkBlakLabel;
    NSTextField *stkCyanField, *stkMagentaField, *stkYellowField, *stkBlakField;
    NSButton *fllButt;
    NSTextField *fllLabel;
    NSTextField *fllCyanLabel, *fllMagentaLabel, *fllYellowLabel, *fllBlakLabel;
    NSTextField *fllCyanField, *fllMagentaField, *fllYellowField, *fllBlakField;

    NSTextField *lineCapLabel;
    NSMatrix* lineCapMatrix;
    NSTextField *lineJoinLabel;
    NSMatrix* lineJoinMatrix;
    NSButtonCell* buttonCell;

    NSTextField *flatnessLabel;
    NSTextField *flatnessField;
    NSTextField *miterlimitLabel;
    NSTextField *miterlimitField;
    NSTextField *linewidthLabel;
    NSTextField *linewidthField;

    NSButton *cancelButt, *okButt;

    NSRect strokeColorRect, fillColorRect;

    BOOL ispath;
    float flatness, miterlimit, linewidth;
    int linejoin, linecap;
    BOOL stroked;
    float strokecyan, strokemagenta, strokeyellow, strokeblack, strokealpha;
    BOOL filled;
    float fillcyan, fillmagenta, fillyellow, fillblack, fillalpha;
}

- (id)initWithFrame:(NSRect)frameRect
                              forDocView:(GRDocView *)aView
          objectProperties:(NSDictionary *)objprops;

- (int)runModal;

- (void)textFieldDidEndEditing:(NSNotification *)notification;

- (void)setLnJoin:(id)sender;

- (void)setLnJoin:(id)sender;

- (void)fllButtPressed:(id)sender;

- (void)stkButtPressed:(id)sender;

- (void)okCancelPressed:(id)sender;

- (NSDictionary *)properties;

@end

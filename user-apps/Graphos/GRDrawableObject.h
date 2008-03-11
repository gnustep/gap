/*
 Project: Graphos
 GRDrawableObject.h

 Copyright (C) 2008 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2008-02-25

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

/**
 * DrawableObject  is a superclass for every graphics object of Graphos.
 * It is abstract and created to standardize behaviour, it is not instantiatable itself.
 */

#import <Foundation/Foundation.h>

@class GRDocView;
@class GRObjectEditor;

@interface GRDrawableObject : NSObject
{
    GRDocView *docView;
    GRObjectEditor *editor;
    BOOL visible, locked;
}

/**
 * Returns a description of the object, used for saving to file.
 * This method must be overridden by each drawable object.
 */
- (NSDictionary *)objectDescription;

- (GRDrawableObject *)duplicate;

- (GRDocView *)view;
- (GRObjectEditor *)editor;

- (BOOL)visible;
- (void)setVisible:(BOOL)value;
- (BOOL)locked;
- (void)setLocked:(BOOL)value;

/**
 * Draws the object in the view. Called from GRDocView.
 * This method must be subclassed.
 */ 
- (void)draw;

@end

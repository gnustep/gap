/*
 *  GSPdf.h: Principal Class  
 *  of the GNUstep GSPdf application
 *
 *  Copyright (c) 2002 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: August 2002
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

#ifndef GSPDF_H
#define GSPDF_H

#include <Foundation/Foundation.h>

@class GSPdfDocument;
@class GSConsole;

@interface GSPdf : NSObject
{
	NSMutableArray *documents;
	NSNotificationCenter *nc;
	NSNumber *processId;
	int pageIdentifier;
	NSDictionary *paperSizes;
	NSString *workPath;
	GSConsole *gsConsole;
}

+ (GSPdf *)gspdf;

- (BOOL)openDocumentForPath:(NSString *)path;

- (void)openFile:(id)sender;

- (void)documentHasClosed:(GSPdfDocument *)doc;

- (NSDictionary *)uniquePageIdentifier;

- (NSDictionary *)paperSizes;

- (GSConsole *)console;

- (void)showConsole:(id)sender;

- (void)runInfoPanel:(id)sender;

@end

#endif // GSPDF_H

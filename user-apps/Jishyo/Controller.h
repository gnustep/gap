/*
	Controller.h - Controller interface for Jishyo.app
	Copyright (C) 2005, Rob Burns
	May 30, 2005

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02111, USA.
*/

#ifndef __JISHYO_CONTROLLER_H__
#define __JISHYO_CONTROLLER_H__

#include <AppKit/AppKit.h>

@class Dictionary;

@interface Controller : NSObject
{
	id 			searchButton;
	id 			searchField;
	id 			resultView;
	id 			typePopup;
	id			theWindow;

	Dictionary 	*_dict;
	NSString 	*_currentSearch;
	int			_searchType;
}

- (void) search: (id)sender;
- (void) searchTypeChanged: (id)sender;

- (id) handleSearchResult: (id)result;


@end

#endif // __JISHYO_CONTROLLER_H__

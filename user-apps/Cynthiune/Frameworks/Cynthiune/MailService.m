/* MailService.m - this file is part of Cynthiune
 *
 * Copyright (C) 2004 Wolfgang Sourdeau
 *
 * Author: Wolfgang Sourdeau <Wolfgang@Contre.COM>
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#import <AppKit/NSWorkspace.h>

#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>

#import "MailService.h"

@implementation MailService : NSObject

+ (id) instance
{
  static MailService *mailService = nil;

  if (!mailService)
    mailService = [MailService new];

  return mailService;
}

- (void) composeBugReport
{
  NSURL *mailtoURL;
  NSString *urlString;

  urlString =
    @"mailto:Wolfgang%20Sourdeau%20%3CWolfgang@Contre.COM%3E"
    @"?subject=[Cynthiune]%20bug%20report"
    @"&body="
    @"[replace%20this%20with%20a%20detailed%20description"
    @"%20of%20the%20problem,%20including%20the%20why's,%20the%20when's%20"
    @"and%20the%20how's.]"
    @"%0D%0D"
    @"[replace%20this%20with%20your%20system%20informations:%20operating"
    @"%20system%20version,%20windowing%20environment,%20CPU,%20RAM,%20...]";

  mailtoURL = [NSURL URLWithString: urlString];
  [[NSWorkspace sharedWorkspace] openURL: mailtoURL];
}

@end

/* BundleManager.m - this file is part of Cynthiune
 *
 * Copyright (C) 2005 Wolfgang Sourdeau
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

#import <Foundation/NSArray.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSPathUtilities.h>

#import <Cynthiune/CynthiuneBundle.h>
#import <Cynthiune/Format.h>
#import <Cynthiune/Output.h>
#import <Cynthiune/Preference.h>
#import <Cynthiune/utils.h>

#import "FormatTester.h"
#import "GeneralPreference.h"
#import "PreferencesController.h"

#import "BundleManager.h"

static NSNotificationCenter *nc = nil;

@implementation BundleManager : NSObject

+ (void) initialize
{
  nc = [NSNotificationCenter defaultCenter];
}

+ (BundleManager *) bundleManager
{
  static BundleManager *bundleManager = nil;

  if (!bundleManager)
    bundleManager = [BundleManager new];

  return bundleManager;
}

// - (id) init
// {
//   if ((self = [super init]))
//     {
//       bundles = [NSMutableArray new];
//     }

//   return self;
// }

// - (void) dealloc
// {
//   [bundles release];
//   [super dealloc];
// }

- (void) _registerClass: (Class) class
{
  PreferencesController *preferencesController;
  FormatTester *formatTester;
  GeneralPreference *generalPreference;

  preferencesController = [PreferencesController preferencesController];
  formatTester = [FormatTester formatTester];
  generalPreference = [GeneralPreference instance];

  if ([class conformsToProtocol: @protocol(Preference)])
    [preferencesController registerPreferenceClass: class];
  if ([class conformsToProtocol: @protocol(Format)])
    [formatTester registerFormatClass: class];
  if ([class conformsToProtocol: @protocol(Output)])
    [generalPreference registerOutputClass: class];
//   if ([class conformsToProtocol: @protocol(Metadata)])
//     [self registerMetadataClass: class];
}

- (void) loadBundlesForPath: (NSString *) path
            withFileManager: (NSFileManager *) fileManager
{
  NSEnumerator *files;
  NSString *file, *bundlePath;
  NSBundle *bundle;

  files = [[fileManager directoryContentsAtPath: path] objectEnumerator];
  file = [files nextObject];

  while (file)
    {
      bundlePath = [path stringByAppendingPathComponent: file];
      bundle = [NSBundle bundleWithPath: bundlePath];
      if (bundle)
        {
          [nc addObserver: self
              selector: @selector (bundleDidLoad:)
              name: NSBundleDidLoadNotification
              object: bundle];
          [bundle load];
        }
      file = [files nextObject];
    }
}

- (void) bundleDidLoad: (NSNotification *) notification
{
  NSDictionary *dictionary;
  NSEnumerator *classNames;
  NSString *className;

  dictionary = [notification userInfo];
  classNames = [[dictionary objectForKey: NSLoadedClasses] objectEnumerator];

  className = [classNames nextObject];
  while (className)
    {
      [self _registerClass: NSClassFromString (className)];
      className = [classNames nextObject];
    }

  [nc removeObserver: self
      name: NSBundleDidLoadNotification
      object: [notification object]];
}

- (void) loadBundlesInSystemDirectories: (NSFileManager *) fileManager
{
  NSEnumerator *paths;
  NSString *path;

  paths = [NSStandardLibraryPaths () objectEnumerator];
  path = [paths nextObject];
  while (path)
    {
      [self loadBundlesForPath:
              [path stringByAppendingPathComponent: @"Cynthiune"]
            withFileManager: fileManager];
      path = [paths nextObject];
    }
}

#if defined (GNUSTEP) && defined (LOCALBUILD)

/* GNUstep */
- (void) loadBundlesInLocalDirectory: (NSFileManager *) fileManager
{
  NSString *sourceDir, *extBundlesDir, *file;
  NSEnumerator *files;
  NSArray *allFiles;

  sourceDir = [[[NSBundle mainBundle] bundlePath]
                stringByDeletingLastPathComponent];

  extBundlesDir = [sourceDir stringByAppendingPathComponent: @"Bundles"];
  allFiles = [fileManager directoryContentsAtPath: extBundlesDir];
  files = [allFiles objectEnumerator];

  file = [files nextObject];
  while (file)
    {
      [self loadBundlesForPath:
              [extBundlesDir stringByAppendingPathComponent: file]
            withFileManager: fileManager];
      file = [files nextObject];
    }
}

#endif /* GNUSTEP && LOCALBUILD */

- (void) loadBundles
{
  NSFileManager *fileManager;

  fileManager = [NSFileManager defaultManager];

#ifdef GNUSTEP
#ifdef LOCALBUILD
  [self loadBundlesInLocalDirectory: fileManager];
#endif /* LOCALBUILD */
#else
  [self loadBundlesForPath: [[NSBundle mainBundle] builtInPlugInsPath]
        withFileManager: fileManager];
#endif /* GNUSTEP */
  [self loadBundlesInSystemDirectories: fileManager];
}

@end

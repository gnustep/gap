//
//  fileElement.h
//  FTP
//
//  Created by Riccardo Mottola on Mon Apr 18 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
       
#import <Foundation/Foundation.h>



@interface fileElement : NSObject {
    NSString *filename;
    BOOL isDir;
    long int size;
    int year;
    int month;
    int day;
    int hour;
    int min;
}

- (id)initWithFileStats :(char *)fname :(struct stat)fSt;
- (id)initWithLsLine :(char *)line;
- (NSString *)filename;
- (BOOL)isDir;
- (long int) size;
- (int) year;
- (int) month;
- (int) day;
- (int) hour;
- (int) min;

@end

/* Copyright 1991, 1994, 1997 Scott Hess.  Permission to use, copy, modify,
 * and distribute this software and its documentation for any purpose
 * and without fee is hereby granted, provided that this copyright
 * notice appear in all copies.  The copyright notice need not appear
 * on binary-only distributions - just in source code.
 * 
 * Scott Hess makes no representations about the suitability of this
 * software for any purpose.  It is provided "as is" without express
 * or implied warranty.
 */
#ifdef __APPLE_CPP__
#import <sys/dkstat.h>
#else
#ifndef GNUSTEP
#import <sys/dk.h>
#endif
#endif

#ifdef GNUSTEP
#define CPUSTATES 4
#define CP_SYS 0
#define CP_USER 1
#define CP_NICE 2
#endif

/* These codes are returned from la_init() and la_read(). */
enum la_error {
    LA_NOERR,		/* No problem. */
    LA_NLIST,		/* Couldn't nlist /mach. */
    LA_PERM,		/* No permissions for /dev/kmem. */
    LA_KMEM,		/* Couldn't open kmem. */
    LA_SEEK,		/* Couldn't seek in kmem. */
    LA_READ,		/* Couldn't read from kmem. */
    LA_TABLE,		/* table() call failed. */
};

/* Get ready for operation and retrieve the current times. */
int la_init( long *times);

/* Retrieve the current times. */
int la_read( long *times);

/* Close up anything that's open. */
void la_finish( void);

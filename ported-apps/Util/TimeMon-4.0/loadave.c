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
/* Get the current load average from the kernel.  Uses the undocumented
 * (and nearly non-existant in NS3.0) table() call if available.
 * Otherwise, is capable of falling back to direct /dev/kmem reading
 * if KMEM is defined (note that this requires the program to run
 * setgid to group kmem).
 */
#import "loadave.h"

    /* Preliminary gunk the routines want to see. */
#ifdef KMEM
    #import <libc.h>
    #import <nlist.h>
    #import <grp.h>
    static struct nlist nl[]={
	{{"_cp_time"}, 0, 0, 0, 0}, {{""}, 0, 0, 0, 0}
    };
    int kmem;			/* File descriptor for /dev/kmem. */
#else
    #import <strings.h>
    #ifndef GNUSTEP
        #if 0
	#import <sys/table.h>
        #else
	/* NS3.0 doesn't include the <sys/table.h> file.  Sigh.
	 * So, I've snarfed the following without permission from
	 * <sys/table.h> on an NS2.1 system.  The structure, prototype,
	 * and #define could also likely be found in Mach documentation
	 * somewhere.
	 */
	#define TBL_CPUINFO		12	/* (no index), generic CPU info */
	/*
	 * TBL_CPUINFO data layout
	 */
	struct tbl_cpuinfo
	{
	    int		ci_swtch;		/* # context switches */
	    int		ci_intr;		/* # interrupts */
	    int		ci_syscall;		/* # system calls */
	    int		ci_traps;		/* # system traps */
	    int		ci_hz;			/* # ticks per second */
	    int		ci_phz;			/* profiling hz */
	    int		ci_cptime[CPUSTATES];	/* cpu state times */
	};
        #endif
    #endif
    extern int table( int, int, void *, int, int);
#endif

    /* Initialize the package and return the current CPU time values. */
int la_init( long *times)
{
#ifdef KMEM
	/* For reading kmem, have to poke through /mach to find
	 * locations for cp_time, and then open the kmem device for
	 * reading.
	 */
    if( nlist( "/mach", nl)) {
	return LA_NLIST;
    }
    if( (kmem=open( "/dev/kmem", O_RDONLY))<0) {
	gid_t gid=getegid();
	struct group *kmemgr=getgrnam( "kmem");
	if( kmemgr->gr_gid!=gid) {
	    return LA_PERM;
	} else {
	    return LA_KMEM;
	}
    }
#endif
    return la_read( times);
}

    /* Return the current CPU time values. */
int la_read( long *times)
{
#ifndef GNUSTEP
#ifdef KMEM
	/* Seek in kmem to the location of cp_time. */
    if( lseek( kmem, nl[ 0].n_value, L_SET)!=nl[ 0].n_value) {
	return LA_SEEK;
    }
    
	/* Read the values for cp_time. */
    if( read( kmem, times, sizeof( long)*CPUSTATES)!=sizeof( long)*CPUSTATES) {
	return LA_READ;
    }
#else
	/* The table() version is a bit simpler - just ask table()
	 * for the appropriate values.
	 */
    struct tbl_cpuinfo tc;
    if( table( TBL_CPUINFO, 0, &tc, 1, sizeof( tc))>=0) {
	bcopy( tc.ci_cptime, times, sizeof( long)*CPUSTATES);
    } else {
	return LA_TABLE;
    }
#endif
#endif
    return LA_NOERR;
}

    /* Clean up after ourselves. */
void la_finish( void)
{
#ifndef GNUSTEP
#ifdef KMEM
	/* Close up kmem and nuke the fd. */
    if( kmem>-1) {
	close( kmem);
	kmem=-1;
    }
#endif
#endif
}

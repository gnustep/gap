#include "loadave.h"

#include <stdio.h>

int la_init(unsigned long long *times)
{
  return la_read(times);
}

#if defined( linux )

int la_read(unsigned long long *times)
{
  int i;
  unsigned long long c_idle,c_sys,c_nice,c_iow,c_user,c_xxx,c_yyy;
  FILE *f=fopen("/proc/stat","rt");
  if (!f)
    return LA_ERROR;
  i=fscanf(f,"cpu %Lu %Lu %Lu %Lu %Lu %Lu %Lu\n",
    &c_user,&c_nice,&c_sys,&c_idle,&c_iow,&c_xxx,&c_yyy);
  if (i<4)
    return LA_ERROR;
  if (i<5)
    c_iow=0;
  fclose(f);
  times[CP_IDLE] = c_idle;
  times[CP_SYS] = c_sys;
  times[CP_NICE] = c_nice;
  times[CP_USER] = c_user;
  times[CP_IOWAIT] = c_iow;
  return LA_NOERR;
}

#elif defined( freebsd )

#include <sys/types.h>
#include <sys/errno.h>
#include <sys/resource.h>	// CPUSTATES
#include <sys/sysctl.h>		// sysctlbyname()
          
int la_read(unsigned long long *times)
{
  const char
    *name = "kern.cp_time";
  int
    cpu_states[CPUSTATES];
  size_t
    nlen = sizeof cpu_states,
    len = nlen;
  int
    err;
  
  err= sysctlbyname(name, &cpu_states, &nlen, NULL, 0);
  if( -1 == err )
  {
    fprintf(stderr, "sysctl(%s...) failed: %s\n", name, strerror(errno));
    exit(errno);
  }
  if( nlen != len )
  {
    fprintf(stderr, "sysctl(%s...) expected %lu, got %lu\n",
                    name, (unsigned long) len, (unsigned long) nlen);
    exit(errno);
  }
  times[CP_IDLE] = cpu_states[4];
  times[CP_SYS] = cpu_states[2];
  times[CP_NICE] = cpu_states[1];
  times[CP_USER] = cpu_states[0];
  times[CP_IOWAIT] = cpu_states[3];
  
  return LA_NOERR;
}

#else

#error Do not know how to retrieve CPU statistics on this platform.

#endif

void la_finish(void)
{
}

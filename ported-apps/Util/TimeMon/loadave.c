#include "loadave.h"

#include <stdio.h>

int la_init(unsigned long long *times)
{
  return la_read(times);
}

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

void la_finish(void)
{
}


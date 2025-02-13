dnl Process this file with autoconf to produce a configure script.
dnl Copyright 1998-2013 Glyph & Cog, LLC

AC_PREREQ([2.72])

AC_INIT
AC_CONFIG_SRCDIR([xpdf/Gfx.cc])
AC_CONFIG_HEADERS([aconf.h])

dnl ##### Optional features.

AC_ARG_ENABLE([a4-paper],
  AS_HELP_STRING([--enable-a4-paper],
                 [use A4 paper size instead of Letter for PostScript output]))
AS_IF([test "x$enable_a4_paper" = "xyes"],
      [AC_DEFINE([A4_PAPER], [], [A4 Paper])])

AC_ARG_ENABLE([no-text-select],
  AS_HELP_STRING([--enable-no-text-select],
                 [do not allow text selection]))
AS_IF([test "x$enable_no_text_select" = "xyes"],
      [AC_DEFINE([NO_TEXT_SELECT], [], [No Text Select])])

AC_ARG_ENABLE([opi],
  AS_HELP_STRING([--enable-opi],
                 [include support for OPI comments]))
AS_IF([test "x$enable_opi" = "xyes"],
      [AC_DEFINE([OPI_SUPPORT], [], [OPI Support])])

AC_ARG_ENABLE([multithreaded],
  AS_HELP_STRING([--enable-multithreaded],
                 [include support for multithreading]))
AS_IF([test "x$enable_multithreaded" = "xyes"],
      [AC_DEFINE([MULTITHREADED], [], [Multithreaded])])

AC_ARG_ENABLE([exceptions],
  AS_HELP_STRING([--enable-exceptions],
                 [use C++ exceptions]))
AS_IF([test "x$enable_exceptions" = "xyes"],
      [AC_DEFINE([USE_EXCEPTIONS], [], [Exceptions])])

AC_ARG_ENABLE([fixedpoint],
  AS_HELP_STRING([--enable-fixedpoint],
                 [use fixed point (instead of floating point) arithmetic]))
AS_IF([test "x$enable_fixedpoint" = "xyes"],
      [AC_DEFINE([USE_FIXEDPOINT], [], [Fixed point])])

AC_ARG_ENABLE([cmyk],
  AS_HELP_STRING([--enable-cmyk],
                 [include support for CMYK rasterization]))
AS_IF([test "x$enable_cmyk" = "xyes"],
      [AC_DEFINE([SPLASH_CMYK], [], [Splash CMYK])])

AC_ARG_WITH([appdef-dir],
  AS_HELP_STRING([--with-appdef-dir],
                 [set app-defaults directory]))
AS_IF([test "x$with_appdef_dir" != "xno"],
      [AC_DEFINE_UNQUOTED(APPDEFDIR, "$with_appdef_dir")])

dnl ##### Path to xpdfrc.
dnl This ugly kludge to get the sysconfdir path is needed because
dnl autoconf doesn't actually set the prefix variable until later.
if test "$sysconfdir" = '${prefix}/etc'; then
  if test "x$prefix" = xNONE; then
    system_xpdfrc="$ac_default_prefix/etc/xpdfrc"
  else
    system_xpdfrc="$prefix/etc/xpdfrc"
  fi
else
  system_xpdfrc="$sysconfdir/xpdfrc"
fi
AC_DEFINE_UNQUOTED(SYSTEM_XPDFRC, "$system_xpdfrc")

dnl ##### Checks for programs.
AC_PROG_CC
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_RANLIB

dnl ##### Default values for Unix.
EXE=""
LIBPREFIX="lib"
AR="ar rc"
UP_DIR=""

dnl ##### Do substitutions.
AC_SUBST(EXE)
AC_SUBST(LIBPREFIX)
AC_SUBST(AR)
AC_SUBST(UP_DIR)

dnl ##### Checks for header files.
AC_PATH_XTRA
AC_HEADER_DIRENT

dnl ##### Switch over to C++.  This will make the checks below a little
dnl ##### bit stricter (requiring function prototypes in include files).
dnl ##### (99% of xpdf is written in C++.)
AC_LANG([C++])

dnl ##### Check for extra libraries needed by X.  (LynxOS needs this.)
AC_CHECK_FUNC(gethostbyname)
if test $ac_cv_func_gethostbyname = no; then
  AC_CHECK_LIB(bsd, gethostbyname, X_EXTRA_LIBS="$X_EXTRA_LIBS -lbsd")
fi

dnl ##### Look for header that defines select() and fd_set.
AC_MSG_CHECKING([select() and fd_set in sys/select.h and sys/bsdtypes.h])
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <stdlib.h>
#include <stddef.h>
#include <unistd.h>
#include <sys/types.h>]], [[fd_set fds;
select(0, NULL, NULL, NULL, NULL);]])],[xpdf_ok=yes],[xpdf_ok=no])
if test $xpdf_ok = yes; then
  AC_MSG_RESULT([not needed])
else
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <stdlib.h>
#include <stddef.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/select.h>]], [[fd_set fds;
select(0, NULL, NULL, NULL, NULL);]])],[xpdf_ok=yes],[xpdf_ok=no])
  if test $xpdf_ok = yes; then
    AC_DEFINE(HAVE_SYS_SELECT_H)
    AC_MSG_RESULT([need sys/select.h])
  else
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <stdlib.h>
#include <stddef.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/bsdtypes.h>]], [[fd_set fds;
select(0, NULL, NULL, NULL, NULL);]])],[xpdf_ok=yes],[xpdf_ok=no])
    if test $xpdf_ok = yes; then
      AC_DEFINE(HAVE_SYS_BSDTYPES_H)
      AC_MSG_RESULT([need sys/bsdtypes.h])
    else
      AC_MSG_RESULT([problem])
    fi
  fi
fi

dnl ##### Look for header that defines FD_ZERO.
AC_MSG_CHECKING([FD_ZERO and strings.h or bstring.h])
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <stdlib.h>
#include <sys/types.h>
#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif]], [[fd_set fds; FD_ZERO(&fds);]])],[xpdf_ok=yes],[xpdf_ok=no])
if test $xpdf_ok = yes; then
  AC_MSG_RESULT([not needed])
else
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <stdlib.h>
#include <sys/types.h>
#include <strings.h>
#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif]], [[fd_set fds; FD_ZERO(&fds);]])],[xpdf_ok=yes],[xpdf_ok=no])
  if test $xpdf_ok = yes; then
    AC_DEFINE(HAVE_STRINGS_H)
    AC_MSG_RESULT([need strings.h])
  else
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <stdlib.h>
#include <sys/types.h>
#include <bstring.h>
#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif]], [[fd_set fds; FD_ZERO(&fds);]])],[xpdf_ok=yes],[xpdf_ok=no])
    if test $xpdf_ok = yes; then
      AC_DEFINE([HAVE_BSTRING_H], [], [have bstring.h])
      AC_MSG_RESULT([need bstring.h])
    else
      AC_MSG_RESULT([problem])
    fi
  fi
fi

dnl ##### Look for rewinddir.
AC_CHECK_FUNCS(rewinddir)
if test $ac_cv_func_rewinddir = no; then
  AC_CHECK_LIB(cposix, rewinddir)
fi

dnl ##### Checks for library functions.
AC_CHECK_FUNCS(popen)
dnl # This should use 'AC_CHECK_FUNCS(mkstemp)' but that fails if
dnl # the mkstemp exists in the library but isn't declared in the
dnl # include file (e.g., in cygwin 1.1.2).
AC_CACHE_CHECK([for mkstemp],
xpdf_cv_func_mkstemp,
[AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <stdlib.h>
#include <unistd.h>]], [[mkstemp("foo");]])],[xpdf_cv_func_mkstemp=yes],[xpdf_cv_func_mkstemp=no])])
if test "$xpdf_cv_func_mkstemp" = yes; then
  AC_DEFINE(HAVE_MKSTEMP)
fi
dnl # Check for mkstemps, just like mkstemp.
AC_CACHE_CHECK([for mkstemps],
xpdf_cv_func_mkstemps,
[AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <stdlib.h>
#include <unistd.h>]], [[mkstemps("foo", 0);]])],[xpdf_cv_func_mkstemps=yes],[xpdf_cv_func_mkstemps=no])])
if test "$xpdf_cv_func_mkstemps" = yes; then
  AC_DEFINE(HAVE_MKSTEMPS)
fi

dnl ##### Check select argument type: on HP-UX before version 10, select
dnl ##### takes (int *) instead of (fd_set *).
AC_CACHE_CHECK([whether select takes fd_set arguments],
xpdf_cv_func_select_arg,
[AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <sys/types.h>
#include <sys/time.h>
#include <unistd.h>
#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif]], [[fd_set fds;
select(1, &fds, &fds, &fds, 0);]])],[xpdf_cv_func_select_arg=yes],[xpdf_cv_func_select_arg=no])])
if test "$xpdf_cv_func_select_arg" != yes; then
  AC_DEFINE(SELECT_TAKES_INT)
fi

dnl ##### Check for std::sort.
AC_CACHE_CHECK([for std::sort],
xpdf_cv_func_std_sort,
[AC_COMPILE_IFELSE(
  [AC_LANG_PROGRAM([[#include <algorithm>
struct functor {
  bool operator()(const int &i0, const int &i1) { return i0 < i1; }
};]],
                  [[int a[100];
std::sort(a, a+100, functor());]])],
xpdf_cv_func_std_sort=yes, xpdf_cv_func_std_sort=no)])
if test "$xpdf_cv_func_std_sort" = yes; then
  AC_DEFINE(HAVE_STD_SORT)
fi

dnl ##### Back to C for the library tests.
AC_LANG([C])

dnl ##### Check for fseeko/ftello or fseek64/ftell64
dnl The LARGEFILE and FSEEKO macros have to be called in C, not C++, mode.
AC_SYS_LARGEFILE
AC_FUNC_FSEEKO
AC_CHECK_FUNCS(fseek64, xpdf_cv_func_fseek64=yes, xpdf_cv_func_fseek64=no)
AC_CHECK_FUNCS(ftell64, xpdf_cv_func_ftell64=yes, xpdf_cv_func_ftell64=no)
if test "$xpdf_cv_func_fseek64" = yes -a "$xpdf_cv_func_ftell64" = yes; then
  AC_DEFINE(HAVE_FSEEK64)
fi

PKG_PROG_PKG_CONFIG

PKG_CHECK_MODULES([freetype2], [freetype2])

if test x"$freetype2_LIBS" != x; then
  AC_SUBST(freetype2_LIBS)
  AC_SUBST(freetype2_CFLAGS)
  AC_DEFINE(HAVE_FREETYPE_H)
  AC_DEFINE(HAVE_SPLASH)
fi

dnl ##### Check for libpng.
# use libpng-config if available
AC_CHECK_PROG(HAVE_LIBPNG_CONFIG, [libpng-config], yes)
if test "$HAVE_LIBPNG_CONFIG" = "yes"; then
  PNG_CFLAGS="`libpng-config --I_opts`"
  PNG_LDFLAGS="`libpng-config --ldflags`"
  CPPFLAGS="${CPPFLAGS} $PNG_CFLAGS"
  LDFLAGS="$PNG_LDFLAGS ${LDFLAGS}"
  AC_CHECK_HEADERS(png.h)
  AC_CHECK_LIB(png, png_write_row)
  if test "$ac_cv_search_write_row" != no; then
    libpng_CFLAGS="$PNG_CFLAGS"
    libpng_LFLAGS="$PNG_LDFLAGS"
    AC_SUBST(libpng_CFLAGS)
    AC_SUBST(libpng_LIBS)
    AC_DEFINE([HAVE_LIBPNG], [1])
  fi
else
  AC_MSG_WARN([Can't find libpng-config, guessing required headers and libraries.])
  AC_CHECK_HEADERS(png.h)
  AC_CHECK_LIB(png, png_write_row)
fi

dnl ##### Check for libpaper (Debian).
PKG_CHECK_MODULES([libpaper], [libpaper], [], AC_MSG_WARN([No libpaper]))
AC_SUBST(libpaper_LIBS)
AC_SUBST(libpaper_CFLAGS)

dnl ##### Disable X-specific stuff in top-level Makefile.
if test -n "$no_x" -o "x$smr_have_Xm_library" != xyes -o "x$smr_have_freetype2_library" != xyes; then
  X="#"
  XPDF_TARGET="all-no-x"
else
  X=""
  XPDF_TARGET="all"
fi
AC_SUBST(X)
AC_SUBST(XPDF_TARGET)

dnl ##### Extra libraries.
EXTRA_LIBS=
EXTRA_CFLAGS=
AC_SUBST(EXTRA_LIBS)
AC_SUBST(EXTRA_CFLAGS)

dnl ##### Write the makefiles.
AC_CONFIG_FILES([Makefile goo/Makefile fofi/Makefile splash/Makefile xpdf/Makefile])
AC_OUTPUT

dnl ##### Warn user if X is missing.
if test x"$freetype2_LIBS" != x; then
  AC_MSG_WARN([Could not find FreeType: -- You will be able to compile pdftops, pdftotext,
        pdfinfo, pdffonts, pdfdetach, and pdfimages, but not xpdf
        or pdftoppm])
fi

dnl ##### Warn user if libpng is missing.
if test "$ac_cv_lib_png_png_write_row" = no; then
  AC_MSG_WARN([Couldn't find libpng -- you will not be able to build pdftohtml or pdftopng])
fi

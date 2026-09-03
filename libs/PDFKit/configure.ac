AC_PREREQ(2.52)
AC_INIT(PDFKit, 1.2.0)

XPDF_SRC=xpdf-4.03

if test -z "$GNUSTEP_MAKEFILES"; then
  AC_MSG_ERROR([You must run the GNUstep initialization script first!])
fi

#--------------------------------------------------------------------
# Use config.guess, config.sub and install-sh provided by gnustep-make
#--------------------------------------------------------------------
AC_CONFIG_AUX_DIR([$GNUSTEP_MAKEFILES])

#--------------------------------------------------------------------
# Find the compiler
#--------------------------------------------------------------------
if test "$CC" = ""; then
  CC=`gnustep-config --variable=CC`
fi
if test "$CPP" = ""; then
  CPP=`gnustep-config --variable=CPP`
fi
if test "$CXX" = ""; then
  CXX=`gnustep-config --variable=CXX`
fi

MAKECC=`gnustep-config --variable=CC`
if test "$CC" != "$MAKECC"; then
  AC_MSG_ERROR([You are running configure with the compiler ($CC) set to a different value from that used by gnustep-make ($MAKECC).  Please run configure again with your environment set to match your gnustep-make])
  exit 1
fi


AC_SUBST(CC)
AC_SUBST(CPP)
AC_SUBST(CXX)
export CC
export CPP
export CXX

AC_SUBST(XPDF_SRC)

AC_CONFIG_FILES([GNUmakefile xpdf/GNUmakefile xpdf/bridge/GNUmakefile xpdf/"$XPDF_SRC"/GNUmakefile])

AC_OUTPUT


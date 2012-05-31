AC_PREREQ(2.52)
AC_INIT(PDFKit, 0.9.1)

if test -z "$GNUSTEP_SYSTEM_ROOT"; then
  AC_MSG_ERROR([You must run the GNUstep initialization script first!])
fi

#--------------------------------------------------------------------
# Use config.guess, config.sub and install-sh provided by gnustep-make
#--------------------------------------------------------------------
AC_CONFIG_AUX_DIR([$GNUSTEP_MAKEFILES])

#--------------------------------------------------------------------
# Determine the host, build, and target systems
#--------------------------------------------------------------------
AC_CANONICAL_TARGET([])

AC_PROG_CC
AC_PROG_CXX

#--------------------------------------------------------------------
# freetype2
#--------------------------------------------------------------------
AC_ARG_WITH(freetype2_library, 
           [  --with-freetype2-library=DIR 
                      use freetype2 library (FreeType2 font rasterizer - version 2.0.5+)], ,
           with_freetype2_library=)
           
AC_ARG_WITH(freetype2_includes, 
           [  --with-freetype2-includes=DIR 
                      set directory for freetype2 headers], ,
           with_freetype2_includes=)

AC_ARG_WITH(freetype2_add_includes, 
           [  --with-freetype2-add-includes=DIR 
                      set directory for freetype2 additional headers], ,
           with_freetype2_add_includes=)

if test -n "$with_freetype2_library"; then
  lib_freetype_libs=$with_freetype2_library
else  
  case "$target_os" in
    freebsd*)
    	lib_freetype_libs=/usr/local/lib
      ;;
    netbsd*)
    	lib_freetype_libs=/usr/pkg/lib
      ;;
    *)	
      lib_freetype_libs=`freetype-config --prefix`/lib
      ;;
  esac
fi

if test -n "$with_freetype2_add_includes"; then
  lib_freetype_add_includes=$with_freetype2_add_includes
else  
  case "$target_os" in
    freebsd*)
    	lib_freetype_add_includes=/usr/local/include
      ;;
    netbsd*)
	lib_freetype_add_includes=/usr/pkg/include
      ;;
    openbsd*)
	lib_freetype_add_includes=/usr/X11R6/include
      ;;
    *)	
      lib_freetype_add_includes=`freetype-config --prefix`/include
      ;;
  esac
fi

if test -n "$with_freetype2_includes"; then
  lib_freetype_includes=$with_freetype2_includes
else
  case "$target_os" in
    freebsd*)
    	lib_freetype_includes=/usr/local/include/freetype2
      ;;
    netbsd*)
    	lib_freetype_includes=/usr/pkg/include/freetype2
      ;;
    openbsd*)
	lib_freetype_add_includes=/usr/X11R6/include/freetype2
       ;;
    *)	
      lib_freetype_includes=`freetype-config --prefix`/include/freetype2
      ;;
  esac
fi

AC_SUBST(lib_freetype_libs)
AC_SUBST(lib_freetype_includes)
AC_SUBST(lib_freetype_add_includes)

AC_CONFIG_FILES([GNUmakefile xpdf/GNUmakefile xpdf/bridge/GNUmakefile xpdf/xpdf-3.02/GNUmakefile])

AC_OUTPUT


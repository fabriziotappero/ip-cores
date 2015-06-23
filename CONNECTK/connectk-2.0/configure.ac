#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.61)
AC_INIT([connectk], [2.0], [levi0190@umn.edu])
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([src/connectk.c])
AC_CONFIG_HEADER([config.h])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.
#AM_PATH_GTK_2_0(2.8.0,,[AC_MSG_ERROR([GTK not found])])
PKG_CHECK_MODULES(GTK, gtk+-2.0 glib-2.0 gthread-2.0)
AC_SUBST(GTK_CFLAGS)
AC_SUBST(GTK_LIBS)

# Checks for header files.
AC_HEADER_STDC

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_OUTPUT([
	Makefile
])

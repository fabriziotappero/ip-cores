AC_INIT([adv_jtag_bridge],[3.0.0])
AM_INIT_AUTOMAKE([-Wall -Werror])
LT_INIT

# Use "make V=1" in order to see the gcc command-lines during compilation.
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])

# These compilation flags must be set before AC_PROG_CC/CXX,
# or you'll get "-g -O2" by default.
CFLAGS="${CFLAGS=} -g -Wall"

AC_PROG_CC
AC_PROG_INSTALL

AC_CONFIG_MACRO_DIR([m4])


# ----------- Detect host type -----------

AC_CANONICAL_HOST

case $host in
  *-cygwin)   # Normally it is "i686-pc-cygwin"
    echo "Host system: Cygwin detected."
    MY_HOST=cygwin
    CFLAGS="$CFLAGS -D__CYGWIN_HOST__"
    AC_CHECK_HEADER(sys/io.h,,[AC_MSG_ERROR([Include file 'sys/io.h' not found, please install the Cygwin 'ioperm' package.])])
    LIBS+=-lioperm
    ;;
  *-linux-*)
    echo "Host system: Linux detected."
    MY_HOST=linux
    CFLAGS="$CFLAGS -D__LINUX_HOST__"
    ;;
  *freebsd*)
    echo "Host system: FreeBSD detected."
    MY_HOST=freebsd
    CFLAGS="$CFLAGS -D__FREEBSD_HOST__"
    ;;
  *)
    echo "Host system: Unknown, assuming a Linux host."
    MY_HOST=linux
    ;;
esac


# ----------- Check whether debug or release build -----------

AC_MSG_CHECKING(whether to generate a debug build)
AC_ARG_ENABLE([debug],
              [AS_HELP_STRING([--enable-debug=[[yes/no]]],
                              [generate a debug build with assertions and no optimization [default=no]])],
              [case "${enableval}" in
               yes) debug_build=true ;;
               no)  debug_build=false ;;
               *) AC_MSG_ERROR([bad value ${enableval} for --enable-debug]) ;;
               esac],
              debug_build=false)

if [ test x$debug_build = xtrue ]
then
    AC_MSG_RESULT(yes)
    CFLAGS="$CFLAGS -O0 -DDEBUG"
else
    AC_MSG_RESULT(no)
    # If we let the 'omit frame pointer' optimisation enabled,
    # we'll have difficulty later on while trying
    # to analyse crash dump files sent by the users.
    CFLAGS="$CFLAGS -O2 -DNDEBUG -fno-omit-frame-pointer"
fi


# ----------- Check whether legacy debug_if -----------

AC_MSG_CHECKING(whether to build for the legacy debug unit)
AC_ARG_ENABLE([legacy-debug-if],
              [AS_HELP_STRING([--enable-legacy-debug-if=[[yes/no]]],
                              [build for the legacy debug unit, as opposed to the newer Advanced Debug Unit [default=no]])],
              [case "${enableval}" in
               yes) legacy_debug_if=true ;;
               no)  legacy_debug_if=false ;;
               *) AC_MSG_ERROR([bad value ${enableval} for --enable-legacy-debug-if]) ;;
               esac],
              legacy_debug_if=false)

if [ test x$legacy_debug_if = xtrue ]
then
    AC_MSG_RESULT(yes)
    CFLAGS="$CFLAGS -D__LEGACY__"
else
    AC_MSG_RESULT(no)
fi


# ----------- Check whether to support parallel cables -----------

AC_MSG_CHECKING(whether to support parallel cables)
AC_ARG_ENABLE([parallel-cables],
              [AS_HELP_STRING([--enable-parallel-cables=[[yes/no]]],
                              [support parallel cables (requires libioperm under Cygwin) [default=yes]])],
              [case "${enableval}" in
               yes) support_parallel=true ;;
               no)  support_parallel=false ;;
               *) AC_MSG_ERROR([bad value ${enableval} for --enable-parallel-cables]) ;;
               esac],
              support_parallel=not_given)

if [ test $support_parallel = not_given ]
then
    support_parallel=true
fi

if [ test $MY_HOST = freebsd ] && [ test $support_parallel = true ]
then
  AC_MSG_ERROR([Support for parallel cables is not available under FreeBSD.])
fi

AM_CONDITIONAL(SUPPORT_PARALLEL_CABLES,[test x$support_parallel = xtrue])
AM_COND_IF([SUPPORT_PARALLEL_CABLES],[AC_MSG_RESULT(yes)],[AC_MSG_RESULT(no)])


# ----------- Check whether to support USB cables -----------

AC_MSG_CHECKING(whether to support usb cables)
AC_ARG_ENABLE([usb-cables],
              [AS_HELP_STRING([--enable-usb-cables=[[yes/no]]],
                              [support usb cables (requires libusb) [default=yes]])],
              [case "${enableval}" in
               yes) support_usb=true ;;
               no)  support_usb=false ;;
               *) AC_MSG_ERROR([bad value ${enableval} for --enable-usb-cables]) ;;
               esac],
              support_usb=true)

AM_CONDITIONAL(SUPPORT_USB_CABLES,[test x$support_usb = xtrue])
AM_COND_IF([SUPPORT_USB_CABLES],[AC_MSG_RESULT(yes)],[AC_MSG_RESULT(no)])

if [ test $support_usb = true ]
then
  AC_CHECK_HEADER(usb.h,,[AC_MSG_ERROR([Include file 'usb.h' not found, please install the libusb-0.1 development files (for example, that would be package 'libusb-win32' under Cygwin, and 'libusb-dev' under Ubuntu).])])
fi


# ------ At least one from (parallel, usb) must be enabled ------

if [ test x$support_parallel = xfalse ] && [ test x$support_usb = xfalse ]; then
  AC_MSG_ERROR([Support for both parallel and usb cables is disabled.])
fi 

# ------ Check whether the xilinx parallel cable mode is given ------
# This argument should be called --set-xxx and not --enable-xxx ,
# but autoconf identifies only the --enable and --with prefixes
# for recursive configuration option processing.

AC_MSG_CHECKING(xilinx parallel cable speed limit scheme)
AC_ARG_ENABLE([xpc3-limit-scheme],
              [AS_HELP_STRING([--enable-xpc3-limit-scheme=[[sleep_wait/timer_wait/no_wait]]],
                              [limit Xilinx parallel cable speed, as some clones cannot operate as fast as we can drive them [default=no_wait]])],
              [case "${enableval}" in
               sleep_wait)  xpc3_limit_scheme=sleep_wait ;;
               timer_wait)  xpc3_limit_scheme=timer_wait ;;
               no_wait)     xpc3_limit_scheme=no_wait ;;
               *) AC_MSG_ERROR([bad value ${enableval} for --enable-xpc3-limit-scheme]) ;;
               esac],
              xpc3_limit_scheme=not_given)

if [ ! test $xpc3_limit_scheme = not_given ] && [ test $support_parallel = false ]
then
  AC_MSG_ERROR([Option --enable-xpc3-limit-scheme can only be supplied if support for the parallel cables has been enabled.])
fi

if [ test $xpc3_limit_scheme = not_given ]
then
  xpc3_limit_scheme=no_wait
fi

AC_MSG_RESULT($xpc3_limit_scheme)

case "${xpc3_limit_scheme}" in
  sleep_wait)
    CFLAGS="$CFLAGS -D__PARALLEL_SLEEP_WAIT__"
    ;;
  timer_wait)
    CFLAGS="$CFLAGS -D__PARALLEL_TIMER_BUSY_WAIT__"
    ;;
  no_wait)
    # no_wait is the default, nothing to define
    ;;
  *)
    AC_MSG_ERROR([Internal error in --enable-xpc3-limit-scheme.])
    ;;
esac


# ----------- Check whether to support FTDI cables -----------

AC_MSG_CHECKING(whether to support ftdi cables)
AC_ARG_ENABLE([ftdi-cables],
              [AS_HELP_STRING([--enable-ftdi-cables=[[yes/no]]],
                              [support ftdi cables (requires libftdi) [default=yes]])],
              [case "${enableval}" in
               yes) support_ftdi=true ;;
               no)  support_ftdi=false ;;
               *) AC_MSG_ERROR([bad value ${enableval} for --enable-ftdi-cables]) ;;
               esac],
              support_ftdi=not_given)

if [ test $support_ftdi = not_given ]
then
  support_ftdi=$support_usb
fi

AM_CONDITIONAL(SUPPORT_FTDI_CABLES,[test x$support_ftdi = xtrue])
AM_COND_IF([SUPPORT_FTDI_CABLES],[AC_MSG_RESULT(yes)],[AC_MSG_RESULT(no)])

if [ test x$support_usb = xfalse ] && [ test x$support_ftdi = xtrue ]; then
  AC_MSG_ERROR([Support for FTDI cables requires support for USB cables.])
fi 

if [ test $support_ftdi = true ]
then
  AC_CHECK_HEADER(ftdi.h,,[AC_MSG_ERROR([Include file 'ftdi.h' not found, please install the libftdi development files (for example, that would be package 'libftdi-dev' under Ubuntu).])])
fi


# ----------- Check whether to enable the high-speed mode -----------

AC_MSG_CHECKING(whether to enable the high-speed mode)
AC_ARG_ENABLE([high-speed],
              [AS_HELP_STRING([--enable-high-speed=[[yes/no]]],
                              [enable the high-speed mode at the cost of some error checking (requires hardware HDL support) [default=yes]])],
              [case "${enableval}" in
               yes) enable_high_speed=true ;;
               no)  enable_high_speed=false ;;
               *) AC_MSG_ERROR([bad value ${enableval} for --enable-high-speed]) ;;
               esac],
              enable_high_speed=true)

if [ test x$enable_high_speed = xtrue ]
then
    AC_MSG_RESULT(yes)
    CFLAGS="$CFLAGS -DADBG_OPT_HISPEED"
else
    AC_MSG_RESULT(no)
fi


# ----------- Check whether to enable the JSP server -----------

AC_MSG_CHECKING(whether to enable the JSP server)
AC_ARG_ENABLE([jsp-server],
              [AS_HELP_STRING([--enable-jsp-server=[[yes/no]]],
                              [enable the JSP server (requires hardware HDL support) [default=yes]])],
              [case "${enableval}" in
               yes) enable_jsp_server=true ;;
               no)  enable_jsp_server=false ;;
               *) AC_MSG_ERROR([bad value ${enableval} for --enable-jsp-server]) ;;
               esac],
              enable_jsp_server=not_given)

if [ test x$legacy_debug_if = xtrue ] && [ test x$enable_jsp_server = xtrue ]
then
  AC_MSG_ERROR([Option --enable-jsp-server cannot be true when using the legacy_debug_if hardware.])
fi

if [ test $enable_jsp_server = not_given ]
then
  if [ test x$legacy_debug_if = xtrue ]
  then
    enable_jsp_server=false
  else
    enable_jsp_server=true
  fi
fi

AM_CONDITIONAL(INCLUDE_JSP_SERVER,[test x$enable_jsp_server = xtrue])
AM_COND_IF([INCLUDE_JSP_SERVER],[AC_MSG_RESULT(yes)],[AC_MSG_RESULT(no)])


# ----------- Check whether to enable the JSP multi device support -----------

AC_MSG_CHECKING(whether to enable the JSP multi device chain support)
AC_ARG_ENABLE([jsp-multi-device-chain],
              [AS_HELP_STRING([--enable-jsp-multi-device-chain=[[yes/no]]],
                              [enable the JTAG Serial Port (JSP) multi device chain support (slower, requires hardware HDL support) [default=yes]])],
              [case "${enableval}" in
               yes) enable_jsp_multi_device_chain=true ;;
               no)  enable_jsp_multi_device_chain=false ;;
               *) AC_MSG_ERROR([bad value ${enableval} for --enable-jsp-multi-device-chain]) ;;
               esac],
              enable_jsp_multi_device_chain=not_given)

if [ ! test $enable_jsp_multi_device_chain = not_given ] && [ test $enable_jsp_server = false ]
then
  AC_MSG_ERROR([Option --enable-jsp-multi-device-chain can only be supplied if the JSP server has been enabled.])
fi

if [ test $enable_jsp_multi_device_chain = not_given ]
then
  enable_jsp_multi_device_chain=true
fi

if [ test x$enable_jsp_multi_device_chain = xtrue ]
then
    AC_MSG_RESULT(yes)
    CFLAGS="$CFLAGS -DENABLE_JSP_MULTI"
else
    AC_MSG_RESULT(no)
fi


# ----------- Check whether to optimize the JSP for parallel or USB -----------

AC_MSG_CHECKING(whether to optimize the JSP for USB)
AC_ARG_ENABLE([jsp-optimize-for-usb],
              [AS_HELP_STRING([--enable-jsp-optimize-for-usb=[[yes/no]]],
                              [optimizes the JTAG Serial Port (JSP) for USB cables (as opposed to optimizing for parallel cables) [default=yes]])],
              [case "${enableval}" in
               yes) enable_jsp_optimize_for_usb=true ;;
               no)  enable_jsp_optimize_for_usb=false ;;
               *) AC_MSG_ERROR([bad value ${enableval} for --enable-jsp-optimize-for-usb]) ;;
               esac],
              enable_jsp_optimize_for_usb=not_given)


if [ ! test $enable_jsp_optimize_for_usb = not_given ] && [ test $enable_jsp_server = false ]
then
  AC_MSG_ERROR([Option --enable-jsp-optimize-for-usb can only be supplied if the JSP server has been enabled.])
fi

if [ test $enable_jsp_optimize_for_usb = not_given ]
then
  enable_jsp_optimize_for_usb=true
fi

if [ test x$enable_jsp_optimize_for_usb = xtrue ]
then
    AC_MSG_RESULT(yes)
    CFLAGS="$CFLAGS -DOPTIMIZE_JSP_FOR_USB"
else
    AC_MSG_RESULT(no)
fi

# ----------------------------------------

AC_CONFIG_FILES([Makefile])
AC_OUTPUT

AC_PREREQ(2.59)
AC_INIT([MyGPU], [0.1], [dm.leontiev at gmail.com])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE()

AC_PREFIX_DEFAULT([/opt/MyGPUProject/])
AC_PROG_CXX
AC_PROG_LIBTOOL
AC_PROG_INSTALL

AC_CHECK_PROG(VERILATOR,verilator,yes)

if test x"$VERILATOR" != x"yes" ; then
    AC_MSG_ERROR([Please install verilator before building the project.])
fi

AC_CONFIG_FILES([Makefile 
                 Tools/Makefile 
                 Tools/Rescale/Makefile
                 Tools/Verilate/Makefile
                 Hardware/Makefile 
                 Hardware/Components/Makefile
                 Hardware/Processor/Makefile
                 Hardware/Memory/Makefile
                 Hardware/ASIC/Makefile
                 Software/Makefile
                 Software/Compiler/Makefile 
                 Software/Firmware/Makefile])
AC_OUTPUT

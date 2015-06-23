#!/bin/bash
#
# Script to compile sources to a library using Active HDL
# (c) Copyright Andras Tantos <tantos@opencores.org> 2001/04/25
# This code is distributed under the terms and conditions of the GNU General Public Lince.
#
# USAGE:
#
# Set APATH to the installation directory of ActiveHDL and
# LIB to whatever name your library has
# RESULT_PATH to where generated files you wish to be put
# Also make sure that you upadted the Library.cfg file to contain 
# the specified library name. 
# After the common part, list all files you wish to include in your library
# with 'compile_file' preciding the file name.
#
# NOTES:
#
# This script depends on the following executables:
#    bash
#    cat
#    rm
#    mv
#    mkdir
#    echo
#    test
# they are available under all UNIX-es and can be installed for windows
# and DOS too. The windows version of these files can be obtained from
# GNU Cygnus distribution (http://sources.redhat.com/cygwin)
# The minimal package of these utilities are also available from
# OpenCores web-site.

APATH=C:/CAED/ActiveHDL.36/
LIB=wb_vga
RESULT_PATH=ahdl

# ___________Common part of the script____________

LIB_FILE=$RESULT_PATH/$LIB.lib
CMP_FILE=$RESULT_PATH/0.mgf
CMP=$APATH/bin/acombat.exe
CMP_FLAGS="-avhdl $APATH -lib $LIB -93"

compile_file() {
    LOG_FILE=$1
    LOG_FILE=$RESULT_PATH/${LOG_FILE/.vhd/.rlt}
    ERR_FILE=${LOG_FILE/.rtl/.err}
    rm -f $LOG_FILE
    rm -f $ERR_FILE
    $CMP $CMP_FLAGS -log $LOG_FILE $1 || {
        mv $LOG_FILE $ERR_FILE
        cat $ERR_FILE
        exit 1
    }
    cat $LOG_FILE
}

if test ! -d $RESULT_PATH; then
    mkdir $RESULT_PATH
fi
rm -f $RESULT_PATH/*
if test ! -f $LIB_FILE; then
	echo > $LIB_FILE
fi
# ___________End of common part of the script____________

compile_file wb_io_reg.vhd
compile_file mem_reader.vhd
compile_file sync_gen.vhd
compile_file hv_sync.vhd
compile_file video_engine.vhd
compile_file accel.vhd
compile_file palette.vhd
compile_file vga_core.vhd
compile_file vga_core_v2.vhd
compile_file vga_chip.vhd

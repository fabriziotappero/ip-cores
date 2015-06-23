# Filename : syn.sh
# Author   : Nikolaos Kavvadias 2013, 2014
# Copyright: (C) 2013, 2014 Nikolaos Kavvadias

#!/bin/bash

##########################################################################
# Script for running Xilinx XST logic synthesis of cordic.
# USAGE:
# ./syn.sh
##########################################################################

E_PRINTUSAGE=83

function print_usage () {
  echo "Script for running Xilinx XST logic synthesis of cordic."
  echo "Author: Nikolaos Kavvadias (C) 2013, 2014"
  echo "Copyright: (C) 2013, 2014 Nikolaos Kavvadias"
  echo "Usage: ./syn.sh"
}

if [ "$1" == "-help" ]
then
  print_usage;
  exit $E_PRINTUSAGE
fi

export XDIR="c:/XilinxISE/14.6/ISE_DS/ISE"

#arch="spartan3"
arch="virtex6"
#part="xc3s200-ft256-4"
part="xc6vlx75t-ff484-1"

make -if ../bin/xst.mk clean
SOURCES="../../../sim/rtl_sim/vhdl/operpack.vhd ../../../rtl/vhdl/cordic_cdt_pkg.vhd ../../../rtl/vhdl/cordic.vhd"
make -if ../bin/xst.mk PROJECT="${mode}" SOURCES="${SOURCES}" TOPDIR="../log" TOP="cordic" cordic.ngc ARCH=${arch} PART=${part}

if [ "$SECONDS" -eq 1 ]
then
  units=second
else
  units=seconds
fi
echo "This script has been running $SECONDS $units."

exit 0

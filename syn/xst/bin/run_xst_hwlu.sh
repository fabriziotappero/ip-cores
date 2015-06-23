#!/bin/bash

VPP_HOME=/usr/local/bin/vpp
VPP=vpp

ARCH=DUMMY
DEVICE=DUMMY


#for device in 2
#for device in 3
for device in 4
do
  #
  if [ "$device" = "0" ]
  then
    ARCH="spartan3"
    DEVICE="xc3s200-ft256-4"
  elif [ "$device" = "1" ]
  then
    ARCH="spartan3"
    DEVICE="xc3s1000-ft256-4"
  elif [ "$device" = "2" ]
  then
    ARCH="spartan3"
    DEVICE="xc3s1500-fg456-4"
  elif [ "$device" = "3" ]
  then
    ARCH="virtex4"
    DEVICE="xc4vlx25-ff668-10"
  elif [ "$device" = "4" ]
  then
    ARCH="virtex5"
    DEVICE="xc5vlx50t-ff665-1"
  fi
  #
#  for dw in 8 12 16
#  for dw in 8
  for dw in 12
#  for dw in 16
  do
#    for nlp in 1 2 3 4 5 6 7 8 
    for nlp in 2 5 
    do
      cd ../../../rtl/vhdl
#      ../../sw/gen_priority_encoder ${nlp} prenc
#      ../../sw/gen_hw_looping -nlp ${nlp} -nodistrib hw
      ../../sw/gen_hw_looping -nlp ${nlp} hw
      cd ../../syn/xst/bin
      ./change_dw.pl ../../../rtl/vhdl/hw_loops${nlp}_top.vhd ${dw} >../../../rtl/vhdl/hw_loops${nlp}_top_fix.vhd
      make -f Makefile.ise clean
      make -f Makefile.ise DEFAULT_ARCH=hw_looping DEFAULT_PART=${DEVICE} PROJECT=hw_looping${nlp} SOURCES="../../../rtl/vhdl/add_dw.vhd ../../../rtl/vhdl/reg_dw.vhd ../../../rtl/vhdl/cmpeq.vhd ../../../rtl/vhdl/index_inc.vhd ../../../rtl/vhdl/prenc_loops${nlp}.vhd ../../../rtl/vhdl/hw_loops${nlp}_top_fix.vhd" TOP=hw_looping hw_looping${nlp}.ngc
    done
  done
done

if [ "$SECONDS" -eq 1 ]
then
  units=second
else
  units=seconds
fi
echo "This script has been running $SECONDS $units."

exit 0

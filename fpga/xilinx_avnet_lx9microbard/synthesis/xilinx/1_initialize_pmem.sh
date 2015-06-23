#!/bin/bash
###############################################################################
#                                                                             #
#                       Xilinx RAM update script for LINUX                    #
#                                                                             #
###############################################################################
# In order to figure out where the RAM cells are mapped in the target
# FPGA, please use the utility provided by Xilinx:
#                  > export DISPLAY=:0
#                  > fpga_editor

###############################################################################
#                            Parameter Check                                  #
###############################################################################
EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]; then
    echo ""
    echo "ERROR          : wrong number of arguments"
    echo "USAGE          : ./1_initialize_pmem.sh <test name>"
    echo "EXAMPLE        : ./1_initialize_pmem.sh    leds"
    echo ""
    echo "AVAILABLE TESTS:"
    for fullfile in ../../software/* ; do
	filename=$(basename "$fullfile")
	filename="${filename%.*}"
	echo "                  - $filename"
    done
    echo ""
  exit 1
fi

###############################################################################
#                     Check if the required files exist                       #
###############################################################################
softdir=../../software/$1;
elffile=../../software/$1/$1.elf;

if [ ! -e $softdir ]; then
    echo "Software directory doesn't exist: $softdir"
    exit 1
fi

###############################################################################
#                           Update FPGA Bitstream                             #
###############################################################################

cd ./WORK

# Generate memory file
msp430-objcopy -O ihex ../$elffile ./$1.ihex
../scripts/ihex2mem.tcl -ihex $1.ihex -out $1.mem -mem_size 16384

# Update bitstream
data2mem -bm ../scripts/memory.bmm -bd $1.mem -bt openMSP430_fpga.bit -o b $1.bit

# Copy new bitstream in the proper directory
cp -f ./$1.bit ../bitstreams

cd ../

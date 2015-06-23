#!/bin/bash
###############################################################################
#                                                                             #
#                       Xilinx RAM update script for LINUX                    #
#                                                                             #
###############################################################################

###############################################################################
#                            Parameter Check                                  #
###############################################################################
EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]; then
    echo ""
    echo "ERROR          : wrong number of arguments"
    echo "USAGE          : ./3_program_fpga <prom name>"
    echo "EXAMPLE        : ./3_program_fpga    leds"
    echo ""
    echo "AVAILABLE TESTS:"
    for fullfile in ./bitstreams/*.mcs ; do
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
promfile=./bitstreams/$1.mcs;

if [ ! -e $promfile ]; then
    echo "Specified PROM file doesn't exist: $promfile"
    exit 1
fi

###############################################################################
#                           Update FPGA Bitstream                             #
###############################################################################

# Move to the XFLOW workspace
cd ./WORK

# Copy PROM & bitstream in working directory
cp -f ../bitstreams/$1.bit .
cp -f ../bitstreams/$1.mcs .

# Copy the impact script and update it
cp ../scripts/impact_program_fpga.batch ./impact_program_fpga.batch
sed -i "s/PROM_NAME/$1/g"  ./impact_program_fpga.batch

# Program FPGA
impact -batch ./impact_program_fpga.batch

# Return to the root directory
cd ../

#!/bin/bash
#------------------------------------------------------------------------------
# Copyright (C) 2001 Authors
#
# This source file may be used and distributed without restriction provided
# that this copyright statement is not removed from the file and that any
# derivative work contains the original copyright notice and the associated
# disclaimer.
#
# This source file is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.1
#
# This source is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this source; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
#------------------------------------------------------------------------------
#
# File Name: asm2ihex.sh
#
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev: 200 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2015-01-21 23:01:31 +0100 (Wed, 21 Jan 2015) $
#------------------------------------------------------------------------------

###############################################################################
#                            Parameter Check                                  #
###############################################################################
EXPECTED_ARGS=7
if [ $# -ne $EXPECTED_ARGS ]; then
  echo "ERROR    : wrong number of arguments"
  echo "USAGE    : asm2ihex.sh <test name> <test assembler file> <linker script> <assembler define>  <prog mem size> <data mem size> <peripheral addr space size>"
  echo "Example  : asm2ihex.sh c-jump_jge  ../src/c-jump_jge.s43 ../bin/template.x ../bin/pmem.h 2048            128             512"
  exit 1
fi

# MSPGCC version prefix
MSPGCC_PFX=${MSPGCC_PFX:=msp430}

###############################################################################
#               Check if definition & assembler files exist                   #
###############################################################################

if [ ! -e $2 ]; then
    echo "Assembler file doesn't exist: $2"
    exit 1
fi
if [ ! -e $3 ]; then
    echo "Linker definition file template doesn't exist: $3"
    exit 1
fi
if [ ! -e $4 ]; then
    echo "Assembler definition file template doesn't exist: $4"
    exit 1
fi


###############################################################################
#               Generate the linker definition file                           #
###############################################################################

PER_SIZE=$7
DMEM_SIZE=$6
PMEM_SIZE=$5
PMEM_BASE=$((0x10000-$PMEM_SIZE))
STACK_INIT=$((PER_SIZE+0x0080))

cp  $3  ./pmem.x
cp  $4  ./pmem_defs.asm
sed -i "s/PMEM_BASE/$PMEM_BASE/g"         pmem.x
sed -i "s/PMEM_SIZE/$PMEM_SIZE/g"         pmem.x
sed -i "s/DMEM_SIZE/$DMEM_SIZE/g"         pmem.x
sed -i "s/PER_SIZE/$PER_SIZE/g"           pmem.x
sed -i "s/STACK_INIT/$STACK_INIT/g"       pmem.x

sed -i "s/PMEM_SIZE/$PMEM_SIZE/g"         pmem_defs.asm
sed -i "s/PER_SIZE_HEX/$PER_SIZE/g"       pmem_defs.asm
if [ $MSPGCC_PFX == "msp430-elf" ]; then
    sed -i "s/PER_SIZE/.data/g"           pmem_defs.asm
    sed -i "s/PMEM_EDE_SIZE/0/g"          pmem_defs.asm
else
    sed -i "s/PER_SIZE/$PER_SIZE/g"       pmem_defs.asm
    sed -i "s/PMEM_EDE_SIZE/$PMEM_SIZE/g" pmem_defs.asm
fi


###############################################################################
#                  Compile, link & generate IHEX file                         #
###############################################################################
echo ""
echo "\$ $MSPGCC_PFX-as      -alsm $2 -o $1.o > $1.l43"
$MSPGCC_PFX-as      -alsm         $2     -o $1.o     > $1.l43
echo "\$ $MSPGCC_PFX-objdump -xdsStr $1.o >> $1.l43"
$MSPGCC_PFX-objdump -xdsStr       $1.o              >> $1.l43
echo "\$ $MSPGCC_PFX-ld      -T ./pmem.x $1.o -o $1.elf"
$MSPGCC_PFX-ld      -T ./pmem.x   $1.o   -o $1.elf
echo "\$ $MSPGCC_PFX-objcopy -O ihex $1.elf $1.ihex"
$MSPGCC_PFX-objcopy -O ihex       $1.elf    $1.ihex
echo ""

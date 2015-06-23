#!/bin/ksh

# Copyright (C) 2010, 2011 Embedded Computing Systems Group,
# Department of Computer Engineering, Vienna University of Technology.
# Contributed by Martin Walter <mwalter@opencores.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>. */

# Creates memory map dependency files for the SCARTS architecture.
#
# Usage: scarts-memmap.sh SRC [install]
#   SRC ... A file containing memory mapping parameters.
#
# Example: ./scarts-memmap.sh ./cfg/scarts_32_hpe_midi_gdb.cfg install

usage()
{
  echo "Creates dependencies for a memory mapping for the SCARTS architecture."
  echo "Usage: $0 SRC [install]"
  echo "  SRC ... A file containing memory mapping parameters."
  echo ""
  echo "Example: ./scarts-memmap.sh ./cfg/scarts_32_hpe_midi_gdb.cfg install"
}

############################
# Load external parameters #
############################

if [ "$1" == "" ]; then
  usage
  exit
fi

. $1

if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
  if [ "$SCARTS_16_TOOLCHAIN_LIB_DIR" == "" ]; then
    echo "Error: environment variable SCARTS_16_TOOLCHAIN_LIB_DIR is not set. Please source scartsrc and try again."
    exit
  fi
elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
  if [ "$SCARTS_32_TOOLCHAIN_LIB_DIR" == "" ]; then
    echo "Error: environment variable SCARTS_32_TOOLCHAIN_LIB_DIR is not set. Please source scartsrc and try again."
    exit
  fi
fi

#################################
# Architecture specific options #
#################################

SCARTS_16_WORD_SIZE=16
SCARTS_32_WORD_SIZE=32

SCARTS_WORD_SIZE=0
if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
  SCARTS_WORD_SIZE=$SCARTS_16_WORD_SIZE
elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
  SCARTS_WORD_SIZE=$SCARTS_32_WORD_SIZE
fi

# Calculate sizes, start addresses and end addresses of the code memory.
SCARTS_CODEMEM_SIZE=$((SCARTS_CODEMEM_SIZE))
SCARTS_CODEMEM_SIZE_LOG=$((`echo "l($((SCARTS_CODEMEM_SIZE)))/l(2)" | bc -l`))
SCARTS_CODEMEM_VMA_START=0
SCARTS_CODEMEM_VMA_END=$((SCARTS_CODEMEM_VMA_START + SCARTS_CODEMEM_SIZE - 1))
SCARTS_CODEMEM_LMA_START=$((pow(2, SCARTS_WORD_SIZE - 1)))
SCARTS_CODEMEM_LMA_END=$((SCARTS_CODEMEM_LMA_START + SCARTS_CODEMEM_SIZE - 1))

SCARTS_CODEMEM_USABLE_SIZE=$(($SCARTS_CODEMEM_SIZE))
SCARTS_CODEMEM_USABLE_VMA_END=$((SCARTS_CODEMEM_VMA_START + SCARTS_CODEMEM_USABLE_SIZE - 1))

# Calculate sizes, start addresses and end addresses of the Boot-ROM.
SCARTS_BOOTROM_SIZE=$((SCARTS_BOOTROM_SIZE))
SCARTS_BOOTROM_SIZE_LOG=$((`echo "l($((SCARTS_BOOTROM_SIZE)))/l(2)" | bc -l`))

# The architecture demands the address of the Boot-ROM to be a power of two,
# so that log2 (SCARTS_BOOTROM_VMA_START) is an integer. Also, we must make
# sure that SCARTS_BOOTROM_VMA_START_LOG < 31, since the Boot-ROM is mapped
# into the address of the code memory and:
#
# SCARTS_BOOTROM_LMA_START = SCARTS_CODEMEM_LMA_START | <= 2^31
#                          + SCARTS_BOOTROM_VMA_START |  < 2^31.
# 
# This guarantees that the Boot-ROM fits into the combined address space of
# LMAs (Load Memory Addresses) that is limited to 32 bits in the simulator.

SCARTS_BOOTROM_VMA_START_LOG=$((SCARTS_WORD_SIZE - 1))

if [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
  if [ $SCARTS_BOOTROM_VMA_START_LOG -ge $((SCARTS_WORD_SIZE - 1)) ]; then
    SCARTS_BOOTROM_VMA_START_LOG=$((SCARTS_BOOTROM_VMA_START_LOG - 1))
  fi
fi

SCARTS_BOOTROM_VMA_START=$((pow(2, SCARTS_BOOTROM_VMA_START_LOG)))
SCARTS_BOOTROM_VMA_END=$((SCARTS_BOOTROM_VMA_START + SCARTS_BOOTROM_SIZE - 1))
SCARTS_BOOTROM_LMA_START=$((SCARTS_CODEMEM_LMA_START + SCARTS_BOOTROM_VMA_START))
SCARTS_BOOTROM_LMA_END=$((SCARTS_BOOTROM_LMA_START + SCARTS_BOOTROM_SIZE - 1))

# Calculate sizes, start addresses and end addresses of the data memory.
SCARTS_DATAMEM_SIZE=$((SCARTS_DATAMEM_SIZE))
SCARTS_DATAMEM_SIZE_LOG=$((`echo "l($((SCARTS_DATAMEM_SIZE)))/l(2)" | bc -l`))
SCARTS_DATAMEM_VMA_START=0
SCARTS_DATAMEM_VMA_END=$((SCARTS_DATAMEM_VMA_START + SCARTS_DATAMEM_SIZE - 1))
SCARTS_DATAMEM_LMA_START=0
SCARTS_DATAMEM_LMA_END=$((SCARTS_DATAMEM_LMA_START + SCARTS_DATAMEM_SIZE - 1))

SCARTS_DATAMEM_USABLE_SIZE=$(($SCARTS_DATAMEM_SIZE))
SCARTS_DATAMEM_USABLE_VMA_END=$((SCARTS_DATAMEM_VMA_START + SCARTS_DATAMEM_USABLE_SIZE - 1))

# Map the external modules to the end of the data memory's address space.
SCARTS_DATAMEM_EXTMODS_SIZE=$((SCARTS_DATAMEM_EXTMODS_SIZE))
SCARTS_DATAMEM_EXTMODS_VMA_END=$((pow(2, SCARTS_WORD_SIZE) - 1))
SCARTS_DATAMEM_EXTMODS_VMA_START=$((SCARTS_DATAMEM_EXTMODS_VMA_END - SCARTS_DATAMEM_EXTMODS_SIZE + 1))

# Map the bootloader into the data memory's address space.
SCARTS_DATAMEM_BOOTLOADER_SIZE=$((SCARTS_DATAMEM_BOOTLOADER_SIZE))

if [ $SCARTS_DATAMEM_BOOTLOADER_SIZE -gt 0 ]; then
  SCARTS_DATAMEM_BOOTLOADER_VMA_END=$SCARTS_DATAMEM_USABLE_VMA_END
  SCARTS_DATAMEM_BOOTLOADER_VMA_START=$((SCARTS_DATAMEM_BOOTLOADER_VMA_END - SCARTS_DATAMEM_BOOTLOADER_SIZE + 1))
  SCARTS_DATAMEM_BOOTLOADER_LMA_END=$((SCARTS_DATAMEM_LMA_START + SCARTS_DATAMEM_BOOTLOADER_VMA_END))
  SCARTS_DATAMEM_BOOTLOADER_LMA_START=$((SCARTS_DATAMEM_LMA_START + SCARTS_DATAMEM_BOOTLOADER_VMA_START))

  if [ "$SCARTS_DATAMEM_BOOTLOADER_PERSISTENT" = "true" ]; then
    # The bootloader reduces the usable size of the data memory.
    SCARTS_DATAMEM_USABLE_SIZE=$((SCARTS_DATAMEM_USABLE_SIZE - SCARTS_DATAMEM_BOOTLOADER_SIZE))
    SCARTS_DATAMEM_USABLE_VMA_END=$((SCARTS_DATAMEM_BOOTLOADER_VMA_START - 1))
  fi
fi

if [ $SCARTS_DATAMEM_USABLE_SIZE -lt 0 ]; then
  SCARTS_DATAMEM_USABLE_SIZE=0
fi

##################################
# Linker Script specific options #
##################################

LINKER_SCRIPT_SEARCH_DIR=""
if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
  LINKER_SCRIPT_SEARCH_DIR=$SCARTS_16_TOOLCHAIN_LIB_DIR
elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
  LINKER_SCRIPT_SEARCH_DIR=$SCARTS_32_TOOLCHAIN_LIB_DIR
fi

###########################
# Memmap specific options #
###########################

MEMMAP_SRC_DIR="./src"
MEMMAP_BUILD_DIR="./build"

MEMMAP_DEPS_BOOTLOADER_DIR="bootloader"
MEMMAP_DEPS_CORE_DIR="core"
MEMMAP_DEPS_GDB_DIR="gdb"
MEMMAP_DEPS_GDB_INCLUDE_DIR="$MEMMAP_DEPS_GDB_DIR/include/gdb"
MEMMAP_DEPS_GDB_STUB_DIR="gdb-stub"
MEMMAP_DEPS_MAKE_DIR="make"

#############################
# Makefile specific options #
#############################

MAKEFILE_GCC_BINARY_SCARTS_16="scarts_16-none-eabi-gcc"
MAKEFILE_GCC_BINARY_SCARTS_32="scarts_32-none-eabi-gcc"
MAKEFILE_OBJCOPY_BINARY_SCARTS_16="scarts_16-none-eabi-objcopy"
MAKEFILE_OBJCOPY_BINARY_SCARTS_32="scarts_32-none-eabi-objcopy"
MAKEFILE_OBJDUMP_BINARY_SCARTS_16="scarts_16-none-eabi-objdump"
MAKEFILE_OBJDUMP_BINARY_SCARTS_32="scarts_32-none-eabi-objdump"

MAKEFILE_CFLAGS_DEBUG="-O0 -ggdb --save-temps"
MAKEFILE_CFLAGS_OPT="-O2"
MAKEFILE_LDFLAGS_DEBUG="-Wl,--nmagic,--no-check-sections"
MAKEFILE_LDFLAGS_OPT="-Wl,--nmagic,--no-check-sections,--strip-all"

MAKEFILE_GCC_BINARY=""
MAKEFILE_OBJCOPY_BINARY=""
MAKEFILE_OBJDUMP_BINARY=""
if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
  MAKEFILE_GCC_BINARY=$MAKEFILE_GCC_BINARY_SCARTS_16
  MAKEFILE_OBJCOPY_BINARY=$MAKEFILE_OBJCOPY_BINARY_SCARTS_16
  MAKEFILE_OBJDUMP_BINARY=$MAKEFILE_OBJDUMP_BINARY_SCARTS_16
elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
  MAKEFILE_GCC_BINARY=$MAKEFILE_GCC_BINARY_SCARTS_32
  MAKEFILE_OBJCOPY_BINARY=$MAKEFILE_OBJCOPY_BINARY_SCARTS_32
  MAKEFILE_OBJDUMP_BINARY=$MAKEFILE_OBJDUMP_BINARY_SCARTS_32
fi

MAKEFILE_CFLAGS=""
MAKEFILE_LDFLAGS=""
if [ "$SCARTS_DEBUG_MODE" = "true" ]; then
  MAKEFILE_CFLAGS=$MAKEFILE_CFLAGS_DEBUG
  MAKEFILE_LDFLAGS=$MAKEFILE_LDFLAGS_DEBUG
else
  MAKEFILE_CFLAGS=$MAKEFILE_CFLAGS_OPT
  MAKEFILE_LDFLAGS=$MAKEFILE_LDFLAGS_OPT
fi

# Validate arguments
if [ "$2" != "" ] && [ "$2" != "install" ]; then
  usage
  exit 1
fi

if [ "$MEMMAP_CFG_MACH" != "scarts_16" ] && [ "$MEMMAP_CFG_MACH" != "scarts_32" ]; then
  echo "Error: MEMMAP_CFG_MACH must be one of {\"scarts_16\", \"scarts_32\"}."
  exit 1
fi

echo "#######################"
echo "# Code memory mapping #"
echo "#######################"
echo ""
echo "SCARTS_BOOTROM_SIZE := 0x$(echo "obase=16; $(($SCARTS_BOOTROM_SIZE))" | bc)"
echo "SCARTS_CODEMEM_SIZE := 0x$(echo "obase=16; $(($SCARTS_CODEMEM_SIZE))" | bc)"
echo "SCARTS_CODEMEM_USABLE_SIZE := 0x$(echo "obase=16; $(($SCARTS_CODEMEM_USABLE_SIZE))" | bc)"
echo ""
echo "+--------------------+ <- SCARTS_CODEMEM_START := 0x$(echo "obase=16; $(($SCARTS_CODEMEM_VMA_START))" | bc)"
echo "|      .text         |"
echo "+--------------------+ <- SCARTS_CODEMEM_USABLE_END := 0x$(echo "obase=16; $(($SCARTS_CODEMEM_USABLE_VMA_END))" | bc)"
echo "+--------------------+ <- SCARTS_CODEMEM_END := 0x$(echo "obase=16; $(($SCARTS_CODEMEM_VMA_END))" | bc)"
echo "+--------------------+ <- SCARTS_BOOTROM_START := 0x$(echo "obase=16; $(($SCARTS_BOOTROM_VMA_START))" | bc)"
echo "|      BootROM       |"
echo "+--------------------+ <- SCARTS_BOOTROM_END := 0x$(echo "obase=16; $(($SCARTS_BOOTROM_VMA_END))" | bc)"

if [ $SCARTS_BOOTROM_VMA_END -lt $((pow(2, SCARTS_WORD_SIZE) - 1)) ]; then
  echo "|       Unused       |"
  echo "+--------------------+ <- 0x$(echo "obase=16; $((pow(2, SCARTS_WORD_SIZE) - 1))" | bc)"
fi

echo ""
echo "#######################"
echo "# Data memory mapping #"
echo "#######################"
echo ""
echo "SCARTS_DATAMEM_SIZE := 0x$(echo "obase=16; $((SCARTS_DATAMEM_SIZE))" | bc)"
echo "SCARTS_DATAMEM_BOOTLOADER_SIZE := 0x$(echo "obase=16; $((SCARTS_DATAMEM_BOOTLOADER_SIZE))" | bc)"
echo "SCARTS_DATAMEM_EXTMODS_SIZE := 0x$(echo "obase=16; $((SCARTS_DATAMEM_EXTMODS_SIZE))" | bc)"
echo "SCARTS_DATAMEM_USABLE_SIZE := 0x$(echo "obase=16; $((SCARTS_DATAMEM_USABLE_SIZE))" | bc)"
echo ""
echo "+--------------------+ <- SCARTS_DATAMEM_START := 0x$(echo "obase=16; $((SCARTS_DATAMEM_VMA_START))" | bc)"
echo "|       .data        |"
echo "|       .bss         |"
echo "+--------------------+"
echo "|       Heap         |"
echo ".                    ."
echo ".                    ."
echo ".                    ."
echo "|       Stack        |"
echo "+--------------------+ <- SCARTS_DATAMEM_USABLE_END := 0x$(echo "obase=16; $((SCARTS_DATAMEM_USABLE_VMA_END))" | bc)"

if [ $SCARTS_DATAMEM_BOOTLOADER_SIZE -gt 0 ]; then
  echo "+--------------------+ <- SCARTS_DATAMEM_BOOTLOADER_START := 0x$(echo "obase=16; $((SCARTS_DATAMEM_BOOTLOADER_VMA_START))" | bc)"
  echo "|                    |"
  echo "|     Bootloader     |"
  echo "|                    |"
  echo "+--------------------+ <- SCARTS_DATAMEM_BOOTLOADER_END := 0x$(echo "obase=16; $((SCARTS_DATAMEM_BOOTLOADER_VMA_END))" | bc)"
fi

echo "+--------------------+ <- SCARTS_DATAMEM_END := 0x$(echo "obase=16; $((SCARTS_DATAMEM_VMA_END))" | bc)"

echo "+--------------------+ <- SCARTS_DATAMEM_EXTMODS_START := 0x$(echo "obase=16; $((SCARTS_DATAMEM_EXTMODS_VMA_START))" | bc)"
echo "|                    |"
echo "|      External      |"
echo "|      Modules       |"
echo "|                    |"
echo "+--------------------+ <- SCARTS_DATAMEM_EXTMODS_END := 0x$(echo "obase=16; $((SCARTS_DATAMEM_EXTMODS_VMA_END))" | bc)"

echo ""
echo "#######################"
echo "# Validating settings #"
echo "#######################"
echo ""

echo -n "Validating log2(SCARTS_CODEMEM_SIZE) is integer in [5; $SCARTS_WORD_SIZE] ..."
if [ $(echo "$((int(SCARTS_CODEMEM_SIZE_LOG))) == $SCARTS_CODEMEM_SIZE_LOG" | bc) -eq 0 ] || [ $((SCARTS_CODEMEM_SIZE_LOG-1)) -lt 5 -o $((SCARTS_CODEMEM_SIZE_LOG-1)) -gt $SCARTS_WORD_SIZE ]; then
  echo " failed"
  echo "The size of the code memory (SCARTS_CODEMEM_SIZE := 0x$(echo "obase=16; $(($SCARTS_CODEMEM_SIZE))" | bc)) is not a power of two with log2(SCARTS_CODEMEM_SIZE) in [5; $SCARTS_WORD_SIZE]."
  exit 1
fi
echo " passed"

echo -n "Validating log2(SCARTS_BOOTROM_SIZE) is integer in [0; 16] ..."
if [ $(echo "$((int(SCARTS_BOOTROM_SIZE_LOG))) == $SCARTS_BOOTROM_SIZE_LOG" | bc) -eq 0 ] || [ $SCARTS_BOOTROM_SIZE_LOG -lt 0 -o $SCARTS_BOOTROM_SIZE_LOG -gt 16 ]; then
  echo " failed"
  echo "The size of the Boot-ROM (SCARTS_BOOTROM_SIZE := 0x$(echo "obase=16; $(($SCARTS_BOOTROM_SIZE))" | bc)) is not a power of two with log2(SCARTS_BOOTROM_SIZE) in [0; 16]."
  exit 1
fi
echo " passed"

echo -n "Validating SCARTS_CODEMEM_END < SCARTS_BOOTROM_START ..."
if [ $SCARTS_CODEMEM_VMA_END -ge $SCARTS_BOOTROM_VMA_START ]; then
  echo " failed"
  echo "The code memory (SCARTS_CODEMEM_END := 0x$(echo "obase=16; $((SCARTS_CODEMEM_VMA_END))" | bc)) collides with the address of the Boot-ROM (SCARTS_BOOTROM_START := 0x$(echo "obase=16; $((SCARTS_BOOTROM_START))" | bc))."
  exit 1
fi
echo " passed"

echo -n "Validating SCARTS_CODEMEM_USABLE_SIZE > 0 ..."
if [ $SCARTS_CODEMEM_USABLE_SIZE -le 0 ]; then
  echo " failed"
  echo "The code memory (SCARTS_CODEMEM_USABLE_SIZE := 0x$(echo "obase=16; $((SCARTS_CODEMEM_USABLE_SIZE))" | bc)) has become unusable, increase its size!"
  exit 1
fi
echo " passed"

echo -n "Validating log2(SCARTS_DATAMEM_SIZE) is integer in [5; $SCARTS_WORD_SIZE] ..."
if [ $(echo "$((int(SCARTS_DATAMEM_SIZE_LOG))) == $SCARTS_DATAMEM_SIZE_LOG" | bc) -eq 0 ] || [ $SCARTS_DATAMEM_SIZE_LOG -lt 5 -o $SCARTS_DATAMEM_SIZE_LOG -gt $SCARTS_WORD_SIZE ]; then
  echo " failed"
  echo "The size of the data memory (SCARTS_DATAMEM_SIZE := 0x$(echo "obase=16; $(($SCARTS_DATAMEM_SIZE))" | bc)) is not a power of two with log2(SCARTS_DATAMEM_SIZE) in [5; $SCARTS_WORD_SIZE]."
  exit 1
fi
echo " passed"

echo -n "Validating SCARTS_DATAMEM_END < SCARTS_DATAMEM_EXTMODS_START ..."
if [ $SCARTS_DATAMEM_VMA_END -ge $SCARTS_DATAMEM_EXTMODS_VMA_START ]; then
  echo " failed"
  echo "The data memory (SCARTS_DATAMEM_END := 0x$(echo "obase=16; $((SCARTS_DATAMEM_VMA_END))" | bc)) collides with the address of the external modules (SCARTS_DATAMEM_EXTMODS_START := 0x$(echo "obase=16; $((SCARTS_DATAMEM_EXTMODS_VMA_START))" | bc))."
  exit 1
fi
echo " passed"

echo -n "Validating SCARTS_DATAMEM_USABLE_SIZE > 0 ..."
if [ $SCARTS_DATAMEM_USABLE_SIZE -le 0 ]; then
  echo " failed"
  echo "The data memory (SCARTS_DATAMEM_USABLE_SIZE := 0x$(echo "obase=16; $((SCARTS_DATAMEM_USABLE_SIZE))" | bc)) has become unusable, increase its size!"
  exit 1
fi
echo " passed"

if [ "$2" = "install" ]; then

  echo ""
  echo "###########################"
  echo "# Installing dependencies #"
  echo "###########################"
  echo ""

  # Create missing directories
  if [ ! -d "$MEMMAP_BUILD_DIR" ]; then
    echo -n "Creating directory $MEMMAP_BUILD_DIR ..."
    mkdir -p $MEMMAP_BUILD_DIR
    echo " done"
  fi

  if [ ! -d "$MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH" ]; then
    echo -n "Creating directory $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH ..."
    mkdir -p $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH
    echo " done"
  fi

  if [ ! -d "$MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_BOOTLOADER_DIR" ]; then
    echo -n "Creating directory $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_BOOTLOADER_DIR ..."
    mkdir -p $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_BOOTLOADER_DIR
    echo " done"
  fi

  if [ ! -d "$MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_CORE_DIR" ]; then
    echo -n "Creating directory $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_CORE_DIR ..."
    mkdir -p $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_CORE_DIR
    echo " done"
  fi

  if [ ! -d "$MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_INCLUDE_DIR" ]; then
    echo -n "Creating directory $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_INCLUDE_DIR ..."
    mkdir -p $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_INCLUDE_DIR
    echo " done"
  fi

  if [ ! -d "$MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_STUB_DIR" ]; then
    echo -n "Creating directory $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_STUB_DIR ..."
    mkdir -p $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_STUB_DIR
    echo " done"
  fi

  if [ ! -d "$MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_MAKE_DIR" ]; then
    echo -n "Creating directory $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_MAKE_DIR ..."
    mkdir -p $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_MAKE_DIR
    echo " done"
    echo ""
  fi

  echo "-- SCARTS Bootloader --"

  # Create linker script for bootloader
  SCARTS_BOOTLOADER_LD_SCRIPT=""
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    SCARTS_BOOTLOADER_LD_SCRIPT="scarts_16-bootloader.ld"
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    SCARTS_BOOTLOADER_LD_SCRIPT="scarts_32-bootloader.ld"
  fi

  echo -n "Creating linker script $SCARTS_BOOTLOADER_LD_SCRIPT in $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_BOOTLOADER_DIR ..."
  sed "s/@SCARTS_BOOTROM_LMA_START@/0x$(echo "obase=16; $((SCARTS_BOOTROM_LMA_START))" | bc)/g;
       s/@SCARTS_BOOTROM_SIZE@/0x$(echo "obase=16; $((SCARTS_BOOTROM_SIZE))" | bc)/g;
       s/@SCARTS_BOOTROM_VMA_END@/0x$(echo "obase=16; $((SCARTS_BOOTROM_VMA_END))" | bc)/g;
       s/@SCARTS_BOOTROM_VMA_START@/0x$(echo "obase=16; $((SCARTS_BOOTROM_VMA_START))" | bc)/g;
       s/@SCARTS_DATAMEM_BOOTLOADER_LMA_START@/0x$(echo "obase=16; $((SCARTS_DATAMEM_BOOTLOADER_LMA_START))" | bc)/g;
       s/@SCARTS_DATAMEM_BOOTLOADER_SIZE@/0x$(echo "obase=16; $((SCARTS_DATAMEM_BOOTLOADER_SIZE))" | bc)/g;
       s/@SCARTS_DATAMEM_BOOTLOADER_VMA_END@/0x$(echo "obase=16; $((SCARTS_DATAMEM_BOOTLOADER_VMA_END))" | bc)/g;
       s/@SCARTS_DATAMEM_BOOTLOADER_VMA_START@/0x$(echo "obase=16; $((SCARTS_DATAMEM_BOOTLOADER_VMA_START))" | bc)/g;
       s/@SCARTS_SEARCH_DIR@/\"${LINKER_SCRIPT_SEARCH_DIR//\//\\/}\"/g
       " $MEMMAP_SRC_DIR/$MEMMAP_DEPS_BOOTLOADER_DIR/$SCARTS_BOOTLOADER_LD_SCRIPT > $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_BOOTLOADER_DIR/$SCARTS_BOOTLOADER_LD_SCRIPT
  echo " done"

  # Create Makefile for bootloader
  SCARTS_BOOTLOADER_MAKEFILE=""
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    SCARTS_BOOTLOADER_MAKEFILE="scarts_16-Makefile"
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    SCARTS_BOOTLOADER_MAKEFILE="scarts_32-Makefile"
  fi

  BOOTLOADER_MAKEFILE_CFLAGS=$MAKEFILE_CFLAGS
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    BOOTLOADER_MAKEFILE_CFLAGS=$BOOTLOADER_MAKEFILE_CFLAGS' -I$(INST_SCARTS_TOOLCHAIN_GDB_DIR)\/include'
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    BOOTLOADER_MAKEFILE_CFLAGS=$BOOTLOADER_MAKEFILE_CFLAGS' -I$(INST_SCARTS_TOOLCHAIN_GDB_DIR)\/include'
  fi

  BOOTLOADER_MAKEFILE_PROGRAM=""
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    BOOTLOADER_MAKEFILE_PROGRAM="scarts_16-bootloader"
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    BOOTLOADER_MAKEFILE_PROGRAM="scarts_32-bootloader"
  fi

  echo -n "Creating $SCARTS_BOOTLOADER_MAKEFILE in $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_BOOTLOADER_DIR ..."
  sed "s/@MAKEFILE_CFLAGS@/$BOOTLOADER_MAKEFILE_CFLAGS/g;
       s/@MAKEFILE_GCC_BINARY@/$MAKEFILE_GCC_BINARY/g;
       s/@MAKEFILE_LDFLAGS@/$MAKEFILE_LDFLAGS/g;
       s/@MAKEFILE_LINKER_SCRIPT@/$SCARTS_BOOTLOADER_LD_SCRIPT/g;
       s/@MAKEFILE_OBJCOPY_BINARY@/$MAKEFILE_OBJCOPY_BINARY/g;
       s/@MAKEFILE_OBJDUMP_BINARY@/$MAKEFILE_OBJDUMP_BINARY/g;
       s/@MAKEFILE_PROGRAM@/$BOOTLOADER_MAKEFILE_PROGRAM/g
       " $MEMMAP_SRC_DIR/$MEMMAP_DEPS_BOOTLOADER_DIR/Makefile > $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_BOOTLOADER_DIR/$SCARTS_BOOTLOADER_MAKEFILE
  echo " done"
  echo ""

  echo "-- SCARTS Core --"

  # Create scarts.cmp
  echo -n "Creating scarts.cmp for machine $MEMMAP_CFG_MACH in $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_CORE_DIR ..."
  sed "s/@SCARTS_BOOTROM_SIZE_LOG@/$((SCARTS_BOOTROM_SIZE_LOG-1))/g;
       s/@SCARTS_BOOTROM_START_LOG@/$SCARTS_BOOTROM_VMA_START_LOG/g;
       s/@SCARTS_CODEMEM_SIZE_LOG@/$((SCARTS_CODEMEM_SIZE_LOG-1))/g;
       s/@SCARTS_DATAMEM_SIZE_LOG@/$SCARTS_DATAMEM_SIZE_LOG/g;
       s/@SCARTS_GDB_MODE@/$SCARTS_GDB_MODE/g;
       s/@SCARTS_WORD_SIZE@/$SCARTS_WORD_SIZE/g
       " $MEMMAP_SRC_DIR/$MEMMAP_DEPS_CORE_DIR/scarts.cmp > $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_CORE_DIR/scarts.cmp
  echo " done"
  echo ""

  echo "-- SCARTS GDB Simulator --"

  # Create sim-scarts.h for GDB
  SCARTS_MACHINE_NAME=""
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    SCARTS_MACHINE_NAME="SCARTS_16"
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    SCARTS_MACHINE_NAME="SCARTS_32"
  fi

  SCARTS_SIM_INCLUDE_FILE=""
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    SCARTS_SIM_INCLUDE_FILE="sim-scarts_16.h"
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    SCARTS_SIM_INCLUDE_FILE="sim-scarts_32.h"
  fi

  echo -n "Creating $SCARTS_SIM_INCLUDE_FILE for machine $MEMMAP_CFG_MACH in $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_INCLUDE_DIR ..."
  sed "s/@SCARTS_BOOTMEM_VMA@/0x$(echo "obase=16; $((SCARTS_BOOTROM_VMA_START))" | bc)/g;
       s/@SCARTS_BOOTMEM_LMA@/0x$(echo "obase=16; $((SCARTS_BOOTROM_LMA_START))" | bc)/g;
       s/@SCARTS_BOOTMEM_SIZE@/0x$(echo "obase=16; $((SCARTS_BOOTROM_SIZE/2))" | bc)/g;
       s/@SCARTS_CODEMEM_VMA@/0x$(echo "obase=16; $((SCARTS_CODEMEM_VMA_START))" | bc)/g;
       s/@SCARTS_CODEMEM_LMA@/0x$(echo "obase=16; $((SCARTS_CODEMEM_LMA_START))" | bc)/g;
       s/@SCARTS_CODEMEM_SIZE@/0x$(echo "obase=16; $((SCARTS_CODEMEM_SIZE/2))" | bc)/g;
       s/@SCARTS_DATAMEM_VMA@/0x$(echo "obase=16; $((SCARTS_DATAMEM_VMA_START))" | bc)/g;
       s/@SCARTS_DATAMEM_LMA@/0x$(echo "obase=16; $((SCARTS_DATAMEM_LMA_START))" | bc)/g;
       s/@SCARTS_DATAMEM_SIZE@/0x$(echo "obase=16; $((SCARTS_DATAMEM_SIZE))" | bc)/g;
       s/@SCARTS_MACHINE_NAME@/$SCARTS_MACHINE_NAME/g;
       s/@SCARTS_WORD_SIZE@/$((SCARTS_WORD_SIZE/8))/g
       " $MEMMAP_SRC_DIR/$MEMMAP_DEPS_GDB_INCLUDE_DIR/sim-scarts.h > $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_INCLUDE_DIR/$SCARTS_SIM_INCLUDE_FILE
  echo " done"
  echo ""

  echo "-- SCARTS GDB-Stub --"

  # Create linker script for GDB-stub
  SCARTS_GDB_STUB_LD_SCRIPT=""
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    SCARTS_GDB_STUB_LD_SCRIPT="scarts_16-gdb-stub.ld"
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    SCARTS_GDB_STUB_LD_SCRIPT="scarts_32-gdb-stub.ld"
  fi

  echo -n "Creating linker script $SCARTS_GDB_STUB_LD_SCRIPT in $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_STUB_DIR ..."
  sed "s/@SCARTS_BOOTROM_LMA_START@/0x$(echo "obase=16; $((SCARTS_BOOTROM_LMA_START))" | bc)/g;
       s/@SCARTS_BOOTROM_SIZE@/0x$(echo "obase=16; $((SCARTS_BOOTROM_SIZE))" | bc)/g;
       s/@SCARTS_BOOTROM_VMA_END@/0x$(echo "obase=16; $((SCARTS_BOOTROM_VMA_END))" | bc)/g;
       s/@SCARTS_BOOTROM_VMA_START@/0x$(echo "obase=16; $((SCARTS_BOOTROM_VMA_START))" | bc)/g;
       s/@SCARTS_DATAMEM_BOOTLOADER_SIZE@/0x$(echo "obase=16; $((SCARTS_DATAMEM_BOOTLOADER_SIZE))" | bc)/g;
       s/@SCARTS_DATAMEM_BOOTLOADER_LMA_START@/0x$(echo "obase=16; $((SCARTS_DATAMEM_BOOTLOADER_LMA_START))" | bc)/g;
       s/@SCARTS_DATAMEM_BOOTLOADER_VMA_END@/0x$(echo "obase=16; $((SCARTS_DATAMEM_BOOTLOADER_VMA_END))" | bc)/g;
       s/@SCARTS_DATAMEM_BOOTLOADER_VMA_START@/0x$(echo "obase=16; $((SCARTS_DATAMEM_BOOTLOADER_VMA_START))" | bc)/g;
       s/@SCARTS_SEARCH_DIR@/\"${LINKER_SCRIPT_SEARCH_DIR//\//\\/}\"/g
       " $MEMMAP_SRC_DIR/$MEMMAP_DEPS_GDB_STUB_DIR/$SCARTS_GDB_STUB_LD_SCRIPT > $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_STUB_DIR/$SCARTS_GDB_STUB_LD_SCRIPT
  echo " done"

  # Create Makefile for GDB-stub
  SCARTS_GDBSTUB_MAKEFILE=""
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    SCARTS_GDBSTUB_MAKEFILE="scarts_16-Makefile"
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    SCARTS_GDBSTUB_MAKEFILE="scarts_32-Makefile"
  fi

  GDBSTUB_MAKEFILE_CFLAGS=$MAKEFILE_CFLAGS' -I$(INST_SCARTS_TOOLCHAIN_GDB_DIR)\/gdb -I$(INST_SCARTS_TOOLCHAIN_GDB_DIR)\/include'
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    GDBSTUB_MAKEFILE_CFLAGS=$GDBSTUB_MAKEFILE_CFLAGS' -I$(INST_SCARTS_TOOLCHAIN_GDB_DIR)\/..\/assets\/sim-plugins\/scarts_16'
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    GDBSTUB_MAKEFILE_CFLAGS=$GDBSTUB_MAKEFILE_CFLAGS' -I$(INST_SCARTS_TOOLCHAIN_GDB_DIR)\/..\/assets\/sim-plugins\/scarts_32'
  fi

  GDBSTUB_MAKEFILE_PROGRAM=""
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    GDBSTUB_MAKEFILE_PROGRAM="scarts_16-gdb-stub"
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    GDBSTUB_MAKEFILE_PROGRAM="scarts_32-gdb-stub"
  fi

  echo -n "Creating $SCARTS_GDBSTUB_MAKEFILE in $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_STUB_DIR ..."
  sed "s/@MAKEFILE_CFLAGS@/$GDBSTUB_MAKEFILE_CFLAGS/g;
       s/@MAKEFILE_GCC_BINARY@/$MAKEFILE_GCC_BINARY/g;
       s/@MAKEFILE_LDFLAGS@/$MAKEFILE_LDFLAGS/g;
       s/@MAKEFILE_LINKER_SCRIPT@/$SCARTS_GDB_STUB_LD_SCRIPT/g;
       s/@MAKEFILE_OBJCOPY_BINARY@/$MAKEFILE_OBJCOPY_BINARY/g;
       s/@MAKEFILE_OBJDUMP_BINARY@/$MAKEFILE_OBJDUMP_BINARY/g;
       s/@MAKEFILE_PROGRAM@/$GDBSTUB_MAKEFILE_PROGRAM/g
       " $MEMMAP_SRC_DIR/$MEMMAP_DEPS_GDB_STUB_DIR/Makefile > $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_STUB_DIR/$SCARTS_GDBSTUB_MAKEFILE
  echo " done"
  echo ""

  echo "-- SCARTS Makefile --"

  # Create default linker script
  MEMMAP_LD_SCRIPT=""
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    MEMMAP_LD_SCRIPT=$MEMMAP_SRC_DIR/$MEMMAP_DEPS_MAKE_DIR/scarts_16.ld
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    MEMMAP_LD_SCRIPT=$MEMMAP_SRC_DIR/$MEMMAP_DEPS_MAKE_DIR/scarts_32.ld
  fi

  echo -n "Creating default linker script ${MEMMAP_CFG_MACH}_$MEMMAP_CFG_NAME.ld for machine $MEMMAP_CFG_MACH in $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_MAKE_DIR ..."
  sed "s/@SCARTS_CODEMEM_LMA_START@/0x$(echo "obase=16; $((SCARTS_CODEMEM_LMA_START))" | bc)/g;
       s/@SCARTS_CODEMEM_USABLE_SIZE@/0x$(echo "obase=16; $((SCARTS_CODEMEM_USABLE_SIZE))" | bc)/g;
       s/@SCARTS_CODEMEM_USABLE_VMA_END@/0x$(echo "obase=16; $((SCARTS_CODEMEM_USABLE_VMA_END))" | bc)/g;
       s/@SCARTS_CODEMEM_VMA_START@/0x$(echo "obase=16; $((SCARTS_CODEMEM_VMA_START))" | bc)/g;
       s/@SCARTS_DATAMEM_LMA_START@/0x$(echo "obase=16; $((SCARTS_DATAMEM_LMA_START))" | bc)/g;
       s/@SCARTS_DATAMEM_USABLE_SIZE@/0x$(echo "obase=16; $((SCARTS_DATAMEM_USABLE_SIZE))" | bc)/g;
       s/@SCARTS_DATAMEM_USABLE_VMA_END@/0x$(echo "obase=16; $((SCARTS_DATAMEM_USABLE_VMA_END))" | bc)/g;
       s/@SCARTS_DATAMEM_VMA_START@/0x$(echo "obase=16; $((SCARTS_DATAMEM_VMA_START))" | bc)/g;
       s/@SCARTS_SEARCH_DIR@/\"${LINKER_SCRIPT_SEARCH_DIR//\//\\/}\"/g
       " $MEMMAP_LD_SCRIPT > $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_MAKE_DIR/${MEMMAP_CFG_MACH}-$MEMMAP_CFG_NAME.ld
  echo " done"

  # Create default Makefile
  SCARTS_DEFAULT_MAKEFILE=""
  if [ "$MEMMAP_CFG_MACH" = "scarts_16" ]; then
    SCARTS_DEFAULT_MAKEFILE="scarts_16-Makefile"
  elif [ "$MEMMAP_CFG_MACH" = "scarts_32" ]; then
    SCARTS_DEFAULT_MAKEFILE="scarts_32-Makefile"
  fi

  echo -n "Creating default $SCARTS_DEFAULT_MAKEFILE for machine $MEMMAP_CFG_MACH in $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_MAKE_DIR ..."
  sed "s/@MAKEFILE_CFLAGS@/$MAKEFILE_CFLAGS/g;
       s/@MAKEFILE_GCC_BINARY@/$MAKEFILE_GCC_BINARY/g;
       s/@MAKEFILE_LDFLAGS@/$MAKEFILE_LDFLAGS/g;
       s/@MAKEFILE_LINKER_SCRIPT@/${MEMMAP_CFG_MACH}-$MEMMAP_CFG_NAME.ld/g;
       s/@MAKEFILE_OBJCOPY_BINARY@/$MAKEFILE_OBJCOPY_BINARY/g;
       s/@MAKEFILE_OBJDUMP_BINARY@/$MAKEFILE_OBJDUMP_BINARY/g
       " $MEMMAP_SRC_DIR/$MEMMAP_DEPS_MAKE_DIR/Makefile > $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_MAKE_DIR/$SCARTS_DEFAULT_MAKEFILE
  echo " done"

  echo ""
  echo "#############################"
  echo "# Installation instructions #"
  echo "#############################"
  echo ""

  echo "-- SCARTS Bootloader --"
  echo "Copy $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_BOOTLOADER_DIR/$SCARTS_BOOTLOADER_LD_SCRIPT into the directory of the SCARTS Bootloader."
  echo "Copy $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_BOOTLOADER_DIR/$SCARTS_BOOTLOADER_MAKEFILE into the directory of the SCARTS Bootloader and compile."
  echo ""

  echo "-- SCARTS Core --"
  echo "Copy $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_CORE_DIR/scarts_conf.vhd into the SCARTS Core project and recompile it."
  echo ""

  echo "-- SCARTS GDB Simulator --"
  echo "Copy $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_INCLUDE_DIR/$SCARTS_SIM_INCLUDE_FILE into the include/gdb directory of the SCARTS GDB and compile."
  echo ""

  echo "-- SCARTS GDB-Stub --"
  echo "Copy $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_STUB_DIR/$SCARTS_GDB_STUB_LD_SCRIPT into the directory of the SCARTS GDB-Stub."
  echo "Copy $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_GDB_STUB_DIR/$SCARTS_GDBSTUB_MAKEFILE into the directory of the SCARTS GDB-Stub and compile."
  echo ""

  echo "-- SCARTS Makefile --"
  echo "Copy $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_MAKE_DIR/$SCARTS_DEFAULT_MAKEFILE into your application's build directory and use it for compilation."
  echo "Copy $MEMMAP_BUILD_DIR/$MEMMAP_CFG_NAME/$MEMMAP_CFG_MACH/$MEMMAP_DEPS_MAKE_DIR/${MEMMAP_CFG_MACH}_$MEMMAP_CFG_NAME.ld into your application's build directory, the linker will automatically include it."
  echo "    Optionally you could specify the location of ${MEMMAP_CFG_MACH}_$MEMMAP_CFG_NAME.ld via the -L option in the LDFLAGS directive of your Makefile."
fi


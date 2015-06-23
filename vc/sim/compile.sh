#!/bin/bash
#
# Asynchronous SDM NoC
# (C)2012 Wei Song
# Advanced Processor Technologies Group
# Computer Science, the Univ. of Manchester, UK
# 
# Authors: 
# Wei Song     wsong83@gmail.com
# 
# License: LGPL 3.0 or later
# 
# The script to compile the SystemC/Verilog mixed NoC simulation
#   
# History:
# 05/06/2011  CLean up for opensource. <wsong83@gmail.com>
#

# make sure the LDVHOME environment is ready for NC-Simulator, IUS/LDV,  Cadence
export NCSC_GCC=${LDVHOME}/tools/systemc/gcc/bin/g++

CXXFLAG="-c -g -Wall -I../../common/tb -I../tb -I../"

# remove the files from last run
rm -fr INCA_libs
rm *.o
rm *.so

# compile verilog files
# cell library
ncvlog -nowarn RECOMP ../../lib/NangateOpenCellLibrary_typical_conditional.v
# the synthesised netlist, available after synthesis
ncvlog ../syn/file/router_syn.v
# other verilog test bench files
ncvlog     -incdir ../ ../../common/tb/anaproc.v
ncvlog -sv -incdir ../ ../tb/rtwrapper.v
ncvlog     -incdir ../ ../tb/netnode.v
ncvlog -sv -incdir ../ ../tb/noc_top.v
ncvlog -sv -incdir ../ ../tb/node_top.v
ncvlog                 ../tb/noctb.v

#compile SystemC files
ncsc -compiler $NCSC_GCC -cflags "${CXXFLAG}" ../../common/tb/sim_ana.cpp
ncsc -compiler $NCSC_GCC -cflags "${CXXFLAG}" ../../common/tb/anaproc.cpp
ncsc -compiler $NCSC_GCC -cflags "${CXXFLAG}" ../tb/netnode.cpp
ncsc -compiler $NCSC_GCC -cflags "${CXXFLAG}" ../tb/ni.cpp
ncsc -compiler $NCSC_GCC -cflags "${CXXFLAG}" ../tb/rtdriver.cpp

# build the run time link library
${NCSC_GCC}  -Wl -shared -o sysc.so -L${CDS_LNX86_ROOT}/ldv_2009_sc/tools/lib \
 sim_ana.o anaproc.o netnode.o ni.o rtdriver.o \
 ${CDS_LNX86_ROOT}/ldv_2009_sc/tools/systemc/lib/gnu/libncscCoSim_sh.so \
 ${CDS_LNX86_ROOT}/ldv_2009_sc/tools/systemc/lib/gnu/libncscCoroutines_sh.so \
 ${CDS_LNX86_ROOT}/ldv_2009_sc/tools/systemc/lib/gnu/libsystemc_sh.so

# elaborate the simulation
ncelab -timescale 1ns/1ps -access +rwc -loadsc sysc.so worklib.noctb


#!/bin/sh

XILINXPATH="c:/Xilinx/12.3/ISE_DS/ISE"

# This script should be run from the testbench directory.

LIB_NAME=unisims_lib
LIB_DIR=./$LIB_NAME

rm -r -f $LIB_DIR
vlib $LIB_DIR
vmap $LIB_NAME $LIB_DIR

OPTS=""

vlog -work $LIB_NAME $OPTS $XILINXPATH/verilog/src/glbl.v
vlog -work $LIB_NAME $OPTS $XILINXPATH/verilog/src/unisims/[A-J]*.v
vlog -work $LIB_NAME $OPTS $XILINXPATH/verilog/src/unisims/[K-Q]*.v
vlog -work $LIB_NAME $OPTS $XILINXPATH/verilog/src/unisims/[R-Z]*.v

date


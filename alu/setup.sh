#!/bin/bash -f
# update as required

ALU_BASE=`pwd`
ALU_COMPONENTS="$ALU_BASE/.."
ALU_RTL="$ALU_BASE/rtl/verilog"
export ALU_BASE ALU_COMPONENTS ALU_RTL
echo "#####"
printenv | grep ALU_
echo "Ok."
echo "#####"

#!/bin/bash -f
# update as required

export ECPU_BASE=`pwd`
export ECPU_COMPONENTS="$ECPU_BASE/components"
export ECPU_ALU_BASE="$ECPU_COMPONENTS/alu"
export ECPU_ALU_RTL="$ECPU_ALU_BASE/rtl/verilog"
export ECPU_RTL="$ECPU_BASE/rtl/verilog"

echo "#####"
printenv | grep ECPU_
echo "Ok."
echo "#####"

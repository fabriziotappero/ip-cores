#!/bin/bash

../../../../robust -null
if [ $? -eq 0 ];then
  ROBUST=../../../../robust
else
  echo "RobustVerilog warning: GUI version not supported - using non-GUI version robust-lite"
  ROBUST=../../../../robust-lite
fi

#$ROBUST src/base/fir.v ../src/base/def_fir_top.txt -od out -I ../src/gen -list list.txt -listpath -header -gui ${@}
$ROBUST ../robust_fir.pro -gui ${@}

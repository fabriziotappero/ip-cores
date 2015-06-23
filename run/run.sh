#!/bin/bash

../../../../robust -null
if [ $? -eq 0 ];then
  ROBUST=../../../../robust
else
  echo "RobustVerilog warning: GUI version not supported - using non-GUI version robust-lite"
  ROBUST=../../../../robust-lite
fi

#$ROBUST src/base/regfile_top.txt -od out -list list.txt -listpath -gui ${@}
$ROBUST ../robust_reg.pro -gui ${@}

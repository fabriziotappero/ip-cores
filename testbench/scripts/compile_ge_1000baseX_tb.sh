#!/bin/bash

LIB_NAME=ge_1000baseX_tb_lib
LIB_DIR=./$LIB_NAME

if [[ $# == 0 ]]; then
  echo "Removing libraries..."
  mv -f $LIB_DIR ${LIB_DIR}_tmp
  rm -r -f ${LIB_DIR}_tmp &
  vlib $LIB_DIR
  vmap $LIB_NAME $LIB_DIR
fi

OPTS="-quiet -sv"

INCLUDES="
 +incdir+../rtl/verilog\
 +incdir+./rtl/verilog"

tests="
 ge_1000baseX_tb_script\
 ge_1000baseX_tb"

packages="
 tb_utils\
 packet\
 ethernet_frame\
 ethernet_threads\
 interfaces\
 ge_1000baseX_utils\
 encoder_8b10b_threads"


models="
 clock_gen\
 mdio_serial_model\
 gmii_rx_model\
 gmii_tx_model\
 encoder_8b_tx_model\
 encoder_10b_rx_model\
 decoder_8b_rx_model"

if [[  $1 == "tests" ]]; then
  files=$tests
elif [[  $1 == "models" ]]; then
  files=$models
elif [[  $1 == "packages" ]]; then
  files=$packages
else
  files="$packages $tests $models"
fi

for filename in $files; do
  f="rtl/verilog/$filename.v"
  echo "Compiling $f"
  if ! vlog -work $LIB_NAME $OPTS $INCLUDES $f; then
    echo "COMPILE FAILED!"
    exit
  fi
done

date


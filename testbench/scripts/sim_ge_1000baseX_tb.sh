#!/bin/bash

TEST_NAME="ge_1000baseX_tb"

if [[ $1 != "" ]]; then
  TEST_NAME=$1
fi

LIBS="-L ge_1000baseX_lib -L unisims_lib"

TB="ge_1000baseX_tb_lib.ge_1000baseX_tb"

vsim -permit_unmatched_virtual_intf  -gui $TB -Gtest_name=\"$TEST_NAME\" $LIBS &



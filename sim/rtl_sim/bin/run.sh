#!/bin/bash

# Test sfixed rounding
#../../../sw/gentestround -signed -iw 4 -fw 4 -step 0.25 ../../../gen/vhdl/testroundings.vhd
#./testroundings.sh

# Test ufixed rounding
../../../sw/gentestround -unsigned -iw 4 -fw 4 -step 0.25 ../../../gen/vhdl/testroundingu.vhd
./testroundingu.sh

if [ "$SECONDS" -eq 1 ]
then
  units=second
else
  units=seconds
fi
echo "This script has been running for $SECONDS $units."
exit 0

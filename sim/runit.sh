#!/bin/sh -f

# remove old run file
rm -rf ./run_ecpu


if [ ! -n "$1" ]; then
  EXTRA_OPTS=""
else
  EXTRA_OPTS="$*"
fi

INCDIR="-I $ECPU_ALU_RTL -I $ECPU_RTL"

if [ ! -n "$ECPU_BARREL_SHIFTER" ]; then
  ECPU_BARREL_SHIFTER="$ECPU_COMPONENTS/barrel_shifter/simple/barrel_shifter_simple.v"
  export ECPU_BARREL_SHIFTER
fi

if [ ! -n "$ECPU_ADDER" ]; then
  ECPU_ADDER="$ECPU_COMPONENTS/adder/alu_adder.v"
  export ECPU_ADDER
fi


echo "Using iverilog options $EXTRA_OPTS"

cmd="iverilog ${EXTRA_OPTS} $INCDIR -f rtl.list -f tb.list -o run_ecpu"
echo $cmd
$cmd |tee log

if [ ! -n "$NO_SIM" ]; then

  if [ -e ./run_ecpu ]; then
    ./run_ecpu
  else
    echo "ERROR : Could not build design"
  fi

fi

#!/bin/sh
IN=$1

echo "memory_initialization_radix=2;"
echo "memory_initialization_vector="

cat $IN | tr [0-9] '8' | tr '+' '8' | tr '-' '8' | grep -v "8" >psf2coe.tmp

for L in `cat psf2coe.tmp | sed s/" "/0/g | sed s/"X"/1/g`
do
      echo "$L," 

done

#rm psf2coe.tmp

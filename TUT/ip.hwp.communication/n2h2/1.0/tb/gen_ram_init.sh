#!/bin/bash

echo
echo "Generating ram_init.dat, don't mind the possible rm error"
echo

rm ram_init.dat

for i in {1..102400}
do
    echo $i >> ram_init.dat
done

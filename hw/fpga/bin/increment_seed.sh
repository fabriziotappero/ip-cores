#/bin/sh -f
# Simple script to increment a number in a file
NUM=`cat $1`
NUM=$(($NUM + 2 ))
echo $NUM > $1
echo $NUM

#!/bin/bash

if [ -z "$1" -o -z "$2" ]
then
  echo "This program recodes movies into mjpeg format suitable"
  echo "for running on Sebastian Manz' FPGA mjpeg decoder. You"
  echo "should install transcode to use this script."
  echo "Usage: $0 <infile> <outfile>"
  echo
  echo "<infile>:  The source file. The input formats allowed depend on your transcode installation."
  echo "<outfile>: The resulting mjpeg file in an avi container (no sound, \".avi\" will be appended)."
  exit 1
fi

INFILE="$1"
OUTFILE="${2}.avi"



transcode -i $INFILE -o $OUTFILE -y mjpeg,null --export_fps 20 || exit 1

echo "ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE ENDE" >> $OUTFILE

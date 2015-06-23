#!/bin/sh
#
# Downloads an executable object file in the S-Record format to
# the SCARTS bootloader running in the SCARTS simulator.
#
# Author: Martin Walter, mwalter@opencores.org


if [ $# -ne 2 ]; then
  echo 1>&2 Usage: $0 FILE DEVICE
  echo 1>&2 Downloads an executable object file in the S-Record format in FILE to the SCARTS bootloader
  echo 1>&2 running in the SCARTS simulator awaiting data on the pseudo-terminal slave device in DEVICE.
  echo 1>&2 Example: $0 main.srec /dev/pts/1
  exit 1
fi


while read line; do
  echo "$line" > $2
done < $1


#!/bin/bash
sed "s/\$Version:[^\$]\+/\$Version: $1 /g" $2  | 
  sed "s/\$Date:[^\$]\+/\$Date: $(date -R) /g" > $2.tmp
mv $2.tmp $2

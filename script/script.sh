#/bin/sh

# $Id: script.sh,v 1.1 2005-02-11 03:44:21 arif_endro Exp $
#
# This old script was used in designing simple FM receiver
# This script is used to make ROM in that design
# This is because i'm too lazy to write manually (it's approx. 1024 lines).
# This script also usefull for other purpose.
# 
# I put this file in CVS repository so I can used it again some other time
# when I need it. This script is slow, but it's works well.
#
# Output format of this script will looks like this
# BXXXXXXXX when BXXXXXXXXXX, -- INDEX XXX
# ^-> 8bit input  ^-> 10bit address 
# input data is taken from input file
# The input file must simple list of value
#
# Author  : "Arif E. Nugroho" <arif_endro@yahoo.com>
#
# Copyright (c) 2005 Arif E. Nugroho

Z=0
A=0
B=0
C=0
D=0
E=0
F=0
G=0
H=0
I=0
J=0

# Change this file name to suite yours
if [ ! -z $1 ]; then
	input_file=$1
else
	input_file="cos.txt"
fi

if [ -r $input_file ] ; then
for list in `cat $input_file` 

do
  tmp0=`expr $Z %    2`
  tmp1=`expr $Z %    4`
  tmp2=`expr $Z %    8`
  tmp3=`expr $Z %   16`
  tmp4=`expr $Z %   32`
  tmp5=`expr $Z %   64`
  tmp6=`expr $Z %  128`
  tmp7=`expr $Z %  256`
  tmp8=`expr $Z %  512`
  if [ $tmp0 = 1 ] 
    then 
      J=1
  fi
  if [ $tmp0 = 0 ]
    then
      J=0
  fi
  if [ $tmp1 = 0 -o $tmp1 = 1 ]
    then
     I=0
  fi
  if [ $tmp1 = 2 -o $tmp1 = 3 ]
    then
     I=1
  fi
  if [ $tmp2 = 0 -o $tmp2 = 1 -o $tmp2 = 2 -o $tmp2 = 3 ]
    then
     H=0
  fi
  if [ $tmp2 = 4 -o $tmp2 = 5 -o $tmp2 = 6 -o $tmp2 = 7 ]
    then
     H=1
  fi
  if [ $tmp3 -le 7 ]
     then
     G=0
  fi
  if [ $tmp3 -gt 7 ]
     then
     G=1
  fi
  if [ $tmp4 -le 15 ]
     then
     F=0
  fi
  if [ $tmp4 -gt 15 ]
     then
     F=1
  fi
  if [ $tmp5 -le 31 ]
     then
     E=0
  fi
  if [ $tmp5 -gt 31 ]
     then
     E=1
  fi
  if [ $tmp6 -le 63 ]
     then
     D=0
  fi
  if [ $tmp6 -gt 63 ]
     then
     D=1
  fi
  if [ $tmp7 -le 127 ]
     then
     C=0
  fi
  if [ $tmp7 -gt 127 ]
     then
     C=1
  fi
  if [ $tmp8 -le 255 ]
     then
     B=0
  fi
  if [ $tmp8 -gt 255 ]
     then
     B=1
  fi
  if [ $Z -le 511 ]
     then
     A=0
  fi
  if [ $Z -gt 511 ]
     then
     A=1
  fi
  # echo "$tmp0"
  # echo "$tmp1"
  # echo "$tmp2"
  # echo "$tmp3"
  # echo "$tmp4"
  # echo "$tmp5"
  # echo "$tmp6"
  # echo "$tmp7"
  # echo "$tmp8"
  echo "B\"$list\" when B\"$A$B$C$D$E$F$G$H$I$J\",  -- INDEX $Z"
  Z=`expr $Z + 1`

done

else
#	echo "Input file: $input_file doesn't exist";
	echo "Input file or file cos.txt doesn't exist";
	echo "Usage: `basename $0` input_file";
fi

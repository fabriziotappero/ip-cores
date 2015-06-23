#/bin/sh

# $Id: script.sh,v 1.1.1.1 2005-11-15 01:51:51 arif_endro Exp $
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
# BX when BXXXXXXXXXXXXXXX, -- INDEX XXX
# ^-> 1bit ^-> 15bit address 
# input data is taken from input file
# The input file must simple list of value
#
# Author  : "Arif E. Nugroho" <arif_endro@yahoo.com>
#
# Copyright (C) 2005 Arif E. Nugroho
###############################################################################
## 
## 	THIS SOURCE FILE MAY BE USED AND DISTRIBUTED WITHOUT RESTRICTION
## PROVIDED THAT THIS COPYRIGHT STATEMENT IS NOT REMOVED FROM THE FILE AND THAT
## ANY DERIVATIVE WORK CONTAINS THE ORIGINAL COPYRIGHT NOTICE AND THE
## ASSOCIATED DISCLAIMER.
## 
###############################################################################
## 
## 	THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
## IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
## EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
## SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
## PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
## OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
## WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
## OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
## ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## 
###############################################################################

Z=0
A=0 # 1
B=0 # 2
C=0 # 3
D=0 # 4
E=0 # 5
F=0 # 6
G=0 # 7
H=0 # 8
I=0 # 9
J=0 # 10
K=0 # 11
L=0 # 12
M=0 # 13
N=0 # 14
O=0 # 15

# Change this file name to suite yours
if [ ! -z $1 ]; then
	input_file=$1
else
	input_file="cos.txt"
fi

if [ -r $input_file ] ; then
for list in `cat $input_file` 

do
  tmp0=`expr $Z %      2`
  tmp1=`expr $Z %      4`
  tmp2=`expr $Z %      8`
  tmp3=`expr $Z %     16`
  tmp4=`expr $Z %     32`
  tmp5=`expr $Z %     64`
  tmp6=`expr $Z %    128`
  tmp7=`expr $Z %    256`
  tmp8=`expr $Z %    512`
  tmp9=`expr $Z %   1024`
  tmp10=`expr $Z %  2048`
  tmp11=`expr $Z %  4096`
  tmp12=`expr $Z %  8192`
  tmp13=`expr $Z % 16384`

  if [ $tmp0 = 1 ] 
    then 
      O=1
  fi
  if [ $tmp0 = 0 ]
    then
      O=0
  fi

  if [ $tmp1 -le 1 ]
    then
     N=0
  fi
  if [ $tmp1 -gt 1 ]
    then
     N=1
  fi

  if [ $tmp2 -le 3 ]
    then
     M=0
  fi
  if [ $tmp2 -gt 3 ]
    then
     M=1
  fi

  if [ $tmp3 -le 7 ]
     then
     L=0
  fi
  if [ $tmp3 -gt 7 ]
     then
     L=1
  fi

  if [ $tmp4 -le 15 ]
     then
     K=0
  fi
  if [ $tmp4 -gt 15 ]
     then
     K=1
  fi

  if [ $tmp5 -le 31 ]
     then
     J=0
  fi
  if [ $tmp5 -gt 31 ]
     then
     J=1
  fi

  if [ $tmp6 -le 63 ]
     then
     I=0
  fi
  if [ $tmp6 -gt 63 ]
     then
     I=1
  fi

  if [ $tmp7 -le 127 ]
     then
     H=0
  fi
  if [ $tmp7 -gt 127 ]
     then
     H=1
  fi

  if [ $tmp8 -le 255 ]
     then
     G=0
  fi
  if [ $tmp8 -gt 255 ]
     then
     G=1
  fi

  if [ $tmp9 -le 511 ]
     then
     F=0
  fi
  if [ $tmp9 -gt 511 ]
     then
     F=1
  fi

  if [ $tmp10 -le 1023 ]
     then
     E=0
  fi
  if [ $tmp10 -gt 1023 ]
     then
     E=1
  fi

  if [ $tmp11 -le 2047 ]
     then
     D=0
  fi
  if [ $tmp11 -gt 2047 ]
     then
     D=1
  fi

  if [ $tmp12 -le 4095 ]
     then
     C=0
  fi
  if [ $tmp12 -gt 4095 ]
     then
     C=1
  fi

  if [ $tmp13 -le 8191 ]
     then
     B=0
  fi
  if [ $tmp13 -gt 8191 ]
     then
     B=1
  fi

  if [ $Z -le 16383 ]
     then
     A=0
  fi
  if [ $Z -gt 16383 ]
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
  # echo "$tmp9"
  # echo "$tmp10"
  # echo "$tmp11"
  # echo "$tmp12"
  # echo "$tmp13"
  # echo "$tmp14"

  echo "B\"$list\" when B\"$A$B$C$D$E$F$G$H$I$J$K$L$M$N$O\",  -- INDEX $Z"
  Z=`expr $Z + 1`

done

else
#	echo "Input file: $input_file doesn't exist";
	echo "Input file or file cos.txt doesn't exist";
	echo "Usage: `basename $0` input_file";
fi

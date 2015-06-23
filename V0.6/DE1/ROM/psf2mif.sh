#!/bin/sh
IN=$1

# Shift the bits left or right
SHIFT="+1"

addr () {
 s=$1
 ss=${s//+/?}
 sss=${ss//-/?}
 #echo $sss
 echo ${sss:11:2} 

} 

convbin () {
 s=$1
 ss=${s//X/1}
 echo ${ss// /0}

}

echo "%------------------------------------------------------------------%"
echo "% File generate automatically by:                                  %"
echo "%                                                                  %"
echo "% psf2mif.sh                                                       %"
echo "%                                                                  %"
echo "% Convert fonts from PSF format to MIF format                      %"
echo "%                                                                  %"
echo "% by:                                                              %"
echo "%                                                                  %"
echo "% Ronivon C. Costa                                                 %"
echo "% 2008/04/17                                                       %"
echo "%                                                                  %"
echo "%------------------------------------------------------------------%"
echo "Depth = 2048;
Width = 8;
Address_radix = hex;
Data_radix = bin;
Content
  Begin"


ADDR=0

for L in `cat $IN | awk '{ if (substr($0,1,1)!="+") { print $0 } }' | grep -v [0-9] | sed s/" "/0/g`
do
   ISADDR=`echo $L | grep "++"`
   if [[ -z "$ISADDR" ]]; then
      LIN=${L//X/1}
      ROMADDR="000"`printf "%02X" $ADDR`
      FADDR=${ROMADDR:(-4)}

# print Letter using * in front of the binary code

      ASCII1=${LIN//0/" "}
      ASCII2=${ASCII1//1/*}

      if [[ $SHIFT == "+1" ]]; then
         LIN="0"${LIN:0:7}
      else 
         if [[ $SHIFT == "+2" ]]; then
            LIN="00"${LIN:0:6}
         else 
            if [[ $SHIFT == "-1" ]]; then
               LIN=${LIN:1:7}"0"
            else 
               if [[ $SHIFT == "-2" ]]; then
                  LIN=${LIN:2:6}"00"
               fi
            fi
         fi
       fi
         

      echo "$FADDR : $LIN ; % $ASCII2 %" 

      let ADDR=$ADDR+1
    fi

done

echo "End;"


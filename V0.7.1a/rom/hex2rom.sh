#!/bin/sh
# hex2romvhdl.sh
# By: Ronivon Candido Costa
# ronivon.costa@gmail.com
#
# This tool runs on Cygwin, Linux and Mac OS X
#
# hex2romvhdl.sh will take a file with hexa bytes as input and convert to a rom format in vhdl
# Input file should be a file named rom.hex, and the format can be:
# - Motorola HEX format
# - Z80ASM format (after assembled, use the View in Hex format, and copy the contents to rom.hex
# 
# ----------------------------------------------------------------------------------------------
convMotorolaHexToAscIIHex() {
  in=rom.hex
  outtmp=romC.hex

  >$outtmp

  while read line   
  do
    if [[ "$line" != ":00000001FF" ]];then
       lenbytes=${line:1:2}
       len=`echo $lenbytes | bc`
       let bytepos=9
       while [[ $len -gt 0 ]] 
       do
          echo ${line:$bytepos:2} >> $outtmp 
          let bytepos=bytepos+2
          let len=len-1
       done
    fi
  done<$in
  cp rom.hex rom.hex.bak
  mv romC.hex rom.hex
}


file=rom.hex

# Vefify if file is in Motorola Hex format, and converto to HEX Ascii codes

read line < $file

if [[ ${line:0:1} = ":" ]];then
   convMotorolaHexToAscIIHex
fi

echo "library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
        port(
                Clk             : in std_logic;
                A               : in std_logic_vector(11 downto 0);
                D               : out std_logic_vector(7 downto 0)
        );
end rom;

architecture rtl of rom is
begin

process (Clk)
begin
 if Clk'event and Clk = '1' then
        case A is"


ADDR=0
for i in `cat $file | tr ',' ' '`
do
  BL1="when x\""
  BL3="\" => D <= x\"$i\";"
  hexaddr="00"`echo "obase=16;ibase=10;$ADDR" | bc`
  fixhexaddr=${hexaddr:(-3)}
  echo "             "$BL1$fixhexaddr$BL3
  let ADDR=ADDR+1
done
echo "             when others => D <=\"ZZZZZZZZ\";
        end case;
 end if;
end process;
end;"


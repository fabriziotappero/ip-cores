#!/bin/sh
IN=$1

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

echo "library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity char is
	port (
	clka: IN std_logic;
	addra: IN std_logic_VECTOR(10 downto 0);
	douta: OUT std_logic_VECTOR(7 downto 0));
end char;

architecture a of char is
begin

process (clka)
begin
 if clka'event and clka = '1' then
        case addra is"

ADDR=0

for L in `cat $IN | sed s/" "/0/g | grep -v "font" | grep -v chars | grep -v width | grep -v height | grep -v 256 | grep -v "^8"`
do
   ISADDR=`echo $L | grep "++"`
   if [[ -z "$ISADDR" ]]; then
      LIN=${L//X/1}
      BL1="when \""
      BL3="\" => douta <= \"$LIN\";"
      binaddr="0000000000"`echo "obase=2;ibase=10;$ADDR" | bc`
      fixhexaddr=${binaddr:(-11)}
      echo "             "$BL1$fixhexaddr$BL3 

      let ADDR=$ADDR+1
    fi

done

echo "             when others => douta <= \"00000000\";
        end case;
 end if;
end process;
end;" 


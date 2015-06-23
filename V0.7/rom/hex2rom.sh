#!/bin/sh
file=rom.hex
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



#!/bin/sh
file=rom.hex
echo "library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
        port(
                Clk : in std_logic;
                A   : in std_logic_vector(13 downto 0);
                D   : out std_logic_vector(7 downto 0)
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
  BL1="when \""
  BL3="\" => D <= x\"$i\";"
  binaddr="000000000000000"`echo "obase=2;ibase=10;$ADDR" | bc`
  fixhexaddr=${binaddr:(-14)}
  echo "             "$BL1$fixhexaddr$BL3
  let ADDR=ADDR+1
done
echo "             when others => D <= \"ZZZZZZZZ\";
        end case;
 end if;
end process;
end;" 


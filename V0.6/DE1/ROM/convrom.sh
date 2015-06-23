#/bin/sh
file=rom.hex
echo "library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
	port(
		Clk		: in std_logic;
		A		: in std_logic_vector(15 downto 0);
		D		: out std_logic_vector(7 downto 0)
	);
end rom;

architecture rtl of rom is
begin

process (Clk)
begin
 if Clk'event and Clk = '1' then
	case A is" > rom.vhd


ADDR=0 
for i in `cat $file | tr ',' ' '`
do
  BL1="when x\""
  BL3="\" => D <= x\"$i\";"
  hexaddr="000"`echo "obase=16;ibase=10;$ADDR" | bc`
  fixhexaddr=${hexaddr:(-4)}
  echo "             "$BL1$fixhexaddr$BL3 >>rom.vhd
  echo $fixhexaddr" "$i
  let ADDR=ADDR+1
done
echo "             when others => D <= x\"00\";
	end case;
 end if;
end process;
end;" >> rom.vhd

cat rom.vhd

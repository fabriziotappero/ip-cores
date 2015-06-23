-- 10/24/2005
-- Program Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity pc is port(
	reset:	in std_logic;
	clk:	in std_logic;
	load:	in std_logic;
	d:	in std_logic_vector(15 downto 0);
	c:	out std_logic_vector(15 downto 0)
);
end pc;

architecture pc_arch of pc is

signal count: unsigned(15 downto 0);
  --signal count : std_logic_vector(15 downto 0);

begin
	count_logic:process(clk, reset, load)
	begin
		if reset = '1' then
			count <= x"0000";
		elsif (clk'EVENT and clk='1') then
			count <= count + '1';
		elsif load = '1' then
			count <= unsigned(d);
		end if;
                -- don't assign the output here!
                -- if you do, the count will change on the falling
                -- edge of the clock!  and that's lame!
                --c <= count;
	end process count_logic;
        c <= std_logic_vector(count);
end pc_arch;

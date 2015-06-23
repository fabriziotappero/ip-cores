--------------------------------------------------------------------------------
-- This models the external memory
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.leval_package.all;
use ieee.numeric_std.all;

entity ext_mem is
	port(
		we : in std_logic;
		re : in std_logic;
		a : in std_logic_vector(ADDR_SIZE - 1 downto 0);
		d : inout std_logic_vector(WORD_SIZE - 1 downto 0);
		ce : in std_logic
	);
end entity;

architecture behav of ext_mem is

type ram_type is array (0 to 2**10) of std_logic_vector(WORD_SIZE - 1 downto 0);
signal RAM : ram_type := (others => (others => '0'));
begin
	process(a,we,re,d, ce)
	begin
		if to_integer(unsigned(a)) < 2**10 then	
			if we = '1' and re= '0' then
				RAM(to_integer(unsigned(a))) <= d;
			elsif re = '1' and we = '0' then
				d <= RAM(to_integer(unsigned(a)));
			else 
				d <= (others => 'Z');
			end if;
		end if;
	end process;
end architecture;

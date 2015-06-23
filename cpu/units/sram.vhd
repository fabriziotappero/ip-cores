------------------------------------------------------------------
-- PROJECT:     HiCoVec (highly configurable vector processor)
--
-- ENTITY:      sram
--
-- PURPOSE:     sram memory             
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.cfg.all;

entity sram is
	port (
		clk : in std_logic;
		we : in std_logic;
		en : in std_logic;
		addr : in std_logic_vector(31 downto 0);
		di : in std_logic_vector(31 downto 0);
		do : out std_logic_vector(31 downto 0)
	);
end sram;

architecture rtl of sram is
	type memory_type is array(0 to sram_size) of std_logic_vector(31 downto 0);
	signal memory : memory_type;
begin
	process (clk)
	begin
		if clk'event and clk = '1' then
			if en = '1' then
				if we = '1' then
					memory(conv_integer(addr)) <= di;
					do <= di;
				else
					do <= memory(conv_integer(addr));
				end if;
			end if;
		end if;
	end process;
end;

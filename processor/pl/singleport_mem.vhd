library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.whisk_constants.all;

entity singleport_mem is
    generic ( 
    memsize, addr_width, data_width : integer);
                
	port (
		clk : in std_logic;
		we : in std_logic;
		addr : in std_logic_vector(addr_width - 1 downto 0);
		di : in std_logic_vector(data_width - 1 downto 0);
		do : out std_logic_vector(data_width - 1 downto 0)
	);
end entity singleport_mem;

architecture behav of singleport_mem is
	type ram_type is array (0 to memsize - 1) of bit_vector(data_width - 1 downto 0);
	signal read_a : std_logic_vector(addr_width - 1 downto 0);
signal RAM : ram_type;
begin
	process(clk)
		begin
            --capture on rising edge, gives registered output. 
			if rising_edge(clk) then
				if (we = '1') then
					RAM(to_integer(unsigned(addr))) <= to_bitvector(di);
				end if;
				read_a <= addr;
			end if;
	end process;
	do <= to_stdlogicvector(RAM(to_integer(unsigned(read_a))));
end behav;

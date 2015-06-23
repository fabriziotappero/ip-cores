library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity rwmem is
    generic (memsize, addr_width, data_width : integer);
                
	port (
		clk : in std_logic;
		we : in std_logic;
		read_addr : in std_logic_vector(addr_width - 1 downto 0);
		write_addr : in std_logic_vector(addr_width - 1 downto 0);
		write_data : in std_logic_vector(data_width - 1 downto 0);
		read_data : out std_logic_vector(data_width - 1 downto 0)
	);
end entity;

architecture behav of rwmem is
	type ram_type is array (0 to memsize - 1) of bit_vector(data_width - 1
	downto 0);
	
	signal read_a : std_logic_vector(addr_width - 1 downto 0);
	
signal RAM : ram_type;
begin
	process(clk)
		begin
			if rising_edge(clk) then
				if (we = '1') then
					RAM(to_integer(unsigned(write_addr))) <= to_bitvector(write_data);
				end if;
				read_a <= read_addr;
			end if;
	end process;
	read_data <= to_stdlogicvector(RAM(to_integer(unsigned(read_a))));
end behav;
	




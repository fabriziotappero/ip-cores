library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity rrwmem is
    generic ( 
    memsize, addr_width, data_width : integer;
    initfile : string);
                
	port (
		clk : in std_logic;
		we : in std_logic;
		a : in std_logic_vector(addr_width - 1 downto 0);
		b : in std_logic_vector(addr_width - 1 downto 0);
        c : in std_logic_vector(addr_width - 1 downto 0); 
		dia : in std_logic_vector(data_width - 1 downto 0);
		doa : out std_logic_vector(data_width - 1 downto 0);
		dob : out  std_logic_vector(data_width - 1 downto 0)
	);
end entity;

architecture behav of rrwmem is
	type ram_type is array (0 to memsize - 1) of bit_vector(data_width - 1
	downto 0);
	
	signal read_a : std_logic_vector(addr_width - 1 downto 0);
	signal read_b : std_logic_vector(addr_width - 1 downto 0);
	
	
	impure function init_ram(filename : in string) return ram_type is
	file ramfile : text is in filename;
	variable li : line;
	variable RAM : ram_type; 
	begin
		for i in ram_type'range loop
			readline(ramfile, li);
			read(li, RAM(i));
		end loop;
	return RAM;
	end function;
	
signal RAM : ram_type := init_ram(initfile);
begin
	process(clk)
		begin
			if rising_edge(clk) then
				if (we = '1') then
					RAM(to_integer(unsigned(c))) <= to_bitvector(dia);
				end if;
				read_a <= a;
				read_b <= b;
			end if;
	end process;
	doa <= to_stdlogicvector(RAM(to_integer(unsigned(read_a))));
	dob <= to_stdlogicvector(RAM(to_integer(unsigned(read_b))));
end behav;
	




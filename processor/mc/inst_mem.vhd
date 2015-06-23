--------------------------------------------------------------------------------
-- Desc: Asynch ROM
-- Author: Odd Rune
--------------------------------------------------------------------------------

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.leval_package.all;
use std.textio.all;
use ieee.numeric_std.all;

entity inst_mem is
    generic ( memsize, addrbits, databits  : integer;
              initfile : string);
	port (
		clk : in std_logic;
		addr : in std_logic_vector(addrbits - 1 downto 0);
		dout : out std_logic_vector(databits - 1 downto 0);
		din : in std_logic_vector(databits - 1 downto 0);
		we : in std_logic
	);
end entity inst_mem;

architecture behav of inst_mem is
type rom_type is array(0 to memsize) of bit_vector(databits - 1
downto 0);


impure function init_rom(filename : in string) return rom_type is
	file romfile : text is in filename;
	variable li : line;
	variable ROM : rom_type; 
	begin
		for i in rom_type'range loop
			readline(romfile, li);
			read(li, ROM(i));
		end loop;
	return ROM;
end function;

signal ROM : rom_type := init_rom(initfile);
signal read_reg : std_logic_vector(addrbits - 1 downto 0);
begin
	process(clk,addr)
	begin
		if rising_edge(clk) then
			if we = '1' then
				ROM(to_integer(unsigned(addr))) <= to_bitvector(din);
			end if;
			read_reg <= addr;
		end if;
	end process;
	dout <= to_stdlogicvector(ROM(to_integer(unsigned(read_reg))));
end architecture behav;

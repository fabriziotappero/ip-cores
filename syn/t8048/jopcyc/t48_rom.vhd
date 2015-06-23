-- This file was generated with hex2rom written by Daniel Wallner

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rom_t48 is
	port(
		Clk	: in std_logic;
		A	: in std_logic_vector(9 downto 0);
		D	: out std_logic_vector(7 downto 0)
	);
end rom_t48;

architecture rtl of rom_t48 is
	signal A_r : std_logic_vector(9 downto 0);
begin
	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			A_r <= A;
		end if;
	end process;
	process (A_r)
	begin
		case to_integer(unsigned(A_r)) is
		when 000000 => D <= "00100011";	-- 0x0000
		when 000001 => D <= "11111111";	-- 0x0001
		when 000002 => D <= "00111001";	-- 0x0002
		when 000003 => D <= "11010011";	-- 0x0003
		when 000004 => D <= "00000001";	-- 0x0004
		when 000005 => D <= "00000100";	-- 0x0005
		when 000006 => D <= "00000010";	-- 0x0006
		when others => D <= "--------";
		end case;
	end process;
end;

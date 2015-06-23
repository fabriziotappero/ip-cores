-- 10/25/2005
-- Logical Unit

library ieee;
use ieee.std_logic_1164.all;

entity logical is port(
	a:	in std_logic_vector(15 downto 0);
	b:	in std_logic_vector(15 downto 0);
	fcn:	in std_logic_vector(2 downto 0);
	o:	out std_logic_vector(15 downto 0)
);
end logical;

architecture logic_arch of logical is
begin
	logical_logic: process(fcn)
	begin
		case fcn is
			when "000" =>			-- not
				o <= not(a);
			when "001" =>			-- and
				o <= a and b;
			when "010" =>			-- or
				o <= a or b;
			when "011" =>			-- xor
				o <= a xor b;
			when "100" =>			-- nand
				o <= a nand b;
			when "101" =>			-- nor
				o <= a nor b;
			when others =>
				o <= x"0000";
		end case;
	end process logical_logic;
end logic_arch;
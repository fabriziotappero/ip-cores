-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_utilities.all;

--! @brief Component for comparing two registers in the ID stage whens branching.
entity pp_comparator is
	port(
		funct3   : in  std_logic_vector(14 downto 12);
		rs1, rs2 : in  std_logic_vector(31 downto 0);
		result   : out std_logic --! Result of the comparison.
	);
end entity pp_comparator;

architecture behaviour of pp_comparator is
begin

	compare: process(funct3, rs1, rs2)
	begin
		case funct3 is
			when b"000" => -- EQ
				result <= to_std_logic(rs1 = rs2);
			when b"001" => -- NE
				result <= to_std_logic(rs1 /= rs2);
			when b"100" => -- LT
				result <= to_std_logic(signed(rs1) < signed(rs2));
			when b"101" => -- GE
				result <= to_std_logic(signed(rs1) >= signed(rs2));
			when b"110" => -- LTU
				result <= to_std_logic(unsigned(rs1) < unsigned(rs2));
			when b"111" => -- GEU
				result <= to_std_logic(unsigned(rs1) >= unsigned(rs2));
			when others =>
				result <= '0';
		end case;
	end process compare;

end architecture behaviour;

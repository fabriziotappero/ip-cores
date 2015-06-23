-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_csr.all;

--! @brief ALU used for calculating new values of control and status registers.
entity pp_csr_alu is
	port(
		x, y          : in  std_logic_vector(31 downto 0);
		result        : out std_logic_vector(31 downto 0);
		immediate     : in  std_logic_vector(4 downto 0);
		use_immediate : in  std_logic;
		write_mode    : in  csr_write_mode
	);
end entity pp_csr_alu;

architecture behaviour of pp_csr_alu is
	signal a, b : std_logic_vector(31 downto 0);
begin

	a <= x;
	b <= y when use_immediate = '0' else std_logic_vector(resize(unsigned(immediate), b'length));

	calculate: process(a, b, write_mode)
	begin
		case write_mode is
			when CSR_WRITE_NONE =>
				result <= a;
			when CSR_WRITE_SET =>
				result <= a or b;
			when CSR_WRITE_CLEAR =>
				result <= a and (not b);
			when CSR_WRITE_REPLACE =>
				result <= b;
		end case;
	end process calculate;

end architecture behaviour;

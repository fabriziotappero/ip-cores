-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;

use work.pp_types.all;

package pp_constants is

	--! No-operation instruction, addi x0, x0, 0.
	constant RISCV_NOP : std_logic_vector(31 downto 0) := (31 downto 5 => '0') & b"10011"; --! ADDI x0, x0, 0.

end package pp_constants;

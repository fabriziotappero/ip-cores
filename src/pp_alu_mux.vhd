-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_types.all;

--! @brief Multiplexer used to choose between ALU inputs.
entity pp_alu_mux is
	port(
		source : in alu_operand_source;

		register_value  : in std_logic_vector(31 downto 0);
		immediate_value : in std_logic_vector(31 downto 0);
		shamt_value     : in std_logic_vector( 4 downto 0);
		pc_value        : in std_logic_vector(31 downto 0);
		csr_value       : in std_logic_vector(31 downto 0);

		output : out std_logic_vector(31 downto 0)
	);
end entity pp_alu_mux;

architecture behaviour of pp_alu_mux is
begin

	mux: process(source, register_value, immediate_value, shamt_value, pc_value, csr_value)
	begin
		case source is
			when ALU_SRC_REG =>
				output <= register_value;
			when ALU_SRC_IMM =>
				output <= immediate_value;
			when ALU_SRC_PC =>
				output <= pc_value;
			when ALU_SRC_PC_NEXT =>
				output <= std_logic_vector(unsigned(pc_value) + 4);
			when ALU_SRC_CSR =>
				output <= csr_value;
			when ALU_SRC_SHAMT =>
				output <= (31 downto 5 => '0') & shamt_value;
			when ALU_SRC_NULL =>
				output <= (others => '0');
		end case;
	end process mux;

end architecture behaviour;

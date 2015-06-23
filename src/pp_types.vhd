-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;

package pp_types is

	--! Type used for register addresses.
	subtype register_address is std_logic_vector(4 downto 0);

	--! The available ALU operations.
	type alu_operation is (
			ALU_AND, ALU_OR, ALU_XOR,
			ALU_SLT, ALU_SLTU,
			ALU_ADD, ALU_SUB,
			ALU_SRL, ALU_SLL, ALU_SRA,
			ALU_NOP, ALU_INVALID
		);

	--! Types of branches.
	type branch_type is (
			BRANCH_NONE, BRANCH_JUMP, BRANCH_JUMP_INDIRECT, BRANCH_CONDITIONAL, BRANCH_SRET
		);

	--! Source of an ALU operand.
	type alu_operand_source is (
			ALU_SRC_REG, ALU_SRC_IMM, ALU_SRC_SHAMT, ALU_SRC_PC, ALU_SRC_PC_NEXT, ALU_SRC_NULL, ALU_SRC_CSR
		);

	--! Type of memory operation:
	type memory_operation_type is (
			MEMOP_TYPE_NONE, MEMOP_TYPE_INVALID, MEMOP_TYPE_LOAD, MEMOP_TYPE_LOAD_UNSIGNED, MEMOP_TYPE_STORE
		);

	-- Determines if a memory operation is a load:
	function memop_is_load(input : in memory_operation_type) return boolean;

	--! Size of a memory operation:
	type memory_operation_size is (
			MEMOP_SIZE_BYTE, MEMOP_SIZE_HALFWORD, MEMOP_SIZE_WORD
		);

	--! Wishbone master output signals:
	type wishbone_master_outputs is record	
			adr : std_logic_vector(31 downto 0);
			sel : std_logic_vector( 3 downto 0);
			cyc : std_logic;
			stb : std_logic;
			we  : std_logic;
			dat : std_logic_vector(31 downto 0);
		end record; 

	--! Wishbone master input signals:
	type wishbone_master_inputs is record
			dat : std_logic_vector(31 downto 0);
			ack : std_logic;
		end record;

end package pp_types;

package body pp_types is

	function memop_is_load(input : in memory_operation_type) return boolean is
	begin
		return (input = MEMOP_TYPE_LOAD or input = MEMOP_TYPE_LOAD_UNSIGNED);
	end function memop_is_load;

end package body pp_types;

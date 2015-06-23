-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;

use work.pp_types.all;
use work.pp_constants.all;

entity pp_alu_control_unit is
	port(
		opcode  : in std_logic_vector( 4 downto 0);
		funct3  : in std_logic_vector( 2 downto 0);
		funct7  : in std_logic_vector( 6 downto 0);
		
		-- Sources of ALU operands:
		alu_x_src, alu_y_src : out alu_operand_source;

		-- ALU operation:
		alu_op : out alu_operation
	);
end entity pp_alu_control_unit;

architecture behaviour of pp_alu_control_unit is
begin

	decode_alu: process(opcode, funct3, funct7)
	begin
		case opcode is
			when b"01101" => -- Load upper immediate
				alu_x_src <= ALU_SRC_NULL;
				alu_y_src <= ALU_SRC_IMM;
				alu_op <= ALU_ADD;
			when b"00101" => -- Add upper immediate to PC
				alu_x_src <= ALU_SRC_PC;
				alu_y_src <= ALU_SRC_IMM;
				alu_op <= ALU_ADD;
			when b"11011" => -- Jump and link
				alu_x_src <= ALU_SRC_PC_NEXT;
				alu_y_src <= ALU_SRC_NULL;
				alu_op <= ALU_ADD;
			when b"11001" => -- Jump and link register
				alu_x_src <= ALU_SRC_PC_NEXT;
				alu_y_src <= ALU_SRC_NULL;
				alu_op <= ALU_ADD;
			when b"11000" => -- Branch operations
				-- The funct3 field decides which type of branch comparison is
				-- done; this is decoded in the branch comparator module.
				alu_x_src <= ALU_SRC_NULL;
				alu_y_src <= ALU_SRC_NULL;
				alu_op <= ALU_NOP;
			when b"00000" => -- Load instruction
				alu_x_src <= ALU_SRC_REG;
				alu_y_src <= ALU_SRC_IMM;
				alu_op <= ALU_ADD;
			when b"01000" => -- Store instruction
				alu_x_src <= ALU_SRC_REG;
				alu_y_src <= ALU_SRC_IMM;
				alu_op <= ALU_ADD;
			when b"00100" => -- Register-immediate operations
				alu_x_src <= ALU_SRC_REG;

				if funct3 = b"001" or funct3 = b"101" then
					alu_y_src <= ALU_SRC_SHAMT;
				else
					alu_y_src <= ALU_SRC_IMM;
				end if;

				case funct3 is
					when b"000" =>
						alu_op <= ALU_ADD;
					when b"001" =>
						alu_op <= ALU_SLL;
					when b"010" =>
						alu_op <= ALU_SLT;
					when b"011" =>
						alu_op <= ALU_SLTU;
					when b"100" =>
						alu_op <= ALU_XOR;
					when b"101" =>
						if funct7 = b"0000000" then
							alu_op <= ALU_SRL;
						else
							alu_op <= ALU_SRA;
						end if;
					when b"110" =>
						alu_op <= ALU_OR;
					when b"111" =>
						alu_op <= ALU_AND;
					when others =>
						alu_op <= ALU_INVALID;
				end case; 
			when b"01100" => -- Register-register operations
				alu_x_src <= ALU_SRC_REG;
				alu_y_src <= ALU_SRC_REG;

				case funct3 is
					when b"000" =>
						if funct7 = b"0000000" then
							alu_op <= ALU_ADD;
						else
							alu_op <= ALU_SUB;
						end if;
					when b"001" =>
						alu_op <= ALU_SLL;
					when b"010" =>
						alu_op <= ALU_SLT;
					when b"011" =>
						alu_op <= ALU_SLTU;
					when b"100" =>
						alu_op <= ALU_XOR;
					when b"101" =>
						if funct7 = b"0000000" then
							alu_op <= ALU_SRL;
						else
							alu_op <= ALU_SRA;
						end if;
					when b"110" =>
						alu_op <= ALU_OR;
					when b"111" =>
						alu_op <= ALU_AND;
					when others =>
						alu_op <= ALU_INVALID;
				end case;
			when b"00011" => -- Fence instructions, ignored
				alu_x_src <= ALU_SRC_REG;
				alu_y_src <= ALU_SRC_REG;
				alu_op <= ALU_NOP;
			when b"11100" => -- System instructions
				alu_x_src <= ALU_SRC_CSR;
				alu_y_src <= ALU_SRC_NULL;
				alu_op <= ALU_ADD;
			when others =>
				alu_x_src <= ALU_SRC_REG;
				alu_y_src <= ALU_SRC_REG;
				alu_op <= ALU_INVALID;
		end case;
	end process decode_alu;

end architecture behaviour;

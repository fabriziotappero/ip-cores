-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- arm_types.vhd  --  Package containing types for the whole project
--
-- Written By -  Jonathan Masur and Xavier Jimenez (2013)
--
-- This program is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the
-- Free Software Foundation; either version 2, or (at your option) any
-- later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- In other words, you are welcome to use, share and improve this program.
-- You are forbidden to forbid anyone else to use, share and improve
-- what you give them.   Help stamp out software-hoarding!

library ieee;
use ieee.std_logic_1164.all;

package arm_types is

	-- Condition flags (top 4 bits of ARM instruction)
	constant COND_EQ : std_logic_vector(3 downto 0) := "0000";
	constant COND_NE : std_logic_vector(3 downto 0) := "0001";
	constant COND_CS : std_logic_vector(3 downto 0) := "0010";
	constant COND_CC : std_logic_vector(3 downto 0) := "0011";
	constant COND_MI : std_logic_vector(3 downto 0) := "0100";
	constant COND_PL : std_logic_vector(3 downto 0) := "0101";
	constant COND_VS : std_logic_vector(3 downto 0) := "0110";
	constant COND_VC : std_logic_vector(3 downto 0) := "0111";
	constant COND_HI : std_logic_vector(3 downto 0) := "1000";
	constant COND_LS : std_logic_vector(3 downto 0) := "1001";
	constant COND_GE : std_logic_vector(3 downto 0) := "1010";
	constant COND_LT : std_logic_vector(3 downto 0) := "1011";
	constant COND_GT : std_logic_vector(3 downto 0) := "1100";
	constant COND_LE : std_logic_vector(3 downto 0) := "1101";
	constant COND_AL : std_logic_vector(3 downto 0) := "1110";
	
	-- register re-mapping at decode stage
	constant r0 : std_logic_vector(4 downto 0) := "00000";
	constant r1 : std_logic_vector(4 downto 0) := "00001";
	constant r2 : std_logic_vector(4 downto 0) := "00010";
	constant r3 : std_logic_vector(4 downto 0) := "00011";
	constant r4 : std_logic_vector(4 downto 0) := "00100";
	constant r5 : std_logic_vector(4 downto 0) := "00101";
	constant r6 : std_logic_vector(4 downto 0) := "00110";
	constant r7 : std_logic_vector(4 downto 0) := "00111";
	constant r8 : std_logic_vector(4 downto 0) := "01000";
	constant r9 : std_logic_vector(4 downto 0) := "01001";
	constant r10 : std_logic_vector(4 downto 0) := "01010";
	constant r11 : std_logic_vector(4 downto 0) := "01011";
	constant r12 : std_logic_vector(4 downto 0) := "01100";
	constant r13 : std_logic_vector(4 downto 0) := "01101";
	constant r14 : std_logic_vector(4 downto 0) := "01110";
	constant fiq_r8 : std_logic_vector(4 downto 0) := "01111";
	constant fiq_r9 : std_logic_vector(4 downto 0) := "10000";
	constant fiq_r10 : std_logic_vector(4 downto 0) := "10001";
	constant fiq_r11 : std_logic_vector(4 downto 0) := "10010";
	constant fiq_r12 : std_logic_vector(4 downto 0) := "10011";
	constant fiq_r13 : std_logic_vector(4 downto 0) := "10100";
	constant sup_r13 : std_logic_vector(4 downto 0) := "10101";
	constant irq_r13 : std_logic_vector(4 downto 0) := "10110";
	constant und_r13 : std_logic_vector(4 downto 0) := "10111";
	constant fiq_r14 : std_logic_vector(4 downto 0) := "11000";
	constant sup_r14 : std_logic_vector(4 downto 0) := "11001";
	constant irq_r14 : std_logic_vector(4 downto 0) := "11010";
	constant und_r14 : std_logic_vector(4 downto 0) := "11011";
	constant fiq_spsr : std_logic_vector(4 downto 0) := "11100";
	constant sup_spsr : std_logic_vector(4 downto 0) := "11101";
	constant irq_spsr : std_logic_vector(4 downto 0) := "11110";
	constant und_spsr : std_logic_vector(4 downto 0) := "11111";

	-- Finite state machine inside the Decode pipeline stage
	type DECODE_FSM is (MAIN_STATE, RETURN_FROM_EXCEPTION, TWO_LATENCY_CYCLES, ONE_LATENCY_CYCLE,  LOADSTORE_WRITEBACK,
						LDMSTM_TRANSFER, LDMSTM_RETURN_FROM_EXCEPTION, LDMSTM_WRITEBACK,
						RESET_CYCLE2, UNDEF_CYCLE2, SWI_CYCLE2, IRQ_CYCLE2, FIQ_CYCLE2);

	-- List of arithmetic and logical operations which can be performed in the execute pipeline stage
	type ALU_OPERATION is (ALU_NOP, ALU_NOT, ALU_ORR, ALU_AND, ALU_EOR, ALU_BIC, ALU_RWF, ALU_ADD, ALU_ADC, ALU_SUB, ALU_SBC, ALU_RSB, ALU_RSC);

	-- List of memory-related operation that can be perfored in the memory pipeline stage
	type MEM_OPERATION is (NO_MEM_OP, LOAD_WORD, LOAD_BYTE, LOAD_BURST, STORE_WORD, STORE_BYTE);
	
end package;

package body arm_types is

end package body;

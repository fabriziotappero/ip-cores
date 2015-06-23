-- #######################################################
-- #     < STORM CORE PROCESSOR by Stephan Nolting >     #
-- # *************************************************** #
-- #           ARM-Native OPCODE Decoding Unit           #
-- # *************************************************** #
-- # Last modified: 13.05.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

-- ###############################################################################################
-- ##       Interface                                                                           ##
-- ###############################################################################################

entity OPCODE_DECODER is
	port	(
				OPCODE_DATA_I : in  STD_LOGIC_VECTOR(31 downto 0);
				OPCODE_CTRL_I : in  STD_LOGIC_VECTOR(15 downto 0);
				OPCODE_CTRL_O : out STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				OPCODE_MISC_O : out STD_LOGIC_VECTOR(99 downto 0)
			);
end OPCODE_DECODER;

architecture instruction_decoder of OPCODE_DECODER is

-- ###############################################################################################
-- ##       Local Signals                                                                       ##
-- ###############################################################################################

	-- INPUTS --
	signal INSTR_REG     : STD_LOGIC_VECTOR(31 downto 0);
	signal DUAL_OP       : STD_LOGIC_VECTOR(04 downto 0);
	signal R_OFFSET      : STD_LOGIC_VECTOR(04 downto 0);

	-- OUTPUTS --
	signal DEC_CTRL      : STD_LOGIC_VECTOR(CTRL_MSB downto 0);
	signal OP_ADR_OUT    : STD_LOGIC_VECTOR(11 downto 0);
	signal IMM_OUT       : STD_LOGIC_VECTOR(31 downto 0);
	signal NEXT_DUAL_OP  : STD_LOGIC_VECTOR(04 downto 0);
	signal NEXT_OFFSET   : STD_LOGIC_VECTOR(04 downto 0);
	signal REG_SEL       : STD_LOGIC_VECTOR(14 downto 12);

begin

-- ###############################################################################################
-- ##       Internal Signal Connection                                                          ##
-- ###############################################################################################

		INSTR_REG <= OPCODE_DATA_I;
		DUAL_OP   <= OPCODE_CTRL_I(04 downto 00);
		R_OFFSET  <= OPCODE_CTRL_I(09 downto 05);

		OPCODE_CTRL_O <= DEC_CTRL;
		OPCODE_MISC_O(44 downto 33) <= OP_ADR_OUT;
		OPCODE_MISC_O(47 downto 45) <= REG_SEL;
		OPCODE_MISC_O(79 downto 48) <= IMM_OUT;
		OPCODE_MISC_O(86 downto 80) <= (others => '0');
		OPCODE_MISC_O(91 downto 87) <= NEXT_DUAL_OP;
		OPCODE_MISC_O(96 downto 92) <= NEXT_OFFSET;
		OPCODE_MISC_O(99 downto 97) <= (others => '0'); -- unused


-- ###############################################################################################
-- ##       ARM NATIVE OPCODE DECODER                                                           ##
-- ###############################################################################################

		OPCODE_DECODER: process (INSTR_REG, DUAL_OP, R_OFFSET)
			variable temp_2, temp_3, temp_4, temp_5 : std_logic_vector(02 downto 0);
			variable B_TEMP_1, B_TEMP_2, B_TEMP_3   : std_logic_vector(01 downto 0);
			variable block_t_en_v                   : std_logic;
			variable block_t_tmp_v                  : std_logic_vector(15 downto 0);
			variable adr_offs_v                     : std_logic_vector(04 downto 0);
			variable number_of_regs_v               : std_logic_vector(04 downto 0);
			variable pc_in_list_v                   : std_logic;
		begin

			--- DEFAULT CONTROL ---
			DEC_CTRL                                     <= (others => '0');
			DEC_CTRL(CTRL_RD_3     downto CTRL_RD_0)     <= INSTR_REG(15 downto 12); -- R_DEST
			DEC_CTRL(CTRL_COND_3   downto CTRL_COND_0)   <= INSTR_REG(31 downto 28); -- Condition
			OP_ADR_OUT(OP_A_ADR_3  downto OP_A_ADR_0)    <= INSTR_REG(19 downto 16);
			OP_ADR_OUT(OP_B_ADR_3  downto OP_B_ADR_0)    <= INSTR_REG(03 downto 00);
			OP_ADR_OUT(OP_C_ADR_3  downto OP_C_ADR_0)    <= INSTR_REG(11 downto 08);
			REG_SEL                                      <= (others => '0'); -- all operands are anything but registers
			IMM_OUT                                      <= (others => '0');
			NEXT_DUAL_OP                                 <= (others => '0'); -- single cycle operation as default
			NEXT_OFFSET                                  <= (others => '0'); -- auto offset is 0

			--- INSTRUCTION CLASS DECODER ---
			case INSTR_REG(27 downto 26) is

				when "00" => -- ALU DATA PROCESSING / SREG ACCESS / MUL(MAC) / MULL/MLAL / BX / SWP / (S/U/HW/B) MEM ACCESS
				-- ===================================================================================
					if (INSTR_REG(25 downto 22) = "0000") and (INSTR_REG(7 downto 4) = "1001") then
					-- MUL/MAC
					----------------------------------------------------------------------------------
						DEC_CTRL(CTRL_AF)                        <= INSTR_REG(20); -- ALTER_FLAGS
						DEC_CTRL(CTRL_WB_EN)                     <= '1'; -- WB_ENABLE
						DEC_CTRL(CTRL_MS)                        <= '1'; -- select multiplicator
						DEC_CTRL(CTRL_RD_3    downto  CTRL_RD_0) <= INSTR_REG(19 downto 16);
						OP_ADR_OUT(OP_A_ADR_3 downto OP_A_ADR_0) <= INSTR_REG(15 downto 12);
						OP_ADR_OUT(OP_B_ADR_3 downto OP_B_ADR_0) <= INSTR_REG(11 downto 08);
						OP_ADR_OUT(OP_C_ADR_3 downto OP_C_ADR_0) <= INSTR_REG(03 downto 00);
						REG_SEL(OP_B_IS_REG)                     <= '1'; -- OP B is always reg
						REG_SEL(OP_C_IS_REG)                     <= '1'; -- OP C is always reg
						REG_SEL(OP_A_IS_REG)                     <= INSTR_REG(21);
						if (INSTR_REG(21) = '1') then -- perform MAC operation
							DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= A_ADD;
						else -- perform MUL operation
							DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= PassB;
						end if;

					elsif (INSTR_REG(25 downto 23) = "001") and (INSTR_REG(7 downto 4) = "1001") then
					-- MULL/MLAL
					----------------------------------------------------------------------------------
						DEC_CTRL(CTRL_UND) <= '1'; -- not supported/implemented

					elsif (INSTR_REG(25 downto 4) = "0100101111111111110001") then
					-- Branch and Exchange (BX)
					----------------------------------------------------------------------------------
						DEC_CTRL(CTRL_BX)                            <= '1'; -- is bx instruction
						DEC_CTRL(CTRL_BRANCH)                        <= '1'; -- BRANCH_INSTR
						OP_ADR_OUT(OP_B_ADR_3 downto OP_B_ADR_0)     <= INSTR_REG(03 downto 00);
						DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= PassB;
						REG_SEL(OP_B_IS_REG)                         <= '1';

					elsif (INSTR_REG(25) = '0') and (INSTR_REG(7) = '1') and (INSTR_REG(4) = '1') then
					-- Halfword / Signed Data Transfer
					----------------------------------------------------------------------------------
						DEC_CTRL(CTRL_RD_3    downto  CTRL_RD_0) <= INSTR_REG(15 downto 12); -- R_DATA
						OP_ADR_OUT(OP_A_ADR_3 downto OP_A_ADR_0) <= INSTR_REG(19 downto 16); -- BASE
						OP_ADR_OUT(OP_B_ADR_3 downto OP_B_ADR_0) <= INSTR_REG(03 downto 00); -- Offset
						OP_ADR_OUT(OP_C_ADR_3 downto OP_C_ADR_0) <= INSTR_REG(15 downto 12); -- W_DATA
						IMM_OUT                                  <= x"000000" & INSTR_REG(11 downto 08) & INSTR_REG(03 downto 00); -- IMMEDIATE
						DEC_CTRL(CTRL_CONST)                     <= INSTR_REG(22); -- IS_CONST
						DEC_CTRL(CTRL_MEM_SE)                    <= INSTR_REG(6);

						if (INSTR_REG(5) = '1') then
							DEC_CTRL(CTRL_MEM_DQ_1 downto CTRL_MEM_DQ_0) <= DQ_HALFWORD;
						else
							DEC_CTRL(CTRL_MEM_DQ_1 downto CTRL_MEM_DQ_0) <= DQ_BYTE;
						end if;

						if (INSTR_REG(23) = '0') then -- sub index
							DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= A_SUB; -- ALU_CTRL = SUB
						else -- add index
							DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= A_ADD; -- ALU_CTRL = ADD
						end if;

						temp_5 := INSTR_REG(20) & INSTR_REG(24) & INSTR_REG(21);
						case temp_5 is -- L_P_W

							when "110" => -- load, pre indexing, no write back
							----------------------------------------------------------------------------------
								DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)	<= INSTR_REG(15 downto 12); -- R_DEST
								DEC_CTRL(CTRL_MEM_ACC)					<= '1'; -- MEM_ACCESS
								DEC_CTRL(CTRL_MEM_RW)					<= '0'; -- MEM_READ
								DEC_CTRL(CTRL_WB_EN)					<= '1'; -- WB EN
								NEXT_DUAL_OP(0)							<= '0';
								REG_SEL(OP_A_IS_REG)                    <= '1';
								REG_SEL(OP_B_IS_REG)                    <= not INSTR_REG(22);
								REG_SEL(OP_C_IS_REG)                    <= '0';

							when "111" => -- load, pre indexing, write back
							----------------------------------------------------------------------------------
								if (DUAL_OP(0) = '0') then -- ADD/SUB Ra,Ra,Op_B
									DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)	<= INSTR_REG(19 downto 16); -- R_DEST
									DEC_CTRL(CTRL_MEM_ACC)					<= '0'; -- MEM_ACCESS
									DEC_CTRL(CTRL_WB_EN)					<= '1'; -- WB EN
									NEXT_DUAL_OP(0)							<= '1';
									REG_SEL(OP_A_IS_REG)                    <= '1';
									REG_SEL(OP_B_IS_REG)                    <= not INSTR_REG(22);
									REG_SEL(OP_C_IS_REG)                    <= '0';
								else -- LD Rd, Ra
									DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)			<= INSTR_REG(15 downto 12); -- R_DEST
									DEC_CTRL(CTRL_MEM_ACC)							<= '1'; -- MEM_ACCESS
									DEC_CTRL(CTRL_WB_EN)							<= '1'; -- WB EN
									NEXT_DUAL_OP(0)									<= '0';
									DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0)	<= PassA; -- ALU_CTRL = PassA
									REG_SEL(OP_A_IS_REG)                    		<= '1';
									REG_SEL(OP_B_IS_REG)                   			<= '0';
									REG_SEL(OP_C_IS_REG)                    		<= '0';
								end if;


							when "100" | "101" => -- load, post indexing, always write back
							----------------------------------------------------------------------------------
								if (DUAL_OP(0) = '0') then -- LD Rd,Ra
									DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)			<= INSTR_REG(15 downto 12); -- R_DEST
									DEC_CTRL(CTRL_MEM_ACC)							<= '1'; -- MEM_ACCESS
									DEC_CTRL(CTRL_MEM_RW)							<= '0'; -- MEM_READ
									DEC_CTRL(CTRL_WB_EN)							<= '1'; -- WB EN
									NEXT_DUAL_OP(0)									<= '1';
									DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0)	<= PassA; -- ALU_CTRL = PassA
									REG_SEL(OP_A_IS_REG)                    		<= '1';
									REG_SEL(OP_B_IS_REG)                    		<= '0';
									REG_SEL(OP_C_IS_REG)                    		<= '0';
								else -- ADD/SUB Ra,Ra,Op_B
									DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)	<= INSTR_REG(19 downto 16); -- R_DEST
									DEC_CTRL(CTRL_MEM_ACC)					<= '0'; -- MEM_ACCESS
									DEC_CTRL(CTRL_WB_EN)					<= '1'; -- WB EN
									NEXT_DUAL_OP(0)							<= '0';
									REG_SEL(OP_A_IS_REG)                    <= '1';
									REG_SEL(OP_B_IS_REG)                    <= not INSTR_REG(22);
									REG_SEL(OP_C_IS_REG)                    <= '0';
								end if;


							when "010" => -- store, pre indexing, no write back
							----------------------------------------------------------------------------------
								DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)	<= INSTR_REG(19 downto 16); -- R_DEST <WAYNE>
								DEC_CTRL(CTRL_MEM_ACC)					<= '1'; -- MEM_ACCESS
								DEC_CTRL(CTRL_MEM_RW)					<= '1'; -- MEM_WRITE
								DEC_CTRL(CTRL_WB_EN)					<= '0'; -- WB EN
								NEXT_DUAL_OP(0)							<= '0';
								REG_SEL(OP_A_IS_REG)                    <= '1';
								REG_SEL(OP_B_IS_REG)                    <= not INSTR_REG(22);
								REG_SEL(OP_C_IS_REG)                    <= '1';


							when "011" => -- store, pre indexing, write back
							----------------------------------------------------------------------------------
								DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)	<= INSTR_REG(19 downto 16); -- R_DEST
								DEC_CTRL(CTRL_MEM_ACC)					<= '1'; -- MEM_ACCESS
								DEC_CTRL(CTRL_MEM_RW)					<= '1'; -- MEM_WRITE
								DEC_CTRL(CTRL_WB_EN)					<= '1'; -- WB EN
								NEXT_DUAL_OP(0)							<= '0';
								REG_SEL(OP_A_IS_REG)                    <= '1';
								REG_SEL(OP_B_IS_REG)                    <= not INSTR_REG(22);
								REG_SEL(OP_C_IS_REG)                    <= '1';


							when others => -- store, post indexing, always write back
							----------------------------------------------------------------------------------
								if (DUAL_OP(0) = '0') then -- ST Ra, Rd
									DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)			<= INSTR_REG(15 downto 12); -- R_DEST
									DEC_CTRL(CTRL_MEM_ACC)							<= '1'; -- MEM_ACCESS
									DEC_CTRL(CTRL_MEM_RW)							<= '1'; -- MEM_WRITE
									DEC_CTRL(CTRL_WB_EN)							<= '0'; -- WB EN
									NEXT_DUAL_OP(0)									<= '1';
									DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) 	<= PassA; -- ALU_CTRL = PassA
									REG_SEL(OP_A_IS_REG)                    		<= '1';
									REG_SEL(OP_B_IS_REG)                    		<= '0';
									REG_SEL(OP_C_IS_REG)                    		<= '1';
								else -- ADD/SUB Ra,Ra,Op_B
									DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)	<= INSTR_REG(19 downto 16); -- R_DEST
									DEC_CTRL(CTRL_MEM_ACC)					<= '0'; -- MEM_ACCESS
									DEC_CTRL(CTRL_MEM_RW)					<= '0'; -- MEM_WRITE
									DEC_CTRL(CTRL_WB_EN)					<= '1'; -- WB EN
									NEXT_DUAL_OP(0)							<= '0';
									REG_SEL(OP_A_IS_REG)                    <= '1';
									REG_SEL(OP_B_IS_REG)                    <= not INSTR_REG(22);
									REG_SEL(OP_C_IS_REG)                    <= '0';
								end if;

						end case;

					elsif (INSTR_REG(25 downto 23) = "010") and (INSTR_REG(21 downto 20) = "00") and (INSTR_REG(11 downto 4) = "00001001") then
					-- Single Data Swap SWP
					----------------------------------------------------------------------------------
						OP_ADR_OUT(OP_A_ADR_3  downto OP_A_ADR_0)    <= INSTR_REG(19 downto 16); -- BASE
						OP_ADR_OUT(OP_C_ADR_3  downto OP_C_ADR_0)    <= INSTR_REG(03 downto 00); -- W_DATA
						DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= PassA; -- ALU_CTRL = PassA
						DEC_CTRL(CTRL_MEM_DQ_1 downto CTRL_MEM_DQ_0) <= '0' & INSTR_REG(22); -- DATA QUANTITY
						DEC_CTRL(CTRL_MEM_ACC)                       <= '1'; -- MEM_ACCESS
						REG_SEL(OP_A_IS_REG)                         <= '1';
						REG_SEL(OP_B_IS_REG)                         <= '0';
						if (DUAL_OP(0) = '0') then
							NEXT_DUAL_OP(0)       <= '1';
							DEC_CTRL(CTRL_MEM_RW) <= '0'; -- MEM_READ
							DEC_CTRL(CTRL_WB_EN)  <= '1'; -- WB EN
							REG_SEL(OP_C_IS_REG)  <= '0';
							DEC_CTRL(CTRL_WB_EN)  <= '1'; -- WB_ENABLE
						else
							NEXT_DUAL_OP(0)       <= '0';
							DEC_CTRL(CTRL_MEM_RW) <= '1'; -- MEM_WRITE
							DEC_CTRL(CTRL_WB_EN)  <= '0'; -- WB EN
							REG_SEL(OP_C_IS_REG)  <= '1';
							DEC_CTRL(CTRL_WB_EN)  <= '0'; -- WB_ENABLE
						end if;


					else -- ALU operation / MCR access
					----------------------------------------------------------------------------------
						DEC_CTRL(CTRL_AF)      <= INSTR_REG(20); -- ALTER_FLAGS
						DEC_CTRL(CTRL_WB_EN)   <= '1';           -- WB_ENABLE
						DEC_CTRL(CTRL_CONST)   <= INSTR_REG(25); -- IS_CONST
						DEC_CTRL(CTRL_MREG_M)  <= INSTR_REG(22); -- CMSR/SMSR access
						DEC_CTRL(CTRL_MREG_RW) <= INSTR_REG(21); -- read/write access
						DEC_CTRL(CTRL_MREG_FA) <= not INSTR_REG(16); -- only flag access?

						B_TEMP_1 := INSTR_REG(25) & INSTR_REG(04);
						case B_TEMP_1 is
							when "10" | "11" => -- IS_CONST
								REG_SEL(OP_A_IS_REG)    <= '1';
								REG_SEL(OP_B_IS_REG)    <= '0';
								REG_SEL(OP_C_IS_REG)    <= '0';
								DEC_CTRL(CTRL_SHIFT_V_4 downto CTRL_SHIFT_V_0) <= INSTR_REG(11 downto 08) & '0'; -- SHIFT_POS x2
								if (INSTR_REG(11 downto 08) = "0000") then
									DEC_CTRL(CTRL_SHIFT_M_1 downto CTRL_SHIFT_M_0) <= S_LSL; -- SHIFT MODE = anything but ROR
								else
									DEC_CTRL(CTRL_SHIFT_M_1 downto CTRL_SHIFT_M_0) <= S_ROR; -- SHIFT MODE = ROR
								end if;
								IMM_OUT					<= x"000000" & INSTR_REG(07 downto 00); -- IMMEDIATE
								DEC_CTRL(CTRL_SHIFTR)	<= '0'; -- SHIFT WITH IMMEDIATE
		
							when "00" => -- shift REG_B direct
								REG_SEL(OP_A_IS_REG)    <= '1';
								REG_SEL(OP_B_IS_REG)    <= '1';
								REG_SEL(OP_C_IS_REG)    <= '0';
								DEC_CTRL(CTRL_SHIFT_V_4 downto CTRL_SHIFT_V_0) <= INSTR_REG(11 downto 07); -- SHIFT POS
								DEC_CTRL(CTRL_SHIFT_M_1 downto CTRL_SHIFT_M_0) <= INSTR_REG(06 downto 05); -- SHIFT MODE
								IMM_OUT					<= (others => '0'); -- IMMEDIATE
								DEC_CTRL(CTRL_SHIFTR)	<= '0'; -- SHIFT WITH IMMEDIATE

							when others => -- shift REG_B with REG_C
								REG_SEL(OP_A_IS_REG)    <= '1';
								REG_SEL(OP_B_IS_REG)    <= '1';
								REG_SEL(OP_C_IS_REG)    <= '1';
								DEC_CTRL(CTRL_SHIFT_V_4 downto CTRL_SHIFT_V_0) <= (others => '0'); -- SHIFT POS
								DEC_CTRL(CTRL_SHIFT_M_1 downto CTRL_SHIFT_M_0) <= INSTR_REG(06 downto 05); -- SHIFT MODE
								IMM_OUT					<= (others => '0'); -- IMMEDIATE
								DEC_CTRL(CTRL_SHIFTR)	<= '1'; -- SHIFT_REG
						end case;

						-- ALU FUNCTION SET --
						DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= INSTR_REG(24 downto 21);
						case (INSTR_REG(24 downto 21)) is
							when L_TST => -- read SREG
								DEC_CTRL(CTRL_WB_EN)        <= '0'; -- disable register write back
								if (INSTR_REG(20) = '0') then -- ALTER FLAGS ?
									DEC_CTRL(CTRL_MREG_ACC)	<= '1'; -- access MREG
									DEC_CTRL(CTRL_WB_EN)    <= '1'; -- re-enable register write back
									REG_SEL(OP_A_IS_REG)    <= '0';
									REG_SEL(OP_B_IS_REG)    <= '0';
									REG_SEL(OP_C_IS_REG)    <= '0';
								end if;
							when L_TEQ => -- write SREG
								DEC_CTRL(CTRL_WB_EN)        <= '0'; -- disable register write back
								if (INSTR_REG(20) = '0') then -- ALTER FLAGS ?
									DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= PassB; -- write SREG
									DEC_CTRL(CTRL_MREG_ACC)	<= '1'; -- access MREG
									REG_SEL(OP_A_IS_REG)    <= '0';
									REG_SEL(OP_B_IS_REG)    <= '1';
									REG_SEL(OP_C_IS_REG)    <= '0';
								end if;
							when A_CMP => -- read SREG
								DEC_CTRL(CTRL_WB_EN)        <= '0'; -- disable register write back
								if (INSTR_REG(20) = '0') then -- ALTER FLAGS ?
									DEC_CTRL(CTRL_MREG_ACC)	<= '1'; -- access MREG
									DEC_CTRL(CTRL_WB_EN)    <= '1'; -- re-enable register write back
									REG_SEL(OP_A_IS_REG)    <= '0';
									REG_SEL(OP_B_IS_REG)    <= '0';
									REG_SEL(OP_C_IS_REG)    <= '0';
								end if;
							when A_CMN => -- write SREG
								DEC_CTRL(CTRL_WB_EN)        <= '0'; -- disable register write back
								if (INSTR_REG(20) = '0') then -- ALTER FLAGS ?
									DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= PassB; -- write SREG
									DEC_CTRL(CTRL_MREG_ACC)	<= '1'; -- access MREG
									REG_SEL(OP_A_IS_REG)    <= '0';
									REG_SEL(OP_B_IS_REG)    <= '1';
									REG_SEL(OP_C_IS_REG)    <= '0';
								end if;
							when L_MOV =>
								REG_SEL(OP_A_IS_REG) <= '0';
							when L_NOT =>
								REG_SEL(OP_A_IS_REG) <= '0';
							when others => -- use default values
								NULL;
						end case;

					end if;


				when "01" => -- UNDEFINED INSTRUCTION INTERRUPT / SINGLE MEMORY ACCESS
				-- ============================================================================================
					DEC_CTRL(CTRL_UND) <= INSTR_REG(25) and INSTR_REG(4); -- undefined instruction

					OP_ADR_OUT(OP_A_ADR_3 downto OP_A_ADR_0)		<= INSTR_REG(19 downto 16); -- BASE
					OP_ADR_OUT(OP_B_ADR_3 downto OP_B_ADR_0)		<= INSTR_REG(03 downto 00); -- OFFSET
					OP_ADR_OUT(OP_C_ADR_3 downto OP_C_ADR_0)		<= INSTR_REG(15 downto 12); -- DATA
					NEXT_DUAL_OP(0)									<= '0';
					DEC_CTRL(CTRL_CONST)							<= not INSTR_REG(25); -- IS_CONST
					if (INSTR_REG(22) = '0') then -- W/B quantity
						DEC_CTRL(CTRL_MEM_DQ_1 downto CTRL_MEM_DQ_0) <= DQ_WORD;
					else
						DEC_CTRL(CTRL_MEM_DQ_1 downto CTRL_MEM_DQ_0) <= DQ_BYTE;
					end if;

					B_TEMP_2 := INSTR_REG(25) & INSTR_REG(04);
					case B_TEMP_2 is
						when "00" | "01" => -- IS_CONST
							DEC_CTRL(CTRL_SHIFT_V_4 downto CTRL_SHIFT_V_0) <= (others => '0'); -- SHIFT POS
							DEC_CTRL(CTRL_SHIFT_M_1 downto CTRL_SHIFT_M_0) <= S_LSL; -- SHIFT MODE = wayne
							IMM_OUT(31 downto 00)	<= x"00000" & INSTR_REG(11 downto 00); -- unsigned IMMEDIATE
							DEC_CTRL(CTRL_SHIFTR)	<= '0'; -- SHIFT_REG

						when "10" => -- shift REG_B direct
							DEC_CTRL(CTRL_SHIFT_V_4 downto CTRL_SHIFT_V_0) <= INSTR_REG(11 downto 07); -- SHIFT POS
							DEC_CTRL(CTRL_SHIFT_M_1 downto CTRL_SHIFT_M_0) <= INSTR_REG(06 downto 05); -- SHIFT MODE
							IMM_OUT(31 downto 00)	<= (others => '0'); -- IMMEDIATE
							DEC_CTRL(CTRL_SHIFTR)	<= '0'; -- SHIFT_REG

						when others => -- shift REG_B with REG_C
							DEC_CTRL(CTRL_SHIFT_V_4 downto CTRL_SHIFT_V_0) <= (others => '0'); -- SHIFT POS
							DEC_CTRL(CTRL_SHIFT_M_1 downto CTRL_SHIFT_M_0) <= INSTR_REG(06 downto 05); -- SHIFT MODE
							IMM_OUT(31 downto 00)	<= (others => '0'); -- IMMEDIATE
							DEC_CTRL(CTRL_SHIFTR)	<= '1'; -- SHIFT_REG
					end case;

					if (INSTR_REG(23) = '0') then -- sub index
						DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= A_SUB; -- ALU_CTRL = SUB
					else -- add index
						DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= A_ADD; -- ALU_CTRL = ADD
					end if;

					temp_3 := INSTR_REG(20) & INSTR_REG(24) & INSTR_REG(21);
					case temp_3 is -- L_P_W

						when "110" => -- load, pre indexing, no write back
						----------------------------------------------------------------------------------
							DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)		<= INSTR_REG(15 downto 12); -- R_DEST
							DEC_CTRL(CTRL_MEM_ACC)						<= '1'; -- MEM_ACCESS
							DEC_CTRL(CTRL_MEM_RW)						<= '0'; -- MEM_READ
							DEC_CTRL(CTRL_WB_EN)						<= '1'; -- WB EN
							NEXT_DUAL_OP(0)								<= '0';
							REG_SEL(OP_A_IS_REG)    					<= '1';
							REG_SEL(OP_B_IS_REG)   						<= INSTR_REG(25);
							REG_SEL(OP_C_IS_REG)    					<= '0';

						when "111" => -- load, pre indexing, write back
						----------------------------------------------------------------------------------
							if (DUAL_OP(0) = '0') then -- ADD/SUB Ra,Ra,Op_B
								DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)	<= INSTR_REG(19 downto 16); -- Base
								DEC_CTRL(CTRL_MEM_ACC)					<= '0'; -- MEM_ACCESS
								DEC_CTRL(CTRL_WB_EN)					<= '1'; -- WB EN
								NEXT_DUAL_OP(0) 						<= '1';
								REG_SEL(OP_A_IS_REG)    				<= '1';
								REG_SEL(OP_B_IS_REG)   					<= INSTR_REG(25);
								REG_SEL(OP_C_IS_REG)    				<= '0';
							else -- LD Rd, Ra
								DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)			<= INSTR_REG(15 downto 12); -- R_DEST
								DEC_CTRL(CTRL_MEM_ACC)							<= '1'; -- MEM_ACCESS
								DEC_CTRL(CTRL_WB_EN)							<= '1'; -- WB EN
								NEXT_DUAL_OP(0)									<= '0';
								DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0)	<= PassA; -- ALU_CTRL = PassA
								REG_SEL(OP_A_IS_REG)    						<= '1';
								REG_SEL(OP_B_IS_REG)   							<= '0';
								REG_SEL(OP_C_IS_REG)    						<= '0';
							end if;

						when "100" | "101" => -- load, post indexing, always write back
						----------------------------------------------------------------------------------
							if (DUAL_OP(0) = '0') then -- LD Rd,Ra
								DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)			<= INSTR_REG(15 downto 12); -- R_DEST
								DEC_CTRL(CTRL_MEM_ACC)							<= '1'; -- MEM_ACCESS
								DEC_CTRL(CTRL_MEM_RW)							<= '0'; -- MEM_READ
								DEC_CTRL(CTRL_WB_EN)							<= '1'; -- WB EN
								NEXT_DUAL_OP(0)									<= '1';
								DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0)	<= PassA; -- ALU_CTRL = PassA
								REG_SEL(OP_A_IS_REG)    						<= '1';
								REG_SEL(OP_B_IS_REG)   							<= '0';
								REG_SEL(OP_C_IS_REG)    						<= '0';
							else -- ADD/SUB Ra,Ra,Op_B
								DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)	<= INSTR_REG(19 downto 16); -- R_DEST
								DEC_CTRL(CTRL_MEM_ACC)					<= '0'; -- MEM_ACCESS
								DEC_CTRL(CTRL_WB_EN)					<= '1'; -- WB EN
								NEXT_DUAL_OP(0)							<= '0';
								REG_SEL(OP_A_IS_REG)    				<= '1';
								REG_SEL(OP_B_IS_REG)   					<= INSTR_REG(25);
								REG_SEL(OP_C_IS_REG)    				<= '0';
							end if;

						when "010" => -- store, pre indexing, no write back
						----------------------------------------------------------------------------------
							DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)	<= INSTR_REG(19 downto 16); -- R_DEST <WAYNE>
							DEC_CTRL(CTRL_MEM_ACC)					<= '1'; -- MEM_ACCESS
							DEC_CTRL(CTRL_MEM_RW)					<= '1'; -- MEM_WRITE
							DEC_CTRL(CTRL_WB_EN)					<= '0'; -- WB EN
							NEXT_DUAL_OP(0)							<= '0';
							REG_SEL(OP_A_IS_REG)    				<= '1';
							REG_SEL(OP_B_IS_REG)   					<= INSTR_REG(25);
							REG_SEL(OP_C_IS_REG)    				<= '1';

						when "011" => -- store, pre indexing, write back
						----------------------------------------------------------------------------------
							DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)	<= INSTR_REG(19 downto 16); -- R_DEST
							DEC_CTRL(CTRL_MEM_ACC)					<= '1'; -- MEM_ACCESS
							DEC_CTRL(CTRL_MEM_RW)					<= '1'; -- MEM_WRITE
							DEC_CTRL(CTRL_WB_EN)					<= '1'; -- WB EN
							NEXT_DUAL_OP(0)							<= '0';
							REG_SEL(OP_A_IS_REG)    				<= '1';
							REG_SEL(OP_B_IS_REG)   					<= INSTR_REG(25);
							REG_SEL(OP_C_IS_REG)    				<= '1';

						when others => -- store, post indexing, always write back
						----------------------------------------------------------------------------------
							if (DUAL_OP(0) = '0') then -- ST Ra, Rd
								DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)			<= INSTR_REG(15 downto 12); -- R_DEST
								DEC_CTRL(CTRL_MEM_ACC)							<= '1'; -- MEM_ACCESS
								DEC_CTRL(CTRL_MEM_RW)							<= '1'; -- MEM_WRITE
								DEC_CTRL(CTRL_WB_EN)							<= '0'; -- WB EN
								NEXT_DUAL_OP(0)									<= '1';
								DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) 	<= PassA; -- ALU_CTRL = PassA
								REG_SEL(OP_A_IS_REG)    						<= '1';
								REG_SEL(OP_B_IS_REG)   							<= '0';
								REG_SEL(OP_C_IS_REG)    						<= '1';
							else -- ADD/SUB Ra,Ra,Op_B
								DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)	<= INSTR_REG(19 downto 16); -- R_DEST
								DEC_CTRL(CTRL_MEM_ACC)					<= '0'; -- MEM_ACCESS
								DEC_CTRL(CTRL_MEM_RW)					<= '0'; -- MEM_WRITE
								DEC_CTRL(CTRL_WB_EN)					<= '1'; -- WB EN
								NEXT_DUAL_OP(0)							<= '0';
								REG_SEL(OP_A_IS_REG)    				<= '1';
								REG_SEL(OP_B_IS_REG)   					<= INSTR_REG(25);
								REG_SEL(OP_C_IS_REG)    				<= '0';
							end if;

					end case;

				
				when "10" => -- BRANCH OPERATIONS / BLOCK DATA TRANSFER
				-- ============================================================================================
					if (INSTR_REG(25) = '1') then -- Branch (and Link)
					----------------------------------------------------------------------------------
						DEC_CTRL(CTRL_LINK)   <= INSTR_REG(24); -- LINK
						DEC_CTRL(CTRL_WB_EN)  <= INSTR_REG(24); -- WB_EN
						DEC_CTRL(CTRL_CONST)  <= '1'; -- IS_CONST
						DEC_CTRL(CTRL_BRANCH) <= '1'; -- BRANCH_INSTR
						DEC_CTRL(CTRL_SHIFT_V_4 downto CTRL_SHIFT_V_0) <= "00010"; -- SHIFT POS = 2 => x4
						DEC_CTRL(CTRL_SHIFT_M_1 downto CTRL_SHIFT_M_0) <= S_LSL; -- SHIFT MODE
						DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0)   <= A_ADD; -- ALU.ADD
						IMM_OUT(23 downto 0)  <= INSTR_REG(23 downto 0);
						for i in 24 to 31 loop
							IMM_OUT(i) <= INSTR_REG(23); -- IMMEDIATE sign extension
						end loop;

					else -- Block Data Transfer
					----------------------------------------------------------------------------------
						OP_ADR_OUT(OP_A_ADR_3 downto OP_A_ADR_0)     <= INSTR_REG(19 downto 16); -- BASE
						REG_SEL(OP_A_IS_REG)    				     <= '1'; -- BASE is always a register
						DEC_CTRL(CTRL_CONST)                         <= '1'; -- is immediate
						DEC_CTRL(CTRL_MEM_DQ_1 downto CTRL_MEM_DQ_0) <= DQ_WORD; -- word-quantity
						REG_SEL(OP_A_IS_REG)    				     <= '1'; -- op A is always the base register
						REG_SEL(OP_B_IS_REG)    				     <= '0'; -- OFFSET is always an immediate

						--- (Reversed) Up/Down indexing ---
						if (INSTR_REG(21) = '1') then -- perform write back
							if (INSTR_REG(23) = '0') then -- reverse sub index
								DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= A_ADD;
							else -- reverse add index
								DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= A_SUB;
							end if;
						else -- no write back
							if (INSTR_REG(23) = '0') then -- sub index
								DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= A_SUB;
							else -- add index
								DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= A_ADD;
							end if;
						end if;

						--- Register index manager ---
						OP_ADR_OUT(OP_C_ADR_3 downto OP_C_ADR_0) <= DUAL_OP(4 downto 1); -- register to process
						block_t_tmp_v := INSTR_REG(15 downto 0); -- register list
						block_t_en_v := block_t_tmp_v(to_integer(unsigned(DUAL_OP(4 downto 1)))); -- process current reg?

						--- Transfer action ---
						adr_offs_v := R_OFFSET; -- actual offset
						if (block_t_en_v = '1') then -- transfer register
							if (INSTR_REG(21) = '1') then -- perform write back
								if (INSTR_REG(23) = '1') then -- inc (reversed)
									NEXT_OFFSET <= Std_Logic_Vector(unsigned(adr_offs_v) - 1);
								else -- dec (reversed)
									NEXT_OFFSET <= Std_Logic_Vector(unsigned(adr_offs_v) + 1);
								end if;
							else -- no write back
								if (INSTR_REG(23) = '1') then -- inc (reversed)
									NEXT_OFFSET <= Std_Logic_Vector(unsigned(adr_offs_v) + 1);
								else -- dec (reversed)
									NEXT_OFFSET <= Std_Logic_Vector(unsigned(adr_offs_v) - 1);
								end if;
							end if;
						else -- empty cycle (no transfer)
							NEXT_OFFSET <= adr_offs_v; -- keep offset
--							DEC_CTRL(CTRL_COND_3 downto CTRL_COND_0) <= COND_NV; -- disable cycle
						end if;

						--- End-of-block control ---
						NEXT_DUAL_OP(0) <= DUAL_OP(0); -- keep flag
						NEXT_DUAL_OP(4 downto 1) <= Std_Logic_Vector(unsigned(DUAL_OP(4 downto 1)) + 1); -- next possible reg
						pc_in_list_v := '0';
						if (DUAL_OP(4 downto 1) = C_PC_ADR) then -- for last cycle ^^
							pc_in_list_v := '1';
							NEXT_DUAL_OP <= (others => '0'); -- finish instruction
						end if;

						--- Special functions ---
						DEC_CTRL(CTRL_AF)     <=      INSTR_REG(20)  and INSTR_REG(22) and      pc_in_list_v;  -- copy SMSR => CMSR when transf. the PC
						DEC_CTRL(CTRL_RD_USR) <= (not INSTR_REG(20)) and INSTR_REG(22)                       ; -- read regs from user bank
						DEC_CTRL(CTRL_WR_USR) <=      INSTR_REG(20)  and INSTR_REG(22) and (not pc_in_list_v); -- write regs to user bank

						--- The memory access itself ---
						DEC_CTRL(CTRL_MEM_ACC) <= block_t_en_v; -- MEM_ACCESS if valid transfer
						DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0) <= DUAL_OP(4 downto 1); -- R_DEST, just for load instr important
						if (block_t_en_v = '1') then
							if (INSTR_REG(20) = '1') then
								-- LD Rd, [Ra+-auto_offset]
								DEC_CTRL(CTRL_MEM_RW) <= '0'; -- MEM_READ
								DEC_CTRL(CTRL_WB_EN)  <= '1'; -- WB EN to save loaded data
							else
								-- ST [Ra+-auto_offset], Rd 
								DEC_CTRL(CTRL_MEM_RW) <= '1'; -- MEM_WRITE
								REG_SEL(OP_C_IS_REG)  <= '1'; -- the store-data
							end if;
						end if;

						--- First cycle: SETUP ---
						if (DUAL_OP(0) = '0') then
							-- Number of regs to transfer --
							number_of_regs_v := (others => '0');
							for i in 0 to 15 loop
								if (INSTR_REG(i) = '1') then
									number_of_regs_v := Std_Logic_Vector(unsigned(number_of_regs_v) + 1);
								else
									number_of_regs_v := number_of_regs_v;
								end if;
							end loop;

							-- Control for BASE' write back --
							DEC_CTRL(CTRL_COND_3 downto CTRL_COND_0) <= INSTR_REG(31 downto 28);
							DEC_CTRL(CTRL_RD_3 downto CTRL_RD_0)     <= INSTR_REG(19 downto 16); -- R_DEST = BASE
							DEC_CTRL(CTRL_WB_EN)                     <= INSTR_REG(21); -- WB EN
							NEXT_DUAL_OP                             <= "00001"; -- prepare for start
							REG_SEL(OP_C_IS_REG)                     <= '0';
							DEC_CTRL(CTRL_MEM_ACC)                   <= '0'; -- no memory access, thank you
							DEC_CTRL(CTRL_RD_USR)                    <= '0'; -- read regs from current bank
							DEC_CTRL(CTRL_WR_USR)                    <= '0'; -- write regs to current bank
							if (INSTR_REG(23) = '0') then -- sub index
								DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= A_SUB; -- ALU_CTRL = SUB
							else -- add index
								DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= A_ADD; -- ALU_CTRL = ADD
							end if;
							adr_offs_v := number_of_regs_v;

							-- Calculate start offset --
							if (INSTR_REG(21) = '1') then -- perform write back
								if (INSTR_REG(24) = '0') then
									if (INSTR_REG(23) = '1') then -- post, increment
										NEXT_OFFSET <= number_of_regs_v;
									else -- post, decrement
										NEXT_OFFSET <= "00001";
									end if;
								else
									if (INSTR_REG(23) = '1') then -- pre, increment
										NEXT_OFFSET <= Std_Logic_Vector(unsigned(number_of_regs_v) + 1);
									else -- pre, decrement
										NEXT_OFFSET <= "00000";
									end if;
								end if;
							else -- no write back
								if (INSTR_REG(24) = '0') then
									if (INSTR_REG(23) = '1') then -- post, increment
										NEXT_OFFSET <= "00000";
									else -- post, decrement
										NEXT_OFFSET <= Std_Logic_Vector(unsigned(number_of_regs_v) - 1);
									end if;
								else
									if (INSTR_REG(23) = '1') then -- pre, increment
										NEXT_OFFSET <= "00001";
									else -- pre, decrement
										NEXT_OFFSET <= number_of_regs_v;
									end if;
								end if;
							end if;
						end if;

						-- the lonely address inc --
						IMM_OUT(31 downto 0) <= x"000000" & '0' & adr_offs_v & "00"; -- auto offset

					end if;



				when others => -- COPROCESSOR REGISTER TRANSFER / SOFTWARE INTERRUPT
				-- ============================================================================================
					if (INSTR_REG(25 downto 24) = "11") then
						DEC_CTRL(CTRL_SWI) <= '1'; -- SOFTWARE INTERRUPT

					elsif (INSTR_REG(25 downto 24) = "10") and (INSTR_REG(11 downto 8) = SYS_CP_ADR) and (INSTR_REG(4) = '1') then -- CP #15 action
						DEC_CTRL(CTRL_CP_ACC) <= '1'; -- coprocessor access
						DEC_CTRL(CTRL_CP_RW)  <= not INSTR_REG(20); -- read/write
						DEC_CTRL(CTRL_CP_REG_3 downto CTRL_CP_REG_0) <= INSTR_REG(19 downto 16);
						if (INSTR_REG(20) = '0') then -- REG -> CP
						----------------------------------------------------------------------------------
							DEC_CTRL(CTRL_WB_EN) <= '0'; -- disable register write back
							REG_SEL(OP_B_IS_REG) <= '1';
							OP_ADR_OUT(OP_B_ADR_3 downto OP_B_ADR_0)     <= INSTR_REG(15 downto 12);
							DEC_CTRL(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) <= PassB; -- write CREG
						else -- CP -> REG
						----------------------------------------------------------------------------------
							DEC_CTRL(CTRL_WB_EN) <= '1'; -- enable register write back
							OP_ADR_OUT(CTRL_RD_3 downto CTRL_RD_0) <= INSTR_REG(15 downto 12);
						end if;


					else -- COPROCESSOR OPERATION / COPROCESSOR MEMORY TRANSFER
					----------------------------------------------------------------------------------
						DEC_CTRL(CTRL_UND) <= '1'; -- undefined instruction, since not implemented

					end if;

			end case;
	end process OPCODE_DECODER;


end instruction_decoder;
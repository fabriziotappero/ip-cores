-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- decode.vhd  --  Description of the decode pipeline stage
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
use ieee.numeric_std.all;
use work.arm_types.all;

entity decode is
port(
	clk : in std_logic;
	reset_n : in std_logic;
	
	fiq : in std_logic;
	irq : in std_logic;
	flush : in std_logic;
	low_flags : in std_logic_vector(5 downto 0);
	decode_stage_valid : in std_logic;
	inst_cache_miss : in std_logic;
	dec_pc_plus_4 : in unsigned(31 downto 0);
	dec_pc_plus_8 : in unsigned(31 downto 0);
	
	-- instruction being decoded
	inst_data : in std_logic_vector(31 downto 0);
	
	-- regiser file adresses
	rfile_A_adr : out std_logic_vector(4 downto 0);
	rfile_B_adr : out std_logic_vector(4 downto 0);
	rfile_C_adr : out std_logic_vector(4 downto 0);
	
	-- register operands
	exe_A_adr : out std_logic_vector(5 downto 0);
	exe_B_adr : out std_logic_vector(5 downto 0);
	exe_C_adr : out std_logic_vector(5 downto 0);
	exe_pc_plus_4 : out unsigned(31 downto 0);
	exe_pc_plus_8 : out unsigned(31 downto 0);

	-- output of the latch
	exe_stage_valid : out std_logic;
	exe_barrelshift_operand : out std_logic;
	exe_barrelshift_type : out std_logic_vector(1 downto 0);
	exe_literal_shift_amnt : out std_logic_vector(4 downto 0);
	exe_literal_data : out std_logic_vector(23 downto 0);
	exe_opb_is_literal : out std_logic;
	exe_opb_sel : out std_logic;
	exe_alu_operation : out ALU_OPERATION;
	exe_condition : out std_logic_vector(3 downto 0);
	exe_affect_sflags : out std_logic;
	exe_data_sel : out std_logic;
	exe_rdest_wren : out std_logic;
	exe_rdest_adr : out std_logic_vector(4 downto 0);
	exe_branch_en : out std_logic;
	exe_wb_sel : out std_logic;
	exe_mem_ctrl : out MEM_OPERATION;
	exe_mem_burstcount : out std_logic_vector(3 downto 0);

	-- 1 if the stage has completed an instruction for this cycle, 0 otherwise
	decode_blocked_n : out std_logic;
	-- enable signal for latch after the fetch stage
	decode_latch_enable : in std_logic
);
end entity decode;

architecture rtl of decode is

	signal state, next_state : DECODE_FSM;
	
	signal barrelshift_operand : std_logic;
	signal barrelshift_type : std_logic_vector(1 downto 0);
	signal literal_shift_amnt : std_logic_vector(4 downto 0);
	signal literal_data : std_logic_vector(23 downto 0);
	signal opb_is_literal : std_logic;
	signal opb_sel : std_logic;
	signal alu_operation : ALU_OPERATION;
	signal condition : std_logic_vector(3 downto 0);
	signal affect_sflags : std_logic;
	signal data_sel : std_logic;
	signal rdest_wren : std_logic;
	signal rdest_adr : std_logic_vector(4 downto 0);
	signal branch_en : std_logic;
	signal wb_sel : std_logic;
	signal mem_ctrl : MEM_OPERATION;
	signal mem_burstcount : std_logic_vector(3 downto 0);
	signal stage_active : std_logic;
	
	signal rfA_adr : std_logic_vector(5 downto 0);
	signal rfB_adr : std_logic_vector(5 downto 0);
	signal rfC_adr : std_logic_vector(5 downto 0);
	
	signal i, f, reset_l : std_logic;
	signal mode : std_logic_vector(3 downto 0);

	signal current_inst, current_inst_l : std_logic_vector(31 downto 0);

	signal ldmstm_cur_bitmask : std_logic_vector(15 downto 0);
	signal ldmstm_next_bitmask : std_logic_vector(15 downto 0);
	signal ldmstm_current_reg : integer range 0 to 15;

	-- remap register adresses (4 bits) to actual registers (5 adress bits)
	function address_remap(adr : std_logic_vector(3 downto 0);
	                       mode : std_logic_vector(3 downto 0)) return std_logic_vector is
	begin
		-- source : http://www.heyrick.co.uk/armwiki/The_Status_register
		-- highest bit of "mode" is always 1 and is not implemented
		case mode is
			when "0000" =>
			--user mode
				case adr is
					when "0000" => return r0;
					when "0001" => return r1;
					when "0010" => return r2;
					when "0011" => return r3;
					when "0100" => return r4;
					when "0101" => return r5;
					when "0110" => return r6;
					when "0111" => return r7;
					when "1000" => return r8;
					when "1001" => return r9;
					when "1010" => return r10;
					when "1011" => return r11;
					when "1100" => return r12;
					when "1101" => return r13;
					when "1110" => return r14;
					when others => return "-----";
				end case;
			
			when "0001" =>
			-- FIQ mode
				case adr is
					when "0000" => return r0;
					when "0001" => return r1;
					when "0010" => return r2;
					when "0011" => return r3;
					when "0100" => return r4;
					when "0101" => return r5;
					when "0110" => return r6;
					when "0111" => return r7;
					when "1000" => return fiq_r8;
					when "1001" => return fiq_r9;
					when "1010" => return fiq_r10;
					when "1011" => return fiq_r11;
					when "1100" => return fiq_r12;
					when "1101" => return fiq_r13;
					when "1110" => return fiq_r14;
					when others => return "-----";
				end case;
			
			when  "0010" =>
			-- IRQ mode
				case adr is
					when "0000" => return r0;
					when "0001" => return r1;
					when "0010" => return r2;
					when "0011" => return r3;
					when "0100" => return r4;
					when "0101" => return r5;
					when "0110" => return r6;
					when "0111" => return r7;
					when "1000" => return r8;
					when "1001" => return r9;
					when "1010" => return r10;
					when "1011" => return r11;
					when "1100" => return r12;
					when "1101" => return irq_r13;
					when "1110" => return irq_r14;
					when others => return "-----";
				end case;
			
			when "0011" =>
			-- Supervisor (software interrupt) mode
				case adr is
					when "0000" => return r0;
					when "0001" => return r1;
					when "0010" => return r2;
					when "0011" => return r3;
					when "0100" => return r4;
					when "0101" => return r5;
					when "0110" => return r6;
					when "0111" => return r7;
					when "1000" => return r8;
					when "1001" => return r9;
					when "1010" => return r10;
					when "1011" => return r11;
					when "1100" => return r12;
					when "1101" => return sup_r13;
					when "1110" => return sup_r14;
					when others => return "-----";
				end case;
			
			when "1011" =>
			-- Undefined instruction mode
				case adr is
					when "0000" => return r0;
					when "0001" => return r1;
					when "0010" => return r2;
					when "0011" => return r3;
					when "0100" => return r4;
					when "0101" => return r5;
					when "0110" => return r6;
					when "0111" => return r7;
					when "1000" => return r8;
					when "1001" => return r9;
					when "1010" => return r10;
					when "1011" => return r11;
					when "1100" => return r12;
					when "1101" => return und_r13;
					when "1110" => return und_r14;
					when others => return "-----";
				end case;

			when others => return "-----";
			end case;
	end;
	
	function address_remap_pc(adr : std_logic_vector(3 downto 0);
	                          mode : std_logic_vector(3 downto 0)) return std_logic_vector is
	begin
		-- adr is PC
		if adr = "1111"
		then
			return "1-----";
		else
			return "0" & address_remap(adr, mode);
		end if;
	end;

	function address_remap_spsr(mode : std_logic_vector(3 downto 0)) return std_logic_vector is
	begin
		case mode is	
			-- FIQ mode
			when "0001" => return fiq_spsr;
			-- IRQ mode
			when "0010" => return irq_spsr;
			-- Supervisor (software interrupt) mode
			when "0011" => return sup_spsr;
			-- Undefined instruction mode
			when "1011" => return und_spsr;
			-- user mode and invalid mode - undefined implementation
			when others => return "-----";
		end case;
	end;

	function count_set_bits(word : std_logic_vector) return integer is
		variable i, res : integer;
	begin
		res := 0;
		for i in 0 to word'length - 1 loop
			if word(i) = '1'
			then
				res := res + 1;
			end if;
		end loop;
		return res;
	end;

	function find_rightmost_bit(word : std_logic_vector(15 downto 0)) return integer is
		variable i : integer;
	begin
		i := 0;
		while i < 15 and word(i) = '0' loop
			i := i + 1;
		end loop;
		return i;
	end;

begin
	-- separate low flags bits
	i <= low_flags(5);
	f <= low_flags(4);
	mode <= low_flags(3 downto 0);

	stage_active <= '1' when inst_cache_miss = '0' and decode_stage_valid = '1' and decode_latch_enable = '1' else '0';

	-- instruction latch
	process(clk) is
	begin
		if rising_edge(clk)
		then
			current_inst_l <= current_inst;
		end if;
	end process;
	current_inst <= inst_data when stage_active = '1' and state = MAIN_STATE else current_inst_l;

	-- output latch
	process(clk) is
	begin
		if rising_edge(clk)
		then
			if decode_latch_enable = '1'
			then
				exe_A_adr <= rfA_adr;
				exe_B_adr <= rfB_adr;
				exe_C_adr <= rfC_adr;
				exe_pc_plus_8 <= dec_pc_plus_8;
				exe_pc_plus_4 <= dec_pc_plus_4;

				exe_stage_valid <= stage_active;
				exe_barrelshift_operand <= barrelshift_operand;
				exe_barrelshift_type <= barrelshift_type;
				exe_literal_shift_amnt <= literal_shift_amnt;
				exe_literal_data <= literal_data;
				exe_opb_is_literal <= opb_is_literal;
				exe_opb_sel <= opb_sel;
				exe_alu_operation <= alu_operation;
				exe_condition <= condition;
				exe_affect_sflags <= affect_sflags;
				exe_data_sel <= data_sel;
				exe_rdest_wren <= rdest_wren;
				exe_rdest_adr <= rdest_adr;
				exe_branch_en <= branch_en;
				exe_wb_sel <= wb_sel;
				exe_mem_ctrl <= mem_ctrl;
				exe_mem_burstcount <= mem_burstcount;

				ldmstm_cur_bitmask <= ldmstm_next_bitmask;
			end if;
			if flush = '1'
			then
				exe_stage_valid <= '0';
			end if;
		end if;
	end process;

	fsm : process(clk, reset_n) is
	begin
		if reset_n = '0'
		then
			state <= MAIN_STATE;
		elsif rising_edge(clk)
		then
			if stage_active = '1'
			then
				state <= next_state;
			end if;
		end if;
	end process fsm;

	-- reset interrupt happens one cycle after reset_n is deasserted
	resetl : process(clk, reset_n) is
	begin
		if reset_n = '0'
		then
			reset_l <= '1';
		elsif rising_edge(clk)
		then
			if stage_active = '1'
			then
				reset_l <= '0';
			end if;
		end if;
	end process resetl;
	
	ldmstm_current_reg <= find_rightmost_bit(current_inst(15 downto 0) and ldmstm_cur_bitmask);

	-- Decoding matrix : please consult the decode matrix spreadsheet for more information about how this works
	decode : process(state, flush, current_inst, low_flags, reset_l, irq, fiq, mode, f, i, stage_active, ldmstm_cur_bitmask, ldmstm_current_reg, ldmstm_next_bitmask) is
	begin
		-- default instruction condition
		condition <= current_inst(31 downto 28);

		-- behaviour in case of cache miss (the state should not be changed, and other values are don't care)
		next_state <= state;

		-- using PC as a "unused" register is good in the way it prevents forwarding to stall the processor without reason
		rfA_adr <= "1-----";
		rfB_adr <= "1-----";
		rfC_adr <= "1-----";

		rdest_adr <= (others=>'-');
		barrelshift_operand <= '-';
		barrelshift_type <= (others=>'-');
		literal_shift_amnt <= (others=>'-');
		literal_data <= (others=>'-');
		opb_is_literal <= '-';
		opb_sel <= '-';
		alu_operation <= ALU_NOP;
		affect_sflags <= '-';
		rdest_wren <= '-';
		data_sel <= '-';
		branch_en <= '-';
		wb_sel <= '-';
		mem_ctrl <= NO_MEM_OP;
		mem_burstcount <= "----";
		ldmstm_next_bitmask <= (others=>'1');
		
		if flush = '1'
		then
			next_state <= MAIN_STATE;
		elsif stage_active = '1' 
		then
			if state = MAIN_STATE or state = RETURN_FROM_EXCEPTION or state = LDMSTM_TRANSFER
			then
				-- reset interrupt - used to move into user mode
				if reset_l = '1'
				then
					condition <= "1110";
					next_state <= RESET_CYCLE2;
					alu_operation <= ALU_RWF;
					affect_sflags <= '1';
					branch_en <= '0';
					rdest_wren <= '0';
					mem_ctrl <= NO_MEM_OP;

					-- Enter USR mode, clears IRQ and FIQ flags
					barrelshift_operand <= '0';
					barrelshift_type <= "00";
					literal_shift_amnt <= (others => '0');
					literal_data <= (23 downto 8 => '0') & "00010000";
					opb_is_literal <= '1';
					opb_sel <= '0';
				
				-- See if a FIQ interrupt is pending
				elsif state = MAIN_STATE and f = '0' and fiq = '1'
				then
					condition <= "1110";		-- force ALWAYS condition, so that the FIQ is always executed !
					next_state <= FIQ_CYCLE2;
					-- read CPSR and save it in fiq_SPSR, and also write new value to CPSR at the same time
					alu_operation <= ALU_RWF;
					affect_sflags <= '1';
					data_sel <= '1';
					branch_en <= '0';
					rdest_wren <= '1';
					wb_sel <= '0';
					mem_ctrl <= NO_MEM_OP;
					rdest_adr <= fiq_SPSR;

					-- Enter FIQ mode, set FIQ and IRQ flags
					barrelshift_operand <= '0';
					barrelshift_type <= "00";
					literal_shift_amnt <= (others => '0');
					literal_data <= (23 downto 8 => '0') & "11010001";
					opb_is_literal <= '1';
					opb_sel <= '0';

				-- See if an IRQ interrupt is pending
				elsif state = MAIN_STATE and i = '0' and irq = '1'
				then
					condition <= "1110";		-- force ALWAYS condition, so that the IRQ is always executed !
					next_state <= IRQ_CYCLE2;
					-- read CPSR and save it in fiq_SPSR, and also write new value to CPSR at the same time
					alu_operation <= ALU_RWF;
					affect_sflags <= '1';
					data_sel <= '1';
					branch_en <= '0';
					rdest_wren <= '1';
					wb_sel <= '0';
					mem_ctrl <= NO_MEM_OP;
					rdest_adr <= irq_SPSR;

					-- Enter IRQ mode, set IRQ flag, clear FIQ flag
					barrelshift_operand <= '0';
					barrelshift_type <= "00";
					literal_shift_amnt <= (others => '0');
					literal_data <= (23 downto 8 => '0') & "10010010";
					opb_is_literal <= '1';
					opb_sel <= '0';

				-- ** MUL/MLA instructions **
				elsif current_inst(27 downto 22) = "000000" and current_inst(7 downto 4) = "1001"
				then
					-- single cycle instruction
					next_state <= MAIN_STATE;
					
					-- ALU adds or does nothing
					if current_inst(21) = '0'
					then
						alu_operation <= ALU_NOP;
					else
						alu_operation <= ALU_ADD;
					end if;
					
					-- use multiplier
					opb_sel <= '1';
					affect_sflags <= current_inst(20);
					data_sel <= '1';
					branch_en <= '0';
					rdest_wren <= '1';
					wb_sel <= '0';
					-- no memory access
					mem_ctrl <= NO_MEM_OP;
					
					rdest_adr <= address_remap(current_inst(19 downto 16), mode);
					rfA_adr <= address_remap_pc(current_inst(15 downto 12), mode);
					rfB_adr <= address_remap_pc(current_inst(3 downto 0), mode);
					rfC_adr <= address_remap_pc(current_inst(11 downto 8), mode);
				

				-- ** MSR instruction **
				elsif (current_inst(27 downto 26) = "00" and current_inst(24 downto 23) = "10"
				and current_inst(21 downto 20) = "10" and current_inst(15 downto 12) = "1111")
				and (current_inst(25) = '1' or current_inst(11 downto 4) = X"00")
				then
					if current_inst(22) = '0'
					then
						-- ** write to CPSR **
						alu_operation <= ALU_RWF;
						-- wait an additional cycle, so that the decoding of next instruction is done in correct mode
						next_state <= ONE_LATENCY_CYCLE;
						-- don't write any register, write to flags
						affect_sflags <= '1';
						rdest_wren <= '0';
					else
						-- ** write to SPSR **
						alu_operation <= ALU_NOP;
						-- no need for a latency cycle, don't write flags, but need for writeback
						next_state <= MAIN_STATE;
						affect_sflags <= '0';
						rdest_wren <= '1';
					end if;
					data_sel <= '1';
					wb_sel <= '0';
					rdest_adr <= address_remap_spsr(mode);
					
					-- use barrel shifter
					opb_sel <= '0';
					branch_en <= '0';
					-- no memory access
					mem_ctrl <= NO_MEM_OP;

					-- rotate by literal value
					barrelshift_operand <= '0';
					if current_inst(25) = '1'
					then
						-- rotated constant adressing
						if current_inst(11 downto 8) = "0000" then
							-- no rotation - LSL #0
							barrelshift_type <= "00";
							literal_shift_amnt <= (others => '0');
						else
							-- use ROR barrelshift to compute rotated constant
							literal_shift_amnt <= current_inst(11 downto 8) & '0';
							barrelshift_type <= "11";
						end if;
						opb_is_literal <= '1';
						literal_data <= (23 downto 8 => '0') & current_inst(7 downto 0);
					else
						-- register adressing, use LSL #0 (i.e. no modification of the register)
						barrelshift_type <= "00";
						literal_shift_amnt <= (others => '0');
						opb_is_literal <= '0';
					end if;
					rfB_adr <= address_remap_pc(current_inst(3 downto 0), mode);

				-- ** MRS instruction **
				elsif current_inst(27 downto 23) = "00010" and current_inst(21 downto 16) = "001111" and current_inst(11 downto 0) = X"000"
				then
					next_state <= MAIN_STATE;
					
					if current_inst(22) = '0'
					then
						-- ** Read CPSR **
						alu_operation <= ALU_RWF;
					else
						-- ** Read SPSR **, use LSL #0 (i.e. no modification of the register)
						alu_operation <= ALU_NOP;
					end if;
					
					opb_sel <= '0';
					rfB_adr <= '0' & address_remap_spsr(mode);
					barrelshift_operand <= '0';
					barrelshift_type <= "00";
					literal_shift_amnt <= (others => '0');
					opb_is_literal <= '0';
					
					-- don't affect sflags, always write back ALU data
					affect_sflags <= '0';
					data_sel <= '1';
					branch_en <= '0';
					rdest_wren <= '1';
					wb_sel <= '0';
					mem_ctrl <= NO_MEM_OP;
					rdest_adr <= address_remap(current_inst(15 downto 12), mode);

				-- ** data processing instructions **
				elsif current_inst(27 downto 26) = "00"
				and ((current_inst(4)='0' or (current_inst(4)='1' and current_inst(7)='0')) or current_inst(25)='1')
				then
					-- this is (normally) a single cycle instruction
					next_state <= MAIN_STATE;
					
					case current_inst(24 downto 21) is
					-- ADC instruction
					when "0101" => alu_operation <= ALU_ADC;
					-- ADD instruction
					when "0100" => alu_operation <= ALU_ADD;
					-- AND instruction
					when "0000" => alu_operation <= ALU_AND;
					-- BIC instruction
					when "1110" => alu_operation <= ALU_BIC;
					-- CMN instruction
					when "1011" => alu_operation <= ALU_ADD;
					-- CMP instruction
					when "1010" => alu_operation <= ALU_SUB;
					-- EOR instruction
					when "0001" => alu_operation <= ALU_EOR;
					-- MVN instruction
					when "1111" => alu_operation <= ALU_NOT;
					-- ORR instruction
					when "1100" => alu_operation <= ALU_ORR;
					-- RSB instruction
					when "0011" => alu_operation <= ALU_RSB;
					-- RSC instruction
					when "0111" => alu_operation <= ALU_RSC;
					-- SBC instruction
					when "0110" => alu_operation <= ALU_SBC;
					-- SUB instruction
					when "0010" => alu_operation <= ALU_SUB;
					-- TEQ instruction
					when "1001" => alu_operation <= ALU_EOR;
					-- TST instruction
					when "1000" => alu_operation <= ALU_AND;
					-- MOV instruction
					when others => alu_operation <= ALU_NOP;
					end case;
					
					-- use barrelshifter
					opb_sel <= '0';

					-- CMP, CMN, TEQ and TST instructions always affect sflags, never write enable
					if current_inst(24 downto 23) = "10"
					then
						affect_sflags <= '1';
						rdest_wren <= '0';
					else
						-- other instructions
						affect_sflags <= current_inst(20);
						if current_inst(15 downto 12) = "1111"
						then
							rdest_wren <= '0';
						else
							rdest_wren <= '1';
						end if;
					end if;
					
					-- use ALU result, writeback from ALU, no memory operation
					data_sel <= '1';
					wb_sel <= '0';
					mem_ctrl <= NO_MEM_OP;

					literal_data <= (23 downto 8 => '0') & current_inst(7 downto 0);
					opb_is_literal <= current_inst(25);
					
					rdest_adr <= address_remap(current_inst(15 downto 12), mode);
					rfA_adr <= address_remap_pc(current_inst(19 downto 16), mode);
					rfB_adr <= address_remap_pc(current_inst(3 downto 0), mode);
					rfC_adr <= address_remap_pc(current_inst(11 downto 8), mode);

					-- adressing mode decoding
					if current_inst(4)='1' and current_inst(25)='0'
					then
						barrelshift_operand <= '1' ;
					else
						barrelshift_operand <= '0';
					end if;
					if current_inst(25) = '0'
					then
						-- rotated register adressing
						barrelshift_type <= current_inst(6 downto 5);
						literal_shift_amnt <= current_inst(11 downto 7);
					else
						if current_inst(11 downto 8) = "0000"
						then
							-- no rotation - LSL #0
							barrelshift_type <= "00";
							literal_shift_amnt <= (others => '0');
						else
							-- use ROR barrelshift to compute rotated constant
							literal_shift_amnt <= current_inst(11 downto 8) & '0';
							barrelshift_type <= "11";
						end if;
					end if;

					-- is rdest = r15 = PC (hidden jump instruction) ?
					if current_inst(15 downto 12) = "1111"
					then
						if current_inst(20) = '0'
						then
							branch_en <= '1';
						else
							-- special 2 cycle return from instruction
							if state = MAIN_STATE
							then
								-- 1st cycle : move the SPSR into CPSR
								affect_sflags <= '1';		-- ALWAYS affect sflags

								-- ** Read SPSR **, use LSL #0 (i.e. no modification of the register)
								barrelshift_operand <= '0';
								barrelshift_type <= "00";
								literal_shift_amnt <= (others => '0');
								opb_is_literal <= '0';
								rfB_adr <= '0' & address_remap_spsr(mode);

								-- write flags and execute the real instruction on next cycle
								alu_operation <= ALU_RWF;
								branch_en <= '0';
								next_state <= RETURN_FROM_EXCEPTION;
							
							else
								-- 2nd cycle of a ***S R15, **** instruction
								-- which is used to return from an exeption
								branch_en <= '1';
								affect_sflags <= '0';	-- do NOT affect sflags, obviously
							end if;
						end if;
					else
						branch_en <= '0' ;
					end if;
				
				-- ** branch instructions **
				elsif current_inst(27 downto 25) = "101"
				then
					next_state <= MAIN_STATE;
					alu_operation <= ALU_ADD;
					opb_sel <= '0';
					affect_sflags <= '0';
					branch_en <= '1';
					
					data_sel <= '0';
					if(current_inst(24) = '1')
					then
					-- BL, write PC+4 into R14 of current mode
						rdest_wren <= '1';
					else
					-- normal branch
						rdest_wren <= '0';
					end if;
					wb_sel <= '0';
					rdest_adr <= address_remap("1110", mode);
					
					rfA_adr <= "100000";

					-- multiply operand by 4 (LSL #2)
					barrelshift_operand <= '0';
					barrelshift_type <= "00";
					literal_shift_amnt <= "00010";
					literal_data <= current_inst(23 downto 0);
					opb_is_literal <= '1';
					mem_ctrl <= NO_MEM_OP;

				-- ** LDR(B) instruction **
				elsif current_inst(27 downto 26) = "01" and current_inst(20) = '1'
				and ((current_inst(21) = '0') or (current_inst(21) = '1' and current_inst(24) = '1'))
				then
					-- if pre or post-indexed adressing with writeback enabled, a second state is needed
					if current_inst(24) = current_inst(21)
					then
						next_state <= LOADSTORE_WRITEBACK;
					else
						if current_inst(15 downto 12) = "1111"
						then		-- insert two bubbles if loading into R15
							next_state <= TWO_LATENCY_CYCLES;
						else
							next_state <= MAIN_STATE;
						end if;
					end if;

					-- add/sub address (common lines for all load/store instructions cycles)
					if current_inst(23) = '0'
					then
						alu_operation <= ALU_SUB;
					else
						alu_operation <= ALU_ADD;
					end if;
					affect_sflags <= '0';
					opb_sel <= '0';
					barrelshift_operand <= '0';
					data_sel <= '1';

					-- branch if loading to R15, else writeback
					if current_inst(15 downto 12) = "1111"
					then
						branch_en <= '1';
						rdest_wren <= '0';
					else
						branch_en <= '0';
						rdest_wren <= '1';
					end if;

					-- write back from data bus
					wb_sel <= '1';
					rdest_adr <= address_remap(current_inst(15 downto 12), mode);
					
					if current_inst(22) = '1'
					then
						mem_ctrl <= LOAD_BYTE;
					else
						mem_ctrl <= LOAD_WORD;
					end if;
					mem_burstcount <= "0001";

					rfA_adr <= address_remap_pc(current_inst(19 downto 16), mode);
					rfB_adr <= address_remap_pc(current_inst(3 downto 0), mode);

					-- offset adressing
					if current_inst(25) = '0'
					then
						barrelshift_type <= "00";	-- LSR #00
						literal_shift_amnt <= (others => '0');
						literal_data <= (23 downto 12 => '0') & current_inst(11 downto 0);
						opb_is_literal <= '1';
					else
					-- register addressing
						barrelshift_type <= current_inst(6 downto 5);
						literal_shift_amnt <= current_inst(11 downto 7);
						opb_is_literal <= '0';
					end if;
					literal_data <= (23 downto 12 => '0') & current_inst(11 downto 0);
					
					if current_inst(24) = '0'
					then
						literal_data <= (others => '0');
						opb_is_literal <= '1';
						barrelshift_type <= "00";
					end if;

				-- ** STR(B) instruction **
				elsif current_inst(27 downto 26) = "01" and current_inst(20) = '0'
				and ((current_inst(21) = '0') or (current_inst(21) = '1' and current_inst(24) = '1'))
				then
					if current_inst(24) = '0'
					then
						next_state <= LOADSTORE_WRITEBACK;
					else
						next_state <= MAIN_STATE;
					end if;
					
					-- pre-indexing : add/sub address
					if current_inst(23) = '0'
					then
						alu_operation <= ALU_SUB;
					else
						alu_operation <= ALU_ADD;
					end if;

					affect_sflags <= '0';
					opb_sel <= '0';
					barrelshift_operand <= '0';
					data_sel <= '1';

					branch_en <= '0';
					wb_sel <= '0';
					rdest_adr <= address_remap(current_inst(19 downto 16), mode);
					rdest_wren <= current_inst(21);

					if current_inst(22) = '1'
					then
						mem_ctrl <= STORE_BYTE;
					else
						mem_ctrl <= STORE_WORD;
					end if;
					mem_burstcount <= "0001";

					rfA_adr <= address_remap_pc(current_inst(19 downto 16), mode);
					rfB_adr <= address_remap_pc(current_inst(3 downto 0), mode);
					rfC_adr <= address_remap_pc(current_inst(15 downto 12), mode);
					
					-- offset adressing
					if current_inst(25) = '0'
					then
						barrelshift_type <= "00";	-- LSR #00
						literal_shift_amnt <= (others => '0');
						opb_is_literal <= '1';
					else
					-- register addressing
						barrelshift_type <= current_inst(6 downto 5);
						literal_shift_amnt <= current_inst(11 downto 7);
						opb_is_literal <= '0';
					end if;
					literal_data <= (23 downto 12 => '0') & current_inst(11 downto 0);
					
					if current_inst(24) = '0'
					then
						literal_data <= (others => '0');
						opb_is_literal <= '1';
						barrelshift_type <= "00";
					end if;

				-- LDM/STM instruction, procceed to burst transfter start
				elsif current_inst(27 downto 25) = "100" and current_inst(15 downto 0) /= x"0000"
				then
					-- ldmstm_current_reg := 0;

					-- while current_inst(ldmstm_current_reg) = '0' and ldmstm_cur_bitmask(ldmstm_current_reg) = '0' loop
						-- ldmstm_current_reg := ldmstm_current_reg + 1;
					-- end loop;				

					-- Compute mask for next cycle, excluding the current register
					for n in 0 to 15
					loop
						if n > ldmstm_current_reg
						then
							ldmstm_next_bitmask(n) <= '1';
						else
							ldmstm_next_bitmask(n) <= '0';
						end if;
					end loop;

					-- Don't branch by default
					branch_en <= '0';

					-- Check if we are done with the LDM/STM transfer
					if (ldmstm_next_bitmask and current_inst(15 downto 0)) = x"0000"
					then
						-- if we are loading from R15, we should branch
						if current_inst(20) = '1' and current_inst(15) = '1'
						then
							branch_en <= '1';
							-- if the 'S' flag is set, we should move SPSR to CPSR, and do a potential writeback the following cycle
							if current_inst(22) = '1'
							then
								next_state <= LDMSTM_RETURN_FROM_EXCEPTION;
							-- 'S' flag is clear, directly do the writeback, then insert a bubble
							elsif current_inst(21) = '1'
							then
								next_state <= LDMSTM_WRITEBACK;
							-- Neither of those are true -> insert two bubbles
							else
								next_state <= TWO_LATENCY_CYCLES;
							end if;
						
						-- Is writeback enabled in something that is not STMDB ?
						elsif current_inst(21) = '1' and (current_inst(24 downto 23) /= "10" or current_inst(20) /= '0')
						then
							-- Yes -> a writeback cycle should follow
							next_state <= LDMSTM_WRITEBACK;
						else
							-- No -> continue code execution
							next_state <= MAIN_STATE;
						end if;
					else
						next_state <= LDMSTM_TRANSFER;
					end if;

					-- Use SUB, for IA and IB addressing, use ADD
					if current_inst(23) = '0'
					then
						alu_operation <= ALU_SUB;
					else
						alu_operation <= ALU_ADD;
					end if;

					-- Use barrelshifter in all cases
					opb_sel <= '0';
					affect_sflags <= '0';
					data_sel <= '1';
					barrelshift_operand <= '1';

					-- If we are loading a register which is not R15, writeback si enabled
					if (current_inst(20) = '1' and ldmstm_current_reg /= 15)
					-- If base writeback is enabled and we are in a STMDB instruction, writeback is enabled
					or (current_inst(24 downto 23) = "10" and current_inst(21 downto 20) = "10" and state = MAIN_STATE)
					then
						rdest_wren <= '1';
					else
						rdest_wren <= '0';
					end if;

					wb_sel <= current_inst(20);

					if current_inst(20) = '1'
					then
						-- Load from memory in the case of LDM
						wb_sel <= '1';
						
						-- if S bit is clear or r15 is in the list (ret. from interrupt), load into current mode registers
						if current_inst(22) = '0' or current_inst(15) = '1'
						then
							rdest_adr <= address_remap(std_logic_vector(to_unsigned(ldmstm_current_reg, 4) ), mode);
						else
							-- S bit is set and r15 is not in the list, load into user mode registers
							rdest_adr <= address_remap(std_logic_vector(to_unsigned(ldmstm_current_reg, 4) ), "0000");
						end if;

						-- Start a burst if this is the 1st cylce, else continue a burst
						if state = MAIN_STATE
						then
							mem_ctrl <= LOAD_WORD;
						else
							mem_ctrl <= LOAD_BURST;
						end if;
					else
						-- Write back the address (STM, only actually used in STMDB, as it's the only case where the address is correct)
						wb_sel <= '0';
						
						rdest_adr <= address_remap(current_inst(19 downto 16), mode);
						mem_ctrl <= STORE_WORD;
					end if;

					-- Send the number of transfers that should be done
					mem_burstcount <= std_logic_vector(to_unsigned(count_set_bits(current_inst(15 downto 0)) , 4));

					rfA_adr <= address_remap_pc(current_inst(19 downto 16), mode);
					
					if current_inst(22) = '0'
					then
						rfC_adr <= address_remap_pc(std_logic_vector(to_unsigned(ldmstm_current_reg, 4) ), mode);
					else
						-- S bit is set, store user mode registers insted of current mode
						rfC_adr <= address_remap_pc(std_logic_vector(to_unsigned(ldmstm_current_reg, 4) ), "0000");
					end if;
					
					-- LSL #0
					barrelshift_type <= "00";
					barrelshift_operand <= '0';
					literal_shift_amnt <= "00010";

					case current_inst(24 downto 23) is
					-- IA
					when "01" => literal_data <= x"000000";
					-- IB
					when "11" => literal_data <= x"000001";
					-- DA
					when "00" => literal_data <= std_logic_vector(to_signed(count_set_bits(current_inst(15 downto 0)) - 1, 24));
					-- DB
					when others =>	literal_data <= std_logic_vector(to_signed(count_set_bits(current_inst(15 downto 0)), 24));
					end case;
					
					opb_is_literal <= '1';

				-- SWI (software interrupt) instruction
				elsif current_inst(27 downto 24) = "1111"
				then
					next_state <= SWI_CYCLE2;
					-- read CPSR and save it in sup_SPSR, and also write new value to CPSR at the same time
					alu_operation <= ALU_RWF;
					affect_sflags <= '1';
					data_sel <= '1';
					branch_en <= '0';
					rdest_wren <= '1';
					wb_sel <= '0';
					mem_ctrl <= NO_MEM_OP;
					rdest_adr <= sup_SPSR;

					-- Enter supervisor mode, clears FIQ or IRQ flags
					barrelshift_operand <= '0';
					barrelshift_type <= "00";
					literal_shift_amnt <= (others => '0');
					literal_data <= (23 downto 8 => '0') & "00010011";
					opb_is_literal <= '1';
					opb_sel <= '0';

				-- ** Undefined instruction **
				else
					-- Could not decode the instruction, start an undefined instruction trap interrupt
					next_state <= UNDEF_CYCLE2;
					-- read CPSR and save it in fiq_SPSR, and also write new value to CPSR at the same time
					alu_operation <= ALU_RWF;
					affect_sflags <= '1';
					data_sel <= '1';
					branch_en <= '0';
					rdest_wren <= '1';
					wb_sel <= '0';
					mem_ctrl <= NO_MEM_OP;
					rdest_adr <= und_SPSR;

					-- Enter UNDEF mode, clears FIQ and IRQ flags
					barrelshift_operand <= '0';
					barrelshift_type <= "00";
					literal_shift_amnt <= (others => '0');
					literal_data <= (23 downto 8 => '0') & "00011011";
					opb_is_literal <= '1';
					opb_sel <= '0';
				end if;

			elsif state = TWO_LATENCY_CYCLES
			then
				-- 2 dummy latency cycles which does nothing
				next_state <= ONE_LATENCY_CYCLE;
				affect_sflags <= '0';
				rdest_wren <= '0';
				branch_en <= '0';
				mem_ctrl <= NO_MEM_OP;

			elsif state = ONE_LATENCY_CYCLE
			then
				-- a dummy latency cycle which do nothing
				next_state <= MAIN_STATE;

				affect_sflags <= '0';
				rdest_wren <= '0';
				branch_en <= '0';
				mem_ctrl <= NO_MEM_OP;

			-- Rn writeback state after a load or a store
			elsif state = LOADSTORE_WRITEBACK
			then
				-- one more latency cycle needed if loading from PC
				if current_inst(20) = '1' and current_inst(15 downto 12) = "1111"
				then
					next_state <= ONE_LATENCY_CYCLE;
				else
					next_state <= MAIN_STATE;
				end if;
				
				-- add/sub address
				if current_inst(23) = '1'
				then
					alu_operation <= ALU_ADD;
				else
					alu_operation <= ALU_SUB;
				end if;
				affect_sflags <= '0';
				opb_sel <= '0';
				barrelshift_operand <= '0';
				data_sel <= '1';

				branch_en <= '0';
				rdest_wren <= '1';
				wb_sel <= '0';
				rdest_adr <= address_remap(current_inst(19 downto 16), mode);
				mem_ctrl <= NO_MEM_OP;
				
				rfA_adr <= address_remap_pc(current_inst(19 downto 16), mode);
				rfB_adr <= address_remap_pc(current_inst(3 downto 0), mode);

				-- offset adressing
				if current_inst(25) = '0'
				then
					barrelshift_type <= "00";	-- LSR #00
					literal_shift_amnt <= (others => '0');
					literal_data <= (23 downto 12 => '0') & current_inst(11 downto 0);
					opb_is_literal <= '1';
				else
				-- register addressing
					barrelshift_type <= current_inst(6 downto 5);
					literal_shift_amnt <= current_inst(11 downto 7);
					opb_is_literal <= '0';
				end if;

			elsif state = LDMSTM_WRITEBACK
			then
				-- one more latency cycle needed if loading from PC and S flag was clear
				if current_inst(20) = '1' and current_inst(15) = '1' and current_inst(22) = '0'
				then
					next_state <= ONE_LATENCY_CYCLE;
				else
					next_state <= MAIN_STATE;
				end if;

				-- add/sub address
				if current_inst(23) = '1'
				then
					alu_operation <= ALU_ADD;
				else
					alu_operation <= ALU_SUB;
				end if;

				branch_en <= '0';
				affect_sflags <= '0';
				opb_sel <= '0';
				barrelshift_operand <= '0';
				data_sel <= '1';
				rdest_wren <= '1';
				wb_sel <= '0';
				rdest_adr <= address_remap(current_inst(19 downto 16), mode);
				mem_ctrl <= NO_MEM_OP;
				rfA_adr <= address_remap_pc(current_inst(19 downto 16), mode);
				
				-- LSL #0
				barrelshift_type <= "00";
				literal_shift_amnt <= "00010";
				
				-- Add the # of register writtens to Rn and write it back
				literal_data <= std_logic_vector(to_signed(count_set_bits(current_inst(15 downto 0)) , 24));
				opb_is_literal <= '1';

			-- Cycle that moves SPSR -> CPSR when LDM with R15 in the list and S flag set
			elsif state = LDMSTM_RETURN_FROM_EXCEPTION
			then
				affect_sflags <= '1';		-- ALWAYS affect sflags

				-- ** Read SPSR **, use LSL #0 (i.e. no modification of the register)
				barrelshift_operand <= '0';
				barrelshift_type <= "00";
				literal_shift_amnt <= (others => '0');
				opb_is_literal <= '0';
				rfB_adr <= '0' & address_remap_spsr(mode);

				-- write flags and execute the real instruction on next cycle
				alu_operation <= ALU_RWF;
				branch_en <= '0';
				rdest_wren <= '0';

				if current_inst(21) = '1'
				then
					next_state <= LDMSTM_WRITEBACK;		-- if base writeback is enabled do it
				else
					next_state <= ONE_LATENCY_CYCLE;	-- else insert simply a bubble in the pipeline
				end if;

			-- 2nd cycle of an interrupt, very similar to a BL instruction
			elsif state = RESET_CYCLE2 or state = UNDEF_CYCLE2 or state = SWI_CYCLE2
			or state = IRQ_CYCLE2 or state = FIQ_CYCLE2
			then
				next_state <= MAIN_STATE;
				alu_operation <= ALU_NOP;
				opb_sel <= '0';
				affect_sflags <= '0';
				branch_en <= '1';
				
				-- BL, write PC+4 into R14 of current mode
				data_sel <= '0';
				rdest_wren <= '1';
				wb_sel <= '0';

				barrelshift_operand <= '0';
				barrelshift_type <= "00";
				literal_shift_amnt <= (others => '0');
				-- interrupt vectors
				case state is
				when RESET_CYCLE2 => literal_data <= x"000000";
									rdest_adr <= r14;
									-- prevents to fetch a useless opcode on next cycle
									next_state <= ONE_LATENCY_CYCLE;
									condition <= "1110";		-- always

				when UNDEF_CYCLE2 => literal_data <= x"000004";
									rdest_adr <= und_r14;

				when SWI_CYCLE2 => literal_data <= x"000008";
									rdest_adr <= und_r14;

				when IRQ_CYCLE2 => literal_data <= x"000018";
									rdest_adr <= irq_r14;
									next_state <= ONE_LATENCY_CYCLE;
									condition <= "1110";

				when others => literal_data <= x"00001c";		-- FIQ cycle 2
									rdest_adr <= fiq_r14;
									next_state <= ONE_LATENCY_CYCLE;
									condition <= "1110";
				end case;
				opb_is_literal <= '1';
				mem_ctrl <= NO_MEM_OP;
			end if;
		end if;
	end process decode;

	-- send the 4 low bits (adress bits) to the register file adresses
	rfile_A_adr <= rfA_adr(4 downto 0);
	rfile_B_adr <= rfB_adr(4 downto 0);
	rfile_C_adr <= rfC_adr(4 downto 0);

	--decode_blocked_n <= '0' when state /= MAIN_STATE or (decode_stage_valid = '1' and inst_cache_miss = '0') else '1';
	decode_blocked_n <= '0' when next_state /= MAIN_STATE or (inst_cache_miss = '1') else '1';

end architecture;
-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- execute.vhd  --  Description of the execute pipeline stage
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

entity execute is
	port(
		clk : in std_logic;
		n_reset : in std_logic;

		exe_A_adr, exe_B_adr, exe_C_adr : in std_logic_vector(5 downto 0);
		exe_stage_valid : in std_logic;
		exe_barrelshift_operand : in std_logic;
		exe_barrelshift_type : in std_logic_vector(1 downto 0);
		exe_literal_shift_amnt : in std_logic_vector(4 downto 0);
		exe_literal_data : in std_logic_vector(23 downto 0);
		exe_opb_is_literal : in std_logic;
		exe_opb_sel : in std_logic;
		exe_alu_operation : in ALU_OPERATION;
		exe_condition : in std_logic_vector(3 downto 0);
		exe_affect_sflags : in std_logic;
		exe_data_sel : in std_logic;
		exe_rdest_wren : in std_logic;
		exe_rdest_adr : in std_logic_vector(4 downto 0);
		exe_branch_en : in std_logic;
		exe_wb_sel : in std_logic;
		exe_mem_ctrl : in MEM_OPERATION;
		exe_mem_burstcount : in std_logic_vector(3 downto 0);

		exe_pc_plus_4 : in unsigned(31 downto 0);
		exe_pc_plus_8 : in unsigned(31 downto 0);
		--- fowrarding signals to come here

		rfile_A_data : in std_logic_vector(31 downto 0);
		rfile_B_data : in std_logic_vector(31 downto 0);
		rfile_C_data : in std_logic_vector(31 downto 0);

		fwd_wb2_enable : in std_logic;
		fwd_wb2_address : in std_logic_vector(4 downto 0);
		fwd_wb2_data : in std_logic_vector(31 downto 0);
		fwd_wb1_enable : in std_logic;
		fwd_wb1_address : in std_logic_vector(4 downto 0);
		fwd_wb1_data : in std_logic_vector(31 downto 0);
		fwd_wb1_is_invalid : in std_logic;
		fwd_mem_enable : in std_logic;
		fwd_mem_address : in std_logic_vector(4 downto 0);
		fwd_mem_data : in std_logic_vector(31 downto 0);
		fwd_mem_is_invalid : in std_logic;
		
		mem_stage_valid : out std_logic;
		mem_rdest_wren : out std_logic;
		mem_rdest_adr : out std_logic_vector(4 downto 0);
		mem_branch_en : out std_logic;
		mem_wb_sel : out std_logic;
		mem_exe_data : out std_logic_vector(31 downto 0);
		mem_wrdata : out std_logic_vector(31 downto 0);
		mem_mem_ctrl : out MEM_OPERATION;
		mem_mem_burstcount : out std_logic_vector(3 downto 0);

		low_flags : out std_logic_vector(5 downto 0);
		exe_PC_wrdata : out unsigned(31 downto 0);
		exe_blocked_n : out std_logic;
		exe_PC_wr : out std_logic;
		exe_latch_enable : in std_logic
	);
end entity;

architecture rtl of execute is
	
	signal exe_data : std_logic_vector(31 downto 0);
	signal stage_active, forward_ok, forward_a_ok, forward_b_ok, forward_c_ok, condition_is_true : std_logic;
	signal barrelshift_out, alu_out, mult_out, alu_opb, op_a_data, op_b_data, op_c_data : unsigned(31 downto 0);

	signal n, z, v, c : std_logic;
	signal next_n, next_z, next_v, next_c, barrelshift_c : std_logic;
	signal lowflags, next_lowflags : std_logic_vector(5 downto 0);

begin

	-- output latch
	process(clk, n_reset) is
	begin
		if n_reset = '0'
		then
			mem_stage_valid <= '0';
		elsif rising_edge(clk)
		then
			if exe_latch_enable = '1'
			then
				mem_stage_valid <= stage_active;
			end if;
		end if;
	end process;

	process(clk) is
	begin
		if rising_edge(clk)
		then
			if exe_latch_enable = '1'
			then
				mem_rdest_wren <= exe_rdest_wren;
				mem_rdest_adr <= exe_rdest_adr;
				mem_branch_en <= exe_branch_en;
				mem_wb_sel <= exe_wb_sel;
				mem_exe_data <= exe_data;
				mem_wrdata <= std_logic_vector(op_c_data);
				mem_mem_ctrl <= exe_mem_ctrl;
				mem_mem_burstcount <= exe_mem_burstcount;
			end if;
		end if;
	end process;

	low_flags <= lowflags;

	-- enable stage condition
	stage_active <= exe_stage_valid and forward_ok and condition_is_true;

	exe_data <= std_logic_vector(alu_out) when exe_data_sel = '1' else std_logic_vector(exe_pc_plus_4);
	exe_pc_wrdata <= alu_out;
	exe_pc_wr <= exe_branch_en and (not exe_wb_sel) and stage_active;

	exe_blocked_n <= forward_ok or not (exe_stage_valid and condition_is_true);

	-- fowrawrding for operand a
	fwa : entity work.forwarding(rtl) port map
	(
		reg => exe_A_adr,

		fwd_wb2_enable => fwd_wb2_enable,
		fwd_wb2_address => fwd_wb2_address,
		fwd_wb2_data => fwd_wb2_data,
		fwd_wb1_enable => fwd_wb1_enable,
		fwd_wb1_address => fwd_wb1_address,
		fwd_wb1_data => fwd_wb1_data,
		fwd_wb1_is_invalid => fwd_wb1_is_invalid,
		fwd_mem_enable => fwd_mem_enable,
		fwd_mem_address => fwd_mem_address,
		fwd_mem_data => fwd_mem_data,
		fwd_mem_is_invalid => fwd_mem_is_invalid,

		exe_pc_plus_8 => exe_pc_plus_8,
		rfile_data => rfile_a_data,
		
		forward_ok => forward_a_ok,
		op_data => op_a_data
	);

	-- fowrawrding for operand b
	fwb : entity work.forwarding(rtl) port map
	(
		reg => exe_B_adr,

		fwd_wb2_enable => fwd_wb2_enable,
		fwd_wb2_address => fwd_wb2_address,
		fwd_wb2_data => fwd_wb2_data,
		fwd_wb1_enable => fwd_wb1_enable,
		fwd_wb1_address => fwd_wb1_address,
		fwd_wb1_data => fwd_wb1_data,
		fwd_wb1_is_invalid => fwd_wb1_is_invalid,
		fwd_mem_enable => fwd_mem_enable,
		fwd_mem_address => fwd_mem_address,
		fwd_mem_data => fwd_mem_data,
		fwd_mem_is_invalid => fwd_mem_is_invalid,

		exe_pc_plus_8 => exe_pc_plus_8,
		rfile_data => rfile_b_data,
		
		forward_ok => forward_b_ok,
		op_data => op_b_data
	);

	-- fowrawrding for operands c
	fwc : entity work.forwarding(rtl) port map
	(
		reg => exe_C_adr,

		fwd_wb2_enable => fwd_wb2_enable,
		fwd_wb2_address => fwd_wb2_address,
		fwd_wb2_data => fwd_wb2_data,
		fwd_wb1_enable => fwd_wb1_enable,
		fwd_wb1_address => fwd_wb1_address,
		fwd_wb1_data => fwd_wb1_data,
		fwd_wb1_is_invalid => fwd_wb1_is_invalid,
		fwd_mem_enable => fwd_mem_enable,
		fwd_mem_address => fwd_mem_address,
		fwd_mem_data => fwd_mem_data,
		fwd_mem_is_invalid => fwd_mem_is_invalid,

		exe_pc_plus_8 => exe_pc_plus_8,
		rfile_data => rfile_c_data,
		
		forward_ok => forward_c_ok,
		op_data => op_c_data
	);
	-- in order for the forwarding to work, all 3 of the operands have to work
	forward_ok <= forward_a_ok and forward_b_ok and forward_c_ok;

	-- check if the condition is true
	with exe_condition select condition_is_true <=
		z when COND_EQ,
		not z when COND_NE,
		c when COND_CS,
		not c when COND_CC,
		n when COND_MI,
		not n when COND_PL,
		v when COND_VS,
		not v when COND_VC,
		c and not z when COND_HI,
		z or not c when COND_LS,
		n xnor v when COND_GE,
		n xor v when COND_LT,
		(not z) and (n xnor v) when COND_GT,
		z or (n xor v) when COND_LE,
		'1' when COND_AL,
		'-' when others;

	-- barrel shifter (exernal component)
	bs : entity work.barrelshift(optimized) port map
	(
		c => c,
		exe_barrelshift_operand => exe_barrelshift_operand,
		exe_barrelshift_type => exe_barrelshift_type,
		exe_literal_shift_amnt => exe_literal_shift_amnt,
		exe_literal_data => exe_literal_data,
		exe_opb_is_literal => exe_opb_is_literal,
		op_b_data => op_b_data,
		op_c_data => op_c_data,
		barrelshift_c => barrelshift_c,
		barrelshift_out => barrelshift_out
	);

	-- multiplier unit
	multiplier : process(op_b_data, op_c_data) is
		variable mult_dummy : unsigned(63 downto 0);
	begin
		mult_dummy := op_b_data * op_c_data;
		mult_out <= mult_dummy(31 downto 0);
	end process;
			
	-- end process;

	-- alu opb multiplexer
	alu_opb <= mult_out when exe_opb_sel = '1' else barrelshift_out;

	-- alu
	alu : entity work.alu(rtl) port map
	(
		exe_alu_operation => exe_alu_operation,
		alu_o => alu_out,
		alu_opb => alu_opb,
		alu_opa => op_a_data,
		n => n,
		z => z,
		c => c,
		v => v,
		lowflags => lowflags,
		barrelshift_c => barrelshift_c,
		next_n => next_n,
		next_z => next_z,
		next_c => next_c,
		next_v => next_v,
		next_lowflags => next_lowflags
	);

	-- flags flip flops
	process(clk, n_reset) is
	begin
		if rising_edge(clk)
		then
			if exe_affect_sflags = '1' and stage_active = '1' and exe_latch_enable = '1'
			then
				n <= next_n;
				z <= next_z;
				v <= next_v;
				c <= next_c;
				lowflags <= next_lowflags;
			end if;
		end if;
	end process;

end architecture;
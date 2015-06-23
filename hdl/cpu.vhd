-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- cpu.vhd  --  The top level module of the CPU
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
use ieee.math_real.all;
use work.arm_types.all;

entity cpu is
	generic(
		CACHE_BLOCK_BITWIDTH : natural := 5   -- byte address range of a block (hence C_BLOCK_SIZE = 2**BLOCK_BITWIDTH)
 	);
 	port(
		-- Globals
		clk   : in std_logic;
		reset : in std_logic;
		
		--Avalon Master Interface for instructions
		avm_inst_waitrequest   : in  std_logic;
		avm_inst_readdatavalid : in  std_logic;
		avm_inst_readdata      : in  std_logic_vector(31 downto 0);
		avm_inst_read          : out std_logic;
		avm_inst_burstcount    : out std_logic_vector(CACHE_BLOCK_BITWIDTH-2 downto 0);
		avm_inst_address       : out std_logic_vector(31 downto 0);
		
		--Avalon Master Interface for data
		avm_data_waitrequest   : in  std_logic;
		avm_data_readdatavalid : in  std_logic;
		avm_data_readdata      : in  std_logic_vector(31 downto 0);
		avm_data_read          : out std_logic;
		avm_data_writedata     : out std_logic_vector(31 downto 0);
		avm_data_write         : out std_logic;
		avm_data_byteen        : out std_logic_vector(3 downto 0);
		avm_data_burstcount    : out std_logic_vector(4 downto 0);
		avm_data_address       : out std_logic_vector(31 downto 0);
		
		--Interrupt interface
		inr_irq                : in  std_logic_vector(31 downto 0) := (others => '0')
	);
end entity;

architecture bench of cpu is

	signal n_reset  : std_logic := '0';
	signal fiq, irq : std_logic;
	signal inst_cache_adr, inst_data : std_logic_vector(31 downto 0);
	signal inst_cache_miss, pc_wr : std_logic := '0';
	signal pc_wrdata : unsigned(31 downto 0) := (others => 'Z');
	signal fetch_stage_en, fetch_latch_enable : std_logic;
	signal inst_cache_rd, flush, decode_stage_valid, decode_blocked_n, decode_latch_enable: std_logic;
	signal low_flags : std_logic_vector(5 downto 0);
	signal rfile_A_adr, rfile_B_adr, rfile_C_adr : std_logic_vector(4 downto 0);
	signal dec_pc_plus_8, dec_pc_plus_4, exe_pc_plus_8, exe_pc_plus_4 : unsigned(31 downto 0);
	signal exe_A_adr, exe_B_adr, exe_C_adr : std_logic_vector(5 downto 0);
	signal rfile_A_data, rfile_B_data, rfile_C_data : std_logic_vector(31 downto 0);
	signal exe_condition : std_logic_vector(3 downto 0);
	signal exe_stage_valid, exe_barrelshift_operand, exe_opb_is_literal, exe_opb_sel, exe_affect_sflags, exe_data_sel, exe_rdest_wren, exe_branch_en, exe_wb_sel, exe_latch_enable : std_logic;
	signal exe_barrelshift_type : std_logic_vector(1 downto 0);
	signal exe_literal_shift_amnt, exe_rdest_adr : std_logic_vector(4 downto 0);
	signal exe_literal_data : std_logic_vector(23 downto 0);
	signal exe_alu_operation : ALU_OPERATION;
	signal exe_mem_ctrl : MEM_OPERATION;
	signal exe_mem_burstcount : std_logic_vector(3 downto 0);
	signal exe_PC_wrdata : unsigned(31 downto 0);
	signal exe_pc_wr, exe_blocked_n : std_logic;
	signal mem_stage_valid, mem_rdest_wren, mem_branch_en, mem_wb_sel : std_logic;
	signal mem_rdest_adr : std_logic_vector(4 downto 0);
	signal mem_exe_data, mem_wrdata : std_logic_vector(31 downto 0);
	signal mem_mem_ctrl : MEM_OPERATION;
	signal mem_mem_burstcount : std_logic_vector(3 downto 0);
	signal mem_blocked_n, mem_latch_enable, fwd_mem_enable : std_logic;
	signal fwd_mem_address : std_logic_vector(4 downto 0);
	signal fwd_mem_data : std_logic_vector(31 downto 0);
	signal wb_stage_valid, wb_rdest_wren, wb_branch_en, wb_wb_sel : std_logic;
	signal wb_rdest_adr : std_logic_vector(4 downto 0);
	signal wb_exe_data : std_logic_vector(31 downto 0);
	signal wb_mem_ctrl : MEM_OPERATION;
	signal rfile_wr_enable, wb_pc_wr, wb_blocked_n : std_logic;
	signal rfile_address : std_logic_vector(4 downto 0);
	signal wb_data : std_logic_vector(31 downto 0);
	signal fwd_wb2_enable : std_logic;
	signal fwd_wb2_address : std_logic_vector(4 downto 0);
	signal fwd_wb2_data : std_logic_vector(31 downto 0);

begin

	n_reset <= not reset;

	c: entity work.cache(synth) generic map(
		INSTR_BADDR_BITWDTH => 32,  -- input coe_cpu_address width in bits
		BLOCK_BITWIDTH => CACHE_BLOCK_BITWIDTH,   -- byte address range of a block (hence C_BLOCK_SIZE = 2**BLOCK_BITWIDTH)
		CACHE_WAYS => 1,   -- number of ways in the cache (power of 2), for now only direct-mapped
		CACHE_SIZE => 4096 -- cache size in bytes, must be a factor of C_BLOCK_SIZE * CACHE_WAYS
 	) port map(
		-- Globals
		clk  => clk,
		reset => reset,

		-- CPU conduit extern
		coe_cpu_enabled  => inst_cache_rd, -- fetches a new instruction. If deactivated, the last read is kept on the output.
		coe_cpu_address  => inst_cache_adr, -- byte address
		coe_cpu_readdata => inst_data,
		coe_cpu_miss => inst_cache_miss,
		
		--Avalon Master Interface
		avm_waitrequest => avm_inst_waitrequest,
		avm_readdatavalid => avm_inst_readdatavalid,
		avm_readdata => avm_inst_readdata,
		avm_read => avm_inst_read,
		avm_burstcount => avm_inst_burstcount,
		avm_address => avm_inst_address
	);

	f : entity work.fetch(rtl) port map
	(
		clk => clk,
		n_reset => n_reset,
		decode_stage_valid => decode_stage_valid,
		dec_pc_plus_8 => dec_pc_plus_8,
		dec_pc_plus_4 => dec_pc_plus_4,
		flush => flush,
		inst_cache_adr => inst_cache_adr,
		inst_cache_rd => inst_cache_rd,
		pc_wr => pc_wr,
		pc_wrdata => pc_wrdata,
		fetch_stage_en => fetch_stage_en,
		
		fetch_latch_enable => fetch_latch_enable
	);

	d : entity work.decode(rtl) port map
	(
		clk => clk,
		reset_n => n_reset,
		fiq => fiq,
		irq => irq,
		flush => flush,
		low_flags => low_flags,
		decode_stage_valid => decode_stage_valid,
		inst_cache_miss => inst_cache_miss,
		dec_pc_plus_8 => dec_pc_plus_8,
		dec_pc_plus_4 => dec_pc_plus_4,
		
		inst_data => inst_data,
		decode_blocked_n => decode_blocked_n,

		rfile_A_adr => rfile_A_adr,
		rfile_B_adr => rfile_B_adr,
		rfile_C_adr => rfile_C_adr,
		
		exe_A_adr => exe_A_adr,
		exe_B_adr => exe_B_adr,
		exe_C_adr => exe_C_adr,
		exe_pc_plus_4 => exe_pc_plus_4,
		exe_pc_plus_8 => exe_pc_plus_8,

		exe_stage_valid => exe_stage_valid,
		exe_barrelshift_operand => exe_barrelshift_operand,
		exe_barrelshift_type => exe_barrelshift_type,
		exe_literal_shift_amnt => exe_literal_shift_amnt,
		exe_literal_data => exe_literal_data,
		exe_opb_is_literal => exe_opb_is_literal,
		exe_opb_sel => exe_opb_sel,
		exe_alu_operation => exe_alu_operation,
		exe_condition => exe_condition,
		exe_affect_sflags => exe_affect_sflags,
		exe_data_sel => exe_data_sel,
		exe_rdest_wren => exe_rdest_wren,
		exe_rdest_adr => exe_rdest_adr,
		exe_branch_en => exe_branch_en,
		exe_wb_sel => exe_wb_sel,
		exe_mem_ctrl => exe_mem_ctrl,
		exe_mem_burstcount => exe_mem_burstcount,

		decode_latch_enable => decode_latch_enable
	);
	
	e : entity work.execute(rtl) port map
	(
		clk => clk,
		n_reset => n_reset,

		exe_A_adr => exe_A_adr,
		exe_B_adr => exe_B_adr,
		exe_C_adr => exe_C_adr,
		exe_stage_valid => exe_stage_valid,
		exe_barrelshift_operand => exe_barrelshift_operand,
		exe_barrelshift_type => exe_barrelshift_type,
		exe_literal_shift_amnt => exe_literal_shift_amnt,
		exe_literal_data => exe_literal_data,
		exe_opb_is_literal => exe_opb_is_literal,
		exe_opb_sel => exe_opb_sel,
		exe_alu_operation => exe_alu_operation,
		exe_condition => exe_condition,
		exe_affect_sflags => exe_affect_sflags,
		exe_data_sel => exe_data_sel,
		exe_rdest_wren => exe_rdest_wren,
		exe_rdest_adr => exe_rdest_adr,
		exe_branch_en => exe_branch_en,
		exe_wb_sel => exe_wb_sel,
		exe_mem_ctrl => exe_mem_ctrl,
		exe_mem_burstcount => exe_mem_burstcount,
		
		exe_pc_plus_4 => exe_pc_plus_4,
		exe_pc_plus_8 => exe_pc_plus_8,
		
		rfile_A_data => rfile_A_data,
		rfile_B_data => rfile_B_data,
		rfile_C_data => rfile_C_data,

		fwd_wb2_enable => fwd_wb2_enable,
		fwd_wb2_address => fwd_wb2_address,
		fwd_wb2_data => fwd_wb2_data,
		fwd_wb1_enable => rfile_wr_enable,
		fwd_wb1_address => rfile_address,
		fwd_wb1_data => wb_exe_data,
		fwd_wb1_is_invalid => wb_wb_sel,
		fwd_mem_enable => fwd_mem_enable,
		fwd_mem_address => fwd_mem_address,
		fwd_mem_data => fwd_mem_data,
		fwd_mem_is_invalid => mem_wb_sel,

		mem_stage_valid => mem_stage_valid,
		mem_rdest_wren => mem_rdest_wren,
		mem_rdest_adr => mem_rdest_adr,
		mem_branch_en => mem_branch_en,
		mem_wb_sel => mem_wb_sel,
		mem_exe_data => mem_exe_data,
		mem_wrdata => mem_wrdata,
		mem_mem_ctrl => mem_mem_ctrl,
		mem_mem_burstcount => mem_mem_burstcount,

		low_flags => low_flags,
		exe_PC_wrdata => exe_PC_wrdata,
		exe_PC_wr => exe_PC_wr,

		exe_blocked_n => exe_blocked_n,
		exe_latch_enable => exe_latch_enable
	);

	m : entity work.memory(rtl) port map
	(

		clk => clk,
		reset_n => n_reset,
		
		mem_stage_valid => mem_stage_valid,
		mem_rdest_wren => mem_rdest_wren,
		mem_rdest_adr => mem_rdest_adr,
		mem_branch_en => mem_branch_en,
		mem_wb_sel => mem_wb_sel,
		mem_exe_data => mem_exe_data,
		mem_wrdata => mem_wrdata,
		mem_mem_ctrl => mem_mem_ctrl,
		mem_mem_burstcount => mem_mem_burstcount,
		
		wb_stage_valid => wb_stage_valid,
		wb_rdest_wren => wb_rdest_wren,
		wb_rdest_adr => wb_rdest_adr,
		wb_branch_en => wb_branch_en,
		wb_wb_sel => wb_wb_sel,
		wb_exe_data => wb_exe_data,
		wb_mem_ctrl => wb_mem_ctrl,

		fwd_mem_enable => fwd_mem_enable,
		fwd_mem_address => fwd_mem_address,
		fwd_mem_data => fwd_mem_data,

		avm_data_waitrequest => avm_data_waitrequest,
		avm_data_read => avm_data_read,
		avm_data_writedata => avm_data_writedata,
		avm_data_write => avm_data_write,
		avm_data_byteen => avm_data_byteen,
		avm_data_burstcount => avm_data_burstcount,
		avm_data_address => avm_data_address,

		mem_blocked_n => mem_blocked_n,
		mem_latch_enable => mem_latch_enable
	);
	
	w : entity work.writeback(rtl) port map
	(
		clk => clk,
		
		wb_stage_valid => wb_stage_valid,
		wb_rdest_wren => wb_rdest_wren,
		wb_rdest_adr => wb_rdest_adr,
		wb_branch_en => wb_branch_en,
		wb_wb_sel => wb_wb_sel,
		wb_exe_data => wb_exe_data,
		wb_mem_ctrl => wb_mem_ctrl,

		rfile_wr_enable => rfile_wr_enable,
		rfile_address => rfile_address,
		wb_data => wb_data,

		fwd_wb2_enable => fwd_wb2_enable,
		fwd_wb2_address => fwd_wb2_address,
		fwd_wb2_data => fwd_wb2_data,

		avm_data_readdatavalid => avm_data_readdatavalid,
		avm_data_readdata => avm_data_readdata,

		wb_pc_wr => wb_pc_wr,
		wb_blocked_n => wb_blocked_n
	);
	
	rf : entity work.register_file(synth) port map
	(
		clk => clk,
		aa => rfile_A_adr,
		ab => rfile_B_adr,
		ac => rfile_C_adr,
		aw => rfile_address,
		wren => rfile_wr_enable,
		wrdata => wb_data,
		a => rfile_A_data,
		b => rfile_B_data,
		c => rfile_C_data,
		rd_clken => decode_latch_enable
	);

	fiq <= inr_irq(0);
	irq <= '0' when inr_irq(31 downto 1) = (31 downto 1 => '0') else '1';
	

	fetch_stage_en <= fetch_latch_enable;
	fetch_latch_enable <= decode_latch_enable and decode_blocked_n;
	decode_latch_enable <= exe_latch_enable and exe_blocked_n;
	exe_latch_enable <= mem_latch_enable and mem_blocked_n;
	mem_latch_enable <= wb_blocked_n;

	pc_wrdata <= exe_pc_wrdata when exe_pc_wr = '1' else unsigned(wb_data);
   pc_wr <= exe_pc_wr or wb_pc_wr;
end architecture bench;
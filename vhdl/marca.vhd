--  This file is part of the marca processor.
--  Copyright (C) 2007 Wolfgang Puffitsch

--  This program is free software; you can redistribute it and/or modify it
--  under the terms of the GNU Library General Public License as published
--  by the Free Software Foundation; either version 2, or (at your option)
--  any later version.

--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Library General Public License for more details.

--  You should have received a copy of the GNU Library General Public
--  License along with this program; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

-------------------------------------------------------------------------------
-- MARCA top level architecture
-------------------------------------------------------------------------------
-- architecture of the processor itself
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

use work.marca_pkg.all;

architecture behaviour of marca is

component fetch
  port (
    clock   : in  std_logic;
    reset   : in  std_logic;

    hold    : in  std_logic;
    
    pcena   : in  std_logic;
    pc_in   : in  std_logic_vector(REG_WIDTH-1 downto 0);
    pc_out  : out std_logic_vector(REG_WIDTH-1 downto 0);

    src1    : out std_logic_vector(REG_COUNT_LOG-1 downto 0);
    src2    : out std_logic_vector(REG_COUNT_LOG-1 downto 0);
    dest    : out std_logic_vector(REG_COUNT_LOG-1 downto 0);
    instr   : out std_logic_vector(PDATA_WIDTH-1 downto 0));
end component;

signal fetch_pc    : std_logic_vector(REG_WIDTH-1 downto 0);
signal fetch_src1  : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal fetch_src2  : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal fetch_dest  : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal fetch_instr : std_logic_vector(PDATA_WIDTH-1 downto 0);

component decode
  port (
    clock     : in  std_logic;
    reset     : in  std_logic;
    
    hold      : in  std_logic;
    stall     : in  std_logic;
    
    pc_in     : in  std_logic_vector(REG_WIDTH-1 downto 0);
    pc_out    : out std_logic_vector(REG_WIDTH-1 downto 0);

    instr     : in  std_logic_vector(PDATA_WIDTH-1 downto 0);
    
    src1_in   : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    src1_out  : out std_logic_vector(REG_COUNT_LOG-1 downto 0);
    src2_in   : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    src2_out  : out std_logic_vector(REG_COUNT_LOG-1 downto 0);

    dest_in   : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    dest_out  : out std_logic_vector(REG_COUNT_LOG-1 downto 0);

    aop       : out ALU_OP;
    mop       : out MEM_OP;
    iop       : out INTR_OP;
    
    op1       : out std_logic_vector(REG_WIDTH-1 downto 0);
    op2       : out std_logic_vector(REG_WIDTH-1 downto 0);
    imm       : out std_logic_vector(REG_WIDTH-1 downto 0);

    unit      : out UNIT_SELECTOR;
    target    : out TARGET_SELECTOR;
    
    wr_ena    : in  std_logic;
    wr_dest   : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    wr_val    : in  std_logic_vector(REG_WIDTH-1 downto 0));
end component;

signal decode_pc     : std_logic_vector(REG_WIDTH-1 downto 0);
signal decode_op1    : std_logic_vector(REG_WIDTH-1 downto 0);
signal decode_op2    : std_logic_vector(REG_WIDTH-1 downto 0);
signal decode_imm    : std_logic_vector(REG_WIDTH-1 downto 0);
signal decode_src1   : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal decode_src2   : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal decode_dest   : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal decode_aop    : ALU_OP;
signal decode_mop    : MEM_OP;
signal decode_iop    : INTR_OP;
signal decode_unit   : UNIT_SELECTOR;
signal decode_target : TARGET_SELECTOR;
signal decode_instr  : std_logic_vector(PDATA_WIDTH-1 downto 0);

component execute is
  port (
    clock      : in  std_logic;
    reset      : in  std_logic;

    busy       : out std_logic;
    stall      : in  std_logic;
    
    pc_in      : in  std_logic_vector(REG_WIDTH-1 downto 0);
    pcchg      : out std_logic;
    pc_out     : out std_logic_vector(REG_WIDTH-1 downto 0);
    
    dest_in    : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    dest_out   : out std_logic_vector(REG_COUNT_LOG-1 downto 0);

    src1       : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    src2       : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);

    aop        : in  ALU_OP;
    mop        : in  MEM_OP;
    iop        : in  INTR_OP;
    
    op1        : in  std_logic_vector(REG_WIDTH-1 downto 0);
    op2        : in  std_logic_vector(REG_WIDTH-1 downto 0);
    imm        : in  std_logic_vector(REG_WIDTH-1 downto 0);
    
    unit       : in  UNIT_SELECTOR;
    target_in  : in  TARGET_SELECTOR;
    target_out : out TARGET_SELECTOR;

    result     : out std_logic_vector(REG_WIDTH-1 downto 0);

    fw_ena     : in  std_logic;
    fw_dest    : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    fw_val     : in  std_logic_vector(REG_WIDTH-1 downto 0);

    ext_in     : in  std_logic_vector(IN_BITS-1 downto 0);
    ext_out    : out std_logic_vector(OUT_BITS-1 downto 0));
end component;

signal exec_busy   : std_logic;
signal exec_pcchg  : std_logic;
signal exec_pc     : std_logic_vector(REG_WIDTH-1 downto 0);
signal exec_dest   : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal exec_target : TARGET_SELECTOR;
signal exec_result : std_logic_vector(REG_WIDTH-1 downto 0);

component writeback is  
  port (
    clock      : in  std_logic;
    reset      : in  std_logic;

    hold       : in std_logic;

    pc_in      : in  std_logic_vector(REG_WIDTH-1 downto 0);
    pcchg      : in  std_logic;
    pc_out     : out std_logic_vector(REG_WIDTH-1 downto 0);
    pcena      : out std_logic;
    
    dest_in    : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    dest_out   : out std_logic_vector(REG_COUNT_LOG-1 downto 0);

    target     : in  TARGET_SELECTOR;
    result     : in  std_logic_vector(REG_WIDTH-1 downto 0);

    ena        : out std_logic;
    val        : out std_logic_vector(REG_WIDTH-1 downto 0));
end component;

signal wb_pc    : std_logic_vector(REG_WIDTH-1 downto 0);
signal wb_pcena : std_logic;
signal wb_dest  : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal wb_ena   : std_logic;
signal wb_val   : std_logic_vector(REG_WIDTH-1 downto 0);

signal decode_stall : std_logic;

signal reset      : std_logic;
signal meta_reset : std_logic;

begin  -- behaviour

  -- in the decode and execution stage we need to stall a little earlier
  decode_stall <= exec_pcchg or wb_pcena;
  
  fetch_stage : fetch
    port map (
      clock    => clock,
      reset    => reset,
      hold     => exec_busy,
      pcena    => wb_pcena,
      pc_in    => wb_pc,
      pc_out   => fetch_pc,
      src1     => fetch_src1,
      src2     => fetch_src2,
      dest     => fetch_dest,
      instr    => fetch_instr);

  decode_stage : decode
    port map (
      clock      => clock,
      reset      => reset,
      hold       => exec_busy,
      stall      => decode_stall,
      pc_in      => fetch_pc,
      pc_out     => decode_pc,
      instr      => fetch_instr,
      src1_in    => fetch_src1,
      src1_out   => decode_src1,
      src2_in    => fetch_src2,
      src2_out   => decode_src2,
      dest_in    => fetch_dest,
      dest_out   => decode_dest,
      aop        => decode_aop,
      mop        => decode_mop,
      iop        => decode_iop,
      op1        => decode_op1,
      op2        => decode_op2,
      imm        => decode_imm,
      unit       => decode_unit,   
      target     => decode_target,
      wr_ena     => wb_ena,
      wr_dest    => wb_dest,
      wr_val     => wb_val);

  execution_stage : execute
    port map (
      clock      => clock,
      reset      => reset,
      busy       => exec_busy,
      stall      => exec_pcchg,
      pc_in      => decode_pc,
      pcchg      => exec_pcchg,
      pc_out     => exec_pc,
      dest_in    => decode_dest,
      dest_out   => exec_dest,
      src1       => decode_src1,
      src2       => decode_src2,
      aop        => decode_aop,
      mop        => decode_mop,
      iop        => decode_iop,
      op1        => decode_op1,
      op2        => decode_op2,
      imm        => decode_imm,
      unit       => decode_unit,
      target_in  => decode_target,
      target_out => exec_target,
      result     => exec_result,
      fw_ena     => wb_ena,
      fw_dest    => wb_dest,
      fw_val     => wb_val,
      ext_in     => ext_in,
      ext_out    => ext_out);

  writeback_stage : writeback
    port map (
      clock       => clock,
      reset       => reset,
      hold        => exec_busy,      
      pc_in       => exec_pc,
      pcchg       => exec_pcchg,
      pc_out      => wb_pc,
      pcena       => wb_pcena,
      dest_in     => exec_dest,
      dest_out    => wb_dest,
      target      => exec_target,
      result      => exec_result,
      ena         => wb_ena,
      val         => wb_val);
  
  synchronize: process (clock, ext_reset, meta_reset)
  begin
    if clock'event and clock = '1' then
      meta_reset <= ext_reset;
      reset <= meta_reset;
    end if;
  end process synchronize;
  
end behaviour;

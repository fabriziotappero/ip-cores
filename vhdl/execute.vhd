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
-- MARCA execution stage
-------------------------------------------------------------------------------
-- architecture of the execution pipeline stage
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.marca_pkg.all;

architecture behaviour of execute is

component alu is
  port (
    clock   : in  std_logic;
    reset   : in  std_logic;
    busy    : out std_logic;
    op      : in  ALU_OP;
    a       : in  std_logic_vector(REG_WIDTH-1 downto 0);
    b       : in  std_logic_vector(REG_WIDTH-1 downto 0);
    i       : in  std_logic_vector(REG_WIDTH-1 downto 0);
    pc      : in  std_logic_vector(REG_WIDTH-1 downto 0);
    intr    : in  std_logic;
    exc     : out std_logic;
    iena    : out std_logic;
    pcchg   : out std_logic;
    result  : out std_logic_vector(REG_WIDTH-1 downto 0));
end component;

component mem is
  port (
    clock   : in  std_logic;
    reset   : in  std_logic;
    op      : in  MEM_OP;
    address : in  std_logic_vector(REG_WIDTH-1 downto 0);
    data    : in  std_logic_vector(REG_WIDTH-1 downto 0);
    exc     : out std_logic;
    busy    : out std_logic;
    result  : out std_logic_vector(REG_WIDTH-1 downto 0);
    intrs   : out std_logic_vector(VEC_COUNT-1 downto 3);
    ext_in  : in  std_logic_vector(IN_BITS-1 downto 0);
    ext_out : out std_logic_vector(OUT_BITS-1 downto 0));
end component;

component intr is
  port (
    clock   : in  std_logic;
    reset   : in  std_logic;
    enable  : in  std_logic;
    trigger : in  std_logic_vector(VEC_COUNT-1 downto 1);
    op      : in  INTR_OP;
    a       : in  std_logic_vector(REG_WIDTH-1 downto 0);
    i       : in  std_logic_vector(REG_WIDTH-1 downto 0);
    pc      : in  std_logic_vector(REG_WIDTH-1 downto 0);
    exc     : out std_logic;
    pcchg   : out std_logic;
    result  : out std_logic_vector(REG_WIDTH-1 downto 0));
end component;

signal any_busy : std_logic;

signal alu_iena   : std_logic;
signal alu_exc    : std_logic;
signal alu_busy   : std_logic;
signal alu_pcchg  : std_logic;
signal alu_result : std_logic_vector(REG_WIDTH-1 downto 0);

signal mem_exc    : std_logic;
signal mem_busy   : std_logic;
signal mem_result : std_logic_vector(REG_WIDTH-1 downto 0);
signal mem_intrs  : std_logic_vector(VEC_COUNT-1 downto 3);

signal intr_enable : std_logic;
signal intr_exc    : std_logic;
signal intr_pcchg  : std_logic;
signal intr_result : std_logic_vector(REG_WIDTH-1 downto 0);

signal pc_reg   : std_logic_vector(REG_WIDTH-1 downto 0);

signal src1_reg : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal src2_reg : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal dest_reg : std_logic_vector(REG_COUNT_LOG-1 downto 0);

signal op1_reg  : std_logic_vector(REG_WIDTH-1 downto 0);
signal op2_reg  : std_logic_vector(REG_WIDTH-1 downto 0);
signal imm_reg  : std_logic_vector(REG_WIDTH-1 downto 0);

signal op1_fwed : std_logic_vector(REG_WIDTH-1 downto 0);
signal op2_fwed : std_logic_vector(REG_WIDTH-1 downto 0);

signal aop_reg  : ALU_OP;
signal mop_reg  : MEM_OP;
signal iop_reg  : INTR_OP;

signal unit_reg   : UNIT_SELECTOR;
signal target_reg : TARGET_SELECTOR;

signal stall_cnt      : std_logic_vector(1 downto 0);  -- prohibiting                                                        
signal next_stall_cnt : std_logic_vector(1 downto 0);  -- interrupts during reti

begin  -- behaviour

  -- interrupts do not work while jumping
  intr_enable <= alu_iena and zero(stall_cnt) and not any_busy;
  
  alu_unit : alu
    port map (
      clock => clock,
      reset => reset,
      op => aop_reg,
      a => op1_fwed,
      b => op2_fwed,
      i => imm_reg,
      pc => pc_reg,
      intr => intr_exc,
      exc => alu_exc,
      busy => alu_busy,
      iena => alu_iena,
      pcchg => alu_pcchg,
      result => alu_result);

  mem_unit : mem
    port map (
      clock   => clock,
      reset   => reset,
      op      => mop_reg,
      address => op2_fwed,
      data    => op1_fwed,
      exc     => mem_exc,
      busy    => mem_busy,
      result  => mem_result,
      intrs   => mem_intrs,
      ext_in  => ext_in,
      ext_out => ext_out);

  intr_unit : intr
    port map (
      clock            => clock,
      reset            => reset,
      enable           => intr_enable,
      trigger(EXC_ALU) => alu_exc,
      trigger(EXC_MEM) => mem_exc,
      trigger(VEC_COUNT-1 downto 3) => mem_intrs,
      op               => iop_reg,
      a                => op1_fwed,
      i                => imm_reg,
      pc               => pc_reg,
      exc              => intr_exc,
      pcchg            => intr_pcchg,
      result           => intr_result);
  
  syn_proc: process (clock, reset)
  begin  -- process syn_proc
    if reset = RESET_ACTIVE then                 -- asynchronous reset (active low)
      stall_cnt <= (others => '0');
      pc_reg <= (others => '0');
      src1_reg <= (others => '0');
      src2_reg <= (others => '0');
      dest_reg <= (others => '0');
      aop_reg <= ALU_NOP;
      mop_reg <= MEM_NOP;
      iop_reg <= INTR_NOP;
      op1_reg <= (others => '0');
      op2_reg <= (others => '0');
      imm_reg <= (others => '0');
      unit_reg <= UNIT_ALU;
      target_reg <= TARGET_NONE;
    elsif clock'event and clock = '1' then  -- rising clock edge
      if any_busy = '0' then
        stall_cnt <= next_stall_cnt;
        if stall = '1' then
          pc_reg <= (others => '0');
          src1_reg <= (others => '0');
          src2_reg <= (others => '0');
          dest_reg <= (others => '0');
          aop_reg <= ALU_NOP;
          mop_reg <= MEM_NOP;
          iop_reg <= INTR_NOP;
          op1_reg <= (others => '0');
          op2_reg <= (others => '0');
          imm_reg <= (others => '0');
          unit_reg <= UNIT_ALU;
          target_reg <= TARGET_NONE;
        else
          pc_reg <= pc_in;
          dest_reg <= dest_in;
          src1_reg <= src1;
          src2_reg <= src2;
          aop_reg <= aop;
          mop_reg <= mop;
          iop_reg <= iop;
          op1_reg <= op1;
          op2_reg <= op2;
          imm_reg <= imm;      
          unit_reg <= unit;
          target_reg <= target_in;   
        end if;
      end if;
    end if;
  end process syn_proc;

  stalling: process (stall, stall_cnt)
  begin  -- process hold_pc
    
    next_stall_cnt <= std_logic_vector(unsigned(stall_cnt) - 1);  
    if zero(stall_cnt) = '1' then
      next_stall_cnt <= "00";
    end if;
    if stall = '1' then
      next_stall_cnt <= "11";
    end if;
    
  end process stalling;
  
  business: process (any_busy, alu_busy, mem_busy)
  begin  -- process business
    any_busy <= alu_busy or mem_busy;
    busy <= any_busy;
  end process business;
  
  feedthrough: process (pc_reg, dest_reg, unit_reg, target_reg, op2_fwed, intr_exc)
  begin  -- process feedthrough
    if unit_reg /= UNIT_CALL then
      pc_out <= pc_reg;
    else
      pc_out <= op2_fwed;
    end if;
    dest_out <= dest_reg;
    if intr_exc = '1' then
      target_out <= TARGET_PC;
    else
      target_out <= target_reg;
    end if;
  end process feedthrough;

  forward: process (src1_reg, src2_reg, op1_reg, op2_reg, fw_ena, fw_dest, fw_val)
  begin  -- process forward
    op1_fwed <= op1_reg;
    op2_fwed <= op2_reg;
    if fw_ena = '1' then
      if src1_reg = fw_dest then
        op1_fwed <= fw_val;
      end if;
      if src2_reg = fw_dest then
        op2_fwed <= fw_val;        
      end if;
    end if;
  end process forward;
  
  select_result: process(unit_reg, alu_result, mem_result, intr_result, pc_reg,
                         alu_pcchg, intr_pcchg,
                         intr_exc)
  begin  -- process select_result
    case unit_reg is
      when UNIT_ALU => result <= alu_result;
      when UNIT_MEM => result <= mem_result;
      when UNIT_INTR => result <= intr_result;
      when UNIT_CALL => result <= std_logic_vector(unsigned(pc_reg) + 1);
      when others => null;
    end case;
    if intr_exc = '1' then
      result <= intr_result;
    end if;
    pcchg <= alu_pcchg or intr_pcchg;    
  end process select_result;
    
end behaviour;

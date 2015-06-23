-- File: mem_stage.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Memory Access stage
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

use WORK.RISE_PACK.all;
use work.RISE_PACK_SPECIFIC.all;

entity mem_stage is
  
  port (
    clk   : in std_logic;
    reset : in std_logic;

    ex_mem_register : in  EX_MEM_REGISTER_T;
    mem_wb_register : out MEM_WB_REGISTER_T;

    dmem_addr      : out MEM_ADDR_T;
    dmem_data_in   : in  MEM_DATA_T;
    dmem_data_out  : out MEM_DATA_T;
    dmem_wr_enable : out std_logic;

    stall_out : out std_logic;
    clear_in  : in  std_logic;
    clear_out : out std_logic);


end mem_stage;

architecture mem_stage_rtl of mem_stage is

  signal mem_wb_register_int  : MEM_WB_REGISTER_T;
  signal mem_wb_register_next : MEM_WB_REGISTER_T;
  
begin  -- mem_stage_rtl

  mem_wb_register.aluop1    <= mem_wb_register_int.aluop1;
  mem_wb_register.aluop2    <= mem_wb_register_int.aluop2;
  mem_wb_register.reg       <= mem_wb_register_int.reg;
  mem_wb_register.mem_reg   <= dmem_data_in;
  mem_wb_register.dreg_addr <= mem_wb_register_int.dreg_addr;
  mem_wb_register.lr        <= mem_wb_register_int.lr;
  mem_wb_register.sr        <= mem_wb_register_int.sr;

  clear_out <= '0';  -- clear_out output is unused at the moment.
  stall_out <= '0';                     -- development (temporarily)
  process (clk, reset)
  begin  -- process
    if reset = '0' then                 -- asynchronous reset (active low)
      mem_wb_register_int.aluop1    <= (others => '0');
      mem_wb_register_int.aluop2    <= (others => '0');
      mem_wb_register_int.reg       <= (others => '0');
      mem_wb_register_int.dreg_addr <= (others => '0');
      mem_wb_register_int.lr        <= (others => '0');
      mem_wb_register_int.sr        <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      mem_wb_register_int <= mem_wb_register_next;
    end if;
  end process;

  process( reset, ex_mem_register, dmem_data_in )
  begin
    dmem_addr      <= (others => 'X');
    dmem_data_out  <= (others => 'X');
    dmem_wr_enable <= '0';

    if reset = '0' then
      mem_wb_register_next.aluop1    <= (others => '0');
      mem_wb_register_next.aluop2    <= (others => '0');
      mem_wb_register_next.reg       <= (others => '-');
      mem_wb_register_next.mem_reg   <= (others => '-');
      mem_wb_register_next.dreg_addr <= (others => '-');
      mem_wb_register_next.lr        <= (others => '-');
      mem_wb_register_next.sr        <= (others => '-');
    else
      -- check if the instruction accesses the memory. if yes then
      -- either load or store data from the memory.
      assert ex_mem_register.aluop1(ALUOP1_LD_MEM_BIT) = '0' or ex_mem_register.aluop1(ALUOP1_ST_MEM_BIT) = '0';

      if ex_mem_register.aluop1(ALUOP1_LD_MEM_BIT) = '1' then
        dmem_addr <= ex_mem_register.alu;
      end if;

      if ex_mem_register.aluop1(ALUOP1_ST_MEM_BIT) = '1' then
        dmem_addr      <= ex_mem_register.alu;
        dmem_data_out  <= ex_mem_register.reg;
        dmem_wr_enable <= '1';
      end if;

      -- other values are pass through
      mem_wb_register_next.aluop1    <= ex_mem_register.aluop1;
      mem_wb_register_next.aluop2    <= ex_mem_register.aluop2;
      mem_wb_register_next.reg       <= ex_mem_register.alu;
      mem_wb_register_next.dreg_addr <= ex_mem_register.dreg_addr;
      mem_wb_register_next.lr        <= ex_mem_register.lr;
      mem_wb_register_next.sr        <= ex_mem_register.sr;
    end if;
  end process;
  
end mem_stage_rtl;

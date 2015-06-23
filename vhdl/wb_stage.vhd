-- File: wb_stage.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Instruction decode stage
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

use WORK.RISE_PACK.all;
use work.RISE_PACK_SPECIFIC.all;

entity wb_stage is
  
  port (
    clk   : in std_logic;
    reset : in std_logic;

    mem_wb_register : in MEM_WB_REGISTER_T;

    dreg_addr   : out REGISTER_ADDR_T;
    dreg        : out REGISTER_T;
    dreg_enable : out std_logic;

    lr        : out PC_REGISTER_T;
    lr_enable : out std_logic;

    sr        : out SR_REGISTER_T;
    sr_enable : out std_logic;

    clear_out : out std_logic;

    clear_reg_lock0 : out std_logic;
    lock_reg_addr0  : out REGISTER_ADDR_T;
    clear_reg_lock1 : out std_logic;
    lock_reg_addr1  : out REGISTER_ADDR_T);


end wb_stage;

architecture wb_stage_rtl of wb_stage is

begin  -- wb_stage_rtl

  clear_out <= '0';  -- clear_out output is unused at the moment.

  process (reset, mem_wb_register)
  begin
    if reset = '0' then
      clear_reg_lock0 <= '0';
      lock_reg_addr0  <= (others => 'X');
      clear_reg_lock1 <= '0';
      lock_reg_addr1  <= (others => 'X');

      dreg_enable <= '0';
      dreg_addr <= (others => 'X');
      dreg      <= (others => 'X');
      lr_enable   <= '0';
      lr        <= (others => 'X');
      sr_enable   <= '0';
      sr        <= (others => 'X');
    else

      -- write back of register value. --
      dreg_addr <= mem_wb_register.dreg_addr;
      if mem_wb_register.aluop1(ALUOP1_WB_REG_BIT) = '1' then
        if mem_wb_register.aluop1(ALUOP1_LD_MEM_BIT) = '1' then
          dreg <= mem_wb_register.mem_reg;
        else
          dreg <= mem_wb_register.reg;
        end if;
        dreg_enable     <= '1';
        clear_reg_lock0 <= '1';
        lock_reg_addr0  <= mem_wb_register.dreg_addr;
      else
        dreg_enable     <= '0';
        dreg            <= (others => 'X');
        clear_reg_lock0 <= '0';
        lock_reg_addr0  <= (others => 'X');
      end if;

      -- we have only one lock register.
      assert mem_wb_register.aluop2(ALUOP2_SR_BIT) = '0' or mem_wb_register.aluop2(ALUOP2_LR_BIT) = '0';

      clear_reg_lock1 <= '0';
      lock_reg_addr1  <= (others => 'X');
      -- write back of LR --
      if mem_wb_register.aluop2(ALUOP2_LR_BIT) = '1' then
        lr              <= mem_wb_register.lr;
        lr_enable       <= '1';
        clear_reg_lock1 <= '1';
        lock_reg_addr1  <= LR_REGISTER_ADDR;
      else
        lr              <= ( others => 'X' );
        lr_enable       <= '0';
      end if;
      
      -- write back of SR --
      if mem_wb_register.aluop2(ALUOP2_SR_BIT) = '1' then
        -- calculate SR value
        sr              <= mem_wb_register.sr;
        if mem_wb_register.aluop1(ALUOP1_LD_MEM_BIT) = '1' then
           if mem_wb_register.mem_reg = CONV_STD_LOGIC_VECTOR(0, REGISTER_WIDTH) then
             sr( SR_REGISTER_ZERO ) <= '1';
           end if;
           if mem_wb_register.mem_reg( REGISTER_WIDTH - 1 ) = '1' then
             sr( SR_REGISTER_NEGATIVE ) <= '1';
           end if;            
        end if;
        sr_enable       <= '1';
        clear_reg_lock1 <= '1';
        lock_reg_addr1  <= SR_REGISTER_ADDR;
      else
        sr              <= ( others => 'X' );
        sr_enable       <= '0';
      end if;
      
      
    end if;
  end process;
end wb_stage_rtl;

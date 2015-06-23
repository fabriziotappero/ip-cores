
-- File: if_stage.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Instruction fetch stage
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use WORK.RISE_PACK.all;
use WORK.RISE_PACK_SPECIFIC.all;

entity if_stage is
  
  port (
    clk   : in std_logic;
    reset : in std_logic;

    if_id_register : out IF_ID_REGISTER_T;

    branch        : in std_logic;
    branch_target : in PC_REGISTER_T;
    clear_in      : in std_logic;
    stall_in      : in std_logic;

    pc      : in  PC_REGISTER_T;
    pc_next : out PC_REGISTER_T;

    imem_addr : out MEM_ADDR_T;
    imem_data : in  MEM_DATA_T);

end if_stage;

-- This is a simple hardcoded IF unit for the  RISE processor. It does not
-- use the memory and contains a hardcoded program.
architecture if_state_behavioral of if_stage is

  signal if_id_register_int  : IF_ID_REGISTER_T := (others => (others => '0'));
  signal if_id_register_next : IF_ID_REGISTER_T := (others => (others => '0'));
  signal cur_pc              : PC_REGISTER_T;

  component pgrom
    port (
      clk  : in  std_logic;
      addr : in  std_logic_vector(15 downto 0);
      data : out std_logic_vector(15 downto 0)
      );
  end component;
  
begin
  if_id_register <= if_id_register_int;
  cur_pc         <= pc when branch = '0' else branch_target;

  process (clk, reset, clear_in)
  begin
    if reset = '0' then
      if_id_register_int.pc <= PC_RESET_VECTOR;
      if_id_register_int.ir <= (others => '0');
    elsif clk'event and clk = '1' then
      if stall_in = '0' then
        if_id_register_int <= if_id_register_next;
      end if;
    end if;
  end process;

  process (reset, branch, branch_target, cur_pc, stall_in)
  begin
    if reset = '0' then
      if_id_register_next.pc <= PC_RESET_VECTOR;
      pc_next                <= PC_RESET_VECTOR;
    else
      if_id_register_next.pc <= cur_pc;

      if stall_in = '0' then
        pc_next <= std_logic_vector(unsigned(cur_pc) + 2);
      else
        pc_next <= cur_pc;
      end if;
    end if;
  end process;

  pgrom_ut : pgrom port map(
    clk  => clk,
    addr => cur_pc,
    data => if_id_register_next.ir
    );

end if_state_behavioral;



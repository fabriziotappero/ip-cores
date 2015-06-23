-------------------------------------------------------------------------------
-- Title      :  Correlator
-- Project    :  Bluetooth baseband core
-------------------------------------------------------------------------------
-- File        : correlator.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     : 2000/12/18
-- Last update : 2000/12/18
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: Leonardo/WindowsNT
-- Target      : 
-- Dependency  : ieee.std_logic_1164
-------------------------------------------------------------------------------
-- Description: correlator core
-------------------------------------------------------------------------------
-- Copyright (c) 2000 Jamil Khatib
-- 
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it after contacting the author
-- You can check the draft license at
-- http://www.opencores.org/OIPC/license.shtml

-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   1
-- Version         :   0.1
-- Date            :   18 Nov 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- Known bugs      :   
-- To Optimze      :   
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity correlator_core_ent is
  generic (
    REG_WIDTH :     integer := 72);     -- Register width
  port (
    clk       : in  std_logic;          -- system clock
    rst       : in  std_logic;          -- system reset
    Din       : in  std_logic;          -- Input Data
    Dout      : out std_logic;          -- Output Data
    enable    : in  std_logic;          -- correlator enable
    pattern   : in  std_logic_vector(REG_WIDTH-1 downto 0);  -- Match pattern
    Threshold : out std_logic_vector(REG_WIDTH-1 downto 0));  -- Threshold

end correlator_core_ent;


architecture correlator_core_beh of correlator_core_ent is
  signal data_reg    : std_logic_vector(REG_WIDTH-1 downto 0);  -- data register
  signal pattern_reg : std_logic_vector(REG_WIDTH-1 downto 0);  -- pattern register
begin  -- correlator_core_beh

  -- purpose: Correlator core
  -- type   : sequential
  -- inputs : clk, rst
  -- outputs: 
  correlate_proc : process (clk, rst)



  begin  -- process correlate_proc
    if rst = '0' then                   -- asynchronous reset (active low)

      data_reg    <= (others => '0');
      pattern_reg <= (others => '0');
      Dout        <= '0';
      Threshold   <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      if enable = '1' then

        pattern_reg <= pattern;

      else

        data_reg  <= Din & data_reg(REG_WIDTH-1 downto 1);
        Threshold <= data_reg xor pattern_reg;

      end if;

      Dout <= data_reg(0);

    end if;
  end process correlate_proc;

end correlator_core_beh;

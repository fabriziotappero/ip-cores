-------------------------------------------------------------------------------
-- Title      :  Correlator
-- Project    :  Bluetooth baseband core
-------------------------------------------------------------------------------
-- File        : corrtop.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     : 2000/12/24
-- Last update : 2000/12/24
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: Leonardo/WindowsNT
-- Target      : 
-- Dependency  : ieee.std_logic_1164, ieee.std_logic_signed
-------------------------------------------------------------------------------
-- Description: correlator top
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
-- Date            :   24 Dec 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- Known bugs      :   
-- To Optimze      :   Threshold Detection must be optimized
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity corrtop_ent is
  generic (
    THRESHOLD_LIMIT :     integer := 64;
    REG_WIDTH       :     integer := 72);  -- Register width
  port (
    rst             : in  std_logic;    -- system reset
    clk             : in  std_logic;    -- system clock
    enable          : in  std_logic;    -- enable
    din             : in  std_logic;    -- Data in bit
    dout            : out std_logic;    -- Data out
    StartOfFrame    : out std_logic;    -- Start Of Frame
    ThresholdLimit  : in  integer range 0 to REG_WIDTH-1;  -- Threshold limit
    AccessCode      : in  std_logic_vector(REG_WIDTH-1 downto 0));  -- Access code

end corrtop_ent;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture corrtop_beh of corrtop_ent is
  component correlator_core_ent
    generic (
      REG_WIDTH :     integer);
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      Din       : in  std_logic;
      Dout      : out std_logic;
      enable    : in  std_logic;
      pattern   : in  std_logic_vector(REG_WIDTH-1 downto 0);
      Threshold : out std_logic_vector(REG_WIDTH-1 downto 0));
  end component;

-------------------------------------------------------------------------------

  signal threshold : std_logic_vector(REG_WIDTH-1 downto 0);  -- threshold signal
  signal Dout_reg  : std_logic;         -- Output register

begin  -- corrtop_beh
-------------------------------------------------------------------------------
  correlator_core : correlator_core_ent
    generic map (
      REG_WIDTH => REG_WIDTH)
    port map (
      clk       => clk,
      rst       => rst,
      Din       => Din,
      Dout      => Dout_reg,
      enable    => enable,
      pattern   => AccessCode,
      Threshold => Threshold);
-------------------------------------------------------------------------------
  -- purpose: threshold detection
  -- type   : sequential
  -- inputs : clk, rst
  -- outputs: 
  process (clk, rst)

    variable count_ones : integer range 0 to REG_WIDTH;  ---1;  -- Ones counter

  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)

      StartOfFrame <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      count_ones := 0;

      for i in 0 to REG_WIDTH-1 loop
        if Threshold(i) = '1' then
          count_ones := count_ones + 1;
        end if;
        --  count_ones := count_ones + slv_2_int(threshold(i));
      end loop;  -- i

      if count_ones > ThresholdLimit then
        StartOfFrame <= '1';
      else
        StartOfFrame <= '0';
      end if;

    end if;
  end process;
-------------------------------------------------------------------------------
  -- purpose: Register output data
  -- type   : sequential
  -- inputs : clk, rst
  -- outputs: 
  register_out : process (clk, rst)
  begin  -- process register_out
    if rst = '0' then                   -- asynchronous reset (active low)
      Dout <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      Dout <= Dout_reg;
    end if;
  end process register_out;
-------------------------------------------------------------------------------
end corrtop_beh;

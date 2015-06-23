-------------------------------------------------------------------------------
-- Title      : Testbench for design "lcd16x2_ctrl"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : lcd16x2_ctrl_tb.vhd
-- Author     :   <stachelsau@T420>
-- Company    : 
-- Created    : 2012-07-28
-- Last update: 2012-07-29
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-07-28  1.0      stachelsau	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity lcd16x2_ctrl_tb is

end entity lcd16x2_ctrl_tb;

-------------------------------------------------------------------------------

architecture behavior of lcd16x2_ctrl_tb is

  -- component generics
  constant CLK_PERIOD_NS : positive := 20;

  -- component ports
  signal clk          : std_logic := '1';
  signal rst          : std_logic;
  signal lcd_e        : std_logic;
  signal lcd_rs       : std_logic;
  signal lcd_rw       : std_logic;
  signal lcd_db       : std_logic_vector(3 downto 0);
  signal line1_buffer : std_logic_vector(127 downto 0);
  signal line2_buffer : std_logic_vector(127 downto 0);

begin  -- architecture behavior

  -- component instantiation
  DUT: entity work.lcd16x2_ctrl
    generic map (
      CLK_PERIOD_NS => CLK_PERIOD_NS)
    port map (
      clk          => clk,
      rst          => rst,
      lcd_e        => lcd_e,
      lcd_rs       => lcd_rs,
      lcd_rw       => lcd_rw,
      lcd_db       => lcd_db,
      line1_buffer => line1_buffer,
      line2_buffer => line2_buffer);

  -- clock generation
  Clk <= not Clk after 10 ns;
  rst <= '0';
  line1_buffer <= (others => '1');
  line2_buffer <= (others => '0');

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    
    wait until Clk = '1';
  end process WaveGen_Proc;

  

end architecture behavior;

-------------------------------------------------------------------------------

configuration lcd16x2_ctrl_tb_behavior_cfg of lcd16x2_ctrl_tb is
  for behavior
  end for;
end lcd16x2_ctrl_tb_behavior_cfg;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Title      : Synthesizable demo for design "lcd16x2_ctrl"
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
-- Description: This demo writes writes a "hello world" to the display and
-- interchanges both lines periodically.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-07-28  1.0      stachelsau      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity lcd16x2_ctrl_demo is
  port (
    clk    : in  std_logic;
    lcd_e  : out std_logic;
    lcd_rs : out std_logic;
    lcd_rw : out std_logic;
    lcd_db : out std_logic_vector(7 downto 4));

end entity lcd16x2_ctrl_demo;

-------------------------------------------------------------------------------

architecture behavior of lcd16x2_ctrl_demo is

  -- 
  signal timer : natural range 0 to 100000000 := 0;
  signal switch_lines : std_logic := '0';
  signal line1 : std_logic_vector(127 downto 0);
  signal line2 : std_logic_vector(127 downto 0);
  

  -- component generics
  constant CLK_PERIOD_NS : positive := 10;  -- 100 Mhz

  -- component ports
  signal rst          : std_logic;
  signal line1_buffer : std_logic_vector(127 downto 0);
  signal line2_buffer : std_logic_vector(127 downto 0);

begin  -- architecture behavior

  -- component instantiation
  DUT : entity work.lcd16x2_ctrl
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

  rst <= '0';

  -- see the display's datasheet for the character map
  line1(127 downto 120) <= X"20"; 
  line1(119 downto 112) <= X"20";
  line1(111 downto 104) <= X"48";  -- H
  line1(103 downto 96)  <= X"65";  -- e
  line1(95 downto 88)   <= X"6c";  -- l
  line1(87 downto 80)   <= X"6c";  -- l
  line1(79 downto 72)   <= X"6f";  -- o
  line1(71 downto 64)   <= X"20";
  line1(63 downto 56)   <= X"57";  -- W
  line1(55 downto 48)   <= X"6f";  -- o
  line1(47 downto 40)   <= X"72";  -- r
  line1(39 downto 32)   <= X"6c";  -- l
  line1(31 downto 24)   <= X"64";  -- d
  line1(23 downto 16)   <= X"21";  -- !
  line1(15 downto 8)    <= X"20";
  line1(7 downto 0)     <= X"20";

  line2(127 downto 120) <= X"30";
  line2(119 downto 112) <= X"31";
  line2(111 downto 104) <= X"32";
  line2(103 downto 96)  <= X"33";
  line2(95 downto 88)   <= X"34";
  line2(87 downto 80)   <= X"35";
  line2(79 downto 72)   <= X"36";
  line2(71 downto 64)   <= X"37";
  line2(63 downto 56)   <= X"38";
  line2(55 downto 48)   <= X"39";
  line2(47 downto 40)   <= X"3a";
  line2(39 downto 32)   <= X"3b";
  line2(31 downto 24)   <= X"3c";
  line2(23 downto 16)   <= X"3d";
  line2(15 downto 8)    <= X"3e";
  line2(7 downto 0)     <= X"3f";

  line1_buffer <= line2 when switch_lines = '1' else line1;
  line2_buffer <= line1 when switch_lines = '1' else line2;

  -- switch lines every second
  process(clk)
  begin
    if rising_edge(clk) then
      if timer = 0 then
        timer <= 100000000;
        switch_lines <= not switch_lines;
      else
        timer <= timer - 1;
      end if;
    end if;
      
  end process;
end architecture behavior;



-------------------------------------------------------------------------------
-- Title      : Testbench for design "cdc_fifo_tester"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_cdc_fifo_tester.vhd
-- Author     : 
-- Created    : 19.12.2006
-- Last update: 19.12.2006
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 19.12.2006  1.0      AK	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity tb_cdc_fifo_tester is

end tb_cdc_fifo_tester;

-------------------------------------------------------------------------------

architecture struct of tb_cdc_fifo_tester is

  component cdc_fifo_tester
    generic (
      depth_log2_g : integer;
      dataw_g      : integer);
    port (
      rd_clk, wr_clk      : in  std_logic;
      rst_n               : in  std_logic;
      pass_out, error_out : out std_logic;
      pass_count_out      : out std_logic_vector(31 downto 0));
  end component;

  -- component generics
  constant depth_log2_g : integer := 3;
  constant dataw_g      : integer := 30;

  -- component ports
  signal Clk1, Clk2      : std_logic;
  signal rst_n               : std_logic;
  signal pass_out, error_out : std_logic;
  signal pass_count_out      : std_logic_vector(31 downto 0);

  -- clock and reset
  constant Period1 : time := 100 ns;
  constant Period2 : time := 10 ns;

begin  -- struct

  assertion: process (Clk1, rst_n)
  begin  -- process assertion
    if rst_n = '0' then                 -- asynchronous reset (active low)
      
    elsif Clk1'event and Clk1 = '1' then  -- rising clock edge
      assert error_out = '0' report "Error!" severity error;
    end if;
  end process assertion;
  
  -- component instantiation
  DUT: cdc_fifo_tester
    generic map (
      depth_log2_g => depth_log2_g,
      dataw_g      => dataw_g)
    port map (
      rd_clk         => Clk1,
      wr_clk         => Clk2,
      rst_n          => rst_n,
      pass_out       => pass_out,
      error_out      => error_out,
      pass_count_out => pass_count_out);

  -- clock generation
  -- PROC  
  CLOCK1: process -- generate clock signal for design
    variable clktmp: std_logic := '0';
  begin
    wait for PERIOD1/2;
    clktmp := not clktmp;
    Clk1 <= clktmp; 
  end process CLOCK1;

  -- clock generation
  -- PROC  
  CLOCK2: process -- generate clock signal for design
    variable clktmp: std_logic := '0';
  begin
    wait for PERIOD2/2;
    clktmp := not clktmp;
    Clk2 <= clktmp; 
  end process CLOCK2;
  
  -- PROC
  RESET: process
  begin   
    Rst_n <= '0';        -- Reset the testsystem
    wait for 6*PERIOD1; -- Wait 
    Rst_n <= '1';        -- de-assert reset
    wait;
  end process RESET;

end struct;

-------------------------------------------------------------------------------

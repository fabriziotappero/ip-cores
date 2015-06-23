-------------------------------------------------------------------------------
-- Title      : Synchronizes two clock domains to a single clock FIFO
-- Project    : 
-------------------------------------------------------------------------------
-- File       : synch_fifo_pulse.vhd
-- Author     : kulmala3
-- Created    : 01.07.2005
-- Last update: 01.07.2005
-- Description: Generates a narrower pulse from a broader one, to read only one
-- data from a faster FIFO.
-- Should work at least when clk_fast is at least 2x clk_slow
-- tested on FPGA with clk_slow 50 and clk_fast 200 MHz
-- ASYNCHRONOUS INPUT/OUTPUT SIGNALS!
-- clk_slow: ____----____----____----
-- clk_fast: -_-_-_-_-_-_-_-_-_-_-_-_
-- re_in:    __---------------------
-- re_out:   ____--________--______--
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 01.07.2005  1.0      AK	Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity synch_fifo_pulse is
  
  port (
    clk_slow : in  std_logic;
    clk_fast : in  std_logic;
    rst_n    : in  std_logic;
    re_in    : in  std_logic;
    re_out   : out std_logic);

end synch_fifo_pulse;

architecture rtl of synch_fifo_pulse is
  signal pulse_slow_r : std_logic;
  signal pulse_fast_r : std_logic;
  
begin  -- rtl

  process (clk_slow, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      pulse_slow_r <= '0';
      
    elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge
      pulse_slow_r <= not pulse_slow_r;
    end if;
  end process;

  process (clk_fast, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      pulse_fast_r <= '0';
      
    elsif clk_fast'event and clk_fast = '1' then  -- rising clock edge
      pulse_fast_r <= pulse_slow_r;
    end if;
  end process;

  re_out <= (pulse_fast_r xor pulse_slow_r) and re_in;
  
end rtl;

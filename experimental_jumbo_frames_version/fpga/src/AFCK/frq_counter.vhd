-------------------------------------------------------------------------------
-- Title      : frq_counter
-- Project    : 
-------------------------------------------------------------------------------
-- File       : frq_counter.vhd
-- Author     : Wojciech M. Zabolotny  <wzab@wzdell.nasz.dom>
-- Company    : 
-- Created    : 2015-05-15
-- Last update: 2015-05-15
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Simple frequency counter for monitoring of clock frequency
--              inside FPGA
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-05-15  1.0      wzab	Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frq_counter is
  
  generic (
    CNT_TIME   : integer := 10000000; -- Counting time in cycles of ref_clk;
    CNT_LENGTH : integer := 32);        -- Length of the pulse counter

  port (
    ref_clk : in  std_logic;
    rst_p   : in  std_logic;
    frq_in  : in  std_logic;
    frq_out : out std_logic_vector(CNT_LENGTH-1 downto 0));

end entity frq_counter;

architecture beh of frq_counter is

  signal pulse_cnt : unsigned(CNT_LENGTH-1 downto 0) := (others => '0');
  signal gate_cnt : integer range 0 to CNT_TIME+2 := 0;
  signal clear, gate, gate_ack, clear_ack : std_logic := '0';
  
begin  -- architecture beh

  clk1: process (ref_clk, rst_p) is
  begin  -- process clk1
    if rst_p = '1' then               -- asynchronous reset (active low)
      gate_cnt <= 0;
      frq_out <= (others => '0');
    elsif ref_clk'event and ref_clk = '1' then  -- rising clock edge
      if gate_cnt = 0 then
        gate <= '1';
        gate_cnt <= gate_cnt + 1;
      elsif gate_cnt = CNT_TIME then
        gate <= '0';
        if gate_ack = '0' then
          frq_out <= std_logic_vector(pulse_cnt);
          clear <= '1';
          gate_cnt <= gate_cnt+1;
        end if;
      elsif gate_cnt = CNT_TIME+1 then
        if clear_ack = '1' then
          clear <= '0';
          gate_cnt <= CNT_TIME+2;                  
        end if;
      elsif gate_cnt = CNT_TIME+2 then
        if clear_ack = '0' then
          gate_cnt <= 0;
        end if;
      else
        gate_cnt <= gate_cnt + 1;
      end if;      
    end if;
  end process clk1;

  clk2: process (frq_in, rst_p) is
  begin  -- process clk2
    if rst_p = '1' then                   -- asynchronous reset (active low)
      pulse_cnt <= (others => '0');
      gate_ack <= '0';
      clear_ack <= '0';
    elsif frq_in'event and frq_in = '1' then  -- rising clock edge
      gate_ack <= gate;
      clear_ack <= clear;
      if gate_ack = '1' then
        pulse_cnt <= pulse_cnt + 1;
      elsif clear_ack = '1' then
        pulse_cnt <= (others => '0');
      end if;
    end if;
  end process clk2;

end architecture beh;

-------------------------------------------------------------------------------
-- Title      : Packet counter
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pkt_counter.vhd
-- Author     : Jussi Nieminen
-- Company    : 
-- Created    : 2009-05-05
-- Last update: 2011-12-01
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Counts pkt length, num of pkts and idle time
-------------------------------------------------------------------------------
-- Copyright (c) 2009 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009-05-05  1.0      niemin95	Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pkt_counter is

  generic (
    tx_len_width_g : integer := 8
    );
  
  port (
    clk        : in std_logic;
    rst_n      : in std_logic;
    
    len_in     : in std_logic_vector( tx_len_width_g-1 downto 0 );
    new_tx_in  : in std_logic;
    new_pkt_in : in std_logic;
    idle_in    : in std_logic
    );

end pkt_counter;


architecture rtl of pkt_counter is

  -- count idle time
  signal idle_counter_r : integer;
  -- count active time to get procentual data
  signal active_counter_r : integer;

  -- min, max and avg pkt size
  signal min_tx_size_r : integer;
  signal max_tx_size_r : integer;
  -- needed for the avg
  signal sum_of_len_r : integer;
  signal current_tx_size_r : integer;

  -- num of packets
  signal pkt_count_r : integer;
  -- num of transfers
  signal tx_count_r : integer;


  -- needed for edge detection
  signal old_new_pkt_r : std_logic;
  signal old_new_tx_r : std_logic;
  
  -- len as integer
  signal len_int : integer;

-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  -- convert len_in to integer
  len_int <= to_integer( unsigned( len_in ) );

  
  main: process (clk, rst_n)
    variable curr_tx_size_v : integer;
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)
      
      idle_counter_r    <= 0;
      active_counter_r  <= 0;
      min_tx_size_r     <= 0;
      max_tx_size_r     <= 0;
      sum_of_len_r      <= 0;
      pkt_count_r       <= 0;
      tx_count_r        <= 0;
      current_tx_size_r <= 0;
      old_new_tx_r      <= '0';
      old_new_pkt_r     <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      old_new_pkt_r <= new_pkt_in;
      old_new_tx_r <= new_tx_in;

      curr_tx_size_v := current_tx_size_r;
      
      -- count the num of transfers from the rising edge
      if new_tx_in = '1' and old_new_tx_r = '0' then
        tx_count_r <= tx_count_r + 1;

        -- new tx, check the min size and reset the size counter
        -- min
        if min_tx_size_r = 0 or current_tx_size_r < min_tx_size_r then
          min_tx_size_r <= current_tx_size_r;
        end if;
        
        curr_tx_size_v := 0;
      end if;


      -- new_pkt_in comes from the write request, and it can be up several clk
      -- cycles, count rising edges
      if new_pkt_in = '1' and old_new_pkt_r = '0' then
        pkt_count_r <= pkt_count_r + 1;

        curr_tx_size_v := curr_tx_size_v + len_int;

        -- count pkt sizes here
        -- max
        if curr_tx_size_v > max_tx_size_r then
          max_tx_size_r <= curr_tx_size_v;
        end if;

        -- sum of lengths for counting of average length
        sum_of_len_r <= sum_of_len_r + len_int;

      end if;

      current_tx_size_r <= curr_tx_size_v;
      
      -- count the idle and active time
      if idle_in = '1' then
        idle_counter_r <= idle_counter_r + 1;
      else
        active_counter_r <= active_counter_r + 1;
      end if;

    end if;
  end process main;

end rtl;

-------------------------------------------------------------------------------
-- Title      : Led blinker for ase_mesh1
-- Project    : 
-------------------------------------------------------------------------------
-- File       : led_pkt_codec_mk2.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-11-09
-- Last update: 2011-12-02
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Inverts led output for evey data word received.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-11-09  1.0      lehton87        Created
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

entity led_pkt_codec_mk2 is
  
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    cmd_in    : in  std_logic_vector(1 downto 0);
    data_in   : in  std_logic_vector(31 downto 0);
    stall_out : out std_logic;

    cmd_out   : out std_logic_vector(1 downto 0);
    data_out  : out std_logic_vector(31 downto 0);
    stall_in  : in  std_logic;
    
    led_out   : out std_logic
    );

end led_pkt_codec_mk2;


architecture rtl of led_pkt_codec_mk2 is

  signal led_r : std_logic;
  
begin  -- rtl

  data_out  <= (others => '0');
  cmd_out   <= (others => '0');
  stall_out <= '0';                     -- This accepts all incoming data
  led_out   <= led_r;

  --
  -- Read input
  --   
  main_p : process (clk, rst_n)
  begin  -- process main_p
    if rst_n = '0' then                 -- asynchronous reset (active low)

      led_r <= '1';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      if cmd_in = "00" then
        -- no data coming in
      elsif cmd_in = "01" then
        -- address coming in, don't care what it is
      elsif cmd_in = "10" then
        -- data coming in, donät care about its value
        led_r <= not led_r;
      else
        -- not defined
      end if;
      
    end if;
  end process main_p;

  

end rtl;

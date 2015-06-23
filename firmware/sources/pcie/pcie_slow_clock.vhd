
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class pcie_dma_wrap
--! 
--!
--! @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
--!              Frans Schreuder (frans.schreuder@nikhef.nl)
--!
--!
--! @date        26/01/2015    created
--!
--! @version     1.0
--!
--! @brief 
--! Creates a slow clock of ~40 MHz (41.667) by dividing the 250MHz clock by 6.
--!
--! @detail
--!
--!-----------------------------------------------------------------------------
--! @TODO
--!  
--!
--! ------------------------------------------------------------------------------
--! Virtex7 PCIe Gen3 DMA Core
--! 
--! \copyright GNU LGPL License
--! Copyright (c) Nikhef, Amsterdam, All rights reserved. <br>
--! This library is free software; you can redistribute it and/or
--! modify it under the terms of the GNU Lesser General Public
--! License as published by the Free Software Foundation; either
--! version 3.0 of the License, or (at your option) any later version.
--! This library is distributed in the hope that it will be useful,
--! but WITHOUT ANY WARRANTY; without even the implied warranty of
--! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--! Lesser General Public License for more details.<br>
--! You should have received a copy of the GNU Lesser General Public
--! License along with this library.
--! 
-- 
--! @brief ieee



library ieee, UNISIM, work;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use work.pcie_package.all;

entity pcie_slow_clock is
  port (
    clk        : in     std_logic;
    clkDiv6    : out    std_logic;
    pll_locked : out    std_logic;
    reset_n    : in     std_logic;
    reset_out  : out    std_logic);
end entity pcie_slow_clock;



architecture rtl of pcie_slow_clock is
component clk_wiz_40
port
 (-- Clock in ports
  clk_in250           : in     std_logic;
  -- Clock out ports
  clk_out40          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic
 );
end component;

ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
ATTRIBUTE SYN_BLACK_BOX OF clk_wiz_40 : COMPONENT IS TRUE;


ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
ATTRIBUTE BLACK_BOX_PAD_PIN OF clk_wiz_40 : COMPONENT IS "clk_in250,clk_out40,reset,locked";

   signal clkDiv6_s: std_logic;
   signal reset_s: std_logic;
   signal locked_s: std_logic;
   signal reset_cnt: integer range 0 to 15;

begin


reset_s <= not reset_n;
pll_locked <= locked_s;
clkDiv6 <= clkDiv6_s;

clk0 : clk_wiz_40
   port map ( 

   -- Clock in ports
   clk_in250 => clk,
  -- Clock out ports  
   clk_out40 => clkDiv6_s,
  -- Status and control signals                
   reset => reset_s,
   locked => locked_s            
 );
 
  process(reset_s,locked_s, clkDiv6_s)
 begin
   if(reset_s='1' or locked_s = '0') then
      reset_cnt <= 0;
      reset_out <= '1';
   elsif(rising_edge(clkDiv6_s)) then
      if(reset_cnt < 15) then
         reset_cnt <= reset_cnt + 1;
         reset_out <= '1';
      else
         reset_cnt <= 15;
         reset_out <= '0';
      end if;
   end if;
   
 end process;
 
end architecture rtl ; -- of pcie_slow_clock


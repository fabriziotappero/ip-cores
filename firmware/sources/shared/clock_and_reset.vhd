
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class clock_and_reset
--! 
--!
--! @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
--!              Frans Schreuder (frans.schreuder@nikhef.nl)
--!
--!
--! @date        07/01/2015    created
--!
--! @version     1.0
--!
--! @brief 
--! Clock and Reset instantiates an MMCM. It generates clocks of 40,
--! 80, 160 and 320 MHz.
--! Additionally a reset signal is issued when the MMCM is not locked.
--! Reset_out is synchronous to 40MHz
--! 
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

entity clock_and_reset is
  port (
    clk160       : out    std_logic;
    clk320       : out    std_logic;
    clk40        : out    std_logic;
    clk80        : out    std_logic;
    clk_200_in_n : in     std_logic;
    clk_200_in_p : in     std_logic;
    pll_locked   : out    std_logic;
    reset_out    : out    std_logic; --! Active high reset out (synchronous to clk40)
    sys_reset_n  : in     std_logic); --! Active low reset input.
end entity clock_and_reset;



architecture rtl of clock_and_reset is

component clk_wiz_0
port
 (-- Clock in ports
  clk_200_in_p         : in     std_logic;
  clk_200_in_n         : in     std_logic;
  -- Clock out ports
  clk40          : out    std_logic;
  clk80          : out    std_logic;
  clk160         : out    std_logic;
  clk320         : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic
 );
end component;

ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
ATTRIBUTE SYN_BLACK_BOX OF clk_wiz_0 : COMPONENT IS TRUE;


ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
ATTRIBUTE BLACK_BOX_PAD_PIN OF clk_wiz_0 : COMPONENT IS "clk_200_in_p,clk_200_in_n,clk40,reset,locked";

   signal reset_in: std_logic;
   
   signal reset_cnt: integer range 0 to 15;
   signal clk40_s: std_logic;
   signal locked_s: std_logic;
begin

clk0 : clk_wiz_0
   port map ( 

   -- Clock in ports
   clk_200_in_p => clk_200_in_p,
   clk_200_in_n => clk_200_in_n,
  -- Clock out ports  
   clk40  => clk40_s,
   clk80  => clk80,
   clk160 => clk160,
   clk320 => clk320,
  -- Status and control signals                
   reset => reset_in,
   locked => locked_s            
 );

 pll_locked <= locked_s;
 reset_in <= not sys_reset_n;
 clk40 <= clk40_s;

 
 process(reset_in,locked_s, clk40_s)
 begin
   if(reset_in='1' or locked_s = '0') then
      reset_cnt <= 0;
      reset_out <= '1';
   elsif(rising_edge(clk40_s)) then
      if(reset_cnt < 15) then
         reset_cnt <= reset_cnt + 1;
         reset_out <= '1';
      else
         reset_cnt <= 15;
         reset_out <= '0';
      end if;
   end if;
   
 end process;
 
end architecture rtl ; -- of clock_and_reset


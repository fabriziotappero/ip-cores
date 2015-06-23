--
--
--
-- 
-- Copyright (C) 2014  Christian Haettich  - feddischson [ at ] opencores.org
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--
--
--
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity or1200_test_top is
    Port ( CLK_50M   : in  STD_LOGIC;
           BTN_SOUTH : in  STD_LOGIC  );
end or1200_test_top;

architecture Behavioral of or1200_test_top is

component or1200_test is 
port( 
clk_i :  in  std_logic ;
rst_i :  in  std_logic ;
tck_i :  in  std_logic ;
tdi_i :  in  std_logic ;
tdo_o :  out  std_logic ;
debug_rst_i :  in  std_logic ;
shift_dr_i :  in  std_logic ;
pause_dr_i :  in  std_logic ;
update_dr_i :  in  std_logic ;
capture_dr_i :  in  std_logic ;
debug_select_i :  in  std_logic 
 );
end component or1200_test;

signal clk_i :  std_logic ;
signal rst_i :  std_logic ;
signal tck_i :  std_logic ;
signal tdi_i :  std_logic ;
signal tdo_o :  std_logic ;
signal shift_dr_i :  std_logic ;
signal pause_dr_i :  std_logic ;
signal update_dr_i :  std_logic ;
signal capture_dr_i :  std_logic ;
signal debug_select_i :  std_logic ;
signal debug_rst_i  :  std_logic ;
signal gnd : std_logic;
begin

gnd <= '0';
pause_dr_i <= '0';
clk_i <= CLK_50M;
rst_i <= BTN_SOUTH;

BSCAN_SPARTAN3A_inst : BSCAN_SPARTAN3A
   port map (
      CAPTURE => capture_dr_i,
      DRCK1 => open,          
      DRCK2 => open,          
      RESET => debug_rst_i,   
      SEL1 => debug_select_i, 
      SEL2 => open,           
      SHIFT => shift_dr_i,    
      TCK => tck_i,           
      TDI => tdi_i,           
      TMS => open,            
      UPDATE => update_dr_i,  
      TDO1 => tdo_o,          
      TDO2 => gnd             
);


top : or1200_test
port map(
clk_i          => clk_i         ,
rst_i          => rst_i         ,
tck_i          => tck_i         ,
tdi_i          => tdi_i         ,
tdo_o          => tdo_o         ,
debug_rst_i      => debug_rst_i     ,
shift_dr_i     => shift_dr_i    ,
pause_dr_i     => pause_dr_i    ,
update_dr_i    => update_dr_i   ,
capture_dr_i   => capture_dr_i  ,
debug_select_i => debug_select_i
);


end Behavioral;


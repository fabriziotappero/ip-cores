--------------------------------------------------------------------------------
--                                                                            --
--------------------------------------------------------------------------------
-- Version:  1.0                                                              --
-- Device:   Spartan 3E                                                       --
--                                                                            --
-- DESCRIPTION                                                                --
--                                                                            --
--                                                                            --
--------------------------------------------------------------------------------
-- Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.iwb.all;
use work.ivga.all;

entity tb_vga is
   port(
      CLK       : in  std_logic;
      VGA_HSYNC : out std_logic;
      VGA_VSYNC : out std_logic;
      VGA_RED   : out std_logic;
      VGA_GREEN : out std_logic;
      VGA_BLUE  : out std_logic
   );
end tb_vga;

architecture tb of tb_vga is

   component global_clock
      port(
         clkin_in        : in std_logic;
         rst_in          : in std_logic;          
         clkdv_out       : out std_logic;
         clkin_ibufg_out : out std_logic;
         clk0_out        : out std_logic
         );
   end component;

   signal si : slave_in_t;
   signal so : slave_out_t;
begin
   
   inst_clock: global_clock
      port map(
         clkin_in => CLK,
         rst_in => '0',
         clkdv_out => open, --si.clk,
         clkin_ibufg_out => open,
         clk0_out => si.clk--open
      );
     
   disp : vga
   port map(
      si        => si,
      so        => so,
   -- Non Wishbone Signals
      VGA_HSYNC => VGA_HSYNC,
      VGA_VSYNC => VGA_VSYNC,
      VGA_RED   => VGA_RED,
      VGA_GREEN => VGA_GREEN,
      VGA_BLUE  => VGA_BLUE
   );   
end tb;
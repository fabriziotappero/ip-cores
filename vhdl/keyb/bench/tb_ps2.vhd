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

entity tb_ps2 is
   port(
      CLK      : in  std_logic;
      PS2_CLK  : in  std_logic;
      PS2_DATA : in  std_logic;
      LED      : out std_logic_vector(7 downto 0)
   );
end tb_ps2;

architecture tb of tb_ps2 is

   component ps2 is
      port(
         clk      : in  std_logic;
         rst      : in  std_logic;
         PS2_CLK  : in  std_logic;
         PS2_DATA : in  std_logic;
         char     : out std_logic_vector(7 downto 0);
         rx_done  : out std_logic
      );
   end component;
   
begin
   
   uut0 : ps2 port map(
      clk      => CLK,
      rst      => '0',
      PS2_CLK  => PS2_CLK,
      PS2_DATA => PS2_DATA,
      char     => LED,
      rx_done  => open
   );
end tb;
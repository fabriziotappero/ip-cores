--------------------------------------------------------------------------------
--            _   _            __   ____                                      --
--           / / | |          / _| |  __|                                     --
--           | |_| |  _   _  / /   | |_                                       --
--           |  _  | | | | | | |   |  _|                                      --
--           | | | | | |_| | \ \_  | |__                                      --
--           |_| |_| \_____|  \__| |____| microLab                            --
--                                                                            --
--           Bern University of Applied Sciences (BFH)                        --
--           Quellgasse 21                                                    --
--           Room HG 4.33                                                     --
--           2501 Biel/Bienne                                                 --
--           Switzerland                                                      --
--                                                                            --
--           http://www.microlab.ch                                           --
--------------------------------------------------------------------------------
--   GECKO4com
--  
--   2010/2011 Dr. Theo Kluter
--  
--   This VHDL code is free code: you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation, either version 3 of the License, or
--   (at your option) any later version.
--  
--   This VHDL code is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU General Public License for more details. 
--   You should have received a copy of the GNU General Public License
--   along with these sources.  If not, see <http://www.gnu.org/licenses/>.
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

-- Color definition:
-- 0 => black
-- 1 => blue
-- 2 => green
-- 3 => cyan
-- 4 => red
-- 5 => magenta
-- 6 => yellow
-- 7 => white

ENTITY vga_controller IS
   PORT ( clock_75MHz         : IN  std_logic;
          reset               : IN  std_logic;
          vga_off             : IN  std_logic;
          clock               : IN  std_logic;
          
          -- Here the scpi interface is defined
          start_command       : IN  std_logic;
          command_id          : IN  std_logic_vector( 6 DOWNTO 0 );
          command_done        : OUT std_logic;
          command_error       : OUT std_logic;
          
          -- Here the usbtmc fifo interface is defined
          pop                 : OUT std_logic;
          pop_data            : IN  std_logic_vector(  7 DOWNTO 0 );
          pop_last            : IN  std_logic;
          pop_empty           : IN  std_logic;
          push                : OUT std_logic;
          push_data           : OUT std_logic_vector(  7 DOWNTO 0 );
          push_size           : OUT std_logic;
          push_full           : IN  std_logic;
          
          -- Here the PUD interface is defined
          we_char             : IN  std_logic;
          we_ascii            : IN  std_logic_vector(  7 DOWNTO 0 );
          we_addr             : IN  std_logic_vector( 10 DOWNTO 0 );
          
          -- Here the fpga interface is defined
          cursor_pos          : IN  std_logic_vector( 10 DOWNTO 0 );
          screen_offset       : IN  std_logic_vector(  4 DOWNTO 0 );
          fg_color            : IN  std_logic_vector(  2 DOWNTO 0 );
          bg_color            : IN  std_logic_vector(  2 DOWNTO 0 );
          write_address       : IN  std_logic_vector( 10 DOWNTO 0 );
          ascii_data          : IN  std_logic_vector(  7 DOWNTO 0 );
          we                  : IN  std_logic;
          
          vga_red             : OUT std_logic;
          vga_green           : OUT std_logic;
          vga_blue            : OUT std_logic;
          vga_hsync           : OUT std_logic;
          vga_vsync           : OUT std_logic );
END vga_controller;


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

ENTITY clocks IS
   PORT ( system_n_reset    : IN  std_logic;
          clock_25MHz       : IN  std_logic;
          clock_16MHz       : IN  std_logic;
          user_clock_1      : IN  std_logic;
          user_clock_2      : IN  std_logic;
          
          -- Here the compensated clocks are defined
          user_clock_1_out  : OUT std_logic;
          user_clock_1_fb   : IN  std_logic;
          user_clock_1_lock : OUT std_logic;
          user_clock_2_out  : OUT std_logic;
          user_clock_2_fb   : IN  std_logic;
          user_clock_2_lock : OUT std_logic;
          
          -- Here the master clocks are defined
          clock_25MHz_out   : OUT std_logic;
          clock_48MHz_out   : OUT std_logic;
          
          -- Here the FPGA internal clocks are defined
          clk_48MHz         : OUT std_logic;
          clk_96MHz         : OUT std_logic;
          clk_75MHz         : OUT std_logic;
          reset_out         : OUT std_logic;
          msec_tick         : OUT std_logic );
 END clocks;

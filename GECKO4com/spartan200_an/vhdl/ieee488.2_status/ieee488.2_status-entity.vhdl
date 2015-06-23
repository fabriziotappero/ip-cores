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

ENTITY status_controller IS
   PORT ( clock           : IN  std_logic;
          reset           : IN  std_logic;
          
          fpga_configured : IN  std_logic;
          
          -- Here the fx2 interface is defined
          status_nibble   : OUT std_logic_vector( 3 DOWNTO 0 );
          
          -- Here the external status if is defined
          ESB_bit         : IN  std_logic;
          STATUS3_bit     : IN  std_logic;
          
          -- Here the scpi interface is defined
          start           : IN  std_logic;
          command         : IN  std_logic_vector( 6 DOWNTO 0 );
          cmd_error       : OUT std_logic;
          command_error   : IN  std_logic;
          execution_error : IN  std_logic;
          done            : OUT std_logic;
          transparent     : OUT std_logic;
          
          pop             : OUT std_logic;
          pop_data        : IN  std_logic_vector( 7 DOWNTO 0 );
          pop_last        : IN  std_logic;
          pop_empty       : IN  std_logic;
          
          push            : OUT std_logic;
          push_data       : OUT std_logic_vector( 7 DOWNTO 0 );
          push_size       : OUT std_logic;
          push_full       : IN  std_logic;
          push_empty      : IN  std_logic );
END status_controller;

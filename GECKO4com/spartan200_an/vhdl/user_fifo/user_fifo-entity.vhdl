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

ENTITY user_fifo IS
   PORT ( clock                  : IN  std_logic;
          reset                  : IN  std_logic;
          
          -- Here the bus signals are defined
          n_bus_reset            : IN  std_logic;
          n_start_transmission   : IN  std_logic;
          n_end_transmission_in  : IN  std_logic;
          n_end_transmission_out : OUT std_logic;
          n_data_valid_in        : IN  std_logic_vector( 1 DOWNTO 0 );
          n_data_valid_out       : OUT std_logic_vector( 1 DOWNTO 0 );
          data_in                : IN  std_logic_vector(15 DOWNTO 0 );
          data_out               : OUT std_logic_vector(15 DOWNTO 0 );
          read_n_write           : IN  std_logic;
          burst_size             : IN  std_logic_vector( 8 DOWNTO 0 );
          bus_address            : IN  std_logic_vector( 5 DOWNTO 0 );
          n_start_send           : OUT std_logic;
          n_bus_error            : OUT std_logic;

          -- Here the scpi interface is defined
          start_command          : IN  std_logic;
          command_id             : IN  std_logic_vector( 6 DOWNTO 0 );
          transparent_mode       : IN  std_logic;
          command_done           : OUT std_logic;
          command_error          : OUT std_logic;
          message_available      : OUT std_logic;
          
          -- Here the tx_fifo is defined
          push                   : OUT std_logic;
          push_size              : OUT std_logic;
          push_data              : OUT std_logic_vector( 7 DOWNTO 0 );
          fifo_full              : IN  std_logic;
          
          -- Here the rx_fifo is defined
          pop                    : OUT std_logic;
          pop_last               : IN  std_logic;
          pop_data               : IN  std_logic_vector( 7 DOWNTO 0 );
          pop_empty              : IN  std_logic;
          
          -- Here the big fpga interface is defined
          data_request_irq       : OUT std_logic;
          data_available_irq     : OUT std_logic;
          error_irq              : OUT std_logic);
END user_fifo;


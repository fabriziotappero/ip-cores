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

ENTITY config_if IS
   PORT ( clock                  : IN  std_logic;
          reset                  : IN  std_logic;
          
          -- here the flash interface is defined
          start_config           : IN  std_logic;
          flash_start_read       : OUT std_logic;
          flash_done             : IN  std_logic;
          flash_present          : IN  std_logic;
          flash_s1_empty         : IN  std_logic;
          flash_idle             : IN  std_logic;
          
          flash_push             : IN  std_logic;
          flash_push_data        : IN  std_logic_vector( 7 DOWNTO 0 );
          flash_push_size        : IN  std_logic;
          flash_push_last        : IN  std_logic;
          flash_fifo_full        : OUT std_logic;
          
          -- here the flash usbtmc interface is defined
          flash_u_start_read     : IN  std_logic;
          flash_u_done           : OUT std_logic;
          flash_u_push           : OUT std_logic;
          flash_u_push_data      : OUT std_logic_vector( 7 DOWNTO 0 );
          flash_u_push_size      : OUT std_logic;
          flash_u_fifo_full      : IN  std_logic;
          
          -- here the bitfile interface is defined
          bitfile_start          : OUT std_logic;
          bitfile_pop            : IN  std_logic;
          bitfile_pop_data       : OUT std_logic_vector( 7 DOWNTO 0 );
          bitfile_last           : OUT std_logic;
          bitfile_fifo_empty     : OUT std_logic;
          
          -- here the bitfile usbtmc interface is defined
          bitfile_u_start        : IN  std_logic;
          bitfile_u_pop          : OUT std_logic;
          bitfile_u_pop_data     : IN  std_logic_vector( 7 DOWNTO 0 );
          bitfile_u_last         : IN  std_logic;
          bitfile_u_fifo_empty   : IN  std_logic;
          
          -- here the fpga interface is defined
          fpga_idle              : IN  std_logic;
          fpga_type              : IN  std_logic_vector( 2 DOWNTO 0 );
          
          -- here the power interface is defined
          n_bus_power            : IN  std_logic;
          
          -- here the scpi interface is defined
          start_command          : IN  std_logic;
          command_id             : IN  std_logic_vector( 6 DOWNTO 0 );
          command_error          : OUT std_logic );
END config_if;

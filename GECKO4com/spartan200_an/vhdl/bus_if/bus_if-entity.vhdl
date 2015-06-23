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

ENTITY bus_if IS
   PORT ( clock                    : IN    std_logic;
          reset                    : IN    std_logic;
          
          -- Here the IOB interface is defined
          bus_reset                : IN    std_logic;
          bus_n_start_transmission : IN    std_logic;
          bus_n_end_transmission   : INOUT std_logic;
          bus_n_data_valid         : INOUT std_logic_vector( 1 DOWNTO 0 );
          bus_data_addr_cntrl      : INOUT std_logic_vector(15 DOWNTO 0 );
          bus_n_start_send         : OUT   std_logic;
          bus_n_error              : OUT   std_logic;
          
          -- Here the FPGA internal interface is defined
          b_n_reset                : OUT   std_logic;
          b_n_start_transmission   : OUT   std_logic;
          b_n_end_transmission_out : OUT   std_logic;
          b_n_end_transmission_in  : IN    std_logic;
          b_n_data_valid_out       : OUT   std_logic_vector( 1 DOWNTO 0 );
          b_n_data_valid_in        : IN    std_logic_vector( 1 DOWNTO 0 );
          data_out                 : OUT   std_logic_vector(15 DOWNTO 0 );
          data_in                  : IN    std_logic_vector(15 DOWNTO 0 );
          read_n_write             : OUT   std_logic;
          burst_size               : OUT   std_logic_vector( 8 DOWNTO 0 );
          address                  : OUT   std_logic_vector( 5 DOWNTO 0 );
          n_start_send             : IN    std_logic;
          n_bus_error              : IN    std_logic);
END bus_if;

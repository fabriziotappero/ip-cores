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

-- fpga_type:
--   000 => XC3S1000
--   001 => XC3S1500
--   010 => XC3S2000
--   011 => XC3S4000
--   100 => XC3S5000
--  rest => Unknown FPGA or no FPGA mounted

ENTITY fpga_if IS
   PORT ( clock             : IN  std_logic;
          reset             : IN  std_logic;
          
          -- Here the FPGA info is provided
          fpga_idle         : OUT std_logic;
          fpga_revision     : OUT std_logic_vector( 3 DOWNTO 0 );
          fpga_type         : OUT std_logic_vector( 2 DOWNTO 0 );
          fpga_configured   : OUT std_logic;
          fpga_crc_error    : OUT std_logic;
          
          -- Here the bitfile fifo if is defined
          push              : IN  std_logic;
          push_data         : IN  std_logic_vector( 7 DOWNTO 0 );
          last_byte         : IN  std_logic;
          fifo_full         : OUT std_logic;
          
          -- Here the select map pins are defined
          fpga_done         : IN  std_logic;
          fpga_busy         : IN  std_logic;
          fpga_n_init       : IN  std_logic;
          fpga_n_prog       : OUT std_logic;
          fpga_rd_n_wr      : OUT std_logic;
          fpga_n_cs         : OUT std_logic;
          fpga_cclk         : OUT std_logic;
          
          fpga_data_in      : IN  std_logic_vector( 7 DOWNTO 0 );
          fpga_data_out     : OUT std_logic_vector( 7 DOWNTO 0 );
          fpga_n_tri        : OUT std_logic_vector( 7 DOWNTO 0 );
          fpga_data_in_ena  : OUT std_logic;
          fpga_data_out_ena : OUT std_logic);
END fpga_if;
          

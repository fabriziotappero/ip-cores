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

ENTITY bitfile_interpreter IS
   PORT ( clock                 : IN  std_logic;
          reset                 : IN  std_logic;
          msec_tick             : IN  std_logic;
          
          -- Here the handshake interface is defined
          start                 : IN  std_logic;
          write_flash           : IN  std_logic;
          done                  : OUT std_logic;
          error_detected        : OUT std_logic;
          
          -- Here the FX2 fifo interface is defined
          pop                   : OUT std_logic;
          pop_data              : IN  std_logic_vector( 7 DOWNTO 0 );
          pop_last              : IN  std_logic;
          fifo_empty            : IN  std_logic;
          
          -- Here the FPGA_IF fifo interface is defined
          push                  : OUT std_logic;
          push_data             : OUT std_logic_vector( 7 DOWNTO 0 );
          last_byte             : OUT std_logic;
          fifo_full             : IN  std_logic;
          reset_fpga_if         : OUT std_logic;
          
          -- Here the flash write fifo interface is defined
          bitfile_size          : OUT std_logic_vector(31 DOWNTO 0 );
          we_fifo               : OUT std_logic;
          we_data               : OUT std_logic_vector( 7 DOWNTO 0 );
          we_last               : OUT std_logic;
          we_fifo_full          : IN  std_logic;
          start_write           : OUT std_logic;
          size_error            : IN  std_logic;
          
          -- Here the debug vga interface is defined
          we_char               : OUT std_logic;
          ascii_data            : OUT std_logic_vector( 7 DOWNTO 0 ));
END bitfile_interpreter;

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

ENTITY flash_if IS
   PORT ( clock                : IN  std_logic;
          reset                : IN  std_logic;
          msec_tick            : IN  std_logic;
          
          -- here the control interface is defined
          start_erase          : IN  std_logic;
          start_read           : IN  std_logic;
          start_write          : IN  std_logic;
          done                 : OUT std_logic;
          flash_present        : OUT std_logic;
          flash_s1_empty       : OUT std_logic;
          flash_idle           : OUT std_logic;
          size_error           : OUT std_logic;
          flash_n_busy         : OUT std_logic;
          start_config         : OUT std_logic;

          -- here the push fifo interface is defined
          push                 : OUT std_logic;
          push_data            : OUT std_logic_vector( 7 DOWNTO 0 );
          push_size            : OUT std_logic;
          push_last            : OUT std_logic;
          fifo_full            : IN  std_logic;
          
          -- here the write fifo is defined
          bitfile_size         : IN  std_logic_vector( 31 DOWNTO 0 );
          we_fifo              : IN  std_logic;
          we_data              : IN  std_logic_vector(  7 DOWNTO 0 );
          we_last              : IN  std_logic;
          we_fifo_full         : OUT std_logic;
          
          -- Here the scpi interface is defined
          start_command        : IN  std_logic;
          command_id           : IN  std_logic_vector( 6 DOWNTO 0 );
          scpi_pop             : OUT std_logic;
          scpi_pop_data        : IN  std_logic_vector( 7 DOWNTO 0 );
          scpi_pop_last        : IN  std_logic;
          scpi_empty           : IN  std_logic;
          scpi_push            : OUT std_logic;
          scpi_push_data       : OUT std_logic_vector( 7 DOWNTO 0 );
          scpi_push_size       : OUT std_logic;
          scpi_full            : IN  std_logic;
          
          -- Here the vga interface is defined
          we_char              : OUT std_logic;
          we_ascii             : OUT std_logic_vector(  7 DOWNTO 0 );
          we_addr              : OUT std_logic_vector( 10 DOWNTO 0 );
          
          -- define the flash interface
          flash_address        : OUT std_logic_vector( 19 DOWNTO 0 );
          flash_data_in        : IN  std_logic_vector( 15 DOWNTO 0 );
          flash_data_out       : OUT std_logic_vector( 15 DOWNTO 0 );
          flash_data_oe        : OUT std_logic_vector( 15 DOWNTO 0 );
          flash_n_byte         : OUT std_logic;
          flash_n_ce           : OUT std_logic;
          flash_n_oe           : OUT std_logic;
          flash_n_we           : OUT std_logic;
          flash_ready_n_busy   : IN  std_logic);
END flash_if;

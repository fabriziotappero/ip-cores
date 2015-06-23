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

ENTITY USBTMC IS
   PORT ( clock_96MHz      : IN  std_logic;
          clock_48MHz      : IN  std_logic;
          cpu_reset        : IN  std_logic;
          sync_reset_out   : OUT std_logic;
          
          -- FX2 control interface
          FX2_n_ready      : IN  std_logic;
          FX2_hi_speed     : IN  std_logic;
          
          -- SCPI command interpretor interface
          pending_message  : IN  std_logic;
          transfer_in_prog : OUT std_logic;
          
          -- read fifo interface
          rf_pop           : IN  std_logic;
          rf_pop_data      : OUT std_logic_vector( 7 DOWNTO 0 );
          rf_last_data_byte: OUT std_logic;
          rf_fifo_empty    : OUT std_logic;
          
          -- Write fifo interface
          wf_push          : IN  std_logic;
          wf_push_data     : IN  std_logic_vector( 7 DOWNTO 0 );
          wf_push_size_bit : IN  std_logic;
          wf_fifo_full     : OUT std_logic;
          wf_fifo_empty    : OUT std_logic;
          
          -- status interface
          status_nibble    : IN  std_logic_vector( 3 DOWNTO 0 );
          indicator_pulse  : OUT std_logic;
          
          -- FX2 port D interface
          data_nibble      : OUT std_logic_vector( 3 DOWNTO 0 );
          data_select      : IN  std_logic_vector( 3 DOWNTO 0 );
          
          -- FX2 FIFO interface
          EP8_n_empty      : IN  std_logic;
          EP6_n_full       : IN  std_logic;
          EP_data_in       : IN  std_logic_vector( 7 DOWNTO 0 );
          EP_address       : OUT std_logic_vector( 1 DOWNTO 0 );
          EP_IFCLOCK       : OUT std_logic;
          EP_n_PKTEND      : OUT std_logic;
          EP_n_OE          : OUT std_logic;
          EP_n_RE          : OUT std_logic;
          EP_n_WE          : OUT std_logic;
          EP_data_out      : OUT std_logic_vector( 7 DOWNTO 0 );
          EP_n_tri_out     : OUT std_logic_vector( 7 DOWNTO 0 ) );
END USBTMC;

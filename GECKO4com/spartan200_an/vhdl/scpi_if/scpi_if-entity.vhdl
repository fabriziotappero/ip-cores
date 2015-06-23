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

-- The vendor commands are directly send to the main FPGA without
-- interpretation of the ieee488.2 controler

ENTITY SCPI_INTERFACE IS
   PORT ( clock            : IN  std_logic;
          reset            : IN  std_logic;
          
          -- The command interface
          transparent_mode : IN  std_logic;
          start_command    : OUT std_logic;
          command_id       : OUT std_logic_vector( 6 DOWNTO 0 );
          cmd_gen_respons  : OUT std_logic;
          command_done     : IN  std_logic;
          command_error    : IN  std_logic;
          unknown_command  : OUT std_logic;
          slave_pop        : IN  std_logic;
          
          -- USBTMC fifo interface
          pop              : OUT std_logic;
          pop_data         : IN  std_logic_vector( 7 DOWNTO 0 );
          pop_empty        : IN  std_logic;
          pop_last         : IN  std_logic);
END SCPI_INTERFACE;
          
      -- Command ID <=> Command
      --     0x02   <=> "*CLS"
      --     0x06   <=> "*ESE"
      --     0x07   <=> "*ESE?"
      --     0x08   <=> "*ESR?"
      --     0x09   <=> "*IDN?"
      --     0x0A   <=> "*IST?"
      --     0x0B   <=> "*OPC"
      --     0x0C   <=> "*OPC?"
      --     0x0D   <=> "*PUD"
      --     0x0E   <=> "*PUD?"
      --     0x0F   <=> "*RST"
      --     0x10   <=> "*SRE"
      --     0x11   <=> "*SRE?"
      --     0x12   <=> "*STB?"
      --     0x14   <=> "*TST?"
      --     0x15   <=> "*WAI"
      --     0x16   <=> "BITFLASH"
      --     0x17   <=> "BITFLASH?"
      --     0x18   <=> "BOARD?"
      --     0x19   <=> "CONFIG"
      --     0x1A   <=> "ERASE"
      --     0x1B   <=> "FIFO"
      --     0x1C   <=> "FIFO?"
      --     0x1D   <=> "FPGA"
      --     0x1E   <=> "FPGA?"
      --     0x23   <=> "HEXSWITCH"
      --     0x24   <=> "HEXSWITCH?"
      --     0x25   <=> "IDENTIFY"
      --     0x33   <=> "TRANS"
      --     0x3A   <=> "USERRESET"
      --     0x3B   <=> "VGA:BGCOL"
      --     0x3C   <=> "VGA:CLEAR"
      --     0x3D   <=> "VGA:CURSOR"
      --     0x3E   <=> "VGA:CURSOR?"
      --     0x3F   <=> "VGA:FGCOL"
      --     0x40   <=> "VGA:PUTSTR"

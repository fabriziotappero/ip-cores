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

-- IMPORTANT: This core is single byte writable/readable only!
--            In case of a burst size > 1 a bus_error is generated
--
-- Address map:
-- 0x20 -> read/write fg color
-- 0x21 -> read/write bg color
-- 0x22 -> read/write cursor x position
-- 0x23 -> read/write cursor y position
-- 0x24 -> write ascii data at cursor position
-- 0x25 -> write dummy for clear screen
-- 0x26 -> read buttons
-- 0x27 -> read hexswitch
-- 0x28 -> read/write LED0 mode
-- 0x29 -> read/write LED1 mode
-- 0x2A -> read/write LED2 mode
-- 0x2B -> read/write LED3 mode
-- 0x2C -> read/write LED4 mode
-- 0x2D -> read/write LED5 mode
-- 0x2E -> read/write LED6 mode
-- 0x2F -> read/write LED7 mode

-- Definition of the led mode reg:
-- bit 3 -> 1 => fast blinking/toggle (8Hz)
--          0 => slow blinking/toggle (1Hz)
-- bit 2..0 => 000 LED off
--             001 LED off
--             010 LED Red
--             011 LED Green
--             100 LED Red blinking
--             101 LED Green blinking
--             110 LED Red/Green toggling
--             111 LED Red/Green toggling

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY vga_bus IS
   PORT ( clock                  : IN  std_logic;
          reset                  : IN  std_logic;
          msec_tick              : IN  std_logic;
          
          -- Here the bus signals are defined
          n_bus_reset            : IN  std_logic;
          n_start_transmission   : IN  std_logic;
          n_end_transmission_in  : IN  std_logic;
          n_end_transmission_out : OUT std_logic;
          n_data_valid_in        : IN  std_logic; -- Only for low byte!
          n_data_valid_out       : OUT std_logic_vector( 1 DOWNTO 0 );
          data_in                : IN  std_logic_vector( 7 DOWNTO 0 );
          data_out               : OUT std_logic_vector(15 DOWNTO 0 );
          read_n_write           : IN  std_logic;
          burst_size             : IN  std_logic_vector( 8 DOWNTO 0 );
          bus_address            : IN  std_logic_vector( 5 DOWNTO 0 );
          n_start_send           : OUT std_logic;
          n_bus_error            : OUT std_logic;
          
          -- Here the button interface is defined
          n_button_1             : IN  std_logic;
          n_button_2             : IN  std_logic;
          n_button_3             : IN  std_logic;
          hexswitch              : IN  std_logic_vector( 3 DOWNTO 0 );
          
          -- Here the LED interface is defined
          leds_a                 : OUT std_logic_vector( 7 DOWNTO 0 );
          leds_k                 : OUT std_logic_vector( 7 DOWNTO 0 );
          
          -- Here the VGA interface is defined
          cursor_pos             : OUT std_logic_vector( 10 DOWNTO 0 );
          screen_offset          : OUT std_logic_vector(  4 DOWNTO 0 );
          fg_color               : OUT std_logic_vector(  2 DOWNTO 0 );
          bg_color               : OUT std_logic_vector(  2 DOWNTO 0 );
          write_address          : OUT std_logic_vector( 10 DOWNTO 0 );
          ascii_data             : OUT std_logic_vector(  7 DOWNTO 0 );
          we                     : OUT std_logic);
END vga_bus;

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

ENTITY xc3s200an_top IS
   PORT ( clock_25MHz          : IN    std_logic;
          clock_16MHz          : IN    std_logic;
          
          user_clock_1_in      : IN    std_logic;
          user_clock_1_fb      : IN    std_logic;
          user_clock_2_in      : IN    std_logic;
          user_clock_2_fb      : IN    std_logic;
          
          user_clock_1_out     : OUT   std_logic;
          user_clock_2_out     : OUT   std_logic;
          clock_25MHz_out      : OUT   std_logic;
          clock_48MHz_out      : OUT   std_logic;
          
          user_clock_1_lock    : OUT   std_logic;
          user_clock_2_lock    : OUT   std_logic;
          
          jtag_ndet            : IN    std_logic;
          
          fx2_clk              : OUT   std_logic;
          
          leds_a               : OUT   std_logic_vector( 7 DOWNTO 0 );
          leds_k               : OUT   std_logic_vector( 7 DOWNTO 0 );
          
          flash_address        : OUT   std_logic_vector( 19 DOWNTO 0 );
          flash_data           : INOUT std_logic_vector( 15 DOWNTO 0 );
          flash_n_byte         : OUT   std_logic;
          flash_n_ce           : OUT   std_logic;
          flash_n_oe           : OUT   std_logic;
          flash_n_we           : OUT   std_logic;
          flash_ready_n_busy   : IN    std_logic;
          
          SDA                  : INOUT std_logic;
          SCL                  : IN    std_logic;
          
          -- FX2 Interface
          fx2_n_int0           : OUT   std_logic; 
          fx2_pa1              : IN    std_logic; -- 0 when fx2 is ready
          fx2_pa3              : IN    std_logic; -- 1 full_speed 0 high-speed
          fx2_flaga            : IN    std_logic; -- ep8 fifo n_empty flag
          fx2_flagb            : IN    std_logic; -- ep6 fifo n_full flag
--          fx2_flagc            : IN    std_logic; -- ep6 fifo n_full flag
          
          fx2_data             : INOUT std_logic_vector( 7 DOWNTO 0 );
          fx2_fifo_addr        : OUT   std_logic_vector( 1 DOWNTO 0 );
          fx2_ifclock          : OUT   std_logic;
          fx2_n_oe             : OUT   std_logic;
          fx2_n_re             : OUT   std_logic;
          fx2_n_we             : OUT   std_logic;
          fx2_n_pkt_end        : OUT   std_logic;
          
          fx2_data_nibble      : OUT   std_logic_vector( 3 DOWNTO 0 );
          fx2_data_select      : IN    std_logic_vector( 3 DOWNTO 0 );
          
          -- power sensing interface
          n_usb_power          : IN    std_logic;
          n_bus_power          : IN    std_logic;
          n_usb_charge         : IN    std_logic;
          
          -- Switches
          n_hex_switch         : IN    std_logic_vector(  3 DOWNTO 0 );
          button1              : IN    std_logic;
          button2              : IN    std_logic;
          button3              : IN    std_logic;
          
          -- fpga interface
          fpga_done            : IN    std_logic;
          fpga_busy            : IN    std_logic;
          fpga_n_init          : IN    std_logic;
          fpga_n_prog          : OUT   std_logic;
          fpga_rd_n_wr         : OUT   std_logic;
          fpga_n_cs            : OUT   std_logic;
          fpga_cclk            : OUT   std_logic;
          fpga_data            : INOUT std_logic_vector( 7 DOWNTO 0 );
          
          -- RS232 passthrough
          RxD_in               : IN    std_logic;
          RxD_out              : OUT   std_logic;
          TxD_in               : IN    std_logic;
          TxD_out              : OUT   std_logic;
          
          -- Signals for transparent mode
          scpi_disabled        : OUT   std_logic;
          ESB_bit              : IN    std_logic;
          STATUS3_bit          : IN    std_logic;
          
          -- reset interface
          n_reset_system       : INOUT std_logic;
          
          -- bus interface
          bus_reset                : IN    std_logic;
          bus_n_start_transmission : IN    std_logic;
          bus_n_end_transmission   : INOUT std_logic;
          bus_n_data_valid         : INOUT std_logic_vector( 1 DOWNTO 0 );
          bus_data_addr_cntrl      : INOUT std_logic_vector(15 DOWNTO 0 );
          bus_n_start_send         : OUT   std_logic;
          bus_n_error              : OUT   std_logic;
          data_request_irq         : OUT   std_logic;
          data_available_irq       : OUT   std_logic;
          error_irq                : OUT   std_logic;
          user_n_reset             : OUT   std_logic;

          -- vga interface
          red                  : OUT   std_logic;
          green                : OUT   std_logic;
          blue                 : OUT   std_logic;
          hsync                : OUT   std_logic;
          vsync                : OUT   std_logic);
END xc3s200an_top;

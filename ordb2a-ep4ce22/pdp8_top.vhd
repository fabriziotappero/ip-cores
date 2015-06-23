--!
--! ORSoC ordb2a-ep4ce22 PDP-8 Processor
--!
--! \brief
--!      PDP-8 implementation for the ORSoC ordb2a-ep4ce22 board
--!
--! \details
--!
--! \file
--!      pdp8_top.vhd
--!
--! \author
--!    Joe Manojlovich - joe.manojlovich (at) gmail (dot) com
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2012 Joe Manojlovich
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- version 2.1 of the License.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE. See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl.txt
--
--------------------------------------------------------------------
--
-- Comments are formatted for doxygen
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std;
use work.uart_types.all;                        --! UART Types
use work.dk8e_types.all;                        --! DK8E Types
use work.kc8e_types.all;                        --! KC8E Types
use work.kl8e_types.all;                        --! KL8E Types
use work.rk8e_types.all;                        --! RK8E Types
use work.rk05_types.all;
use work.ls8e_types.all;                        --! LS8E Types
use work.pr8e_types.all;                        --! PR8E Types
use work.cpu_types.all;                         --! CPU Types
use work.sd_types.all;                                  --! SD Types
use work.sdspi_types.all;                               --! SPI Types

ENTITY pdp8_top IS
generic(
     invert_reset : std_logic := '0' -- 0 : not invert, 1 invert
 );
	PORT ( 
		sys_clk_pad_i : IN STD_LOGIC;
		rst_n_pad_i : IN STD_LOGIC;
		spi0_sck_o : OUT STD_LOGIC;
		spi0_mosi_o : OUT STD_LOGIC;
		spi0_miso_i : IN STD_LOGIC;
		spi0_ss_o : OUT STD_LOGIC;
		uart0_srx_pad_i : IN STD_LOGIC;
		uart0_stx_pad_o : OUT STD_LOGIC
	);
END pdp8_top;

architecture a of pdp8_top is
  signal rk8eSTAT : rk8eSTAT_t;
  signal swCNTL : swCNTL_t := (others => '0');                       --! Front Panel Control Switches
  signal swROT : swROT_t := dispPC;                                  --! Front panel rotator switch
  signal swOPT  : swOPT_t;                                           --! PDP-8 options
  signal swDATA : swDATA_t;             --! Front panel switches
  
  signal dly: std_logic := '0';         --! Delay used for reset logic
  signal rst: std_logic := '0';         --! Internal reset line
  signal int_reset : std_logic;         --! Initial reset line
  signal rst_out : std_logic;           --! Reset line output to PDP-8
  
begin

  swOPT.KE8       <= '1'; 
  swOPT.KM8E      <= '1';
  swOPT.TSD       <= '1';
  swOPT.STARTUP   <= '1'; -- Setting the 'STARTUP' bit will cause the PDP8 to boot
  -- to the address in the switch register

  int_reset <= '0';
	
  ----------------------------------------------------------------------------
  --  RESET signal generator.
  ----------------------------------------------------------------------------
  process(sys_clk_pad_i)
  begin
    if(rising_edge(sys_clk_pad_i)) then
      dly <= ( not(int_reset) and     dly  and not(rst) )
             or ( not(int_reset) and not(dly) and     rst  );
      rst  <= ( not(int_reset) and not(dly) and not(rst) );
    end if;
  end process;
  
  rst_out <= rst xor invert_reset ;

  --
  -- Front Panel Data Switches
  --

  swDATA          <= o"0023";  

  ----------------------------------------------------------------------------
  -- PDP8 Processor
  ---------------------------------------------------------------------------    
  iPDP8 : entity work.ePDP8 (rtl) port map (
    -- System
    clk      => sys_clk_pad_i,              --! 50 MHz Clock
    rst      => rst_out,                    --! Reset Button
    -- CPU Configuration
    swCPU    => swPDP8A,                    --! CPU Configured to emulate PDP8A
    swOPT    => swOPT,                      --! Enable Options
    -- Real Time Clock Configuration
    swRTC    => clkDK8EC2,                  --! RTC 50 Hz interrupt
    -- TTY1 Interfaces
    tty1BR   => uartBR9600,                 --! TTY1 is 9600 Baud
    tty1HS   => uartHSnone,                 --! TTY1 has no flow control
    tty1CTS  => '1',                        --! TTY1 doesn't need CTS
    tty1RTS  => open,                       --! TTY1 doesn't need RTS
    tty1RXD  => uart0_srx_pad_i,            --! TTY1 RXD (to RS-232 interface)
    tty1TXD  => uart0_stx_pad_o,            --! TTY1 TXD (to RS-232 interface)
    -- TTY2 Interfaces
    tty2BR   => uartBR9600,                 --! TTY2 is 9600 Baud
    tty2HS   => uartHSnone,                 --! TTY2 has no flow control
    tty2CTS  => '1',                        --! TTY2 doesn't need CTS
    tty2RTS  => open,                       --! TTY2 doesn't need RTS
    tty2RXD  => '1',                        --! TTY2 RXD (tied off)
    tty2TXD  => open,                       --! TTY2 TXD (tied off)
    -- LPR Interface
    lprBR    => uartBR9600,                 --! LPR is 9600 Baud
    lprHS    => uartHSnone,                 --! LPR has no flow control
    lprDTR   => '1',                        --! LPR doesn't need DTR
    lprDSR   => open,                       --! LPR doesn't need DSR
    lprRXD   => '1',                        --! LPR RXD (tied off)
    lprTXD   => open,                       --! LPR TXD (tied off)
    -- Paper Tape Reader Interface
    ptrBR    => uartBR9600,                 --! PTR is 9600 Baud
    ptrHS    => uartHSnone,                 --! PTR has no flow control
    ptrCTS   => '1',                        --! PTR doesn't need CTS
    ptrRTS   => open,                       --! PTR doesn't need RTS
    ptrRXD   => '1',                        --! PTR RXD (tied off)
    ptrTXD   => open,                       --! PTR TXD (tied off)
    -- Secure Digital Disk Interface
    sdCD     => '0',                        --! SD Card Detect
    sdWP     => '0',                        --! SD Write Protect
    sdMISO   => spi0_miso_i,                --! SD Data In
    sdMOSI   => spi0_mosi_o,                --! SD Data Out
    sdSCLK   => spi0_sck_o,                 --! SD Clock
    sdCS     => spi0_ss_o,                  --! SD Chip Select
    -- Status
    rk8eSTAT => rk8eSTAT,                   --! Disk Status (Ignore)
    -- Switches and LEDS
    swROT    => swROT,                      --! Data LEDS display PC
    swDATA   => swDATA,                     --! RK8E Boot Loader Address
    swCNTL   => swCNTL,                     --! Switches
    ledRUN   => open,                       --! Run LED
    ledDATA  => open,                       --! Data output register
    ledADDR  => open                        --! Address output register
  );

end a;
 

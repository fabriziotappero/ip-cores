--!
--! DE2-115 PDP-8 Processor
--!
--! \brief
--!      PDP-8 implementation for the DE2-115 board
--!
--! \details
--!     Switch 17 - Single step
--!     Switch 16 - Halt
--!     Switches 11 to 0 - Front panel data switches
--!     Key 2 - Address load
--!     Key 1 - Continue
--!     Key 0 - Front panel rotator switch (press to "rotate")
--!     Hex 3 to 0 - Data register
--!     Red LEDs 14 to 0 - Address register
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
use work.rk05_types.all;                        --! RK05 Types
use work.ls8e_types.all;                        --! LS8E Types
use work.pr8e_types.all;                        --! PR8E Types
use work.cpu_types.all;                         --! CPU Types
use work.sd_types.all;                          --! SD Types
use work.sdspi_types.all;                       --! SPI Types

ENTITY pdp8_top IS
  generic(
    invert_reset : std_logic := '0' -- 0 : not invert, 1 invert
    );
  
  PORT ( 
    SW : IN STD_LOGIC_VECTOR(17 DOWNTO 0) := (others => 'Z');    --! Toggle switches
    KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => 'Z');    --! Push buttons
    CLOCK_50 : IN STD_LOGIC;                                     --! Input clock
    LEDG : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => 'Z');  --! Output green LEDs
    LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 0) := (others => 'Z'); --! Output red LEDs
    SD_CLK : OUT STD_LOGIC;                                      --! SD card clock
    SD_CMD : OUT STD_LOGIC;                                      --! SD card master out slave in
    SD_DAT0 : IN STD_LOGIC;                                      --! SD card master in slave out
    SD_DAT3 : OUT STD_LOGIC;                                     --! SD card chip select
    UART_RXD : IN STD_LOGIC;                                     --! UART receive line
    UART_TXD : OUT STD_LOGIC;                                    --! UART send line
    HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (others => 'Z');  --! 7 segment display 0
    HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (others => 'Z');  --! 7 segment display 1
    HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (others => 'Z');  --! 7 segment display 2
    HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (others => 'Z')   --! 7 segment display 3
    );
END pdp8_top;

architecture rtl of pdp8_top is
  signal rk8eSTAT : rk8eSTAT_t;
  signal ledDATA : std_logic_vector(11 downto 0) := (others => 'Z'); --! Output data register
  signal swCNTL : swCNTL_t := (others => '0');                       --! Front Panel Control Switches
  signal swROT : swROT_t := dispPC;                                  --! Front panel rotator switch
  signal swOPT  : swOPT_t;                                           --! PDP-8 options
  
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
  process(CLOCK_50)
  begin
    if(rising_edge(CLOCK_50)) then
      dly <= ( not(int_reset) and     dly  and not(rst) )
             or ( not(int_reset) and not(dly) and     rst  );
      rst <= ( not(int_reset) and not(dly) and not(rst) );
    end if;
  end process;

  rst_out <= rst xor invert_reset ;

  ----------------------------------------------------------------------------
  -- Display toggle switch (stand in for rotator switch)
  ---------------------------------------------------------------------------  
  toggle_switch : process(CLOCK_50)
  begin
    if rising_edge(KEY(0)) then
      swROT <= swROT + 1;
    end if;
  end process toggle_switch;

  ----------------------------------------------------------------------------
  -- Process that converts address into hex for the 7 segment displays
  ---------------------------------------------------------------------------  
  displaystate : process (CLOCK_50)
  begin
    if rising_edge(CLOCK_50) then

      case ledDATA(11 downto 9) is
        when O"0" => HEX3 <= "1000000";
        when O"1" => HEX3 <= "1111001";
        when O"2" => HEX3 <= "0100100";
        when O"3" => HEX3 <= "0110000";
        when O"4" => HEX3 <= "0011001";
        when O"5" => HEX3 <= "0010010";
        when O"6" => HEX3 <= "0000010";
        when O"7" => HEX3 <= "1111000";
        when others => null;
      end case;

      case ledDATA(8 downto 6) is
        when O"0" => HEX2 <= "1000000";
        when O"1" => HEX2 <= "1111001";
        when O"2" => HEX2 <= "0100100";
        when O"3" => HEX2 <= "0110000";
        when O"4" => HEX2 <= "0011001";
        when O"5" => HEX2 <= "0010010";
        when O"6" => HEX2 <= "0000010";
        when O"7" => HEX2 <= "1111000";
        when others => null;
      end case;

      case ledDATA(5 downto 3) is
        when O"0" => HEX1 <= "1000000";
        when O"1" => HEX1 <= "1111001";
        when O"2" => HEX1 <= "0100100";
        when O"3" => HEX1 <= "0110000";
        when O"4" => HEX1 <= "0011001";
        when O"5" => HEX1 <= "0010010";
        when O"6" => HEX1 <= "0000010";
        when O"7" => HEX1 <= "1111000";
        when others => null;
      end case;

      case ledDATA(2 downto 0) is
        when O"0" => HEX0 <= "1000000";
        when O"1" => HEX0 <= "1111001";
        when O"2" => HEX0 <= "0100100";
        when O"3" => HEX0 <= "0110000";
        when O"4" => HEX0 <= "0011001";
        when O"5" => HEX0 <= "0010010";
        when O"6" => HEX0 <= "0000010";
        when O"7" => HEX0 <= "1111000";
        when others => null;
      end case;
      
    end if;
  end process displaystate;

  swCNTL.step <= SW(17);                -- Single step switch
  swCNTL.halt <= SW(16);                -- Halt switch
  swCNTL.loadADDR <= KEY(2);            -- Address load momentary switch
  swCNTL.cont <= KEY(1);                -- Continue momentary switch

  ----------------------------------------------------------------------------
  -- PDP8 Processor
  ---------------------------------------------------------------------------    
  iPDP8 : entity work.ePDP8 (rtl) port map (
    -- System
    clk      => CLOCK_50,                   --! 50 MHz Clock
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
    tty1RXD  => UART_RXD,                   --! TTY1 RXD (to RS-232 interface)
    tty1TXD  => UART_TXD,                   --! TTY1 TXD (to RS-232 interface)
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
    sdMISO   => SD_DAT0,                    --! SD Data In
    sdMOSI   => SD_CMD,                     --! SD Data Out
    sdSCLK   => SD_CLK,                     --! SD Clock
    sdCS     => SD_DAT3,                    --! SD Chip Select
    -- Status
    rk8eSTAT => rk8eSTAT,                   --! Disk Status (Ignore)
    -- Switches and LEDS
    swROT    => swROT,                      --! Data LEDS display PC
    swDATA   => SW(11 DOWNTO 0),            --! RK8E Boot Loader Address
    swCNTL   => swCNTL,                     --! Switches
    ledRUN => LEDR(17),                     --! Run LED
    ledDATA => ledDATA,                     --! Data output register
    ledADDR => LEDR(14 downto 0)            --! Address output register
    );

end rtl;

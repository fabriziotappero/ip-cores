--!
--! DE0-Nano PDP-8 Processor
--!
--! \brief
--!      PDP-8 implementation for the DE0-Nano board
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
use work.rk05_types.all;                        --! RK05 Types
use work.ls8e_types.all;                        --! LS8E Types
use work.pr8e_types.all;                        --! PR8E Types
use work.cpu_types.all;                         --! CPU Types
use work.sd_types.all;                          --! SD Types
use work.sdspi_types.all;                       --! SPI Types
use work.oct_7seg;

ENTITY pdp8_top IS
  generic(
    invert_reset : std_logic := '0' -- 0 : not invert, 1 invert
    );
  
  PORT ( 
    SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => 'Z');     --! Toggle switches
    KEY : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => 'Z');    --! Push buttons
    CLOCK_50 : IN STD_LOGIC;                                     --! Input clock
    LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => 'Z');   --! Output green LEDs
	 
	 TTY1_TXD : OUT STD_LOGIC;                                    --! UART send line
	 TTY1_RXD : IN STD_LOGIC;                                     --! UART receive line
	 TTY2_TXD : OUT STD_LOGIC;                                    --! UART send line
	 TTY2_RXD : IN STD_LOGIC;                                     --! UART receive line	 
	 LPR_TXD : OUT STD_LOGIC;                                     --! LPR send line
	 LPR_RXD : IN STD_LOGIC;                                      --! LPR receive line
	 LPR_CTS : IN STD_LOGIC;
	 LPR_RTS : OUT STD_LOGIC;
	 PTR_TXD : OUT STD_LOGIC;
	 PTR_RXD : IN STD_LOGIC;
	 PTR_CTS : IN STD_LOGIC;
	 PTR_RTS : OUT STD_LOGIC;
	 USB_CLK_12MHZ : OUT STD_LOGIC; -- FIXME
	 RESET : OUT STD_LOGIC;
	 fpMISO : IN STD_LOGIC;
	 fpMOSI : OUT STD_LOGIC;
	 fpFS : OUT STD_LOGIC;
	 fpSCLK : OUT STD_LOGIC;
	 
	 swLOCK : IN STD_LOGIC;
	 swCONT : IN STD_LOGIC;
	 swBOOT : IN STD_LOGIC;
	 swEXAM : IN STD_LOGIC;
	 swLDADDR : IN STD_LOGIC;
	 swHALT : IN STD_LOGIC;
	 swLDEXTD : IN STD_LOGIC;
	 swSTEP : IN STD_LOGIC;
	 swD0 : IN STD_LOGIC;
	 swDEP : IN STD_LOGIC; 
	 swD1 : IN STD_LOGIC;
	 swROT0 : IN STD_LOGIC;
	 swD2 : IN STD_LOGIC;
	 swROT1 : IN STD_LOGIC;
	 swD3 : IN STD_LOGIC;
	 swROT2 : IN STD_LOGIC;
	 swD4 : IN STD_LOGIC;
	 swROT3 : IN STD_LOGIC;
	 swD5 : IN STD_LOGIC;
	 swROT4 : IN STD_LOGIC;
	 swD6 : IN STD_LOGIC;
	 swROT5 : IN STD_LOGIC;
	 swD7 : IN STD_LOGIC;
	 swROT6 : IN STD_LOGIC;
	 swROT7 : IN STD_LOGIC;
	 sdCS : OUT STD_LOGIC; --! SD card chip select
	 swD8 : IN STD_LOGIC;
	 sdCLK : OUT STD_LOGIC; --! SD card clock
	 swD9 : IN STD_LOGIC;
	 sdDI : OUT STD_LOGIC; --! SD card master out slave in
	 swD10 : IN STD_LOGIC;
	 sdDO : IN STD_LOGIC; --! SD card master in slave out
	 swD11 : IN STD_LOGIC;
	 sdCD: IN STD_LOGIC;
	 swCLEAR : IN STD_LOGIC;
	 swWP : IN STD_LOGIC

    );
END pdp8_top;

 architecture rtl of pdp8_top is
  signal rk8eSTAT : rk8eSTAT_t;
  signal swCNTL : swCNTL_t := (others => '0');                       --! Front Panel Control Switches
  signal swROT : swROT_t := dispIR;                                  --! Front panel rotator switch
  signal swOPT  : swOPT_t;                                           --! PDP-8 options\
  signal swDATA : swDATA_t;             --! Front panel switches  
  signal ledDATA : data_t;
  
  signal dly: std_logic := '0';         --! Delay used for reset logic
  signal rst: std_logic := '0';         --! Internal reset line
  signal int_reset : std_logic;         --! Initial reset line
  signal rst_out : std_logic;           --! Reset line output to PDP-8
  
  constant max_count : natural := 24000;
  signal op : std_logic;
  
  type display_type is (S0, S1, S2, S3, S4, S5);
  signal state: display_type := S0;   
  signal i : integer range 0 to 32 := 0;
  --signal i : std_logic_vector(7 downto 0) := (others => '0');
  signal data7 : std_logic_vector(31 downto 0); -- := X"fa00fa00"; -- (others => '0');
  

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
  
  --
  -- Front Panel Data Switches
  --

  swDATA          <= o"0023";   
  --swDATA          <= o"7400";   
  
    compteur : process(CLOCK_50, rst_out)
        variable count : natural range 0 to max_count := 0;
    begin
			if rising_edge(CLOCK_50) then
            if count < max_count/2 then
                op    <='1';
                count := count + 1;
            elsif count < max_count then
                op    <='0';
                count := count + 1;
            else
                count := 0;
                op    <='1';
            end if;
        end if;
    end process compteur;   
	 
	 	--	LED(6) <= op;

  ----------------------------------------------------------------------------
  -- Display toggle switch (stand in for rotator switch)
  ---------------------------------------------------------------------------  
  toggle_switch : process(CLOCK_50)
  begin
    if rising_edge(KEY(0)) then
      swROT <= swROT + 1;
    end if;
  end process toggle_switch;
  

  display : process(CLOCK_50)
  begin
 
	if rising_edge(CLOCK_50) then
 
		if op = '1'
		then
			state <= S1;
			i <= 0;
			RESET <= '1';
		end if;
		
--		if state = S0
--		then
--			LED(1) <= '1';
--			LED(2) <= '1';
--			LED(3) <= '1';
--			LED(4) <= '1';
--			LED(5) <= '1';
--		end if;
			
		if state = S1
		then
			fpFS <= '0';
			state <= S2;
			
--			LED(1) <= '1';
--			LED(2) <= '0';
--			LED(3) <= '0';
--			LED(4) <= '0';
--			LED(5) <= '0';
		end if;
			
		if state = S2
		then
--			LED(1) <= '0';
--			LED(2) <= '1';
--			LED(3) <= '0';
--			LED(4) <= '0';
--			LED(5) <= '0';

			if i = 32
			then
				state <= S5;
			else
				fpSCLK <= '0';
				state <= S3;
			end if;
		end if;
			
		if state = S3
		then
			fpMOSI <= data7(31 - i);
			i <= i + 1;
			state <= S4;

--			LED(1) <= '0';
--			LED(2) <= '0';
--			LED(3) <= '1';
--			LED(4) <= '0';
--			LED(5) <= '0';
		end if;
			
		if state = S4
		then
			fpSCLK <= '1';
			state <= S2;

--			LED(1) <= '0';
--			LED(2) <= '0';
--			LED(3) <= '0';
--			LED(4) <= '1';
--			LED(5) <= '0';
		end if;
			
		if state = S5
		then
			fpFS <= '1';
			state <= S0;

--			LED(1) <= '0';
--			LED(2) <= '0';
--			LED(3) <= '0';
--			LED(4) <= '0';
--			LED(5) <= '1';
		end if;
	end if;
	
end process display;

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
    tty1RXD  => TTY1_RXD,                   --! TTY1 RXD (to RS-232 interface)
    tty1TXD  => TTY1_TXD,                   --! TTY1 TXD (to RS-232 interface)
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
    sdMISO   => sdDO,                       --! SD Data In
    sdMOSI   => sdDI,                       --! SD Data Out
    sdSCLK   => sdCLK,                      --! SD Clock
    sdCS     => sdCS,                       --! SD Chip Select
    -- Status
    rk8eSTAT => rk8eSTAT,                   --! Disk Status (Ignore)
    -- Switches and LEDS
    swROT    => swROT,                      --! Data LEDS display PC
    swDATA   => swDATA,                     --! RK8E Boot Loader Address
    swCNTL   => swCNTL,                     --! Switches
    ledRUN => LED(7),                       --! Run LED
    ledDATA => ledDATA,                        --! Data output register
    ledADDR => open                         --! Address output register
    );
	 
	 --data7(7 downto 0) <= rk8eSTAT.sdSTAT.state;
	 --data7(15 downto 8) <= rk8eSTAT.sdSTAT.err;
	 --data7(23 downto 16) <= rk8eSTAT.sdSTAT.val;
	 --data7(31 downto 24) <= rk8eSTAT.sdSTAT.debug;
	 
--	 digit1 : entity hex_7seg port map (
--		CLOCK_50 => CLOCK_50,
--		hex_digit => rk8eSTAT.sdSTAT.debug(4 to 7),
--		seg => data7(13 downto 7)
--	 );
--	 
--	 digit2 : entity hex_7seg port map (
--		CLOCK_50 => CLOCK_50,
--		hex_digit => rk8eSTAT.sdSTAT.debug(0 to 3),
--		seg => data7(6 downto 0)
--	 );
--	 
--	 digit3 : entity hex_7seg port map (
--		CLOCK_50 => CLOCK_50,
--		hex_digit => rk8eSTAT.sdSTAT.err(4 to 7),
--		seg => data7(20 downto 14)
--	 );
--	 
--	 digit4 : entity hex_7seg port map (
--		CLOCK_50 => CLOCK_50,
--		hex_digit => rk8eSTAT.sdSTAT.err(0 to 3),
--		seg => data7(27 downto 21)
--	 );
	 

--	 digit3 : entity oct_7seg port map (
--		CLOCK_50 => CLOCK_50,
--		oct_digit => ledDATA(3 to 5),
--		seg => data7(13 downto 7)
--	 );
--
--	 digit4 : entity oct_7seg port map (
--		CLOCK_50 => CLOCK_50,
--		oct_digit => ledDATA(0 to 2),
--		seg => data7(6 downto 0)
--	 );	 	 

	 digit1 : entity oct_7seg port map (
		CLOCK_50 => CLOCK_50,
		oct_digit => ledDATA(9 to 11),
		seg => data7(27 downto 21)
	 );
	 
	 digit2 : entity oct_7seg port map (
		CLOCK_50 => CLOCK_50,
		oct_digit => ledDATA(6 to 8),
		seg => data7(20 downto 14)
	 );

	 digit3 : entity oct_7seg port map (
		CLOCK_50 => CLOCK_50,
		oct_digit => ledDATA(3 to 5),
		seg => data7(13 downto 7)
	 );

	 digit4 : entity oct_7seg port map (
		CLOCK_50 => CLOCK_50,
		oct_digit => ledDATA(0 to 2),
		seg => data7(6 downto 0)
	 );	 

end rtl;

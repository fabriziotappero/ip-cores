--##############################################################################
-- ION MIPS-compatible CPU demo on Terasic DE-1 Cyclone-II starter board
--##############################################################################
-- This module is little more than a wrapper around the SoC.
--------------------------------------------------------------------------------
-- Switch 9 (leftmost) is used as reset.
--------------------------------------------------------------------------------
-- NOTE: See note at bottom of file about optional use of PLL.
--##############################################################################
-- Copyright (C) 2011 Jose A. Ruiz
--                                                              
-- This source file may be used and distributed without         
-- restriction provided that this copyright statement is not    
-- removed from the file and that any derivative work contains  
-- the original copyright notice and the associated disclaimer. 
--                                                              
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--                                                              
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--                                                              
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.opencores.org/lgpl.shtml
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.mips_pkg.all; -- Only needed if port debug_info is not OPEN
use work.obj_code_pkg.all;

-- FPGA i/o for Terasic DE-1 board
-- (Many of the board's i/o devices will go unused in this demo)
entity c2sb_demo is
    port (
        -- ***** Clocks
        clk_50MHz     : in std_logic;
        clk_27MHz     : in std_logic;

        -- ***** Flash 4MB
        flash_addr    : out std_logic_vector(21 downto 0);
        flash_data    : in std_logic_vector(7 downto 0);
        flash_oe_n    : out std_logic;
        flash_we_n    : out std_logic;
        flash_reset_n : out std_logic;

        -- ***** SRAM 256K x 16
        sram_addr     : out std_logic_vector(17 downto 0);
        sram_data     : inout std_logic_vector(15 downto 0);
        sram_oe_n     : out std_logic;
        sram_ub_n     : out std_logic;
        sram_lb_n     : out std_logic;
        sram_ce_n     : out std_logic;
        sram_we_n     : out std_logic;

        -- ***** RS-232
        rxd           : in std_logic;
        txd           : out std_logic;

        -- ***** Switches and buttons
        switches      : in std_logic_vector(9 downto 0);
        buttons       : in std_logic_vector(3 downto 0);

        -- ***** Quad 7-seg displays
        hex0          : out std_logic_vector(0 to 6);
        hex1          : out std_logic_vector(0 to 6);
        hex2          : out std_logic_vector(0 to 6);
        hex3          : out std_logic_vector(0 to 6);

        -- ***** Leds
        red_leds      : out std_logic_vector(9 downto 0);
        green_leds    : out std_logic_vector(7 downto 0);

        -- ***** SD Card
        sd_data       : in  std_logic;
        sd_cs         : out std_logic;
        sd_cmd        : out std_logic;
        sd_clk        : out std_logic
    );
end c2sb_demo;

architecture minimal of c2sb_demo is


--##############################################################################
-- Parameters

-- Address size (FIXME: not tested with other values)
constant SRAM_ADDR_SIZE : integer := 32;

-- Clock rate selection (affects UART configuration)
-- Acceptable values: {27000000, 50000000, 45000000(pll config)}
constant CLOCK_FREQ : integer := 50000000;

--##############################################################################
-- RS232 interface signals

signal rx_rdy :             std_logic;
signal tx_rdy :             std_logic;
signal rs232_data_rx :      std_logic_vector(7 downto 0);
signal rs232_status :       std_logic_vector(7 downto 0);
signal data_io_out :        std_logic_vector(7 downto 0);
signal io_port :            std_logic_vector(7 downto 0);
signal read_rx :            std_logic;
signal write_tx :           std_logic;


--##############################################################################
-- I/O registers


signal p0_out :             std_logic_vector(31 downto 0);
signal p1_in :              std_logic_vector(31 downto 0);

signal sd_clk_reg :         std_logic;
signal sd_cs_reg :          std_logic;
signal sd_cmd_reg :         std_logic;
signal sd_do_reg :          std_logic;


-- CPU access to hex display
signal reg_display :        std_logic_vector(15 downto 0);


--##############################################################################
-- DE-1 board interface signals

-- Synchronization FF chain for asynchronous reset input
signal reset_sync :         std_logic_vector(3 downto 0);

-- Reset pushbutton debouncing logic
subtype t_debouncer is natural range 0 to CLOCK_FREQ*4;
constant DEBOUNCING_DELAY : t_debouncer := 1500;
signal debouncing_counter : t_debouncer := (CLOCK_FREQ/1000) * DEBOUNCING_DELAY;

-- Quad 7-segment display (non multiplexed) & LEDS
signal display_data :       std_logic_vector(15 downto 0);
signal reg_gleds :          std_logic_vector(7 downto 0);

-- Clock & reset signals
signal clk_1hz :            std_logic;
signal clk_master :         std_logic;
signal counter_1hz :        std_logic_vector(25 downto 0);
signal reset :              std_logic;
-- Master clock signal
signal clk :                std_logic;
-- Clock from PLL, is a PLL is used
signal clk_pll :            std_logic;
-- '1' when PLL is locked or when no PLL is used
signal pll_locked :         std_logic;

-- Altera PLL component declaration (in case it's used)
-- Note that the MegaWizard component needs to be called 'pll' or the component
-- name should be changed in this file.
--component pll
--    port (
--        areset      : in std_logic  := '0';
--        inclk0      : in std_logic  := '0';
--        c0          : out std_logic ;
--        locked      : out std_logic
--    );
--end component;

-- MPU interface signals
signal data_uart :          std_logic_vector(31 downto 0);
signal data_uart_status :   std_logic_vector(31 downto 0);
signal uart_tx_rdy :        std_logic := '1';
signal uart_rx_rdy :        std_logic := '1';

--signal io_rd_data :         std_logic_vector(31 downto 0);
--signal io_rd_addr :         std_logic_vector(31 downto 2);
--signal io_wr_addr :         std_logic_vector(31 downto 2);
--signal io_wr_data :         std_logic_vector(31 downto 0);
--signal io_rd_vma :          std_logic;
--signal io_byte_we :         std_logic_vector(3 downto 0);

signal mpu_sram_address :   std_logic_vector(SRAM_ADDR_SIZE-1 downto 0);
signal mpu_sram_data_rd :   std_logic_vector(15 downto 0);
signal mpu_sram_data_wr :   std_logic_vector(15 downto 0);
signal mpu_sram_byte_we_n : std_logic_vector(1 downto 0);
signal mpu_sram_oe_n :      std_logic;

signal debug_info :         t_debug_info;

-- Converts hex nibble to 7-segment
-- Segments ordered as "GFEDCBA"; '0' is ON, '1' is OFF
function nibble_to_7seg(nibble : std_logic_vector(3 downto 0))
                        return std_logic_vector is
begin
    case nibble is
    when X"0"       => return "0000001";
    when X"1"       => return "1001111";
    when X"2"       => return "0010010";
    when X"3"       => return "0000110";
    when X"4"       => return "1001100";
    when X"5"       => return "0100100";
    when X"6"       => return "0100000";
    when X"7"       => return "0001111";
    when X"8"       => return "0000000";
    when X"9"       => return "0000100";
    when X"a"       => return "0001000";
    when X"b"       => return "1100000";
    when X"c"       => return "0110001";
    when X"d"       => return "1000010";
    when X"e"       => return "0110000";
    when X"f"       => return "0111000";
    when others     => return "0111111"; -- can't happen
    end case;
end function nibble_to_7seg;


begin

    mpu: entity work.mips_soc
    generic map (
        OBJECT_CODE    => obj_code,
        BOOT_BRAM_SIZE => work.obj_code_pkg.BRAM_SIZE,
        CLOCK_FREQ     => CLOCK_FREQ,
        SRAM_ADDR_SIZE => SRAM_ADDR_SIZE
    )
    port map (
        interrupt   => "00000000",

        -- interface to off-SoC, on-FPGA i/o devices: UNUSED
        io_rd_data  => X"00000000",
        io_rd_addr  => OPEN,
        io_wr_addr  => OPEN,
        io_wr_data  => OPEN,
        io_rd_vma   => OPEN,
        io_byte_we  => OPEN,

        -- interface to asynchronous 16-bit-wide EXTERNAL SRAM
        sram_address    => mpu_sram_address,
        sram_data_rd    => mpu_sram_data_rd,
        sram_data_wr    => mpu_sram_data_wr,
        sram_byte_we_n  => mpu_sram_byte_we_n,
        sram_oe_n       => mpu_sram_oe_n,

        uart_rxd    => rxd,
        uart_txd    => txd,

        p0_out      => p0_out,
        p1_in       => p1_in,
        
        debug_info  => debug_info,
        
        clk         => clk,
        reset       => reset
    );

    

--##############################################################################
-- GPIO and LEDs
--##############################################################################

---- LEDS -- We'll use the LEDs to display debug info --------------------------

-- HEX display is mostly unused
reg_display <= p0_out(31 downto 16);


-- Show the SD interface signals on the green leds for debug
reg_gleds <= p1_in(0) & "0000" & p0_out(2 downto 0);

-- Red leds (light with '1') -- some CPU control signals
red_leds(0) <= debug_info.cache_enabled;
red_leds(1) <= debug_info.unmapped_access;
red_leds(2) <= '0';
red_leds(3) <= '0';
red_leds(4) <= '0';
red_leds(5) <= '0';
red_leds(6) <= '0';
red_leds(7) <= '0';
red_leds(8) <= reset;
red_leds(9) <= clk_1hz;


--##############################################################################
-- terasIC Cyclone II STARTER KIT BOARD -- interface to on-board devices
--##############################################################################

--##############################################################################
-- FLASH (connected to the same mup bus as the sram)
--##############################################################################

flash_we_n <= '1'; -- all write control signals inactive
flash_reset_n <= '1';

flash_addr(21 downto 18) <= (others => '0');
flash_addr(17 downto  0) <= mpu_sram_address(17 downto 0); -- FIXME

-- Flash is decoded at 0xb0000000
flash_oe_n <= '0' 
    when mpu_sram_address(31 downto 27)="10110" and mpu_sram_oe_n='0'
    else '1';



--##############################################################################
-- SRAM
--##############################################################################

sram_addr <= mpu_sram_address(sram_addr'high+1 downto 1);
sram_oe_n <= '0'    
    when mpu_sram_address(31 downto 27)="00000" and mpu_sram_oe_n='0'
    else '1';

sram_ub_n <= mpu_sram_byte_we_n(1) and mpu_sram_oe_n;
sram_lb_n <= mpu_sram_byte_we_n(0) and mpu_sram_oe_n;
sram_ce_n <= '0';
sram_we_n <= mpu_sram_byte_we_n(1) and mpu_sram_byte_we_n(0);

sram_data <= mpu_sram_data_wr when mpu_sram_byte_we_n/="11" else (others => 'Z');

-- The only reason we need this mux is because we have the static RAM and the
-- static flash in separate FPGA pins, whereas in a real world application they
-- would be on the same data+address bus
mpu_sram_data_rd <= 
    -- SRAM is decoded at 0x00000000
    sram_data when mpu_sram_address(31 downto 27)="00000" else
    X"00" & flash_data;



--##############################################################################
-- RESET, CLOCK
--##############################################################################


-- This FF chain only prevents metastability trouble, it does not help with
-- switching bounces.
-- (NOTE: the anti-metastability logic is probably not needed when we include 
-- the debouncing logic)
reset_synchronization:
process(clk)
begin
    if clk'event and clk='1' then
        reset_sync(3) <= not switches(9);
        reset_sync(2) <= reset_sync(3);
        reset_sync(1) <= reset_sync(2);
        reset_sync(0) <= reset_sync(1);
    end if;
end process reset_synchronization;

reset_debouncing:
process(clk)
begin
    if clk'event and clk='1' then
        if reset_sync(0)='1' and reset_sync(1)='0' then
            debouncing_counter <= (CLOCK_FREQ/1000) * DEBOUNCING_DELAY;
        else
            if debouncing_counter /= 0 then
                debouncing_counter <= debouncing_counter - 1;
            end if;
        end if;
    end if;
end process reset_debouncing;

-- Reset will be active and glitch free for some serious time (1.5 s).
reset <= '1' when debouncing_counter /= 0 or pll_locked='0' else '0';

-- Generate a 1-Hz 'clock' to flash a LED for visual reference.
process(clk)
begin
  if clk'event and clk='1' then
    if reset = '1' then
      clk_1hz <= '0';
      counter_1hz <= (others => '0');
    else
      if conv_integer(counter_1hz) = CLOCK_FREQ-1 then
        counter_1hz <= (others => '0');
        clk_1hz <= not clk_1hz;
      else
        counter_1hz <= counter_1hz + 1;
      end if;
    end if;
  end if;
end process;

-- Master clock is external 50MHz or 27MHz oscillator

slow_clock:
if CLOCK_FREQ = 27000000 generate
clk <= clk_27MHz;
pll_locked <=  '1';
end generate;

fast_clock:
if CLOCK_FREQ = 50000000 generate
clk <= clk_50MHz;
pll_locked <=  '1';
end generate;

--pll_clock:
--if CLOCK_FREQ /= 27000000 and CLOCK_FREQ/=50000000 generate
---- Assume PLL black box is properly configured for whatever the clock rate is...
--input_clock_pll: component pll
--    port map(
--        areset  => '0',
--        inclk0  => clk_50MHz,
--        c0      => clk_pll,
--        locked  => pll_locked
--    );
--
--clk <= clk_pll;
--end generate;


--##############################################################################
-- LEDS, SWITCHES
--##############################################################################

-- Display the contents of a debug register at the green leds bar
green_leds <= reg_gleds;


--##############################################################################
-- QUAD 7-SEGMENT DISPLAYS
--##############################################################################

-- Show contents of debug register in hex display
display_data <= reg_display;
    

-- 7-segment encoders; the dev board displays are not multiplexed or encoded
hex3 <= nibble_to_7seg(display_data(15 downto 12));
hex2 <= nibble_to_7seg(display_data(11 downto  8));
hex1 <= nibble_to_7seg(display_data( 7 downto  4));
hex0 <= nibble_to_7seg(display_data( 3 downto  0));

--##############################################################################
-- SD card interface
--##############################################################################

-- Connect to FFs for use in bit-banged interface (still unused)
sd_cs       <= p0_out(0);       -- SPI CS
sd_cmd      <= p0_out(2);       -- SPI DI
sd_clk      <= p0_out(1);       -- SPI SCLK
p1_in(0)    <= sd_data;         -- SPI DO


--##############################################################################
-- SERIAL
--##############################################################################

--  Embedded in the MPU entity

end minimal;

--------------------------------------------------------------------------------
-- NOTE: Optional use of a PLL
-- 
-- In order to try the core with any clock other the 50 and 27MHz oscillators 
-- readily available onboard we need to use a PLL.
-- Unfortunately, Quartus-II won't let you just instantiate a PLL like ISE does.
-- Instead, you have to build a PLL module using the MegaWizard tool.
-- A nasty consequence of this is that the PLL can't be reconfigured without
-- rebuilding it with the MW tool, and a bunch of ugly binary files have to be 
-- committed to SVN if the project is to be complete.
-- When I figure up what files need to be committed to SVN I will. Meanwhile you
-- have to build the module yourself if you want to u se a PLL -- Sorry!
-- At least it is very straightforward -- create an ALTPLL variation (from the 
-- IO module library) named 'pll' with a 45MHz clock at output c0, that's it.
--
-- Please note that the system will run at >50MHz when using 'balanced' 
-- synthesis. Only the 'area optimized' synthesis may give you trouble.
--------------------------------------------------------------------------------

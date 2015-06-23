--##############################################################################
-- light52 MCU demo on DE-1 board
--##############################################################################
-- 
-- This is a minimal demo of the light52 core targetting Terasic's DE-1 
-- development board for Cyclone-2 FPGAs. 
-- Since the demo uses little board resources other than the serial port it 
-- should be easy to port it to other platforms.
-- This file is strictly for demonstration purposes and has not been tested.
--
-- This demo has been built from a generic template for designs targetting the
-- DE-1 development board. The entity defines all the inputs and outputs present
-- in the actual board, whether or not they are used in the design at hand.
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Package with utility functions for handling SoC object code.
use work.light52_pkg.all;
-- Package that contains the program object code in VHDL constant format.
use work.obj_code_pkg.all;


-- Define the entity outputs as they are connected in the DE-1 development 
-- board. Many of the outputs will be left unused in this demo.
entity c2sb_soc is
    port ( 
        -- ***** Clocks
        clk_50MHz     : in std_logic;

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
end c2sb_soc;

architecture minimal of c2sb_soc is

--##############################################################################
-- Some of these signals are 

-- light52 MCU signals ---------------------------------------------------------
signal p0_out :           std_logic_vector(7 downto 0);
signal p1_out :           std_logic_vector(7 downto 0);
signal p2_in :            std_logic_vector(7 downto 0);
signal p3_in :            std_logic_vector(7 downto 0);
signal external_irq :     std_logic_vector(7 downto 0);  
signal uart_txd :         std_logic;
signal uart_rxd :         std_logic;

-- Signals for external SRAM synchronization -----------------------------------
signal sram_data_out :    std_logic_vector(7 downto 0); -- sram output reg
signal sram_write :       std_logic; -- sram we register
signal address_reg :      std_logic_vector(15 downto 0); -- registered addr bus


--##############################################################################
-- On-board device interface signals 

-- Quad 7-segment display (non multiplexed) & LEDS -----------------------------
signal display_data :     std_logic_vector(15 downto 0);


-- Clock & reset signals -------------------------------------------------------
signal clk_1hz :          std_logic;
signal clk_master :       std_logic;
signal reset :            std_logic;
signal clk :              std_logic;
signal counter_1hz :      std_logic_vector(25 downto 0);

-- SD control signals ----------------------------------------------------------
-- SD connector unused, unconnected


--## Functions #################################################################

-- Converts hex nibble to 7-segment (sinthesizable).
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

  -- SOC instantiation 
  mcu: entity work.light52_mcu 
  generic map (
    -- Memory size is defined in package obj_code_pkg...
    CODE_ROM_SIZE => work.obj_code_pkg.XCODE_SIZE,
    XDATA_RAM_SIZE => work.obj_code_pkg.XDATA_SIZE,
    -- ...as is the object code initialization constant.
    OBJ_CODE => work.obj_code_pkg.object_code,
    -- Leave BCD opcodes disabled.
    IMPLEMENT_BCD_INSTRUCTIONS => false,
    -- UART baud rate isn't programmable in run time.
    UART_HARDWIRED => true,
    -- We're using the 50MHz clock of the DE-1 board.
    CLOCK_RATE => 50e6
  )
  port map (
    clk             => clk,
    reset           => reset,
        
    txd             => uart_txd,
    rxd             => uart_rxd,
    
    external_irq    => external_irq, 
    
    p0_out          => p0_out,
    p1_out          => p1_out,
    p2_in           => p2_in,
    p3_in           => p3_in
  );

  -- Input port P2 connected to switches for lack of better use...
  p2_in <= switches(7 downto 0);
  -- ...and input port P3 is connected to P0 for test purposes.
  p3_in <= p0_out; 

  -- External irq inputs tied to P1 for test purposes
  external_irq <= p0_out;
  
--##### Input ports ###########################################################


--##############################################################################
-- terasIC Cyclone II STARTER KIT BOARD
--##############################################################################

--##############################################################################
-- FLASH (flash is unused in this demo)
--##############################################################################

  flash_addr <= (others => '0');

  flash_we_n <= '1'; -- all enable signals inactive
  flash_oe_n <= '1';
  flash_reset_n <= '1';


--##############################################################################
-- SRAM (wired as 64K x 8)
-- The SRAM is unused in this demo.
--##############################################################################

  -- These registera make the external, asynchronous SRAM behave like an
  -- internal syncronous BRAM, except for the timing.
  -- Since the SoC has no wait state capability, the SoC clock rate must 
  -- accomodate the SRAM timing -- including FPGA clock-to-output, RAM delays 
  -- and FPGA input setup and hold times. Setting up the synthesis constraints
  -- is left to the user too.
  sram_registers:
  process(clk)
  begin
    if clk'event and clk='1' then
      if reset='1' then
        sram_addr <= "000000000000000000";
        address_reg <= "0000000000000000";
        sram_data_out <= X"00";
        sram_write <= '0';
      else
      end if;
    end if;
  end process sram_registers;

  sram_data(15 downto 8) <= "ZZZZZZZZ"; -- high byte unused
  sram_data(7 downto 0)  <= "ZZZZZZZZ" when sram_write='0' else sram_data_out;  
  -- (the X"ZZ" will physically be the read input data)

  -- sram access controlled by WE_N
  sram_oe_n <= '0'; 
  sram_ce_n <= '0'; 
  sram_we_n <= not sram_write;
  sram_ub_n <= '1'; -- always disable
  sram_lb_n <= '0';

  
--##############################################################################
-- RESET, CLOCK
--##############################################################################

  -- Use switch 9 as reset
  reset <= not switches(9);


  -- Generate a 1-Hz 'clock' to flash a LED for visual reference.
  process(clk_50MHz)
  begin
    if clk_50MHz'event and clk_50MHz='1' then
      if reset = '1' then
        clk_1hz <= '0';
        counter_1hz <= (others => '0');
      else
        if conv_integer(counter_1hz) = 50000000 then
          counter_1hz <= (others => '0');
          clk_1hz <= not clk_1hz;
        else
          counter_1hz <= counter_1hz + 1;
        end if;
      end if;
    end if;
  end process;

  -- Master clock is external 50MHz oscillator
  clk <= clk_50MHz;


--##############################################################################
-- LEDS, SWITCHES
--##############################################################################

  -- Display the contents of an output port at the green leds bar
  green_leds <= p0_out;

  -- Red leds unused except for 1-Hz clock
  red_leds(9 downto 1) <= (others => '0');
  red_leds(0) <= clk_1hz;

 
--##############################################################################
-- QUAD 7-SEGMENT DISPLAYS
--##############################################################################

  -- Display the contents of the output port at the hex displays.
  display_data <= p0_out & p1_out;

  -- 7-segment encoders; the dev board displays are not multiplexed or encoded
  hex3 <= nibble_to_7seg(display_data(15 downto 12));
  hex2 <= nibble_to_7seg(display_data(11 downto  8));
  hex1 <= nibble_to_7seg(display_data( 7 downto  4));
  hex0 <= nibble_to_7seg(display_data( 3 downto  0));

  
--##############################################################################
-- SD card interface
--##############################################################################

  -- SD card unused in this demo
  sd_cs     <= '0';
  sd_cmd    <= '0';
  sd_clk    <= '0';
  --sd_in     <= '0';


--##############################################################################
-- SERIAL
--##############################################################################

  -- Txd & rxd pins connected straight to the MCU core
  txd <= uart_txd;
  uart_rxd <= rxd;
  
  
end minimal;

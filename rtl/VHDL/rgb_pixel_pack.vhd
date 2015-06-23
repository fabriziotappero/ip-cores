--------------------------------------------------------------------------
-- Package of dds components
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package rgb_pixel_pack is

  component ws2812_LED_chain_driver
    generic (
      SYS_CLK_RATE : real; -- underlying clock rate
      ADR_BITS     : natural; -- Must equal or exceed BIT_WIDTH(N_LEDS)+2.
      N_LEDS       : natural  -- Number of LEDs in chain
    );
    port (

      -- System Clock, Reset and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- Selection of color information
      c_adr_o    : out unsigned(ADR_BITS-1 downto 0);
      c_dat_i    : in  unsigned(7 downto 0);

      -- Output
      sdat_o     : out std_logic
    );
  end component;

  component lpd8806_LED_chain_driver
    generic (
      SCLK_FREQ    : real;    -- Desired lpd8806 serial clock frequency
      UPDATE_FREQ  : real;    -- Desired LED chain update frequency
      SYS_CLK_RATE : real;    -- underlying clock rate
      N_LEDS       : integer  -- Number of LEDs in chain
    );
    port (

      -- System Clock, Reset and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- Selection of color information
      c_adr_o    : out unsigned(7 downto 0);
      c_dat_i    : in  unsigned(6 downto 0);

      -- Output
      sclk_o     : out std_logic;
      sdat_o     : out std_logic
    );
  end component;

  component spi_byte_writer
    generic (
      SCLK_FREQ    : real;    -- Desired lpd8806 serial clock frequency
      SYS_CLK_RATE : real     -- underlying clock rate
    );
    port (

      -- System Clock, Reset and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- Data to send.
      sel_i      : in  std_logic;
      we_i       : in  std_logic;
      dat_i      : in  unsigned(7 downto 0);

      -- Output
      ssel_o     : out std_logic;
      sclk_o     : out std_logic;
      sdat_o     : out std_logic
    );
  end component;

end rgb_pixel_pack;

package body rgb_pixel_pack is
end rgb_pixel_pack;

-------------------------------------------------------------------------------
-- WS2812 "GRB" LED chain driver module
-------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Update: Oct. 19, 2013 Started Coding, wrote description.
--
-- Description
-------------------------------------------------------------------------------
-- This module outputs a serial stream of NRZ data pulses which
-- are intended for driving a chain of WS2812 LED PWM driver ICs.
-- Actually, the WS2811 is the driver as a separate IC, and the WS2812 is
-- a complete RGB LED pixel with the driver built right in.  As costs drop
-- the popularity of this device is rising.
--
-- The datasheet seems to indicate some very specific timing requirements.
--
-- A '1' bit is apparently 0.35us high, followed by 0.8us low.
-- A '0' bit is apparently 0.7us high, followed by 0.6us low.
--
-- The datasheet also states that Th+Tl = 1.25us +/- 600 ns.
--
-- Well, based on that, this module chooses to use 1.25 microseconds
-- per bit time, which corresponds to 800kbps.  Internally, the system clock
-- rate is divided by 800000, and the result is the number of clock cycles
-- per bit available for creating the serial bitstream.
--
-- Then, constants are determined based on CLKS_PER_BIT according to the
-- following formulae:
--
--   CLKS_T0h = 0.28*CLKS_PER_BIT
--   CLKS_T1h = 0.54*CLKS_PER_BIT
--
-- This means that the timing will be closer or farther from ideal,
-- depending on the SYS_CLK_RATE.  For example:
--
--   Fsys_clk = 50 MHz
--   CLKS_PER_BIT = 62.5 which is rounded down to 62.
--   CLKS_T0h = 17.36 which is rounded down to 17.
--   CLKS_T1h = 33.48 which is rounded down to 33.
--   This leaves 45 clocks for the T0l time.
--   This leaves 29 clocks for the T1l time.
--
--   For this example, the bit time is 1.24us.
--   The T0h is 0.34us and T0l is 0.9us.
--   The T1h is 0.66us and T1l is 0.58us.
--
-- The lower the SYS_CLK_RATE, the tougher it is to meet the stated timing
-- requirements of the WS2812 device.  Using this scheme, the lowest clock
-- rate supported is 20 MHz.
--
-- The LEDs are driven with 24-bit color, that is 8 bits for red
-- intensity, 8 bits for green intensity and 8 bits for blue intensity.
--
-- I stopped short of calling it an "RGB LED driver" since WS2811/WS2812
-- receives the data in the order "GRB."  The ordering of the color
-- bits should not really matter anyway, so let's just be very accepting,
-- shall we not?
--
-- After the entire sequence of serial bits is driven out for updating the
-- GRB colors of the LEDs, then a reset interval of RESET_CLKS is given,
-- where RESET_CLKS is set by constants.
--
-- Interestingly, it seems that sending extra color information will not
-- affect the LED string in a negative way.  So, for example, if there
-- are only eight devices in the string, and the module is configured to
-- send out data for 10 devices, then the first eight devices will run
-- just fine.
--
-- Yes, that is correct, the LEDs closest to the source of sdat_o get lit
-- first, then they become "passthrough" so that the next one gets lit, and
-- so forth.
--
-- This module latches color information from an external source.
-- It provides the c_adr_o signal to specify which information
-- should be selected.  In this way, the module can be used with a variable
-- numbers of WS2811/WS2812 devices in the chain.
--
-- Just to keep things on an even keel, the c_adr_o address
-- advances according to the following pattern:
--
-- 0,1,2,4,5,6,8,9,A,C,D,E...
--
-- What is happening is that one address per LED is getting skipped
-- or "wasted" in order to start with each LEDs green value on an
-- even multiple N*4, where N is the LED number, beginning with zero
-- for the "zeroth" LED.  Then the red values are at N*4+1, while
-- the blue values are at N*4+2.  The N*4+3 values are simply skipped.
-- Isn't that super organized?
--
-- This unit runs continuously, the only way to stop it is to lower
-- the sys_clk_en input.
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

library work;
use work.dds_pack.all;
use work.convert_pack.all;

  entity ws2812_LED_chain_driver is
    generic (
      SYS_CLK_RATE : real := 50000000.0; -- underlying clock rate
      ADR_BITS     : natural := 8; -- Must equal or exceed BIT_WIDTH(N_LEDS)+2.
      N_LEDS       : natural := 8  -- Number of LEDs in chain
    );
    port (

      -- System Clock, Reset and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- Selection of color information
      c_adr_o    : out unsigned(ADR_BITS-1 downto 0);
      c_dat_i    : in  unsigned(7 downto 0);

      -- Output
      sdat_o     : out std_logic
    );
    end ws2812_LED_chain_driver;

architecture beh of ws2812_LED_chain_driver is

-- Constants
constant LED_BIT_RATE   : real := 800000.0;
constant CLKS_PER_BIT   : natural := integer(floor(SYS_CLK_RATE/LED_BIT_RATE));
constant CLKS_T0_H      : natural := integer(floor(0.28*SYS_CLK_RATE/LED_BIT_RATE));
constant CLKS_T1_H      : natural := integer(floor(0.54*SYS_CLK_RATE/LED_BIT_RATE));
constant SUB_COUNT_BITS : natural := bit_width(CLKS_PER_BIT);
constant STRING_BYTES   : natural := 3*N_LEDS;
constant RESET_TIME     : real := 0.000050; -- "time" data type could have been used...
constant RESET_BCOUNT   : natural := integer(floor(RESET_TIME*LED_BIT_RATE));
constant RESET_BITS     : natural := timer_width(RESET_BCOUNT);

-- Signals
signal reset_count : unsigned(RESET_BITS-1 downto 0);
signal sub_count   : unsigned(SUB_COUNT_BITS-1 downto 0);
signal bit_count   : unsigned(2 downto 0);
signal byte_count  : unsigned(bit_width(STRING_BYTES)-1 downto 0);
signal c_adr       : unsigned(ADR_BITS-1 downto 0);
signal c_dat       : unsigned(7 downto 0);

-----------------------------------------------------------------------------
begin

  c_adr_proc: Process(sys_rst_n,sys_clk)
  begin
    if (sys_rst_n = '0') then
      reset_count <= to_unsigned(RESET_BCOUNT,reset_count'length);
      sub_count  <= (others=>'0');
      byte_count <= (others=>'0');
      c_adr      <= (others=>'0');
      c_dat      <= (others=>'0');
      bit_count  <= (others=>'0');
    elsif (sys_clk'event and sys_clk='1') then
      if (sys_clk_en='1') then
        -- Sub count just keeps going all the time, during reset
        -- and during data transition.
        sub_count <= sub_count+1;
        if (sub_count=CLKS_PER_BIT-1) then
          sub_count <= (others=>'0');
        end if;

        -- Reset count decrements until reaching one, then
        -- it is set to zero while data is shifted out.
        -- It decrements once for each bit time.
        if (reset_count>0) then
          if (sub_count=CLKS_PER_BIT-1) then
            reset_count <= reset_count-1;
          end if;
        end if;

        -- When reset count reaches zero, color data shifting occurs
        if (reset_count>0) then
          c_adr <= (others=>'0');
          if (reset_count=1 and sub_count=CLKS_PER_BIT-1) then
            c_adr <= c_adr+1; -- Data from first address is loaded during reset time...
          end if;
          c_dat <= c_dat_i;
        else
          if (sub_count=CLKS_PER_BIT-1) then
            c_dat <= c_dat(c_dat'length-2 downto 0) & '0'; -- shift
            bit_count <= bit_count+1;
            if (bit_count=7) then
              c_dat <= c_dat_i;
              if (c_adr(1 downto 0)="10") then
                c_adr <= c_adr+2;
                if (byte_count=STRING_BYTES-1) then
                  byte_count <= (others=>'0');
                  reset_count <= to_unsigned(RESET_BCOUNT,reset_count'length);
                else
                  byte_count <= byte_count+1;
                end if;
              else
                c_adr <= c_adr+1;
              end if;
            end if;
          end if;
        end if;
      end if;
    end if; -- sys_clk
  end process;
  sdat_o <= '0' when (reset_count>0) else
            '1' when (c_dat(7)='1') and (sub_count<CLKS_T1_H) else
            '1' when (sub_count<CLKS_T0_H) else
            '0';
  c_adr_o <= c_adr;

end beh;


-------------------------------------------------------------------------------
-- LPD8806 "GRB" LED chain driver module
-------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Update: Apr.  8, 2013 Started Coding, wrote description.
--         Apr. 10, 2013 Simulated and tested in hardware.
--
-- Description
-------------------------------------------------------------------------------
-- This module outputs a serial stream of clock and data pulses which
-- are intended for driving a chain of LPD8806 LED PWM driver ICs.
--
-- This type of LED driver is commonly sold pre-built into strips
-- of LEDs, with each LPD8806 circuit driving two multi-color LEDs.
--
-- The LEDs are driven with 21-bit color, that is 7 bits for red
-- intensity, 7 bits for green intensity and 7 bits for blue intensity.
--
-- I stopped short of calling it an "RGB LED driver" since lpd8806
-- receives the data in the order "GRB."  The ordering of the color
-- bits should not really matter anyway, so just be happy, OK?
--
-- The first bit, the MSB, is set for updating the LED colors, and cleared
-- for resetting the drivers.  Therefore, after each sequence of color
-- information bits, about 24 bits of zero are sent out to reset
-- everything in order to be ready for the next update.
--
-- This module generates its own serial bit clock by using a DDS based
-- on the underlying system clock rate.  It has been suggested that
-- 2 MHz is a good number, although I'll bet many other speeds will
-- also work, both higher and lower.
--
-- Another DDS generates the update rate pulse, which kicks off
-- the updating process.  Beware, if one sets the update rate too
-- high, it may become impossible to transmit all the required color
-- bits, and so the LEDs at the end of the chain may get left out
-- of the process!
--
-- Yes, that is correct, the LEDs closest to the source of SCLK
-- and SDAT get lit first, then they become "passthrough" so that
-- the next one gets set, and so forth.
--
-- This module latches color information from an external source.
-- It provides the c_adr_o signal to specify which information
-- should be selected.  In this way, the module can be used with
-- different numbers of drivers and LED pairs in the strip.
--
-- Just to keep things on an even keel, the c_adr_o address
-- advances according to the following pattern:
--
-- 0,1,2,4,5,6,8,9,A,C,D,E...
--
-- What is happening is that one address per LED is getting skipped
-- or "wasted" in order to start with each LEDs green value on an
-- even multiple N*4, where N is the LED number, beginning with zero
-- for the "zeroth" LED.  Then the red values are at N*4+1, while
-- the blue values are at N*4+2.  The N*4+3 values are simply skipped.
-- Isn't that super organized?
--
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

library work;
use work.dds_pack.all;

  entity lpd8806_LED_chain_driver is
    generic (
      SCLK_FREQ    : real;    -- Desired lpd8806 serial clock frequency
      UPDATE_FREQ  : real;    -- Desired LED chain update frequency
      SYS_CLK_RATE : real;    -- underlying clock rate
      N_LEDS       : integer  -- Number of LEDs in chain
    );
    port (

      -- System Clock, Reset and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- Selection of color information
      c_adr_o    : out unsigned(7 downto 0);
      c_dat_i    : in  unsigned(6 downto 0);

      -- Output
      sclk_o     : out std_logic;
      sdat_o     : out std_logic
    );
    end lpd8806_LED_chain_driver;

architecture beh of lpd8806_LED_chain_driver is

-- Constants
constant N_ZERO_BYTES : natural := 3;

-- Signals
signal sclk            : std_logic;
signal sclk_pulse      : std_logic;
signal update_pulse    : std_logic;
signal bit_count       : unsigned(3 downto 0);
signal byte_count      : unsigned(7 downto 0); -- Widen for chains of 64+ LEDs.
signal c_adr           : unsigned(7 downto 0); -- Widen for chains of 64+ LEDs.
signal c_dat           : unsigned(7 downto 0);

-----------------------------------------------------------------------------
begin

  c_adr_proc: Process(sys_rst_n,sys_clk)
  begin
    if (sys_rst_n = '0') then
      byte_count <= (others=>'0');
      c_adr      <= (others=>'0');
      c_dat      <= (others=>'0');
      bit_count  <= (others=>'0');
    elsif (sys_clk'event and sys_clk='1') then
      if (sys_clk_en='1') then
        if (byte_count=0) then
          c_adr <= (others=>'0');
        end if;
        if (byte_count>0 and sclk_pulse='1') then
          bit_count <= bit_count-1;
          if (bit_count<8) then
            c_dat <= c_dat(6 downto 0) & '0'; -- Default is to shift color data
            if (bit_count=0) then
              byte_count <= byte_count-1;
              bit_count  <= to_unsigned(7,bit_count'length);
              -- Set color data MSB appropriately
              if (byte_count<=4) then
                c_dat <= (others=>'0');
              else
                c_dat <= '1' & c_dat_i;
              end if;
              -- Cause c_adr to skip every address.ending in "11"
              if (c_adr(1 downto 0)="10") then
                c_adr <= c_adr+2;
              else
                c_adr <= c_adr+1;
              end if;
            end if;
          end if;
        end if;
        -- Update pulse gets highest priority
        if (update_pulse='1') then
          byte_count <= to_unsigned(N_LEDS*3+1+N_ZERO_BYTES,byte_count'length);
          if (sclk_pulse='1') then
            bit_count  <= to_unsigned(7,bit_count'length);
          else
            bit_count  <= to_unsigned(8,bit_count'length); -- means "pending"
          end if;
          c_dat      <= '1' & c_dat_i;
          c_adr      <= c_adr+1;
        end if;
      end if;
    end if; -- sys_clk
  end process;
  sdat_o <= c_dat(7) when (byte_count>0 and bit_count<8) else '0';
  c_adr_o <= c_adr;

  -------------------------
  -- Update pulse generation
  update_gen: dds_constant_squarewave
    generic map(
      OUTPUT_FREQ  => UPDATE_FREQ,  -- Desired output frequency
      SYS_CLK_RATE => SYS_CLK_RATE, -- underlying clock rate
      ACC_BITS     => 24 -- Bit width of DDS phase accumulator
    )
    port map( 
       
      sys_rst_n    => sys_rst_n,
      sys_clk      => sys_clk,
      sys_clk_en   => sys_clk_en,

      -- Output
      pulse_o      => update_pulse,
      squarewave_o => open
    );

  -------------------------
  -- Serial clock generation
  sclk_gen: dds_constant_squarewave
    generic map(
      OUTPUT_FREQ  => SCLK_FREQ,   -- Desired output frequency
      SYS_CLK_RATE => SYS_CLK_RATE, -- underlying clock rate
      ACC_BITS     => 16 -- Bit width of DDS phase accumulator
    )
    port map( 
       
      sys_rst_n    => sys_rst_n,
      sys_clk      => sys_clk,
      sys_clk_en   => sys_clk_en,

      -- Output
      pulse_o      => sclk_pulse,
      squarewave_o => sclk
    );
  sclk_o <= not sclk when (byte_count>0 and bit_count<8) else '0';

end beh;


-------------------------------------------------------------------------------
-- SPI byte writer module
-------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Update: Apr.  8, 2013 Started Coding, wrote description.
--
-- Description
-------------------------------------------------------------------------------
-- I conceived of this module while debugging a serial driver for a
-- string of LPD8806 LED drivers.  It essentially latches the input
-- data, and sends it out serially at the desired rate.  When the byte
-- is fully transmitted, it stops and waits for the next byte.
--
-- The output clock is gated by ssel_o.  If you need a continuous
-- clock, please ungate it yourself.
--
-- Unlike with asynchronous data which shift out the lsb first, this
-- unit shifts out the msb first.
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

library work;
use work.dds_pack.all;

  entity spi_byte_writer is
    generic (
      SCLK_FREQ    : real;    -- Desired lpd8806 serial clock frequency
      SYS_CLK_RATE : real     -- underlying clock rate
    );
    port (

      -- System Clock, Reset and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- Data to send.
      sel_i      : in  std_logic;
      we_i       : in  std_logic;
      dat_i      : in  unsigned(7 downto 0);

      -- Output
      ssel_o     : out std_logic;
      sclk_o     : out std_logic;
      sdat_o     : out std_logic
    );
    end spi_byte_writer;

architecture beh of spi_byte_writer is

-- Signals
signal sclk            : std_logic;
signal sclk_pulse      : std_logic;
signal ssel            : std_logic;
signal sdat            : unsigned(7 downto 0);
signal bit_count       : unsigned(3 downto 0);

-----------------------------------------------------------------------------
begin

  spi_write_proc: Process(sys_rst_n,sys_clk)
  begin
    if (sys_rst_n = '0') then
      sdat      <= (others=>'0');
      bit_count <= (others=>'0');
    elsif (sys_clk'event and sys_clk='1') then
      if (sys_clk_en='1') then
        if (sclk_pulse='1') then
          if (bit_count>0) then
            bit_count <= bit_count-1;
          end if;
          if ssel='1' then
            sdat <= sdat(6 downto 0) & '0';
          end if;
        elsif (sel_i='1' and we_i='1') then
          if (sclk_pulse='1') then
            bit_count  <= to_unsigned(8,bit_count'length);
          else
            bit_count  <= to_unsigned(9,bit_count'length); -- means "pending"
          end if;
          sdat <= dat_i;
        end if;
      end if;
    end if; -- sys_clk
  end process;
  sdat_o <= sdat(7) when ssel='1' else '0';

  -------------------------
  -- Serial clock generation
  sclk_gen: dds_constant_squarewave
    generic map(
      OUTPUT_FREQ  => SCLK_FREQ,   -- Desired output frequency
      SYS_CLK_RATE => SYS_CLK_RATE, -- underlying clock rate
      ACC_BITS     => 16 -- Bit width of DDS phase accumulator
    )
    port map( 
       
      sys_rst_n    => sys_rst_n,
      sys_clk      => sys_clk,
      sys_clk_en   => sys_clk_en,

      -- Output
      pulse_o      => sclk_pulse,
      squarewave_o => sclk
    );
  sclk_o <= not sclk when ssel='1' else '0';
  ssel   <= '1'  when (bit_count<9 and bit_count>0) else '0';
  ssel_o <= ssel;

end beh;



--------------------------------------
-- LPD8806 RGB LED string driver FPGA
--------------------------------------
--
-- Capable of lighting up a string of
-- colorful LEDs with any desired
-- colors, at a specific update rate.
--
--------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;

library work;
use work.lpd8806_pack.all;
use work.convert_pack.all;

entity fpga is
  port (
    -- System Clock & Reset_n
    sys_clk      : in    std_logic; -- FPGA clock
    sys_rst_n    : in    std_logic;

    -- lpd8806 I/O
    rgb_led_clk  : out   std_logic;
    rgb_led_dat  : out   std_logic;

    -- Standardized Board Inputs / Outputs
    switch       : in    unsigned(7 downto 0);
    led          : out   unsigned(7 downto 0)

  );
end fpga;

architecture beh of fpga is
  -- Constants
  constant SYS_CLK_RATE    : real :=  25000000.0; -- The clock rate at which the FPGA runs

  --Component Declarations

  ----------------------------------------------------------------------------
  --Internal signal declarations

    -- Reset signals (can be asserted through syscon)
  signal fpga_rst_n        : std_logic;

  -----------------------------------------------
  -- Board Input & Output related

  signal switch_l         : unsigned(7 downto 0);

  -- Colorful Display related
  signal lpd8806_c_adr    : unsigned(7 downto 0);
  signal lpd8806_c_dat    : unsigned(6 downto 0);
  signal lpd8806_sclk     : std_logic;
  signal lpd8806_sdat     : std_logic;

  -- Test and Debug related
  signal spi_sclk         : std_logic;
  signal spi_sdat         : std_logic;

-------------------------------------------------
begin

  -- Invert switch inputs.  On this board, "switch on" is a low logic level.
  switch_l <= not (switch);

  -- System clock enable currently not used.
  sys_clk_en <= '1';

  -- Assign LED outputs.  These LEDs illuminate when driven low.
  led <= switch;

  ------------------------------
  -- Drive lpd8806 RGB LED string
  lpd8806_0 : lpd8806_LED_chain_driver
    generic map(
      SCLK_FREQ    => 2000000.0, -- Desired lpd8806 serial clock frequency
      UPDATE_FREQ  => 20.0,      -- Desired LED chain update frequency
      SYS_CLK_RATE => SYS_CLK_RATE,  -- underlying clock rate
      N_LEDS       => 8           -- Number of LEDs in chain
    )
    port map(

      -- System Clock, Reset and Clock Enable
      sys_rst_n   => sys_rst_n,
      sys_clk     => sys_clk,
      sys_clk_en  => sys_clk_en,

      -- Selection of color information
      c_adr_o     => lpd8806_c_adr,
      c_dat_i     => lpd8806_c_dat,

      -- Output
      sclk_o      => lpd8806_sclk,
      sdat_o      => lpd8806_sdat
    );

  with to_integer(lpd8806_c_adr) select
    lpd8806_c_dat <=
                             -- LED 0
      "1111111"            when 16#00#, -- Green
      "0000000"            when 16#01#, -- Red
      "0000000"            when 16#02#, -- Blue
                             -- LED 1
      "1111111"            when 16#04#, -- Green
      "1111111"            when 16#05#, -- Red
      "0000000"            when 16#06#, -- Blue
                             -- LED 2
      "0000000"            when 16#08#, -- Green
      "1111111"            when 16#09#, -- Red
      "0000000"            when 16#0A#, -- Blue
                             -- LED 3
      "0000000"            when 16#0C#, -- Green
      "0000000"            when 16#0D#, -- Red
      "1111111"            when 16#0E#, -- Blue
                             -- LED 4
      "0000000"            when 16#10#, -- Green
      switch_l(6 downto 0) when 16#11#, -- Red
      "0000000"            when 16#12#, -- Blue
                             -- LED 5
      switch_l(6 downto 0) when 16#14#, -- Green
      "0000000"            when 16#15#, -- Red
      "0000000"            when 16#16#, -- Blue
                             -- LED 6
      "0000000"            when 16#18#, -- Green
      "0000000"            when 16#19#, -- Red
      switch_l(6 downto 0) when 16#1A#, -- Blue
                             -- LED 7
      switch_l(6 downto 0) when 16#1C#, -- Green
      switch_l(6 downto 0) when 16#1D#, -- Red
      switch_l(6 downto 0) when 16#1E#, -- Blue

      "1111111"           when others;


  ------------------------------
  -- Debug lpd8806 RGB LED string
  spi_writer_0 : spi_byte_writer
    generic map(
      SCLK_FREQ    => 2000000.0,    -- Desired lpd8806 serial clock frequency
      SYS_CLK_RATE => SYS_CLK_RATE  -- underlying clock rate
    )
    port map(

      -- System Clock, Reset and Clock Enable
      sys_rst_n   => sys_rst_n,
      sys_clk     => sys_clk,
      sys_clk_en  => sys_clk_en,

      -- Data to send.
      sel_i       => sel_led,
      we_i        => bus_we,
      dat_i       => bus_dat_wr(7 downto 0),

      -- Output
      ssel_o      => open,
      sclk_o      => spi_sclk,
      sdat_o      => spi_sdat
    );

  rgb_led_clk <= lpd8806_sclk when switch_l(7)='0' else spi_sclk;
  rgb_led_dat <= lpd8806_sdat when switch_l(7)='0' else spi_sdat;



end beh;

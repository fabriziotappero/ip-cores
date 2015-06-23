-------------------------------------------------------------------------------
-- Title      : Testbench for design "dac_dsm2"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dac_dsm2_tb.vhd
-- Author     : Wojciech M. Zabolotny ( wzab[at]ise.pw.edu.pl )
-- Company    : 
-- Created    : 2009-04-28
-- Last update: 2012-10-16
-- Platform   : 
-- Standard   : VHDL'93c
-------------------------------------------------------------------------------
-- Description: Testbench for S-D DAC converters
-------------------------------------------------------------------------------
-- Copyright (c) 2009  - THIS IS PUBLIC DOMAIN CODE!!!
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009-04-28  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

-------------------------------------------------------------------------------

entity dac_tb is

end dac_tb;

-------------------------------------------------------------------------------

architecture beh1 of dac_tb is

  -- Configuration of the testbench
  -- Clock period [ns]
  constant TCLK : time := 10 ns;
  constant OSR  : real := 256.0;        -- Oversampling ratio:

  constant FREQ1  : real := 0.35;  -- Frequency of the first sinusoid (relative to the sampling frequency)
  constant AMP1   : real := 0.2;        -- Amplitude of the first sinusoid
  constant PHASE1 : real := 0.35;       -- Phase of the first sinusoid
  constant FREQ2  : real := 0.3;  -- Frequency of the second sinusoid (relative to the sampling frequency)
  constant AMP2   : real := 0.4;        -- Amplitude of the second sinusoid
  constant PHASE2 : real := 0.35;       -- Phase of the second sinusoid
  constant FREQ3  : real := 0.25;  -- Frequency of the third sinusoid (relative to the sampling frequency)
  constant AMP3   : real := 0.3;        -- Amplitude of the third sinusoid
  constant PHASE3 : real := 0.35;       -- Phase of the third sinusoid
  constant TSTEP  : real := 3.1415926 / OSR;  -- Phase/time step of the sinusoid generation (considering the OSR)

  file OUTFILE : text is out "dac_tb.dat";

  component dac_dsm3_top
    generic (
      nbits : integer);
    port (
      din   : in  signed((nbits-1) downto 0);
      dout  : out std_logic;
      clk   : in  std_logic;
      n_rst : in  std_logic);
  end component;

  -- component generics
  constant nbits : integer := 16;

  -- component ports
  signal din    : signed((nbits-1) downto 0) := (others => '0');
  signal dout   : std_logic                  := '0';
  signal n_rst  : std_logic                  := '0';

  -- input signal
  signal s_inp  : real      := 0.0;
  signal s_time : real      := 0.0;
  -- clock
  signal Clk    : std_logic := '1';

begin  -- beh1

  -- component instantiation
  DUT1 : dac_dsm3_top
    generic map (
      nbits => nbits)
    port map (
      din   => din,
      dout  => dout,
      clk   => clk,
      n_rst => n_rst);

  -- clock generation
  Clk <= not Clk after TCLK/2.0;

  -- Generation of input signal and simulation of DACs
  din <= to_signed(integer(s_inp), nbits);
  process (clk, n_rst)
    variable s  : line;
    variable c  : character := ' ';
    variable c1 : character := '1';
    variable c0 : character := '0';
  begin  -- process
    if n_rst = '0' then                 -- asynchronous reset (active low)
      s_time <= 0.0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      s_time <= s_time+TSTEP;
      s_inp <= (2.0**(nbits-1))*(
        AMP1 * sin(s_time*FREQ1+PHASE1) +
        AMP2 * sin(s_time*FREQ2+PHASE2) +
        AMP3 * sin(s_time*FREQ3+PHASE3)
        );
      -- Write results to file
      write(s, s_inp);
      write(s, c);

      if dout = '1' then
        write(s, c1);
      else
        write(s, c0);
      end if;
      writeline(OUTFILE, s);
    end if;
  end process;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here  
    wait until Clk = '1';
    wait for 25 ns;
    n_rst <= '1';
  end process WaveGen_Proc;

end beh1;



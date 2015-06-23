-------------------------------------------------------------------------------
-- Title      : Testbench for design "butterfly"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : butterfly_tb.vhd
-- Author     : Wojciech Zabolotny wzab01<at>gmail.com
-- Company    :
-- License    : BSD
-- Created    : 2014-01-19
-- Last update: 2014-02-05
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-01-19  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;
library work;
use work.icpx.all;

-------------------------------------------------------------------------------

entity butterfly_tb is

end butterfly_tb;

-------------------------------------------------------------------------------

architecture beh1 of butterfly_tb is

  function r2s (
    constant dt : real;
    constant l  : integer)
    return signed is
  begin  -- r2s
    return to_signed(integer(dt*(2.0**(l-1))), l);
  end r2s;

  procedure repicpx (
    constant name : in string;
    constant ire  : in signed;
    constant iim  : in signed) is
  begin  -- repicpx
    report name & "=" & integer'image(to_integer(ire)) &
      "+j*" & integer'image(to_integer(iim))
      severity note;
  end repicpx;

  component butterfly
    port (
      din0  : in  icpx_number;
      din1  : in  icpx_number;
      tf    : in  icpx_number;
      dout0 : out icpx_number;
      dout1 : out icpx_number);
  end component;


  constant W_n_p : complex_polar := (1.0, -MATH_PI/3.0);
  constant W_n   : complex       := polar_to_complex(W_n_p);

  constant fd0r : real := 0.93;
  constant fd0i : real := -0.32;
  constant fd1r : real := -0.27;
  constant fd1i : real := 0.51;

  -- complex signals for verification
  signal cd0, cd1 : complex := (0.0, 0.0);
  signal cres0    : complex := (0.0, 0.0);
  signal cres1    : complex := (0.0, 0.0);

  signal res0, res1 : icpx_number;


  -- component ports
  signal din0  : icpx_number := icpx_zero;
  signal din1  : icpx_number := icpx_zero;
  signal tf    : icpx_number := icpx_zero;
  signal dout0 : icpx_number := icpx_zero;
  signal dout1 : icpx_number := icpx_zero;

  -- clock
  signal Clk : std_logic := '1';

begin  -- beh1

  cd0 <= cmplx(fd0r, fd0i);
  cd1 <= cmplx(fd1r, fd1i);

  din0 <= cplx2icpx(cd0);
  din1 <= cplx2icpx(cd1);

  cres0 <= (cd0 + cd1) / 2.0;
  cres1 <= ((cd0 - cd1) * W_n) / 2.0;

  res0 <= cplx2icpx(cres0);
  res1 <= cplx2icpx(cres1);

  tf <= cplx2icpx(W_n);

  -- component instantiation
  butterfly_1 : butterfly
    port map (
      din0  => din0,
      din1  => din1,
      tf    => tf,
      dout0 => dout0,
      dout1 => dout1);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    
    wait until Clk = '1';
    report "Wn=" & real'image(W_n.re) & "+j*" & real'image(W_n.im) severity note;
    -- report result of complex calculations
    repicpx ("tf", tf.re, tf.im);
    repicpx ("Cres0", res0.re, res0.im);
    repicpx ("Cres1", res1.re, res1.im);
    repicpx ("Dout0", dout0.re, dout0.im);
    repicpx ("Dout1", dout1.re, dout1.im);
  end process WaveGen_Proc;

end beh1;

-------------------------------------------------------------------------------

configuration butterfly_tb_beh1_cfg of butterfly_tb is
  for beh1
  end for;
end butterfly_tb_beh1_cfg;

-------------------------------------------------------------------------------

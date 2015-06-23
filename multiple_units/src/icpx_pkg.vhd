-------------------------------------------------------------------------------
-- Title      : icpx
-- Project    : DP RAM based FFT processor
-------------------------------------------------------------------------------
-- File       : icpx_pkg.vhd
-- Author     : Wojciech Zabolotny  wzab01<at>gmail.com
-- Company    : 
-- License    : BSD
-- Created    : 2014-01-18
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This package defines the format used to store complex numbers
--              In this implementation we store numbers from range <-2.0, 2.0)
--              scaled to signed integers with width of ICPX_WIDTH (including
--              the sign bit)
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-01-18  1.0      wzab    Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;
library work;
use work.fft_len.all;
package icpx is
  
  -- Definition below is generated in the fft_len package
  --constant ICPX_WIDTH : integer := 16;

  -- constant defining the size of std_logic_vector
  -- needed to store the number
  constant ICPX_BV_LEN : integer := ICPX_WIDTH * 2;

  type icpx_number is record
    Re : signed(ICPX_WIDTH-1 downto 0);
    Im : signed(ICPX_WIDTH-1 downto 0);
  end record;


  -- conversion functions
  function icpx2stlv (
    constant din : icpx_number)
    return std_logic_vector;

  function stlv2icpx (
    constant din : std_logic_vector)
    return icpx_number;

  function cplx2icpx (
    constant din : complex)
    return icpx_number;

  function icpx_zero
    return icpx_number;
  

end icpx;

package body icpx is

  function icpx2stlv (
    constant din : icpx_number)
    return std_logic_vector is

    variable vres : std_logic_vector(2*ICPX_WIDTH-1 downto 0) :=
      (others => '0');
    
  begin  -- icpx2stlv
    vres := std_logic_vector(din.re) & std_logic_vector(din.im);
    return vres;
  end icpx2stlv;

  function stlv2icpx (
    constant din : std_logic_vector)  
    return icpx_number is

    variable vres : ICPX_NUMBER := icpx_zero;

  begin  -- stlv2icpx
    vres.Re := signed(din(2*ICPX_WIDTH-1 downto ICPX_WIDTH));
    vres.Im := signed(din(ICPX_WIDTH-1 downto 0));
    return vres;
  end stlv2icpx;

  function cplx2icpx (
    constant din : complex)  
    return icpx_number is

    variable vres : ICPX_NUMBER := icpx_zero;

  begin  -- cplx2icpx
    vres.Re := to_signed(integer(din.Re*(2.0**(ICPX_WIDTH-2))), ICPX_WIDTH);
    vres.Im := to_signed(integer(din.Im*(2.0**(ICPX_WIDTH-2))), ICPX_WIDTH);
    return vres;
  end cplx2icpx;

  function icpx_zero
    return icpx_number is

    variable vres : ICPX_NUMBER;
  begin  -- icpx_zero

    vres.Re := (others => '0');
    vres.Im := (others => '0');
    return vres;
  end icpx_zero;
  
end icpx;

-------------------------------------------------------------------------------
-- Title      : vhdl_support
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fft_support.vhd
-- Author     : Wojciech Zabolotny
-- Company    : 
-- License    : BSD
-- Created    : 2014-01-20
-- Last update: 2014-05-02
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-01-20  1.0      wzab    Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;
library work;
use work.icpx.all;

package fft_support_pkg is

  -- In the synthesizable version, we should replace functions
  -- with precalculated tables (probably)

  function rev(a : in unsigned)
    return unsigned;
  function rev(a : in std_logic_vector)
    return std_logic_vector;

end fft_support_pkg;

package body fft_support_pkg is

   function rev(a : in std_logic_vector)
    return std_logic_vector is
    variable result : std_logic_vector(a'range);
    alias aa        : std_logic_vector(a'reverse_range) is a;
  begin
    for i in aa'range loop
      result(i) := aa(i);
    end loop;
    return result;
  end;  -- function reverse_any_bus

   function rev(a : in unsigned)
    return unsigned is
    variable result : unsigned(a'range);
    alias aa        : unsigned(a'reverse_range) is a;
  begin
    for i in aa'range loop
      result(i) := aa(i);
    end loop;
    return result;
  end;  -- function reverse_any_bus
  

end package body fft_support_pkg;
  

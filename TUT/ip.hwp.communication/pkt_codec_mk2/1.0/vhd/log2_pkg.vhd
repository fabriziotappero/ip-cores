-------------------------------------------------------------------------------
-- Title      : log2_ceil function
-- Project    : 
-------------------------------------------------------------------------------
-- File       : log2_pkg.vhdl
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2010-06-16
-- Last update: 2011-10-07
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-06-16  1.0      ase	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


-------------------------------------------------------------------------------
-- PACKAGE DECLARATION
-------------------------------------------------------------------------------

package log2_pkg is

  -----------------------------------------------------------------------------
  -- HELPER FUNCTIONS
  -----------------------------------------------------------------------------

  -- purpose: Return ceiling log 2 of n
  function log2_ceil (
    constant n : positive)
    return positive;

end package log2_pkg;


-------------------------------------------------------------------------------
-- PACKAGE BODY
-------------------------------------------------------------------------------

package body log2_pkg is

  -- purpose: Return ceiling log 2 of n
  function log2_ceil (
    constant n : positive)
    return positive is
    variable retval : positive := 1;
  begin  -- function log2_ceil
    while 2**retval < n loop
      retval := retval + 1;
    end loop;
    return retval;
  end function log2_ceil;

end package body log2_pkg;

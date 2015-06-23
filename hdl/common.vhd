--------------------------------------------------------------------
-- Company       : XESS Corp.
-- Engineer      : Dave Vanden Bout
-- Creation Date : 05/17/2005
-- Copyright     : 2005, XESS Corp
-- Tool Versions : WebPACK 6.3.03i
--
-- Description:
--    Miscellaneous VHDL constants and functions
--
-- Revision:
--    1.0.0
--
-- Additional Comments:
--    1.1.0:
--        Added int_select() and real_select functions.
--    1.0.0:
--        Initial release.
--
-- License:
--    This code can be freely distributed and modified as long as
--    this header is not removed.
--------------------------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package common is

  constant YES                :    std_logic := '1';
  constant NO                 :    std_logic := '0';
  constant HI                 :    std_logic := '1';
  constant LO                 :    std_logic := '0';
  constant ONE                :    std_logic := '1';
  constant ZERO               :    std_logic := '0';
  -- convert a Boolean to a std_logic
  function boolean2stdlogic(b : in boolean) return std_logic;
  -- find the base-2 logarithm of a number
  function log2(v             : in natural) return natural;
  -- select one of two integers based on a Boolean
  function int_select(s       : in boolean; a : in integer; b : in integer) return integer;
  -- select one of two reals based on a Boolean
  function real_select(s      : in boolean; a : in real; b : in real) return real;

end package common;



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


package body common is

  -- convert a Boolean to a std_logic
  function boolean2stdlogic(b : in boolean) return std_logic is
    variable s                :    std_logic;
  begin
    if b then
      s := '1';
    else
      s := '0';
    end if;
    return s;
  end function boolean2stdlogic;

  -- find the base 2 logarithm of a number
  function log2(v : in natural) return natural is
    variable n    :    natural;
    variable logn :    natural;
  begin
    n      := 1;
    for i in 0 to 128 loop
      logn := i;
      exit when (n >= v);
      n    := n * 2;
    end loop;
    return logn;
  end function log2;

  -- select one of two integers based on a Boolean
  function int_select(s : in boolean; a : in integer; b : in integer) return integer is
  begin
    if s then
      return a;
    else
      return b;
    end if;
    return a;
  end function int_select;

  -- select one of two reals based on a Boolean
  function real_select(s : in boolean; a : in real; b : in real) return real is
  begin
    if s then
      return a;
    else
      return b;
    end if;
    return a;
  end function real_select;

end package body common;

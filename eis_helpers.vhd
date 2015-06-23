-------------------------------------------------------------------------------
-- Title      : Helpers
-- Project    : openFPU64
-------------------------------------------------------------------------------
-- File       : eis_helpers.vhd
-- Author     : Prof. Dr. Gundolf Kiefer <gundolf.kiefer@hs-augsburg.de>
-- Company    : University of Applied Sciences, Augsburg
-- Last update: 2010-04-22
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This package contains neat some helper functions that ease
--              printing out std_logic, std_logic_vector, unsigned and integer
--              values. This package is especially handy for Testbenches.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- License   : GPL v3 -- see gpl.txt
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library STD;
use STD.textio.all;



package helpers is
  function to_character (val : in std_logic) return character;
  function to_string (val : in std_logic_vector) return string;
  function to_string (val: in unsigned) return string;
  function to_string (val: in integer) return string;
end helpers;


package body helpers is

  -- Testbench helpers...
  function to_character (val : in std_logic) return character is
  begin
    case val is
      when '0' => return '0';
      when '1' => return '1';
      when 'U' => return 'u';
      when 'Z' => return 'z';
      when others => return 'x';
    end case;
  end to_character;

  function to_string (val : in std_logic_vector) return string is
    variable str: string (1 to val'length);
    alias val_norm : std_logic_vector (1 to val'length) is val;
    variable n: integer;
  begin
    for i in str'range loop
      str(i) := to_character(val_norm(i));
    end loop;
    return str;
  end to_string;

  function to_string (val: in unsigned) return string is
  begin
    return to_string (std_logic_vector (val));
  end to_string;

  function to_string (val: in integer) return string is
    variable retLine: line;
  begin
    write (retLine, val);
    return retLine(1 to retLine'length);
  end to_string;


end helpers;

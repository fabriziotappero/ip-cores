--
-- Risc5x
-- www.OpenCores.Org - November 2001
--
--
-- This library is free software; you can distribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published
-- by the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU Lesser General Public License for more details.
--
-- A RISC CPU core.
--
-- (c) Mike Johnson 2001. All Rights Reserved.
-- mikej@opencores.org for support or any other issues.
--
-- Revision list
--
-- version 1.0 initial opencores release
--

library ieee;
use ieee.std_logic_1164.all;

package pkg_risc5x is
  function slv_to_integer(x : std_logic_vector) return integer;
  function integer_to_slv(n, bits : integer) return std_logic_vector;

end;

package body pkg_risc5x is


  function slv_to_integer(x : std_logic_vector) return integer is
    variable n : integer := 0;
    variable failure : boolean := false;
  begin
    assert (x'high - x'low + 1) <= 31
        report "Range of sulv_to_integer argument exceeds integer range"
        severity error;
    for i in x'range loop
      n := n * 2;
      case x(i) is
        when '1' | 'H' => n := n + 1;
        when '0' | 'L' => null;
        when others =>
            -- failure := true;
            null;
      end case;
    end loop;

    assert not failure
      report "sulv_to_integer cannot convert indefinite std_logic_vector"
      severity error;
    if failure then
      return 0;
    else
      return n;
    end if;
  end slv_to_integer;

  function integer_to_slv(n, bits : integer) return std_logic_vector is
    variable x : std_logic_vector(bits-1 downto 0) := (others => '0');
    variable tempn : integer := n;
  begin
    for i in x'reverse_range loop
      if (tempn mod 2) = 1 then
        x(i) := '1';
      end if;
      tempn := tempn / 2;
    end loop;

    return x;
  end integer_to_slv;

end;

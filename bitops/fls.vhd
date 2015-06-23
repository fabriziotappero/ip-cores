--
-- FLS - Find last (most-significant) set bit in word
--
-- Custom instruction for Nios II
--
-- Copyright (C) 2012 Tobias Klauser <tklauser@distanz.ch>
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity fls is
  port(
    signal dataa  : in std_logic_vector(31 downto 0);
    signal result : out std_logic_vector(31 downto 0)
  );
end entity fls;

architecture rtl of fls is
begin
  process(dataa)
    variable word : unsigned(result'range);
    variable ret  : unsigned(result'range);
  begin
    ret := to_unsigned(33, ret'length);

    for i in dataa'reverse_range loop
      if dataa(i) = '1' then
        ret := to_unsigned(i + 1, ret'length);
      end if;
    end loop;

    result <= std_logic_vector(ret);
  end process;
end architecture rtl;

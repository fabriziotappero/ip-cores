--------------------------------------------------------------
-- sync.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: synchronizer, 2 cascaded DFF
--
-- dependency: none
--
-- Author: M. Umair Siddiqui (umairsiddiqui@opencores.org)
---------------------------------------------------------------
------------------------------------------------------------------------------------
--                                                                                --
--    Copyright (c) 2005, M. Umair Siddiqui all rights reserved                   --
--                                                                                --
--    This file is part of HPC-16.                                                --
--                                                                                --
--    HPC-16 is free software; you can redistribute it and/or modify              --
--    it under the terms of the GNU Lesser General Public License as published by --
--    the Free Software Foundation; either version 2.1 of the License, or         --
--    (at your option) any later version.                                         --
--                                                                                --
--    HPC-16 is distributed in the hope that it will be useful,                   --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of              --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               --
--    GNU Lesser General Public License for more details.                         --
--                                                                                --
--    You should have received a copy of the GNU Lesser General Public License    --
--    along with HPC-16; if not, write to the Free Software                       --
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   --
--                                                                                --
------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sync is
   port
   (
   d : in std_logic;
   clk : in std_logic;
   q : out std_logic
   );
end sync;

architecture behave2 of sync is
  signal t : std_logic;
begin
  process(clk , d)
  begin
    if d = '1' then
      t <= '1';
      q <= '1';
    elsif rising_edge(clk) then
      t <= '0';
      q <= t;
    end if;
  end process;
end behave2;


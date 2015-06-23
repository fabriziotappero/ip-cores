--------------------------------------------------------------
-- log.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: component of ALU, performs logical operations 
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

entity log is
    port ( a : in std_logic_vector(15 downto 0);
           b : in std_logic_vector(15 downto 0);
           s0 : in std_logic;
           s1 : in std_logic;
           result : out std_logic_vector(15 downto 0)
         );
end log;

architecture dataflow of log is
   signal sel : std_logic_vector(1 downto 0);
begin
   sel <= s1 & s0;
   result <= not a when sel = "00" else
             a and b when sel = "01" else
             a or b  when sel = "10" else
             a xor b;       
end dataflow;

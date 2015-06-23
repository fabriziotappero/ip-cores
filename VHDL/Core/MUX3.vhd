---- $Author: songching $
---- $Date: 2004-04-07 15:45:25 $
---- $Revision: 1.2 $
----------------------------------------------------------------------
---- $Log: not supported by cvs2svn $
----------------------------------------------------------------------
----
---- Copyright (C) 2004 Song Ching Koh, Free Software Foundation, Inc. and OPENCORES.ORG
----
---- This program is free software; you can redistribute it and/or modify
---- it under the terms of the GNU General Public License as published by
---- the Free Software Foundation; either version 2 of the License, or
---- (at your option) any later version.
----
---- This program is distributed in the hope that it will be useful,
---- but WITHOUT ANY WARRANTY; without even the implied warranty of
---- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
---- GNU General Public License for more details.
----
---- You should have received a copy of the GNU General Public License
---- along with this program; if not, write to the Free Software
---- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MUX3 is
    Port ( A : in std_logic_vector(63 downto 0);
           B : in std_logic_vector(63 downto 0);
           Sel : in std_logic;
           Count : in std_logic_vector(2 downto 0);
           C : out std_logic_vector(63 downto 0));
end MUX3;

architecture mux3_structure of MUX3 is
begin
	mux3_process: process(A, B, Sel, Count)
	begin
		if(Sel = '1') then
			if(Count = "000") then
				C <= (others=>'0');
			else
				C <= B;
			end if;
		else
			C <= A;
		end if;
	end process mux3_process;
end mux3_structure;

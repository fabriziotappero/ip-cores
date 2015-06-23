---- $Author: songching $
---- $Date: 2004-04-07 15:38:47 $
---- $Revision: 1.1 $
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

entity min1to8 is
    Port ( A : in std_logic_vector(7 downto 0);
           B : in std_logic_vector(63 downto 0);
           C : out std_logic_vector(63 downto 0));
end min1to8;

architecture min1to8_structure of min1to8 is
	COMPONENT minimum
	PORT(
		A : IN std_logic_vector(7 downto 0);
		B : IN std_logic_vector(7 downto 0);          
		C : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;	
begin
	Inst_minimum7to0: minimum PORT MAP(
		A => A,
		B => B(7 downto 0),
		C => C(7 downto 0)
	);
	Inst_minimum15to8: minimum PORT MAP(
		A => A,
		B => B(15 downto 8),
		C => C(15 downto 8)
	);
	Inst_minimum23to16: minimum PORT MAP(
		A => A,
		B => B(23 downto 16),
		C => C(23 downto 16)
	);
	Inst_minimum31to24: minimum PORT MAP(
		A => A,
		B => B(31 downto 24),
		C => C(31 downto 24)
	);
	Inst_minimum39to32: minimum PORT MAP(
		A => A,
		B => B(39 downto 32),
		C => C(39 downto 32)
	);
	Inst_minimum47to40: minimum PORT MAP(
		A => A,
		B => B(47 downto 40),
		C => C(47 downto 40)
	);
	Inst_minimum55to48: minimum PORT MAP(
		A => A,
		B => B(55 downto 48),
		C => C(55 downto 48)
	);
	Inst_minimum63to56: minimum PORT MAP(
		A => A,
		B => B(63 downto 56),
		C => C(63 downto 56)
	);
end min1to8_structure;

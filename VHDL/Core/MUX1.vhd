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

entity MUX1 is
    Port ( Input : in std_logic_vector(63 downto 0);
           Sel : in std_logic_vector(2 downto 0);
           Output : out std_logic_vector(7 downto 0));
end MUX1;

architecture mux1_structure of MUX1 is
begin
	mux: process(Input, Sel)
	begin
		case SEL is
			when "000" => Output <= Input(7 downto 0);
			when "001" => Output <= Input(15 downto 8);
			when "010" => Output <= Input(23 downto 16);
			when "011" => Output <= Input(31 downto 24);
			when "100" => Output <= Input(39 downto 32);
			when "101" => Output <= Input(47 downto 40);
			when "110" => Output <= Input(55 downto 48);
			when others => Output <= Input(63 downto 56);
		end case;
	end process mux;
end mux1_structure;

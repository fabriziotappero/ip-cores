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

entity Zreg is
    Port ( Input : in std_logic_vector(63 downto 0);
           CLK : in std_logic;
           RST : in std_logic;
           En : in std_logic;
           Output : out std_logic_vector(63 downto 0));
end Zreg;

architecture zreg_structure of Zreg is
begin
	zreg_process: process(Input, CLK, RST, En)
	begin
		if(RST = '1') then
			Output <= (others => '0');
		elsif(falling_edge(CLK)) then
			if(En = '1') then
				Output <= Input;
			end if;
		end if;
	end process zreg_process;
end zreg_structure;

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

entity rule is
    Port ( Input : in std_logic_vector(63 downto 0);
           Add : in std_logic_vector(2 downto 0);
           En : in std_logic;
           CLK : in std_logic;
           RST : in std_logic;
           Output : out std_logic_vector(63 downto 0));
end rule;

architecture rule_structure of rule is
	type mem_array is array(0 to 2**Add'length - 1) of std_logic_vector(63 downto 0);
	signal memory: mem_array;
begin
	rule_process: process(CLK, Add, En, RST, Input)
	begin
		if(RST = '1') then
				for i in 0 to 2**Add'length-1 loop
					memory(i) <= (others=>'0');
				end loop;
		elsif(falling_edge(CLK)) then
			if(En = '1') then
				memory(conv_integer(Add)) <= Input;
			end if;
		end if;
	end process rule_process;
	Output <= memory(conv_integer(Add));
end rule_structure;

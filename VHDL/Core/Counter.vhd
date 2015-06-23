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
 
entity counter is 
    port (CLK, RST, START: in std_logic; 
	 		 DONE: out std_logic;
          q : out std_logic_vector (2 downto 0)); 
end counter; 
 
architecture counter_structure of counter is
	type state_type is (INIT, DN);
	signal present_state, next_state: state_type := INIT;
   signal count : std_logic_vector (2 downto 0) := "000"; 
begin 
	state_process: process(CLK, present_state, count, START)
	begin
		case present_state is
			when INIT =>
				DONE <= '0';
				if(count = "111") then
					next_state <= DN;
				else
					next_state <= INIT;
				end if;
			when DN =>
				DONE <= '1';
				if(START = '0') then
					next_state <= INIT;
				else
					next_state <= DN;
				end if;
			when others => next_state <= INIT;
		end case;
	end process state_process;

	count_process: process(CLK, RST, present_state, count)
	begin
		if(rising_edge(CLK)) then
			if(RST = '1') then
				count <= (others=>'0');
			elsif(start = '1') then
				count <= count + '1';
			end if;
		end if;
	end process count_process;

   CLK_Process: process(CLK, RST, next_state)
	begin
		if(rising_edge(CLK)) then
			if(RST = '1') then
				present_state <= INIT;
			else
				present_state <= next_state;
			end if;
		end if;
	end process CLK_Process;
   q <= count; 
end counter_structure; 

-----------------------------------------------------------------------------
-- NoCem -- Network on Chip Emulation Tool for System on Chip Research 
-- and Implementations
-- 
-- Copyright (C) 2006  Graham Schelle, Dirk Grunwald
-- 
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
-- 02110-1301, USA.
-- 
-- The authors can be contacted by email: <schelleg,grunwald>@cs.colorado.edu 
-- 
-- or by mail: Campus Box 430, Department of Computer Science,
-- University of Colorado at Boulder, Boulder, Colorado 80309
-------------------------------------------------------------------------------- 


-- 
-- Filename: arb_bus_nocem.vhd
-- 
-- Description: legacy bus implementation
-- 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.pkg_nocem.all;
 


entity arb_bus_nocem is
	Port(
	 	-- arbitration lines (usage depends on underlying network)
		arb_req   : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		arb_grant : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		
	 
	 	clk : in std_logic;
      rst : in std_logic
	);

end arb_bus_nocem;

architecture Behavioral of arb_bus_nocem is

signal idle : std_logic;
signal arb_grant_i : std_logic_vector(NOCEM_NUM_AP-1 downto 0);
begin


--need internal signal so that I can read from arb_grant internally
arb_grant <= arb_grant_i;


arb_proc : process (clk,rst)
begin
	if rst='1' then
		idle <= '1';
		arb_grant_i <= (others => '0');
	elsif clk'event and clk='1' then
		
		-- if not granting arbitration to anyone, then bus idle
		if arb_grant_i = 0 then
			idle <= '1';
		else
			idle <= '0';	
		end if;

		--grant arbitration to a single access point
		for I in NOCEM_NUM_AP-1 downto 1 loop

				 if idle = '1' and arb_req(I) = '1' and arb_req(I-1 downto 0) = 0 then
				 	arb_grant_i(I) <= '1';
				 else
				 	arb_grant_i(I) <= '0';				 	 
				 end if;

		end loop;

		--base case
	 	if idle = '1' and arb_req(0) = '1' then
	 		arb_grant_i(0) <= '1';
	 	else
	 		arb_grant_i(0) <= '0';

		end if;

	end if;


end process;


end Behavioral;

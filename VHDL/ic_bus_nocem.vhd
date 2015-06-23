
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
-- Filename: ic_bus_nocem.vhd
-- 
-- Description: interconnect for bus design
-- 




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.pkg_nocem.all;



entity ic_bus_nocem is

	
	Port ( 

		arb_grant : in std_logic_vector(NOCEM_NUM_AP-1 downto 0);

		--data and addr incoming/outgoing line (usage depends on underlying network)
		datain        : in   data_array(NOCEM_NUM_AP-1 downto 0);
		dataout       : out data_array(NOCEM_NUM_AP-1 downto 0);

		dataout_valid : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);

		addrin  : in   pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		addrout : out  pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);

		addrout_valid : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);	
	
	 	clk : in std_logic;
    	rst : in std_logic
		
		
		
	);
end ic_bus_nocem;

architecture Behavioral of ic_bus_nocem is



begin


ic_management : process (rst,arb_grant, datain,addrin)
begin
   for I in NOCEM_NUM_AP-1 downto 0 loop
   	dataout(I) <= (others => '0');
   	addrout(I) <= (others => '0');
   	dataout_valid <= (others => '0');
   	addrout_valid <= (others => '0');
   end loop;

	if rst = '1' then
      for I in NOCEM_NUM_AP-1 downto 0 loop
      	dataout(I) <= (others => '0');
      	addrout(I) <= (others => '0');
      	dataout_valid <= (others => '0');
      	addrout_valid <= (others => '0');
      end loop;
	else
		l1: for I in NOCEM_NUM_AP-1 downto 0 loop
			if arb_grant = CONV_STD_LOGIC_VECTOR(2**I,NOCEM_NUM_AP) then
--			if arb_grant(I) = '1' then
				l2: for J in NOCEM_NUM_AP downto 1 loop
					dataout(J)	<= datain(I);
					addrout(J)	<= addrin(I);
				end loop;			
				
				dataout_valid <= (others => '1');
				addrout_valid <= (others => '1');


			end if;		
		end loop;

--		case arb_grant is
--			for I in NOCEM_NUM_AP-1 downto 0 loop
--				when CONV_STD_LOGIC_VECTOR(2**I,NOCEM_NUM_AP) =>
--						l2: for J in NOCEM_NUM_AP downto 1 loop
--							dataout(DATA_WIDTH*J-1 downto DATA_WIDTH*(J-1))	<= datain(DATA_WIDTH*(I+1)-1 downto DATA_WIDTH*I);
-- 							addrout(ADDR_WIDTH*J-1 downto ADDR_WIDTH*(J-1))	<= addrin(ADDR_WIDTH*(I+1)-1 downto ADDR_WIDTH*I);
--						end loop;		

--						dataout_valid <= (others => '1');
--						addrout_valid <= (others => '1');
--			end loop;

--				when others =>
--					dataout <= (others => '0');
--					addrout <= (others => '0');
--					dataout_valid <= (others => '0');
--					addrout_valid <= (others => '0');
					

--		end case;





			




	end if;

end process;




end Behavioral;

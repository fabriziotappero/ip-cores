------------------------------------------------------------------- 
--                                                               --
--  Copyright (C) 2013 Author and VariStream Studio              --
--  Author : Yu Peng                                             --
--                                                               -- 
--  This source file may be used and distributed without         -- 
--  restriction provided that this copyright statement is not    -- 
--  removed from the file and that any derivative work contains  -- 
--  the original copyright notice and the associated disclaimer. -- 
--                                                               -- 
--  This source file is free software; you can redistribute it   -- 
--  and/or modify it under the terms of the GNU Lesser General   -- 
--  Public License as published by the Free Software Foundation; -- 
--  either version 2.1 of the License, or (at your option) any   -- 
--  later version.                                               -- 
--                                                               -- 
--  This source is distributed in the hope that it will be       -- 
--  useful, but WITHOUT ANY WARRANTY; without even the implied   -- 
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      -- 
--  PURPOSE.  See the GNU Lesser General Public License for more -- 
--  details.                                                     -- 
--                                                               -- 
--  You should have received a copy of the GNU Lesser General    -- 
--  Public License along with this source; if not, download it   -- 
--  from http://www.opencores.org/lgpl.shtml                     -- 
--                                                               -- 
------------------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity HandShake is port
	(
		iResetSync_Clk			: in		std_logic;						-- Active Hi Reset
		iClk					: in		std_logic;						-- Clock	 
		
		iExternalDemand			: in		std_logic;						-- Async External Demand : one positive pulse
		oInternalDemand			: out		std_logic;						-- Sync with iClk Internal demand 
		iInternalClrDemand		: in		std_logic						-- Clr Internal Demand
		);
end HandShake;

architecture HandShake of HandShake is 
	
	signal sClrDemand			:	std_logic;		
	signal sAsyncDemand			:	std_logic;		
	signal sAsyncDemandPipe		:	std_logic;		



begin																
	
	
	-- Edge detection for Tranfer requests
		
	hand_shake_tx_proc:
	process(sClrDemand, iResetSync_Clk, iExternalDemand)
	begin
		if (sClrDemand = '1') or (iResetSync_Clk = '1') then
			sAsyncDemand <= '0';
		elsif rising_edge(iExternalDemand) then
			sAsyncDemand <= '1';
		end if;
	end process hand_shake_tx_proc;
	
	sync_tx_proc:
	process(iClk)
	begin
		if rising_edge(iClk) then  		
			if (iResetSync_Clk = '1') then
				oInternalDemand 	<= '0';
				sClrDemand 			<= '0'; 
				sAsyncDemandPipe	<= '0';
			else
				if iInternalClrDemand = '1' then
					sClrDemand 			<= '1';					
					sAsyncDemandPipe    <= '0';
					oInternalDemand		<= '0';
				else   
					sAsyncDemandPipe   	<= sAsyncDemand;
					oInternalDemand		<= sAsyncDemandPipe;
					sClrDemand			<= '0';		
				end if;
			end if;
		end if;
	end process sync_tx_proc;

	
end HandShake;


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
--  Description:
--      Edge detector
--      If iEdge = 1 > rising edge detect
--      If iEdge = 0 > falling edge detect
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity edgedtc is port
	(
		iD				: in		std_logic; 		
		iClk			: in		std_logic;
		iResetSync_Clk	: in		std_logic;
		iEdge			: in		std_logic;
		oQ				: out		std_logic := '0'
	);
end edgedtc;

architecture edgedtc of edgedtc is 

	
	signal sFf	: std_logic_vector(1 downto 0) := "00";

begin

	edgedtc:process(iClk)
		begin
		if rising_edge(iCLk) then 
			if iResetSync_Clk = '1' THEN
				oQ <= '0';
				sFf <= iEdge & iEdge;--"00";
			else
				sFf(0) <= iD;
				sFf(1) <= sFf(0);
				
				oQ <= (not iEdge xor sFf(0)) and (iEdge xor sFf(1));
			end if;
		end if;
			
	end process;



end edgedtc;


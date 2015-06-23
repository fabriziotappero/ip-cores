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
--  Notes: 
--      Generates a "synchronous" reset from the async global 
--      reset.
-------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

entity SyncReset is
	port(
		iClk				: in std_logic;						-- Clock domain that the reset should be resynchronyze to
		iAsyncReset      	: in std_logic;						-- Asynchronous reset that should be resynchronyse
		oSyncReset       	: out std_logic						-- Synchronous reset output
	);
end SyncReset;

architecture SyncReset of SyncReset is  

	signal sResetStage1				: std_logic;
	
begin

	process(iClk, iAsyncReset)
	begin
		if iAsyncReset = '1' then
			sResetStage1		<= '1';
			oSyncReset			<= '1';
		elsif rising_edge(iClk) then
			sResetStage1		<= '0';
			oSyncReset			<= sResetStage1;
		end if;
	end process;

end SyncReset;


  
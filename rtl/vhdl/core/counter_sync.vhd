----------------------------------------------------------------------  
----  counter_sync                                                ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----     counter with synchronous count enable. It generates an   ----
----     overflow when max_value is reached                       ----
----                                                              ----
----  Dependencies: none                                          ----
----                                                              ----
----  Authors:                                                    ----
----      - Geoffrey Ottoy, DraMCo research group                 ----
----      - Jonas De Craene, JonasDC@opencores.org                ---- 
----                                                              ---- 
---------------------------------------------------------------------- 
----                                                              ---- 
---- Copyright (C) 2011 DraMCo research group and OPENCORES.ORG   ---- 
----                                                              ---- 
---- This source file may be used and distributed without         ---- 
---- restriction provided that this copyright statement is not    ---- 
---- removed from the file and that any derivative work contains  ---- 
---- the original copyright notice and the associated disclaimer. ---- 
----                                                              ---- 
---- This source file is free software; you can redistribute it   ---- 
---- and/or modify it under the terms of the GNU Lesser General   ---- 
---- Public License as published by the Free Software Foundation; ---- 
---- either version 2.1 of the License, or (at your option) any   ---- 
---- later version.                                               ---- 
----                                                              ---- 
---- This source is distributed in the hope that it will be       ---- 
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ---- 
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ---- 
---- PURPOSE.  See the GNU Lesser General Public License for more ---- 
---- details.                                                     ---- 
----                                                              ---- 
---- You should have received a copy of the GNU Lesser General    ---- 
---- Public License along with this source; if not, download it   ---- 
---- from http://www.opencores.org/lgpl.shtml                     ---- 
----                                                              ---- 
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- counter with synchronous count enable. It generates an
-- overflow when max_value is reached
entity counter_sync is
  generic(
    max_value : integer := 1024 -- maximum value (constraints the nr bits for counter)
  );
  port(
    reset_value : in integer;   -- value the counter counts to
    core_clk    : in std_logic; -- clock input
    ce          : in std_logic; -- count enable
    reset       : in std_logic; -- reset input
    overflow    : out std_logic -- gets high when counter reaches reset_value
  );
end counter_sync;


architecture Behavioral of counter_sync is
begin
	
	-- counter process with asynchronous active high reset
	count_proc: process(core_clk, reset)
		variable steps_counter : integer range 0 to max_value-1;
	begin
		if reset = '1' then  -- reset counter
			steps_counter := 0;
			overflow <= '0';
		elsif rising_edge(core_clk) then
			-- counter is enabled, count till reset_value
			if ce = '1' then 
				if steps_counter = (reset_value-1) then -- generate overflow and reset counter
					steps_counter := 0;
					overflow <= '1';
				else	-- just count
					steps_counter := steps_counter + 1;
					overflow <= '0';
				end if;
			else
			--counter disabled, halt counter
				overflow <= '0';
				steps_counter := steps_counter;
			end if;
		end if;
	end process;
	
end Behavioral;

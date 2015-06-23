-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     State machine for Present decoder. It is only part of     ----
---- "inverse Present", not key gen. For more informations see     ----
---- below.                                                        ----
---- To Do:                                                        ----
----                                                               ----
---- Author(s):                                                    ----
---- - Krzysztof Gajewski, gajos@opencores.org                     ----
----                       k.gajewski@gmail.com                    ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2013 Authors and OPENCORES.ORG                  ----
----                                                               ----
---- This source file may be used and distributed without          ----
---- restriction provided that this copyright statement is not     ----
---- removed from the file and that any derivative work contains   ----
---- the original copyright notice and the associated disclaimer.  ----
----                                                               ----
---- This source file is free software; you can redistribute it    ----
---- and-or modify it under the terms of the GNU Lesser General    ----
---- Public License as published by the Free Software Foundation;  ----
---- either version 2.1 of the License, or (at your option) any    ----
---- later version.                                                ----
----                                                               ----
---- This source is distributed in the hope that it will be        ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied    ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR       ----
---- PURPOSE. See the GNU Lesser General Public License for more   ----
---- details.                                                      ----
----                                                               ----
---- You should have received a copy of the GNU Lesser General     ----
---- Public License along with this source; if not, download it    ----
---- from http://www.opencores.org/lgpl.shtml                      ----
----                                                               ----
-----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.kody.ALL;

entity PresentDecStateMachine is
	generic (
		w_5 : integer := 5
	);
	port (
		clk, reset, start : in std_logic;
		ready, cnt_res, ctrl_mux, RegEn: out std_logic;
		num : in std_logic_vector (w_5-1 downto 0)
	);
end PresentDecStateMachine;

architecture Behavioral of PresentDecStateMachine is
	
	signal state : stany;
	signal next_state : stany;	
	
	begin
		States : process(state, start, num)
			begin
				case state is
				    ---- Waiting for start
					when NOP =>
						ready <= '0';
						cnt_res <= '0';
						ctrl_mux <= '0';
						if (start = '1') then 
							RegEn <= '1';
							next_state <= SM_START;
						else 
							RegEn <= '0';
							next_state <= NOP;
						end if;
				    -- Decoding
					when SM_START =>
						ready <= '0';
						cnt_res <= '1';
						if (start = '1') then
						    -- control during first start
							if (num = "11111") then
								RegEn <= '1';
								ctrl_mux <= '1';
								next_state <= SM_START;
							-- last iteration
							elsif (num = "00000") then
								RegEn <= '0';
								ctrl_mux <= '1';
								next_state <= SM_READY;
							-- rest iterations
							else
								RegEn <= '1';
								ctrl_mux <= '1';
								next_state <= SM_START;
							end if;
						else
							RegEn <= '0';
							ctrl_mux <= '0';
							next_state <= NOP;
						end if;
					-- Decoding end
					when SM_READY =>
						cnt_res <= '0';
						RegEn <= '0';
						ready <= '1';
						if (start = '1') then
							ctrl_mux <= '1';
							next_state <= SM_READY;
						else
							ctrl_mux <= '0';
							next_state <= NOP;
						end if;
				end case;
		end process States;
		
		SM : process (clk, reset)
			begin
				if (reset = '1') then
					state <= NOP;				
				elsif (clk'Event and clk = '1') then
					state <= next_state;
				end if;
			end process SM;

	end Behavioral;


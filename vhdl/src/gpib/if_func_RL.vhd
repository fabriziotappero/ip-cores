--------------------------------------------------------------------------------
--This file is part of fpga_gpib_controller.
--
-- Fpga_gpib_controller is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Fpga_gpib_controller is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with Fpga_gpib_controller.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------
-- Author: Andrzej Paluch
-- 
-- Create Date:    01:04:57 10/03/2011 
-- Design Name: 
-- Module Name:    if_func_RL - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.utilPkg.all;


entity if_func_RL is
	port(
		-- device inputs
		clk : in std_logic; -- clock
		pon : in std_logic; -- power on
		rtl : in std_logic; -- return to local
		-- state inputs
		ACDS : in std_logic; -- listener active state (AH)
		LADS : in std_logic; -- listener addressed state (L or LE)
		-- instructions
		REN : in std_logic; -- remote enable
		LLO : in std_logic; -- local lockout
		MLA : in std_logic; -- my listen address
		GTL : in std_logic; -- go to local
		-- reported state
		LOCS : out std_logic; -- local state
		LWLS : out std_logic -- local with lockout state
	);
end if_func_RL;

architecture Behavioral of if_func_RL is

	-- states
	type RL_STATE is (
		-- local state
		ST_LOCS,
		-- remote state
		ST_REMS,
		-- local with lockout state
		ST_LWLS,
		-- remote with lockout state
		ST_RWLS
	);

	-- current state
	signal current_state : RL_STATE;

	-- events
	signal event0, event1, event2, event3, event4, event5 : boolean;
	

begin
	-- state machine process
	process(pon, clk) begin
		if pon = '1' then
			current_state <= ST_LOCS;
		elsif rising_edge(clk) then
			case current_state is
				------------------
				when ST_LOCS =>
					if event0 then
						-- no state change
					elsif event1 then
						current_state <= ST_REMS;
					elsif event3 then
						current_state <= ST_LWLS;
					end if;
				------------------
				when ST_REMS =>
					if event0 then
						current_state <= ST_LOCS;
					elsif event2 then
						current_state <= ST_LOCS;
					elsif event3 then
						current_state <= ST_RWLS;
					end if;
				------------------
				when ST_RWLS =>
					if event0 then
						current_state <= ST_LOCS;
					elsif event5 then
						current_state <= ST_LWLS;
					end if;
				------------------
				when ST_LWLS =>
					if event0 then
						current_state <= ST_LOCS;
					elsif event4 then
						current_state <= ST_RWLS;
					end if;
				------------------
				when others =>
					current_state <= ST_LOCS;
			end case;
		end if;
	end process;

	-- events
	event0 <= REN='0';
	event1 <= rtl='0' and MLA='1' and ACDS='1';
	event2 <= 
		(GTL='1' and LADS='1' and ACDS='1') or
		(rtl='1' and not(LLO='1' and ACDS='1'));
	event3 <= LLO='1' and ACDS='1';
	event4 <= MLA='1' and ACDS='1';
	event5 <= GTL='1' and LADS='1' and ACDS='1';

	-- reported states
	LOCS <= to_stdl(current_state = ST_LOCS);
	LWLS <= to_stdl(current_state = ST_LWLS);

end Behavioral;


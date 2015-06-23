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
--------------------------------------------------------------------------------
-- Entity: 	if_func_L_LE
-- Date:	01:04:57 10/01/2011
-- Author: Andrzej Paluch
--------------------------------------------------------------------------------
library IEEE;

use ieee.std_logic_1164.all;

use work.utilPkg.all;


entity if_func_L_LE is
	port(
		-- clock
		clk : in std_logic; -- clock
		-- function settings
		isLE : in std_logic;
		-- local commands
		pon : in std_logic; -- power on
		ltn : in std_logic; -- listen
		lun : in std_logic; -- local unlisten
		lon : in std_logic; -- listen only
		-- state inputs
		ACDS : in std_logic; -- accept data state (AH)
		CACS : in std_logic; -- controller active state (C)
		TPAS : in std_logic; -- talker primary address state (T)
		-- remote commands
		ATN : in std_logic; -- attention
		IFC : in std_logic; -- interface clear
		MLA : in std_logic; -- my listen address
		MTA : in std_logic; -- my talk address
		UNL : in std_logic; -- unlisten
		PCG : in std_logic; -- primary command group
		MSA : in std_logic; -- my secondary address
		-- reported states
		LACS : out std_logic; -- listener active state
		LADS : out std_logic; -- listener addressed state
		LPAS : out std_logic -- listener primary addressed state
		;debug1 : out std_logic
	);
end if_func_L_LE;

architecture Behavioral of if_func_L_LE is

	-- states
	type LE_STATE_1 is (
		-- listener idle state
		ST_LIDS,
		-- listener addressed state
		ST_LADS,
		-- listener active state
		ST_LACS
	);
	
	-- states
	type LE_STATE_2 is (
		-- listener primary idle state
		ST_LPIS,
		-- listener primary addressed state
		ST_LPAS
	);
	
	-- current state
	signal current_state_1 : LE_STATE_1;
	signal current_state_2 : LE_STATE_2;
	
	-- predicates
	signal event0, event1, event2, event3, event4 : boolean;

begin

	debug1 <= to_stdl(current_state_1 = ST_LACS) or
		to_stdl(current_state_1 = ST_LADS);

	-- state machine process - L_STATE_1
	process(pon, clk) begin
	if pon = '1' then
			current_state_1 <= ST_LIDS;
		elsif rising_edge(clk) then
			case current_state_1 is
				------------------
				when ST_LIDS =>
					if event0 then
						-- no state change
					elsif event1 then
						current_state_1 <= ST_LADS;
					end if;
				------------------
				when ST_LADS =>
					if event0 then
						current_state_1 <= ST_LIDS;
					elsif event2 then
						current_state_1 <= ST_LIDS;
					elsif ATN='0' then
						current_state_1 <= ST_LACS;
					end if;
				------------------
				when ST_LACS =>
					if event0 then
						current_state_1 <= ST_LIDS;
					elsif ATN='1' then
						current_state_1 <= ST_LADS;
					end if;
				------------------
				when others =>
					current_state_1 <= ST_LIDS;
			end case;
		end if;
	end process;

	-- state machine process - L_STATE_2
	process(pon, clk) begin
		if pon = '1' then
			current_state_2 <= ST_LPIS;
		elsif rising_edge(clk) then
			case current_state_2 is
				------------------
				when ST_LPIS =>
					if event0 then
						-- no state change
					elsif event3 then
						current_state_2 <= ST_LPAS;
					end if;
				------------------
				when ST_LPAS =>
					if event0 then
						current_state_2 <= ST_LPIS;
					elsif event4 then
						current_state_2 <= ST_LPIS;
					end if;
				------------------
				when others =>
					current_state_2 <= ST_LPIS;
			end case;
		end if;
	end process;

	-- events
	event0 <= IFC='1';

	event1 <= (isLE='1' and (
				lon='1' or (ltn='1' and CACS='1') or
				(MSA='1' and current_state_2=ST_LPAS and ACDS='1')
			)) or
			(isLE='0' and (
				lon='1' or (MLA='1' and ACDS='1') or (ltn='1' and CACS='1')
			));

	event2 <= (isLE='1' and (
				(UNL='1' and ACDS='1') or
				(lun='1' and CACS='1') or
				(MSA='1' and TPAS='1' and ACDS='1')
			)) or
			(isLE='0' and (
				(UNL='1' and ACDS='1') or
				(MTA='1' and ACDS='1') or
				(lun='1' and CACS='1')
			));

	event3 <= MLA='1' and ACDS='1';
	event4 <= PCG='1' and MLA='0' and ACDS='1';

	LACS <= to_stdl(current_state_1 = ST_LACS);
	LADS <= to_stdl(current_state_1 = ST_LADS);
	LPAS <= to_stdl(current_state_2 = ST_LPAS);

end Behavioral;

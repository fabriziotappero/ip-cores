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
-- Entity: 	if_func_T_TE
-- Date:	01:04:57 10/01/2011
-- Author: Andrzej Paluch
--------------------------------------------------------------------------------
library IEEE;

use ieee.std_logic_1164.all;

use work.utilPkg.all;


entity if_func_T_TE is
	port(
		-- clock
		clk : in std_logic; -- clock
		-- function settings
		isTE : in std_logic;
		-- local instruction inputs
		pon : in std_logic; -- power on
		ton : in std_logic; -- talk only
		endOf : in std_logic; -- end of byte string
		-- state inputs
		ACDS : in std_logic; -- accept data state (AH)
		APRS : in std_logic; -- affirmative poll response
		LPAS : in std_logic; -- listener primary state (LE)
		-- remote instruction inputs
		ATN : in std_logic; -- attention
		IFC : in std_logic; -- interface clear
		SPE : in std_logic; -- serial poll enable
		SPD : in std_logic; -- serial poll disable
		MTA : in std_logic; -- my talk address
		OTA : in std_logic; -- other talk address
		MLA : in std_logic; -- my listen address
		OSA : in std_logic; -- other secondary address
		MSA : in std_logic; -- my secondary address
		PCG : in std_logic; -- primary command group
		-- remote instruction outputs
		END_OF : out std_logic; -- end of data
		RQS : out std_logic; -- data accepted
		DAB : out std_logic; -- data byte
		EOS : out std_logic; -- end of string
		STB : out std_logic; -- status byte
		-- local instruction outputs
		tac : out std_logic; -- talker active
		-- reported states
		SPAS : out std_logic; -- serial poll active state
		TPAS : out std_logic; -- transmitter active state
		TADS : out std_logic; -- talker addressed state
		TACS : out std_logic -- talker active state
	);
end if_func_T_TE;

architecture Behavioral of if_func_T_TE is

	-- states
	type T_STATE_1 is (
		-- talker idle state
		ST_TIDS,
		-- talker addressed state
		ST_TADS,
		-- talker active state
		ST_TACS,
		-- serial poll active state
		ST_SPAS
	);

	type T_STATE_2 is (
		-- serial poll idle state
		ST_SPIS,
		-- seriall poll mode state
		ST_SPMS
	);

	type T_STATE_3 is (
		-- talker primary idle state
		ST_TPIS,
		-- talker primary addressed state
		ST_TPAS
	);

	-- current state
	signal current_state_1 : T_STATE_1;
	signal current_state_2 : T_STATE_2;
	signal current_state_3 : T_STATE_3;

	-- events
	signal event1_1, event1_2, event1_3, event1_4, event1_5, event1_6 : boolean;
	signal event2_1, event2_2, event2_3 : boolean;
	signal event3_1, event3_2, event3_3 : boolean;


begin

	-- state machine process - T_STATE_1
	process(pon, clk) begin
		if pon = '1' then
			current_state_1 <= ST_TIDS;
		elsif rising_edge(clk) then
			case current_state_1 is
				------------------
				when ST_TIDS =>
					if event1_6 then
						-- no state change
					elsif event1_1 then
						current_state_1 <= ST_TADS;
					end if;
				------------------
				when ST_TADS =>
					if event1_6 then
						current_state_1 <= ST_TIDS;
					elsif event1_2 then
						current_state_1 <= ST_SPAS;
					elsif event1_3 then
						current_state_1 <= ST_TIDS;
					elsif event1_4 then
						current_state_1 <= ST_TACS;
					end if;
				------------------
				when ST_SPAS =>
					if event1_6 then
						current_state_1 <= ST_TIDS;
					elsif event1_5 then
						current_state_1 <= ST_TADS;
					end if;
				------------------
				when ST_TACS =>
					if event1_6 then
						current_state_1 <= ST_TIDS;
					elsif event1_5 then
						current_state_1 <= ST_TADS;
					end if;
				------------------
				when others =>
					current_state_1 <= ST_TIDS;
			end case;
		end if;
	end process;

	-- state machine process - T_STATE_2
	process(pon, clk) begin
		if pon = '1' then
			current_state_2 <= ST_SPIS;
		elsif rising_edge(clk) then
			case current_state_2 is
				------------------
				when ST_SPIS =>
					if event2_3 then
						-- no state change
					elsif event2_1 then
						current_state_2 <= ST_SPMS;
					end if;
				------------------
				when ST_SPMS =>
					if event2_3 then
						current_state_2 <= ST_SPIS;
					elsif event2_2 then
						current_state_2 <= ST_SPIS;
					end if;
				------------------
				when others =>
					current_state_2 <= ST_SPIS;
			end case;
		end if;
	end process;

	-- state machine process - T_STATE_3
	process(pon, clk) begin
		if pon = '1' then
			current_state_3 <= ST_TPIS;
		elsif rising_edge(clk) then
			case current_state_3 is
				------------------
				when ST_TPIS =>
					if event3_3 then
						-- no state change
					elsif event3_1 then
						current_state_3 <= ST_TPAS;
					end if;
				------------------
				when ST_TPAS =>
					if event3_3 then
						current_state_3 <= ST_TPIS;
					elsif event3_2 then
						current_state_3 <= ST_TPIS;
					end if;
				------------------
				when others =>
					current_state_3 <= ST_TPIS;
			end case;
		end if;
	end process;

	-- events
	event1_1 <= is_1(
		-- TE
		(isTE and
			(ton or (MSA and ACDS and to_stdl(current_state_3=ST_TPAS)))) or
		-- T
		(not isTE and
			(ton or (MTA and ACDS)))
		);
	event1_2 <= ATN='0' and current_state_2=ST_SPMS;
	event1_3 <= 
			-- TE
			(isTE='1' and ((OTA='1' and ACDS='1') or
			(OSA='1' and current_state_3=ST_TPAS and ACDS='1') or
			(MSA='1' and LPAS='1' and ACDS='1'))) or
			-- T
			(isTE='0' and ((OTA='1' and ACDS='1') or (MLA='1' and ACDS='1')));
	event1_4 <= ATN='0' and current_state_2/=ST_SPMS;
	event1_5 <= ATN='1';
	event1_6 <= IFC='1';

	event2_1 <= SPE='1' and ACDS='1';
	event2_2 <= SPD='1' and ACDS='1';
	event2_3 <= IFC='1';
	
	event3_1 <= MTA='1' and ACDS='1';
	event3_2 <= PCG='1' and MTA='0' and ACDS='1';
	event3_3 <= IFC='1';

	-- TADS generator
	with current_state_1 select
		TADS <=
			'1' when ST_TADS,
			'0' when others;

	-- TACS generator
	with current_state_1 select
		TACS <=
			'1' when ST_TACS,
			'0' when others;

	-- DAB generator
	with current_state_1 select
		DAB <=
			'1' when ST_TACS,
			'0' when others;
	
	-- EOS is kind of DAB
	with current_state_1 select
		EOS <=
			'1' when ST_TACS,
			'0' when others;
	
	-- STB generator
	with current_state_1 select
		STB <=
			'1' when ST_SPAS,
			'0' when others;

	-- SPAS generator
	with current_state_1 select
		SPAS <=
			'1' when ST_SPAS,
			'0' when others;

	-- TPAS generator
	with current_state_3 select
		TPAS <=
			'1' when ST_TPAS,
			'0' when others;

	-- tac generator
	with current_state_1 select
		tac <=
			'1' when ST_TACS,
			'0' when others;

	-- END_OF generator
	with current_state_1 select
		END_OF <=
			endOf when ST_TACS,
			endOf when ST_SPAS,
			'0' when others;

	-- RQS generator
	RQS <= APRS when current_state_1=ST_SPAS else '0';

end Behavioral;

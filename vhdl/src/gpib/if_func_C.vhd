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
-- Entity: 	if_func_C
-- Date:	23:00:30 10/04/2011
-- Author: Andrzej Paluch
--------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;

use work.utilPkg.all;


entity if_func_C is
	port(
		-- device inputs
		clk : in std_logic; -- clock
		pon : in std_logic; -- power on
		gts : in std_logic; -- go to standby
		rpp : in std_logic; -- request parallel poll
		tcs : in std_logic; -- take control synchronously
		tca : in std_logic; -- take control asynchronously
		sic : in std_logic; -- send interface clear
		rsc : in std_logic; -- request system control
		sre : in std_logic; -- send remote enable
		-- state inputs
		TADS : in std_logic; -- talker addressed state (T or TE)
		ACDS : in std_logic; -- accept data state (AH)
		ANRS : in std_logic; -- acceptor not ready state (AH)
		STRS : in std_logic; -- source transfer state (SH)
		SDYS : in std_logic; -- source delay state (SH)
		-- command inputs
		ATN_in : in std_logic; -- attention
		IFC_in : in std_logic; -- interface clear
		TCT_in : in std_logic; -- take control
		SRQ_in : in std_logic; -- service request
		-- command outputs
		ATN_out : out std_logic; -- attention
		IFC_out : out std_logic; -- interface clear
		TCT_out : out std_logic; -- take control
		IDY_out : out std_logic; -- identify
		REN_out : out std_logic; -- remote enable
		-- reported states
		CACS : out std_logic; -- controller active state
		CTRS : out std_logic; -- controller transfer state
		CSBS : out std_logic; -- controller standby state
		CPPS : out std_logic; -- controller parallel poll state
		CSRS : out std_logic; -- controller service requested state
		SACS : out std_logic -- system control active state
	);
end if_func_C;

architecture Behavioral of if_func_C is

	-- states
	type C_STATE_1 is (
		-- controller idle state
		ST_CIDS,
		-- controller addressed state
		ST_CADS,
		-- controller transfer state
		ST_CTRS,
		-- controller active state
		ST_CACS,
		-- controller standby state
		ST_CSBS,
		-- controllet synchronous wait state
		ST_CSWS,
		-- controller active wait state
		ST_CAWS,
		-- controller parallel poll wait state
		ST_CPWS,
		-- controller parallel poll wait state
		ST_CPPS
	);

	-- states
	type C_STATE_2 is (
		-- controller service not requested state
		ST_CSNS,
		-- controller service requested state
		ST_CSRS

	);

	-- states
	type C_STATE_3 is (
		-- system control interface clear idle state
		ST_SIIS,
		-- system control interface clear active state
		ST_SIAS,
		-- system control interface clear not active state
		ST_SINS

	);

	-- states
	type C_STATE_4 is (
		-- system control remote enable idle state
		ST_SRIS,
		-- system control remote enable active state
		ST_SRAS,
		-- system control remote enable not active state
		ST_SRNS

	);

	-- states
	type C_STATE_5 is (
		-- system control not active state
		ST_SNAS,
		-- system control active state
		ST_SACS
	
	);

	-- current state
	signal current_state_1 : C_STATE_1;
	signal current_state_2 : C_STATE_2;
	signal current_state_3 : C_STATE_3;
	signal current_state_4 : C_STATE_4;
	signal current_state_5 : C_STATE_5;

	-- events
	signal event1_1, event1_2, event1_3, event1_4, event1_5,
		event1_6, event1_7, event1_8, event1_9, event1_10,
		event1_11, event1_12 : boolean;

	signal event2_1, event2_2 : boolean;

	signal event3_1, event3_2, event3_3, event3_4, event3_5 : boolean;

	signal event4_1, event4_2, event4_3, event4_4, event4_5 : boolean;

	signal event5_1, event5_2 : boolean;

	-- timers
	constant TIMER_T6_TIMEOUT : integer := 110;
	constant TIMER_T7_TIMEOUT : integer := 25;
	constant TIMER_T9_TIMEOUT : integer := 75;
	constant TIMER_A_MAX : integer := 128;
	signal timer_a : integer range 0 to TIMER_A_MAX;
	signal timer_T6Expired : boolean;
	signal timer_T7Expired : boolean;
	signal timer_T9Expired : boolean;

	constant TIMER_T8_TIMEOUT : integer := 5000;
	constant TIMER_B_MAX : integer := 5004;
	signal timer_b : integer range 0 to TIMER_B_MAX;
	signal timer_b_1 : integer range 0 to TIMER_B_MAX;
	signal timer_T8Expired : boolean;
	signal timer_T8_1Expired : boolean;


begin

	-- state machine process - C_STATE_1
	process(pon, clk) begin
		-- async reset
		if pon='1' then
			current_state_1 <= ST_CIDS;
		elsif rising_edge(clk) then

			-- timer
			if timer_a < TIMER_A_MAX then
				timer_a <= timer_a + 1;
			end if;

			-- state machine
			case current_state_1 is
				------------------
				when ST_CIDS =>
					if event1_1 then
						-- no state change
					elsif event1_2 then
						current_state_1 <= ST_CADS;
					end if;
				------------------
				when ST_CADS =>
					if event1_1 then
						current_state_1 <= ST_CIDS;
					elsif event1_4 then
						current_state_1 <= ST_CACS;
					end if;
				------------------
				when ST_CACS =>
					if event1_1 then
						current_state_1 <= ST_CIDS;
					elsif event1_5 then
						current_state_1 <= ST_CTRS;
					elsif event1_6 then
						current_state_1 <= ST_CSBS;
					elsif event1_7 then
						timer_a <= 0;
						current_state_1 <= ST_CPWS;
					end if;
				------------------
				when ST_CTRS =>
					if event1_1 then
						current_state_1 <= ST_CIDS;
					elsif event1_3 or event1_1 then
						current_state_1 <= ST_CIDS;
					end if;
				------------------
				when ST_CSBS =>
					if event1_1 then
						current_state_1 <= ST_CIDS;
					elsif event1_9 then
						timer_a <= 0;
						current_state_1 <= ST_CSWS;
					end if;
				------------------
				when ST_CSWS =>
					if event1_1 then
						current_state_1 <= ST_CIDS;
					elsif event1_10 then
						timer_a <= 0;
						current_state_1 <= ST_CAWS;
					end if;
				------------------
				when ST_CAWS =>
					if event1_1 then
						current_state_1 <= ST_CIDS;
					elsif event1_8 then
						current_state_1 <= ST_CACS;
					elsif event1_7 then
						timer_a <= 0;
						current_state_1 <= ST_CPWS;
					end if;
				------------------
				when ST_CPWS =>
					if event1_1 then
						current_state_1 <= ST_CIDS;
					elsif event1_11 then
						current_state_1 <= ST_CPPS;
					end if;
				------------------
				when ST_CPPS =>
					if event1_1 then
						current_state_1 <= ST_CIDS;
					elsif event1_12 then
						current_state_1 <= ST_CAWS;
					end if;
				------------------
				when others =>
					current_state_1 <= ST_CIDS;
			end case;
		end if;
	end process;

	-- state machine process - C_STATE_2
	process(pon, clk) begin
		-- async reset
		if pon='1' then
			current_state_2 <= ST_CSNS;
		elsif rising_edge(clk) then
			-- state machine
			case current_state_2 is
				------------------
				when ST_CSNS =>
					if event2_1 then
						current_state_2 <= ST_CSRS;
					end if;
				------------------
				when ST_CSRS =>
					if event2_2 then
						current_state_2 <= ST_CSNS;
					end if;
				------------------
				when others =>
					current_state_2 <= ST_CSNS;
			end case;
		end if;
	end process;

	-- state machine process - C_STATE_3
	process(pon, clk) begin
		-- async reset
		if pon='1' then
			current_state_3 <= ST_SIIS;
		elsif rising_edge(clk) then

			-- timer
			if timer_b < TIMER_B_MAX then
				timer_b <= timer_b + 1;
			end if;

			-- state machine
			case current_state_3 is
				------------------
				when ST_SIIS =>
					if event3_1 then
						-- no state change
					elsif event3_2 then
						timer_b <= 0;
						current_state_3 <= ST_SIAS;
					elsif event3_3 then
						current_state_3 <= ST_SINS;
					end if;
				------------------
				when ST_SIAS =>
					if event3_1 then
						current_state_3 <= ST_SIIS;
					elsif event3_5 then
						current_state_3 <= ST_SINS;
					end if;
				------------------
				when ST_SINS =>
					if event3_1 then
						current_state_3 <= ST_SIIS;
					elsif event3_4 then
						current_state_3 <= ST_SIAS;
					end if;
				------------------
				when others =>
					current_state_3 <= ST_SIIS;
			end case;
		end if;
	end process;

	-- state machine process - C_STATE_4
	process(pon, clk) begin
		-- async reset
		if pon='1' then
			timer_b_1 <= 0;
			current_state_4 <= ST_SRIS;
		elsif rising_edge(clk) then
		
			-- timer
			if timer_b_1 < TIMER_B_MAX then
				timer_b_1 <= timer_b_1 + 1;
			end if;
		
			-- state machine
			case current_state_4 is
				------------------
				when ST_SRIS =>
					if event4_1 then
						-- no state change
					elsif event4_2 then
						timer_b_1 <= 0;
						current_state_4 <= ST_SRAS;
					elsif event4_3 then
						current_state_4 <= ST_SRNS;
					end if;
				------------------
				when ST_SRAS =>
					if event4_1 then
						current_state_4 <= ST_SRIS;
					elsif event4_5 then
						current_state_4 <= ST_SRNS;
					end if;
				------------------
				when ST_SRNS =>
					if event4_1 then
						current_state_4 <= ST_SRIS;
					elsif event4_4 then
						timer_b_1 <= 0;
						current_state_4 <= ST_SRAS;
					end if;
				------------------
				when others =>
					current_state_4 <= ST_SRIS;
			end case;
		end if;
	end process;

	-- state machine process - C_STATE_5
	process(pon, clk) begin
		-- async reset
		if pon='1' then
			current_state_5 <= ST_SNAS;
		elsif rising_edge(clk) then
			-- state machine
			case current_state_5 is
				------------------
				when ST_SNAS =>
					if event5_1 then
						current_state_5 <= ST_SACS;
					end if;
				------------------
				when ST_SACS =>
					if event5_2 then
						current_state_5 <= ST_SNAS;
					end if;
				------------------
				when others =>
					current_state_5 <= ST_SNAS;
			end case;
		end if;
	end process;

	-- events
	event1_1 <= IFC_in='1' and current_state_5/=ST_SACS;
	event1_2 <= (TCT_in='1' and TADS='1' and ACDS='1') or current_state_3=ST_SIAS;
	event1_3 <= STRS='0';
	event1_4 <= ATN_in='0';
	event1_5 <= TCT_in='1' and TADS='0' and ACDS='1';
	event1_6 <= SDYS='0' and STRS='0' and gts='1';
	event1_7 <= rpp='1';
	event1_8 <= timer_T9Expired and rpp='0';
	event1_9 <= (tcs='1' and ANRS='1') or tca='1';
	event1_10 <= timer_T7Expired;
	event1_11 <= timer_T6Expired;
	event1_12 <= rpp='0';

	event2_1 <= SRQ_in='1';
	event2_2 <= SRQ_in='0';

	event3_1 <= current_state_5/=ST_SACS;
	event3_2 <= current_state_5=ST_SACS and sic='1';
	event3_3 <= current_state_5=ST_SACS and sic='0';
	event3_4 <= sic='1';
	event3_5 <= sic='0' and timer_T8Expired;

	event4_1 <= current_state_5/=ST_SACS;
	event4_2 <= current_state_5=ST_SACS and sre='1';
	event4_3 <= current_state_5=ST_SACS and sre='0';
	event4_4 <= sre='1';
	event4_5 <= sre='0' and timer_T8_1Expired;

	event5_1 <= rsc='1';
	event5_2 <= rsc='0';

	-- timers
	timer_T6Expired <= timer_a >= TIMER_T6_TIMEOUT;
	timer_T7Expired <= timer_a >= TIMER_T7_TIMEOUT;
	timer_T9Expired <= timer_a >= TIMER_T9_TIMEOUT;

	timer_T8Expired <= timer_b >= TIMER_T8_TIMEOUT;
	timer_T8_1Expired <= timer_b_1 >= TIMER_T8_TIMEOUT;


	CPPS <= to_stdl(current_state_1 = ST_CPPS);
	CSRS <= to_stdl(current_state_2 = ST_CSRS);
	CSBS <= to_stdl(current_state_1 = ST_CSBS);
	CACS <= to_stdl(current_state_1 = ST_CACS);
	SACS <= to_stdl(current_state_5 = ST_SACS);
	
	-- CTRS
	with current_state_1 select
		CTRS <=
			'1' when ST_CTRS,
			'0' when others;

	-- ATN
	with current_state_1 select
		ATN_out <=
			'0' when ST_CIDS,
			'0' when ST_CADS,
			'0' when ST_CSBS,
			'1' when others;

	-- IDY_out
	with current_state_1 select
		IDY_out <=
			'1' when ST_CPWS,
			'1' when ST_CPPS,
			'0' when others;

	-- TCT
	with current_state_1 select
		TCT_out <=
			'1' when ST_CTRS,
			'0' when others;

	-- IFC
	with current_state_3 select
		IFC_out <=
			'1' when ST_SIAS,
			'0' when others;

	-- REN
	with current_state_4 select
		REN_out <=
			'1' when ST_SRAS,
			'0' when others;

end Behavioral;


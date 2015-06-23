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
-- Create Date:    01:04:57 10/01/2011 
-- Design Name: 
-- Module Name:    if_func_AH - Behavioral 
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


entity if_func_AH is
	port(
		-- device inputs
		clk : in std_logic; -- clock
		pon : in std_logic; -- power on
		rdy : in std_logic; -- ready for next message
		tcs : in std_logic; -- take control synchronously
		-- state inputs
		LACS : in std_logic; -- listener active state
		LADS : in std_logic; -- listener addressed state
		-- interface inputs
		ATN : in std_logic; -- attention
		DAV : in std_logic; -- data accepted
		-- interface outputs
		RFD : out std_logic; -- ready for data
		DAC : out std_logic; -- data accepted
		-- reported state
		ANRS : out std_logic; -- acceptor not ready state
		ACDS : out std_logic -- accept data state
	);
end if_func_AH;

architecture Behavioral of if_func_AH is

	-- states
	type AH_STATE is (
		-- acceptor idle state
		ST_AIDS,
		-- acceptor not ready state
		ST_ANRS,
		-- acceptor ready state
		ST_ACRS,
		-- acceptor wait for new cycle state
		ST_AWNS,
		-- accept data state
		ST_ACDS
	);

	-- current state
	signal current_state : AH_STATE;

	-- events
	signal event1, event2, event3, event4, event5, event6, event7 : boolean;

	-- timers
	constant TIMER_T3_MAX : integer := 3;
	constant TIMER_T3_TIMEOUT : integer := 2;
	signal timerT3 : integer range 0 to TIMER_T3_MAX;
	signal timerT3Expired : boolean;

begin

	-- state machine process
	process(pon, clk) begin
		if pon = '1' then
			current_state <= ST_AIDS;
		elsif rising_edge(clk) then
			case current_state is
				------------------
				when ST_AIDS =>
					if event2 then
						-- no state change
					elsif event1 then
						current_state <= ST_ANRS;
					end if;
				------------------
				when ST_ANRS =>
					if event2 then
						current_state <= ST_AIDS;
					elsif event4 then
						current_state <= ST_ACRS;
					end if;
				------------------
				when ST_ACRS =>
					if event2 then
						current_state <= ST_AIDS;
					elsif event5 then
						current_state <= ST_ANRS;
					elsif event6 then
						timerT3 <= 0;
						current_state <= ST_ACDS;
					end if;
				------------------
				when ST_ACDS =>
					if event2 then
						current_state <= ST_AIDS;
					elsif event3 then
						current_state <= ST_AWNS;
					end if;
				
					if timerT3 < TIMER_T3_MAX then
						timerT3 <= timerT3 + 1;
					end if;
				------------------
				when ST_AWNS =>
					if event2 then
						current_state <= ST_AIDS;
					elsif event7 then
						current_state <= ST_ANRS;
					end if;
				------------------
				when others =>
					current_state <= ST_AIDS;
			end case;
		end if;
	end process;


	-- events
	event1 <= ATN='1' or LACS='1' or LADS='1';
	event2 <= not(ATN='1' or LACS='1' or LADS='1');
	event3 <= (rdy='0' and ATN='0') or (timerT3Expired and ATN='1');
	event4 <= (ATN='1' or rdy='1') and tcs='0';
	event5 <= not (ATN='1' or rdy='1');
	event6 <= DAV = '1';
	event7 <= DAV = '0';

	-- timers
	timerT3Expired <= timerT3 >= TIMER_T3_TIMEOUT;

	RFD <= to_stdl(
			current_state = ST_AIDS or
			current_state = ST_ACRS
		);

	DAC <= to_stdl(
			current_state = ST_AIDS or
			current_state = ST_AWNS
		);

	ACDS <= to_stdl(current_state = ST_ACDS);
	ANRS <= to_stdl(current_state = ST_ANRS);

end Behavioral;


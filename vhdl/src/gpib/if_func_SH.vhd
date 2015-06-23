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
-- Module Name:    if_func_SH - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.utilPkg.all;

entity if_func_SH is
	port(
		-- device inputs
		clk : in std_logic; -- clock
		-- settingd
		T1 : in std_logic_vector (7 downto 0);
		-- local commands
		pon : in std_logic; -- power on
		nba : in std_logic; -- new byte available
		-- state inputs
		TACS : in std_logic; -- talker active state
		SPAS : in std_logic; -- seriall poll active state
		CACS : in std_logic; -- controller active state
		CTRS : in std_logic; -- controller transfer state
		-- interface inputs
		ATN : in std_logic; -- attention
		DAC : in std_logic; -- data accepted
		RFD : in std_logic; -- ready for data
		-- remote instructions
		DAV : out std_logic; -- data address valid
		-- device outputs
		wnc : out std_logic; -- wait for new cycle
		-- reported states
		STRS : out std_logic; -- source transfer state
		SDYS : out std_logic -- source delay state
	);
end if_func_SH;

architecture Behavioral of if_func_SH is

 -- states
 type SH_STATE is (
  -- source idle state
  ST_SIDS,
  -- source generate state
  ST_SGNS,
  -- source delay state
  ST_SDYS,
  -- source transfer state
  ST_STRS,
  -- source wait for new cycle state
  ST_SWNS,
  -- source idle wait state
  ST_SIWS
 );

	-- current state
	signal current_state : SH_STATE;

	-- predicates
	signal pred1 : boolean;
	signal pred2 : boolean;

	-- timers
	constant TIMER_T1_MAX : integer := 255;
	signal timerT1 : integer range 0 to TIMER_T1_MAX;
	signal timerT1Expired : boolean;

begin

	-- state machine process
	process(pon, clk) begin
		if pon = '1' then
			current_state <= ST_SIDS;
		elsif rising_edge(clk) then
			case current_state is
				------------------
				when ST_SIDS =>
					if pred1 then
						current_state <= ST_SGNS;
					end if;
				------------------
				when ST_SGNS =>
					if nba='1' then
						timerT1 <= 0;
						current_state <= ST_SDYS;
					elsif pred2 then
						current_state <= ST_SIDS;
					end if;
				------------------
				when ST_SDYS =>
					if pred2 then
						current_state <= ST_SIDS;
					elsif RFD='1' and timerT1Expired then
						current_state <= ST_STRS;
					end if;
				
					if timerT1 < TIMER_T1_MAX then
						timerT1 <= timerT1 + 1;
					end if;
				------------------
				when ST_STRS =>
					if DAC='1' then
						current_state <= ST_SWNS;
					elsif pred2 then
						current_state <= ST_SIWS;
					end if;
				------------------
				when ST_SWNS =>
					if nba='0' then
						current_state <= ST_SGNS;
					elsif pred2 then
						current_state <= ST_SIWS;
					end if;
				------------------
				when ST_SIWS =>
					if nba='0' then
						current_state <= ST_SIDS;
					elsif pred1 then
						current_state <= ST_SWNS;
					end if;
				------------------
				when others =>
					current_state <= ST_SIDS;
			end case;
		end if;
	end process;

	-- events
	pred1 <= TACS='1' or SPAS='1' or CACS='1';
	pred2 <= (ATN='1' and not(CACS='1' or CTRS='1')) or
			 (ATN='0' and not(TACS='1' or SPAS='1'));

	-- timers
	timerT1Expired <= timerT1 >= conv_integer(UNSIGNED(T1));

	-- DAV command
	DAV <= to_stdl(current_state = ST_STRS);
	-- wnc command
	wnc <= to_stdl(current_state = ST_SWNS);
	-- STRS command
	STRS <= to_stdl(current_state = ST_STRS);
	-- SDYS command
	SDYS <= to_stdl(current_state = ST_SDYS);

end Behavioral;


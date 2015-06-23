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
-- Module Name:    if_func_PP - Behavioral 
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

entity if_func_PP is
	port(
		-- device inputs
		clk : in std_logic; -- clock
		-- settings
		lpeUsed : std_logic;
		fixedPpLine : in std_logic_vector (2 downto 0);
		-- local commands
		pon : in std_logic; -- power on
		lpe : in std_logic; -- local poll enable
		ist : in std_logic; -- individual status
		-- state inputs
		ACDS : in std_logic; -- accept data state
		LADS : in std_logic; -- listener address state (L or LE)
		-- data input
		dio_data : in std_logic_vector(3 downto 0); -- byte from data lines
		-- remote command inputs
		IDY : in std_logic; -- identify
		PPE : in std_logic; -- parallel poll enable
		PPD : in std_logic; -- parallel poll disable
		PPC : in std_logic; -- parallel poll configure
		PPU : in std_logic; -- parallel poll unconfigure
		PCG : in std_logic; -- primary command group
		-- remote command outputs
		PPR : out std_logic; -- paralel poll response
		-- PPR command data
		ppBitValue : out std_logic; -- bit value
		ppLineNumber : out std_logic_vector (2 downto 0);
		-- reported states
		PPAS : out std_logic -- parallel poll active state
	);
end if_func_PP;

architecture Behavioral of if_func_PP is

	-- states
	type PP_STATE_1 is (
		-- parallel poll idle state
		ST_PPIS,
		-- parallel poll standby state
		ST_PPSS,
		-- parallel poll active state
		ST_PPAS
	);

	-- states
	type PP_STATE_2 is (
		-- parallel poll unaddressed to configure state
		ST_PUCS,
		-- parallel poll addressed to configure state
		ST_PACS
	);

	-- current state
	signal current_state_1 : PP_STATE_1;
	signal current_state_2 : PP_STATE_2;

	-- predicates
	signal pred1, pred2, pred3, pred4, pred5 : boolean;

	-- memorized PP metadata
	signal S : std_logic;
	signal lineAddr : std_logic_vector (2 downto 0);

begin

	-- state machine process - PP_STATE_1
	process(pon, clk) begin
		if pon = '1' then
			current_state_1 <= ST_PPIS;
		elsif rising_edge(clk) then
			case current_state_1 is
				------------------
				when ST_PPIS =>
					if pred1 then
						S <= dio_data(3);
						lineAddr <= dio_data(2 downto 0);
						current_state_1 <= ST_PPSS;
					end if;
				------------------
				when ST_PPSS =>
					if pred3 then
						current_state_1 <= ST_PPAS;
					elsif pred2 then
						current_state_1 <= ST_PPIS;
					end if;
				------------------
				when ST_PPAS =>
					if not pred3 then
						current_state_1 <= ST_PPSS;
					end if;
				------------------
				when others =>
					current_state_1 <= ST_PPIS;
			end case;
		end if;
	end process;

	-- state machine process - PP_STATE_2
	process(pon, clk) begin
		if pon = '1' then
			current_state_2 <= ST_PUCS;
		elsif rising_edge(clk) then
			case current_state_2 is
				------------------
				when ST_PUCS =>
					if pred4 then
						current_state_2 <= ST_PACS;
					end if;
				------------------
				when ST_PACS =>
					if pred5 then
						current_state_2 <= ST_PUCS;
					end if;
				------------------
				when others =>
					current_state_2 <= ST_PUCS;
			end case;
		end if;
	end process;

	ppBitValue <= (not S xor ist) when lpeUsed='0' else ist;
	ppLineNumber <= lineAddr when lpeUsed='0' else fixedPpLine;
	PPR <= to_stdl(current_state_1 = ST_PPAS);
	PPAS <= to_stdl(current_state_1 = ST_PPAS);

	-- predicates
	with lpeUsed select
		pred1 <=
			is_1(lpe) when '1',
			PPE='1' and current_state_2=ST_PACS and ACDS='1' when others;

	with lpeUsed select
		pred2 <=
			is_1(not lpe) when '1',
			((PPD='1' and current_state_2=ST_PACS) or PPU='1') and ACDS='1'
				when others;

	pred3 <= IDY='1';
	pred4 <= PPC='1' and LADS='1' and ACDS='1';
	pred5 <= PCG='1' and PPC='0' and ACDS='1';


end Behavioral;

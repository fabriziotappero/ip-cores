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
-- Entity: EventReg
-- Date:2011-11-11  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.helperComponents.all;


entity EventReg is
	port (
		reset : in std_logic;
		clk : in std_logic;
		strobe : in std_logic;
		data_in : in std_logic_vector (15 downto 0);
		data_out : out std_logic_vector (15 downto 0);
		-------------------- gpib device ---------------------
		-- device is local controlled
		isLocal : in std_logic;
		-- input buffer ready
		in_buf_ready : in std_logic;
		-- output buffer ready
		out_buf_ready : in std_logic;
		-- clear device (DC)
		clr : in std_logic;
		-- trigger device (DT)
		trg : in std_logic;
		-- addressed to talk(L or LE)
		att : in std_logic;
		-- addressed to listen (T or TE)
		atl : in std_logic;
		-- seriall poll active
		spa : in std_logic;
		-------------------- gpib controller ---------------------
		-- controller write commands
		cwrc : in std_logic;
		-- controller write data
		cwrd : in std_logic;
		-- service requested
		srq : in std_logic;
		-- parallel poll ready
		ppr : in std_logic;
		-- stb received
		stb_received : in std_logic;
		REN : in std_logic;
		ATN : in std_logic;
		IFC : in std_logic
	);
end EventReg;

architecture arch of EventReg is

	signal i_clr : std_logic;
	signal i_trg : std_logic;
	signal i_srq : std_logic;

	signal clr_app : std_logic;
	signal trg_app : std_logic;
	signal srq_app : std_logic;
	
	signal t_clr_in, t_clr_out : std_logic;
	signal t_trg_in, t_trg_out : std_logic;
	signal t_srq_in, t_srq_out : std_logic;

begin

	data_out(0) <= isLocal;
	data_out(1) <= in_buf_ready;
	data_out(2) <= out_buf_ready;
	data_out(3) <= i_clr;
	data_out(4) <= i_trg;
	data_out(5) <= att;
	data_out(6) <= atl;
	data_out(7) <= spa;
	data_out(8) <= cwrc;
	data_out(9) <= cwrd;
	data_out(10) <= i_srq;
	data_out(11) <= ppr;
	data_out(12) <= stb_received;
	data_out(13) <= REN;
	data_out(14) <= ATN;
	data_out(15) <= IFC;

	process (reset, strobe) begin
		if reset = '1' then
			t_clr_in <= '0';
			t_trg_in <= '0';
			t_srq_in <= '0';
		elsif rising_edge(strobe) then
			if data_in(3) = '0' then
				t_clr_in <= not t_clr_out;
			elsif data_in(4) = '0' then
				t_trg_in <= not t_trg_out;
			elsif data_in(10) = '0' then
				t_srq_in <= not t_srq_out;
			end if;
		end if;
	end process;

	EVM1: EventMem port map (
		reset => reset, occured => clr, approved => clr_app,
		output => i_clr
	);

	SPG1: SinglePulseGenerator generic map (WIDTH => 1) port map(
		reset => reset, clk => clk,
		t_in => t_clr_in, t_out => t_clr_out,
		pulse => clr_app
	);

	EVM2: EventMem port map (
		reset => reset, occured => trg, approved => trg_app,
		output => i_trg
	);

	SPG2: SinglePulseGenerator generic map (WIDTH => 1) port map(
		reset => reset, clk => clk,
		t_in => t_trg_in, t_out => t_trg_out,
		pulse => trg_app
	);
	
	EVM3: EventMem port map (
		reset => reset, occured => srq, approved => srq_app,
		output => i_srq
	);

	SPG3: SinglePulseGenerator generic map (WIDTH => 1) port map(
		reset => reset, clk => clk,
		t_in => t_srq_in, t_out => t_srq_out,
		pulse => srq_app
	);

end arch;


--
--  Wishbone bus toolkit.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--
-- ELEMENTS:
--   wb_arbiter: two-way bus arbiter. Asyncronous logic ensures 0-ws operation on shared bus

-------------------------------------------------------------------------------
--
--  wb_arbiter
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library wb_tk;
use wb_tk.technology.all;

entity wb_arbiter is
	port (
--		clk: in std_logic;
		rst_i: in std_logic := '0';

		-- interface to master device a
		a_we_i: in std_logic;
		a_stb_i: in std_logic;
		a_cyc_i: in std_logic;
		a_ack_o: out std_logic;
		a_ack_oi: in std_logic := '-';
		a_err_o: out std_logic;
		a_err_oi: in std_logic := '-';
		a_rty_o: out std_logic;
		a_rty_oi: in std_logic := '-';

		-- interface to master device b
		b_we_i: in std_logic;
		b_stb_i: in std_logic;
		b_cyc_i: in std_logic;
		b_ack_o: out std_logic;
		b_ack_oi: in std_logic := '-';
		b_err_o: out std_logic;
		b_err_oi: in std_logic := '-';
		b_rty_o: out std_logic;
		b_rty_oi: in std_logic := '-';

		-- interface to shared devices
		s_we_o: out std_logic;
		s_stb_o: out std_logic;
		s_cyc_o: out std_logic;
		s_ack_i: in std_logic;
		s_err_i: in std_logic := '-';
		s_rty_i: in std_logic := '-';

		mux_signal: out std_logic; -- 0: select A signals, 1: select B signals

		-- misc control lines
		priority: in std_logic -- 0: A have priority over B, 1: B have priority over A
	);
end wb_arbiter;

-- This acthitecture is a clean asyncron state-machine. However it cannot be mapped to FPGA architecture
architecture behaviour of wb_arbiter is
	type states is (idle,aa,ba);
	signal i_mux_signal: std_logic;

	signal e_state: states;
begin
	mux_signal <= i_mux_signal;

	sm: process
		variable state: states;
	begin
		wait on a_cyc_i, b_cyc_i, priority, rst_i;
		if (rst_i = '1') then
			state := idle;
			i_mux_signal <= priority;
		else
			case (state) is
				when idle =>
					if (a_cyc_i = '1' and (priority = '0' or b_cyc_i = '0')) then
						state := aa;
						i_mux_signal <= '0';
					elsif (b_cyc_i = '1' and (priority = '1' or a_cyc_i = '0')) then
						state := ba;
						i_mux_signal <= '1';
					else
						i_mux_signal <= priority;
					end if;
				when aa =>
					if (a_cyc_i = '0') then
						if (b_cyc_i = '1') then
							state := ba;
							i_mux_signal <= '1';
						else
							state := idle;
							i_mux_signal <= priority;
						end if;
					else
						i_mux_signal <= '0';
					end if;
				when ba =>
					if (b_cyc_i = '0') then
						if (a_cyc_i = '1') then
							state := aa;
							i_mux_signal <= '0';
						else
							state := idle;
							i_mux_signal <= priority;
						end if;
					else
						i_mux_signal <= '1';
					end if;
			end case;
		end if;
		e_state <= state;
	end process;

	signal_mux: process
	begin
		wait on a_we_i, a_stb_i, a_ack_oi, a_err_oi, a_rty_oi, a_cyc_i,
				b_we_i, b_stb_i, b_ack_oi, b_err_oi, b_rty_oi, b_cyc_i,
				s_ack_i, s_err_i, s_rty_i, i_mux_signal;
		if (i_mux_signal = '0') then
			s_we_o <= a_we_i;
			s_stb_o <= a_stb_i;
			s_cyc_o <= a_cyc_i;
			a_ack_o <= (a_stb_i and s_ack_i) or (not a_stb_i and a_ack_oi);
			a_err_o <= (a_stb_i and s_err_i) or (not a_stb_i and a_err_oi);
			a_rty_o <= (a_stb_i and s_rty_i) or (not a_stb_i and a_rty_oi);
			b_ack_o <= (b_stb_i and '0') or (not b_stb_i and b_ack_oi);
			b_err_o <= (b_stb_i and '0') or (not b_stb_i and b_err_oi);
			b_rty_o <= (b_stb_i and '0') or (not b_stb_i and b_rty_oi);
		else
			s_we_o <= b_we_i;
			s_stb_o <= b_stb_i;
			s_cyc_o <= b_cyc_i;
			b_ack_o <= (b_stb_i and s_ack_i) or (not b_stb_i and b_ack_oi);
			b_err_o <= (b_stb_i and s_err_i) or (not b_stb_i and b_err_oi);
			b_rty_o <= (b_stb_i and s_rty_i) or (not b_stb_i and b_rty_oi);
			a_ack_o <= (a_stb_i and '0') or (not a_stb_i and a_ack_oi);
			a_err_o <= (a_stb_i and '0') or (not a_stb_i and a_err_oi);
			a_rty_o <= (a_stb_i and '0') or (not a_stb_i and a_rty_oi);
		end if;
	end process;
end behaviour;

-- This acthitecture is a more-or-less structural implementation. Fits for FPGA realization.
architecture FPGA of wb_arbiter is
	component d_ff
		port (  d  :  in STD_LOGIC;
				clk:  in STD_LOGIC;
				ena:  in STD_LOGIC := '1';
				clr:  in STD_LOGIC := '0';
				pre:  in STD_LOGIC := '0';
				q  :  out STD_LOGIC
		);
	end component;

	signal i_mux_signal: std_logic;

	type states is (idle,aa,ba,XX);
	signal e_state: states;

	-- signals for a DFF in FPGA
	signal idle_s, aa_s, ba_s: std_logic;

	signal aa_clk, aa_ena, aa_clr, aa_pre: std_logic;
	signal ba_clk, ba_ena, ba_clr, ba_pre: std_logic;

	signal one: std_logic := '1';
begin
	one <= '1';
	mux_signal <= i_mux_signal;

	idle_s <= not (a_cyc_i or b_cyc_i);

	aa_clr <= rst_i or not a_cyc_i;
	aa_clk <= a_cyc_i;
	aa_ena <= not b_cyc_i and priority;
	aa_pre <= (a_cyc_i and not priority and not ba_s) or (a_cyc_i and not b_cyc_i);
	aa_ff: d_ff port map (
		d => one,
		clk => aa_clk,
		ena => aa_ena,
		clr => aa_clr,
		pre => aa_pre,
		q => aa_s
	);

	ba_clr <= rst_i or not b_cyc_i;
	ba_clk <= b_cyc_i;
	ba_ena <= not a_cyc_i and not priority;
	ba_pre <= (b_cyc_i and priority and not aa_s) or (b_cyc_i and not a_cyc_i);
	ba_ff: d_ff port map (
		d => one,
		clk => ba_clk,
		ena => ba_ena,
		clr => ba_clr,
		pre => ba_pre,
		q => ba_s
	);

	i_mux_signal <= (priority and idle_s) or ba_s;

	signal_mux: process
	begin
		wait on a_we_i, a_stb_i, a_ack_oi, a_err_oi, a_rty_oi, a_cyc_i,
				b_we_i, b_stb_i, b_ack_oi, b_err_oi, b_rty_oi, b_cyc_i,
				s_ack_i, s_err_i, s_rty_i, i_mux_signal;
		if (i_mux_signal = '0') then
			s_we_o <= a_we_i;
			s_stb_o <= a_stb_i;
			s_cyc_o <= a_cyc_i;
			a_ack_o <= (a_stb_i and s_ack_i) or (not a_stb_i and a_ack_oi);
			a_err_o <= (a_stb_i and s_err_i) or (not a_stb_i and a_err_oi);
			a_rty_o <= (a_stb_i and s_rty_i) or (not a_stb_i and a_rty_oi);
			b_ack_o <= (b_stb_i and '0') or (not b_stb_i and b_ack_oi);
			b_err_o <= (b_stb_i and '0') or (not b_stb_i and b_err_oi);
			b_rty_o <= (b_stb_i and '0') or (not b_stb_i and b_rty_oi);
		else
			s_we_o <= b_we_i;
			s_stb_o <= b_stb_i;
			s_cyc_o <= b_cyc_i;
			b_ack_o <= (b_stb_i and s_ack_i) or (not b_stb_i and b_ack_oi);
			b_err_o <= (b_stb_i and s_err_i) or (not b_stb_i and b_err_oi);
			b_rty_o <= (b_stb_i and s_rty_i) or (not b_stb_i and b_rty_oi);
			a_ack_o <= (a_stb_i and '0') or (not a_stb_i and a_ack_oi);
			a_err_o <= (a_stb_i and '0') or (not a_stb_i and a_err_oi);
			a_rty_o <= (a_stb_i and '0') or (not a_stb_i and a_rty_oi);
		end if;
	end process;

	gen_e_state: process
	begin
		wait on idle_s,aa_s,ba_s;
		   if (idle_s = '1' and ba_s = '0' and aa_s = '0') then e_state <= idle;
		elsif (idle_s = '0' and ba_s = '1' and aa_s = '0') then e_state <= aa;
		elsif (idle_s = '0' and ba_s = '0' and aa_s = '1') then e_state <= ba;
		else                                                    e_state <= XX;
		end if;
	end process;
end FPGA;


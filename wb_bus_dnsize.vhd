--
--  Wishbone bus toolkit.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--
-- ELEMENTS:
--   wb_bus_dnsize: bus downsizer.
--   doesn't split access cycles so granularity on the input bus must not be greater than
--   the width of the output bus.

-------------------------------------------------------------------------------
--
--  wb_bus_upsize
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library wb_tk;
use wb_tk.technology.all;

entity wb_bus_dnsize is
	generic (
		m_dat_width: positive := 32; -- master bus width
		m_adr_width: positive := 20; -- master bus width
		s_dat_width: positive := 16; -- slave bus width
		s_adr_width: positive := 21; -- master bus width
		little_endien: boolean := true -- if set to false, big endien
	);
	port (
--		clk_i: in std_logic;
--		rst_i: in std_logic := '0';

		-- Master bus interface
		m_adr_i: in std_logic_vector (m_adr_width-1 downto 0);
		m_sel_i: in std_logic_vector ((m_dat_width/8)-1 downto 0) := (others => '1');
		m_dat_i: in std_logic_vector (m_dat_width-1 downto 0);
		m_dat_oi: in std_logic_vector (m_dat_width-1 downto 0) := (others => '-');
		m_dat_o: out std_logic_vector (m_dat_width-1 downto 0);
		m_cyc_i: in std_logic;
		m_ack_o: out std_logic;
		m_ack_oi: in std_logic := '-';
		m_err_o: out std_logic;
		m_err_oi: in std_logic := '-';
		m_rty_o: out std_logic;
		m_rty_oi: in std_logic := '-';
		m_we_i: in std_logic;
		m_stb_i: in std_logic;

		-- Slave bus interface
		s_adr_o: out std_logic_vector (s_adr_width-1 downto 0);
		s_sel_o: out std_logic_vector ((s_dat_width/8)-1 downto 0);
		s_dat_i: in std_logic_vector (s_dat_width-1 downto 0);
		s_dat_o: out std_logic_vector (s_dat_width-1 downto 0);
		s_cyc_o: out std_logic;
		s_ack_i: in std_logic;
		s_err_i: in std_logic := '-';
		s_rty_i: in std_logic := '-';
		s_we_o: out std_logic;
		s_stb_o: out std_logic
	);
end wb_bus_dnsize;

architecture wb_bus_dnsize of wb_bus_dnsize is
	constant addr_diff: integer := log2(m_dat_width/s_dat_width);
	constant mux_mask: integer := ((m_dat_width / 8)-1) - ((s_dat_width/8)-1);
	signal i_m_dat_o: std_logic_vector(m_dat_width-1 downto 0);
	signal mux_sel: std_logic_vector(log2(m_sel_i'HIGH+1)-1 downto 0);
	signal i_mux_sel: integer := 0;

	function prior_decode(inp: std_logic_vector) return integer is
	begin
--	    variable ret: std_logic_vector(log2(inp'HIGH)-1 downto 0) := (others = '1');
		for i in inp'HIGH downto 0 loop
			if (inp(i) = '1') then
				return i;
			end if;
		end loop;
		return inp'HIGH;
	end;
begin
	assert (s_adr_width = m_adr_width+addr_diff) report "Address widths are not consistent" severity FAILURE;

	-- Reconstructing address bits (mux_sel)
	compute_mux_sel: process(m_sel_i)
		variable i: integer;
	begin
--		wait on m_sel_i;
		i := prior_decode(m_sel_i);
		mux_sel <= to_std_logic_vector(i,log2(m_sel_i'HIGH+1)) and to_std_logic_vector(mux_mask,log2(m_sel_i'HIGH+1));
	end process;
	i_mux_sel <= to_integer(mux_sel);


	-- create slave address bus
	s_adr_o(s_adr_width-1 downto addr_diff) <= m_adr_i;
	s_adr_o_gen: process
		variable all_ones: std_logic_vector(addr_diff-1 downto 0) := (others => '1');
	begin
--:::TA This does not work under webpack. Re-simulate!!!!
--		wait on mux_sel(mux_sel'HIGH downto mux_sel'HIGH-addr_diff+1);
		wait on mux_sel;
		if (little_endien) then
			s_adr_o(addr_diff-1 downto 0) <= mux_sel(mux_sel'HIGH downto mux_sel'HIGH-addr_diff+1);
		else
			s_adr_o(addr_diff-1 downto 0) <= all_ones-mux_sel(mux_sel'HIGH downto mux_sel'HIGH-addr_diff+1);
		end if;
	end process;

	-- create output byte select signals
	s_sel_o <= m_sel_i(i_mux_sel+(s_dat_width/8)-1 downto i_mux_sel);


	s_we_o <= m_we_i;
	m_ack_o <= (m_stb_i and s_ack_i) or (not m_stb_i and m_ack_oi);
	m_err_o <= (m_stb_i and s_err_i) or (not m_stb_i and m_err_oi);
	m_rty_o <= (m_stb_i and s_rty_i) or (not m_stb_i and m_rty_oi);
	s_stb_o <= m_stb_i;
	s_cyc_o <= m_cyc_i;

	-- Multiplex data-bus down to the slave width
	s_dat_o <= m_dat_i((i_mux_sel)*8-1+s_dat_width downto (i_mux_sel)*8);

	m_dat_o_mux: process
	begin
		wait on m_dat_oi, s_dat_i, i_mux_sel, m_stb_i, m_we_i;
		m_dat_o <= m_dat_oi;
		if (m_stb_i = '1' and m_we_i = '0') then
			m_dat_o((i_mux_sel)*8-1+s_dat_width downto (i_mux_sel)*8) <= s_dat_i;
		end if;
	end process;
end wb_bus_dnsize;


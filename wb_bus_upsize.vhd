--
--  Wishbone bus toolkit.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--
-- ELEMENTS:
--   wb_bus_upsize: bus upsizer.

-------------------------------------------------------------------------------
--
--  wb_bus_upsize
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library wb_tk;
use wb_tk.technology.all;

entity wb_bus_upsize is
	generic (
		m_dat_width: positive := 8; -- master bus width
		m_adr_width: positive := 21; -- master bus width
		s_dat_width: positive := 16; -- slave bus width
		s_adr_width: positive := 20; -- master bus width
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
end wb_bus_upsize;

architecture wb_bus_upsize of wb_bus_upsize is
	constant addr_diff: integer := log2(s_dat_width/m_dat_width);
	signal i_m_dat_o: std_logic_vector(m_dat_width-1 downto 0);
begin
	assert (m_adr_width = s_adr_width+addr_diff) report "Address widths are not consistent" severity FAILURE;
	s_adr_o <= m_adr_i(m_adr_width-addr_diff downto addr_diff);
	s_we_o <= m_we_i;
	m_ack_o <= (m_stb_i and s_ack_i) or (not m_stb_i and m_ack_oi);
	m_err_o <= (m_stb_i and s_err_i) or (not m_stb_i and m_err_oi);
	m_rty_o <= (m_stb_i and s_rty_i) or (not m_stb_i and m_rty_oi);
	s_stb_o <= m_stb_i;
	s_cyc_o <= m_cyc_i;


	sel_dat_mux: process
	begin
		wait on s_dat_i, m_adr_i;
		if (little_endien) then
			for i in s_sel_o'RANGE loop
				if (equ(m_adr_i(addr_diff-1 downto 0),i)) then
					s_sel_o(i) <= '1';
					i_m_dat_o <= s_dat_i(8*i+7 downto 8*i+0);
				else
					s_sel_o(i) <= '0';
				end if;
			end loop;
		else
			for i in s_sel_o'RANGE loop
				if (equ(m_adr_i(addr_diff-1 downto 0),i)) then
					s_sel_o(s_sel_o'HIGH-i) <= '1';
					i_m_dat_o <= s_dat_i(s_dat_i'HIGH-8*i downto s_dat_i'HIGH-8*i-7);
				else
					s_sel_o(s_sel_o'HIGH-i) <= '0';
				end if;
			end loop;
		end if;
	end process;

	d_i_for: for i in m_dat_o'RANGE generate
		m_dat_o(i) <= (m_stb_i and i_m_dat_o(i)) or (not m_stb_i and m_dat_oi(i));
	end generate;

	d_o_for: for i in s_sel_o'RANGE generate
		s_dat_o(8*i+7 downto 8*i+0) <= m_dat_i;
	end generate;
end wb_bus_upsize;


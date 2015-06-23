--
--  Wishbone bus toolkit.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--
-- ELEMENTS:
--   wb_bus_resize: bus resizer.

-------------------------------------------------------------------------------
--
--  wb_bus_resize
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library wb_tk;
use wb_tk.technology.all;
use wb_tk.all;

entity wb_bus_resize is
	generic (
		m_bus_width: positive := 32; -- master bus width
		m_addr_width: positive := 19; -- master bus width
		s_bus_width: positive := 16; -- slave bus width
		s_addr_width: positive := 20; -- master bus width
		little_endien: boolean := true -- if set to false, big endien
	);
	port (
--		clk_i: in std_logic;
--		rst_i: in std_logic := '0';

		-- Master bus interface
		m_adr_i: in std_logic_vector (m_addr_width-1 downto 0);
		m_sel_i: in std_logic_vector ((m_bus_width/8)-1 downto 0) := (others => '1');
		m_dat_i: in std_logic_vector (m_bus_width-1 downto 0);
		m_dat_oi: in std_logic_vector (m_bus_width-1 downto 0) := (others => '-');
		m_dat_o: out std_logic_vector (m_bus_width-1 downto 0);
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
		s_adr_o: out std_logic_vector (s_addr_width-1 downto 0);
		s_sel_o: out std_logic_vector ((s_bus_width/8)-1 downto 0);
		s_dat_i: in std_logic_vector (s_bus_width-1 downto 0);
		s_dat_o: out std_logic_vector (s_bus_width-1 downto 0);
		s_cyc_o: out std_logic;
		s_ack_i: in std_logic;
		s_err_i: in std_logic := '-';
		s_rty_i: in std_logic := '-';
		s_we_o: out std_logic;
		s_stb_o: out std_logic
	);
end wb_bus_resize;

architecture wb_bus_resize of wb_bus_resize is
	component wb_bus_upsize is
		generic (
			m_bus_width: positive := 8; -- master bus width
			m_addr_width: positive := 21; -- master bus width
			s_bus_width: positive := 16; -- slave bus width
			s_addr_width: positive := 20; -- master bus width
			little_endien: boolean := true -- if set to false, big endien
		);
		port (
	--		clk_i: in std_logic;
	--		rst_i: in std_logic := '0';
	
			-- Master bus interface
			m_adr_i: in std_logic_vector (m_addr_width-1 downto 0);
			m_sel_i: in std_logic_vector ((m_bus_width/8)-1 downto 0) := (others => '1');
			m_dat_i: in std_logic_vector (m_bus_width-1 downto 0);
			m_dat_oi: in std_logic_vector (m_bus_width-1 downto 0) := (others => '-');
			m_dat_o: out std_logic_vector (m_bus_width-1 downto 0);
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
			s_adr_o: out std_logic_vector (s_addr_width-1 downto 0);
			s_sel_o: out std_logic_vector ((s_bus_width/8)-1 downto 0);
			s_dat_i: in std_logic_vector (s_bus_width-1 downto 0);
			s_dat_o: out std_logic_vector (s_bus_width-1 downto 0);
			s_cyc_o: out std_logic;
			s_ack_i: in std_logic;
			s_err_i: in std_logic := '-';
			s_rty_i: in std_logic := '-';
			s_we_o: out std_logic;
			s_stb_o: out std_logic
		);
	end component;

	component wb_bus_dnsize is
		generic (
			m_bus_width: positive := 32; -- master bus width
			m_addr_width: positive := 20; -- master bus width
			s_bus_width: positive := 16; -- slave bus width
			s_addr_width: positive := 21; -- master bus width
			little_endien: boolean := true -- if set to false, big endien
		);
		port (
	--		clk_i: in std_logic;
	--		rst_i: in std_logic := '0';
	
			-- Master bus interface
			m_adr_i: in std_logic_vector (m_addr_width-1 downto 0);
			m_sel_i: in std_logic_vector ((m_bus_width/8)-1 downto 0) := (others => '1');
			m_dat_i: in std_logic_vector (m_bus_width-1 downto 0);
			m_dat_oi: in std_logic_vector (m_bus_width-1 downto 0) := (others => '-');
			m_dat_o: out std_logic_vector (m_bus_width-1 downto 0);
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
			s_adr_o: out std_logic_vector (s_addr_width-1 downto 0);
			s_sel_o: out std_logic_vector ((s_bus_width/8)-1 downto 0);
			s_dat_i: in std_logic_vector (s_bus_width-1 downto 0);
			s_dat_o: out std_logic_vector (s_bus_width-1 downto 0);
			s_cyc_o: out std_logic;
			s_ack_i: in std_logic;
			s_err_i: in std_logic := '-';
			s_rty_i: in std_logic := '-';
			s_we_o: out std_logic;
			s_stb_o: out std_logic
		);
	end component;
begin
	dn_sel: if (m_bus_width > s_bus_width) generate
		dnsizer: wb_bus_dnsize
			generic map (
				m_bus_width => m_bus_width,
				m_addr_width => m_addr_width,
				s_bus_width => s_bus_width,
				s_addr_width => s_addr_width,
				little_endien => little_endien
			)
			port map
				(m_adr_i => m_adr_i,
				m_sel_i => m_sel_i,
				m_dat_i => m_dat_i,
				m_dat_oi => m_dat_oi,
				m_dat_o => m_dat_o,
				m_cyc_i => m_cyc_i,
				m_ack_o => m_ack_o,
				m_ack_oi => m_ack_oi,
				m_err_o => m_err_o,
				m_err_oi => m_err_oi,
				m_rty_o => m_rty_o,
				m_rty_oi => m_rty_oi,
				m_we_i => m_we_i,
				m_stb_i => m_stb_i,
				s_adr_o => s_adr_o,
				s_sel_o => s_sel_o,
				s_dat_i => s_dat_i,
				s_dat_o => s_dat_o,
				s_cyc_o => s_cyc_o,
				s_ack_i => s_ack_i,
				s_err_i => s_err_i,
				s_rty_i => s_rty_i,
				s_we_o => s_we_o,
				s_stb_o => s_stb_o
			);
	end generate;
	up_sel: if (m_bus_width < s_bus_width) generate
		upsizer: wb_bus_upsize
			generic map (
				m_bus_width => m_bus_width,
				m_addr_width => m_addr_width,
				s_bus_width => s_bus_width,
				s_addr_width => s_addr_width,
				little_endien => little_endien
			)
			port map
				(m_adr_i => m_adr_i,
				m_sel_i => m_sel_i,
				m_dat_i => m_dat_i,
				m_dat_oi => m_dat_oi,
				m_dat_o => m_dat_o,
				m_cyc_i => m_cyc_i,
				m_ack_o => m_ack_o,
				m_ack_oi => m_ack_oi,
				m_err_o => m_err_o,
				m_err_oi => m_err_oi,
				m_rty_o => m_rty_o,
				m_rty_oi => m_rty_oi,
				m_we_i => m_we_i,
				m_stb_i => m_stb_i,
				s_adr_o => s_adr_o,
				s_sel_o => s_sel_o,
				s_dat_i => s_dat_i,
				s_dat_o => s_dat_o,
				s_cyc_o => s_cyc_o,
				s_ack_i => s_ack_i,
				s_err_i => s_err_i,
				s_rty_i => s_rty_i,
				s_we_o => s_we_o,
				s_stb_o => s_stb_o
			);
	end generate;
	eq_sel: if (m_bus_width = s_bus_width) generate
		dat_o_for: for i in m_dat_o'RANGE generate
			dat_o_gen: m_dat_o(i) <= (s_dat_i(i) and m_stb_i and not m_we_i) or (m_dat_oi(i) and not (m_stb_i and not m_we_i));
		end generate;
		m_ack_o <= (s_ack_i and m_stb_i and not m_we_i) or (m_ack_oi and not (m_stb_i and not m_we_i));
		m_err_o <= (s_err_i and m_stb_i and not m_we_i) or (m_err_oi and not (m_stb_i and not m_we_i));
		m_rty_o <= (s_rty_i and m_stb_i and not m_we_i) or (m_rty_oi and not (m_stb_i and not m_we_i));
		s_adr_o <= m_adr_i;
		s_sel_o <= m_sel_i;
		s_dat_o <= m_dat_i;
		s_cyc_o <= m_cyc_i;
		s_we_o <= m_we_i;
		s_stb_o <= m_stb_i;
	end generate;
end wb_bus_resize;

--configuration c_wb_bus_resize of wb_bus_resize is
--    for wb_bus_resize
--        for dnsizer: wb_bus_dnsize
--            use entity wb_bus_dnsize(wb_bus_dnsize);
--        end for;
--        for upsizer: wb_bus_upsize
--            use entity wb_bus_upsize(wb_bus_upsize);
--        end for;
--    end for;
--end c_wb_bus_resize;


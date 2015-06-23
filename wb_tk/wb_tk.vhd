--
--  Wishbone bus toolkit.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--
-- ELEMENTS:
--   wb_bus_upsize: bus upsizer. Currently only 8->16 bit bus resize is supported
--   wb_async_slave: Wishbone bus to async (SRAM-like) bus slave bridge.
--   wb_arbiter: two-way bus arbiter. Asyncronous logic ensures 0-ws operation on shared bus
--   wb_out_reg: Wishbone bus compatible output register.
--   wb_bus_resize: Wishbone bus resizer.

library IEEE;
use IEEE.std_logic_1164.all;
library wb_tk;
use wb_tk.technology.all;

package wb_tk is
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
	
	component wb_bus_resize is
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
	
	component wb_async_master is
		generic (
			width: positive := 16;
			addr_width: positive := 20
		);
		port (
			clk_i: in std_logic;
			rst_i: in std_logic := '0';
			
			-- interface to wb slave devices
			s_adr_o: out std_logic_vector (addr_width-1 downto 0);
			s_sel_o: out std_logic_vector ((width/8)-1 downto 0);
			s_dat_i: in std_logic_vector (width-1 downto 0);
			s_dat_o: out std_logic_vector (width-1 downto 0);
			s_cyc_o: out std_logic;
			s_ack_i: in std_logic;
			s_err_i: in std_logic := '-';
			s_rty_i: in std_logic := '-';
			s_we_o: out std_logic;
			s_stb_o: out std_logic;

			-- interface to asyncron master device
			a_data: inout std_logic_vector (width-1 downto 0) := (others => 'Z');
			a_addr: in std_logic_vector (addr_width-1 downto 0) := (others => 'U');
			a_rdn: in std_logic := '1';
			a_wrn: in std_logic := '1';
			a_cen: in std_logic := '1';
			a_byen: in std_logic_vector ((width/8)-1 downto 0);
			a_waitn: out std_logic
		);
	end component;
	
	component wb_async_slave is
		generic (
			width: positive := 16;
			addr_width: positive := 20
		);
		port (
			clk_i: in std_logic;
			rst_i: in std_logic := '0';
			
			-- interface for wait-state generator state-machine
			wait_state: in std_logic_vector (3 downto 0);
	
			-- interface to wishbone master device
			adr_i: in std_logic_vector (addr_width-1 downto 0);
			sel_i: in std_logic_vector ((addr_width/8)-1 downto 0);
			dat_i: in std_logic_vector (width-1 downto 0);
			dat_o: out std_logic_vector (width-1 downto 0);
			dat_oi: in std_logic_vector (width-1 downto 0) := (others => '-');
			we_i: in std_logic;
			stb_i: in std_logic;
			ack_o: out std_logic := '0';
			ack_oi: in std_logic := '-';
		
			-- interface to async slave
			a_data: inout std_logic_vector (width-1 downto 0) := (others => 'Z');
			a_addr: out std_logic_vector (addr_width-1 downto 0) := (others => 'U');
			a_rdn: out std_logic := '1';
			a_wrn: out std_logic := '1';
			a_cen: out std_logic := '1';
			-- byte-enable signals
			a_byen: out std_logic_vector ((width/8)-1 downto 0)
		);
	end component;
	
	component wb_arbiter is
		port (
	--		clk_i: in std_logic;
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
	end component;
	
	component wb_out_reg is
    	generic (
    		width : positive := 8;
    		bus_width: positive := 8;
    		offset: integer := 0
    	);
    	port (
    		clk_i: in std_logic;
    		rst_i: in std_logic;
    		rst_val: std_logic_vector(width-1 downto 0) := (others => '0');
    
            cyc_i: in std_logic := '1';
    		stb_i: in std_logic;
            sel_i: in std_logic_vector ((bus_width/8)-1 downto 0) := (others => '1');
    		we_i: in std_logic;
    		ack_o: out std_logic;
    		ack_oi: in std_logic := '-';
    		adr_i: in std_logic_vector (size2bits((width+offset+bus_width-1)/bus_width)-1 downto 0) := (others => '0');
    		dat_i: in std_logic_vector (bus_width-1 downto 0);
    		dat_oi: in std_logic_vector (bus_width-1 downto 0) := (others => '-');
    		dat_o: out std_logic_vector (bus_width-1 downto 0);
    		q: out std_logic_vector (width-1 downto 0)
    	);
	end component;
end wb_tk;


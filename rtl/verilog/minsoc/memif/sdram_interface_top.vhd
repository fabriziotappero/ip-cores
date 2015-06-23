-- Xiang Li, olivercamel@gmail.com
-- Last Revised: 2008/06/27
--
-- This is an interface for the SDRAM IS42S16160B of DE2-70 Board.
-- The interface only includes tri-state logic for external pins.
-- All read/write timing logics are implemented by Memory Controller (MC) Core.
--
-- The SDRAM is 64 MBytes.
-- The SDRAM address is configured as: 0x2000_0000 - 0x23FF_FFFC,
-- as the Memory Controller is attached to conmax slave 2.
--
-- The MC registers in our system could config as following
-- (Only valid at 50MHz system clk):
-- CSR     0x2800_0000: 0x1700_0300
-- POC     0x2800_0004: 0x0000_0002 This is done in mc_defines.v
-- BA_MASK 0x2800_0008: 0x0000_0020 Only judge addr(26)
-- CSC0    0x2800_0018: 0x0000_0691 for SDRAM
-- TMS0    0x2800_001C: 0x0724_0230 for SDRAM

library ieee;
use ieee.std_logic_1164.all;

entity sdram_interface_top is
	port(
		-- Memory Controller (MC) Interface
		-- Same signals as MC but inverted in/out (except for mc_clk_i)
		mc_clk_i:         in  std_logic;
		mc_br_pad_i:      out std_logic;
		mc_bg_pad_o:      in  std_logic;
		mc_ack_pad_i:     out std_logic;
		mc_addr_pad_o:    in  std_logic_vector (23 downto 0);
		mc_data_pad_i:    out std_logic_vector (31 downto 0);
		mc_data_pad_o:    in  std_logic_vector (31 downto 0);
		mc_dp_pad_i:      out std_logic_vector (3 downto 0);
		mc_dp_pad_o:      in  std_logic_vector (3 downto 0);
		mc_doe_pad_doe_o: in  std_logic;
		mc_dqm_pad_o:     in  std_logic_vector (3 downto 0);
		mc_oe_pad_o:      in  std_logic;
		mc_we_pad_o:      in  std_logic;
		mc_cas_pad_o:     in  std_logic;
		mc_ras_pad_o:     in  std_logic;
		mc_cke_pad_o:     in  std_logic;
		mc_cs_pad_o:      in  std_logic_vector (7 downto 0);
		mc_sts_pad_i:     out std_logic;
		mc_rp_pad_o:      in  std_logic;
		mc_vpen_pad_o:    in  std_logic;
		mc_adsc_pad_o:    in  std_logic;
		mc_adv_pad_o:     in  std_logic;
		mc_zz_pad_o:      in  std_logic;
		mc_coe_pad_coe_o: in  std_logic;
		
		-- SDRAM chip 1 interface
		dram0_a_o:        out std_logic_vector (12 downto 0);
		dram0_d_io:     inout std_logic_vector (15 downto 0);
		dram0_ba_o:       out std_logic_vector (1 downto 0);
		dram0_ldqm0_o:    out std_logic;
		dram0_udqm1_o:    out std_logic;
		dram0_ras_n_o:    out std_logic;
		dram0_cas_n_o:    out std_logic;
		dram0_cke_o:      out std_logic;
		dram0_clk_o:      out std_logic;
		dram0_we_n_o:     out std_logic;
		dram0_cs_n_o:     out std_logic;
		
		-- SDRAM chip 2 interface
		dram1_a_o:        out std_logic_vector (12 downto 0);
		dram1_d_io:     inout std_logic_vector (15 downto 0);
		dram1_ba_o:       out std_logic_vector (1 downto 0);
		dram1_ldqm0_o:    out std_logic;
		dram1_udqm1_o:    out std_logic;
		dram1_ras_n_o:    out std_logic;
		dram1_cas_n_o:    out std_logic;
		dram1_cke_o:      out std_logic;
		dram1_clk_o:      out std_logic;
		dram1_we_n_o:     out std_logic;
		dram1_cs_n_o:     out std_logic
	);
end sdram_interface_top;

architecture behave of sdram_interface_top is

begin

	-- take care of unused output signals
	mc_br_pad_i  <= '0';
	mc_ack_pad_i <= '0';
	mc_sts_pad_i <= '0';
	mc_dp_pad_i  <= (others => '0');
	
	-- the following signals are not in use in our system
	--mc_bg_pad_o:      in  std_logic;
	--mc_rp_pad_o:      in  std_logic;
	--mc_vpen_pad_o:    in  std_logic;
	--mc_zz_pad_o:      in  std_logic;
	--mc_cs_pad_o:      in  std_logic_vector (7 downto 1);
	--mc_adsc_pad_o:    in  std_logic;
	--mc_adv_pad_o:     in  std_logic;
	--mc_dp_pad_o:      in  std_logic_vector (3 downto 0);
	--mc_oe_pad_o:      in  std_logic;
	
	-- clk output for sdram chip,
	-- this should be exactly a half of system clock frequency
	dram0_clk_o    <= mc_clk_i;
	dram1_clk_o    <= mc_clk_i;
	
	-- SDRAM control signals with tri-state
	dram0_a_o      <= mc_addr_pad_o (12 downto 0)  when mc_coe_pad_coe_o = '1' else (others => 'Z');
	dram0_ba_o     <= mc_addr_pad_o (14 downto 13) when mc_coe_pad_coe_o = '1' else (others => 'Z');
	dram0_ldqm0_o  <= mc_dqm_pad_o (0)             when mc_coe_pad_coe_o = '1' else 'Z';
	dram0_udqm1_o  <= mc_dqm_pad_o (1)             when mc_coe_pad_coe_o = '1' else 'Z';
	dram0_ras_n_o  <= mc_ras_pad_o                 when mc_coe_pad_coe_o = '1' else 'Z';
	dram0_cas_n_o  <= mc_cas_pad_o                 when mc_coe_pad_coe_o = '1' else 'Z';
	dram0_cke_o    <= mc_cke_pad_o                 when mc_coe_pad_coe_o = '1' else 'Z';
	dram0_we_n_o   <= mc_we_pad_o                  when mc_coe_pad_coe_o = '1' else 'Z';
	dram0_cs_n_o   <= mc_cs_pad_o (0)              when mc_coe_pad_coe_o = '1' else 'Z';
	dram1_a_o      <= mc_addr_pad_o (12 downto 0)  when mc_coe_pad_coe_o = '1' else (others => 'Z');
	dram1_ba_o     <= mc_addr_pad_o (14 downto 13) when mc_coe_pad_coe_o = '1' else (others => 'Z');
	dram1_ldqm0_o  <= mc_dqm_pad_o (2)             when mc_coe_pad_coe_o = '1' else 'Z';
	dram1_udqm1_o  <= mc_dqm_pad_o (3)             when mc_coe_pad_coe_o = '1' else 'Z';
	dram1_ras_n_o  <= mc_ras_pad_o                 when mc_coe_pad_coe_o = '1' else 'Z';
	dram1_cas_n_o  <= mc_cas_pad_o                 when mc_coe_pad_coe_o = '1' else 'Z';
	dram1_cke_o    <= mc_cke_pad_o                 when mc_coe_pad_coe_o = '1' else 'Z';
	dram1_we_n_o   <= mc_we_pad_o                  when mc_coe_pad_coe_o = '1' else 'Z';
	dram1_cs_n_o   <= mc_cs_pad_o (0)              when mc_coe_pad_coe_o = '1' else 'Z';
	
	-- SDRAM data with tri-state
	dram0_d_io     <= mc_data_pad_o (15 downto 0)  when mc_doe_pad_doe_o = '1' else (others => 'Z');
	dram1_d_io     <= mc_data_pad_o (31 downto 16) when mc_doe_pad_doe_o = '1' else (others => 'Z');
	
	-- tri-state input
	mc_data_pad_i (15 downto 0)  <= dram0_d_io;
	mc_data_pad_i (31 downto 16) <= dram1_d_io;
	
end behave;

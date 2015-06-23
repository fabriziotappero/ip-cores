-- Xiang Li, olivercamel@gmail.com
-- Last Revised: 2008/06/27
--
-- This is an interface for the SSRAM IS61LPS51236A of DE2-70 Board.
-- The interface only includes tri-state logic for external pins.
-- All read/write timing logics are implemented by Memory Controller (MC) Core.
--
-- The SSRAM is 2 MBytes.
-- The SSRAM address is configured as: 0x1000_0000 - 0x101F_FFFC,
-- as the Memory Controller is attached to conmax slave 1.
--
-- The MC registers in our system could config as the following:
-- CSR     0x1800_0000: 0x0000_0000
-- POC     0x1800_0004: 0x0000_0002 This is done in mc_defines.v
-- BA_MASK 0x1800_0008: 0x0000_0020 Only judge addr(26)
-- CSC0    0x1800_0010: 0x0000_0823 for SSRAM
-- TMS0    0x1800_0014: 0xFFFF_FFFF

library ieee;
use ieee.std_logic_1164.all;

entity ssram_interface_top is
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
		
		-- SSRAM interface
		sram_a_o:        out std_logic_vector (18 downto 0);
		sram_dq_io:    inout std_logic_vector (31 downto 0);
		sram_adsc_n_o:   out std_logic;
		sram_adsp_n_o:   out std_logic;
		sram_adv_n_o:    out std_logic;
		sram_be_n_o:     out std_logic_vector (3 downto 0);
		sram_ce1_n_o:    out std_logic;
		sram_ce2_o:      out std_logic;
		sram_ce3_n_o:    out std_logic;
		sram_clk_o:      out std_logic;
		sram_dpa_io:   inout std_logic_vector (3 downto 0);
		sram_gw_n_o:     out std_logic;
		sram_oe_n_o:     out std_logic;
		sram_we_n_o:     out std_logic
	);
end ssram_interface_top;

architecture behave of ssram_interface_top is

begin

	-- take care of the unused output signals
	mc_br_pad_i  <= '0';
	mc_ack_pad_i <= '0';
	mc_sts_pad_i <= '0';
	
	-- the following signals are not in use in our system
	--mc_bg_pad_o:      in  std_logic;
	--mc_rp_pad_o:      in  std_logic;
	--mc_vpen_pad_o:    in  std_logic;
	--mc_zz_pad_o:      in  std_logic;
	--mc_cs_pad_o:      in  std_logic_vector (7 downto 1);
	--mc_cas_pad_o:     in  std_logic;
	--mc_ras_pad_o:     in  std_logic;
	--mc_cke_pad_o:     in  std_logic;
	
	-- clk output for external SSRAM chip,
	-- this should be exactly a half of system clock frequency
	sram_clk_o    <= mc_clk_i;
	
	-- SSRAM control signals with tri-state
	sram_a_o      <= mc_addr_pad_o (18 downto 0) when mc_coe_pad_coe_o = '1' else (others => 'Z');
	sram_be_n_o   <= mc_dqm_pad_o                when mc_coe_pad_coe_o = '1' else (others => 'Z');
	sram_oe_n_o   <= mc_oe_pad_o                 when mc_coe_pad_coe_o = '1' else 'Z';
	sram_we_n_o   <= mc_we_pad_o                 when mc_coe_pad_coe_o = '1' else 'Z';
	sram_ce1_n_o  <= mc_cs_pad_o (0)             when mc_coe_pad_coe_o = '1' else 'Z';
	sram_adsc_n_o <= mc_adsc_pad_o               when mc_coe_pad_coe_o = '1' else 'Z';
	sram_adv_n_o  <= mc_adv_pad_o                when mc_coe_pad_coe_o = '1' else 'Z';
	sram_adsp_n_o <= '1'                         when mc_coe_pad_coe_o = '1' else 'Z';
	sram_ce2_o    <= '1'                         when mc_coe_pad_coe_o = '1' else 'Z';
	sram_ce3_n_o  <= '0'                         when mc_coe_pad_coe_o = '1' else 'Z';
	sram_gw_n_o   <= '1'                         when mc_coe_pad_coe_o = '1' else 'Z';
	
	-- SSRAM data with tri-state
	sram_dq_io    <= mc_data_pad_o               when mc_doe_pad_doe_o = '1' else (others => 'Z');
	sram_dpa_io   <= mc_dp_pad_o                 when mc_doe_pad_doe_o = '1' else (others => 'Z');
	
	-- tri-state input
	mc_data_pad_i <= sram_dq_io;
	mc_dp_pad_i   <= sram_dpa_io;
	
end behave;

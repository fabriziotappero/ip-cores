-- ***************************************************
-- File: de2_samos_soc.vhd
-- Creation date: 03.09.2012
-- Creation time: 15:11:54
-- Description: Altera de2 template soc
-- 
-- Created by: matilail
-- This file was generated with Kactus2 vhdl generator.
-- ***************************************************
library IEEE;
library dct_to_hibi;
library work;
library udp2hibi;
use dct_to_hibi.all;
use work.all;
use udp2hibi.all;
use IEEE.std_logic_1164.all;

entity de2_samos_soc is

	port (

		-- Interface: clk_in
		CLOCK_50 : in std_logic;

		-- Interface: DM9000A
		ENET_INT : in std_logic;
		ENET_CLK : out std_logic;
		ENET_CMD : out std_logic;
		ENET_CS_N : out std_logic;
		ENET_RD_N : out std_logic;
		ENET_RST_N : out std_logic;
		ENET_WR_N : out std_logic;
		ENET_DATA : inout std_logic_vector(15 downto 0);

		-- Interface: rst_n
		SW_17 : in std_logic;

		-- Interface: sdram_clk
		DRAM_CLK : out std_logic;

		-- Interface: sdram_if
		DRAM_ADDR : out std_logic_vector(11 downto 0);
		DRAM_BA : out std_logic_vector(1 downto 0);
		DRAM_CAS_N : out std_logic;
		DRAM_CKE : out std_logic;
		DRAM_CS_N : out std_logic;
		DRAM_DQM : out std_logic_vector(1 downto 0);
		DRAM_RAS_N : out std_logic;
		DRAM_WE_N : out std_logic;
		DRAM_DQ : inout std_logic_vector(15 downto 0);

		-- Interface: sram_if
		SRAM_ADDR : out std_logic_vector(17 downto 0);
		SRAM_CE_N : out std_logic;
		SRAM_LB_N : out std_logic;
		SRAM_OE_N : out std_logic;
		SRAM_UB_N : out std_logic;
		SRAM_WE_N : out std_logic;
		SRAM_DQ : inout std_logic_vector(15 downto 0)
	);

end de2_samos_soc;


architecture structural of de2_samos_soc is

	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifCHROMA_TO_ACC : std_logic;
	signal nios_ii_sram_0_clk_to_pll_0_ip_clkCLK : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_DCT_TO_ACC : std_logic_vector(8 downto 0);
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_IDCT_FROM_ACC : std_logic_vector(8 downto 0);
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_QUANT_FROM_ACC : std_logic_vector(7 downto 0);
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDCT_READY4COL_FROM_ACC : std_logic;
	signal dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3AV : std_logic;
	signal dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3AV : std_logic;
	signal dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3COMM : std_logic_vector(4 downto 0);
	signal dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3COMM : std_logic_vector(4 downto 0);
	signal dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3DATA : std_logic_vector(31 downto 0);
	signal dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3DATA : std_logic_vector(31 downto 0);
	signal dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3EMPTY : std_logic;
	signal dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3FULL : std_logic;
	signal dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3RE : std_logic;
	signal dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3WE : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifIDCT_READY4COL_TO_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifINTRA_TO_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifLOAD_QP_TO_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQP_TO_ACC : std_logic_vector(4 downto 0);
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQUANT_READY4COL_TO_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_DCT_TO_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_IDCT_FROM_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_QUANT_FROM_ACC : std_logic;
	signal nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0AV : std_logic;
	signal nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1AV : std_logic;
	signal udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2AV : std_logic;
	signal nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0AV : std_logic;
	signal nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1AV : std_logic;
	signal udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2AV : std_logic;
	signal nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0COMM : std_logic_vector(4 downto 0);
	signal nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1COMM : std_logic_vector(4 downto 0);
	signal udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2COMM : std_logic_vector(4 downto 0);
	signal nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0COMM : std_logic_vector(4 downto 0);
	signal nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1COMM : std_logic_vector(4 downto 0);
	signal udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2COMM : std_logic_vector(4 downto 0);
	signal nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0DATA : std_logic_vector(31 downto 0);
	signal nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1DATA : std_logic_vector(31 downto 0);
	signal udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2DATA : std_logic_vector(31 downto 0);
	signal nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0DATA : std_logic_vector(31 downto 0);
	signal nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1DATA : std_logic_vector(31 downto 0);
	signal udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2DATA : std_logic_vector(31 downto 0);
	signal nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0EMPTY : std_logic;
	signal nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1EMPTY : std_logic;
	signal udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2EMPTY : std_logic;
	signal nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0FULL : std_logic;
	signal nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1FULL : std_logic;
	signal udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2FULL : std_logic;
	signal nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0RE : std_logic;
	signal nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1RE : std_logic;
	signal udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2RE : std_logic;
	signal nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0WE : std_logic;
	signal nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1WE : std_logic;
	signal udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2WE : std_logic;
	signal udp2hibi_0_clk_udp_to_pll_0_clk_25MHzCLK : std_logic;
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxdest_port_out : std_logic_vector(15 downto 0);
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxlink_up_out : std_logic;
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxnew_rx_out : std_logic;
	signal udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txnew_tx_in : std_logic;
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_out : std_logic_vector(15 downto 0);
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_valid_out : std_logic;
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_erroneous_out : std_logic;
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_len_out : std_logic_vector(10 downto 0);
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_re_in : std_logic;
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_addr_out : std_logic_vector(31 downto 0);
	signal udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txsource_port_in : std_logic_vector(15 downto 0);
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_port_out : std_logic_vector(15 downto 0);
	signal udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtarget_addr_in : std_logic_vector(31 downto 0);
	signal udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtarget_port_in : std_logic_vector(15 downto 0);
	signal udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_data_in : std_logic_vector(15 downto 0);
	signal udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_data_valid_in : std_logic;
	signal udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_len_in : std_logic_vector(10 downto 0);
	signal udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_re_out : std_logic;

	component nios_ii_sdram
		port (

			-- Interface: clk
			clk_0 : in std_logic;

			-- Interface: hibi_master
			hibi_av_out_from_the_hibi_pe_dma_1 : out std_logic;
			hibi_comm_out_from_the_hibi_pe_dma_1 : out std_logic_vector(4 downto 0);
			hibi_data_out_from_the_hibi_pe_dma_1 : out std_logic_vector(31 downto 0);
			hibi_re_out_from_the_hibi_pe_dma_1 : out std_logic;
			hibi_we_out_from_the_hibi_pe_dma_1 : out std_logic;

			-- Interface: hibi_slave
			hibi_av_in_to_the_hibi_pe_dma_1 : in std_logic;
			hibi_comm_in_to_the_hibi_pe_dma_1 : in std_logic_vector(4 downto 0);
			hibi_data_in_to_the_hibi_pe_dma_1 : in std_logic_vector(31 downto 0);
			hibi_empty_in_to_the_hibi_pe_dma_1 : in std_logic;
			hibi_full_in_to_the_hibi_pe_dma_1 : in std_logic;

			-- Interface: rst_n
			reset_n : in std_logic;

			-- Interface: sdram_if
			zs_addr_from_the_sdram_1 : out std_logic_vector(11 downto 0);
			zs_ba_from_the_sdram_1 : out std_logic_vector(1 downto 0);
			zs_cas_n_from_the_sdram_1 : out std_logic;
			zs_cke_from_the_sdram_1 : out std_logic;
			zs_cs_n_from_the_sdram_1 : out std_logic;
			zs_dqm_from_the_sdram_1 : out std_logic_vector(1 downto 0);
			zs_ras_n_from_the_sdram_1 : out std_logic;
			zs_we_n_from_the_sdram_1 : out std_logic;
			zs_dq_to_and_from_the_sdram_1 : inout std_logic_vector(15 downto 0)

		);
	end component;

	component nios_ii_sram
		port (

			-- Interface: clk
			clk_0 : in std_logic;

			-- Interface: hibi_master
			hibi_av_out_from_the_hibi_pe_dma_0 : out std_logic;
			hibi_comm_out_from_the_hibi_pe_dma_0 : out std_logic_vector(4 downto 0);
			hibi_data_out_from_the_hibi_pe_dma_0 : out std_logic_vector(31 downto 0);
			hibi_re_out_from_the_hibi_pe_dma_0 : out std_logic;
			hibi_we_out_from_the_hibi_pe_dma_0 : out std_logic;

			-- Interface: hibi_slave
			hibi_av_in_to_the_hibi_pe_dma_0 : in std_logic;
			hibi_comm_in_to_the_hibi_pe_dma_0 : in std_logic_vector(4 downto 0);
			hibi_data_in_to_the_hibi_pe_dma_0 : in std_logic_vector(31 downto 0);
			hibi_empty_in_to_the_hibi_pe_dma_0 : in std_logic;
			hibi_full_in_to_the_hibi_pe_dma_0 : in std_logic;

			-- Interface: rst_n
			reset_n : in std_logic;

			-- Interface: sram_if
			SRAM_ADDR_from_the_sram_0 : out std_logic_vector(17 downto 0);
			SRAM_CE_N_from_the_sram_0 : out std_logic;
			SRAM_LB_N_from_the_sram_0 : out std_logic;
			SRAM_OE_N_from_the_sram_0 : out std_logic;
			SRAM_UB_N_from_the_sram_0 : out std_logic;
			SRAM_WE_N_from_the_sram_0 : out std_logic;
			SRAM_DQ_to_and_from_the_sram_0 : inout std_logic_vector(15 downto 0)

		);
	end component;

	-- DCT to Hibi. Connects dctQidct block to HIBI Wrapper
	-- 
	-- 
	-- Input:
	-- 1. Two address to send the results to (one for quant, one for idct)
	-- 2. Control word for the current macroblock
	--     Control word structure: bit 6: chroma(1)/luma(0), 5: intra(1)/inter(0),
	--                              4..0: quantizer parameter (QP)
	-- 3. Then the DCT data ( 8x8x6 x 16-bit values = 384 x 16 bit )
	-- 
	-- Chroma/luma: 4 luma, 2 chroma
	-- 
	-- Outputs:
	--  Outputs are 16-bit words which are packed up to hibi. If hibi width is
	--  32b, then 2 16-bit words are combined into one hibi word.
	--  01. quant results: 1. 8*8 x 16bit values to quant result address
	--  02. idct  results: 1. 8*8 x 16bit values to idct  result address  
	--  03. quant results: 2. 8*8 x 16bit values to quant result address
	--  04. idct  results: 2. 8*8 x 16bit values to idct  result address
	--  05. quant results: 3. 8*8 x 16bit values to quant result address
	--  06. idct  results: 3. 8*8 x 16bit values to idct  result address
	--  07. quant results: 4. 8*8 x 16bit values to quant result address
	--  08. idct  results: 4. 8*8 x 16bit values to idct  result address
	--  09. quant results: 5. 8*8 x 16bit values to quant result address
	--  10. idct  results: 5. 8*8 x 16bit values to idct  result address
	--  11. quant results: 6. 8*8 x 16bit values to quant result address
	--  12. quant results: 1 word with bits 5..0 determing if 8x8 quant blocks(1-6)
	--                     has all values zeros (except dc-component in intra)
	--  13. idct  results: 6. 8*8 x 16bit values to idct  result address
	-- -
	--  Total amount of 16-bit values is: 384 per result address + 1 hibi word to
	--  quantization result address.
	-- 
	--  With default parameter:
	--  Total of 193 words of data to quant address (if data_width_g = 32)
	--  Total of 192 words of data to idct address (if data_width_g = 32)
	-- 
	component dct_to_hibi
		generic (
			comm_width_g : integer := 5;
			data_width_g : integer := 32;
			dct_width_g : integer := 9; -- Incoming data width(9b)
			debug_w_g : integer := 1;
			idct_width_g : integer := 9; -- Data width after IDCT(9b)
			own_address_g : integer := 0; -- Used for self-release
			quant_width_g : integer := 8; -- Quantizated data width(8b)
			rtm_address_g : integer := 0; -- Used for self-release
			use_self_rel_g : integer := 1 -- Does it release itself from RTM?

		);
		port (

			-- Interface: clk
			-- Clock interface
			clk : in std_logic;

			-- Interface: dct_if
			-- Interface for connecting idctquant accelerator	
			data_idct_in : in std_logic_vector(8 downto 0);
			data_quant_in : in std_logic_vector(7 downto 0);
			dct_ready4col_in : in std_logic;
			wr_idct_in : in std_logic;
			wr_quant_in : in std_logic;
			chroma_out : out std_logic;
			data_dct_out : out std_logic_vector(8 downto 0);
			idct_ready4col_out : out std_logic;
			intra_out : out std_logic;
			loadQP_out : out std_logic;
			QP_out : out std_logic_vector(4 downto 0);
			quant_ready4col_out : out std_logic;
			wr_dct_out : out std_logic;

			-- Interface: hibi_master
			-- HIBI wrapper r4 version 2 master interface
			hibi_av_out : out std_logic;
			hibi_comm_out : out std_logic_vector(4 downto 0);
			hibi_data_out : out std_logic_vector(31 downto 0);
			hibi_re_out : out std_logic;
			hibi_we_out : out std_logic;

			-- Interface: hibi_slave
			hibi_av_in : in std_logic;
			hibi_comm_in : in std_logic_vector(4 downto 0);
			hibi_data_in : in std_logic_vector(31 downto 0);
			hibi_empty_in : in std_logic;
			hibi_full_in : in std_logic;

			-- These ports are not in any interface
			-- debug_out : out std_logic;

			-- Interface: rst_n
			-- Active low reset input.
			rst_n : in std_logic

		);
	end component;

	component dctQidct_core
		port (

			-- Interface: clk
			clk : in std_logic;

			-- Interface: dct_if
			chroma_in : in std_logic;
			data_dct_in : in std_logic_vector(8 downto 0);
			idct_ready4column_in : in std_logic;
			intra_in : in std_logic;
			loadQP_in : in std_logic;
			QP_in : in std_logic_vector(4 downto 0);
			quant_ready4column_in : in std_logic;
			wr_dct_in : in std_logic;
			data_idct_out : out std_logic_vector(8 downto 0);
			data_quant_out : out std_logic_vector(7 downto 0);
			dct_ready4column_out : out std_logic;
			wr_idct_out : out std_logic;
			wr_quant_out : out std_logic;

			-- Interface: rst_n
			rst_n : in std_logic

		);
	end component;

	component hibi_segment
		generic (
			hibi_addr_0_g : integer := 16#01000000#; -- HIBI address for interface 0
			hibi_addr_1_g : integer := 16#03000000#; -- HIBI address for interface 1
			hibi_addr_2_g : integer := 16#05000000#; -- HIBI address for interface 2
			hibi_addr_3_g : integer := 16#07000000#; -- HIBI address for interface 3
			hibi_end_addr_0_g : integer := 16#03000000#
-1; -- HIBI end address for interface 0
			hibi_end_addr_1_g : integer := 16#05000000# -1; -- HIBI end address for interface 1
			hibi_end_addr_2_g : integer := 16#07000000# -1; -- HIBI end address for interface 2
			hibi_end_addr_3_g : integer := 16#09000000# -1 -- HIBI end address for interface 3

		);
		port (

			-- Interface: clocks_0
			-- Clock inputs  interface for hibi wrapper_3
			agent_clk : in std_logic;
			agent_sync_clk : in std_logic;
			bus_clk : in std_logic;
			bus_sync_clk : in std_logic;

			-- Interface: clocks_1
			-- Clock inputs  interface for hibi wrapper_3
			agent_clk_1 : in std_logic;
			agent_sync_clk_1 : in std_logic;
			bus_clk_1 : in std_logic;
			bus_sync_clk_1 : in std_logic;

			-- Interface: clocks_2
			-- Clock inputs  interface for hibi wrapper_3
			agent_clk_2 : in std_logic;
			agent_sync_clk_2 : in std_logic;
			bus_clk_2 : in std_logic;
			bus_sync_clk_2 : in std_logic;

			-- Interface: clocks_3
			-- Clock inputs  interface for hibi wrapper_3
			agent_clk_3 : in std_logic;
			agent_sync_clk_3 : in std_logic;
			bus_clk_3 : in std_logic;
			bus_sync_clk_3 : in std_logic;

			-- Interface: ip_mMaster_0
			-- HIBI ip mirrored master agent interface 0 (r4 wrapper)
			agent_av_in : in std_logic;
			agent_comm_in : in std_logic_vector(4 downto 0);
			agent_data_in : in std_logic_vector(31 downto 0);
			agent_re_in : in std_logic;
			agent_we_in : in std_logic;

			-- Interface: ip_mMaster_1
			-- HIBI ip mirrored master agent interface 1 (r4 wrapper)
			agent_av_in_1 : in std_logic;
			agent_comm_in_1 : in std_logic_vector(4 downto 0);
			agent_data_in_1 : in std_logic_vector(31 downto 0);
			agent_re_in_1 : in std_logic;
			agent_we_in_1 : in std_logic;

			-- Interface: ip_mMaster_2
			-- HIBI ip mirrored master agent interface 2 (r4 wrapper)
			agent_av_in_2 : in std_logic;
			agent_comm_in_2 : in std_logic_vector(4 downto 0);
			agent_data_in_2 : in std_logic_vector(31 downto 0);
			agent_re_in_2 : in std_logic;
			agent_we_in_2 : in std_logic;

			-- Interface: ip_mMaster_3
			-- HIBI ip mirrored master agent interface 3 (r4 wrapper)
			agent_av_in_3 : in std_logic;
			agent_comm_in_3 : in std_logic_vector(4 downto 0);
			agent_data_in_3 : in std_logic_vector(31 downto 0);
			agent_re_in_3 : in std_logic;
			agent_we_in_3 : in std_logic;

			-- Interface: ip_mSlave_0
			-- HIBI ip mirrored slave agent interface 0 (r4 wrapper)
			agent_av_out : out std_logic;
			agent_comm_out : out std_logic_vector(4 downto 0);
			agent_data_out : out std_logic_vector(31 downto 0);
			agent_empty_out : out std_logic;
			agent_full_out : out std_logic;
			-- agent_one_d_out : out std_logic;
			-- agent_one_p_out : out std_logic;

			-- Interface: ip_mSlave_1
			-- HIBI ip mirrored slave agent interface 1  (r4 wrapper)
			agent_av_out_1 : out std_logic;
			agent_comm_out_1 : out std_logic_vector(4 downto 0);
			agent_data_out_1 : out std_logic_vector(31 downto 0);
			agent_empty_out_1 : out std_logic;
			agent_full_out_1 : out std_logic;
			-- agent_one_d_out_1 : out std_logic;
			-- agent_one_p_out_1 : out std_logic;

			-- Interface: ip_mSlave_2
			-- HIBI ip mirrored slave agent interface 2 (r4 wrapper)
			agent_av_out_2 : out std_logic;
			agent_comm_out_2 : out std_logic_vector(4 downto 0);
			agent_data_out_2 : out std_logic_vector(31 downto 0);
			agent_empty_out_2 : out std_logic;
			agent_full_out_2 : out std_logic;
			-- agent_one_d_out_2 : out std_logic;
			-- agent_one_p_out_2 : out std_logic;

			-- Interface: ip_mSlave_3
			-- HIBI ip mirrored slave agent interface_3 (r4 wrapper)
			agent_av_out_3 : out std_logic;
			agent_comm_out_3 : out std_logic_vector(4 downto 0);
			agent_data_out_3 : out std_logic_vector(31 downto 0);
			agent_empty_out_3 : out std_logic;
			agent_full_out_3 : out std_logic;
			-- agent_one_d_out_3 : out std_logic;
			-- agent_one_p_out_3 : out std_logic;

			-- Interface: rst_n
			-- Active low reset interface.
			rst_n : in std_logic

		);
	end component;

	-- - Interface between a UDP/IP block and the HIBI bus.
	-- - Capable of handling one transmission and one incoming packet at a time
	-- - UDP2HIBI uses HIBI addresses to separate transfers from different agents
	-- - So all agents must use different addresses when sending to UDP2HIBI
	-- 
	component udp2hibi
		generic (
			ack_fifo_depth_g : integer := 4;
			frequency_g : integer := 50000000;
			hibi_addr_width_g : integer := 32;
			hibi_comm_width_g : integer := 5;
			hibi_data_width_g : integer := 32;
			hibi_tx_fifo_depth_g : integer := 10;
			receiver_table_size_g : integer := 4;
			rx_multiclk_fifo_depth_g : integer := 10;
			tx_multiclk_fifo_depth_g : integer := 10

		);
		port (

			-- Interface: clk
			-- clock input
			clk : in std_logic;

			-- Interface: clk_udp
			-- clock udp input (25MHz)
			clk_udp : in std_logic;

			-- Interface: hibi_master
			-- HIBI master interface
			hibi_av_out : out std_logic;
			hibi_comm_out : out std_logic_vector(4 downto 0);
			hibi_data_out : out std_logic_vector(31 downto 0);
			hibi_re_out : out std_logic;
			hibi_we_out : out std_logic;

			-- Interface: hibi_slave
			-- HIBI slave interface
			hibi_av_in : in std_logic;
			hibi_comm_in : in std_logic_vector(4 downto 0);
			hibi_data_in : in std_logic_vector(31 downto 0);
			hibi_empty_in : in std_logic;
			hibi_full_in : in std_logic;

			-- Interface: rst_n
			-- active low reset
			rst_n : in std_logic;

			-- Interface: udp_ip_rx
			-- udp_ip_rx
			dest_port_in : in std_logic_vector(15 downto 0);
			eth_link_up_in : in std_logic;
			new_rx_in : in std_logic;
			rx_data_in : in std_logic_vector(15 downto 0);
			rx_data_valid_in : in std_logic;
			rx_erroneous_in : in std_logic;
			rx_len_in : in std_logic_vector(10 downto 0);
			source_ip_in : in std_logic_vector(31 downto 0);
			source_port_in : in std_logic_vector(15 downto 0);
			rx_re_out : out std_logic;

			-- Interface: udp_ip_tx
			-- udp_ip_tx
			tx_re_in : in std_logic;
			dest_ip_out : out std_logic_vector(31 downto 0);
			dest_port_out : out std_logic_vector(15 downto 0);
			new_tx_out : out std_logic;
			source_port_out : out std_logic_vector(15 downto 0);
			tx_data_out : out std_logic_vector(15 downto 0);
			tx_data_valid_out : out std_logic;
			tx_len_out : out std_logic_vector(10 downto 0)

		);
	end component;

	-- DM9000A controller and UDP/IP.
	component udp_ip_dm9000a
		generic (
			disable_arp_g : integer := 0;
			disable_rx_g : integer := 0

		);
		port (

			-- Interface: app_rx
			-- Application receive operations
			rx_re_in : in std_logic;
			dest_port_out : out std_logic_vector(15 downto 0);
			new_rx_out : out std_logic;
			rx_data_out : out std_logic_vector(15 downto 0);
			rx_data_valid_out : out std_logic;
			rx_erroneous_out : out std_logic;
			-- rx_error_out : out std_logic;
			rx_len_out : out std_logic_vector(10 downto 0);
			source_addr_out : out std_logic_vector(31 downto 0);
			source_port_out : out std_logic_vector(15 downto 0);

			-- Interface: app_tx
			-- Application transmit operations
			new_tx_in : in std_logic;
			no_arp_target_MAC_in : in std_logic_vector(47 downto 0);
			source_port_in : in std_logic_vector(15 downto 0);
			target_addr_in : in std_logic_vector(31 downto 0);
			target_port_in : in std_logic_vector(15 downto 0);
			tx_data_in : in std_logic_vector(15 downto 0);
			tx_data_valid_in : in std_logic;
			tx_len_in : in std_logic_vector(10 downto 0);
			tx_re_out : out std_logic;

			-- Interface: clk
			-- Clock 25 MHz in.
			clk : in std_logic;

			-- Interface: DM9000A
			-- Connection to the DM9000A chip via IO pins.
			eth_interrupt_in : in std_logic;
			eth_chip_sel_out : out std_logic;
			eth_clk_out : out std_logic;
			eth_cmd_out : out std_logic;
			eth_read_out : out std_logic;
			eth_reset_out : out std_logic;
			eth_write_out : out std_logic;
			eth_data_inout : inout std_logic_vector(15 downto 0);

			-- Interface: rst_n
			-- Asynchronous reset active-low.
			rst_n : in std_logic;

			-- There ports are contained in many interfaces
			-- fatal_error_out : out std_logic;
			link_up_out : out std_logic

		);
	end component;

	-- 50 MHz Altera ALTPLL instantiation for Cyclone II FPGA's with input clk of 50 MHz (mul = 1, div = 1)
	component pll
		port (

			-- Interface: clk_25MHz
			c2 : out std_logic;

			-- Interface: clk_in
			-- Input clock (50 MHz, DE2 PIN_N2)
			inclk0 : in std_logic;

			-- Interface: sdram_clk
			-- -54 degrees phase adjustment
			c1 : out std_logic;

			-- There ports are contained in many interfaces
			c0 : out std_logic

		);
	end component;

	-- You can write vhdl code after this tag and it is saved through the generator.
	-- ##KACTUS2_BLACK_BOX_DECLARATIONS_BEGIN##
	-- ##KACTUS2_BLACK_BOX_DECLARATIONS_END##
	-- Stop writing your code after this tag.


begin

	-- You can write vhdl code after this tag and it is saved through the generator.
	-- ##KACTUS2_BLACK_BOX_ASSIGNMENTS_BEGIN##
	-- ##KACTUS2_BLACK_BOX_ASSIGNMENTS_END##
	-- Stop writing your code after this tag.

	dct_to_hibi_0 : dct_to_hibi
		port map (
			chroma_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifCHROMA_TO_ACC,
			clk => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			data_dct_out(8 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_DCT_TO_ACC(8 downto 0),
			data_idct_in(8 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_IDCT_FROM_ACC(8 downto 0),
			data_quant_in(7 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_QUANT_FROM_ACC(7 downto 0),
			dct_ready4col_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDCT_READY4COL_FROM_ACC,
			hibi_av_in => dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3AV,
			hibi_av_out => dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3AV,
			hibi_comm_in(4 downto 0) => dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3COMM(4 downto 0),
			hibi_comm_out(4 downto 0) => dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3COMM(4 downto 0),
			hibi_data_in(31 downto 0) => dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3DATA(31 downto 0),
			hibi_data_out(31 downto 0) => dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3DATA(31 downto 0),
			hibi_empty_in => dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3EMPTY,
			hibi_full_in => dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3FULL,
			hibi_re_out => dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3RE,
			hibi_we_out => dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3WE,
			idct_ready4col_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifIDCT_READY4COL_TO_ACC,
			intra_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifINTRA_TO_ACC,
			loadQP_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifLOAD_QP_TO_ACC,
			QP_out(4 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQP_TO_ACC(4 downto 0),
			quant_ready4col_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQUANT_READY4COL_TO_ACC,
			rst_n => SW_17,
			wr_dct_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_DCT_TO_ACC,
			wr_idct_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_IDCT_FROM_ACC,
			wr_quant_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_QUANT_FROM_ACC
		);

	dctqidct_0 : dctQidct_core
		port map (
			chroma_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifCHROMA_TO_ACC,
			clk => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			data_dct_in(8 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_DCT_TO_ACC(8 downto 0),
			data_idct_out(8 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_IDCT_FROM_ACC(8 downto 0),
			data_quant_out(7 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_QUANT_FROM_ACC(7 downto 0),
			dct_ready4column_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDCT_READY4COL_FROM_ACC,
			idct_ready4column_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifIDCT_READY4COL_TO_ACC,
			intra_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifINTRA_TO_ACC,
			loadQP_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifLOAD_QP_TO_ACC,
			QP_in(4 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQP_TO_ACC(4 downto 0),
			quant_ready4column_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQUANT_READY4COL_TO_ACC,
			rst_n => SW_17,
			wr_dct_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_DCT_TO_ACC,
			wr_idct_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_IDCT_FROM_ACC,
			wr_quant_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_QUANT_FROM_ACC
		);

	hibi_segment_0 : hibi_segment(structural)
		port map (
			agent_av_in => nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0AV,
			agent_av_in_1 => nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1AV,
			agent_av_in_2 => udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2AV,
			agent_av_in_3 => dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3AV,
			agent_av_out => nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0AV,
			agent_av_out_1 => nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1AV,
			agent_av_out_2 => udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2AV,
			agent_av_out_3 => dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3AV,
			agent_clk => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			agent_clk_1 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			agent_clk_2 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			agent_clk_3 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			agent_comm_in(4 downto 0) => nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0COMM(4 downto 0),
			agent_comm_in_1(4 downto 0) => nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1COMM(4 downto 0),
			agent_comm_in_2(4 downto 0) => udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2COMM(4 downto 0),
			agent_comm_in_3(4 downto 0) => dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3COMM(4 downto 0),
			agent_comm_out(4 downto 0) => nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0COMM(4 downto 0),
			agent_comm_out_1(4 downto 0) => nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1COMM(4 downto 0),
			agent_comm_out_2(4 downto 0) => udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2COMM(4 downto 0),
			agent_comm_out_3(4 downto 0) => dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3COMM(4 downto 0),
			agent_data_in(31 downto 0) => nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0DATA(31 downto 0),
			agent_data_in_1(31 downto 0) => nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1DATA(31 downto 0),
			agent_data_in_2(31 downto 0) => udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2DATA(31 downto 0),
			agent_data_in_3(31 downto 0) => dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3DATA(31 downto 0),
			agent_data_out(31 downto 0) => nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0DATA(31 downto 0),
			agent_data_out_1(31 downto 0) => nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1DATA(31 downto 0),
			agent_data_out_2(31 downto 0) => udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2DATA(31 downto 0),
			agent_data_out_3(31 downto 0) => dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3DATA(31 downto 0),
			agent_empty_out => nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0EMPTY,
			agent_empty_out_1 => nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1EMPTY,
			agent_empty_out_2 => udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2EMPTY,
			agent_empty_out_3 => dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3EMPTY,
			agent_full_out => nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0FULL,
			agent_full_out_1 => nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1FULL,
			agent_full_out_2 => udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2FULL,
			agent_full_out_3 => dct_to_hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_3FULL,
			agent_re_in => nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0RE,
			agent_re_in_1 => nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1RE,
			agent_re_in_2 => udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2RE,
			agent_re_in_3 => dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3RE,
			agent_sync_clk => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			agent_sync_clk_1 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			agent_sync_clk_2 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			agent_sync_clk_3 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			agent_we_in => nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0WE,
			agent_we_in_1 => nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1WE,
			agent_we_in_2 => udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2WE,
			agent_we_in_3 => dct_to_hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_3WE,
			bus_clk => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			bus_clk_1 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			bus_clk_2 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			bus_clk_3 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			bus_sync_clk => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			bus_sync_clk_1 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			bus_sync_clk_2 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			bus_sync_clk_3 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			rst_n => SW_17
		);

	nios_ii_sdram_1 : nios_ii_sdram
		port map (
			clk_0 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			hibi_av_in_to_the_hibi_pe_dma_1 => nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1AV,
			hibi_av_out_from_the_hibi_pe_dma_1 => nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1AV,
			hibi_comm_in_to_the_hibi_pe_dma_1(4 downto 0) => nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1COMM(4 downto 0),
			hibi_comm_out_from_the_hibi_pe_dma_1(4 downto 0) => nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1COMM(4 downto 0),
			hibi_data_in_to_the_hibi_pe_dma_1(31 downto 0) => nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1DATA(31 downto 0),
			hibi_data_out_from_the_hibi_pe_dma_1(31 downto 0) => nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1DATA(31 downto 0),
			hibi_empty_in_to_the_hibi_pe_dma_1 => nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1EMPTY,
			hibi_full_in_to_the_hibi_pe_dma_1 => nios_ii_sdram_1_hibi_slave_to_hibi_segment_0_ip_mSlave_1FULL,
			hibi_re_out_from_the_hibi_pe_dma_1 => nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1RE,
			hibi_we_out_from_the_hibi_pe_dma_1 => nios_ii_sdram_1_hibi_master_to_hibi_segment_0_ip_mMaster_1WE,
			reset_n => SW_17,
			zs_addr_from_the_sdram_1(11 downto 0) => DRAM_ADDR(11 downto 0),
			zs_ba_from_the_sdram_1(1 downto 0) => DRAM_BA(1 downto 0),
			zs_cas_n_from_the_sdram_1 => DRAM_CAS_N,
			zs_cke_from_the_sdram_1 => DRAM_CKE,
			zs_cs_n_from_the_sdram_1 => DRAM_CS_N,
			zs_dq_to_and_from_the_sdram_1(15 downto 0) => DRAM_DQ(15 downto 0),
			zs_dqm_from_the_sdram_1(1 downto 0) => DRAM_DQM(1 downto 0),
			zs_ras_n_from_the_sdram_1 => DRAM_RAS_N,
			zs_we_n_from_the_sdram_1 => DRAM_WE_N
		);

	nios_ii_sram_0 : nios_ii_sram
		port map (
			clk_0 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			hibi_av_in_to_the_hibi_pe_dma_0 => nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0AV,
			hibi_av_out_from_the_hibi_pe_dma_0 => nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0AV,
			hibi_comm_in_to_the_hibi_pe_dma_0(4 downto 0) => nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0COMM(4 downto 0),
			hibi_comm_out_from_the_hibi_pe_dma_0(4 downto 0) => nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0COMM(4 downto 0),
			hibi_data_in_to_the_hibi_pe_dma_0(31 downto 0) => nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0DATA(31 downto 0),
			hibi_data_out_from_the_hibi_pe_dma_0(31 downto 0) => nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0DATA(31 downto 0),
			hibi_empty_in_to_the_hibi_pe_dma_0 => nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0EMPTY,
			hibi_full_in_to_the_hibi_pe_dma_0 => nios_ii_sram_0_hibi_slave_to_hibi_segment_0_ip_mSlave_0FULL,
			hibi_re_out_from_the_hibi_pe_dma_0 => nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0RE,
			hibi_we_out_from_the_hibi_pe_dma_0 => nios_ii_sram_0_hibi_master_to_hibi_segment_0_ip_mMaster_0WE,
			reset_n => SW_17,
			SRAM_ADDR_from_the_sram_0(17 downto 0) => SRAM_ADDR(17 downto 0),
			SRAM_CE_N_from_the_sram_0 => SRAM_CE_N,
			SRAM_DQ_to_and_from_the_sram_0(15 downto 0) => SRAM_DQ(15 downto 0),
			SRAM_LB_N_from_the_sram_0 => SRAM_LB_N,
			SRAM_OE_N_from_the_sram_0 => SRAM_OE_N,
			SRAM_UB_N_from_the_sram_0 => SRAM_UB_N,
			SRAM_WE_N_from_the_sram_0 => SRAM_WE_N
		);

	pll_0 : pll
		port map (
			c0 => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			c1 => DRAM_CLK,
			c2 => udp2hibi_0_clk_udp_to_pll_0_clk_25MHzCLK,
			inclk0 => CLOCK_50
		);

	udp2hibi_0 : udp2hibi
		port map (
			clk => nios_ii_sram_0_clk_to_pll_0_ip_clkCLK,
			clk_udp => udp2hibi_0_clk_udp_to_pll_0_clk_25MHzCLK,
			dest_ip_out(31 downto 0) => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtarget_addr_in(31 downto 0),
			dest_port_in(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxdest_port_out(15 downto 0),
			dest_port_out(15 downto 0) => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtarget_port_in(15 downto 0),
			eth_link_up_in => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxlink_up_out,
			hibi_av_in => udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2AV,
			hibi_av_out => udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2AV,
			hibi_comm_in(4 downto 0) => udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2COMM(4 downto 0),
			hibi_comm_out(4 downto 0) => udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2COMM(4 downto 0),
			hibi_data_in(31 downto 0) => udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2DATA(31 downto 0),
			hibi_data_out(31 downto 0) => udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2DATA(31 downto 0),
			hibi_empty_in => udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2EMPTY,
			hibi_full_in => udp2hibi_0_hibi_slave_to_hibi_segment_0_ip_mSlave_2FULL,
			hibi_re_out => udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2RE,
			hibi_we_out => udp2hibi_0_hibi_master_to_hibi_segment_0_ip_mMaster_2WE,
			new_rx_in => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxnew_rx_out,
			new_tx_out => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txnew_tx_in,
			rst_n => SW_17,
			rx_data_in(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_out(15 downto 0),
			rx_data_valid_in => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_valid_out,
			rx_erroneous_in => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_erroneous_out,
			rx_len_in(10 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_len_out(10 downto 0),
			rx_re_out => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_re_in,
			source_ip_in(31 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_addr_out(31 downto 0),
			source_port_in(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_port_out(15 downto 0),
			source_port_out(15 downto 0) => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txsource_port_in(15 downto 0),
			tx_data_out(15 downto 0) => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_data_in(15 downto 0),
			tx_data_valid_out => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_data_valid_in,
			tx_len_out(10 downto 0) => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_len_in(10 downto 0),
			tx_re_in => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_re_out
		);

	udp_ip_dm9000a_0 : udp_ip_dm9000a
		port map (
			clk => udp2hibi_0_clk_udp_to_pll_0_clk_25MHzCLK,
			dest_port_out(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxdest_port_out(15 downto 0),
			eth_chip_sel_out => ENET_CS_N,
			eth_clk_out => ENET_CLK,
			eth_cmd_out => ENET_CMD,
			eth_data_inout(15 downto 0) => ENET_DATA(15 downto 0),
			eth_interrupt_in => ENET_INT,
			eth_read_out => ENET_RD_N,
			eth_reset_out => ENET_RST_N,
			eth_write_out => ENET_WR_N,
			link_up_out => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxlink_up_out,
			new_rx_out => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxnew_rx_out,
			new_tx_in => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txnew_tx_in,
			no_arp_target_MAC_in => "0",
			rst_n => SW_17,
			rx_data_out(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_out(15 downto 0),
			rx_data_valid_out => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_valid_out,
			rx_erroneous_out => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_erroneous_out,
			rx_len_out(10 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_len_out(10 downto 0),
			rx_re_in => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_re_in,
			source_addr_out(31 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_addr_out(31 downto 0),
			source_port_in(15 downto 0) => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txsource_port_in(15 downto 0),
			source_port_out(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_port_out(15 downto 0),
			target_addr_in(31 downto 0) => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtarget_addr_in(31 downto 0),
			target_port_in(15 downto 0) => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtarget_port_in(15 downto 0),
			tx_data_in(15 downto 0) => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_data_in(15 downto 0),
			tx_data_valid_in => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_data_valid_in,
			tx_len_in(10 downto 0) => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_len_in(10 downto 0),
			tx_re_out => udp_ip_dm9000a_0_app_tx_to_udp2hibi_0_udp_ip_txtx_re_out
		);

end structural;


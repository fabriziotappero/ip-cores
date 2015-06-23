-- ***************************************************
-- File: hibi_dct.vhd
-- Creation date: 25.03.2013
-- Creation time: 13:53:33
-- Description: This block combines dct to hibi dctQidct block together
-- 
-- DCT_TO_HIBI Connects dctQidct block to HIBI Wrapper
-- 
-- Input:
-- 1.  Address to send the results to quant
-- 2.  Address to send the results to idct (set unused address if you don't use this)
-- 2. Control word for the current macroblock
--     Control word structure: bit    6: chroma(1)/luma(0) NOT USED, 
-- 	                        5: intra(1)/inter(0),
--                                                    4..0: quantizer parameter (QP)
-- 3. Then the DCT data ( 8x8x6 x 16-bit values = 384 x 16 bit )
-- 
-- Only 9b DCT data values are supported currently. 
-- Send two DCT-values packed to upper and lower 16bits in the sigle hibi transmission. 
-- 
-- <31------------------16--------------------0>  BIT index
--             DCT_DATA_1         DCT_DATA_0     DATA                    
-- 
-- 
-- NOTE: If self release is used (use_self_rel_g=1) user gets the signal that dct_to_hibi is ready to receive data.
--             By default self release is disabled and you user can send data to dct_to_hibi after quant results are received. 
-- 	
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
-- Created by: matilail
-- This file was generated with Kactus2 vhdl generator.
-- ***************************************************
library IEEE;
library dct_to_hibi;
library work;
use dct_to_hibi.all;
use work.all;
use IEEE.std_logic_1164.all;

entity hibi_dct is

	port (

		-- Interface: clk
		clk : in std_logic;

		-- Interface: hibi_master
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

		-- Interface: rst_n
		rst_n : in std_logic
	);

end hibi_dct;


architecture structural of hibi_dct is

	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifCHROMA_TO_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_DCT_TO_ACC : std_logic_vector(8 downto 0);
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_IDCT_FROM_ACC : std_logic_vector(8 downto 0);
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_QUANT_FROM_ACC : std_logic_vector(7 downto 0);
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDCT_READY4COL_FROM_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifIDCT_READY4COL_TO_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifINTRA_TO_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifLOAD_QP_TO_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQP_TO_ACC : std_logic_vector(4 downto 0);
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQUANT_READY4COL_TO_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_DCT_TO_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_IDCT_FROM_ACC : std_logic;
	signal dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_QUANT_FROM_ACC : std_logic;

	-- DCT to Hibi. Connects dctQidct block to HIBI Wrapper
	-- 
	-- Input:
	-- 1.  Address to send the results to quant
	-- 2.  Address to send the results to idct (set unused address if you don't use this)
	-- 2. Control word for the current macroblock
	--     Control word structure: bit    6: chroma(1)/luma(0) (NOT USED), 
	-- 	                        5: intra(1)/inter(0),
	--                                                    4..0: quantizer parameter (QP)
	-- 3. Then the DCT data ( 8x8x6 x 16-bit values = 384 x 16 bit )
	-- 
	-- Only 9b DCT data values are supported currently. 
	-- Send two DCT-values packed to upper and lower 16bits in the sigle hibi transmission. 
	-- 
	-- <31------------------16--------------------0>  BIT index
	--             DCT_DATA_1         DCT_DATA_0     DATA                    
	-- 
	-- 
	-- NOTE: If self release is used (use_self_rel_g=1) user gets the signal that dct_to_hibi is ready to receive data.
	--             By default self release is disabled and you user can send data to dct_to_hibi after quant results are received. 
	-- 	
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
			use_self_rel_g : integer := 0 -- Does it release itself from RTM?

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
			clk => clk,
			data_dct_out(8 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_DCT_TO_ACC(8 downto 0),
			data_idct_in(8 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_IDCT_FROM_ACC(8 downto 0),
			data_quant_in(7 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_QUANT_FROM_ACC(7 downto 0),
			dct_ready4col_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDCT_READY4COL_FROM_ACC,
			hibi_av_in => hibi_av_in,
			hibi_av_out => hibi_av_out,
			hibi_comm_in(4 downto 0) => hibi_comm_in(4 downto 0),
			hibi_comm_out(4 downto 0) => hibi_comm_out(4 downto 0),
			hibi_data_in(31 downto 0) => hibi_data_in(31 downto 0),
			hibi_data_out(31 downto 0) => hibi_data_out(31 downto 0),
			hibi_empty_in => hibi_empty_in,
			hibi_full_in => hibi_full_in,
			hibi_re_out => hibi_re_out,
			hibi_we_out => hibi_we_out,
			idct_ready4col_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifIDCT_READY4COL_TO_ACC,
			intra_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifINTRA_TO_ACC,
			loadQP_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifLOAD_QP_TO_ACC,
			QP_out(4 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQP_TO_ACC(4 downto 0),
			quant_ready4col_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQUANT_READY4COL_TO_ACC,
			rst_n => rst_n,
			wr_dct_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_DCT_TO_ACC,
			wr_idct_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_IDCT_FROM_ACC,
			wr_quant_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_QUANT_FROM_ACC
		);

	dctqidct_0 : dctQidct_core
		port map (
			chroma_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifCHROMA_TO_ACC,
			clk => clk,
			data_dct_in(8 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_DCT_TO_ACC(8 downto 0),
			data_idct_out(8 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_IDCT_FROM_ACC(8 downto 0),
			data_quant_out(7 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDATA_QUANT_FROM_ACC(7 downto 0),
			dct_ready4column_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifDCT_READY4COL_FROM_ACC,
			idct_ready4column_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifIDCT_READY4COL_TO_ACC,
			intra_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifINTRA_TO_ACC,
			loadQP_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifLOAD_QP_TO_ACC,
			QP_in(4 downto 0) => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQP_TO_ACC(4 downto 0),
			quant_ready4column_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifQUANT_READY4COL_TO_ACC,
			rst_n => rst_n,
			wr_dct_in => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_DCT_TO_ACC,
			wr_idct_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_IDCT_FROM_ACC,
			wr_quant_out => dct_to_hibi_0_dct_if_to_dctqidct_0_dct_ifWR_QUANT_FROM_ACC
		);

end structural;


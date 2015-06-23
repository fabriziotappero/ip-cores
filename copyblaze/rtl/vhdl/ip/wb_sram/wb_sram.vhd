--------------------------------------------------------------------------------
-- Company: 
--
-- File: wb_sram.vhd
--
-- Description:
--	projet copyblaze
--	wishbone 8bit data Memory 
--
-- File history:
-- v1.0: 08/12/11: Creation
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

use	work.Usefull_Pkg.all;		-- Usefull Package

--------------------------------------------------------------------------------
-- Entity: wb_sram
--
-- Description:
--	
--	REMARQUE:
--
--	
-- History:
-- 08/12/11 AM: Creation
-- ---------------------
-- xx/xx/xx AM: 
--				
--------------------------------------------------------------------------------
entity wb_sram is
	generic
	(
		GEN_WIDTH_DATA		: positive := 8;
		GEN_DEPTH_MEM		: positive := 64
	);
	port
	(
		clk      : in  std_ulogic;
		reset    : in  std_ulogic;
		-- Wishbone bus
		wb_adr_i : in  std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		wb_dat_i : in  std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		wb_dat_o : out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		wb_cyc_i : in  std_ulogic;
		wb_stb_i : in  std_ulogic;
		wb_ack_o : out std_ulogic;
		wb_we_i  : in  std_ulogic
	);
end wb_sram;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : wb_sram
--------------------------------------------------------------------------------
architecture rtl of wb_sram is

	type	MEM_TYPE is array(0 to GEN_DEPTH_MEM-1) of std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);

	signal	iMemArray		: MEM_TYPE;
	signal	iMemDataIn		,
			iMemDataOut		: std_ulogic_vector( GEN_WIDTH_DATA-1 downto 0 );
	signal	iMemAddr		: std_ulogic_vector( log2(GEN_DEPTH_MEM)-1 downto 0 );
	signal	iMemWrite		: std_ulogic;
	
begin

	-- ============== --
	-- Memory Process --
	-- ============== --
	Mem_Proc : process(reset, clk)
	begin
		if ( reset='0' ) then
		-- For Simulation only
			for i in 0 to GEN_DEPTH_MEM-1 loop
				iMemArray(i)	<=	(others=>'0');
				--iMemArray(i)	<=	std_ulogic_vector(to_unsigned(GEN_DEPTH_MEM-i, GEN_WIDTH_DATA));
			end loop;		
		elsif ( rising_edge(clk) ) then
			if ( iMemWrite = '1' ) then
				iMemArray( to_integer(unsigned(iMemAddr)) )	<= iMemDataIn;
			end if;
		end if;
	end process Mem_Proc;
	iMemDataOut	<=	iMemArray( to_integer(unsigned(iMemAddr)) );

	-- ================== --
	-- Wishbone Interface --
	-- ================== --
	wb_dat_o	<=	iMemDataOut;
	wb_ack_o	<=	wb_stb_i;
	
	iMemWrite	<=	wb_stb_i and wb_we_i;
	iMemDataIn	<=	wb_dat_i;
	iMemAddr	<=	wb_adr_i(iMemAddr'range);
	
	
end rtl;
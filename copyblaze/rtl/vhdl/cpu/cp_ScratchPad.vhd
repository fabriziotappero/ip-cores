--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_ScratchPad.vhd
--
-- Description:
--	projet copyblaze
--	Scratch Pad Memory 
--
-- File history:
-- v1.0: 10/10/11: Creation
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use	work.Usefull_Pkg.all;		-- Usefull Package

--------------------------------------------------------------------------------
-- Entity: cp_ScratchPad
--
-- Description:
--	
--	REMARQUE:
--
--	
-- History:
-- 10/10/11 AM: Creation
-- ---------------------
-- xx/xx/xx AM: 
--				
--------------------------------------------------------------------------------
entity cp_ScratchPad is
	generic
	(
		GEN_WIDTH_DATA		: positive := 8;
		GEN_DEPTH_SCRATCH	: positive := 64
	);
	port (
	--------------------------------------------------------------------------------
	-- Signaux Systeme
	--------------------------------------------------------------------------------
		Clk_i				: in std_ulogic;	--	signal d'horloge générale
		Rst_i_n				: in std_ulogic;	--	signal de reset générale

	--------------------------------------------------------------------------------
	-- Signaux Fonctionels
	--------------------------------------------------------------------------------
		Ptr_i				: in std_ulogic_vector(log2(GEN_DEPTH_SCRATCH)-1 downto 0);
		
		Write_i				: in std_ulogic;
		Data_i				: in std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
		
		Data_o				: out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0)
	);
end cp_ScratchPad;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_ScratchPad
--------------------------------------------------------------------------------
architecture rtl of cp_ScratchPad is

	--------------------------------------------------------------------------------
	-- Définition des fonctions
	--------------------------------------------------------------------------------
	


	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	type RAM_TYPE is array (0 to GEN_DEPTH_SCRATCH-1) of std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);

	signal iScratchPadMem	: RAM_TYPE;
	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------

begin
	
	--------------------------------------------------------------------------------
	-- Process : ScratchPad_Proc
	-- Description: ScratchPad Memory
	--------------------------------------------------------------------------------
	ScratchPad_Proc : process(Rst_i_n, Clk_i)
	begin
		if ( Rst_i_n = '0' ) then
			for i in 0 to GEN_DEPTH_SCRATCH-1 loop
				iScratchPadMem(i)	<= (others=>'0');
			end loop;

		elsif ( rising_edge(Clk_i) ) then
			if ( Write_i = '1' ) then
				iScratchPadMem( to_integer(unsigned(Ptr_i)) )	<= Data_i;
			end if;
		end if;
	end process ScratchPad_Proc;

	Data_o	<=	iScratchPadMem( to_integer(unsigned(Ptr_i)) );

end rtl;


--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_ProgramCounter.vhd
--
-- Description:
--	projet copyblaze
--	Program Counter management
--
-- File history:
-- v1.0: 04/10/11: Creation
-- v1.1: 12/10/11: Modification du traitement des conditions de saut
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use	work.Usefull_Pkg.all;		-- Usefull Package

--------------------------------------------------------------------------------
-- Entity: cp_ProgramCounter
--
-- Description:
--	
--	REMARQUE:
--
--	
-- History:
-- 04/10/11 AM: Creation
-- ---------------------
-- xx/xx/xx AM: 
--				
--------------------------------------------------------------------------------
entity cp_ProgramCounter is
	generic
	(
		GEN_WIDTH_PC		: positive := 8
	);
	port (
	--------------------------------------------------------------------------------
	-- Signaux Systeme
	--------------------------------------------------------------------------------
		Clk_i				: in std_ulogic;	--	signal d'horloge générale
		Rst_i_n				: in std_ulogic;	--	signal de reset générale

		Enable_i			: in std_ulogic;
	--------------------------------------------------------------------------------
	-- Signaux Fonctionels
	--------------------------------------------------------------------------------
		PC_i				: in std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);
		Change_i			: in std_ulogic;

		PC_o				: out std_ulogic_vector(GEN_WIDTH_PC-1 downto 0)
	);
end cp_ProgramCounter;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_ProgramCounter
--------------------------------------------------------------------------------
architecture rtl of cp_ProgramCounter is

	--------------------------------------------------------------------------------
	-- Définition des fonctions
	--------------------------------------------------------------------------------


	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	signal	iPC			: std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);
	signal	iPcNext		: std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);

	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------

begin


	iPcNext	<=	(PC_i)									when ( Change_i = '1' ) else
				std_ulogic_vector(UNSIGNED(iPC) + 1);

	--------------------------------------------------------------------------------
	-- Process : PC_Proc
	-- Description: 
	--------------------------------------------------------------------------------
	PC_Proc : process(Rst_i_n, Clk_i)
	begin
		if ( Rst_i_n = '0' ) then
			iPC				<=	(others=>'0');
		elsif ( rising_edge(Clk_i) ) then
			if (Enable_i = '1') then
				iPC			<=	iPcNext;
			end if;
		end if;
	end process PC_Proc;

	PC_o <=	iPC;

end rtl;


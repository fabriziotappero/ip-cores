--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_Flags.vhd
--
-- Description:
--	projet copyblaze
--	Flags ZERO & CARRY management
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
-- Entity: cp_Flags
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
entity cp_Flags is
	port (
	--------------------------------------------------------------------------------
	-- Signaux Systeme
	--------------------------------------------------------------------------------
		Clk_i				: in std_ulogic;	--	signal d'horloge générale
		Rst_i_n				: in std_ulogic;	--	signal de reset générale

	--------------------------------------------------------------------------------
	-- Signaux Fonctionels
	--------------------------------------------------------------------------------
		Z_i					: in std_ulogic;
		C_i					: in std_ulogic;
		
		Z_o					: out std_ulogic;
		C_o					: out std_ulogic;
		
		Push_i				: in std_ulogic;
		Pop_i				: in std_ulogic;
		
		Write_i				: in std_ulogic
	);
end cp_Flags;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_Flags
--------------------------------------------------------------------------------
architecture rtl of cp_Flags is

	--------------------------------------------------------------------------------
	-- Définition des fonctions
	--------------------------------------------------------------------------------
	


	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	signal		iZ		: std_ulogic;	-- flag
	signal		iC		: std_ulogic;	-- flag
	
	signal		iZs		: std_ulogic;	-- Shadow flag
	signal		iCs		: std_ulogic;	-- Shadow flag
	
	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------

begin
	
	--------------------------------------------------------------------------------
	-- Process : Flags_Proc
	-- Description: Flags Management
	--------------------------------------------------------------------------------
	Flags_Proc : process(Rst_i_n, Clk_i)
	begin
		if ( Rst_i_n = '0' ) then
			iZ	<=	'0';
			iC	<=	'0';

		elsif ( rising_edge(Clk_i) ) then
			if ( Write_i = '1' ) then
				iZ	<=	Z_i;
				iC	<=	C_i;
			elsif ( Pop_i = '1' ) then
				iZ	<=	iZs;
				iC	<=	iCs;
			end if;
		end if;
	end process Flags_Proc;
	
	--------------------------------------------------------------------------------
	-- Process : ShadowFlags_Proc
	-- Description: Shadow Flags Management
	--------------------------------------------------------------------------------
	ShadowFlags_Proc : process(Rst_i_n, Clk_i)
	begin
		if ( Rst_i_n = '0' ) then
			iZs	<=	'0';
			iCs	<=	'0';

		elsif ( rising_edge(Clk_i) ) then
			if ( Push_i = '1' ) then
				iZs	<=	iZ;
				iCs	<=	iC;
			end if;
		end if;
	end process ShadowFlags_Proc;
	
	Z_o		<=	iZ;
	C_o		<=	iC;

end rtl;


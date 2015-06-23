--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_BancRegister.vhd
--
-- Description:
--	projet copyblaze
--	Banc Registers 
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
-- Entity: cp_BancRegister
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
entity cp_BancRegister is
	generic
	(
		GEN_WIDTH_DATA		: positive := 8;
		GEN_DEPTH_BANC		: positive := 16
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
		SxPtr_i				: in std_ulogic_vector(log2(GEN_DEPTH_BANC)-1 downto 0);
		SyPtr_i				: in std_ulogic_vector(log2(GEN_DEPTH_BANC)-1 downto 0);
		
		Write_i				: in std_ulogic;
		SxData_i			: in std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
		
		SxData_o			: out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
		SyData_o			: out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0)
	);
end cp_BancRegister;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_BancRegister
--------------------------------------------------------------------------------
architecture rtl of cp_BancRegister is

	--------------------------------------------------------------------------------
	-- Définition des fonctions
	--------------------------------------------------------------------------------
	


	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Machine d'état principale de pilotage du driver de l'igbt
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	type RAM_TYPE is array (0 to GEN_DEPTH_BANC-1) of std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);

	signal iBancRegMem	: RAM_TYPE;
	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------

begin
	
	--------------------------------------------------------------------------------
	-- Process : BancReg_Proc
	-- Description: BancRegister Memory
	--------------------------------------------------------------------------------
	BancReg_Proc : process(Rst_i_n, Clk_i)
	begin
		if ( Rst_i_n = '0' ) then
			for i in 0 to GEN_DEPTH_BANC-1 loop
				iBancRegMem(i)	<= (others=>'0');
			end loop;

		elsif ( rising_edge(Clk_i) ) then
			if ( Write_i = '1' ) then
				iBancRegMem( to_integer(unsigned(SxPtr_i)) )	<= SxData_i;
			end if;
		end if;
	end process BancReg_Proc;

	SxData_o	<=	iBancRegMem( to_integer(unsigned(SxPtr_i)) );
	SyData_o	<=	iBancRegMem( to_integer(unsigned(SyPtr_i)) );

end rtl;


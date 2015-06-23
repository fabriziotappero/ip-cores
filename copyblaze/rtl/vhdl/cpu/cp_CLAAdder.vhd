--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_CLAAdder.vhd
--
-- Description:
--	projet copyblaze
--	carry look-ahead adder by recursively expanding the carry term to each stage
--
-- File history:
-- v1.0: 14/10/11: Creation
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use	work.Usefull_Pkg.all;		-- Usefull Package

--------------------------------------------------------------------------------
-- Entity: cp_CLAAdder
--
-- Description:
--	
--	REMARQUE:
--
--	
-- History:
-- 14/10/11 AM: Creation
-- ---------------------
-- xx/xx/xx AM: 
--				
--------------------------------------------------------------------------------
entity cp_CLAAdder is
	generic
	(
		GEN_WIDTH_DATA		: positive := 8
	);
	port (
	--------------------------------------------------------------------------------
	-- Signaux Fonctionels
	--------------------------------------------------------------------------------
		CarryIn_i			: in std_ulogic;
		sX_i				: in std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		sY_i				: in std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);

		CarryOut_o			: out std_ulogic;
		Result_o			: out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0)
	);
end cp_CLAAdder;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_CLAAdder
--------------------------------------------------------------------------------
architecture rtl of cp_CLAAdder is

	--------------------------------------------------------------------------------
	-- Définition des fonctions
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	signal iCarry: std_ulogic_vector (GEN_WIDTH_DATA downto 0);
		
	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------
	component cp_FullAdder
		port (
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			Ci_i		: in std_ulogic;
			A_i			: in std_ulogic;
			B_i			: in std_ulogic;
	
			Co_o		: out std_ulogic;
			S_o			: out std_ulogic
		);
	end component;

begin

	--------------------------------------------------------------------------------
	-- Full adder
	--------------------------------------------------------------------------------
     Adder_Gen: for i in 0 to GEN_WIDTH_DATA-1 generate
	 
		U_FullAdder : cp_FullAdder
			port map(
			--------------------------------------------------------------------------------
			-- Signaux Fonctionels
			--------------------------------------------------------------------------------
				Ci_i		=> iCarry(i)	,
				A_i			=> sX_i(i)		,
				B_i			=> sY_i(i)		,

				Co_o		=> iCarry(i+1)	,
				S_o			=> Result_o(i)
			);
      end generate Adder_Gen;

      iCarry(0)		<=	CarryIn_i;
      CarryOut_o	<=	iCarry(GEN_WIDTH_DATA);

end rtl;


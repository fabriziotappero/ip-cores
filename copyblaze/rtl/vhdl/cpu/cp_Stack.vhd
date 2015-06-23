--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_Stack.vhd
--
-- Description:
--	projet copyblaze
--	Program Counter stack
--
-- File history:
-- v1.0: 07/10/11: Creation
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use	work.Usefull_Pkg.all;		-- Usefull Package

--------------------------------------------------------------------------------
-- Entity: cp_Stack
--
-- Description:
--	
--	REMARQUE:
--
--	
-- History:
-- 07/10/11 AM: Creation
-- ---------------------
-- xx/xx/xx AM: 
--				
--------------------------------------------------------------------------------
entity cp_Stack is
	generic
	(
		GEN_WIDTH_PC		: positive := 8;
		GEN_DETPH			: positive := 15
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
		Data_i				: in std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);	-- 
		Data_o				: out std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);	-- 
		
		Enable_i			: in std_ulogic;
		
		Push_i				: in std_ulogic;
		Pop_i				: in std_ulogic
	);
end cp_Stack;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_Stack
--------------------------------------------------------------------------------
architecture rtl of cp_Stack is

	--------------------------------------------------------------------------------
	-- Définition des fonctions
	--------------------------------------------------------------------------------
	


	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	type RAM_TYPE is array (0 to GEN_DETPH-1) of std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);--(Data_i'range);

	signal iStackMem	: RAM_TYPE;
	signal iStackEn		: std_ulogic;

	signal iPointer		: natural range 0 to GEN_DETPH-1;
	signal iPtrUp		: std_ulogic;
	signal iPtrDown		: std_ulogic;
	
	signal iTempo		: std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);

	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------

begin
	
	iStackEn	<= not(Enable_i) and Push_i;
	--------------------------------------------------------------------------------
	-- Process : Stack_Proc
	-- Description: Stack Memory
	--------------------------------------------------------------------------------
	Stack_Proc : process(Rst_i_n, Clk_i)
	begin
		if ( Rst_i_n = '0' ) then
			for i in 0 to GEN_DETPH-1 loop
				iStackMem(i)	<= (others=>'0');
			end loop;
			iTempo				<= (others=>'0');
		elsif ( rising_edge(Clk_i) ) then
			if ( iPtrUp = '1' ) then
				iTempo	<=	Data_i;
			end if;
			if ( iStackEn = '1' ) then
				iStackMem( iPointer )	<= iTempo;
			end if;
		end if;
	end process Stack_Proc;
	
	
	iPtrUp		<= Enable_i and Push_i;
	iPtrDown	<= Enable_i and Pop_i;
	--------------------------------------------------------------------------------
	-- Process : Ptr_Proc
	-- Description: Stack pointer
	--------------------------------------------------------------------------------
	Ptr_Proc : process(Rst_i_n, Clk_i)
	begin
		if ( Rst_i_n = '0' ) then
			iPointer		<=	GEN_DETPH-1;
			
		elsif ( rising_edge(Clk_i) ) then
			if ( iPtrUp = '1' ) then
				if ( iPointer + 1 = GEN_DETPH ) then
					iPointer	<= 0;
				else
					iPointer	<=	(iPointer + 1) ;
				end if;
			end if;
			
			if ( iPtrDown = '1' ) then
				if ( iPointer = 0 ) then
					iPointer	<= GEN_DETPH-1;
				else
					iPointer	<=	(iPointer - 1) ;
				end if;
				
			end if;
			
		end if;
	end process Ptr_Proc;

	Data_o	<=	iStackMem( iPointer );

end rtl;


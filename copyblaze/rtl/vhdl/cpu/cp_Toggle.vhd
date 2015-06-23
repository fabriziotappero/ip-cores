--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_Toggle.vhd
--
-- Description:
--	projet copyblaze
--	Toggle horloge clock (divisor by 2)
--
-- File history:
-- v1.0: 07/10/11: Creation
-- v2.0: 25/10/11: Add Freeze Management
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use	work.Usefull_Pkg.all;		-- Usefull Package

--------------------------------------------------------------------------------
-- Entity: cp_Toggle
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
entity cp_Toggle is
	port (
	--------------------------------------------------------------------------------
	-- Signaux Systeme
	--------------------------------------------------------------------------------
		Clk_i				: in std_ulogic;	--	signal d'horloge générale
		Rst_i_n				: in std_ulogic;	--	signal de reset générale

	--------------------------------------------------------------------------------
	-- Signaux Fonctionels
	--------------------------------------------------------------------------------
		Freeze_i			: in std_ulogic;

		Phase1_o			: out std_ulogic;
		Phase2_o			: out std_ulogic
	);
end cp_Toggle;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_Toggle
--------------------------------------------------------------------------------
architecture rtl of cp_Toggle is

	--------------------------------------------------------------------------------
	-- Définition des fonctions
	--------------------------------------------------------------------------------
	type States_TYPE is
	(
		S_NORMAL		,	-- 
		S_FREEZE			-- for external "Freeze processor" signal
	);
	


	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	signal	iFSM_State	: States_TYPE;								-- Signal de la machine d'état
	
	signal	iPhase1		: std_ulogic;
	signal	iPhase2		: std_ulogic;
	
	signal	iPhase1Out	: std_ulogic;
	signal	iPhase2Out	: std_ulogic;

	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------

begin

	--------------------------------------------------------------------------------
	-- Process : Phase_Proc
	-- Description: generate the Phase1 and Phase2 of the processor
	--------------------------------------------------------------------------------
	Phase_Proc : process(Rst_i_n, Clk_i)
	begin
		if ( Rst_i_n = '0' ) then
			iPhase1	<= '0';
			iPhase2	<= '0';

		elsif ( rising_edge(Clk_i) ) then
			iPhase1	<= not( iPhase1 );
			iPhase2 <= iPhase1;
		end if;
	end process Phase_Proc;

	
	--------------------------------------------------------------------------------
	-- Process : Freeze_Proc
	-- Description: if Freeze_i signal is active, then the processor exectution is freezed (stoped)
	--------------------------------------------------------------------------------
	Freeze_Proc : process(Rst_i_n, Clk_i)
	begin
	
		if ( Rst_i_n = '0' ) then
			iFSM_State		<=	S_NORMAL;

		elsif ( rising_edge(Clk_i) ) then
		
				case iFSM_State is
					when S_NORMAL =>
						if ( ( iPhase2 = '1' ) and (Freeze_i = '1') ) then
							iFSM_State	<=	S_FREEZE;
						end if;
	
					when S_FREEZE =>
						if ( ( iPhase2 = '1' ) and (Freeze_i = '0') ) then
							iFSM_State	<=	S_NORMAL;
						end if;
					
				end case;

		end if;
	end process Freeze_Proc;

	with iFSM_State select
		iPhase1Out	<=	iPhase1	when S_NORMAL,
						'0'		when S_FREEZE,	--	Phase 1 to 0
						'0'		when others;
	with iFSM_State select
		iPhase2Out	<=	iPhase2	when S_NORMAL,
						'0'		when S_FREEZE,	--	Phase 2 to 0
						'0'		when others;

						
	Phase1_o	<= iPhase1Out;
	Phase2_o	<= iPhase2Out;

end rtl;


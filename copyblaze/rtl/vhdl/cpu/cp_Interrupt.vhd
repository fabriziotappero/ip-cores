--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_Interrupt.vhd
--
-- Description:
--	projet copyblaze
--	Interrupt Module
--
-- File history:
-- v1.0: 17/10/11: Creation
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use	work.Usefull_Pkg.all;		-- Usefull Package

--------------------------------------------------------------------------------
-- Entity: cp_Interrupt
--
-- Description:
--	
--	REMARQUE:
--
--	
-- History:
-- 17/10/11 AM: Creation
-- ---------------------
-- xx/xx/xx AM: 
--				
--------------------------------------------------------------------------------
entity cp_Interrupt is
	port (
	--------------------------------------------------------------------------------
	-- Signaux Systeme
	--------------------------------------------------------------------------------
		Clk_i				: in std_ulogic;	--	signal d'horloge générale
		Rst_i_n				: in std_ulogic;	--	signal de reset générale

	--------------------------------------------------------------------------------
	-- Signaux Fonctionels
	--------------------------------------------------------------------------------
		IEWrite_i			: in std_ulogic;
		IEValue_i			: in std_ulogic;
		
		--Phase1_i			: in std_ulogic;
		Phase2_i			: in std_ulogic;

		Interrupt_i			: in std_ulogic;
		IEvent_o			: out std_ulogic
	);
end cp_Interrupt;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_Interrupt
--------------------------------------------------------------------------------
architecture rtl of cp_Interrupt is

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
	signal	iInterrupt_i_old	: std_ulogic;
	signal	iInterrupt_i_edge	: std_ulogic;
	signal	iIDetect			: std_ulogic;

	signal	iIE					: std_ulogic; -- Interrupt Enable Flags
	signal	iIEvent				: std_ulogic; -- Interrupt Event Flags
	
	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------

begin
	
	iInterrupt_i_edge	<=	(Interrupt_i) and ( not(iInterrupt_i_old) );

	--------------------------------------------------------------------------------
	-- Process : IE_Proc
	-- Description: Interrupt management
	--------------------------------------------------------------------------------
	-- Interrupt Flag -- 
	IE_Proc : process(Rst_i_n, Clk_i)
	begin
		if ( Rst_i_n = '0' ) then
			iInterrupt_i_old	<=	'0';
			iIE					<=	'0';
			iIEvent				<=	'0';
					
			iIDetect			<= '0';
			
		elsif ( rising_edge(Clk_i) ) then
			-- Interrupt Input sampling
			iInterrupt_i_old	<=	Interrupt_i;
		
			-- Set the IE bit
			if ( IEWrite_i ='1' ) then
				iIE		<=	IEValue_i;
			end if;
			if ( iIEvent = '1' ) then
				iIE		<=	'0';
			end if;

			-- Save the interrupt edge detection for a phase cycle
			if ( iInterrupt_i_edge = '1' ) then
				iIDetect	<= '1';
			elsif ( (Phase2_i = '1') and (iIDetect = '1') ) then
				iIDetect	<= '0';
			end if;
			
			-- Proceding the interrupt Event
			if ( (Phase2_i = '1') and (iIDetect = '1') and (iIE = '1') ) then
				iIEvent		<= '1';	-- Interrupt Event proceding now
				iIDetect	<= '0';	-- Now, can clear the EdgeDectection
				
			-- Next phase clear the IEvent
			-- TODO : The ENABLE INTERRUPT instruction must clear the "iIEvent" bit if is set while the interrupts are disabled.
			elsif ( (Phase2_i = '1') and (iIEvent = '1') ) then
				iIEvent		<= '0';	-- Clear the Interrupt Event
			end if;
			
		end if;
	end process IE_Proc;

	IEvent_o	<=	iIEvent;

end rtl;


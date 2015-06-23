--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_ProgramFlowControl.vhd
--
-- Description:
--	projet copyblaze
--	Program Flow Control management
--
-- File history:
-- v1.0: 10/10/11: Creation
-- v1.1: 11/10/11: Add Condionnal management
-- v1.2: 12/10/11: Modification du traitement des conditions de saut
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use	work.Usefull_Pkg.all;		-- Usefull Package

--------------------------------------------------------------------------------
-- Entity: cp_ProgramFlowControl
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
entity cp_ProgramFlowControl is
	generic
	(
		GEN_WIDTH_PC			: positive := 8;
		GEN_INT_VECTOR			: std_ulogic_vector(11 downto 0) := x"0F0";
		GEN_DEPTH_STACK			: positive := 15
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
		aaa_i				: in std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);	-- 
		
		Interrupt_i			: in std_ulogic;	-- 

		Jump_i				: in std_ulogic;
		Call_i				: in std_ulogic;
		Return_i			: in std_ulogic;
		ReturnI_i			: in std_ulogic;
		
		ConditionCtrl_i		: in std_ulogic_vector(2 downto 0);
		FlagC_i				: in std_ulogic;
		FlagZ_i				: in std_ulogic;
		
		PC_o				: out std_ulogic_vector(GEN_WIDTH_PC-1 downto 0)	-- 
	);
end cp_ProgramFlowControl;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_ProgramFlowControl
--------------------------------------------------------------------------------
architecture rtl of cp_ProgramFlowControl is

	--------------------------------------------------------------------------------
	-- Définition des fonctions
	--------------------------------------------------------------------------------
	


	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	signal	iPC			: std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);	-- Programm Counter Signal
	signal	iPCin		: std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);	-- Programm Counter Signal

	signal	iDataStackToPC	: std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);
	
	signal	iChangePC		: std_ulogic;
	
	alias	iUnConditionnal	: std_ulogic					is	ConditionCtrl_i(2);
	alias	iConditionnal	: std_ulogic_vector(1 downto 0)	is	ConditionCtrl_i(1 downto 0);
	signal	iCondition		: std_ulogic;

	signal	iPush		: std_ulogic;
	signal	iPop		: std_ulogic;
	
	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------
	component cp_ProgramCounter
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
	end component;

	component cp_Stack
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
	end component;
	
begin

	--------------------------------------------------------------------------------
	-- Traitement des conditions du saut du PC
	--------------------------------------------------------------------------------
	iCondition	<=		'1'			when	(iUnConditionnal='0')	else
						FlagZ_i		when	(iConditionnal="00")	else
					not(FlagZ_i)	when	(iConditionnal="01")	else
						FlagC_i		when	(iConditionnal="10")	else
					not(FlagC_i)	when	(iConditionnal="11")	else
						'0';

	-- Commande d'écriture de la nouvelle valeur du PC
	iChangePC	<=	((Jump_i or Call_i or Return_i) and (iCondition))
					or
					(Interrupt_i) or (ReturnI_i);
	
	-- Nouvelle valeur du PC
	iPCin		<=	-- !TODO : Who has the priority, Jump or Interrupt?
					(GEN_INT_VECTOR(GEN_WIDTH_PC-1 downto 0))			when (Interrupt_i='1')	else
					(iDataStackToPC)									when (ReturnI_i='1')	else
					(std_ulogic_vector(UNSIGNED(iDataStackToPC) + 1))	when (Return_i='1')		else
					(aaa_i);
					
	--------------------------------------------------------------------------------
	-- Traitement des commande de Push & Pop de la stack
	--------------------------------------------------------------------------------
	iPush		<=	(iCondition and Call_i) or (Interrupt_i);
	iPop		<=	(iCondition and Return_i) or (ReturnI_i);
	
	--------------------------------------------------------------------------------
	-- Instantiation du composant "cp_ProgramCounter"
	--------------------------------------------------------------------------------
	U_ProgramCounter : cp_ProgramCounter
		generic map
		(
			GEN_WIDTH_PC		=>	GEN_WIDTH_PC
		)
		port map(
		--------------------------------------------------------------------------------
		-- Signaux Systeme
		--------------------------------------------------------------------------------
			Clk_i				=> Clk_i,
			Rst_i_n				=> Rst_i_n,
	
			Enable_i			=> Enable_i,
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			PC_i				=> iPCin,
			Change_i			=> iChangePC,
			
			PC_o				=> iPC
		);

	--------------------------------------------------------------------------------
	-- Instantiation du composant "cp_Stack"
	--------------------------------------------------------------------------------
	U_Stack : cp_Stack
		generic map
		(
			GEN_WIDTH_PC		=> GEN_WIDTH_PC,
			GEN_DETPH			=> GEN_DEPTH_STACK
		)
		port map(
		--------------------------------------------------------------------------------
		-- Signaux Systeme
		--------------------------------------------------------------------------------
			Clk_i				=> Clk_i,
			Rst_i_n				=> Rst_i_n,
	
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			Data_i				=> iPC,
			Data_o				=> iDataStackToPC,
			
			Enable_i			=> Enable_i,
			
			Push_i				=> iPush,
			Pop_i				=> iPop
		);
		
	--------------------------------------------------------------------------------
	-- Sorties
	--------------------------------------------------------------------------------
	PC_o <= iPC;

end rtl;


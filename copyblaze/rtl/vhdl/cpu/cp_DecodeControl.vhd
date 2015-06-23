--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_DecodeControl.vhd
--
-- Description:
--	projet copyblaze
--	instruction decoding & Operational control
--
-- File history:
-- v1.0: 21/10/11: Creation
-- v2.0: 26/10/11: Add Wishbone instructions
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use	work.Usefull_Pkg.all;		-- Usefull Package

--------------------------------------------------------------------------------
-- Entity: cp_DecodeControl
--
-- Description:
--	
--	REMARQUE:
--
--	
-- History:
-- 21/10/11 AM: Creation
-- ---------------------
-- xx/xx/xx AM: 
--				
--------------------------------------------------------------------------------
entity cp_DecodeControl is
	generic
	(
		GEN_WIDTH_INST		: positive := 18;
		GEN_WIDTH_PC		: positive := 10;

		GEN_DEPTH_BANC		: positive := 16;	-- Taille (en octet) du Banc Register
		GEN_DEPTH_SCRATCH	: positive := 64	-- Taille (en octet) du Scratch Pad
	);
	port (
	--------------------------------------------------------------------------------
	-- Signaux Fonctionels
	--------------------------------------------------------------------------------
		--Phase1_i			: in std_ulogic;
		Phase2_i			: in std_ulogic;
		
		IEvent_i			: in std_ulogic;
		
		Instruction_i		: in std_ulogic_vector(GEN_WIDTH_INST-1 downto 0);		

		Fetch_o				: out std_ulogic;
		Input_o				: out std_ulogic;
		Ouput_o				: out std_ulogic;
		Jump_o				: out std_ulogic;
		Call_o				: out std_ulogic;
		Return_o			: out std_ulogic;
		ReturnI_o			: out std_ulogic;
		IEWrite_o			: out std_ulogic;
		BancWrite_o			: out std_ulogic;
		ScratchWrite_o		: out std_ulogic;
		OperationSelect_o	: out std_ulogic_vector(2 downto 0);
		FlagsWrite_o		: out std_ulogic;
		FlagsPush_o			: out std_ulogic;
		FlagsPop_o			: out std_ulogic;
		
		aaa_o				: out std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);
		kk_o				: out std_ulogic_vector(7 downto 0);
		ss_o				: out std_ulogic_vector(log2(GEN_DEPTH_SCRATCH)-1 downto 0);
		pp_o				: out std_ulogic_vector(7 downto 0);

		SxPtr_o				: out std_ulogic_vector(log2(GEN_DEPTH_BANC)-1 downto 0);
		SyPtr_o				: out std_ulogic_vector(log2(GEN_DEPTH_BANC)-1 downto 0);

		OperandSelect_o		: out std_ulogic;
		
		ArithOper_o			: out std_ulogic_vector(1 downto 0);
		LogicOper_o			: out std_ulogic_vector(1 downto 0);
		ShiftBit_o			: out std_ulogic_vector(2 downto 0);
		ShiftSens_o			: out std_ulogic;
		
		ConditionCtrl_o		: out std_ulogic_vector(2 downto 0);
		
		IEValue_o			: out std_ulogic;
		
		wbRdSing_o			: out std_ulogic;
		wbWrSing_o			: out std_ulogic
	);
end cp_DecodeControl;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_DecodeControl
--------------------------------------------------------------------------------
architecture rtl of cp_DecodeControl is

	--------------------------------------------------------------------------------
	-- Définition des fonctions
	--------------------------------------------------------------------------------
	


	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	signal	iInstruction		: std_ulogic_vector(GEN_WIDTH_INST-1 downto 0);

	alias	iInstructionCode	: std_ulogic_vector(4 downto 0) is iInstruction(17 downto 13);
	-- **** --
	-- PATH --
	-- **** --
	alias	iaaa				: std_ulogic_vector(GEN_WIDTH_PC-1 downto 0)			is iInstruction(GEN_WIDTH_PC-1 downto 0);
	alias	ikk					: std_ulogic_vector(7 downto 0)							is iInstruction(7 downto 0);
	alias	iss					: std_ulogic_vector(log2(GEN_DEPTH_SCRATCH)-1 downto 0)	is iInstruction(log2(GEN_DEPTH_SCRATCH)-1 downto 0);
	alias	ipp					: std_ulogic_vector(7 downto 0)							is iInstruction(7 downto 0);

	alias	iSxPtr				: std_ulogic_vector(log2(GEN_DEPTH_BANC)-1 downto 0)	is iInstruction(8+log2(GEN_DEPTH_BANC)-1 downto 8);
	alias	iSyPtr				: std_ulogic_vector(log2(GEN_DEPTH_BANC)-1 downto 0)	is iInstruction(4+log2(GEN_DEPTH_BANC)-1 downto 4);
	-- ******* --
	-- CONTROL --
	-- ******* --
	-- Alu
	signal	iOperationSelect	: std_ulogic_vector(2 downto 0);
	alias	iOperandSelect		: std_ulogic											is iInstruction(12);
	
	alias	iArithOper			: std_ulogic_vector(1 downto 0) 						is iInstruction(14 downto 13);
	alias	iLogicOper			: std_ulogic_vector(1 downto 0) 						is iInstruction(14 downto 13);
	alias	iShiftBit			: std_ulogic_vector(2 downto 0) 						is iInstruction(2 downto 0);
	alias	iShiftSens			: std_ulogic											is iInstruction(3);
	-- Banc
	signal	iBancWrite			: std_ulogic;
	-- Scratch
	signal	iScratchWrite		: std_ulogic;
	-- Flags
	signal	iFlagsWrite			,
			iFlagsPush			,
			iFlagsPop			: std_ulogic;

	signal	iIEWrite			: std_ulogic;
	signal	iAddSub				,
			iCompare			,
			iLoad				,
			iLogic				,
			iTest				,
			iShift				,
			iStore				,
			iFetch				,
			iInput				,
			iOuput				,
			iJump				,
			iCall				,
			iReturn				,
			iReturnI			,
			iSetInterrupt		,
			-- Wishbone instructions
			iWBWrSing			,
			iWBRdSing			
								: std_ulogic;
	-- Flow
	alias	iConditionCtrl		: std_ulogic_vector(2 downto 0) 						is iInstruction(12 downto 10);
	-- Int		
	alias	iIEValue			: std_ulogic					 						is iInstruction(0);
	signal	iIEvent				: std_ulogic;

	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------

begin
	--------------------------------------------------------------------------------
	-- DECODER
	--------------------------------------------------------------------------------
	iIEvent			<=	IEvent_i;

	-- Preempte the instruction in case of interrupt event
	iInstruction	<=	(others => '1') when (iIEvent='1') else Instruction_i;

	--------------------------------------------------------------------------------
	-- INSTRUCTION DECODER
	--------------------------------------------------------------------------------
	-- Arithmetic Group
	iAddSub			<=	'1' when ((iInstructionCode = '0' & x"C") or
								  (iInstructionCode = '0' & x"D") or
								  (iInstructionCode = '0' & x"E") or
								  (iInstructionCode = '0' & x"F")) else '0';
	iCompare		<=	'1' when ( iInstructionCode = '0' & x"A" ) else '0';

	-- Logic Group
	iLoad			<=	'1' when ( iInstructionCode = '0' & x"0" ) else '0';
	iLogic			<=	'1' when ((iInstructionCode = '0' & x"5") or
								  (iInstructionCode = '0' & x"6") or
								  (iInstructionCode = '0' & x"7")) else '0';
	iTest			<=	'1' when ( iInstructionCode = '0' & x"9" ) else '0';

	-- Shift and Rotate Group
	iShift			<=	'1' when ( iInstructionCode = '1' & x"0" ) else '0';

	-- Storage Group
	iStore			<=	'1' when ( iInstructionCode = '1' & x"7" ) else '0';
	iFetch			<=	'1' when ( iInstructionCode = '0' & x"3" ) else '0';

	-- Input/Ouput Group
	iInput			<=	'1' when ( iInstructionCode = '0' & x"2" ) else '0';
	iOuput			<=	'1' when ( iInstructionCode = '1' & x"6" ) else '0';
	
	-- Program Control Group
	iJump			<=	'1' when ( iInstructionCode = '1' & x"A" ) else '0';
	iCall			<=	'1' when ( iInstructionCode = '1' & x"8" ) else '0';
	iReturn			<=	'1' when ( iInstructionCode = '1' & x"5" ) else '0';

	-- Interrupt Group
	iReturnI		<=	'1' when ( iInstructionCode = '1' & x"C" ) else '0';
	-- TODO : The ENABLE INTERRUPT instruction must clear the "iIEvent" bit if is set while the interrupts are disabled.
	iSetInterrupt	<=	'1' when ( iInstructionCode = '1' & x"E" ) else '0';

	-- Reserved for extension 6
	-- STAR			= '0' & "B"	
	-- TESTCY		= '0' & "7"
	-- COMPARECY	= '0' & "F"
	-- REGBANK		= '1' & "B"
	-- OUTPUTK		= '1' & "5"
	-- CALL@		= '1' & "2"
	-- LOAD&RETURN	= '1' & "0"
	-- HWBUILD		= '0' & "A"
	
	-- Wishbone instructions
	iWBRdSing		<=	'1' when ( iInstructionCode = '0' & x"1" ) else '0';
	iWBWrSing		<=	'1' when ( iInstructionCode = '0' & x"4" ) else '0';
	--------------------------------------------------------------------------------
	-- CONTROL SIGNAL
	--------------------------------------------------------------------------------
	-- Flow
	iIEWrite		<=	(Phase2_i and (iSetInterrupt or iReturnI));
	-- Banc
	iBancWrite		<=	(Phase2_i and (iAddSub or iLoad or iLogic or iShift or iFetch or iInput));
	-- Scratch
	iScratchWrite	<=	(Phase2_i and (iStore));
	-- Alu
	iOperationSelect	<=	"000"	when (iShift='1')						else
							"001"	when (iLogic='1'	or iTest='1')		else
							"010"	when (iAddSub='1'	or iCompare='1')	else
							"011"	when (iLoad='1')						else
							"111";

	-- Flags
	iFlagsWrite		<= (Phase2_i and (iAddSub or iCompare or iLogic or iTest or iShift));
	iFlagsPush		<= (Phase2_i and (IEvent_i));
	iFlagsPop		<= (Phase2_i and (iReturnI));

	--------------------------------------------------------------------------------
	-- Outputs
	--------------------------------------------------------------------------------
	Fetch_o				<= iFetch			;
	Input_o				<= iInput			;
	Ouput_o				<= iOuput			;
	Jump_o				<= iJump			;
	Call_o				<= iCall			;
	Return_o			<= iReturn			;
	ReturnI_o			<= iReturnI			;
	IEWrite_o			<= iIEWrite			;
	BancWrite_o			<= iBancWrite		;
	ScratchWrite_o		<= iScratchWrite	;
	OperationSelect_o	<= iOperationSelect	;
	FlagsWrite_o		<= iFlagsWrite		;
	FlagsPush_o			<= iFlagsPush		;
	FlagsPop_o			<= iFlagsPop		;

	aaa_o				<= iaaa				;
	kk_o				<= ikk				;
	ss_o				<= iss				;
	pp_o				<= ipp				;

	SxPtr_o				<= iSxPtr			;
	SyPtr_o				<= iSyPtr			;
											
	OperandSelect_o		<= iOperandSelect	;
											
	ArithOper_o			<= iArithOper		;
	LogicOper_o			<= iLogicOper		;
	ShiftBit_o			<= iShiftBit		;
	ShiftSens_o			<= iShiftSens		;
	
	ConditionCtrl_o		<= iConditionCtrl	;
	
	IEValue_o			<= iIEValue			;
	
	wbRdSing_o			<= iWBRdSing		;
	wbWrSing_o			<= iWBWrSing		;

end rtl;

--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_copyBlaze.vhd
--
-- Description:
--	projet copyblaze
--	copyBlaze processor
--
-- File history:
-- v1.0: 10/10/11: Creation
-- v1.1: 24/10/11: Add the "Decode & Control" module
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use	work.Usefull_Pkg.all;		-- Usefull Package

--------------------------------------------------------------------------------
-- Entity: cp_copyBlaze
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
entity cp_copyBlaze is
	generic
	(
		GEN_WIDTH_DATA		: positive := 8;
		GEN_WIDTH_PC		: positive := 10;
		GEN_WIDTH_INST		: positive := 18;
		
		GEN_DEPTH_STACK		: positive := 15;	-- Taille (en octet) de la Stack
		GEN_DEPTH_BANC		: positive := 16;	-- Taille (en octet) du Banc Register
		GEN_DEPTH_SCRATCH	: positive := 64;	-- Taille (en octet) du Scratch Pad
		
		GEN_INT_VECTOR		: std_ulogic_vector(11 downto 0) := x"3FF" -- Interrupt Vector
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
		Address_o			: out std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);
		Instruction_i		: in std_ulogic_vector(GEN_WIDTH_INST-1 downto 0);
		
		Interrupt_i			: in std_ulogic;	-- 
		Interrupt_Ack_o		: out std_ulogic;	-- 
		
		IN_PORT_i			: in std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
		OUT_PORT_o			: out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
		PORT_ID_o			: out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
		READ_STROBE_o		: out std_ulogic;
		WRITE_STROBE_o		: out std_ulogic;
		
	--------------------------------------------------------------------------------
	-- Signaux Speciaux
	--------------------------------------------------------------------------------
		Freeze_i			: in std_ulogic;
		
	--------------------------------------------------------------------------------
	-- Signaux Wishbone Interface
	--------------------------------------------------------------------------------
--		RST_I   			: in    std_ulogic;
--		CLK_I   			: in    std_ulogic;
					
		ADR_O				: out	std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		DAT_I				: in	std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		DAT_O				: out	std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		WE_O    			: out	std_ulogic;
		SEL_O				: out	std_ulogic_vector(1 downto 0);

		STB_O   			: out	std_ulogic;
		ACK_I   			: in	std_ulogic;
		CYC_O   			: out	std_ulogic
	);
end cp_copyBlaze;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_copyBlaze
--------------------------------------------------------------------------------
architecture rtl of cp_copyBlaze is

	--------------------------------------------------------------------------------
	-- Définition des fonctions
	--------------------------------------------------------------------------------
	


	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	signal	iPhase1				: std_ulogic;
	signal	iPhase2				: std_ulogic;

	-- **** --
	-- PATH --
	-- **** --
	signal	iaaa				: std_ulogic_vector(GEN_WIDTH_PC-1 downto 0)			;
	signal	ikk					: std_ulogic_vector(7 downto 0)							;
	signal	iss					: std_ulogic_vector(log2(GEN_DEPTH_SCRATCH)-1 downto 0)	;
	signal	ipp					: std_ulogic_vector(7 downto 0)							;
	
	-- Flags
	signal	iZ					: std_ulogic;
	signal	iC					: std_ulogic;
	signal	iZi					: std_ulogic;
	signal	iCi					: std_ulogic;
	
	-- Alu
	signal	iAluResult			: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	
	-- Banc
	signal	iSxDataIn			: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
	signal 	iSxData				: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
	signal 	iSyData				: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
	signal	iSxPtr				: std_ulogic_vector(log2(GEN_DEPTH_BANC)-1 downto 0);
	signal	iSyPtr				: std_ulogic_vector(log2(GEN_DEPTH_BANC)-1 downto 0);
	-- Scratch
	signal	iScratchPtr			: std_ulogic_vector(log2(GEN_DEPTH_SCRATCH)-1 downto 0);
	signal	iScratchDataOut		: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
	
	-- ******* --
	-- CONTROL --
	-- ******* --
	-- Banc
	signal	iBancWriteOP		,
			iBancWrite			: std_ulogic;
	-- Scratch
	signal	iScratchWrite		: std_ulogic;
	signal	iFetch				: std_ulogic;
	signal	iInput				: std_ulogic;
	signal	iOuput				: std_ulogic;
	
	-- Alu
	signal	iOperationSelect	: std_ulogic_vector(2 downto 0);
	signal	iOperandSelect		: std_ulogic;
	
	signal	iArithOper			: std_ulogic_vector(1 downto 0);
	signal	iLogicOper			: std_ulogic_vector(1 downto 0);
	signal	iShiftBit			: std_ulogic_vector(2 downto 0);
	signal	iShiftSens			: std_ulogic				   ;
	-- Flags
	signal	iFlagsWrite			,
			iFlagsPush			,
			iFlagsPop			: std_ulogic;
	
	-- Flow
	signal	iConditionCtrl		: std_ulogic_vector(2 downto 0);
	signal	iJump				,
			iCall				,
			iReturn				,
			iReturnI			: std_ulogic;
	signal	iPcEnable			: std_ulogic;

	-- Int		
	signal	iIEvent				: std_ulogic; -- Interrupt Event Flags
	signal	iIEWrite			,
			iIEValue			: std_ulogic;

	-- System
	signal	iFreeze				: std_ulogic; -- Freeze the processor

	--------------------------------------------------------------------------------
	-- WISHBONE
	--------------------------------------------------------------------------------
	-- Signaux Wishbone Interface
--	signal	iwbRST_I   			: std_ulogic;
--	signal	iwbCLK_I   			: std_ulogic;

	signal	iwbADR_O			: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
	signal	iwbDAT_I			,
			iwbDAT				: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
	signal	iwbDAT_O			: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
	signal	iwbWE_O    			: std_ulogic;
	signal	iwbSEL_O			: std_ulogic_vector(1 downto 0);

	signal	iwbSTB_O   			: std_ulogic;
	signal	iwbACK_I   			: std_ulogic;
	signal	iwbCYC   			: std_ulogic;

	-- Signaux de management du Wishbone
	signal	iWbWrSing			: std_ulogic;	-- "Single Write Cycle" Wishbone instruction
	signal	iWbRdSing			: std_ulogic;	-- "Single Read Cycle" Wishbone instruction

	--signal	iWB_inst		: std_ulogic;	-- WB Instruction
	signal	iWB_validHandshake	: std_ulogic;	-- WB valid Handshake
	signal	iWB_validPC			: std_ulogic;	-- WB valid PC increment
	signal	iWB_validOperand	: std_ulogic;	-- WB valid Operation

--	-- Machine d'état
--	type wbStates_TYPE is
--	(
--		S_WB_RESET	,
--		
--		S_WB_RD		,
--		S_WB_RD_ACK	,
--		
--		S_WB_WR		,
--		S_WB_WR_ACK
--	);
--	signal	iWbFSM				: wbStates_TYPE;

	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------
	component cp_Toggle
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
	end component;

	component cp_Interrupt
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
	end component;
	
	component cp_ProgramFlowControl
		generic
		(
			GEN_WIDTH_PC		: positive := 8;
			GEN_INT_VECTOR		: std_ulogic_vector(11 downto 0) := x"0F0";
			GEN_DEPTH_STACK		: positive := 15
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
	end component;
	
	component cp_Alu
		generic
		(
			GEN_WIDTH_DATA		: positive := 8
		);
		port (
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			OperationSelect_i	: in std_ulogic_vector(2 downto 0);
			
			LogicOper_i			: in std_ulogic_vector(1 downto 0);
			ArithOper_i			: in std_ulogic_vector(1 downto 0);

			OperandSelect_i		: in std_ulogic;
		
			CY_i				: in std_ulogic;
			sX_i				: in std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
			sY_i				: in std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
			kk_i				: in std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
			
			ShiftBit_i			: in std_ulogic_vector( 2 downto 0 );
			ShiftSens_i			: in std_ulogic;
			
			Result_o			: out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
			C_o					: out std_ulogic;
			Z_o					: out std_ulogic
		);
	end component;
	
	component cp_Flags
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
	end component;
	
	component cp_BancRegister
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
	end component;

	component cp_ScratchPad
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
	end component;

	component cp_DecodeControl
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
	end component;

begin
	U_Toggle : cp_Toggle
		port map(
		--------------------------------------------------------------------------------
		-- Signaux Systeme
		--------------------------------------------------------------------------------
			Clk_i				=> Clk_i,
			Rst_i_n				=> Rst_i_n,
	
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			Freeze_i			=> iFreeze ,

			Phase1_o			=> iPhase1 ,
			Phase2_o			=> iPhase2
		);

	U_Interrupt : cp_Interrupt
		port map(
		--------------------------------------------------------------------------------
		-- Signaux Systeme
		--------------------------------------------------------------------------------
			Clk_i				=> Clk_i,
			Rst_i_n				=> Rst_i_n,
	
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			IEWrite_i			=> iIEWrite,
			IEValue_i			=> iIEValue,
			
			--Phase1_i			=> iPhase1,
			Phase2_i			=> iPhase2,
	
			Interrupt_i			=> Interrupt_i,
			IEvent_o			=> iIEvent
		);

	U_ProgramFlowControl : cp_ProgramFlowControl
		generic map
		(
			GEN_WIDTH_PC		=> GEN_WIDTH_PC,
			GEN_INT_VECTOR		=> GEN_INT_VECTOR,
			GEN_DEPTH_STACK		=> GEN_DEPTH_STACK
		)
		port map(
		--------------------------------------------------------------------------------
		-- Signaux Systeme
		--------------------------------------------------------------------------------
			Clk_i				=> Clk_i,
			Rst_i_n				=> Rst_i_n,
	
			Enable_i			=> iPcEnable, --iPhase1,
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			aaa_i				=> iaaa,
			
			Interrupt_i			=> iIEvent,--'0', -- '0' when substitue the IEvent by a "Call ISR" instruction
			
			Jump_i				=> iJump,
			Call_i				=> iCall,
			Return_i			=> iReturn,
			ReturnI_i			=> iReturnI,
			
			ConditionCtrl_i		=> iConditionCtrl,
			FlagC_i				=> iC,
			FlagZ_i				=> iZ,
			
			PC_o				=> Address_o
		);

	U_ALU : cp_Alu
		generic map
		(
			GEN_WIDTH_DATA		=> GEN_WIDTH_DATA
		)
		port map(
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			OperationSelect_i	=> iOperationSelect,
			
			LogicOper_i			=> iLogicOper,
			ArithOper_i			=> iArithOper,

			OperandSelect_i		=> iOperandSelect,
		
			CY_i				=> iC,
			sX_i				=> iSxData,
			sY_i				=> iSyData,
			kk_i				=> ikk,
			
			ShiftBit_i			=> iShiftBit,
			ShiftSens_i			=> iShiftSens,
			
			Result_o			=> iAluResult,
			C_o					=> iCi,
			Z_o					=> iZi
		);

	U_Flags : cp_Flags
		port map(
		--------------------------------------------------------------------------------
		-- Signaux Systeme
		--------------------------------------------------------------------------------
			Clk_i				=> Clk_i,
			Rst_i_n				=> Rst_i_n,
	
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			Z_i					=> iZi,
			C_i					=> iCi,
			
			Z_o					=> iZ,
			C_o					=> iC,
			
			Push_i				=> iFlagsPush,
			Pop_i				=> iFlagsPop,
			
			Write_i				=> iFlagsWrite
		);

	U_BancRegister : cp_BancRegister
		generic map
		(
			GEN_WIDTH_DATA		=> GEN_WIDTH_DATA,
			GEN_DEPTH_BANC		=> GEN_DEPTH_BANC
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
			SxPtr_i				=> iSxPtr,
			SyPtr_i				=> iSyPtr,
			
			Write_i				=> iBancWrite,
			SxData_i			=> iSxDataIn,
			
			SxData_o			=> iSxData,
			SyData_o			=> iSyData
		);

	U_ScratchPad : cp_ScratchPad
		generic map
		(
			GEN_WIDTH_DATA		=> GEN_WIDTH_DATA,
			GEN_DEPTH_SCRATCH	=> GEN_DEPTH_SCRATCH
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
			Ptr_i				=> iScratchPtr,
			
			Write_i				=> iScratchWrite,
			Data_i				=> iSxData,
			
			Data_o				=> iScratchDataOut
		);
		
	U_DecodeControl : cp_DecodeControl
		generic map
		(
			GEN_WIDTH_INST		=> GEN_WIDTH_INST,
			GEN_WIDTH_PC		=> GEN_WIDTH_PC,

			GEN_DEPTH_BANC		=> GEN_DEPTH_BANC,
			GEN_DEPTH_SCRATCH	=> GEN_DEPTH_SCRATCH
		)
		port map(
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			--Phase1_i			: in std_ulogic;
			Phase2_i			=> iPhase2,
			
			IEvent_i			=> iIEvent,
			
			Instruction_i		=> Instruction_i,
	
			Fetch_o				=> iFetch,
			Input_o				=> iInput,
			Ouput_o				=> iOuput,
			Jump_o				=> iJump,
			Call_o				=> iCall,
			Return_o			=> iReturn,
			ReturnI_o			=> iReturnI,
			IEWrite_o			=> iIEWrite,
			BancWrite_o			=> iBancWriteOP,
			ScratchWrite_o		=> iScratchWrite,
			OperationSelect_o	=> iOperationSelect,
			FlagsWrite_o		=> iFlagsWrite,
			FlagsPush_o			=> iFlagsPush,
			FlagsPop_o			=> iFlagsPop,

			aaa_o				=> iaaa,
			kk_o				=> ikk,	
			ss_o				=> iss,
			pp_o				=> ipp,
			
			SxPtr_o				=> iSxPtr,
			SyPtr_o				=> iSyPtr,

			OperandSelect_o		=> iOperandSelect,

			ArithOper_o			=> iArithOper,
			LogicOper_o			=> iLogicOper,
			ShiftBit_o			=> iShiftBit,
			ShiftSens_o			=> iShiftSens,
		
			ConditionCtrl_o		=> iConditionCtrl,
		
			IEValue_o			=> iIEValue,
		
			wbRdSing_o			=> iWbRdSing,
			wbWrSing_o			=> iWbWrSing

		);

	-- **** --
	-- PATH --
	-- **** --
	-- Banc --
	iSxDataIn		<=	iScratchDataOut	when ( iFetch = '1' ) else
						IN_PORT_i		when ( iInput = '1' ) else
						iwbDAT			when ( iWbRdSing = '1') else
						iAluResult		;

	iBancWrite		<=	iWB_validOperand			when ( iWbRdSing = '1') else
						iBancWriteOP	;

	-- Scratch --
	iScratchPtr		<=	iSyData(iScratchPtr'range)	when ( iOperandSelect = '1' ) else
						iss;
			

	--------------------------------------------------------------------------------
	-- Outputs
	--------------------------------------------------------------------------------

	-- TODO : Take care when the "iIE" bit is not set. In this case how to manage "Interrupt_Ack_o" !!!
	Interrupt_Ack_o	<=	((iPhase2) and (iIEvent));
	
	OUT_PORT_o		<=	iSxData;
	PORT_ID_o		<=	iSyData						when ( iOperandSelect = '1' ) else
						ipp		;
	READ_STROBE_o	<=	((iPhase2) and (iInput));
	WRITE_STROBE_o	<=	((iPhase2) and (iOuput));
	
	--------------------------------------------------------------------------------
	-- System
	--------------------------------------------------------------------------------
	iFreeze			<=	Freeze_i;
	
	-- Evolution of the PC:
	-- condition : in Phase1 and the processor is not in stall by wishbone
	--iPcEnable		<=	(iPhase1 and not(iwbStall));
	iPcEnable		<=	((iPhase1) and (iWB_validHandshake)) when (iwbCYC='1') else
						(iPhase1);

	--------------------------------------------------------------------------------
	-- WISHBONE
	--------------------------------------------------------------------------------
	-- =================== --
	-- Wishbone Management --
	-- =================== --
	--iWB_inst	<=	iWbRdSing or iWbWrSing;	-- wishbone instruction
	iWB_validHandshake		<=	iwbCYC and iwbACK_I;	-- wishbone VALID ACKNOWLEDGE
	
	-- Valid PC write --
	-- ************** --
	iWB_validPC	<=	((iPhase1) and (iWB_validHandshake));	-- Valid PC incremente
	
	-- Then Valid Operand Read/Write
	-- ************************** --
	wbvOp_Proc : process (Rst_i_n, Clk_i)
	begin
		if ( Rst_i_n = '0' ) then
			iWB_validOperand <=	'0';
			iwbDAT			<= (others => '0');
		elsif ( rising_edge(Clk_i) ) then
			iWB_validOperand <=	iWB_validPC;			-- Valid Operand Read/Write
			if ( iWB_validPC = '1' ) then
				iwbDAT	<= iwbDAT_I;
			end if;
		end if;
	end process wbvOp_Proc;
	
	-- CYCle determination --
	-- ******************* --
	wbCYC_Proc : process (Rst_i_n, Clk_i, iPhase2, iWB_validOperand)
	begin
		-- reset or end of wishbone cycle : after wishbone Operand Validation
		if ( ( Rst_i_n = '0' ) or ((iPhase2='1') and (iWB_validOperand='1')) ) then
			iwbCYC	<= '0';
		-- valid a begining Wishbone Cycle: in Phase1 and wishbone instruction
		elsif ( falling_edge(Clk_i) ) then
			if ( (iPhase1='1') and ((iWbRdSing='1') or (iWbWrSing='1')) ) then
				iwbCYC	<= '1';
			end if;
		end if;
	end process wbCYC_Proc;
	
	-- ============== --
	-- Inputs/Outputs --
	-- ============== --
	--iwbRST_I		<= RST_I;
	--iwbCLK_I		<= CLK_I;

	iwbSTB_O	<=	iwbCYC;
	iwbSEL_O	<=	(others => '0');

	ADR_O		<= iwbADR_O;
	iwbDAT_I	<= DAT_I;
	DAT_O		<= iwbDAT_O;
	WE_O    	<= iwbWE_O  ;
	SEL_O		<= iwbSEL_O;
                
	STB_O   	<= iwbSTB_O ;
	iwbACK_I	<= ACK_I;
	CYC_O   	<= iwbCYC ;

	iwbWE_O		<= iWbWrSing;
	iwbDAT_O	<= iSxData;
	iwbADR_O	<= iSyData		when ( iOperandSelect = '1' ) else
					ikk		;


end rtl;
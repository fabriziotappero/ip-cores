--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_Alu.vhd
--
-- Description:
--	projet copyblaze
--	Arithmetic, Logic, Shift, Rotate
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
-- Entity: cp_Alu
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
entity cp_Alu is
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
end cp_Alu;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_Alu
--------------------------------------------------------------------------------
architecture rtl of cp_Alu is

	--------------------------------------------------------------------------------
	-- Définition des fonctions
	--------------------------------------------------------------------------------
	


	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
		signal		iOperand1		: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		signal		iOperand2		: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		
		signal		iOperand1Arith	: std_ulogic_vector(GEN_WIDTH_DATA downto 0);
		signal		iOperand2Arith	: std_ulogic_vector(GEN_WIDTH_DATA downto 0);

		signal		iShiftResult	: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		signal		iLogicalResult	: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		signal		iArithResult	: std_ulogic_vector(GEN_WIDTH_DATA downto 0);

		signal		iTotalResult	: std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
		
		signal		iShiftBit		: std_ulogic;

		signal		iShiftC			: std_ulogic;
		signal		iLogicC			: std_ulogic;
		signal		iArithC			: std_ulogic;
		signal		iArithCin		: std_ulogic;
		
	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------
	component cp_CLAAdder
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
	end component;

begin

	iOperand1	<=	sX_i;
	iOperand2	<=	sY_i	when ( OperandSelect_i = '1' ) else
					kk_i;
					

	--------------------------------------------------------------------------------
	-- Operation de décalage et rotation
	--------------------------------------------------------------------------------
	with ShiftBit_i select 
		iShiftBit	<=
							('0')						when	"110",
							('1')						when	"111",
							(CY_i)						when	"000",
							iOperand1(GEN_WIDTH_DATA-1)	when	"010",
							iOperand1(0)				when	"100",

							'0'							when	others;
							
	with ShiftSens_i select 
		iShiftResult	<=
							iOperand1(GEN_WIDTH_DATA-2 downto 0) & iShiftBit	when	'0',	--	Left
							iShiftBit & iOperand1(GEN_WIDTH_DATA-1 downto 1)	when	'1',	--	Right
							iOperand1											when	others;
	with ShiftSens_i select
		iShiftC			<=
							iOperand1(GEN_WIDTH_DATA-1)	when	'0',	--	Left
							iOperand1(0)				when	'1',	--	Right
							'0'							when	others;

	--------------------------------------------------------------------------------
	-- Operation Logique
	--------------------------------------------------------------------------------
	with LogicOper_i select 
		iLogicalResult	<=
											iOperand2	when	"00",
							iOperand1	and	iOperand2	when	"01",
							iOperand1	or	iOperand2	when	"10",
							iOperand1	xor	iOperand2	when	"11",
							iOperand1					when	others;

	iLogicC				<=	ODD_Func(iLogicalResult);
	--------------------------------------------------------------------------------
	-- Operation Arithmetique
	--------------------------------------------------------------------------------
	-- Instruction	| #ADD/SUB	| Include CY	| Cin
	--	ADD			| 	0		|	0			|	0
	--	ADDCY		| 	0		|	1			|	CY
	--	SUB			| 	1		|	0			|	1
	--	SUBCY		| 	1		|	1			|	not CY
	with ArithOper_i select 
		iArithCin	<=	
							('0')	when	"00", -- ADD
							(CY_i)	when	"01", -- ADDCY
							('1')	when	"10", -- SUB
						 not(CY_i)	when	"11", -- SUBCY
						
							('0')	when	others;

	iOperand1Arith	<=	'0' & iOperand1;
	-- A SUB B => A ADD (not(B) + 1)
	iOperand2Arith	<=	not('0' & iOperand2)	when (ArithOper_i(1)='1') else ('0' & iOperand2);

	U_Adder : cp_CLAAdder
		generic map
		(
			GEN_WIDTH_DATA		=> GEN_WIDTH_DATA+1
		)
		port map(
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			CarryIn_i			=> iArithCin		,
			sX_i				=> iOperand1Arith	,
			sY_i				=> iOperand2Arith	,
	
			CarryOut_o			=> open				,
			Result_o			=> iArithResult
		);
		
	iArithC			<=	iArithResult(GEN_WIDTH_DATA);
	
	--------------------------------------------------------------------------------
	-- Choix de l'operation
	--------------------------------------------------------------------------------
	with OperationSelect_i select 
		iTotalResult	<=
							iShiftResult						when	"000",
							iLogicalResult						when	"001",
							iArithResult(iTotalResult'range)	when	"010",
							iOperand2							when	"011",
												
							iOperand1							when	others;

	--------------------------------------------------------------------------------
	-- Resultats et Flags
	--------------------------------------------------------------------------------
	Result_o	<=	iTotalResult;
	Z_o			<=	not ( OR_Func( iTotalResult ) );
	
	with OperationSelect_i select
		C_o		<=
					iShiftC					when	"000",	-- (Shift/Rotate)		: 
					iLogicC					when	"001",	-- (Test)				: Odd parity
					iArithC					when	others; -- (Add/Sub/Compare)	: Carry, Borrow

end rtl;


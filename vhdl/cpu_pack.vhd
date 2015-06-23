--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package cpu_pack is
  
	type cycle is (	M1, M2, M3, M4, M5 );

	type op_category is (
		INTR,
		HALT_WAIT,

		-- 0X
		HALT,
		NOP,
		JMP_i,
		JMP_RRNZ_i,
		JMP_RRZ_i,
		CALL_i,
		CALL_RR,
		RET,
		MOVE_SPi_RR,
		MOVE_SPi_RS,
		MOVE_SPi_RU,
		MOVE_SPi_LL,
		MOVE_SPi_LS,
		MOVE_SPi_LU,
		MOVE_RR_dSP,
		MOVE_R_dSP,

		-- 1X
		AND_RR_i,
		OR_RR_i,
		XOR_RR_i,
		SEQ_RR_i,
		SNE_RR_i,
		SGE_RR_i,
		SGT_RR_i,
		SLE_RR_i,

		-- 2X
		SLT_RR_i,
		SHS_RR_i,
		SHI_RR_i,
		SLS_RR_i,
		SLO_RR_i,
		CLRW_dSP,
		CLRB_dSP,
		IN_ci_RU,
		OUT_R_ci,

		-- 3X
		AND_LL_RR,
		OR_LL_RR,
		XOR_LL_RR,
		SEQ_LL_RR,
		SNE_LL_RR,
		SGE_LL_RR,
		SGT_LL_RR,
		SLE_LL_RR,
		SLT_LL_RR,
		SHS_LL_RR,
		SHI_LL_RR,
		SLS_LL_RR,
		SLO_LL_RR,
		LNOT_RR,
		NEG_RR,
		NOT_RR,

		-- 4X
		MOVE_LL_RR,
		MOVE_LL_cRR,
		MOVE_L_cRR,
		MOVE_RR_LL,
		MOVE_RR_cLL,
		MOVE_R_cLL,
		MOVE_cRR_RR,
		MOVE_cRR_RS,
		MOVE_cRR_RU,
		MOVE_ci_RR,
		MOVE_ci_RS,
		MOVE_ci_RU,
		MOVE_ci_LL,
		MOVE_ci_LS,
		MOVE_ci_LU,
		MOVE_RR_SP,

		-- 5X
		LSL_RR_i,
		ASR_RR_i,
		LSR_RR_i,
		LSL_LL_RR,
		ASR_LL_RR,
		LSR_LL_RR,
		ADD_LL_RR,
		SUB_LL_RR,
		MOVE_RR_ci,
		MOVE_R_ci,
		MOVE_RR_uSP,
		MOVE_R_uSP,

		-- 6X
		MOVE_uSP_RR,
		MOVE_uSP_RS,
		MOVE_uSP_RU,
		MOVE_uSP_LL,
		MOVE_uSP_LS,
		MOVE_uSP_LU,
		LEA_uSP_RR,
		MOVE_dRR_dLL,
		MOVE_RRi_LLi,

		-- 7X
		MUL_IS,
		MUL_IU,
		DIV_IS,
		DIV_IU,
		MD_STEP,
		MD_FIN,
		MOD_FIN,
		EI,
		RETI,
		DI,

		-- 9X ... FX
		ADD_RR_I,
		SUB_RR_I,
		MOVE_I_RR,
		ADD_SP_I,
		SEQ_LL_I,
		MOVE_I_LL,
		
		undef );

	type SP_OP is ( SP_NOP, SP_INC, SP_LOAD );

	-- ALU codes
	--
	constant ALU_X_HS_Y   : std_logic_vector(4 downto 0) := "00000";
	constant ALU_X_LO_Y   : std_logic_vector(4 downto 0) := "00001";
	constant ALU_X_HI_Y   : std_logic_vector(4 downto 0) := "00010";
	constant ALU_X_LS_Y   : std_logic_vector(4 downto 0) := "00011";
	constant ALU_X_GE_Y   : std_logic_vector(4 downto 0) := "00100";
	constant ALU_X_LT_Y   : std_logic_vector(4 downto 0) := "00101";
	constant ALU_X_GT_Y   : std_logic_vector(4 downto 0) := "00110";
	constant ALU_X_LE_Y   : std_logic_vector(4 downto 0) := "00111";
	constant ALU_X_EQ_Y   : std_logic_vector(4 downto 0) := "01000";
	constant ALU_X_NE_Y   : std_logic_vector(4 downto 0) := "01001";

	constant ALU_NEG_Y    : std_logic_vector(4 downto 0) := "01100";
	constant ALU_X_SUB_Y  : std_logic_vector(4 downto 0) := "01101";
	constant ALU_MOVE_Y   : std_logic_vector(4 downto 0) := "01110";
	constant ALU_X_ADD_Y  : std_logic_vector(4 downto 0) := "01111";

	constant ALU_X_AND_Y  : std_logic_vector(4 downto 0) := "10000";
	constant ALU_X_OR_Y   : std_logic_vector(4 downto 0) := "10001";
	constant ALU_X_XOR_Y  : std_logic_vector(4 downto 0) := "10010";
	constant ALU_NOT_Y    : std_logic_vector(4 downto 0) := "10011";

	constant ALU_X_LSR_Y  : std_logic_vector(4 downto 0) := "10100";
	constant ALU_X_ASR_Y  : std_logic_vector(4 downto 0) := "10101";
	constant ALU_X_LSL_Y  : std_logic_vector(4 downto 0) := "10110";
	constant ALU_X_MIX_Y  : std_logic_vector(4 downto 0) := "10111";

	constant ALU_MUL_IU  : std_logic_vector(4 downto 0) := "11000";
	constant ALU_MUL_IS  : std_logic_vector(4 downto 0) := "11001";
	constant ALU_DIV_IU  : std_logic_vector(4 downto 0) := "11010";
	constant ALU_DIV_IS  : std_logic_vector(4 downto 0) := "11011";

	constant ALU_MD_STP  : std_logic_vector(4 downto 0) := "11100";
	constant ALU_MD_FIN  : std_logic_vector(4 downto 0) := "11101";
	constant ALU_MOD_FIN : std_logic_vector(4 downto 0) := "11110";

	constant ALU_ANY     : std_logic_vector(4 downto 0) := ALU_X_AND_Y;
--------------------------------------------------------------
	constant SA_43_0    : std_logic_vector(1 downto 0) := "00";
	constant SA_43_FFFF : std_logic_vector(1 downto 0) := "01";	-- last bit 1 !!!
	constant SA_43_I16  : std_logic_vector(1 downto 0) := "10";
	constant SA_43_I8S  : std_logic_vector(1 downto 0) := "11";

	constant SA_21_0    : std_logic_vector(1 downto 0) := "00";
	constant SA_21_LL   : std_logic_vector(1 downto 0) := "01";
	constant SA_21_RR   : std_logic_vector(1 downto 0) := "10";
	constant SA_21_SP   : std_logic_vector(1 downto 0) := "11";

	constant ADR_cSP_L  : std_logic_vector(4 downto 0) := SA_43_0    & SA_21_SP & '0';
	constant ADR_cRR_L  : std_logic_vector(4 downto 0) := SA_43_0    & SA_21_RR & '0';
	constant ADR_cLL_L  : std_logic_vector(4 downto 0) := SA_43_0    & SA_21_LL & '0';
	constant ADR_cI16_L : std_logic_vector(4 downto 0) := SA_43_I16  & SA_21_0  & '0';
	constant ADR_16SP_L : std_logic_vector(4 downto 0) := SA_43_I16  & SA_21_SP & '0';
	constant ADR_8SP_L  : std_logic_vector(4 downto 0) := SA_43_I8S  & SA_21_SP & '0';
	constant ADR_IO     : std_logic_vector(4 downto 0) := SA_43_I8S  & SA_21_0  & '0';

	constant ADR_cSP_H  : std_logic_vector(4 downto 0) := SA_43_0    & SA_21_SP & '1';
	constant ADR_cRR_H  : std_logic_vector(4 downto 0) := SA_43_0    & SA_21_RR & '1';
	constant ADR_cLL_H  : std_logic_vector(4 downto 0) := SA_43_0    & SA_21_LL & '1';
	constant ADR_cI16_H : std_logic_vector(4 downto 0) := SA_43_I16  & SA_21_0  & '1';
	constant ADR_16SP_H : std_logic_vector(4 downto 0) := SA_43_I16  & SA_21_SP & '1';
	constant ADR_8SP_H  : std_logic_vector(4 downto 0) := SA_43_I8S  & SA_21_SP & '1';

	constant ADR_dSP    : std_logic_vector(4 downto 0) := SA_43_FFFF & SA_21_SP & '0';
	constant ADR_dRR    : std_logic_vector(4 downto 0) := SA_43_FFFF & SA_21_RR & '0';
	constant ADR_dLL    : std_logic_vector(4 downto 0) := SA_43_FFFF & SA_21_LL & '0';
	constant ADR_SPi    : std_logic_vector(4 downto 0) := SA_43_FFFF & SA_21_SP & '1';
	constant ADR_RRi    : std_logic_vector(4 downto 0) := ADR_cRR_L;
	constant ADR_LLi    : std_logic_vector(4 downto 0) := ADR_cLL_L;
--------------------------------------------------------------
	constant SX_LL   : std_logic_vector(1 downto 0) := "00";
	constant SX_RR   : std_logic_vector(1 downto 0) := "01";
	constant SX_SP   : std_logic_vector(1 downto 0) := "10";
	constant SX_PC   : std_logic_vector(1 downto 0) := "11";
	constant SX_ANY  : std_logic_vector(1 downto 0) := SX_RR;
--------------------------------------------------------------
	constant SY_SY0  : std_logic_vector(3 downto 0) := "0000";
	constant SY_SY1  : std_logic_vector(3 downto 0) := "0001";
	constant SY_SY2  : std_logic_vector(3 downto 0) := "0010";
	constant SY_SY3  : std_logic_vector(3 downto 0) := "0011";
	constant SY_I16  : std_logic_vector(3 downto 0) := "0100";
	constant SY_RR   : std_logic_vector(3 downto 0) := "0101";

	constant SY_SI8  : std_logic_vector(3 downto 0) := "1000";
	constant SY_UI8  : std_logic_vector(3 downto 0) := "1001";
	constant SY_SQ   : std_logic_vector(3 downto 0) := "1010";
	constant SY_UQ   : std_logic_vector(3 downto 0) := "1011";
	constant SY_SM   : std_logic_vector(3 downto 0) := "1100";
	constant SY_UM   : std_logic_vector(3 downto 0) := "1101";
	constant SY_ANY  : std_logic_vector(3 downto 0) := SY_RR;
--------------------------------------------------------------
	constant PC_NEXT : std_logic_vector(2 downto 0) := "000";	-- count up
	constant PC_JMP  : std_logic_vector(2 downto 0) := "001";	-- JMP/CALL
	constant PC_RETH : std_logic_vector(2 downto 0) := "010";	-- RET (H)
	constant PC_RETL : std_logic_vector(2 downto 0) := "011";	-- RET (L)
	constant PC_WAIT : std_logic_vector(2 downto 0) := "100";	-- WAIT
	constant PC_JPRR : std_logic_vector(2 downto 0) := "101";	-- JMP (RR)
	constant PC_INT  : std_logic_vector(2 downto 0) := "110";	-- INT
--------------------------------------------------------------

end cpu_pack;

package body cpu_pack is
 
end cpu_pack;

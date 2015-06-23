//
// $Id: constants.h,v 1.2 2006-02-09 15:39:38 igorloi Exp $
//
#ifndef _CONSTANTS_H
#define _CONSTANTS_H
// #include "config.h"
#include <stdio.h>

//#ifndef _DEBUG_
//#define _DEBUG_    
//#endif

#ifdef _DEBUG_
#define PRINT(aa) cout << "MIPS:  "  << aa
#define PRINTLN(aa) cout << "MIPS:  "  << aa << endl
#define PRINT2(aa,bb) cout << "MIPS:  "  << aa << bb
#define PRINT2LN(aa,bb) cout << "MIPS:  "  << aa << bb << endl
#define PRINT3(aa,bb,cc) cout << "MIPS:  "  << aa << bb << cc
#define PRINT3LN(aa,bb,cc) cout << "MIPS:  "  << aa << bb << cc <<endl
#else
#define PRINT(aa)
#define PRINTLN(aa)
#define PRINT2(aa,bb)
#define PRINT2LN(aa,bb)
#define PRINT3(aa,bb,cc)
#define PRINT3LN(aa,bb,cc)
#endif

#define SC_LOGIC_0 (sc_logic) 0
#define SC_LOGIC_1 (sc_logic) 1
 

#define BIT_ZERO      '0'
#define BIT_ONE       '1'
#define BIT_X         'X'
#define BIT_Z         'Z'

#define BYTE_ZERO      "00000000"
#define BYTE_ONE       "11111111"
#define BYTE_X         "XXXXXXXX"
#define BYTE_Z         "ZZZZZZZZ"
    
#define HALFWORD_ZERO  "0000000000000000"
#define HALFWORD_ONE   "1111111111111111"
#define HALFWORD_X     "XXXXXXXXXXXXXXXX"
#define HALFWORD_Z     "ZZZZZZZZZZZZZZZZ"
    
#define WORD_ZERO      "00000000000000000000000000000000"
#define WORD_ONE       "11111111111111111111111111111111"
#define WORD_X         "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
#define WORD_Z         "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
#define DOUBLE_ZERO    "0000000000000000000000000000000000000000000000000000000000000000"

#define WORD_CON_ONE       "00000000000000000000000000000001"
#define WORD_CON_TWO       "00000000000000000000000000000010"
#define WORD_CON_THREE     "00000000000000000000000000000011"
#define WORD_CON_FOUR      "00000000000000000000000000000100"
#define WORD_CON_FIVE      "00000000000000000000000000000101"
#define WORD_CON_10000     "00000000000000000010011100010000"

#define OP_RFORMAT "000000"
#define OP_BRANCH  "000001"
#define BRANCH_BLTZ    "00"
#define BRANCH_BGEZ    "01"
#define BRANCH_BLTZAL  "10"
#define BRANCH_BGEZAL  "11"
#define OP_J       "000010"
#define OP_JAL     "000011"
#define OP_BEQ     "000100"
#define OP_BNE     "000101"
#define OP_BLEZ    "000110"
#define OP_BGTZ    "000111"
#define OP_ADDI    "001000"
#define OP_ADDIU   "001001"
#define OP_SLTI    "001010"
#define OP_SLTIU   "001011"
#define OP_ANDI    "001100"
#define OP_ORI     "001101"
#define OP_XORI    "001110"
#define OP_LUI     "001111"

#define OP_COPROC0 "010000"
#define OP_COPROC1 "010001"
#define OP_COPROC2 "010010"

#define OP_LB      "100000"
#define OP_LH      "100001"
#define OP_LWL     "100010"
#define OP_LW      "100011"
#define OP_LBU     "100100"
#define OP_LHU     "100101"
#define OP_LWR     "100110"
#define OP_SB      "101000"
#define OP_SH      "101001"
#define OP_SWL     "101010"
#define OP_SW      "101011"
#define OP_SWR     "101110"
#define OP_CACHE   "101111"
#define OP_COSW0   "110000"
#define OP_COSW1   "110001"
#define OP_COSW2   "110010"

#define FUNC_SLL     "000000"
#define FUNC_SRL     "000010"
#define FUNC_SRA     "000011"
#define FUNC_SLLV    "000100"
#define FUNC_SRLV    "000110"
#define FUNC_SRAV    "000111"
#define FUNC_JR      "001000"
#define FUNC_JALR    "001001"
#define FUNC_SYSCALL "001100"
#define FUNC_BREAK   "001101"
#define FUNC_MFHI    "010000"
#define FUNC_MTHI    "010001"
#define FUNC_MFLO    "010010"
#define FUNC_MTLN    "010011"
#define FUNC_MULT    "011000"
#define FUNC_MULTU   "011001"
#define FUNC_DIV     "011010"
#define FUNC_DIVU    "011011"
#define FUNC_ADD     "100000"
#define FUNC_ADDU    "100001"
#define FUNC_SUB     "100010"
#define FUNC_SUBU    "100011"
#define FUNC_AND     "100100"
#define FUNC_OR      "100101"
#define FUNC_XOR     "100110"
#define FUNC_NOR     "100111"
#define FUNC_SLT     "101010"
#define FUNC_SLTU    "101011"

#define FUNC_    

/*!
  Cp0 function code
  Note - thei
*/
#define FUNC_TLBR    "000001"
#define FUNC_TLBWI   "000010"
#define FUNC_TLBWR   "000110"
#define FUNC_TLBP    "001000"
#define FUNC_ERET    "011000"
#define FUNC_DERET   "011111"
#define FUNC_WAIT    "100000"


#define RS_MFC0 "00000"
#define RS_MTC0 "00100"


#define CP0_NOTHING "0000"
#define CP0_SYSCALL "0001"
#define CP0_BREAK   "0010"
#define CP0_CACHE   "0011"
#define CP0_ERET    "0100"
#define CP0_MFC0    "0101"
#define CP0_MTC0    "0110"
#define CP0_TLBP    "0111"
#define CP0_TLBWR   "1000"
#define CP0_TLBWI   "1001"
#define CP0_TLBR    "1010"
#define CP0_WAIT    "1011"
#define CP0_DERET   "1100"

#define OCP_MCMD_IDLE "000"
#define OCP_MCMD_WR   "001"
#define OCP_MCMD_RD   "010"
#define OCP_MCMD_RDEX "011"
#define OCP_MCMD_BCST "111"

#define OCP_SRESP_NULL "00"
#define OCP_SRESP_DVA  "01"
#define OCP_SRESP_ERR  "11"

#endif

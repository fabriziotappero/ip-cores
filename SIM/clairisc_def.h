`define SIM




`define MUXA_W     0
`define MUXA_BD    1

`define MUXB_EK    0
`define MUXB_REG   1	

`define BRC_NOP    0
`define BRC_ZERO   1
`define BRC_NZERO  2

`define BG_ZERO    1
`define BG_NZERO   2
`define BG_IGN     0
`define BG_NOP     0  

`define PC_NOP     0
`define PC_BRC     1
`define PC_GOTO    2
`define PC_CALL    2
`define PC_INS     2   
`define PC_RET     3   
`define PC_NEXT    4

`define MUXB_IGN     1'BX
`define MUXA_IGN     1'BX

`define R1_LEN	    1
`define R2_LEN		 	2
`define R3_LEN  	 	3
`define R4_LEN      4
`define R5_LEN	    5
`define R8_LEN 		 	8
`define R9_LEN 			9
`define R11_LEN 		11
`define R12_LEN 	 	12

`define ALU_NOP    0
`define ALU_ADD    1
`define ALU_SUB    2
`define ALU_AND    3
`define ALU_OR     4
`define ALU_XOR    5
`define ALU_COM    6
`define ALU_ROR    7
`define ALU_ROL    8
`define ALU_SWAP   9
`define ALU_BSF    10
`define ALU_BCF    11
`define ALU_ZERO   12
`define ALU_DEC    13
`define ALU_INC    14
`define ALU_PB     15
`define ALU_PA     16
`define ALU_BTFSC  17
`define ALU_BTFSS  18

`define STK_PSH        1
`define STK_POP        2
`define STK_NOP        0   

`define EN             1
`define DIS            0

//`define    TTE_MTHD1

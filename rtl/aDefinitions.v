/**********************************************************************************
Theaia, Ray Cast Programable graphic Processing Unit.
Copyright (C) 2009  Diego Valverde (diego.valverde.g@gmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

***********************************************************************************/


/*******************************************************************************
Module Description:

	This module defines constants that are going to be used
	all over the code. By now you have may noticed that all
	constants are pre-compilation define directives. This is
	for simulation perfomance reasons mainly.
*******************************************************************************/

`define MAX_CORES 4 		//The number of cores, make sure you update MAX_CORE_BITS!
`define MAX_CORE_BITS 2 		// 2 ^ MAX_CORE_BITS = MAX_CORES
`define MAX_TMEM_BANKS 4 		//The number of memory banks for TMEM
`define SELECT_ALL_CORES `MAX_CORES'b1111 		//XXX: Change for more cores
//---------------------------------------------------------------------------------
//Verilog provides a `default_nettype none compiler directive.  When
//this directive is set, implicit data types are disabled, which will make any
//undeclared signal name a syntax error.This is very usefull to avoid annoying
//automatic 1 bit long wire declaration where you don't want them to be!
`default_nettype none

//The clock cycle
`define CLOCK_CYCLE  5
`define CLOCK_PERIOD 10
//---------------------------------------------------------------------------------
//Defines the Scale. This very important because it sets the fixed point precision.
//The Scale defines the number bits that are used as the decimal part of the number.
//The code has been written in such a way that allows you to change the value of the
//Scale, so that it is possible to experiment with different scenarios. SCALE can be
//no smaller that 1 and no bigger that WIDTH.
`define SCALE        17

//The next section defines the length of the registers, buses and other structures, 
//do not change this valued unless you really know what you are doing (seriously!)
`define WIDTH        32
`define WB_WIDTH     32  //width of wish-bone buses		
`define LONG_WIDTH   64

`define WB_SIMPLE_READ_CYCLE  0
`define WB_SIMPLE_WRITE_CYCLE 1
//---------------------------------------------------------------------------------
//Next are the constants that define the size of the instructions.
//instructions are formed like this:
// Tupe I:
// Operand         (of size INSTRUCTION_OP_LENGTH )
// DestinationAddr (of size DATA_ADDRESS_WIDTH )
// SourceAddrr1    (of size DATA_ADDRESS_WIDTH )
// SourceAddrr2    (of size DATA_ADDRESS_WIDTH )	
//Type II:
// Operand         (of size INSTRUCTION_OP_LENGTH )
// DestinationAddr (of size DATA_ADDRESS_WIDTH )
// InmeadiateValue (of size WIDTH = DATA_ADDRESS_WIDTH * 2 )
//
//You can play around with the size of instuctions, but keep
//in mind that Bits 3 and 4 of the Operand have a special meaning
//that is used for the jump familiy of instructions (see Documentation).
//Also the MSB of Operand is used by the decoder to distinguish 
//between Type I and Type II instructions.
`define INSTRUCTION_WIDTH       64
`define INSTRUCTION_OP_LENGTH   16
`define INSTRUCTION_IMM_BITPOS  54
`define INSTRUCTION_IMM_BIT     6	//don't change this!

//Defines the Lenght of Memory blocks
`define DATA_ROW_WIDTH        96
`define DATA_ADDRESS_WIDTH    16
`define ROM_ADDRESS_WIDTH     16
`define ROM_ADDRESS_SEL_MASK  `ROM_ADDRESS_WIDTH'h8000

//---------------------------------------------------------------------------------
//The next section defines the code memory entry point for the various code routines
//Please keep this syntax ENTRYPOINT_ADDR_* because the perl script that
//parses the user code expects this pattern in order to read in the tokens

//Internal Entry points (default ROM Address)
`define ENTRYPOINT_ADRR_INITIAL                 `ROM_ADDRESS_WIDTH'd0   //0 - This should always be zero
`define ENTRYPOINT_ADRR_CPPU                    `ROM_ADDRESS_WIDTH'd44   
`define ENTRYPOINT_ADRR_RGU                     `ROM_ADDRESS_WIDTH'd47  
`define ENTRYPOINT_ADRR_AABBIU                  `ROM_ADDRESS_WIDTH'd69  
`define ENTRYPOINT_ADRR_BIU                     `ROM_ADDRESS_WIDTH'd157 
`define ENTRYPOINT_ADRR_PSU                     `ROM_ADDRESS_WIDTH'd232 
`define ENTRYPOINT_ADRR_PSU2                    `ROM_ADDRESS_WIDTH'd248 
`define ENTRYPOINT_ADRR_TCC                     `ROM_ADDRESS_WIDTH'd190 
`define ENTRYPOINT_ADRR_NPG                     `ROM_ADDRESS_WIDTH'd55  
//User Entry points (default ROM Address)
`define ENTRYPOINT_ADRR_USERCONSTANTS           `ROM_ADDRESS_WIDTH'd276
`define ENTRYPOINT_ADRR_PIXELSHADER             `ROM_ADDRESS_WIDTH'd278
`define ENTRYPOINT_ADRR_MAIN                    `ROM_ADDRESS_WIDTH'd37 

//Please keep this syntax ENTRYPOINT_INDEX_* because the perl script that
//parses the user code expects this pattern in order to read in the tokens
//Internal subroutines
`define ENTRYPOINT_INDEX_INITIAL                `ROM_ADDRESS_WIDTH'h8000
`define ENTRYPOINT_INDEX_CPPU                   `ROM_ADDRESS_WIDTH'h8001
`define ENTRYPOINT_INDEX_RGU                    `ROM_ADDRESS_WIDTH'h8002
`define ENTRYPOINT_INDEX_AABBIU                 `ROM_ADDRESS_WIDTH'h8003
`define ENTRYPOINT_INDEX_BIU                    `ROM_ADDRESS_WIDTH'h8004
`define ENTRYPOINT_INDEX_PSU                    `ROM_ADDRESS_WIDTH'h8005
`define ENTRYPOINT_INDEX_PSU2                   `ROM_ADDRESS_WIDTH'h8006
`define ENTRYPOINT_INDEX_TCC                    `ROM_ADDRESS_WIDTH'h8007
`define ENTRYPOINT_INDEX_NPG                    `ROM_ADDRESS_WIDTH'h8008
//User defined subroutines
`define ENTRYPOINT_INDEX_USERCONSTANTS          `ROM_ADDRESS_WIDTH'h8009
`define ENTRYPOINT_INDEX_PIXELSHADER            `ROM_ADDRESS_WIDTH'h800A
`define ENTRYPOINT_INDEX_MAIN                   `ROM_ADDRESS_WIDTH'h800B

`define USER_AABBIU_UCODE_ADDRESS `ROM_ADDRESS_WIDTH'b1000000000000000
//---------------------------------------------------------------------------------
//This handy little macro allows me to print stuff either to STDOUT or a file.
//Notice that the compilation vairable DUMP_CODE must be set if you want to print
//to a file. In XILINX right click 'Simulate Beahvioral Model' -> Properties and
//under 'Specify `define macro name and value' type 'DEBUG=1|DUMP_CODE=1|DEBUG_CORE=<core you want to dump>'
`ifdef DUMP_CODE
	
	`define LOGME  $fwrite(ucode_file,
`else
	`define LOGME  $write(
`endif
//---------------------------------------------------------------------------------	
`define TRUE     32'h1
`define FALSE    32'h0
`define RT_TRUE  48'b1
`define RT_FALSE 48'b0
//---------------------------------------------------------------------------------	

`define GENERAL_PURPOSE_REG_ADDR_MASK  `DATA_ADDRESS_WIDTH'h1F
`define VOID                           `DATA_ADDRESS_WIDTH'd0	//0000
//** Control register bits **//
`define CR_EN_LIGHTS   0
`define CR_EN_TEXTURE  1
`define CR_USER_AABBIU 2
/** Swapping registers **/
//** Configuration Registers **//
`define CREG_LIGHT_INFO                   `DATA_ADDRESS_WIDTH'd0	
`define CREG_CAMERA_POSITION              `DATA_ADDRESS_WIDTH'd1	
`define CREG_PROJECTION_WINDOW_MIN        `DATA_ADDRESS_WIDTH'd2	
`define CREG_PROJECTION_WINDOW_MAX        `DATA_ADDRESS_WIDTH'd3	
`define CREG_RESOLUTION                   `DATA_ADDRESS_WIDTH'd4	
`define CREG_TEXTURE_SIZE                 `DATA_ADDRESS_WIDTH'd5	
`define CREG_PIXEL_2D_INITIAL_POSITION    `DATA_ADDRESS_WIDTH'd6 
`define CREG_PIXEL_2D_FINAL_POSITION      `DATA_ADDRESS_WIDTH'd7 
`define CREG_FIRST_LIGTH                  `DATA_ADDRESS_WIDTH'd8	
`define CREG_FIRST_LIGTH_DIFFUSE          `DATA_ADDRESS_WIDTH'd8	
//OK, so from address 0x06 to 0x0F is where the lights are,watch out values are harcoded
//for now!! (look in ROM.v for hardcoded values!!!)


//Don't change the order of the registers. CREG_V* and CREG_UV* registers
//need to be in that specific order for the triangle fetcher to work 
//correctly!

`define CREG_AABBMIN                   `DATA_ADDRESS_WIDTH'd42
`define CREG_AABBMAX                   `DATA_ADDRESS_WIDTH'd43
`define CREG_V0                        `DATA_ADDRESS_WIDTH'd44	
`define CREG_UV0                       `DATA_ADDRESS_WIDTH'd45	
`define CREG_V1                        `DATA_ADDRESS_WIDTH'd46	
`define CREG_UV1                       `DATA_ADDRESS_WIDTH'd47	
`define CREG_V2                        `DATA_ADDRESS_WIDTH'd48	
`define CREG_UV2                       `DATA_ADDRESS_WIDTH'd49	
`define CREG_TRI_DIFFUSE               `DATA_ADDRESS_WIDTH'd50	
`define CREG_TEX_COLOR1                `DATA_ADDRESS_WIDTH'd53	
`define CREG_TEX_COLOR2                `DATA_ADDRESS_WIDTH'd54	
`define CREG_TEX_COLOR3                `DATA_ADDRESS_WIDTH'd55	
`define CREG_TEX_COLOR4                `DATA_ADDRESS_WIDTH'd56
`define CREG_TEX_COLOR5                `DATA_ADDRESS_WIDTH'd57	
`define CREG_TEX_COLOR6                `DATA_ADDRESS_WIDTH'd58	
`define CREG_TEX_COLOR7                `DATA_ADDRESS_WIDTH'd59	


/** Non-Swapping registers **/
// ** User Registers **//
//General Purpose registers, the user may put what ever he/she
//wants in here...
`define C1     `DATA_ADDRESS_WIDTH'd64 
`define C2     `DATA_ADDRESS_WIDTH'd65 
`define C3     `DATA_ADDRESS_WIDTH'd66 
`define C4     `DATA_ADDRESS_WIDTH'd67 
`define C5     `DATA_ADDRESS_WIDTH'd68 
`define C6     `DATA_ADDRESS_WIDTH'd69 
`define C7     `DATA_ADDRESS_WIDTH'd70 
`define R1		`DATA_ADDRESS_WIDTH'd71 
`define R2		`DATA_ADDRESS_WIDTH'd72 
`define R3		`DATA_ADDRESS_WIDTH'd73 
`define R4		`DATA_ADDRESS_WIDTH'd74
`define R5		`DATA_ADDRESS_WIDTH'd75
`define R6		`DATA_ADDRESS_WIDTH'd76
`define R7		`DATA_ADDRESS_WIDTH'd77
`define R8		`DATA_ADDRESS_WIDTH'd78
`define R9		`DATA_ADDRESS_WIDTH'd79
`define R10		`DATA_ADDRESS_WIDTH'd80
`define R11		`DATA_ADDRESS_WIDTH'd81
`define R12		`DATA_ADDRESS_WIDTH'd82

//** Internal Registers **//
`define CREG_PROJECTION_WINDOW_SCALE   `DATA_ADDRESS_WIDTH'd83
`define CREG_UNORMALIZED_DIRECTION     `DATA_ADDRESS_WIDTH'd84
`define CREG_RAY_DIRECTION             `DATA_ADDRESS_WIDTH'd85	
`define CREG_E1_LAST                   `DATA_ADDRESS_WIDTH'd86
`define CREG_E2_LAST                   `DATA_ADDRESS_WIDTH'd87
`define CREG_T                         `DATA_ADDRESS_WIDTH'd88
`define CREG_P                         `DATA_ADDRESS_WIDTH'd89
`define CREG_Q                         `DATA_ADDRESS_WIDTH'd90
`define CREG_UV0_LAST                  `DATA_ADDRESS_WIDTH'd91
`define CREG_UV1_LAST                  `DATA_ADDRESS_WIDTH'd92
`define CREG_UV2_LAST                  `DATA_ADDRESS_WIDTH'd93
`define CREG_TRI_DIFFUSE_LAST          `DATA_ADDRESS_WIDTH'd94
`define CREG_LAST_t                    `DATA_ADDRESS_WIDTH'd95
`define CREG_LAST_u                    `DATA_ADDRESS_WIDTH'd96
`define CREG_LAST_v                    `DATA_ADDRESS_WIDTH'd97
`define CREG_COLOR_ACC                 `DATA_ADDRESS_WIDTH'd98
`define CREG_t                         `DATA_ADDRESS_WIDTH'd99
`define CREG_E1                        `DATA_ADDRESS_WIDTH'd100
`define CREG_E2                        `DATA_ADDRESS_WIDTH'd101
`define CREG_DELTA                     `DATA_ADDRESS_WIDTH'd102
`define CREG_u                         `DATA_ADDRESS_WIDTH'd103
`define CREG_v                         `DATA_ADDRESS_WIDTH'd104
`define CREG_H1                        `DATA_ADDRESS_WIDTH'd105
`define CREG_H2                        `DATA_ADDRESS_WIDTH'd106
`define CREG_H3                        `DATA_ADDRESS_WIDTH'd107
`define CREG_PIXEL_PITCH               `DATA_ADDRESS_WIDTH'd108

`define CREG_LAST_COL                  `DATA_ADDRESS_WIDTH'd109 //the last valid column, simply CREG_RESOLUTIONX - 1
`define CREG_TEXTURE_COLOR             `DATA_ADDRESS_WIDTH'd110 
`define CREG_PIXEL_2D_POSITION         `DATA_ADDRESS_WIDTH'd111
`define CREG_TEXWEIGHT1                `DATA_ADDRESS_WIDTH'd112	
`define CREG_TEXWEIGHT2                `DATA_ADDRESS_WIDTH'd113	
`define CREG_TEXWEIGHT3                `DATA_ADDRESS_WIDTH'd114	
`define CREG_TEXWEIGHT4                `DATA_ADDRESS_WIDTH'd115
`define CREG_TEX_COORD1                `DATA_ADDRESS_WIDTH'd116	
`define CREG_TEX_COORD2                `DATA_ADDRESS_WIDTH'd117
`define R99                            `DATA_ADDRESS_WIDTH'd118
`define CREG_ZERO                      `DATA_ADDRESS_WIDTH'd119
`define CREG_CURRENT_OUTPUT_PIXEL      `DATA_ADDRESS_WIDTH'd120
`define CREG_3                         `DATA_ADDRESS_WIDTH'd121
`define CREG_012                       `DATA_ADDRESS_WIDTH'd122

//** Ouput registers **//

`define OREG_PIXEL_COLOR               `DATA_ADDRESS_WIDTH'd128
`define OREG_TEX_COORD1                `DATA_ADDRESS_WIDTH'd129	
`define OREG_TEX_COORD2                `DATA_ADDRESS_WIDTH'd130	
`define OREG_ADDR_O                    `DATA_ADDRESS_WIDTH'd131
//-------------------------------------------------------------
//*** Instruction Set ***
//The order of the instructions is important here!. Don't change
//it unless you know what you are doing. For example all the 'SET'
//family of instructions have the MSB bit in 1. This means that
//if you add an instruction and the MSB=1, this instruction will treated
//as type II (see manual) meaning the second 32bit argument is expected to be
//an inmediate value instead of a register address!
//Another example is that in the JUMP family Bits 3 and 4 have a special
//meaning: b4b3 = 01 => X jump type, b4b3 = 10 => Y jump type, finally 
//b4b3 = 11 means Z jump type.
//All this is just to tell you: Don't play with these values!

// *** Type I Instructions (OP DST REG1 REG2) ***
`define NOP    `INSTRUCTION_OP_LENGTH'b0_000000 	//0
`define ADD 	`INSTRUCTION_OP_LENGTH'b0_000001 	//1
`define SUB		`INSTRUCTION_OP_LENGTH'b0_000010 	//2
`define DIV		`INSTRUCTION_OP_LENGTH'b0_000011 	//3
`define MUL 	`INSTRUCTION_OP_LENGTH'b0_000100 	//4
`define MAG		`INSTRUCTION_OP_LENGTH'b0_000101 	//5
`define COPY	`INSTRUCTION_OP_LENGTH'b0_000111 	//7
`define JGX		`INSTRUCTION_OP_LENGTH'b0_001_000  	//8
`define JLX		`INSTRUCTION_OP_LENGTH'b0_001_001	//9
`define JEQX	`INSTRUCTION_OP_LENGTH'b0_001_010 	//10 - A
`define JNEX	`INSTRUCTION_OP_LENGTH'b0_001_011 	//11 - B
`define JGEX	`INSTRUCTION_OP_LENGTH'b0_001_100	//12 - C
`define JLEX	`INSTRUCTION_OP_LENGTH'b0_001_101 	//13 - D
`define INC		`INSTRUCTION_OP_LENGTH'b0_001_110	//14 - E
`define ZERO	`INSTRUCTION_OP_LENGTH'b0_001_111	//15 - F
`define JGY		`INSTRUCTION_OP_LENGTH'b0_010_000  	//16
`define JLY		`INSTRUCTION_OP_LENGTH'b0_010_001 	//17
`define JEQY	`INSTRUCTION_OP_LENGTH'b0_010_010  	//18
`define JNEY	`INSTRUCTION_OP_LENGTH'b0_010_011 	//19
`define JGEY	`INSTRUCTION_OP_LENGTH'b0_010_100 	//20
`define JLEY	`INSTRUCTION_OP_LENGTH'b0_010_101  	//21
`define CROSS	`INSTRUCTION_OP_LENGTH'b0_010_110	//22
`define DOT		`INSTRUCTION_OP_LENGTH'b0_010_111	//23
`define JGZ		`INSTRUCTION_OP_LENGTH'b0_011_000 	//24
`define JLZ		`INSTRUCTION_OP_LENGTH'b0_011_001	//25
`define JEQZ	`INSTRUCTION_OP_LENGTH'b0_011_010 	//26
`define JNEZ	`INSTRUCTION_OP_LENGTH'b0_011_011	//27
`define JGEZ	`INSTRUCTION_OP_LENGTH'b0_011_100	//28
`define JLEZ	`INSTRUCTION_OP_LENGTH'b0_011_101 	//29

//The next instruction is for simulation debug only
//not to be synthetized! Pretty much behaves the same
//as a NOP, only that prints the register value to
//a log file called 'Registers.log'
`ifdef DEBUG
`define DEBUG_PRINT `INSTRUCTION_OP_LENGTH'b0_011_110	//30
`endif

`define MULP     `INSTRUCTION_OP_LENGTH'b0_011_111			//31	R1.z = S1.x * S1.y
`define MOD      `INSTRUCTION_OP_LENGTH'b0_100_000			//32	R = MODULO( S1,S2 )
`define FRAC     `INSTRUCTION_OP_LENGTH'b0_100_001			//33	R =FractionalPart( S1 )
`define INTP     `INSTRUCTION_OP_LENGTH'b0_100_010			//34	R =IntergerPart( S1 )
`define NEG      `INSTRUCTION_OP_LENGTH'b0_100_011			//35	R = -S1
`define DEC      `INSTRUCTION_OP_LENGTH'b0_100_100			//36	R = S1--
`define XCHANGEX `INSTRUCTION_OP_LENGTH'b0_100_101		//		R.x = S2.x, R.y = S1.y, R.z = S1.z
`define XCHANGEY `INSTRUCTION_OP_LENGTH'b0_100_110		//		R.x = S1.x, R.y = S2.y, R.z = S1.z
`define XCHANGEZ `INSTRUCTION_OP_LENGTH'b0_100_111		//		R.x = S1.x, R.y = S1.y, R.z = S2.z
`define IMUL     `INSTRUCTION_OP_LENGTH'b0_101_000		//		R = INTEGER( S1 * S2 )
`define UNSCALE  `INSTRUCTION_OP_LENGTH'b0_101_001		//		R = S1 >> SCALE
`define RESCALE  `INSTRUCTION_OP_LENGTH'b0_101_010		//		R = S1 << SCALE
`define INCX     `INSTRUCTION_OP_LENGTH'b0_101_011	   //    R.X = S1.X + 1
`define INCY     `INSTRUCTION_OP_LENGTH'b0_101_100	   //    R.Y = S1.Y + 1
`define INCZ     `INSTRUCTION_OP_LENGTH'b0_101_101	   //    R.Z = S1.Z + 1
`define OMWRITE  `INSTRUCTION_OP_LENGTH'b0_101_111	   //47    IO write to O memory
`define TMREAD   `INSTRUCTION_OP_LENGTH'b0_110_000	   //48    IO read from T memory
`define LEA      `INSTRUCTION_OP_LENGTH'b0_110_001	   //49    Load effective address

//*** Type II Instructions (OP DST REG1 IMM) ***
`define RETURN          `INSTRUCTION_OP_LENGTH'b1_000000 //64  0x40
`define SETX            `INSTRUCTION_OP_LENGTH'b1_000001 //65  0x41
`define SETY            `INSTRUCTION_OP_LENGTH'b1_000010 //66
`define SETZ            `INSTRUCTION_OP_LENGTH'b1_000011 //67
`define SWIZZLE3D       `INSTRUCTION_OP_LENGTH'b1_000100 //68 
`define JMP             `INSTRUCTION_OP_LENGTH'b1_011000 //56
`define CALL            `INSTRUCTION_OP_LENGTH'b1_011001 //57
`define RET             `INSTRUCTION_OP_LENGTH'b1_011010 //58

//-------------------------------------------------------------

//All the posible values for the SWIZZLE3D instruction are defined next
`define SWIZZLE_XXX		32'd0
`define SWIZZLE_YYY		32'd1
`define SWIZZLE_ZZZ		32'd2
`define SWIZZLE_XYY		32'd3
`define SWIZZLE_XXY		32'd4
`define SWIZZLE_XZZ		32'd5
`define SWIZZLE_XXZ		32'd6
`define SWIZZLE_YXX		32'd7
`define SWIZZLE_YYX		32'd8
`define SWIZZLE_YZZ		32'd9
`define SWIZZLE_YYZ		32'd10
`define SWIZZLE_ZXX		32'd11
`define SWIZZLE_ZZX		32'd12
`define SWIZZLE_ZYY		32'd13
`define SWIZZLE_ZZY		32'd14
`define SWIZZLE_XZX		32'd15
`define SWIZZLE_XYX		32'd16
`define SWIZZLE_YXY		32'd17
`define SWIZZLE_YZY		32'd18
`define SWIZZLE_ZXZ		32'd19
`define SWIZZLE_ZYZ		32'd20
`define SWIZZLE_YXZ		32'd21




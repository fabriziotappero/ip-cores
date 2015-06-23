
/*
 *  Copyright © 2003..2008 : Henk van Kampen <henk@mediatronix.com>
 *
 *	This file is part of pBlazASM.
 *
 *  pBlazASM is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  pBlazASM is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with pBlazASM.  If not, see <http://www.gnu.org/licenses/>.
 */

typedef unsigned char bool ;
#define true (1)
#define false (0)

// token types
typedef enum {
	tNONE = 0,
	tERROR,
	tLPAREN,
	tRPAREN,
	tCOMMA,
	tCOLON,
	tOPERATOR,
	tREGISTER,
	tOPERAND,
	tOPCODE,
	tCONDITION,
	tIDENT,
	tLABEL,
	tDIRECTIVE,
	tINDEX,
	tVALUE,
	tCHAR,
	tSTRING,
	tHEX,
	tBIN,
	tDEC
} type_e ;

// token subtypes
typedef enum {
	stNONE = 0,
	stCOMMENT,

	// instruction types
	stMOVE,
	stINT,
	stINTI,
	stINTE,
	stCJMP,
	stCSKP,
	stCRET,
	stIO,
	stSHIFT,
 	stINST,

	// operators
	stADD,
	stSUB,
	stAND,
	stIOR,
	stXOR,
	stSHL,
	stSHR,
	stMUL,
	stDIV,
	stMOD,
	stTILDA,

	// equate types
	stVAL,
	stREG,
	stCLONE,

	// directives
	stORG,
	stPAGE,

	stIOSP,
	stSCRATCHPAD,
	stEND,

	stEQU,
	stBYTE,
	stWORD_BE,
	stWORD_LE,
	stLONG_BE,
	stLONG_LE,
	stTEXT,
	stBUFFER,
	stSFR,

	stDS,
	stDSIN,
	stDSOUT,
	stDSIO,
	stDSROM,
	stDSRAM,

	// KCPSM3
	stADDRESS,
	stCONSTANT,
	stNAMEREG,

	stVHDL,
	stXDL,
	stMEM,
	stCOE,
	stHEX,

	stDOT
} subtype_e ;

// token and symbol type
typedef struct {
	type_e type ;
	subtype_e subtype ;
	char * text ;
	int32_t value ;
} symbol_t ;

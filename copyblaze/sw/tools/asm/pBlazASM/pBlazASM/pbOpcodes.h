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

const symbol_t opcodes[] =
	{
		// preferred mnemonics
		 { tOPCODE, stMOVE,   "ADD",      0x18000 },
		 { tOPCODE, stMOVE,   "ADDC",     0x1A000 },
		 { tOPCODE, stMOVE,   "AND",      0x0A000 },
		 { tOPCODE, stCJMP,   "CALL",     0x30000 },
		 { tOPCODE, stMOVE,   "COMP",     0x14000 },
		 { tOPCODE, stINT,    "DINT",     0x3C000 },
		 { tOPCODE, stINT,    "EINT",     0x3C001 },
		 { tOPCODE, stIO,     "IN",       0x04000 },
		 { tOPCODE, stCJMP,   "JUMP",     0x34000 },
		 { tOPCODE, stIO,     "LD",		  0x06000 },
		 { tOPCODE, stMOVE,   "MOVE",     0x00000 },
		 { tOPCODE, stMOVE,   "OR",       0x0C000 },
		 { tOPCODE, stIO,     "OUT",      0x2C000 },
		 { tOPCODE, stCRET,   "RET",      0x2A000 },
		 { tOPCODE, stINTE,   "RETI",     0x38001 },
		 { tOPCODE, stSHIFT,  "RL",       0x20002 },
		 { tOPCODE, stSHIFT,  "RR",       0x2000C },
		 { tOPCODE, stCSKP,   "SKIP",     0x34000 },
		 { tOPCODE, stSHIFT,  "SL0",      0x20006 },
		 { tOPCODE, stSHIFT,  "SL1",      0x20007 },
		 { tOPCODE, stSHIFT,  "SLA",      0x20000 },
		 { tOPCODE, stSHIFT,  "SLX",      0x20004 },
		 { tOPCODE, stSHIFT,  "SR0",      0x2000E },
		 { tOPCODE, stSHIFT,  "SR1",      0x2000F },
		 { tOPCODE, stSHIFT,  "SRA",      0x20008 },
		 { tOPCODE, stSHIFT,  "SRX",      0x2000A },
		 { tOPCODE, stIO,     "ST",		  0x2E000 },
		 { tOPCODE, stMOVE,   "SUB",      0x1C000 },
		 { tOPCODE, stMOVE,   "SUBC",     0x1E000 },
		 { tOPCODE, stMOVE,   "TEST",     0x12000 },
		 { tOPCODE, stMOVE,   "XOR",      0x0E000 },
		 { tOPCODE, stINST,   "INST",     0x00000 },

		// alternative mnemonics
		 { tOPCODE, stMOVE,   "ADDCY",    0x1A000 },
		 { tOPCODE, stMOVE,   "COMPARE",  0x14000 },
		 { tOPCODE, stINTI,   "DISABLE",  0x3C000 },
		 { tOPCODE, stINTI,   "ENABLE",   0x3C001 },
		 { tOPCODE, stIO,     "FETCH",    0x06000 },
		 { tOPCODE, stIO,     "INPUT",    0x04000 },
		 { tOPCODE, stINTE,   "HALT",     0x3C003 },
		 { tOPCODE, stMOVE,   "LOAD",     0x00000 },
		 { tOPCODE, stIO,     "OUTPUT",   0x2C000 },
		 { tOPCODE, stCRET,   "RETURN",   0x2A000 },
		 { tOPCODE, stINTE,   "RETURNI",  0x38001 },
		 { tOPCODE, stIO,     "STORE",    0x2E000 },
		 { tOPCODE, stMOVE,   "SUBCY",    0x1E000 }
		 
		 ,// Wishbone
		 { tOPCODE, stIO,     "WBRDSING", 0x02000 },
		 { tOPCODE, stIO,     "WBWRSING", 0x08000 }
 } ;

const symbol_t conditions[] =
	{
		 { tCONDITION, stNONE, "Z",       0x01000 },
		 { tCONDITION, stNONE, "C",       0x01800 },
		 { tCONDITION, stNONE, "NZ",      0x01400 },
		 { tCONDITION, stNONE, "NC",      0x01C00 } } ;

const symbol_t indexes[] =
	{
		 { tVALUE, stINT, "SP",        0x000F0 },
		 { tINDEX, stNONE, ".SP",      0x000F4 },
		 { tINDEX, stNONE, ".SP++",    0x000F5 },
		 { tINDEX, stNONE, ".--SP",    0x000F6 },
		 { tINDEX, stNONE, ".-SP+",    0x000F7 },

		 { tVALUE, stINT, "IX",         0x000F8 },
		 { tINDEX, stNONE, ".IX",       0x000FC },
		 { tINDEX, stNONE, ".IX++",     0x000FD },
		 { tINDEX, stNONE, ".--IX",     0x000FE },
		 { tINDEX, stNONE, ".-IX+",     0x000FF }
} ;

const symbol_t registers[] =
	{
		 { tREGISTER, stNONE, "S0", 0 },
		 { tREGISTER, stNONE, "S1", 1 },
		 { tREGISTER, stNONE, "S2", 2 },
		 { tREGISTER, stNONE, "S3", 3 },
		 { tREGISTER, stNONE, "S4", 4 },
		 { tREGISTER, stNONE, "S5", 5 },
		 { tREGISTER, stNONE, "S6", 6 },
		 { tREGISTER, stNONE, "S7", 7 },
		 { tREGISTER, stNONE, "S8", 8 },
		 { tREGISTER, stNONE, "S9", 9 },
		 { tREGISTER, stNONE, "SA", 0xA },
		 { tREGISTER, stNONE, "SB", 0xB },
		 { tREGISTER, stNONE, "SC", 0xC },
		 { tREGISTER, stNONE, "SD", 0xD },
		 { tREGISTER, stNONE, "SE", 0xE },
		 { tREGISTER, stNONE, "SF", 0xF },
		 { tREGISTER, stNONE, "s0", 0 },
		 { tREGISTER, stNONE, "s1", 1 },
		 { tREGISTER, stNONE, "s2", 2 },
		 { tREGISTER, stNONE, "s3", 3 },
		 { tREGISTER, stNONE, "s4", 4 },
		 { tREGISTER, stNONE, "s5", 5 },
		 { tREGISTER, stNONE, "s6", 6 },
		 { tREGISTER, stNONE, "s7", 7 },
		 { tREGISTER, stNONE, "s8", 8 },
		 { tREGISTER, stNONE, "s9", 9 },
		 { tREGISTER, stNONE, "sA", 0xA },
		 { tREGISTER, stNONE, "sB", 0xB },
		 { tREGISTER, stNONE, "sC", 0xC },
		 { tREGISTER, stNONE, "sD", 0xD },
		 { tREGISTER, stNONE, "sE", 0xE },
		 { tREGISTER, stNONE, "sF", 0xF } } ;

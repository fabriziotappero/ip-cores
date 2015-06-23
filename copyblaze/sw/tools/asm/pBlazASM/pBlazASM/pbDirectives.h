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

//!
// List of directive recognized by pBlazASM.
// For compatability, pBlazIDE and KCPSM3 directives
// are recognized and processed
//
const symbol_t directives[] =
	{
	// pBlazASM
			{ tDIRECTIVE, stORG,        ".ORG",     0 },
			{ tDIRECTIVE, stEND,        ".END",     0 },
			{ tDIRECTIVE, stPAGE,       ".PAG",     0 },

			{ tDIRECTIVE, stSCRATCHPAD, ".SCR",     0 },
			{ tDIRECTIVE, stSFR,        ".SFR",     0 },

			{ tDIRECTIVE, stEQU,        ".EQU",     0 },
			{ tDIRECTIVE, stBYTE,       ".BYT",     0 },
			{ tDIRECTIVE, stWORD_BE,    ".WBE",     0 },
			{ tDIRECTIVE, stWORD_LE,    ".WLE",     0 },
			{ tDIRECTIVE, stLONG_BE,    ".LBE",     0 },
			{ tDIRECTIVE, stLONG_LE,    ".LLE",     0 },
			{ tDIRECTIVE, stBUFFER,     ".BUF",     0 },
			{ tDIRECTIVE, stTEXT,       ".TXT",     0 },

		// pBlazIDE
			{ tDIRECTIVE, stORG,        "ORG",      0 },
			{ tDIRECTIVE, stEQU,        "EQU",      0 },
			{ tDIRECTIVE, stDS,         "DS",       0 },
			{ tDIRECTIVE, stDSIN,       "DSIN",     0 },
			{ tDIRECTIVE, stDSOUT,      "DSOUT",    0 },
			{ tDIRECTIVE, stDSIO,       "DSIO",     0 },
			{ tDIRECTIVE, stDSROM,      "DSROM",    0 },
			{ tDIRECTIVE, stDSRAM,      "DSRAM",    0 },

			{ tDIRECTIVE, stVHDL,       "VHDL",     0 },
			{ tDIRECTIVE, stMEM,        "MEM",      0 },
			{ tDIRECTIVE, stCOE,        "COE",      0 },
			{ tDIRECTIVE, stHEX,        "HEX",      0 },

		// KCPSM3
			{ tDIRECTIVE, stADDRESS,    "ADDRESS",  0 },
			{ tDIRECTIVE, stCONSTANT,   "CONSTANT",	0 },
			{ tDIRECTIVE, stNAMEREG,    "NAMEREG",  0 } } ;

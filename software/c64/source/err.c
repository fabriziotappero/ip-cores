// ============================================================================
// (C) 2012 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// C64 - Raptor64 'C' derived language compiler
//  - 64 bit CPU
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
// ============================================================================
//
#include "c.h"

extern int numerrs;
extern int total_errors;
extern int errno[80];

static char *errtextstr[] = {
	"Syntax error",
	"Illegal character",
	"Floating point",
	"Illegal type",
	"Undefined symbol",
	"Duplicate symbol",
	"Bad punctuation",
	"Identifier expected",
	"No initializer",
	"Incomplete statement",
	"Illegal initializer",
	"Illegal class",
	"block",
	"No pointer",
	"No function",
	"No member",
	"LValue required",
	"Dereference",
	"Mismatch",
	"Expression expected",
	"While/Until expected",
	"Missing case statement",
	"Duplicate case statement",
	"Bad label",
	"Preprocessor error",
	"Include file",
	"Can't open",
	"Define",
	"Expecting a catch statement",
	"Bad bitfield width",
	"Expression too complex",
	"Asm statement too long - break into multiple statements",
	"Too many case constants",
	"Attempting to catch a structure - aggregates may not be caught - use a pointer to struct",
	"Semaphore increment / decrement limited to 1 to 15."
	"Semaphore address must be 16 byte aligned."
};

char *errtext(int errnum)
{
	return errtextstr[errnum];
}

/*
 *      error - print error information
 */
void error(int n)
{
	if (numerrs < 80) {
		errno[numerrs++] = n;
		++total_errors;
	}
	else
		exit(1);
}



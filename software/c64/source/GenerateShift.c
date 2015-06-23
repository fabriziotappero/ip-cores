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
#include <stdio.h>
#include "c.h"
#include "expr.h"
#include "Statement.h"
#include "gen.h"
#include "cglbdec.h"


AMODE *GenerateShift(ENODE *node,int flags, int size, int op)
{
	AMODE *ap1, *ap2, *ap3;

    ap1 = GenerateExpression(node->p[0],F_REG,size);
    ap2 = GenerateExpression(node->p[1],F_REG | F_IMMED,8);
	switch(op) {
	case op_shru:
		switch (size) {
			case 8:		GenerateTriadic(op_andi,0,ap1,ap1,make_immed(0xff)); break;
			case 16:	GenerateTriadic(op_andi,0,ap1,ap1,make_immed(0xffff)); break;
			case 32:	GenerateTriadic(op_andi,0,ap1,ap1,make_immed(0xffffffff)); break;
			default:	;
		}
		break;
	case op_shr:
		switch (size) {
			case 8:		GenerateTriadic(op_sext8,0,ap1,ap1,NULL); break;
			case 16:	GenerateTriadic(op_sext16,0,ap1,ap1,NULL); break;
			case 32:	GenerateTriadic(op_sext32,0,ap1,ap1,NULL); break;
			default:	;
		}
		break;
	}
	ap3 = GetTempRegister();
	if (ap2->mode==am_immed) {
		switch(op)
		{
		case op_shl:	op = op_shli; break;
		case op_shr:	op = op_shri; break;
		case op_shru:	op = op_shrui; break;
		}
		GenerateTriadic(op,0,ap3,ap1,make_immed(ap2->offset->i));
	}
	else
		GenerateTriadic(op,0,ap3,ap1,ap2);
    ReleaseTempRegister(ap1);
    ReleaseTempRegister(ap2);
    MakeLegalAmode(ap3,flags,size);
    return ap3;
}


/*
 *      generate shift equals operators.
 */
struct amode *GenerateAssignShift(ENODE *node,int flags,int size,int op)
{
	struct amode    *ap1, *ap2, *ap3;

    ap3 = GenerateExpression(node->p[0],F_ALL,size);
    ap2 = GenerateExpression(node->p[1],F_REG | F_IMMED,size);
	if (ap3->mode != am_reg) {
		ap1 = GetTempRegister();
		GenerateDiadic(op_lw,0,ap1,ap3);
	}
	else
		ap1 = ap3;
	switch(op) {
	case op_shru:
		switch (size) {
			case 8:		GenerateTriadic(op_andi,0,ap1,ap1,make_immed(0xff)); break;
			case 16:	GenerateTriadic(op_andi,0,ap1,ap1,make_immed(0xffff)); break;
			case 32:	GenerateTriadic(op_andi,0,ap1,ap1,make_immed(0xffffffff)); break;
			default:	;
		}
		break;
	case op_shr:
		switch (size) {
			case 8:		GenerateTriadic(op_sext8,0,ap1,ap1,NULL); break;
			case 16:	GenerateTriadic(op_sext16,0,ap1,ap1,NULL); break;
			case 32:	GenerateTriadic(op_sext32,0,ap1,ap1,NULL); break;
			default:	;
		}
		break;
	}
	if (ap2->mode==am_immed)
		GenerateTriadic(op,0,ap1,ap1,make_immed(ap2->offset->i));
	else
		GenerateTriadic(op,0,ap1,ap1,ap2);
	if (ap3->mode != am_reg) {
		GenerateDiadic(op_sw,0,ap1,ap3);
	}
    ReleaseTempRegister(ap2);
    MakeLegalAmode(ap1,flags,size);
    return ap1;
}


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

int tmpregs[] = {3,4,5,6,7,8,9,10};
int regstack[8];
int rsp=7;
int regmask=0;

void initRegStack()
{
	for (rsp=0; rsp < 8; rsp=rsp+1)
		regstack[rsp] = tmpregs[rsp];
	rsp = 0;
}

void GenerateTempRegPush(int reg, int rmode)
{
	AMODE *ap1;
    ap1 = allocAmode();
    ap1->preg = reg;
    ap1->mode = rmode;
	GenerateTriadic(op_subui,0,makereg(30),makereg(30),make_immed(8));
	GenerateTriadic(op_sw,0,ap1,make_indirect(30),NULL);
}

void GenerateTempRegPop(int reg, int rmode)
{
	AMODE *ap1;
    ap1 = allocAmode();
    ap1->preg = reg;
    ap1->mode = rmode;
	GenerateTriadic(op_lw,0,ap1,make_indirect(30),NULL);
	GenerateTriadic(op_addui,0,makereg(30),makereg(30),make_immed(8));
}

void initstack()
{
	initRegStack();
}

AMODE *GetTempRegister()
{
	AMODE *ap;
    ap = allocAmode();
    ap->mode = am_reg;
    ap->preg = PopFromRstk();
    ap->deep = rsp;
    return ap;
}

int PopFromRstk()
{
	int reg = 0;

	if (rsp < 8) {
		reg = regstack[rsp];
		rsp = rsp + 1;
		regmask |= (1 << (reg));
	}
	else
		error(ERR_EXPRTOOCOMPLEX);
	return reg;
}

void PushOnRstk(int reg)
{
	if (rsp > 0) {
		rsp = rsp - 1;
		regstack[rsp] = reg;
		regmask &= ~(1 << (reg));
	}
	else
		printf("DIAG - register stack underflow.\r\n");
}

//int SaveTempRegs()
//{
//	if (popcnt(regmask)==1) {
//		GenerateTriadic(op_subui,0,makereg(30),makereg(30),make_immed(8));
//		GenerateTriadic(op_sw,0,make_mask(regmask),make_indirect(30),NULL);
//	}
//	else if (regmask != 0) {
//		GenerateTriadic(op_subui,0,makereg(30),makereg(30),make_immed(popcnt(regmask)*8));
//		GenerateTriadic(op_sm,0,make_indirect(30),make_mask(regmask),NULL);
//	}
//	return regmask;
//}
//

int SaveTempRegs()
{
	int n;
	int rm;

	if (regmask != 0) {
		GenerateTriadic(op_subui,0,makereg(30),makereg(30),make_immed(popcnt(regmask)*8));
		for (n = 1, rm = regmask; rm != 0; n = n + 1,rm = rm >> 1)
			if (rm & 1)
				GenerateDiadic(op_sw,0,makereg(n),make_indexed((popcnt(rm)-1)*8,30));
	}
	return regmask;
}


void RestoreTempRegs(int rgmask)
{
	int n;
	int rm;

	if (rgmask != 0) {
		for (n = 1, rm = rgmask; rm != 0; n = n + 1,rm = rm >> 1)
			if (rm & 1)
				GenerateDiadic(op_lw,0,makereg(n),make_indexed((popcnt(rm)-1)*8,30));
		GenerateTriadic(op_addui,0,makereg(30),makereg(30),make_immed(popcnt(rgmask)*8));
	}
}


//void RestoreTempRegs(int rgmask)
//{
//	if (popcnt(rgmask)==1) {
//		GenerateTriadic(op_lw,0,make_mask(rgmask),make_indirect(30),NULL);
//		GenerateTriadic(op_addui,0,makereg(30),makereg(30),make_immed(8));
//	}
//	else if (rgmask != 0) {
//		GenerateTriadic(op_lm,0,make_indirect(30),make_mask(rgmask),NULL);
//		GenerateTriadic(op_addui,0,makereg(30),makereg(30),make_immed(popcnt(rgmask)*8));
//	}
//}
//
void ReleaseTempRegister(struct amode *ap)
{
	if (ap==NULL) {
		printf("DIAG - NULL pointer in ReleaseTempRegister\r\n");
		return;
	}
	if( ap->mode == am_immed || ap->mode == am_direct )
        return;         // no registers used
	if(ap->preg < 11 && ap->preg >= 3)
		PushOnRstk(ap->preg);
}



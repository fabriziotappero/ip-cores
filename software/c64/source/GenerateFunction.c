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
#include <string.h>
#include "c.h"
#include "expr.h"
#include "Statement.h"
#include "gen.h"
#include "cglbdec.h"

extern int     breaklab;
extern int     contlab;
extern int     retlab;
extern int		throwlab;

extern int lastsph;
extern char *semaphores[20];

extern TYP              stdfunc;

void GenerateReturn(SYM *sym, Statement *stmt);


// Generate a function body.
//
void GenerateFunction(SYM *sym, Statement *stmt)
{
	char buf[20];
	char *bl;

	throwlab = retlab = contlab = breaklab = -1;
	lastsph = 0;
	memset(semaphores,0,sizeof(semaphores));
	throwlab = nextlabel++;
	while( lc_auto & 7 )	/* round frame size to word */
		++lc_auto;
	if (sym->IsInterrupt) {
		//GenerateTriadic(op_subui,0,makereg(30),makereg(30),make_immed(30*8));
		//GenerateDiadic(op_sm,0,make_indirect(30), make_mask(0x9FFFFFFE));
	}
	if (!sym->IsNocall) {
		GenerateTriadic(op_subui,0,makereg(30),makereg(30),make_immed(24));
		// For a leaf routine don't bother to store the link register or exception link register.
		if (sym->IsLeaf)
			GenerateDiadic(op_sw,0,makereg(27),make_indirect(30));
		else {
			GenerateDiadic(op_sw, 0, makereg(27), make_indexed(0,30));
			GenerateDiadic(op_sw, 0, makereg(28), make_indexed(8,30));
			GenerateDiadic(op_sw, 0, makereg(31), make_indexed(16,30));
			GenerateDiadic(op_lea,0,makereg(28),make_label(throwlab));
		}
		GenerateDiadic(op_mov,0,makereg(27),makereg(30));
		if (lc_auto)
			GenerateTriadic(op_subui,0,makereg(30),makereg(30),make_immed(lc_auto));
	}
	if (optimize)
		opt1(stmt);
    GenerateStatement(stmt);
    GenerateReturn(sym,0);
	// Generate code for the hidden default catch
	GenerateLabel(throwlab);
	if (sym->IsLeaf){
		if (sym->DoesThrow) {
			GenerateDiadic(op_mov,0,makereg(31),makereg(28));
			GenerateDiadic(op_bra,0,make_label(retlab),NULL);				// goto regular return cleanup code
		}
	}
	else {
		GenerateDiadic(op_lw,0,makereg(31),make_indexed(8,27));		// load throw return address from stack into LR
		GenerateDiadic(op_sw,0,makereg(31),make_indexed(16,27));		// and store it back (so it can be loaded with the lm)
		GenerateDiadic(op_bra,0,make_label(retlab),NULL);				// goto regular return cleanup code
	}
}


// Generate a return statement.
//
void GenerateReturn(SYM *sym, Statement *stmt)
{
	AMODE *ap;
	int nn;
	int lab1;
	int cnt;

    if( stmt != NULL && stmt->exp != NULL )
	{
		initstack();
		ap = GenerateExpression(stmt->exp,F_REG|F_IMMED,8);
		// Force return value into register 1
		if( ap->preg != 1 ) {
			if (ap->mode == am_immed)
				GenerateTriadic(op_ori, 0, makereg(1),makereg(0),ap);
			else
				GenerateDiadic(op_mov, 0, makereg(1),ap);
		}
	}
	// Generate the return code only once. Branch to the return code for all returns.
	if( retlab == -1 )
    {
		retlab = nextlabel++;
		GenerateLabel(retlab);
		// Unlock any semaphores that may have been set
		for (nn = lastsph - 1; nn >= 0; nn--)
			GenerateDiadic(op_sb,0,makereg(0),make_string(semaphores[nn]));
		if (sym->IsNocall)	// nothing to do for nocall convention
			return;
		// Restore registers used as register variables.
		if( save_mask != 0 ) {
			cnt = (bitsset(save_mask)-1)*8;
			for (nn = 31; nn >=1 ; nn--) {
				if (save_mask & (1 << nn)) {
					GenerateTriadic(op_lw,0,makereg(nn),make_indexed(cnt,30),NULL);
					cnt -= 8;
				}
			}
			GenerateTriadic(op_addui,0,makereg(30),makereg(30),make_immed(popcnt(save_mask)*8));
		}
		// Unlink the stack
		// For a leaf routine the link register and exception link register doesn't need to be saved/restored.
		GenerateDiadic(op_mov,0,makereg(30),makereg(27));
		if (sym->IsLeaf)
			GenerateDiadic(op_lw,0,makereg(27),make_indirect(30));
		else {
			GenerateDiadic(op_lw,0,makereg(27),make_indirect(30));
			GenerateDiadic(op_lw,0,makereg(28),make_indexed(8,30));
			GenerateDiadic(op_lw,0,makereg(31),make_indexed(16,30));
		}
		//if (isOscall) {
		//	GenerateDiadic(op_move,0,makereg(0),make_string("_TCBregsave"));
		//	gen_regrestore();
		//}
		// Generate the return instruction. For the Pascal calling convention pop the parameters
		// from the stack.
		if (sym->IsInterrupt) {
			//GenerateTriadic(op_addui,0,makereg(30),makereg(30),make_immed(24));
			//GenerateDiadic(op_lm,0,make_indirect(30),make_mask(0x9FFFFFFE));
			//GenerateTriadic(op_addui,0,makereg(30),makereg(30),make_immed(popcnt(0x9FFFFFFE)*8));
			GenerateMonadic(op_iret,0,NULL);
			return;
		}
		if (sym->IsPascal)
			GenerateDiadic(op_ret,0,make_immed(24+sym->NumParms * 8),NULL);
		else
			GenerateDiadic(op_ret,0,make_immed(24),NULL);
    }
	// Just branch to the already generated stack cleanup code.
	else {
		GenerateDiadic(op_bra,0,make_label(retlab),0);
	}
}

// push the operand expression onto the stack.
//
static void GeneratePushParameter(ENODE *ep, int i, int n)
{    
	AMODE *ap;
	ap = GenerateExpression(ep,F_REG,8);
	GenerateDiadic(op_sw,0,ap,make_indexed((n-i)*8-8,30));
	ReleaseTempRegister(ap);
}

// push entire parameter list onto stack
//
static int GeneratePushParameterList(ENODE *plist)
{
	ENODE *st = plist;
	int i,n;
	// count the number of parameters
	for(n = 0; plist != NULL; n++ )
		plist = plist->p[1];
	// move stack pointer down by number of parameters
	if (st)
		GenerateTriadic(op_subui,0,makereg(30),makereg(30),make_immed(n*8));
	plist = st;
    for(i = 0; plist != NULL; i++ )
    {
		GeneratePushParameter(plist->p[0],i,n);
		plist = plist->p[1];
    }
    return i;
}

AMODE *GenerateFunctionCall(ENODE *node, int flags)
{ 
	AMODE *ap, *result;
	SYM *sym;
    int             i;
	int msk;

 	msk = SaveTempRegs();
	sym = NULL;
    i = GeneratePushParameterList(node->p[1]);
	// Call the function
	if( node->p[0]->nodetype == en_nacon ) {
        GenerateDiadic(op_call,0,make_offset(node->p[0]),NULL);
		sym = gsearch(node->p[0]->sp);
	}
    else
    {
		ap = GenerateExpression(node->p[0],F_REG,8);
		ap->mode = am_ind;
		GenerateDiadic(op_jal,0,makereg(31),ap);
		ReleaseTempRegister(ap);
    }
	// Pop parameters off the stack
	if (i!=0) {
		if (sym) {
			if (!sym->IsPascal)
				GenerateTriadic(op_addui,0,makereg(30),makereg(30),make_immed(i * 8));
		}
		else
			GenerateTriadic(op_addui,0,makereg(30),makereg(30),make_immed(i * 8));
	}
	RestoreTempRegs(msk);
    result = GetTempRegister();
    if( result->preg != 1 || (flags & F_REG) == 0 )
		if (sym) {
			if (sym->tp->btp->type==bt_void)
				;
			else
				GenerateDiadic(op_mov,0,result,makereg(1));
		}
		else
			GenerateDiadic(op_mov,0,result,makereg(1));
    return result;
}


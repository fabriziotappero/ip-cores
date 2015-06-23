#include        <stdio.h>
#include        "c.h"
#include        "expr.h"
#include "Statement.h"
#include        "gen.h"
#include        "cglbdec.h"

static void AddToPeepList(struct ocode *newc);
void peep_add(struct ocode *ip);
static void PeepoptSub(struct ocode *ip);
void peep_move(struct ocode	*ip);
void peep_cmp(struct ocode *ip);
void opt3();
void put_ocode(struct ocode *p);

/*
 *	68000 C compiler
 *
 *	Copyright 1984, 1985, 1986 Matthew Brandt.
 *  all commercial rights reserved.
 *
 *	This compiler is intended as an instructive tool for personal use. Any
 *	use for profit without the written consent of the author is prohibited.
 *
 *	This compiler may be distributed freely for non-commercial use as long
 *	as this notice stays intact. Please forward any enhancements or questions
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */
/*******************************************************
	Copyright 2012	Robert Finch
	Modified to support Raptor64 'C64' language
	by Robert Finch
	robfinch@opencores.org
*******************************************************/

struct ocode    *peep_head = NULL,
                *peep_tail = NULL;

AMODE *copy_addr(AMODE *ap)
{
	AMODE *newap;
    if( ap == NULL )
        return NULL;
    newap = allocAmode();
	memcpy(newap,ap,sizeof(AMODE));
    return newap;
}

void GenerateMonadic(int op, int len, AMODE *ap1)
{
	struct ocode *cd;
    cd = (struct ocode *)xalloc(sizeof(struct ocode));
    cd->opcode = op;
    cd->length = len;
    cd->oper1 = copy_addr(ap1);
    cd->oper2 = NULL;
	cd->oper3 = NULL;
    AddToPeepList(cd);
}

void GenerateDiadic(int op, int len, AMODE *ap1, AMODE *ap2)
{
	struct ocode *cd;
    cd = (struct ocode *)xalloc(sizeof(struct ocode));
    cd->opcode = op;
    cd->length = len;
    cd->oper1 = copy_addr(ap1);
    cd->oper2 = copy_addr(ap2);
	cd->oper3 = NULL;
    AddToPeepList(cd);
}

void GenerateTriadic(int op, int len, AMODE *ap1, AMODE *ap2, AMODE *ap3)
{
	struct ocode    *cd;
    cd = (struct ocode *)xalloc(sizeof(struct ocode));
    cd->opcode = op;
    cd->length = len;
    cd->oper1 = copy_addr(ap1);
    cd->oper2 = copy_addr(ap2);
	cd->oper3 = copy_addr(ap3);
    AddToPeepList(cd);
}

static void AddToPeepList(struct ocode *cd)
{
	if( peep_head == NULL )
    {
		peep_head = peep_tail = cd;
		cd->fwd = NULL;
		cd->back = NULL;
    }
    else
    {
		cd->fwd = NULL;
		cd->back = peep_tail;
		peep_tail->fwd = cd;
		peep_tail = cd;
    }
}

/*
 *      add a compiler generated label to the peep list.
 */
void GenerateLabel(int labno)
{      
	struct ocode *newl;
    newl = (struct ocode *)xalloc(sizeof(struct ocode));
    newl->opcode = op_label;
    newl->oper1 = (struct amode *)labno;
    AddToPeepList(newl);
}

//void gen_ilabel(char *name)
//{      
//	struct ocode    *new;
//    new = (struct ocode *)xalloc(sizeof(struct ocode));
//    new->opcode = op_ilabel;
//    new->oper1 = (struct amode *)name;
//    add_peep(new);
//}

/*
 *      output all code and labels in the peep list.
 */
void flush_peep()
{
	if (optimize)
		opt3();         /* do the peephole optimizations */
    while( peep_head != NULL )
    {
		if( peep_head->opcode == op_label )
			put_label(peep_head->oper1);
		else
			put_ocode(peep_head);
		peep_head = peep_head->fwd;
    }
}

/*
 *      output the instruction passed.
 */
void put_ocode(struct ocode *p)
{
	put_code(p->opcode,p->length,p->oper1,p->oper2,p->oper3);
}

/*
 *      peephole optimization for move instructions.
 *      makes quick immediates when possible.
 *      changes move #0,d to clr d.
 *      changes long moves to address registers to short when
 *              possible.
 *      changes move immediate to stack to pea.
 */
void peep_move(struct ocode	*ip)
{
	return;
}

/*
 *      compare two address nodes and return true if they are
 *      equivalent.
 */
int equal_address(AMODE *ap1, AMODE *ap2)
{
	if( ap1 == NULL || ap2 == NULL )
		return FALSE;
    if( ap1->mode != ap2->mode )
        return FALSE;
    switch( ap1->mode )
    {
        case am_reg:
            return ap1->preg == ap2->preg;
    }
    return FALSE;
}

/*
 *      peephole optimization for add instructions.
 *      makes quick immediates out of small constants.
 */
void peep_add(struct ocode    *ip)
{
	return;
}

// 'subui' followed by a 'bne' gets turned into 'loop'
//
static void PeepoptSub(struct ocode *ip)
{  
	if (ip->opcode==op_subui) {
		if (ip->oper3) {
			if (ip->oper3->mode==am_immed) {
				if (ip->oper3->offset->nodetype==en_icon && ip->oper3->offset->i==1) {
					if (ip->fwd) {
						if (ip->fwd->opcode==op_bne && ip->fwd->oper2->mode==am_reg && ip->fwd->oper2->preg==0) {
							if (ip->fwd->oper1->preg==ip->oper1->preg) {
								ip->opcode = op_loop;
								ip->oper2 = ip->fwd->oper3;
								ip->oper3 = NULL;
								if (ip->fwd->back) ip->fwd->back = ip;
								ip->fwd = ip->fwd->fwd;
								return;
							}
						}
					}
				}
			}
		}
	}
	return;
}

/*
 *      peephole optimization for compare instructions.
 */
void peep_cmp(struct ocode *ip)
{
	return;
}

/*
 *      changes multiplies and divides by convienient values
 *      to shift operations. op should be either op_asl or
 *      op_asr (for divide).
 */
void PeepoptMuldiv(struct ocode *ip, int op)
{  
	int     shcnt;

    if( ip->oper1->mode != am_immed )
         return;
    if( ip->oper1->offset->nodetype != en_icon )
         return;

        shcnt = ip->oper1->offset->i;
		// remove multiply / divide by 1
		// This shouldn't get through Optimize, but does sometimes.
		if (shcnt==1) {
			if (ip->back)
				ip->back->fwd = ip->fwd;
			if (ip->fwd)
				ip->fwd->back = ip->back;
			return;
		}
/*      vax c doesn't do this type of switch well       */
        if( shcnt == 2) shcnt = 1;
        else if( shcnt == 4) shcnt = 2;
        else if( shcnt == 8) shcnt = 3;
        else if( shcnt == 16) shcnt = 4;
        else if( shcnt == 32) shcnt = 5;
        else if( shcnt == 64) shcnt = 6;
        else if( shcnt == 128) shcnt = 7;
        else if( shcnt == 256) shcnt = 8;
        else if( shcnt == 512) shcnt = 9;
        else if( shcnt == 1024) shcnt = 10;
        else if( shcnt == 2048) shcnt = 11;
        else if( shcnt == 4096) shcnt = 12;
        else if( shcnt == 8192) shcnt = 13;
        else if( shcnt == 16384) shcnt = 14;
		else if( shcnt == 32768) shcnt = 15;
        else return;
        ip->oper1->offset->i = shcnt;
        ip->opcode = op;
        ip->length = 4;
}

// Optimize unconditional control flow transfers
// Instructions that follow an unconditional transfer won't be executed
// unless there is a label to branch to them.
//
void PeepoptUctran(struct ocode    *ip)
{
	if (uctran_off) return;
	while( ip->fwd != NULL && ip->fwd->opcode != op_label)
    {
		ip->fwd = ip->fwd->fwd;
		if( ip->fwd != NULL )
			ip->fwd->back = ip;
    }
}

/*
 *      peephole optimizer. This routine calls the instruction
 *      specific optimization routines above for each instruction
 *      in the peep list.
 */
void opt3()
{  
	struct ocode    *ip;
    ip = peep_head;
    while( ip != NULL )
    {
        switch( ip->opcode )
        {
            case op_move:
                    peep_move(ip);
                    break;
            case op_add:
                    peep_add(ip);
                    break;
            case op_sub:
                    PeepoptSub(ip);
                    break;
            case op_cmp:
                    peep_cmp(ip);
                    break;
            case op_muls:
                    PeepoptMuldiv(ip,op_shl);
                    break;
            case op_bra:
            case op_jmp:
            case op_ret:
			case op_iret:
                    PeepoptUctran(ip);
            }
	       ip = ip->fwd;
        }
}

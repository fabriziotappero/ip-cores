#include        <stdio.h>
#include        "c.h"
#include        "expr.h"
#include "Statement.h"
#include        "gen.h"
#include        "cglbdec.h"

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

/*
 *      this module contains all of the code generation routines
 *      for evaluating expressions and conditions.
 */

/*******************************************************
	Modified to support Raptor64 'C64' language
	by Robert Finch
	robfinch@opencores.org
*******************************************************/

AMODE *GenerateExpression();            /* forward ParseSpecifieraration */

extern int throwlab;
/*
 *      construct a reference node for an internal label number.
 */
AMODE *make_label(__int64 lab)
{
	struct enode    *lnode;
    struct amode    *ap;
    lnode = xalloc(sizeof(struct enode));
    lnode->nodetype = en_labcon;
    lnode->i = lab;
    ap = xalloc(sizeof(struct amode));
    ap->mode = am_direct;
    ap->offset = lnode;
    return ap;
}

AMODE *make_string(char *s)
{
	ENODE *lnode;
    AMODE *ap;

    lnode = xalloc(sizeof(struct enode));
    lnode->nodetype = en_nacon;
    lnode->sp = s;
    ap = allocAmode();
    ap->mode = am_direct;
    ap->offset = lnode;
    return ap;
}

/*
 *      make a node to reference an immediate value i.
 */
AMODE *make_immed(__int64 i)
{
	AMODE *ap;
    ENODE *ep;
    ep = xalloc(sizeof(struct enode));
    ep->nodetype = en_icon;
    ep->i = i;
    ap = allocAmode();
    ap->mode = am_immed;
    ap->offset = ep;
    return ap;
}

AMODE *make_indirect(int i)
{
	AMODE *ap;
    ENODE *ep;
    ep = xalloc(sizeof(struct enode));
    ep->nodetype = en_uw_ref;
    ep->i = 0;
    ap = allocAmode();
	ap->mode = am_ind;
	ap->preg = i;
    ap->offset = ep;
    return ap;
}

AMODE *make_indexed(__int64 o, int i)
{
	AMODE *ap;
    ENODE *ep;
    ep = xalloc(sizeof(struct enode));
    ep->nodetype = en_icon;
    ep->i = o;
    ap = allocAmode();
	ap->mode = am_indx;
	ap->preg = i;
    ap->offset = ep;
    return ap;
}

/*
 *      make a direct reference to a node.
 */
AMODE *make_offset(ENODE *node)
{
	AMODE *ap;
    ap = allocAmode();
    ap->mode = am_direct;
    ap->offset = node;
    return ap;
}
        
/*
 *      MakeLegalAmode will coerce the addressing mode in ap1 into a
 *      mode that is satisfactory for the flag word.
 */
void MakeLegalAmode(AMODE *ap,int flags, int size)
{
	AMODE *ap2;
	__int64 i;

	if (ap==NULL) return;
    if( ((flags & F_VOL) == 0) || ap->tempflag )
    {
        switch( ap->mode ) {
            case am_immed:
					i = ((ENODE *)(ap->offset))->i;
					if (flags & F_IMMED18) {
						if (i < 0x1ffff && i > -0x1ffff)
							return;
					}
                    else if( flags & F_IMMED )
                        return;         /* mode ok */
                    break;
            case am_reg:
                    if( flags & F_REG )
                        return;
                    break;
            case am_ind:
			case am_indx:
            case am_indx2: 
			case am_direct:
			case am_indx3:
                    if( flags & F_MEM )
                        return;
                    break;
            }
        }

        if( flags & F_REG )
        {
            ReleaseTempRegister(ap);      /* maybe we can use it... */
            ap2 = GetTempRegister();      /* AllocateRegisterVars to dreg */
			if (ap->mode == am_ind || ap->mode==am_indx) {
				switch(size) {
				case 1:	GenerateDiadic(op_lb,0,ap2,ap); break;
				case 2:	GenerateDiadic(op_lc,0,ap2,ap); break;
				case 4:	GenerateDiadic(op_lh,0,ap2,ap); break;
				case 8:	GenerateDiadic(op_lw,0,ap2,ap); break;
				}
			}
			else if (ap->mode==am_immed)
				GenerateTriadic(op_ori,0,ap2,makereg(0),ap);
			else {
				if (ap->mode==am_reg)
					GenerateTriadic(op_or,0,ap2,ap,makereg(0));
				else {
					switch(size) {
					case 1:	GenerateDiadic(op_lb,0,ap2,ap); break;
					case 2:	GenerateDiadic(op_lc,0,ap2,ap); break;
					case 4:	GenerateDiadic(op_lh,0,ap2,ap); break;
					case 8:	GenerateDiadic(op_lw,0,ap2,ap); break;
					}
				}
			}
            ap->mode = am_reg;
            ap->preg = ap2->preg;
            ap->deep = ap2->deep;
            ap->tempflag = 1;
            return;
        }
        if( size == 1 )
		{
			ReleaseTempRegister(ap);
			ap2 = GetTempRegister();
			GenerateTriadic(op_or,0,ap2,ap,makereg(0));
			GenerateTriadic(op_sext8,0,ap2,ap2,NULL);
			ap->mode = ap2->mode;
			ap->preg = ap2->preg;
			ap->deep = ap2->deep;
			size = 2;
        }
        ap2 = GetTempRegister();
		switch(ap->mode) {
		case am_ind:
		case am_indx:
			switch(size) {
			case 1:	GenerateDiadic(op_lb,0,ap2,ap); break;
			case 2:	GenerateDiadic(op_lc,0,ap2,ap); break;
			case 4:	GenerateDiadic(op_lh,0,ap2,ap); break;
			case 8:	GenerateDiadic(op_lw,0,ap2,ap); break;
			}
			break;
		case am_immed:
			GenerateTriadic(op_ori,0,ap2,makereg(0),ap);
		case am_reg:
			GenerateTriadic(op_or,0,ap2,ap,makereg(0));
		default:
			switch(size) {
			case 1:	GenerateDiadic(op_lb,0,ap2,ap); break;
			case 2:	GenerateDiadic(op_lc,0,ap2,ap); break;
			case 4:	GenerateDiadic(op_lh,0,ap2,ap); break;
			case 8:	GenerateDiadic(op_lw,0,ap2,ap); break;
			}
		}
    ap->mode = am_reg;
    ap->preg = ap2->preg;
    ap->deep = ap2->deep;
    ap->tempflag = 1;
}

/*
 *      if isize is not equal to osize then the operand ap will be
 *      loaded into a register (if not already) and if osize is
 *      greater than isize it will be extended to match.
 */
void GenerateSignExtend(AMODE *ap, int isize, int osize, int flags)
{    
	struct amode *ap2;

	if( isize == osize )
        return;
    if(ap->mode != am_reg)
        MakeLegalAmode(ap,flags & F_REG,isize);
    switch( isize )
    {
    case 1:	GenerateDiadic(op_sext8,0,ap,ap); break;
    case 2:	GenerateDiadic(op_sext16,0,ap,ap); break;
    case 4:	GenerateDiadic(op_sext32,0,ap,ap); break;
    }
}

/*
 *      return true if the node passed can be generated as a short
 *      offset.
 */
int isshort(ENODE *node)
{
	return node->nodetype == en_icon &&
        (node->i >= -32768 && node->i <= 32767);
}

/*
 *      return true if the node passed can be evaluated as a byte
 *      offset.
 */
int isbyte(ENODE *node)
{
	return node->nodetype == en_icon &&
       (-128 <= node->i && node->i <= 127);
}

int ischar(ENODE *node)
{
	return node->nodetype == en_icon &&
        (node->i >= -32768 && node->i <= 32767);
}

/*
 *      generate code to evaluate an index node (^+) and return
 *      the addressing mode of the result. This routine takes no
 *      flags since it always returns either am_ind or am_indx.
 */
AMODE *GenerateIndex(ENODE *node)
{       
	AMODE *ap1, *ap2, *ap3;

    if( (node->p[0]->nodetype == en_tempref || node->p[0]->nodetype==en_regvar) && (node->p[1]->nodetype == en_tempref || node->p[1]->nodetype==en_regvar))
    {       /* both nodes are registers */
        ap1 = GenerateExpression(node->p[0],F_REG,8);
        ap2 = GenerateExpression(node->p[1],F_REG,8);
        ap1->mode = am_indx2;
        ap1->sreg = ap2->preg;
		ap1->offset = makeinode(en_icon,0);
		ap1->scale = node->scale;
        return ap1;
    }
    ap1 = GenerateExpression(node->p[0],F_REG | F_IMMED,8);
    if( ap1->mode == am_immed )
    {
		ap2 = GenerateExpression(node->p[1],F_REG,8);
		ap2->mode = am_indx;
		ap2->offset = ap1->offset;
		ReleaseTempRegister(ap1);
		return ap2;
    }
    ap2 = GenerateExpression(node->p[1],F_ALL,8);   /* get right op */
    if( ap2->mode == am_immed && ap1->mode == am_reg ) /* make am_indx */
    {
        ap2->mode = am_indx;
		ReleaseTempRegister(ap2);
        ap2->preg = ap1->preg;
        ap2->deep = ap1->deep;
        return ap2;
    }
	// ap1->mode must be F_REG
	MakeLegalAmode(ap2,F_REG,8);
//	ap3 = GetTempRegister();
//	GenerateTriadic(op_addu,0,ap3,ap1,ap2);             /* add left to address reg */
    ap1->mode = am_indx2;            /* make indirect */
	ap1->sreg = ap2->preg;
	ap1->offset = makeinode(en_icon,0);
	ap1->scale = node->scale;
//  ReleaseTempRegister(ap2);                    /* release any temps in ap2 */
//	ReleaseTempRegister(ap1);
    return ap1;                     /* return indirect */
}

long GetReferenceSize(ENODE *node)
{
    switch( node->nodetype )        /* get load size */
    {
    case en_b_ref:
    case en_ub_ref:
    case en_bfieldref:
    case en_ubfieldref:
            return 1;
	case en_c_ref:
	case en_uc_ref:
	case en_cfieldref:
	case en_ucfieldref:
			return 2;
	case en_h_ref:
	case en_uh_ref:
	case en_hfieldref:
	case en_uhfieldref:
			return 4;
    case en_w_ref:
	case en_uw_ref:
    case en_wfieldref:
	case en_uwfieldref:
	case en_tempref:
	case en_regvar:
            return 8;
    }
	return 8;
}

/*
 *      return the addressing mode of a dereferenced node.
 */
AMODE *GenerateDereference(ENODE *node,int flags,int size)
{    
	struct amode    *ap1;
    int             siz1;

	siz1 = GetReferenceSize(node);
    if( node->p[0]->nodetype == en_add )
    {
        ap1 = GenerateIndex(node->p[0]);
        GenerateSignExtend(ap1,siz1,size,flags);
        MakeLegalAmode(ap1,flags,size);
        return ap1;
    }
    else if( node->p[0]->nodetype == en_autocon )
    {
        ap1 = xalloc(sizeof(struct amode));
        ap1->mode = am_indx;
        ap1->preg = 27;
        ap1->offset = makeinode(en_icon,node->p[0]->i);
        GenerateSignExtend(ap1,siz1,size,flags);
        MakeLegalAmode(ap1,flags,size);
        return ap1;
    }
    ap1 = GenerateExpression(node->p[0],F_REG | F_IMMED,4); /* generate address */
    if( ap1->mode == am_reg )
    {
        ap1->mode = am_ind;
        GenerateSignExtend(ap1,siz1,size,flags);
        MakeLegalAmode(ap1,flags,size);
        return ap1;
    }
    ap1->mode = am_direct;
    GenerateSignExtend(ap1,siz1,size,flags);
    MakeLegalAmode(ap1,flags,size);
    return ap1;
}

void SignExtendBitfield(ENODE *node, struct amode *ap3, __int64 mask)
{
	struct amode *ap2;
	__int64 umask;

	umask = 0x8000000000000000L | ~(mask >> 1);
	ap2 = GetTempRegister();
	GenerateTriadic(op_ori,0,ap2,makereg(0),make_immed(umask));
	GenerateTriadic(op_add,0,ap3,ap3,ap2);
	GenerateTriadic(op_xor,0,ap3,ap3,ap2);
	ReleaseTempRegister(ap2);
}

AMODE *GenerateBitfieldDereference(ENODE *node, int flags, int size)
{
    AMODE *ap, *ap1,*ap2,*ap3;
    long            mask,umask;
    int             width = node->bit_width + 1;
	int isSigned;

	isSigned = node->nodetype==en_wfieldref || node->nodetype==en_hfieldref || node->nodetype==en_cfieldref || node->nodetype==en_bfieldref;
	mask = 0;
	while (--width)	mask = mask + mask + 1;
    ap = GenerateDereference(node, flags, node->esize);
    MakeLegalAmode(ap, flags, node->esize);
	ap3 = GetTempRegister();
	GenerateTriadic(op_or,0,ap3,ap,makereg(0));
	ReleaseTempRegister(ap);
    if (node->bit_offset > 0) {
		GenerateDiadic(op_shru, 0, ap3, make_immed((__int64) node->bit_offset));
		GenerateDiadic(op_and, 0, ap3, make_immed(mask));
		//MakeLegalAmode(ap, flags, node->esize);
		if (isSigned)
			SignExtendBitfield(node, ap3, mask);
    }
	else {
		GenerateTriadic(op_and, 0, ap3, ap3, make_immed(mask));
		if (isSigned)
			SignExtendBitfield(node, ap3, mask);
	}
    //mask = 0;
    //while (--width)	mask = mask + mask + 1;
//    GenerateDiadic(op_and, (int) node->esize, make_immed(mask), ap);
	MakeLegalAmode(ap3, flags, node->esize);
    return ap3;
}

/*
 *      generate code to evaluate a unary minus or complement.
 */
AMODE *GenerateUnary(ENODE *node,int flags, int size, int op)
{
	AMODE *ap,*ap1;
    ap = GenerateExpression(node->p[0],F_REG,size);
	ap1 = GetTempRegister();
    GenerateDiadic(op,0,ap1,ap);
    ReleaseTempRegister(ap);
    MakeLegalAmode(ap1,flags,size);
    return ap1;
}

AMODE *GenerateBinary(ENODE *node,int flags, int size, int op)
{
	AMODE *ap1, *ap2, *ap3;
	int op2;
    ap1 = GenerateExpression(node->p[0],F_REG,size);
    ap2 = GenerateExpression(node->p[1],F_REG|F_IMMED,size);
	ap3 = GetTempRegister();
	GenerateTriadic(op,0,ap3,ap1,ap2);
    ReleaseTempRegister(ap1);
    ReleaseTempRegister(ap2);
    MakeLegalAmode(ap3,flags,size);
    return ap3;
}

/*
 *      generate code to evaluate a mod operator or a divide
 *      operator.
 */
AMODE *GenerateModDiv(ENODE *node,int flags,int size, int op)
{
	AMODE *ap1, *ap2, *ap3;

    if( node->p[0]->nodetype == en_icon )
         swap_nodes(node);
    ap1 = GenerateExpression(node->p[0],F_REG,8);
    ap2 = GenerateExpression(node->p[1],F_REG | F_IMMED,8);
	ap3 = GetTempRegister();
	GenerateTriadic(op,0,ap3,ap1,ap2);
//    GenerateDiadic(op_ext,0,ap3,0);
    MakeLegalAmode(ap3,flags,4);
    ReleaseTempRegister(ap1);
    ReleaseTempRegister(ap2);
    return ap3;
}

/*
 *      exchange the two operands in a node.
 */
void swap_nodes(ENODE *node)
{
	ENODE *temp;
    temp = node->p[0];
    node->p[0] = node->p[1];
    node->p[1] = temp;
}

/*
 *      generate code to evaluate a multiply node. both operands
 *      are treated as words and the result is long and is always
 *      in a register so that the 68000 mul instruction can be used.
 */
AMODE *GenerateMultiply(ENODE *node, int flags, int size, int op)
{       
	AMODE *ap1, *ap2, *ap3;
    if( node->p[0]->nodetype == en_icon )
        swap_nodes(node);
    ap1 = GenerateExpression(node->p[0],F_REG,8);
    ap2 = GenerateExpression(node->p[1],F_REG | F_IMMED,8);
ap3 = GetTempRegister();
	if (ap2->mode == am_immed) {
		if (op==op_mulu)
			GenerateTriadic(op_mului,0,ap3,ap1,ap2);
		else
			GenerateTriadic(op_mulsi,0,ap3,ap1,ap2);
	}
	else
		GenerateTriadic(op,0,ap3,ap1,ap2);
    ReleaseTempRegister(ap1);
    ReleaseTempRegister(ap2);
    MakeLegalAmode(ap3,flags,8);
    return ap3;
}

/*
 *      generate code to evaluate a condition operator node (?:)
 */
AMODE *gen_hook(ENODE *node,int flags, int size)
{
	AMODE *ap1, *ap2;
    int false_label, end_label;

    false_label = nextlabel++;
    end_label = nextlabel++;
    flags = (flags & F_REG) | F_VOL;
    GenerateFalseJump(node->p[0],false_label);
    node = node->p[1];
    ap1 = GenerateExpression(node->p[0],flags,size);
    ReleaseTempRegister(ap1);
    GenerateDiadic(op_bra,0,make_label(end_label),0);
    GenerateLabel(false_label);
    ap2 = GenerateExpression(node->p[1],flags,size);
    if( !equal_address(ap1,ap2) )
    {
        ReleaseTempRegister(ap2);
//        GetTempRegister();
		GenerateTriadic(op_or,0,ap1,makereg(0),ap2);
    }
    GenerateLabel(end_label);
    return ap1;
}

AMODE *GenerateAssignAdd(ENODE *node,int flags, int size, int op)
{
	AMODE *ap1, *ap2, *ap3;
    int             ssize, mask0, mask1;
    ssize = GetNaturalSize(node->p[0]);
    if( ssize > size )
            size = ssize;
    ap1 = GenerateExpression(node->p[0],F_ALL,ssize);
    ap2 = GenerateExpression(node->p[1],F_REG | F_IMMED,size);
	if (ap2->mode ==am_immed)
		switch(op) {
		case op_addu:	op = op_addui; break;
		case op_add:	op = op_addui; break;
		case op_subu:	op = op_subui; break;
		case op_sub:	op = op_subui; break;
		}
	if (ap1->mode==am_reg) {
	    GenerateTriadic(op,0,ap1,ap1,ap2);
	}
	else {
		ap3 = GetTempRegister();
		switch(ssize) {
		case 1:	GenerateDiadic(op_lb,0,ap3,ap1); break;
		case 2:	GenerateDiadic(op_lc,0,ap3,ap1); break;
		case 4:	GenerateDiadic(op_lh,0,ap3,ap1); break;
		case 8:	GenerateDiadic(op_lw,0,ap3,ap1); break;
		}
		GenerateTriadic(op,0,ap3,ap3,ap2);
		switch(ssize) {
		case 1:	GenerateDiadic(op_sb,0,ap3,ap1); break;
		case 2:	GenerateDiadic(op_sc,0,ap3,ap1); break;
		case 4:	GenerateDiadic(op_sh,0,ap3,ap1); break;
		case 8:	GenerateDiadic(op_sw,0,ap3,ap1); break;
		}
		ReleaseTempRegister(ap3);
	}
    ReleaseTempRegister(ap2);
    GenerateSignExtend(ap1,ssize,size,flags);
    MakeLegalAmode(ap1,flags,size);
    return ap1;
}

AMODE *GenerateAssignLogic(ENODE *node,int flags, int size, int op)
{
	AMODE *ap1, *ap2, *ap3;
    int             ssize, mask0, mask1;
    ssize = GetNaturalSize(node->p[0]);
    if( ssize > size )
            size = ssize;
    ap1 = GenerateExpression(node->p[0],F_ALL,ssize);
    ap2 = GenerateExpression(node->p[1],F_REG | F_IMMED,size);
	if (ap2->mode==am_immed)
		switch(op) {
		case op_and:	op = op_andi; break;
		case op_or:		op = op_ori; break;
		case op_xor:	op = op_xori; break;
		}
	if (ap1->mode==am_reg) {
	    GenerateTriadic(op,0,ap1,ap1,ap2);
	}
	else {
		ap3 = GetTempRegister();
		switch(ssize) {
		case 1:	GenerateDiadic(op_lb,0,ap3,ap1); break;
		case 2:	GenerateDiadic(op_lc,0,ap3,ap1); break;
		case 4:	GenerateDiadic(op_lh,0,ap3,ap1); break;
		case 8:	GenerateDiadic(op_lw,0,ap3,ap1); break;
		}
		GenerateTriadic(op,0,ap3,ap3,ap2);
		switch(ssize) {
		case 1:	GenerateDiadic(op_sb,0,ap3,ap1); break;
		case 2:	GenerateDiadic(op_sc,0,ap3,ap1); break;
		case 4:	GenerateDiadic(op_sh,0,ap3,ap1); break;
		case 8:	GenerateDiadic(op_sw,0,ap3,ap1); break;
		}
		ReleaseTempRegister(ap3);
	}
    ReleaseTempRegister(ap2);
    GenerateSignExtend(ap1,ssize,size,flags);
    MakeLegalAmode(ap1,flags,size);
    return ap1;
}

/*
 *      generate a *= node.
 */
AMODE *GenerateAssignMultiply(ENODE *node,int flags, int size, int op)
{
	AMODE *ap1, *ap2, *ap3;
    int             ssize, mask0, mask1;
    ssize = GetNaturalSize(node->p[0]);
    if( ssize > size )
            size = ssize;
    ap1 = GenerateExpression(node->p[0],F_ALL,ssize);
    ap2 = GenerateExpression(node->p[1],F_REG | F_IMMED,size);
	if (ap2->mode==am_immed)
		switch(op) {
		case op_mulu:	op = op_mului; break;
		case op_muls:	op = op_mulsi; break;
		}
	if (ap1->mode==am_reg) {
	    GenerateTriadic(op,0,ap1,ap1,ap2);
	}
	else {
		ap3 = GetTempRegister();
		switch(ssize) {
		case 1:	GenerateDiadic(op_lb,0,ap3,ap1); break;
		case 2:	GenerateDiadic(op_lc,0,ap3,ap1); break;
		case 4:	GenerateDiadic(op_lh,0,ap3,ap1); break;
		case 8:	GenerateDiadic(op_lw,0,ap3,ap1); break;
		}
		GenerateTriadic(op,0,ap3,ap3,ap2);
		switch(ssize) {
		case 1:	GenerateDiadic(op_sb,0,ap3,ap1); break;
		case 2:	GenerateDiadic(op_sc,0,ap3,ap1); break;
		case 4:	GenerateDiadic(op_sh,0,ap3,ap1); break;
		case 8:	GenerateDiadic(op_sw,0,ap3,ap1); break;
		}
		ReleaseTempRegister(ap3);
	}
    ReleaseTempRegister(ap2);
    GenerateSignExtend(ap1,ssize,size,flags);
    MakeLegalAmode(ap1,flags,size);
    return ap1;
}

/*
 *      generate /= and %= nodes.
 */
AMODE *gen_asmodiv(ENODE *node,int flags,int size,int op)
{
	AMODE *ap1, *ap2, *ap3;
    int             siz1;

    siz1 = GetNaturalSize(node->p[0]);
    ap1 = GetTempRegister();
    ap2 = GenerateExpression(node->p[0],F_ALL & ~F_IMMED,siz1);
	if (ap2->mode==am_reg && ap2->preg != ap1->preg)
		GenerateTriadic(op_or,0,ap1,ap2,makereg(0));
	else {
		switch(siz1) {
		case 1:	GenerateDiadic(op_lb,0,ap1,ap2); break;
		case 2:	GenerateDiadic(op_lc,0,ap1,ap2); break;
		case 4:	GenerateDiadic(op_lh,0,ap1,ap2); break;
		case 8:	GenerateDiadic(op_lw,0,ap1,ap2); break;
		}
	}
    GenerateSignExtend(ap1,siz1,8,flags);
    ap3 = GenerateExpression(node->p[1],F_REG,2);
    GenerateTriadic(op,0,ap1,ap1,ap3);
    ReleaseTempRegister(ap3);
    //GenerateDiadic(op_ext,0,ap1,0);
	if (ap2->mode==am_reg)
		GenerateTriadic(op_or,0,ap2,ap1,makereg(0));
	else
		switch(siz1) {
			case 1:	GenerateDiadic(op_sb,0,ap1,ap2); break;
			case 2:	GenerateDiadic(op_sc,0,ap1,ap2); break;
			case 4:	GenerateDiadic(op_sh,0,ap1,ap2); break;
			case 8:	GenerateDiadic(op_sw,0,ap1,ap2); break;
		}
    ReleaseTempRegister(ap2);
    MakeLegalAmode(ap1,flags,size);
    return ap1;
}

/*
 *      generate code for an assignment node. if the size of the
 *      assignment destination is larger than the size passed then
 *      everything below this node will be evaluated with the
 *      assignment size.
 */
AMODE *GenerateAssign(ENODE *node, int flags, int size)
{       struct amode    *ap1, *ap2 ,*ap3;
        int             ssize;
		ENODE *ep;
    if (node->p[0]->nodetype == en_uwfieldref ||
		node->p[0]->nodetype == en_wfieldref ||
		node->p[0]->nodetype == en_uhfieldref ||
		node->p[0]->nodetype == en_hfieldref ||
		node->p[0]->nodetype == en_ucfieldref ||
		node->p[0]->nodetype == en_cfieldref ||
		node->p[0]->nodetype == en_ubfieldref ||
		node->p[0]->nodetype == en_bfieldref) {
		long            mask;
		int             i;
		/*
		* Field assignment
		*/
		/* get the value */
		ap1 = GenerateExpression(node->p[1], F_REG | F_VOL,8);
		i = node->p[0]->bit_width;
		for (mask = 0; i--; mask = mask + mask + 1);
		GenerateDiadic(op_and, 0, make_immed(mask), ap1);
		mask <<= node->p[0]->bit_offset;
		if (!(flags & F_NOVALUE)) {
			/*
			* result value needed
			*/
			ap3 = GetTempRegister();
			GenerateTriadic(op_or, 0, ap3, ap1, makereg(0));
		} else
	    ap3 = ap1;
		if (node->p[0]->bit_offset > 0) {
			if (node->p[0]->bit_offset < 9) {
				GenerateTriadic(op_shl, 0, ap3,ap3,make_immed((long) node->p[0]->bit_offset));
			}
			else {
				ap2 = GetTempRegister();
				GenerateTriadic(op_ori, 0, ap2,makereg(0),make_immed((long) node->p[0]->bit_offset));
				GenerateTriadic(op_shl, 0, ap3, ap3, ap2);
				ReleaseTempRegister(ap2);
			}
		}
		ep = makenode(en_w_ref, node->p[0]->p[0], NULL);
		ap2 = GenerateExpression(ep, F_MEM,8);
		//ap2 = GenerateExpression(node->v.p[0],F_ALL,4);
		GenerateTriadic(op_andi, 0, ap2,ap2,make_immed(~mask));
		GenerateTriadic(op_or, 0, ap2, ap2, ap3);
		ReleaseTempRegister(ap2);
		if (!(flags & F_NOVALUE)) {
			ReleaseTempRegister(ap3);
		}
		MakeLegalAmode(ap1, flags, size);
		return ap1;
    }

	ssize = GetReferenceSize(node->p[0]);
	if( ssize > size )
			size = ssize;
	ap2 = GenerateExpression(node->p[1],F_REG,size);
	ap1 = GenerateExpression(node->p[0],F_ALL,ssize);
	if (ap1->mode == am_reg) {
		GenerateDiadic(op_mov,0,ap1,ap2);
	}
	else {
		switch(size) {
		case 1:	GenerateDiadic(op_sb,0,ap2,ap1); break;
		case 2:	GenerateDiadic(op_sc,0,ap2,ap1); break;
		case 4: GenerateDiadic(op_sh,0,ap2,ap1); break;
		case 8:	GenerateDiadic(op_sw,0,ap2,ap1); break;
		}
	}
	ReleaseTempRegister(ap1);
	return ap2;
}

/*
 *      generate an auto increment or decrement node. op should be
 *      either op_add (for increment) or op_sub (for decrement).
 */
AMODE *GenerateAutoIncrement(ENODE *node,int flags,int size,int op)
{
	AMODE *ap1, *ap2;
    int siz1;

    siz1 = GetNaturalSize(node->p[0]);
    if( flags & F_NOVALUE )         /* dont need result */
            {
            ap1 = GenerateExpression(node->p[0],F_ALL,siz1);
			switch(op) {
			case op_addu:	op = op_addui; break;
			case op_add:	op = op_addui; break;
			case op_subu:	op = op_subui; break;
			case op_sub:	op = op_subui; break;
			}
			if (ap1->mode != am_reg) {
				ap2 = GetTempRegister();
				switch(size) {
				case 1:	GenerateTriadic(op_lb,0,ap2,ap1,NULL); break;
				case 2:	GenerateTriadic(op_lc,0,ap2,ap1,NULL); break;
				case 4:	GenerateTriadic(op_lh,0,ap2,ap1,NULL); break;
				case 8:	GenerateTriadic(op_lw,0,ap2,ap1,NULL); break;
				}
	            GenerateTriadic(op,0,ap2,ap2,make_immed(node->i));
				switch(size) {
				case 1:	GenerateTriadic(op_sb,0,ap2,ap1,NULL); break;
				case 2:	GenerateTriadic(op_sc,0,ap2,ap1,NULL); break;
				case 4:	GenerateTriadic(op_sh,0,ap2,ap1,NULL); break;
				case 8:	GenerateTriadic(op_sw,0,ap2,ap1,NULL); break;
				}
				ReleaseTempRegister(ap2);
			}
			else
				GenerateTriadic(op,0,ap1,ap1,make_immed(node->i));
            ReleaseTempRegister(ap1);
            return ap1;
            }
    ap2 = GenerateExpression(node->p[0],F_ALL,siz1);
	if (ap2->mode == am_reg) {
	    GenerateTriadic(op,0,ap2,ap2,make_immed(node->i));
		return ap2;
	}
	else {
	    ap1 = GetTempRegister();
		switch(siz1) {
		case 1:	GenerateDiadic(op_lb,0,ap1,ap2); break;
		case 2:	GenerateDiadic(op_lc,0,ap1,ap2); break;
		case 4:	GenerateDiadic(op_lh,0,ap1,ap2); break;
		case 8:	GenerateDiadic(op_lw,0,ap1,ap2); break;
		}
		switch(op) {
		case op_addu:	op = op_addui; break;
		case op_add:	op = op_addui; break;
		case op_subu:	op = op_subui; break;
		case op_sub:	op = op_subui; break;
		}
		GenerateTriadic(op,0,ap1,ap1,make_immed(node->i));
		switch(siz1) {
		case 1:	GenerateDiadic(op_sb,0,ap1,ap2); break;
		case 2:	GenerateDiadic(op_sc,0,ap1,ap2); break;
		case 4:	GenerateDiadic(op_sh,0,ap1,ap2); break;
		case 8:	GenerateDiadic(op_sw,0,ap1,ap2); break;
		}
	}
    ReleaseTempRegister(ap2);
    GenerateSignExtend(ap1,siz1,size,flags);
    return ap1;
}

/*
 *      general expression evaluation. returns the addressing mode
 *      of the result.
 */
AMODE *GenerateExpression(ENODE *node, int flags, int size)
{   
	AMODE *ap1, *ap2;
    int lab0, lab1;
    int natsize;

    if( node == NULL )
    {
        printf("DIAG - null node in GenerateExpression.\n");
        return NULL;
    }
    switch( node->nodetype )
            {
            case en_icon:
            case en_labcon:
            case en_nacon:
                    ap1 = allocAmode();
                    ap1->mode = am_immed;
                    ap1->offset = node;
                    MakeLegalAmode(ap1,flags,size);
                    return ap1;
            case en_autocon:
                    ap1 = GetTempRegister();
                    ap2 = allocAmode();
                    ap2->mode = am_indx;
                    ap2->preg = 27;          /* frame pointer */
                    ap2->offset = node;     /* use as constant node */
                    GenerateDiadic(op_lea,0,ap1,ap2);
                    MakeLegalAmode(ap1,flags,size);
                    return ap1;             /* return reg */
            case en_b_ref:
			case en_c_ref:
			case en_h_ref:
            case en_ub_ref:
			case en_uc_ref:
			case en_uh_ref:
            case en_w_ref:
			case en_uw_ref:
                    return GenerateDereference(node,flags,size);
			case en_uwfieldref:
			case en_wfieldref:
			case en_bfieldref:
			case en_ubfieldref:
			case en_cfieldref:
			case en_ucfieldref:
			case en_hfieldref:
			case en_uhfieldref:
					return GenerateBitfieldDereference(node,flags,size);
			case en_regvar:
            case en_tempref:
                    ap1 = xalloc(sizeof(struct amode));
                    ap1->mode = am_reg;
                    ap1->preg = node->i;
                    ap1->tempflag = 0;      /* not a temporary */
                    MakeLegalAmode(ap1,flags,size);
                    return ap1;
            case en_uminus: return GenerateUnary(node,flags,size,op_neg);
            case en_compl:  return GenerateUnary(node,flags,size,op_not);
            case en_add:    return GenerateBinary(node,flags,size,op_add);
            case en_sub:    return GenerateBinary(node,flags,size,op_sub);
            case en_and:    return GenerateBinary(node,flags,size,op_and);
            case en_or:     return GenerateBinary(node,flags,size,op_or);
			case en_xor:	return GenerateBinary(node,flags,size,op_xor);
            case en_mul:    return GenerateMultiply(node,flags,size,op_muls);
            case en_mulu:   return GenerateMultiply(node,flags,size,op_mulu);
            case en_div:    return GenerateModDiv(node,flags,size,op_divs);
            case en_udiv:   return GenerateModDiv(node,flags,size,op_divu);
            case en_mod:    return GenerateModDiv(node,flags,size,op_mod);
            case en_umod:   return GenerateModDiv(node,flags,size,op_modu);
            case en_shl:    return GenerateShift(node,flags,size,op_shl);
            case en_shr:	return GenerateShift(node,flags,size,op_shr);
            case en_shru:   return GenerateShift(node,flags,size,op_shru);
            case en_asadd:  return GenerateAssignAdd(node,flags,size,op_add);
            case en_assub:  return GenerateAssignAdd(node,flags,size,op_sub);
            case en_asand:  return GenerateAssignLogic(node,flags,size,op_and);
            case en_asor:   return GenerateAssignLogic(node,flags,size,op_or);
			case en_asxor:  return GenerateAssignLogic(node,flags,size,op_xor);
            case en_aslsh:
                    return GenerateAssignShift(node,flags,size,op_shl);
            case en_asrsh:
                    return GenerateAssignShift(node,flags,size,op_shr);
            case en_asmul: return GenerateAssignMultiply(node,flags,size,op_muls);
            case en_asmulu: return GenerateAssignMultiply(node,flags,size,op_mulu);
            case en_asdiv:
                    return gen_asmodiv(node,flags,size,op_divs);
            case en_asmod:
                    return gen_asmodiv(node,flags,size,op_muls);
            case en_assign:
                    return GenerateAssign(node,flags,size);
            case en_ainc:
                    return GenerateAutoIncrement(node,flags,size,op_add);
            case en_adec:
                    return GenerateAutoIncrement(node,flags,size,op_sub);
            case en_land:   case en_lor:
            case en_eq:     case en_ne:
            case en_lt:     case en_le:
            case en_gt:     case en_ge:
            case en_ult:    case en_ule:
            case en_ugt:    case en_uge:
            case en_not:
                    lab0 = nextlabel++;
                    lab1 = nextlabel++;
                    GenerateFalseJump(node,lab0);
                    ap1 = GetTempRegister();
                    GenerateTriadic(op_ori,0,ap1,makereg(0),make_immed(1));
                    GenerateTriadic(op_bra,0,make_label(lab1),NULL,NULL);
                    GenerateLabel(lab0);
                    GenerateTriadic(op_ori,0,ap1,makereg(0),make_immed(0));
                    GenerateLabel(lab1);
                    return ap1;
            case en_cond:
                    return gen_hook(node,flags,size);
            case en_void:
                    natsize = GetNaturalSize(node->p[0]);
                    ReleaseTempRegister(GenerateExpression(node->p[0],F_ALL | F_NOVALUE,natsize));
                    return GenerateExpression(node->p[1],flags,size);
            case en_fcall:
                    return GenerateFunctionCall(node,flags);
            default:
                    printf("DIAG - uncoded node in GenerateExpression.\n");
                    return 0;
            }
}

/*
 *      return the natural evaluation size of a node.
 */
int GetNaturalSize(ENODE *node)
{ 
	int     siz0, siz1;
    if( node == NULL )
            return 0;
    switch( node->nodetype )
        {
		case en_uwfieldref:
		case en_wfieldref:
			return 8;
		case en_bfieldref:
		case en_ubfieldref:
			return 1;
		case en_cfieldref:
		case en_ucfieldref:
			return 2;
		case en_hfieldref:
		case en_uhfieldref:
			return 4;
        case en_icon:
                if( -128 <= node->i && node->i <= 127 )
                        return 1;
                if( -32768 <= node->i && node->i <= 32767 )
                        return 2;
				if (-2147483648L <= node->i && node->i <= 2147483647L)
					return 4;
				return 8;
        case en_fcall:  case en_labcon:
        case en_nacon:  case en_autocon:
		case en_tempref:
		case en_regvar:
        case en_cbw:
		case en_ccw:
		case en_chw:
                return 8;
		case en_b_ref:
		case en_ub_ref:
                return 1;
        case en_cbc:
		case en_c_ref:	return 2;
		case en_uc_ref:	return 2;
		case en_cbh:	return 4;
		case en_cch:	return 4;
		case en_h_ref:	return 4;
		case en_uh_ref:	return 4;
		case en_w_ref:  case en_uw_ref:
                return 8;
        case en_not:    case en_compl:
        case en_uminus: case en_assign:
        case en_ainc:   case en_adec:
                return GetNaturalSize(node->p[0]);
        case en_add:    case en_sub:
        case en_mul:    case en_div:
        case en_mod:    case en_and:
        case en_or:     case en_xor:
        case en_shl:    case en_shr:	case en_shru:
        case en_eq:     case en_ne:
        case en_lt:     case en_le:
        case en_gt:     case en_ge:
		case en_ult:	case en_ule:
		case en_ugt:	case en_uge:
        case en_land:   case en_lor:
        case en_asadd:  case en_assub:
        case en_asmul:  case en_asdiv:
        case en_asmod:  case en_asand:
		case en_asor:   case en_asxor:	case en_aslsh:
        case en_asrsh:
                siz0 = GetNaturalSize(node->p[0]);
                siz1 = GetNaturalSize(node->p[1]);
                if( siz1 > siz0 )
                    return siz1;
                else
                    return siz0;
        case en_void:   case en_cond:
                return GetNaturalSize(node->p[1]);
        default:
                printf("DIAG - natural size error %d.\n", node->nodetype);
                break;
        }
    return 0;
}


void gen_b(ENODE *node, int op, int label)
{
	int size;
	struct amode *ap1, *ap2;

	size = GetNaturalSize(node);
	ap1 = GenerateExpression(node->p[0],F_REG, size);
	ap2 = GenerateExpression(node->p[1],F_REG|F_IMMED18,size);
    GenerateTriadic(op,0,ap1,ap2,make_label(label));
	ReleaseTempRegister(ap2);
	ReleaseTempRegister(ap1);
}
/*
 *      generate a jump to label if the node passed evaluates to
 *      a true condition.
 */
void GenerateTrueJump(ENODE *node, int label)
{       AMODE  *ap1,*ap2;
        int             siz1;
        int             lab0;
		int size;
        if( node == 0 )
                return;
        switch( node->nodetype )
                {
                case en_eq:	gen_b(node, op_beq, label); break;
                case en_ne: gen_b(node, op_bne, label); break;
                case en_lt: gen_b(node, op_blt, label); break;
                case en_le:	gen_b(node, op_ble, label); break;
                case en_gt: gen_b(node, op_bgt, label); break;
                case en_ge: gen_b(node, op_bge, label); break;
                case en_ult: gen_b(node, op_bltu, label); break;
                case en_ule: gen_b(node, op_bleu, label); break;
                case en_ugt: gen_b(node, op_bgtu, label); break;
                case en_uge: gen_b(node, op_bgeu, label); break;
                case en_land:
                        lab0 = nextlabel++;
                        GenerateFalseJump(node->p[0],lab0);
                        GenerateTrueJump(node->p[1],label);
                        GenerateLabel(lab0);
                        break;
                case en_lor:
                        GenerateTrueJump(node->p[0],label);
                        GenerateTrueJump(node->p[1],label);
                        break;
                case en_not:
                        GenerateFalseJump(node->p[0],label);
                        break;
                default:
                        siz1 = GetNaturalSize(node);
                        ap1 = GenerateExpression(node,F_REG,siz1);
//                        GenerateDiadic(op_tst,siz1,ap1,0);
                        ReleaseTempRegister(ap1);
                        GenerateTriadic(op_bne,0,ap1,makereg(0),make_label(label));
                        break;
                }
}

/*
 *      generate code to execute a jump to label if the expression
 *      passed is false.
 */
void GenerateFalseJump(ENODE *node,int label)
{
	AMODE *ap,*ap1,*ap2;
		int size;
        int             siz1;
        int             lab0;
        if( node == NULL )
                return;
        switch( node->nodetype )
                {
                case en_eq:	gen_b(node, op_bne, label); break;
                case en_ne: gen_b(node, op_beq, label); break;
                case en_lt: gen_b(node, op_bge, label); break;
                case en_le: gen_b(node, op_bgt, label); break;
                case en_gt: gen_b(node, op_ble, label); break;
                case en_ge: gen_b(node, op_blt, label); break;
                case en_ult: gen_b(node, op_bgeu, label); break;
                case en_ule: gen_b(node, op_bgtu, label); break;
                case en_ugt: gen_b(node, op_bleu, label); break;
                case en_uge: gen_b(node, op_bltu, label); break;
                case en_land:
                        GenerateFalseJump(node->p[0],label);
                        GenerateFalseJump(node->p[1],label);
                        break;
                case en_lor:
                        lab0 = nextlabel++;
                        GenerateTrueJump(node->p[0],lab0);
                        GenerateFalseJump(node->p[1],label);
                        GenerateLabel(lab0);
                        break;
                case en_not:
                        GenerateTrueJump(node->p[0],label);
                        break;
                default:
                        siz1 = GetNaturalSize(node);
                        ap = GenerateExpression(node,F_REG,siz1);
//                        GenerateDiadic(op_tst,siz1,ap,0);
                        ReleaseTempRegister(ap);
                        GenerateTriadic(op_beq,0,ap,makereg(0),make_label(label));
                        break;
                }
}

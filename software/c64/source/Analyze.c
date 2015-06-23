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

/*******************************************************
	Modified to support Raptor64 'C64' language
	by Robert Finch
	robfinch@opencores.org
*******************************************************/

extern int popcnt(int m);

/*
 *      this module will step through the parse tree and find all
 *      optimizable expressions. at present these expressions are
 *      limited to expressions that are valid throughout the scope
 *      of the function. the list of optimizable expressions is:
 *
 *              constants
 *              global and static addresses
 *              auto addresses
 *              contents of auto addresses.
 *
 *      contents of auto addresses are valid only if the address is
 *      never referred to without dereferencing.
 *
 *      scan will build a list of optimizable expressions which
 *      opt1 will replace during the second optimization pass.
 */

static CSE *olist;         /* list of optimizable expressions */

/*
 *      equalnode will return 1 if the expressions pointed to by
 *      node1 and node2 are equivalent.
 */
static int equalnode(ENODE *node1, ENODE *node2)
{
//	if( node1 == 0 || node2 == 0 )
//                return 0;
//        if( node1->nodetype != node2->nodetype )
//                return 0;
//        if( (node1->nodetype == en_icon || node1->nodetype == en_labcon ||
//            node1->nodetype == en_nacon || node1->nodetype == en_autocon) &&
//            node1->v.i == node2->v.i )
//                return 1;
//        if( IsLValue(node1) && equalnode(node1->v.p[0], node2->v.p[0]) )
//                return 1;
//        return 0;
//}
    if (node1 == NULL || node2 == NULL)
		return FALSE;
    if (node1->nodetype != node2->nodetype)
		return FALSE;
    switch (node1->nodetype) {
      case en_icon:
      case en_labcon:
      case en_autocon:
			return (node1->i == node2->i);
      case en_nacon:
			return (!strcmp(node1->sp, node2->sp));
      default:
	        if( IsLValue(node1) && equalnode(node1->p[0], node2->p[0])  )
		        return TRUE;
		return FALSE;
    }
}

/*
 *      SearchCSEList will search the common expression table for an entry
 *      that matches the node passed and return a pointer to it.
 */
static CSE *SearchCSEList(ENODE *node)
{
	CSE *csp;

    csp = olist;
    while( csp != NULL ) {
        if( equalnode(node,csp->exp) )
            return csp;
        csp = csp->next;
    }
    return NULL;
}

/*
 *      copy the node passed into a new enode so it wont get
 *      corrupted during substitution.
 */
static ENODE *DuplicateEnode(ENODE *node)
{       
	ENODE *temp;

    if( node == NULL )
        return NULL;
    temp = allocEnode();
	memcpy(temp,node,sizeof(ENODE));	// copy all the fields
    return temp;
}

/*
 *      InsertNodeIntoCSEList will enter a reference to an expression node into the
 *      common expression table. duse is a flag indicating whether or not
 *      this reference will be dereferenced.
 */
CSE *InsertNodeIntoCSEList(ENODE *node, int duse)
{
	CSE *csp;

    if( (csp = SearchCSEList(node)) == NULL ) {   /* add to tree */
        csp = allocCSE();
        csp->next = olist;
        csp->uses = 1;
        csp->duses = (duse != 0);
        csp->exp = DuplicateEnode(node);
        csp->voidf = 0;
		csp->reg = 0;
        olist = csp;
        return csp;
    }
    ++(csp->uses);
    if( duse )
            ++(csp->duses);
    return csp;
}

/*
 *      voidauto will void an auto dereference node which points to
 *      the same auto constant as node.
 */
CSE *voidauto(ENODE *node)
{
	CSE *csp;

	csp = olist;
    while( csp != NULL ) {
        if( IsLValue(csp->exp) && equalnode(node,csp->exp->p[0]) ) {
            if( csp->voidf )
                 return NULL;
            csp->voidf = 1;
            return csp;
        }
        csp = csp->next;
    }
    return NULL;
}

/*
 *      scanexpr will scan the expression pointed to by node for optimizable
 *      subexpressions. when an optimizable expression is found it is entered
 *      into the tree. if a reference to an autocon node is scanned the
 *      corresponding auto dereferenced node will be voided. duse should be
 *      set if the expression will be dereferenced.
 */
static void scanexpr(ENODE *node, int duse)
{
	CSE *csp, *csp1;

    if( node == NULL )
        return;

	switch( node->nodetype ) {
        case en_icon:
        case en_labcon:
        case en_nacon:
                InsertNodeIntoCSEList(node,duse);
                break;
        case en_autocon:
                if( (csp = voidauto(node)) != NULL ) {
                    csp1 = InsertNodeIntoCSEList(node,duse);
                    csp1->uses = (csp1->duses += csp->uses);
                    }
                else
                    InsertNodeIntoCSEList(node,duse);
                break;
        case en_b_ref:
		case en_c_ref:
		case en_h_ref:
        case en_w_ref:
        case en_ub_ref:
		case en_uc_ref:
		case en_uh_ref:
        case en_uw_ref:
		case en_bfieldref:
		case en_ubfieldref:
		case en_cfieldref:
		case en_ucfieldref:
		case en_hfieldref:
		case en_uhfieldref:
		case en_wfieldref:
		case en_uwfieldref:
                if( node->p[0]->nodetype == en_autocon ) {
                        csp = InsertNodeIntoCSEList(node,duse);
                        if( csp->voidf )
                                scanexpr(node->p[0],1);
                        }
                else
                        scanexpr(node->p[0],1);
                break;
        case en_cbc: 
		case en_cbh:
		case en_cbw:
		case en_cch:
		case en_ccw:
		case en_chw:
        case en_uminus:
        case en_compl:  case en_ainc:
        case en_adec:   case en_not:
                scanexpr(node->p[0],duse);
                break;
        case en_asadd:  case en_assub:
        case en_add:    case en_sub:
                scanexpr(node->p[0],duse);
                scanexpr(node->p[1],duse);
                break;
		case en_mul:    case en_mulu:   case en_div:	case en_udiv:
		case en_shl:    case en_shr:	case en_shru:
        case en_mod:    case en_and:
        case en_or:     case en_xor:
        case en_lor:    case en_land:
        case en_eq:     case en_ne:
        case en_gt:     case en_ge:
        case en_lt:     case en_le:
        case en_ugt:    case en_uge:
        case en_ult:    case en_ule:
        case en_asmul:  case en_asdiv:
        case en_asmod:  case en_aslsh:
		case en_asrsh:
		case en_asand:	case en_asxor: case en_asor:
		case en_cond:
        case en_void:   case en_assign:
                scanexpr(node->p[0],0);
                scanexpr(node->p[1],0);
                break;
        case en_fcall:
                scanexpr(node->p[0],1);
                scanexpr(node->p[1],0);
                break;
        }
}

/*
 *      scan will gather all optimizable expressions into the expression
 *      list for a block of statements.
 */
static void scan(Statement *block)
{
	while( block != NULL ) {
        switch( block->stype ) {
            case st_return:
			case st_throw:
            case st_expr:
                    opt4(&block->exp);
                    scanexpr(block->exp,0);
                    break;
            case st_while:
			case st_until:
            case st_do:
			case st_dountil:
                    opt4(&block->exp);
                    scanexpr(block->exp,0);
			case st_doloop:
			case st_forever:
                    scan(block->s1);
                    break;
            case st_for:
                    opt4(&block->initExpr);
                    scanexpr(block->initExpr,0);
                    opt4(&block->exp);
                    scanexpr(block->exp,0);
                    scan(block->s1);
                    opt4(&block->incrExpr);
                    scanexpr(block->incrExpr,0);
                    break;
            case st_if:
                    opt4(&block->exp);
                    scanexpr(block->exp,0);
                    scan(block->s1);
                    scan(block->s2);
                    break;
            case st_switch:
                    opt4(&block->exp);
                    scanexpr(block->exp,0);
                    scan(block->s1);
                    break;
            case st_case:
                    scan(block->s1);
                    break;
            case st_spinlock:
                    scan(block->s1);
                    scan(block->s2);
                    break;
        }
        block = block->next;
    }
}

/*
 *      exchange will exchange the order of two expression entries
 *      following c1 in the linked list.
 */
static void exchange(CSE **c1)
{
	CSE *csp1, *csp2;

    csp1 = *c1;
    csp2 = csp1->next;
    csp1->next = csp2->next;
    csp2->next = csp1;
    *c1 = csp2;
}

/*
 *      returns the desirability of optimization for a subexpression.
 */
int OptimizationDesireability(CSE *csp)
{
	if( csp->voidf || (csp->exp->nodetype == en_icon &&
                       csp->exp->i < 256 && csp->exp->i >= 0))
        return 0;
    if( IsLValue(csp->exp) )
	    return 2 * csp->uses;
    return csp->uses;
}

/*
 *      bsort implements a bubble sort on the expression list.
 */
int bsort(CSE **list)
{
	CSE *csp1, *csp2;
    int i;

    csp1 = *list;
    if( csp1 == NULL || csp1->next == NULL )
        return FALSE;
    i = bsort( &(csp1->next));
    csp2 = csp1->next;
    if( OptimizationDesireability(csp1) < OptimizationDesireability(csp2) ) {
        exchange(list);
        return TRUE;
    }
    return FALSE;
}

/*
 *      AllocateRegisterVars will allocate registers for the expressions that have
 *      a high enough desirability.
 */
void AllocateRegisterVars()
{
	CSE *csp;
    ENODE *exptr;
    int reg, mask, rmask;
    AMODE *ap, *ap2;
	int nn;
	int cnt;

	reg = 11;
    mask = 0;
	rmask = 0;
    while( bsort(&olist) );         /* sort the expression list */
    csp = olist;
    while( csp != NULL ) {
        if( OptimizationDesireability(csp) < 3 )	// was < 3
            csp->reg = -1;
//        else if( csp->duses > csp->uses / 4 && reg < 18 )
        else if( reg < 18 )	// was / 4
            csp->reg = reg++;
        else
            csp->reg = -1;
        if( csp->reg != -1 )
		{
			rmask = rmask | (1 << (31 - csp->reg));
            mask = mask | (1 << csp->reg);
		}
        csp = csp->next;
    }
	if( mask != 0 ) {
		cnt = 0;
		GenerateTriadic(op_subui,0,makereg(30),makereg(30),make_immed(bitsset(rmask)*8));
		for (nn = 0; nn < 32; nn++) {
			if (rmask & (0x80000000 >> nn)) {
				GenerateTriadic(op_sw,0,makereg(nn&31),make_indexed(cnt,30),NULL);
				cnt+=8;
			}
		}
		//else {
		//	GenerateTriadic(op_subui,0,makereg(30),makereg(30),make_immed(popcnt(mask)*8));
  //          GenerateDiadic(op_sm,0,make_indirect(30),make_mask(mask),NULL);
		//}
	}
    save_mask = mask;
    csp = olist;
    while( csp != NULL ) {
            if( csp->reg != -1 )
                    {               /* see if preload needed */
                    exptr = csp->exp;
                    if( !IsLValue(exptr) || (exptr->p[0]->i > 0) )
                            {
                            initstack();
                            ap = GenerateExpression(exptr,F_REG|F_IMMED,8);
                            ap2 = makereg(csp->reg);
							if (ap->mode==am_immed)
								GenerateTriadic(op_ori,0,ap2,makereg(0),ap);
							else
								GenerateDiadic(op_mov,0,ap2,ap);
                            ReleaseTempRegister(ap);
                            }
                    }
            csp = csp->next;
            }
}

/*
 *      repexpr will replace all allocated references within an expression
 *      with tempref nodes.
 */
void repexpr(ENODE *node)
{
	struct cse      *csp;
        if( node == NULL )
                return;
        switch( node->nodetype ) {
                case en_icon:
                case en_nacon:
                case en_labcon:
                case en_autocon:
                        if( (csp = SearchCSEList(node)) != NULL )
                                if( csp->reg > 0 ) {
                                        node->nodetype = en_regvar;
                                        node->i = csp->reg;
                                        }
                        break;
                case en_b_ref:
				case en_c_ref:
				case en_h_ref:
                case en_w_ref:
                case en_ub_ref:
				case en_uc_ref:
				case en_uh_ref:
                case en_uw_ref:
				case en_bfieldref:
				case en_ubfieldref:
				case en_cfieldref:
				case en_ucfieldref:
				case en_hfieldref:
				case en_uhfieldref:
				case en_wfieldref:
				case en_uwfieldref:
                        if( (csp = SearchCSEList(node)) != NULL ) {
                                if( csp->reg > 0 ) {
                                        node->nodetype = en_regvar;
                                        node->i = csp->reg;
                                        }
                                else
                                        repexpr(node->p[0]);
                                }
                        else
                                repexpr(node->p[0]);
                        break;
				case en_cbc:
				case en_cbh:
                case en_cbw:
				case en_cch:
				case en_ccw:
				case en_chw:
                case en_uminus:
                case en_not:    case en_compl:
                case en_ainc:   case en_adec:
                        repexpr(node->p[0]);
                        break;
                case en_add:    case en_sub:
				case en_mul:    case en_mulu:   case en_div:	case en_udiv:
				case en_mod:    case en_shl:	case en_shru:
                case en_shr:    case en_and:
                case en_or:     case en_xor:
                case en_land:   case en_lor:
                case en_eq:     case en_ne:
                case en_lt:     case en_le:
                case en_gt:     case en_ge:
				case en_ult:	case en_ule:
				case en_ugt:	case en_uge:
                case en_cond:   case en_void:
                case en_asadd:  case en_assub:
                case en_asmul:  case en_asdiv:
                case en_asor:   case en_asand:
                case en_asmod:  case en_aslsh:
                case en_asrsh:  case en_fcall:
                case en_assign:
                        repexpr(node->p[0]);
                        repexpr(node->p[1]);
                        break;
                }
}

/*
 *      repcse will scan through a block of statements replacing the
 *      optimized expressions with their temporary references.
 */
void repcse(Statement *block)
{    
	while( block != NULL ) {
        switch( block->stype ) {
			case st_return:
			case st_throw:
					repexpr(block->exp);
					break;
			case st_expr:
					repexpr(block->exp);
					break;
			case st_while:
			case st_until:
			case st_do:
			case st_dountil:
					repexpr(block->exp);
			case st_doloop:
			case st_forever:
					repcse(block->s1);
					repcse(block->s2);
					break;
			case st_for:
					repexpr(block->initExpr);
					repexpr(block->exp);
					repcse(block->s1);
					repexpr(block->incrExpr);
					break;
			case st_if:
					repexpr(block->exp);
					repcse(block->s1);
					repcse(block->s2);
					break;
			case st_switch:
					repexpr(block->exp);
					repcse(block->s1);
					break;
			case st_try:
			case st_catch:
			case st_case:
					repcse(block->s1);
					break;
			case st_spinlock:
					repcse(block->s1);
					repcse(block->s2);	// lockfail statement
					break;
        }
        block = block->next;
    }
}

/*
 *      opt1 is the externally callable optimization routine. it will
 *      collect and allocate common subexpressions and substitute the
 *      tempref for all occurrances of the expression within the block.
 *
 *		optimizer is currently turned off...
 */
void opt1(Statement *block)
{
	olist = NULL;
    scan(block);            /* collect expressions */
    AllocateRegisterVars();             /* allocate registers */
    repcse(block);          /* replace allocated expressions */
}

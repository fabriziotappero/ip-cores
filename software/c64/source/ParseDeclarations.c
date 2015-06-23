#include        <stdio.h>
#include <string.h>
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

TYP             *head = NULL;
TYP             *tail = NULL;
char            *declid = NULL;
TABLE           tagtable = {0,0};
TYP             stdconst = { bt_long, bt_long, 1, FALSE, FALSE, FALSE, 0, 0, 8, {0, 0}, 0, "stdconst"};
char *names[20];
int nparms = 0;
int funcdecl = FALSE;
int catchdecl = FALSE;
int isTypedef = FALSE;
int isUnion = FALSE;
int isUnsigned = FALSE;

/* variable for bit fields */
static int		bit_max;	// largest bitnumber
int bit_offset;	/* the actual offset */
int      bit_width;	/* the actual width */
int bit_next;	/* offset for next variable */

int declbegin(int st);
void dodecl(int defclass);
void ParseDeclarationSuffix();
void declstruct(int ztype);
void structbody(TYP *tp, int ztype);
void ParseEnumDeclaration(TABLE *table);
void enumbody(TABLE *table);

int     imax(int i, int j)
{       return (i > j) ? i : j;
}


char *litlate(char *s)
{
	char    *p;
    p = xalloc(strlen(s) + 1);
    strcpy(p,s);
    return p;
}

TYP *maketype(int bt, int siz)
{
	TYP *tp;
    tp = allocTYP();
    tp->val_flag = 0;
    tp->size = siz;
    tp->type = bt;
	tp->typeno = bt;
    tp->sname = 0;
    tp->lst.head = 0;
    return tp;
}

void ParseSpecifier(TABLE *table)
{
	SYM *sp;

	isUnsigned = FALSE;
	for (;;) {
		switch (lastst) {
			case kw_signed:	// Ignore 'signed'
				NextToken();
				break;
			case kw_typedef:
				isTypedef = TRUE;
				NextToken();
				break;
			case kw_nocall:
				isNocall = TRUE;
				head = tail = maketype(bt_oscall,8);
				NextToken();
				goto lxit;
			case kw_oscall:
				isOscall = TRUE;
				head = tail = maketype(bt_oscall,8);
				NextToken();
				goto lxit;
			case kw_interrupt:
				isInterrupt = TRUE;
				head = tail = maketype(bt_interrupt,8);
				NextToken();
				goto lxit;
			case kw_pascal:
				isPascal = TRUE;
				head = tail = maketype(bt_pascal,8);
				NextToken();
				break;
			case kw_byte:
				head = tail = maketype(bt_byte,1);
				NextToken();
				head->isUnsigned = isUnsigned;
				bit_max = 8;
				goto lxit;
			case kw_char:
				head = tail = maketype(bt_char,2);
				NextToken();
				head->isUnsigned = isUnsigned;
				bit_max = 16;
				goto lxit;
			case kw_short:
				head = tail = maketype(bt_short,4);
				bit_max = 32;
				NextToken();
				if( lastst == kw_int )
					NextToken();
				head->isUnsigned = isUnsigned;
				head->isShort = TRUE;
				goto lxit;
				break;
			case kw_long:	// long, long int
				if (lastst==kw_int) {
					NextToken();
				}
				if (lastst==kw_float)
					head = tail = maketype(bt_double,8);
				else
					head = tail = maketype(bt_long,8);
				NextToken();
				if (lastst==kw_oscall) {
					isOscall = TRUE;
					NextToken();
				}
				if (lastst==kw_nocall) {
					isNocall = TRUE;
					NextToken();
				}
				head->isUnsigned = isUnsigned;
				bit_max = 64;
				goto lxit;
				break;
			case kw_int:
				head = tail = maketype(bt_long,8);
				head->isUnsigned = isUnsigned;
				NextToken();
				if (lastst==kw_oscall) {
					isOscall = TRUE;
					NextToken();
				}
				if (lastst==kw_nocall) {
					isNocall = TRUE;
					NextToken();
				}
				bit_max = 64;
				goto lxit;
				break;
			case kw_unsigned:
				NextToken();
				isUnsigned = TRUE;
				break;
			case id:                /* no type ParseSpecifierarator */
				sp = search(lastid,&gsyms[0]);
				if (sp) {
					if (sp->storage_class==sc_typedef) {
						NextToken();
						head = tail = sp->tp;
					}
					else
						head = tail = sp->tp;
//					head = tail = maketype(bt_long,4);
				}
				else {
					head = tail = maketype(bt_long,8);
					bit_max = 64;
				}
				goto lxit;
				break;
			case kw_float:
				head = tail = maketype(bt_float,4);
				NextToken();
				bit_max = 32;
				goto lxit;
			case kw_double:
				head = tail = maketype(bt_double,8);
				NextToken();
				bit_max = 64;
				goto lxit;
			case kw_void:
				head = tail = maketype(bt_void,0);
				NextToken();
				if (lastst==kw_interrupt) {
					isInterrupt = TRUE;
					NextToken();
				}
				if (lastst==kw_nocall) {
					isNocall = TRUE;
					NextToken();
				}
				bit_max = 0;
				goto lxit;
			case kw_enum:
				NextToken();
				ParseEnumDeclaration(table);
				bit_max = 16;
				goto lxit;
			case kw_struct:
				NextToken();
				ParseStructDeclaration(bt_struct);
				goto lxit;
			case kw_union:
				NextToken();
				ParseStructDeclaration(bt_union);
				goto lxit;
			default:
				goto lxit;
			}
	}
lxit:;
}

void ParseDeclarationPrefix(char isUnion)
{   
	TYP *temp1, *temp2, *temp3, *temp4;
    
	switch (lastst) {
        case id:
                declid = litlate(lastid);
				if (funcdecl==1)
					names[nparms++] = declid;
                NextToken();
				if (lastst == colon) {
					NextToken();
					bit_width = GetIntegerExpression();
					if (isUnion)
						bit_offset = 0;
					else
						bit_offset = bit_next;
					if (bit_width < 0 || bit_width > bit_max) {
						error(ERR_BITFIELD_WIDTH);
						bit_width = 1;
					}
					if (bit_width == 0 || bit_offset + bit_width > bit_max)
						bit_offset = 0;
					bit_next = bit_offset + bit_width;
					break;	// no ParseDeclarationSuffix()
				}
				ParseDeclarationSuffix();
                break;
        case star:
                temp1 = maketype(bt_pointer,8);
                temp1->btp = head;
                head = temp1;
                if(tail == NULL)
                        tail = head;
                NextToken();
                ParseDeclarationPrefix(isUnion);
                break;
        case openpa:
                NextToken();
                temp1 = head;
                temp2 = tail;
                head = tail = NULL;
                ParseDeclarationPrefix(isUnion);
                needpunc(closepa);
                temp3 = head;
                temp4 = tail;
                head = temp1;
                tail = temp2;
                ParseDeclarationSuffix();
                temp4->btp = head;
                if(temp4->type == bt_pointer && temp4->val_flag != 0 && head != NULL)
                    temp4->size *= head->size;
                head = temp3;
                break;
        default:
                ParseDeclarationSuffix();
                break;
        }
}

// Take care of the () or [] trailing part of a ParseSpecifieraration
//
void ParseDeclarationSuffix()
{
	TYP     *temp1;
    switch (lastst) {
    case openbr:
        NextToken();
        temp1 = maketype(bt_pointer,0);
        temp1->val_flag = 1;
        temp1->btp = head;
        if(lastst == closebr) {
                temp1->size = 0;
                NextToken();
                }
        else if(head != NULL) {
                temp1->size = GetIntegerExpression() * head->size;
                needpunc(closebr);
                }
        else {
                temp1->size = GetIntegerExpression();
                needpunc(closebr);
                }
        head = temp1;
        if( tail == NULL)
                tail = head;
        ParseDeclarationSuffix();
        break;
    case openpa:
        NextToken();
        temp1 = maketype(bt_func,0);
        temp1->val_flag = 1;
        temp1->btp = head;
        head = temp1;
        if( lastst == closepa) {
            NextToken();
            temp1->type = bt_ifunc;			// this line wasn't present
            if(lastst == begin)
                temp1->type = bt_ifunc;
        }
        else
            temp1->type = bt_ifunc;
        break;
    }
}

int alignment(TYP *tp)
{
	switch(tp->type) {
	case bt_byte:			return AL_BYTE;
    case bt_char:           return AL_CHAR;
    case bt_short:          return AL_SHORT;
    case bt_long:           return AL_LONG;
    case bt_enum:           return AL_CHAR;
    case bt_pointer:
            if(tp->val_flag)
                return alignment(tp->btp);
            else
				return AL_POINTER;
    case bt_float:          return AL_FLOAT;
    case bt_double:         return AL_DOUBLE;
    case bt_struct:
    case bt_union:          return AL_STRUCT;
    default:                return AL_CHAR;
    }
}

/*
 *      process ParseSpecifierarations of the form:
 *
 *              <type>  <ParseSpecifier>, <ParseSpecifier>...;
 *
 *      leaves the ParseSpecifierarations in the symbol table pointed to by
 *      table and returns the number of bytes declared. al is the
 *      allocation type to assign, ilc is the initial location
 *      counter. if al is sc_member then no initialization will
 *      be processed. ztype should be bt_struct for normal and in
 *      structure ParseSpecifierarations and sc_union for in union ParseSpecifierarations.
 */
int declare(TABLE *table,int al,int ilc,int ztype)
{ 
	SYM *sp, *sp1, *sp2;
    TYP *dhead;
	char stnm[200];

    static long old_nbytes;
    int nbytes;

	nbytes = 0;
    ParseSpecifier(table);
    dhead = head;
    for(;;) {
        declid = 0;
		bit_width = -1;
        ParseDeclarationPrefix(ztype==bt_union);
        if( declid != 0) {      /* otherwise just struct tag... */
            sp = allocSYM();
			sp->name = declid;
            sp->storage_class = al;
			if (bit_width > 0 && bit_offset > 0) {
				// share the storage word with the previously defined field
				nbytes = old_nbytes - ilc;
			}
			old_nbytes = ilc + nbytes;
			if (al != sc_member) {
//							sp->isTypedef = isTypedef;
				if (isTypedef)
					sp->storage_class = sc_typedef;
				isTypedef = FALSE;
			}
            while( (ilc + nbytes) % alignment(head)) {
                if( al != sc_member && al != sc_external && al != sc_auto) {
					dseg();
					GenerateByte(0);
                }
                ++nbytes;
            }
			if( al == sc_static) {
				sp->value.i = nextlabel++;
			}
			else if( ztype == bt_union)
                sp->value.i = ilc;
            else if( al != sc_auto )
                sp->value.i = ilc + nbytes;
            else
                sp->value.i = -(ilc + nbytes + head->size);

			if (bit_width == -1)
				sp->tp = head;
			else {
				sp->tp = allocTYP();
				*(sp->tp) = *head;
				sp->tp->type = bt_bitfield;
				sp->tp->size = head->size;//tp_int.size;
				sp->tp->bit_width = bit_width;
				sp->tp->bit_offset = bit_offset;
			}

            if( 
				(sp->tp->type == bt_func) && 
                    sp->storage_class == sc_global )
                    sp->storage_class = sc_external;
            if(ztype == bt_union)
                    nbytes = imax(nbytes,sp->tp->size);
            else if(al != sc_external)
                    nbytes += sp->tp->size;
            if( sp->tp->type == bt_ifunc && (sp1 = search(sp->name,table)) != 0 &&
                    sp1->tp->type == bt_func )
                    {
                    sp1->tp = sp->tp;
                    sp1->storage_class = sp->storage_class;
//                                sp1->value.i = sp->value.i;
					sp1->IsPrototype = sp->IsPrototype;
                    sp = sp1;
                    }
			else {
				sp2 = search(sp->name,table);
				if (sp2 == NULL)
					insert(sp,table);
				else {
					if (funcdecl==2)
						sp2->tp = sp->tp;
					//else if (!sp2->IsPrototype)
					//	insert(sp,table);
				}
			}
            if( sp->tp->type == bt_ifunc) { /* function body follows */
                ParseFunction(sp);
                return nbytes;
            }
            if( (al == sc_global || al == sc_static) &&
                    sp->tp->type != bt_func && sp->storage_class!=sc_typedef)
                    doinit(sp);
        }
		if (funcdecl==TRUE) {
			if (lastst==comma || lastst==semicolon)
				break;
			if (lastst==closepa)
				goto xit1;
		}
		else if (catchdecl==TRUE) {
			if (lastst==closepa)
				goto xit1;
		}
		else if (lastst == semicolon)
			break;

        needpunc(comma);
        if(declbegin(lastst) == 0)
                break;
        head = dhead;
    }
    NextToken();
xit1:
    return nbytes;
}

int declbegin(int st)
{
	return st == star || st == id || st == openpa || st == openbr; 
}

void ParseGlobalDeclarations()
{
	funcdecl = FALSE;
    for(;;) {
		switch(lastst) {
		case id:
		case kw_interrupt:
		case kw_pascal:
		case kw_nocall:
		case kw_oscall:
		case kw_typedef:
		case kw_byte: case kw_char: case kw_int: case kw_short: case kw_unsigned: case kw_signed:
        case kw_long: case kw_struct: case kw_union:
        case kw_enum: case kw_void:
        case kw_float: case kw_double:
                lc_static += declare(&gsyms,sc_global,lc_static,bt_struct);
				break;
		case kw_register:
				NextToken();
                error(ERR_ILLCLASS);
                lc_static += declare(&gsyms,sc_global,lc_static,bt_struct);
				break;
		case kw_private:
        case kw_static:
                NextToken();
				lc_static += declare(&gsyms,sc_static,lc_static,bt_struct);
                break;
        case kw_extern:
                NextToken();
				if (lastst==kw_pascal) {
					isPascal = TRUE;
					NextToken();
				}
				else if (lastst==kw_oscall || lastst==kw_interrupt || lastst==kw_nocall)
					NextToken();
                ++global_flag;
                declare(&gsyms,sc_external,0,bt_struct);
                --global_flag;
                break;
        default:
                return;
		}
	}
}

void ParseParameterDeclarations(int fd)
{
	funcdecl = fd;
    for(;;) {
		switch(lastst) {
		case kw_interrupt:
		case kw_nocall:
		case kw_oscall:
		case kw_pascal:
		case kw_typedef:
                error(ERR_ILLCLASS);
                declare(&lsyms,sc_auto,0,bt_struct);
				break;
		case id:
		case kw_byte: case kw_char: case kw_int: case kw_short: case kw_unsigned: case kw_signed:
        case kw_long: case kw_struct: case kw_union:
        case kw_enum: case kw_void:
        case kw_float: case kw_double:
                declare(&lsyms,sc_auto,0,bt_struct);
	            break;
        case kw_static:
                NextToken();
                error(ERR_ILLCLASS);
				lc_static += declare(&gsyms,sc_static,lc_static,bt_struct);
				break;
        case kw_extern:
                NextToken();
                error(ERR_ILLCLASS);
				if (lastst==kw_oscall || lastst==kw_interrupt || lastst == kw_nocall)
					NextToken();
                ++global_flag;
                declare(&gsyms,sc_external,0,bt_struct);
                --global_flag;
                break;
        default:
                return;
		}
	}
}


void ParseAutoDeclarations()
{
	SYM *sp;

	funcdecl = FALSE;
    for(;;) {
		switch(lastst) {
		case kw_interrupt:
		case kw_nocall:
		case kw_oscall:
		case kw_pascal:
		case kw_typedef:
                error(ERR_ILLCLASS);
	            lc_auto += declare(&lsyms,sc_auto,lc_auto,bt_struct);
				break;
		case id: //return;
				sp = search(lastid,&gsyms[0]);
				if (sp) {
					if (sp->storage_class==sc_typedef) {
			            lc_auto += declare(&lsyms,sc_auto,lc_auto,bt_struct);
						break;
					}
				}
				return;
        case kw_register:
                NextToken();
		case kw_byte: case kw_char: case kw_int: case kw_short: case kw_unsigned: case kw_signed:
        case kw_long: case kw_struct: case kw_union:
        case kw_enum: case kw_void:
        case kw_float: case kw_double:
            lc_auto += declare(&lsyms,sc_auto,lc_auto,bt_struct);
            break;
        case kw_static:
                NextToken();
				lc_static += declare(&lsyms,sc_static,lc_static,bt_struct);
				break;
        case kw_extern:
                NextToken();
				if (lastst==kw_oscall || lastst==kw_interrupt || lastst == kw_nocall)
					NextToken();
                ++global_flag;
                declare(&gsyms,sc_external,0,bt_struct);
                --global_flag;
                break;
        default:
                return;
		}
	}
}

/*
 *      main compiler routine. this routine parses all of the
 *      ParseSpecifierarations using declare which will call funcbody as
 *      functions are encountered.
 */
void compile()
{
	while(lastst != eof)
	{
        ParseGlobalDeclarations();
        if( lastst != eof)
            NextToken();
    }
    dumplits();
}


#include <stdio.h>
#include <string.h>
#include "c.h"
#include "expr.h"
#include "Statement.h"
#include "gen.h"
#include "cglbdec.h"
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

int InitializeType(TYP *tp);
int InitializeStructure(TYP *tp);
int initbyte();
int initchar();
int initshort();
int initlong();
int InitializePointer();
void endinit();
int InitializeArray(TYP *tp);

void doinit(SYM *sp)
{
	if (sp->storage_class == sc_static || lastst==assign) {
		seg(dataseg);          /* initialize into data segment */
		nl();                   /* start a new line in object */
	}
	else {
		seg(bssseg);            /* initialize into data segment */
		nl();                   /* start a new line in object */
	}
	if(sp->storage_class == sc_static) {
		put_label(sp->value.i);
	}
	else {
		gen_strlab(sp->name);
	}
	if( lastst != assign) {
		genstorage(sp->tp->size);
	}
	else {
		NextToken();
		InitializeType(sp->tp);
	}
    endinit();
}

int InitializeType(TYP *tp)
{   
	int nbytes;

    switch(tp->type) {
	case bt_byte:
			nbytes = initbyte();
			break;
    case bt_char:
    case bt_enum:
            nbytes = initchar();
            break;
    case bt_short:
            nbytes = initshort();
            break;
    case bt_pointer:
            if( tp->val_flag)
                nbytes = InitializeArray(tp);
            else
                nbytes = InitializePointer();
            break;
    case bt_long:
            nbytes = initlong();
            break;
    case bt_struct:
            nbytes = InitializeStructure(tp);
            break;
    default:
        error(ERR_NOINIT);
        nbytes = 0;
    }
    return nbytes;
}

int InitializeArray(TYP *tp)
{     
	int nbytes;
    char *p;

    nbytes = 0;
    if( lastst == begin) {
        NextToken();               /* skip past the brace */
        while(lastst != end) {
            nbytes += InitializeType(tp->btp);
            if( lastst == comma)
                NextToken();
            else if( lastst != end)
                error(ERR_PUNCT);
        }
        NextToken();               /* skip closing brace */
    }
    else if( lastst == sconst && tp->btp->type == bt_char) {
        nbytes = strlen(laststr) * 2 + 2;
        p = laststr;
        while( *p )
            GenerateChar(*p++);
        GenerateChar(0);
        NextToken();
    }
    else if( lastst != semicolon)
        error(ERR_ILLINIT);
    if( nbytes < tp->size) {
        genstorage( tp->size - nbytes);
        nbytes = tp->size;
    }
    else if( tp->size != 0 && nbytes > tp->size)
        error(ERR_INITSIZE);    /* too many initializers */
    return nbytes;
}

int InitializeStructure(TYP *tp)
{
	SYM *sp;
    int nbytes;

    needpunc(begin);
    nbytes = 0;
    sp = tp->lst.head;      /* start at top of symbol table */
    while(sp != 0) {
		while(nbytes < sp->value.i) {     /* align properly */
//                    nbytes += GenerateByte(0);
            GenerateByte(0);
//                    nbytes++;
		}
        nbytes += InitializeType(sp->tp);
        if( lastst == comma)
            NextToken();
        else if(lastst == end)
            break;
        else
            error(ERR_PUNCT);
        sp = sp->next;
    }
    if( nbytes < tp->size)
        genstorage( tp->size - nbytes);
    needpunc(end);
    return tp->size;
}

int initbyte()
{   
	GenerateByte(GetIntegerExpression());
    return 1;
}

int initchar()
{   
	GenerateChar(GetIntegerExpression());
    return 2;
}

int initshort()
{
	GenerateWord(GetIntegerExpression());
    return 4;
}

int initlong()
{
	GenerateLong(GetIntegerExpression());
    return 8;
}

int InitializePointer()
{   
	SYM *sp;

    if(lastst == and) {     /* address of a variable */
        NextToken();
        if( lastst != id)
            error(ERR_IDEXPECT);
		else if( (sp = gsearch(lastid)) == NULL)
            error(ERR_UNDEFINED);
        else {
            NextToken();
            if( lastst == plus || lastst == minus)
                GenerateReference(sp,GetIntegerExpression());
            else
                GenerateReference(sp,0);
            if( sp->storage_class == sc_auto)
                    error(ERR_NOINIT);
        }
    }
    else if(lastst == sconst) {
        GenerateLabelReference(stringlit(laststr));
        NextToken();
    }
    else
        GenerateLong(GetIntegerExpression());
    endinit();
    return 8;       /* pointers are 4 bytes long */
}

void endinit()
{    
	if( lastst != comma && lastst != semicolon && lastst != end) {
		error(ERR_PUNCT);
		while( lastst != comma && lastst != semicolon && lastst != end)
            NextToken();
    }
}

#include        <stdio.h>
#include <string.h>
#include        "c.h"
#include        "expr.h"
#include "Statement.h"
#include        "gen.h"
#include        "cglbdec.h"

/*******************************************************
	Modified to support Raptor64 'C64' language
	by Robert Finch
	robfinch@opencores.org
*******************************************************/

extern TABLE tagtable;
extern TYP *head;
extern TYP stdconst;

void enumbody(TABLE *table);

void ParseEnumDeclaration(TABLE *table)
{   
	SYM *sp;
    TYP     *tp;
    if( lastst == id) {
        if((sp = search(lastid,&tagtable)) == NULL) {
            sp = allocSYM();
            sp->tp = allocTYP();
            sp->tp->type = bt_enum;
            sp->tp->size = 2;
            sp->tp->lst.head = 0;
			sp->tp->btp = 0;
            sp->storage_class = sc_type;
            sp->name = litlate(lastid);
            sp->tp->sname = sp->name;
            NextToken();
            if( lastst != begin)
                    error(ERR_INCOMPLETE);
            else {
				insert(sp,&tagtable);
				NextToken();
				ParseEnumerationList(table);
            }
        }
        else
            NextToken();
        head = sp->tp;
    }
    else {
        tp = allocTYP();	// fix here
        tp->type = bt_short;
        if( lastst != begin)
            error(ERR_INCOMPLETE);
        else {
            NextToken();
            ParseEnumerationList(table);
        }
    head = tp;
    }
}

void ParseEnumerationList(TABLE *table)
{
	int     evalue;
    SYM     *sp;
    evalue = 0;
    while(lastst == id) {
        sp = allocSYM();
        sp->name = litlate(lastid);
        sp->storage_class = sc_const;
        sp->tp = &stdconst;
        insert(sp,table);
        NextToken();
		if (lastst==assign) {
			NextToken();
			sp->value.i = GetIntegerExpression();
			evalue = sp->value.i+1;
		}
		else
			sp->value.i = evalue++;
        if( lastst == comma)
                NextToken();
        else if(lastst != end)
                break;
    }
    needpunc(end);
}


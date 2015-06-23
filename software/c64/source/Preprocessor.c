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
	Copyright 2012	Robert Finch
	Modified to support Raptor64 'C64' language
	by Robert Finch
	robfinch@opencores.org
*******************************************************/

FILE            *inclfile[10];
//int             incldepth = 0;
int             inclline[10];
char            *lptr;
extern char     inpline[132];
int endifCount = 0;
int dodefine();
int doinclude();

int preprocess()
{   
	++lptr;
    lastch = ' ';
    NextToken();               /* get first word on line */
    if( lastst != id ) {
            error(ERR_PREPROC);
            return getline(incldepth == 0);
            }
    if( strcmp(lastid,"include") == 0 )
            return doinclude();
    else if( strcmp(lastid,"define") == 0 )
            return dodefine();
    else if (strcmp(lastid,"ifdef")==0)
			return doifdef();
    else if (strcmp(lastid,"ifndef")==0)
			return doifndef();
    else if (strcmp(lastid,"endif")==0)
			return doendif();
	else
	{
        error(ERR_PREPROC);
        return getline(incldepth == 0);
    }
}

int doinclude()
{
	int     rv;
    NextToken();               /* get file to include */
    if( lastst != sconst ) {
            error(ERR_INCLFILE);
            return getline(incldepth == 0);
            }
    inclline[incldepth] = lineno;
    inclfile[incldepth++] = input;  /* push current input file */
    input = fopen(laststr,"r");
    if( input == 0 ) {
            input = inclfile[--incldepth];
            error(ERR_CANTOPEN);
            rv = getline(incldepth == 0);
            }
    else    {
			_splitpath(laststr,NULL,NULL,nmspace[incldepth],NULL);
            rv = getline(incldepth == 1);
            lineno = -32768;        /* dont list include files */
            }
    return rv;
}

int dodefine()
{   
	SYM     *sp;
    NextToken();               /* get past #define */
    if( lastst != id ) {
            error(ERR_DEFINE);
            return getline(incldepth == 0);
            }
    ++global_flag;          /* always do #define as globals */
    sp = allocSYM();
    sp->name = litlate(lastid);
    sp->value.s = litlate(lptr-1);
    insert(sp,&defsyms);
    --global_flag;
    return getline(incldepth == 0);
}

int doifdef()
{
	SYM *sp;
	int rv;
	char *lne;

	lne = inpline;
	NextToken();
    if( lastst != id ) {
        error(ERR_DEFINE);
        return getline(incldepth == 0);
    }
	endifCount++;
	sp = search(lastid,&defsyms);
	if (sp == NULL) {
		do
			rv = getline(incldepth == 0);
		while (rv==0 && endifCount!=0);
	}
    return getline(incldepth == 0);
}

int doifndef()
{
	SYM *sp;
	int rv;

	NextToken();
    if( lastst != id ) {
        error(ERR_DEFINE);
        return getline(incldepth == 0);
    }
	endifCount++;
	sp = search(lastid,&defsyms);
	if (sp != NULL) {
		do
			rv = getline(incldepth == 0);
		while (rv==0 && endifCount!=0);
	}
    return getline(incldepth == 0);
}

int doendif()
{
	endifCount--;
    return getline(incldepth == 0);
}


#include        <stdio.h>
#include        "c.h"
#include        "expr.h"
#include "Statement.h"
#include        "gen.h"
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

/*      global definitions      */

FILE            *input = 0,
                *list = 0,
                *output = 0;
FILE			*outputG = 0;
int incldepth = 0;
int             lineno = 0;
int             nextlabel = 0;
int             lastch = 0;
int             lastst = 0;
char            lastid[33] = "";
char            laststr[MAX_STRLEN + 1] = "";
__int64			ival = 0;
double          rval = 0.0;

TABLE           gsyms[257],// = {0,0},
	           lsyms = {0,0};
SYM             *lasthead = NULL;
struct slit     *strtab = NULL;
int             lc_static = 0;
int             lc_auto = 0;
struct snode    *bodyptr = 0;
int             global_flag = 1;
TABLE           defsyms = {0,0};
int             save_mask = 0;          /* register save mask */
TYP             tp_int, tp_econst;

int isPascal = FALSE;
int isOscall = FALSE;
int isInterrupt = FALSE;
int isNocall = FALSE;
int optimize = TRUE;
int exceptions = FALSE;
SYM *currentFn = NULL;
int callsFn = FALSE;

char nmspace[20][100];




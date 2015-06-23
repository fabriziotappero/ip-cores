#include        <stdio.h>
#include <string.h>
#include        "c.h"
#include        "expr.h"
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

void makename(char *s, char *e);
void summary();
int options(char *);
int openfiles(char *);
void closefiles();

char            infile[32],
                listfile[32],
                outfile[32],
				outfileG[32];

extern TABLE    tagtable;
int		mainflag;
extern int      total_errors;
int uctran_off;

int main(int argc, char **argv)
{
	uctran_off = 0;
	while(--argc) {
        if( **++argv == '-')
            options(*argv);
        else if( openfiles(*argv)) {
            lineno = 0;
            initsym();
			memset(gsyms,0,sizeof(gsyms));
            getch();
            NextToken();
            compile();
            summary();
            ReleaseGlobalMemory();
            closefiles();
        }
    }
	getchar();
	return 0;
}

int	options(char *s)
{
	optimize =1;
	exceptions=1;
	if (s[1]=='o')
		optimize = 0;
	return 0;
}

int     openfiles(char *s)
{
	int     ofl,oflg;
	int i;
        strcpy(infile,s);
        strcpy(listfile,s);
        strcpy(outfile,s);
		strcpy(outfileG,s);
		_splitpath(s,NULL,NULL,nmspace[0],NULL);
        makename(listfile,".lis");
        makename(outfile,".s");
		makename(outfileG,".sg");
        if( (input = fopen(infile,"r")) == 0) {
                printf(" cant open %s\n",infile);
                return 0;
                }
        ofl = _creat(outfile,-1);
        if( ofl < 0 )
                {
                printf(" cant create %s\n",outfile);
                fclose(input);
                return 0;
                }
        oflg = _creat(outfileG,-1);
        if( oflg < 0 )
                {
                printf(" cant create %s\n",outfileG);
                fclose(input);
                return 0;
                }
        if( (output = _fdopen(ofl,"w")) == 0) {
                printf(" cant open %s\n",outfile);
                fclose(input);
                return 0;
                }
        if( (outputG = _fdopen(oflg,"w")) == 0) {
                printf(" cant open %s\n",outfileG);
                fclose(input);
                fclose(output);
                return 0;
                }
        if( (list = fopen(listfile,"w")) == 0) {
                printf(" cant open %s\n",listfile);
                fclose(input);
                fclose(output);
                fclose(outputG);
                return 0;
                }
        return 1;
}

void makename(char *s, char *e)
{
	while(*s != 0 && *s != '.')
        ++s;
    while(*s++ = *e++);
}

void summary()
{
	printf("\n -- %d errors found.",total_errors);
    fprintf(list,"\f\n *** global scope typedef symbol table ***\n\n");
    ListTable(&gsyms,0);
    fprintf(list,"\n *** structures and unions ***\n\n");
    ListTable(&tagtable,0);
}

void closefiles()
{       
	fclose(input);
    fclose(output);
	fclose(outputG);
    fclose(list);
}

char *GetNamespace()
{
	return nmspace[incldepth];
}

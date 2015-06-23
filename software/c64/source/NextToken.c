#include        <stdio.h>
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
extern char *errtext(int);

int      errno[80];
int      numerrs;
char     inpline[132];
int             total_errors = 0;
char            *lptr;          /* shared with preproc */
FILE            *inclfile[10];  /* shared with preproc */
int             inclline[10];   /* shared with preproc */
int             incldepth;      /* shared with preproc */
char            *linstack[20];  /* stack for substitutions */
char            chstack[20];    /* place to save lastch */
int             lstackptr = 0;  /* substitution stack pointer */

int isalnum(char c)
{       return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
                (c >= '0' && c <= '9');
}

int isidch(char c) { return isalnum(c) || c == '_' || c == '$'; }
int isspace(char c) { return c == ' ' || c == '\t' || c == '\n'; }
int isdigit(char c) { return (c >= '0' && c <= '9'); }

void initsym()
{
	lptr = inpline;
    inpline[0] = 0;
    numerrs = 0;
    total_errors = 0;
    lineno = 0;
}

int getline(int listflag)
{
	int rv;

    if(lineno > 0 && listflag) {
        fprintf(list,"%6d\t%s",lineno,inpline);
        while(numerrs--)
			fprintf(list," *** error %d: %s\n",errno[numerrs],errtext(errno[numerrs]));
        numerrs = 0;
    }
    ++lineno;
    rv = (fgets(inpline,131,input) == NULL);
    if( rv && incldepth > 0 ) {
        fclose(input);
        input = inclfile[--incldepth];
        lineno = inclline[incldepth];
        return getline(0);
    }
    if( rv )
        return 1;
    lptr = inpline;
    if(inpline[0] == '#')
        return preprocess();
    return 0;
}

/*
 *      getch - basic get character routine.
 */
int getch()
{
	while( (lastch = *lptr++) == '\0') {
        if( lstackptr > 0 ) {
            lptr = linstack[--lstackptr];
            lastch = chstack[lstackptr];
            return lastch;
        }
        if(getline(incldepth == 0))
            return lastch = -1;
    }
    return lastch;
}
 
/*
 *      getid - get an identifier.
 *
 *      identifiers are any isidch conglomerate
 *      that doesn't start with a numeric character.
 *      this set INCLUDES keywords.
 */
void getid()
{
	register int    i;
    i = 0;
    while(isidch(lastch)) {
		if(i < 32)
			lastid[i++] = lastch;
		getch();
    }
    lastid[i] = '\0';
    lastst = id;
}
 
/*
 *      getsch - get a character in a quoted string.
 *
 *      this routine handles all of the escape mechanisms
 *      for characters in strings and character constants.
 */
int     getsch()        /* return an in-quote character */
{       register int    i, j;
        if(lastch == '\n')
                return -1;
        if(lastch != '\\') {
                i = lastch;
                getch();
                return i;
                }
        getch();        /* get an escaped character */
        if(isdigit(lastch)) {
                i = 0;
                for(j = i = 0;j < 3;++j) {
                        if(lastch <= '7' && lastch >= '0')
                                i = (i << 3) + lastch - '0';
                        else
                                break;
                        getch();
                        }
                return i;
                }
        i = lastch;
        getch();
        switch(i) {
                case '\n':
                        getch();
                        return getsch();
                case 'b':
                        return '\b';
                case 'f':
                        return '\f';
                case 'n':
                        return '\n';
                case 'r':
                        return '\r';
				case 't':
						return '\t';
                default:
                        return i;
                }
}

__int64 radix36(char c)
{
	if(isdigit(c))
            return c - '0';
    if(c >= 'a' && c <= 'z')
            return c - 'a' + 10;
    if(c >= 'A' && c <= 'Z')
            return c - 'A' + 10;
    return -1;
}
 
/*
 *      getbase - get an integer in any base.
 */
void getbase(b)
{       register __int64 i, j;
        i = 0;
        while(isalnum(lastch)) {
                if((j = radix36(lastch)) < b) {
                        i = i * b + j;
                        getch();
                        }
                else break;
                }
		if (lastch=='L')	// ignore a 'L'ong suffix
			getch();
        ival = i;
        lastst = iconst;
}
 
/*
 *      getfrac - get fraction part of a floating number.
 */
void getfrac()
{       
	double  frmul;
    frmul = 0.1;
    while(isdigit(lastch)) {
        rval += frmul * (lastch - '0');
        getch();
        frmul *= 0.1;
    }
}
 
/*
 *      getexp - get exponent part of floating number.
 *
 *      this algorithm is primative but usefull.  Floating
 *      exponents are limited to +/-255 but most hardware
 *      won't support more anyway.
 */
getexp()
{       double  expo, exmul;
        expo = 1.0;
        if(lastst != rconst)
                rval = ival;
        if(lastch == '-') {
                exmul = 0.1;
                getch();
                }
        else
                exmul = 10.0;
        getbase(10);
        if(ival > 255)
                error(ERR_FPCON);
        else
                while(ival--)
                        expo *= exmul;
        rval *= expo;
}
 
/*
 *      getnum - get a number from input.
 *
 *      getnum handles all of the numeric input. it accepts
 *      decimal, octal, hexidecimal, and floating point numbers.
 */
getnum()
{       register int    i;
        i = 0;
        if(lastch == '0') {
                getch();
                if(lastch == 'x' || lastch == 'X') {
                        getch();
                        getbase(16);
                        }
                else getbase(8);
                }
        else    {
                getbase(10);
                if(lastch == '.') {
                        getch();
                        rval = ival;    /* float the integer part */
                        getfrac();      /* add the fractional part */
                        lastst = rconst;
                        }
                if(lastch == 'e' || lastch == 'E') {
                        getch();
                        getexp();       /* get the exponent */
                        }
                }
}

void SkipSpaces()
{
    while( isspace(lastch) ) 
        getch(); 
}
/*
 *      NextToken - get next symbol from input stream.
 *
 *      NextToken is the basic lexical analyzer.  It builds
 *      basic tokens out of the characters on the input
 *      stream and sets the following global variables:
 *
 *      lastch:         A look behind buffer.
 *      lastst:         type of last symbol read.
 *      laststr:        last string constant read.
 *      lastid:         last identifier read.
 *      ival:           last integer constant read.
 *      rval:           last real constant read.
 *
 *      NextToken should be called for all your input needs...
 */
void NextToken()
{       register int    i, j;
        SYM             *sp;
restart:        /* we come back here after comments */
		SkipSpaces();
        if( lastch == -1)
                lastst = eof;
        else if(isdigit(lastch))
                getnum();
        else if(isidch(lastch)) {
                getid();
                if( (sp = search(lastid,&defsyms)) != NULL ) {
                        linstack[lstackptr] = lptr;
                        chstack[lstackptr++] = lastch;
                        lptr = sp->value.s;
                        getch();
                        goto restart;
                        }
                }
        else switch(lastch) {
                case '+':
                        getch();
                        if(lastch == '+') {
                                getch();
                                lastst = autoinc;
                                }
                        else if(lastch == '=') {
                                getch();
                                lastst = asplus;
                                }
                        else lastst = plus;
                        break;
                case '-':
                        getch();
                        if(lastch == '-') {
                                getch();
                                lastst = autodec;
                                }
                        else if(lastch == '=') {
                                getch();
                                lastst = asminus;
                                }
                        else if(lastch == '>') {
                                getch();
                                lastst = pointsto;
                                }
                        else lastst = minus;
                        break;
                case '*':
                        getch();
                        if(lastch == '=') {
                                getch();
                                lastst = astimes;
                                }
                        else lastst = star;
                        break;
                case '/':
                        getch();
                        if(lastch == '=') {
                                getch();
                                lastst = asdivide;
                                }
                        else if(lastch == '*') {
                                getch();
                                for(;;) {
                                        if(lastch == '*') {
                                                getch();
                                                if(lastch == '/') {
                                                        getch();
                                                        goto restart;
                                                        }
                                                }
                                        else
                                                getch();
                                        }
                                }
						else if (lastch == '/') {
							for(;;) {
								getch();
								if (lastch=='\n') {
									getch();
									goto restart;
								}
							}
						}
                        else lastst = divide;
                        break;
                case '^':
                        getch();
                        lastst = uparrow;
                        break;
                case ';':
                        getch();
                        lastst = semicolon;
                        break;
                case ':':
                        getch();
                        lastst = colon;
                        break;
                case '=':
                        getch();
                        if(lastch == '=') {
                                getch();
                                lastst = eq;
                                }
                        else lastst = assign;
                        break;
                case '>':
                        getch();
                        if(lastch == '=') {
                            getch();
                            lastst = geq;
                        }
                        else if(lastch == '>') {
                            getch();
                            if(lastch == '=') {
                                getch();
                                lastst = asrshift;
                            }
                            else lastst = rshift;
                        }
                        else lastst = gt;
                        break;
                case '<':
                        getch();
                        if(lastch == '=') {
                                getch();
                                lastst = leq;
                                }
                        else if(lastch == '<') {
                                getch();
                                if(lastch == '=') {
                                        getch();
                                        lastst = aslshift;
                                        }
                                else lastst = lshift;
                                }
						else if (lastch == '>') {
							getch();
							lastst = neq;
						}
                        else lastst = lt;
                        break;
                case '\'':
                        getch();
                        ival = getsch();        /* get a string char */
                        if(lastch != '\'')
                                error(ERR_SYNTAX);
                        else
                                getch();
                        lastst = iconst;
                        break;
                case '\"':
                        getch();
                        for(i = 0;i < MAX_STRLEN;++i) {
                                if(lastch == '\"')
                                        break;
                                if((j = getsch()) == -1)
                                        break;
                                else
                                        laststr[i] = j;
                                }
                        laststr[i] = 0;
                        lastst = sconst;
                        if(lastch != '\"')
                                error(ERR_SYNTAX);
                        else
                                getch();
                        break;
                case '!':
                        getch();
                        if(lastch == '=') {
                                getch();
                                lastst = neq;
                                }
                        else lastst = not;
                        break;
                case '%':
                        getch();
                        if(lastch == '=') {
                                getch();
                                lastst = asmodop;
                                }
                        else lastst = modop;
                        break;
                case '~':
                        getch();
                        lastst = compl;
                        break;
                case '.':
                        getch();
                        lastst = dot;
						if (lastch=='.') {
							getch();
							if (lastch=='.')
								getch();
								lastst = ellipsis;
						}
                        break;
                case ',':
                        getch();
                        lastst = comma;
                        break;
                case '&':
                        getch();
                        if( lastch == '&') {
                                lastst = land;
                                getch();
                                }
                        else if( lastch == '=') {
                                lastst = asand;
                                getch();
                                }
                        else
                                lastst = and;
                        break;
                case '|':
                        getch();
                        if(lastch == '|') {
                                lastst = lor;
                                getch();
                                }
                        else if( lastch == '=') {
                                lastst = asor;
                                getch();
                                }
                        else
                                lastst = or;
                        break;
                case '(':
                        getch();
                        lastst = openpa;
                        break;
                case ')':
                        getch();
                        lastst = closepa;
                        break;
                case '[':
                        getch();
                        lastst = openbr;
                        break;
                case ']':
                        getch();
                        lastst = closebr;
                        break;
                case '{':
                        getch();
                        lastst = begin;
                        break;
                case '}':
                        getch();
                        lastst = end;
                        break;
                case '?':
                        getch();
                        lastst = hook;
                        break;
                default:
                        getch();
                        error(ERR_ILLCHAR);
                        goto restart;   /* get a real token */
                }
        if(lastst == id)
                IdentifyKeyword();
}

void needpunc(enum e_sym p)
{
	if( lastst == p)
        NextToken();
    else
        error(ERR_PUNCT);
}


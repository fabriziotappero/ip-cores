/* This file is part of the assembler "spar" for marca.
   Copyright (C) 2007 Wolfgang Puffitsch

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU Library General Public License as published
   by the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA */

%option nounput

%{

#include <stdio.h>
#include <strings.h>

#include "exprs.h"
#include "exprs.tab.h"
#include "spar.h"
#include "symtab.h"

int exprsparse(int64_t *, int64_t *);

static int allow_syms = 1;
static int resolve_syms = 1;
static int localize_syms = 0;
static char *localized_expr = NULL;

#define YY_USER_ACTION \
do { \
  if (localize_syms) { \
    localized_expr = xrealloc(localized_expr, \
                              strlen(localized_expr) \
                              + yyleng + 1); \
    strcat(localized_expr, yytext); \
  } \
} while(0);

%}

BNUM (0b[0-1]+)
ONUM (0[0-7]*)
DNUM ([1-9][0-9]*)
XNUM (0x[0-9a-fA-F]+)
SYM  (\.?[_\.a-zA-Z0-9@]+)

%%

"hi"   return HI;
"lo"   return LO;

"("    return '(';
")"    return ')';

"+"    return '+';
"-"    return '-';
"~"    return '~';
"!"    return '!';
"*"    return '*';
"/"    return '/';
"|/|"  return CUDIV;
"%"    return '%';
"|%|"  return CUMOD;
">>"   return CSHR;
"<<"   return CSHL;
">>>"  return CSLR;
"<"    return '<';
">"    return '>';
"<="   return CLE;
">="   return CGE;
"|<|"  return CULT;
"|>|"  return CUGT;
"|<=|" return CULE;
"|>=|" return CUGE;
"=="   return CEQU;
"!="   return CNEQ;
"&"    return '&';
"^"    return '^';
"|"    return '|';
"&&"   return CLAND;
"||"   return CLOR;
"?"    return '?';
":"    return ':';
"<?"   return CMIN;
">?"   return CMAX;
"|<?|" return CUMIN;
"|>?|" return CUMAX;

{BNUM} {
          exprslval.intval = strtol(yytext+2, NULL, 2);
          return NUM;
       }

{ONUM} {
          exprslval.intval = strtol(yytext, NULL, 8);
          return NUM;
       }

{DNUM} {
          exprslval.intval = strtol(yytext, NULL, 10);
          return NUM;
       }

{XNUM} {
          exprslval.intval = strtol(yytext+2, NULL, 16);
          return NUM;
       }

{SYM}  {
          char *s = yytext;

	  if (localize_syms)
	    {
	      s = localize_string(yytext);
	      localized_expr = xrealloc(localized_expr,
					strlen(localized_expr)
					+ strlen(s)
					- yyleng + 1);
	      strcpy(localized_expr
		     + strlen(localized_expr)
		     - yyleng, s);
	    }
          else if (!allow_syms)
	    {
	      exprslval.intval = 0;
	      fprintf(stderr, "no symbol allowed here: `%s'\n", s);
	      error_count++;
	    }
	  else if (!resolve_syms)
	    {
	      exprslval.intval = 0;
	    }
	  else if (get_sym(s) == NULL)
	    {
	      exprslval.intval = 0;
	      fprintf(stderr, "symbol in expression not found: `%s'\n", s);
	      error_count++;
	    }
	  else
	    {
	      exprslval.intval = get_sym(s)->addr;
	    }

	  return IDENT;
       }

[ \t\r\n]+ { /* ignore whitespace */ }

%%

int yywrap()
{
  return 1;
}

char *expr_localize(const char *expr)
{
  int64_t value = 0;
  int64_t symcount = 0;

  allow_syms = 1;
  resolve_syms = 0;
  localize_syms = 1;
  localized_expr = xmalloc(1);  
  localized_expr[0] = '\0';

  exprs_scan_string(expr);
  exprsparse(&value, &symcount);

  return localized_expr;
}

int64_t expr_symcount(const char *expr)
{
  int64_t value = 0;
  int64_t symcount = 0;

  allow_syms = 1;
  resolve_syms = 0;
  localize_syms = 0;
  localized_expr = NULL;
  
  exprs_scan_string(expr);
  exprsparse(&value, &symcount);

  return symcount;
}

int64_t expr_nevaluate(const char *expr)
{
  int64_t value = 0;
  int64_t symcount = 0;

  allow_syms = 0;
  resolve_syms = 0;
  localize_syms = 0;
  localized_expr = NULL;
    
  exprs_scan_string(expr);
  exprsparse(&value, &symcount);

  return value;
}

int64_t expr_evaluate(const char *expr)
{
  int64_t value = 0;
  int64_t symcount = 0;

  allow_syms = 1;
  resolve_syms = 1;
  localize_syms = 0;
  localized_expr = NULL;
  
  exprs_scan_string(expr);
  exprsparse(&value, &symcount);

  return value;
}

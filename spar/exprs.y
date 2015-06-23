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

%{

#include <stdlib.h>
#include <stdio.h>

#include "exprs.h"

int exprslex(void);
void yyerror(int64_t *, const char *);

%}

%union {
  int64_t intval;
}

%parse-param {
  int64_t *retval, int64_t *symcount
}

%token <intval> NUM IDENT

%token CUMOD CEQU CUGT CSHR CUMIN CLE CNEQ CMIN CLAND
%token CGE CUDIV CUGE CULE CLOR CULT CSHL CMAX CUMAX CSLR
%token HI LO

%type <intval> PrimaryExpr UnaryExpr MultExpr AddExpr ShiftExpr
%type <intval> RelatExpr EqualExpr AndExpr XorExpr OrExpr
%type <intval> LAndExpr LOrExpr CondExpr MinMaxExpr HiLoExpr Expr

%start Expr

%%

PrimaryExpr : NUM 
            { $$ = $1;
	    }
            | IDENT 
            { (*symcount)++;
              $$ = $1;
	    }
            | '(' Expr ')' 
            { $$ = $2;
            }
;

UnaryExpr : PrimaryExpr
          | '+' UnaryExpr
          { $$ = $2;
	  }
          | '-' UnaryExpr
          { $$ = -$2;
	  }
          | '~' UnaryExpr
          { $$ = ~$2;
	  }
          | '!' UnaryExpr
          { $$ = !$2;
	  }
;

MultExpr : UnaryExpr
         | MultExpr '*' UnaryExpr
         { $$ = $1 * $3;
	 }
         | MultExpr '/' UnaryExpr
         {
	   if ($3 == 0)
	     {
	       fprintf(stderr, "division by zero");
	       $$ = 0;
	     }
	   else
	     {
	       $$ = $1 / $3;
	     }
	 }
         | MultExpr CUDIV UnaryExpr
         {
	   if ($3 == 0)
	     {
	       fprintf(stderr, "division by zero");
	       $$ = 0;
	     }
	   else
	     {
	       $$ = (uint64_t)$1 / (uint64_t)$3;
	     }
	 }
         | MultExpr '%' UnaryExpr
         {
	   if ($3 == 0)
	     {
	       fprintf(stderr, "modulo zero");
	       $$ = 0;
	     }
	   else
	     {
	       $$ = $1 % $3;
	     }
	 }
         | MultExpr CUMOD UnaryExpr
         {
	   if ($3 == 0)
	     {
	       fprintf(stderr, "modulo zero");
	       $$ = 0;
	     }
	   else
	     {
	       $$ = (uint64_t)$1 % (uint64_t)$3;
	     }
	 }
;

AddExpr : MultExpr
        | AddExpr '+' MultExpr
        { $$ = $1 + $3;
	}
        | AddExpr '-' MultExpr
        { $$ = $1 - $3;
        }
;

ShiftExpr : AddExpr
          | ShiftExpr CSHR AddExpr
          { $$ = $1 >> $3;
	  }
          | ShiftExpr CSHL AddExpr
          { $$ = $1 << $3;
	  }
          | ShiftExpr CSLR AddExpr
          { $$ = (uint64_t)$1 >> $3;
	  }
;

RelatExpr : ShiftExpr
          | RelatExpr '<' ShiftExpr
          { $$ = $1 < $3;
	  }
          | RelatExpr '>' ShiftExpr
          { $$ = $1 > $3;
	  }
          | RelatExpr CLE ShiftExpr
          { $$ = $1 <= $3;
	  }
          | RelatExpr CGE ShiftExpr
          { $$ = $1 >= $3;
	  }
          | RelatExpr CULT ShiftExpr
          { $$ = (uint64_t)$1 < (uint64_t)$3;
	  }
          | RelatExpr CUGT ShiftExpr
          { $$ = (uint64_t)$1 > (uint64_t)$3;
	  }
          | RelatExpr CULE ShiftExpr
          { $$ = (uint64_t)$1 <= (uint64_t)$3;
	  }
          | RelatExpr CUGE ShiftExpr
          { $$ = (uint64_t)$1 >= (uint64_t)$3;
	  }
;

EqualExpr : RelatExpr
          | EqualExpr CEQU RelatExpr
          { $$ = $1 == $3;
	  }
          | EqualExpr CNEQ RelatExpr
          { $$ = $1 != $3;
	  }
;

AndExpr : EqualExpr
        | AndExpr '&' EqualExpr
        { $$ = $1 & $3;
        }
;

XorExpr : AndExpr
        | XorExpr '^' AndExpr
        { $$ = $1 ^ $3;
        }
;

OrExpr : XorExpr
       | OrExpr '|' XorExpr
       { $$ = $1 | $3;
       }
;

LAndExpr : OrExpr
         | LAndExpr CLAND OrExpr
         { $$ = $1 && $3;
	 }
;

LOrExpr : LAndExpr
        | LOrExpr CLOR LAndExpr
        { $$ = $1 || $3;
        }
;

CondExpr : LOrExpr
         | LOrExpr '?' Expr ':' CondExpr
         { $$ = $1 ? $3 : $5;
	 }
;

MinMaxExpr : CondExpr
           | MinMaxExpr CMIN CondExpr
           { $$ = $1 < $3 ? $1 : $3;
           }
           | MinMaxExpr CMAX CondExpr
           { $$ = $1 > $3 ? $1 : $3;
           }
           | MinMaxExpr CUMIN CondExpr
           { $$ = (uint64_t)$1 < (uint64_t)$3 ? $1 : $3;
           }
           | MinMaxExpr CUMAX CondExpr
           { $$ = (uint64_t)$1 > (uint64_t)$3 ? $1 : $3;
           }
;

HiLoExpr : MinMaxExpr
         | HI '(' MinMaxExpr ')'
         { $$ = ($3 >> 8) & 0xFF;
	 }
         | LO '(' MinMaxExpr ')'
         { $$ = $3 & 0xFF;
	 }

Expr: HiLoExpr
    { *retval = $1;
    }
;

%%

void yyerror(int64_t *r, const char *msg)
{
  fprintf(stderr, "within expression: %s\n", msg);
}


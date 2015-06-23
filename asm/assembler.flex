
D                       [0-9]
L                       [A-Za-z_]
LD			[0-9A-Za-z_]
ID			{L}{LD}*
HX			[0-9A-Fa-f]

%{

#include <assert.h>
#include <stdio.h>
#include <string.h>

class Opcode;
class Operand;
class Expression;

#include "assembler_bison.hh"

void count();
int show_token(int op, const char * txt, YYSTYPE & lval);
#define token(x) show_token(x, yytext, yylval)

%}

%%
";".*			{ count(); return token(EOL  ); }
" "			{ count(); }
"\n"			{ count(); return token(EOL  ); }

".BYTE"			{ count(); return token(_BYTE  ); }
".WORD"			{ count(); return token(_WORD  ); }
".OFFSET"		{ count(); return token(_OFFSET); }
".EXTERN"		{ count(); return token(_EXTERN); }
".STATIC"		{ count(); return token(_STATIC); }
ADD			{ count(); return token(ADD    ); }
AND			{ count(); return token(AND    ); }
CALL			{ count(); return token(CALL   ); }
CLRB			{ count(); return token(CLRB   ); }
CLRW			{ count(); return token(CLRW   ); }
DI			{ count(); return token(DI     ); }
DIV_IS			{ count(); return token(DIV_IS ); }
DIV_IU			{ count(); return token(DIV_IU ); }
EI			{ count(); return token(EI     ); }
HALT			{ count(); return token(HALT   ); }
IN			{ count(); return token(IN     ); }
JMP			{ count(); return token(JMP    ); }
LEA			{ count(); return token(LEA    ); }
LNOT			{ count(); return token(LNOT   ); }
MD_STP			{ count(); return token(MD_STP ); }
MD_FIN			{ count(); return token(MD_FIN ); }
MOD_FIN			{ count(); return token(MOD_FIN); }
MUL_IS			{ count(); return token(MUL_IS ); }
MUL_IU			{ count(); return token(MUL_IU ); }
MOVE			{ count(); return token(MOVE   ); }
NEG			{ count(); return token(NEG    ); }
NOT			{ count(); return token(NOT    ); }
NOP			{ count(); return token(NOP    ); }
OUT			{ count(); return token(OUT    ); }
OR			{ count(); return token(OR     ); }
RET			{ count(); return token(RET    ); }
RETI			{ count(); return token(RETI   ); }
SEQ			{ count(); return token(SEQ    ); }
SGE			{ count(); return token(SGE    ); }
SGT			{ count(); return token(SGT    ); }
SLE			{ count(); return token(SLE    ); }
SLT			{ count(); return token(SLT    ); }
SNE			{ count(); return token(SNE    ); }
SHS			{ count(); return token(SHS    ); }
SHI			{ count(); return token(SHI    ); }
SLS			{ count(); return token(SLS    ); }
SLO			{ count(); return token(SLO    ); }
LSL			{ count(); return token(LSL    ); }
LSR			{ count(); return token(LSR    ); }
ASR			{ count(); return token(ASR    ); }
SUB			{ count(); return token(SUB    ); }
XOR			{ count(); return token(XOR    ); }

RR			{ count(); return token(_RR   );  }
R			{ count(); return token(_R    );  }
RS			{ count(); return token(_RS   );  }
RU			{ count(); return token(_RU   );  }
RRZ			{ count(); return token(_RRZ  );  }
RRNZ			{ count(); return token(_RRNZ );  }

LL			{ count(); return token(_LL   );  }
L			{ count(); return token(_L    );  }
LS			{ count(); return token(_LS   );  }
LU			{ count(); return token(_LU   );  }

SP			{ count(); return token(_SP   );  }

[#,:+=()*/-]		{ count(); return token(*yytext); }

0[xX]{HX}+		{ count();
			  sscanf(yytext + 2, "%X", &yylval._num);
			  return token(INT   ); }

"-"0[xX]{HX}+		{ count();
			  sscanf(yytext + 3, "%X", &yylval._num);
                          yylval._num = -yylval._num;
			  return token(INT   ); }

{D}+			{ count();
			  sscanf(yytext, "%d", &yylval._num);
			  return token(INT   ); }

"-"{D}+			{ count();
			  sscanf(yytext + 1, "%d", &yylval._num);
                          yylval._num = -yylval._num;
			  return token(INT   ); }

{ID}			{ count();   return token(IDENT); }

[ \t\v\n\f]             { count(); }

<<EOF>>			{ return EOFILE;  }
.			{ return ERROR;   }

%%

int yywrap()
{
        return(1);
}

int column = 0;
int row    = 1;

//-----------------------------------------------------------------------------
void count()
{
   for (int i = 0; yytext[i]; i++)
       {
         if (yytext[i] == '\n')        { column = 0;   row++; }
         else if (yytext[i] == '\t')   column += 8 - (column % 8);
         else                          column++;
       }
}
//-----------------------------------------------------------------------------
int yyerror(const char *s)
{
   printf("\n%s Line %d Col %d\n", s, row, column);
   fflush(stdout);
}
//-----------------------------------------------------------------------------
bool did_crlf = false;
bool show_it  = false;

int show_token(int op, const char * txt, YYSTYPE & lval)
{
   if (op == INT)
      {
        did_crlf = false;
        if (show_it)   fprintf(stderr, "Token %3d : %s\n", op, txt);
      }
   else if (op == EOL)
      {
        lval._txt = 0;
        if (!did_crlf && show_it)   fprintf(stderr, "\n");
        did_crlf = true;
      }
   else
      {
        assert(txt);
        did_crlf = false;
        if (show_it)   fprintf(stderr, "Token %3d : %s\n", op, txt);
        char * cp = new char[strlen(txt) + 1];
        strcpy(cp, txt);
        lval._txt = cp;
      }
    return op;
}
//-----------------------------------------------------------------------------

/* -----------------------------------------------------------------------------
 *
 *  SystemC to Verilog Translator v0.4
 *  Provided by Universidad Rey Juan Carlos
 *
 * -----------------------------------------------------------------------------
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */


%{
#include <stdio.h>
#include "y.tab.h"

extern int yylval;
extern FILE* yyin;
extern FILE* yyout;

extern int lineno;

int includefound = 0;
int linecomment = 0;
int multilinecomment = 0;
%}

%%
"void"                              if(!includefound & !linecomment & !multilinecomment) return VOID; else {yylval=(int)strdup(yytext);} return COMMENT;
"true"                              if(!includefound & !linecomment & !multilinecomment) return TTRUE; else {yylval=(int)strdup(yytext);} return COMMENT;
"false"                             if(!includefound & !linecomment & !multilinecomment) return TFALSE; else {yylval=(int)strdup(yytext);} return COMMENT;
[0-9]+                              yylval=atoi(yytext); return NUMBER;
"::"                                if(!includefound & !linecomment & !multilinecomment) return TWODOUBLEPOINTS; else {yylval=(int)strdup(yytext);} return COMMENT;
"int"                               if(!includefound & !linecomment & !multilinecomment) return INTEGER; else {yylval=(int)strdup(yytext);} return COMMENT;
sc_int                              if(!includefound & !linecomment & !multilinecomment) return SC_SIGREG; else {yylval=(int)strdup(yytext);} return COMMENT;
sc_uint                             if(!includefound & !linecomment & !multilinecomment) return SC_REG; else {yylval=(int)strdup(yytext);} return COMMENT;
sc_bigint                           if(!includefound & !linecomment & !multilinecomment) return SC_SIGREG; else {yylval=(int)strdup(yytext);} return COMMENT;
sc_biguint                          if(!includefound & !linecomment & !multilinecomment) return SC_REG; else {yylval=(int)strdup(yytext);} return COMMENT;
bool                                if(!includefound & !linecomment & !multilinecomment) return BOOL; else {yylval=(int)strdup(yytext);} return COMMENT;
">"                                 if(!includefound & !linecomment & !multilinecomment) return BIGGER; else {yylval=(int)strdup(yytext);} return COMMENT;
"<"                                 if(!includefound & !linecomment & !multilinecomment) return LOWER; else {yylval=(int)strdup(yytext);} return COMMENT;
"{"                                 if(!includefound & !linecomment & !multilinecomment) return OPENKEY; else {yylval=(int)strdup(yytext);} return COMMENT;
"}"                                 if(!includefound & !linecomment & !multilinecomment) return CLOSEKEY; else {yylval=(int)strdup(yytext);} return COMMENT;
"("                                 if(!includefound & !linecomment & !multilinecomment) return OPENPAR; else {yylval=(int)strdup(yytext);} return COMMENT;
")"                                 if(!includefound & !linecomment & !multilinecomment) return CLOSEPAR; else {yylval=(int)strdup(yytext);} return COMMENT;
"["                                 if(!includefound & !linecomment & !multilinecomment) return OPENCORCH; else {yylval=(int)strdup(yytext);} return COMMENT;
"]"                                 if(!includefound & !linecomment & !multilinecomment) return CLOSECORCH; else {yylval=(int)strdup(yytext);} return COMMENT;
"return"                            if(!includefound & !linecomment & !multilinecomment) return ENDFUNC; else {yylval=(int)strdup(yytext);} return COMMENT;
".write"                            if(!includefound & !linecomment & !multilinecomment) return WRITE; else {yylval=(int)strdup(yytext);} return COMMENT;
"struct"                            if(!includefound & !linecomment & !multilinecomment) return STRUCT; else {yylval=(int)strdup(yytext);} return COMMENT;
"switch"                            if(!includefound & !linecomment & !multilinecomment) return SWITCH; else {yylval=(int)strdup(yytext);} return COMMENT;
"case"                              if(!includefound & !linecomment & !multilinecomment) return CASE; else {yylval=(int)strdup(yytext);} return COMMENT;
"default"                           if(!includefound & !linecomment & !multilinecomment) return DEFAULT; else {yylval=(int)strdup(yytext);} return COMMENT;
"break"                             if(!includefound & !linecomment & !multilinecomment) return BREAK; else {yylval=(int)strdup(yytext);} return COMMENT;
".read"                             if(!includefound & !linecomment & !multilinecomment) return READ; else {yylval=(int)strdup(yytext);} return COMMENT;
".range"                            if(!includefound & !linecomment & !multilinecomment) return RANGE; else {yylval=(int)strdup(yytext);} return COMMENT;
[a-zA-Z][_a-zA-Z0-9]*               yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return WORD; else return COMMENT;
[:^!%/+*_"&""?""|""\\"]             yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return SYMBOL; else return COMMENT;
"<="                                yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return MINEQ; else return COMMENT;
"="                                 yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return EQUALS; else  return COMMENT;
"++"                                yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return INC; else return COMMENT;
"--"                                yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return DEC; else  return COMMENT;
"-"                                 yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return SYMBOL; else  return COMMENT;
"~"                                 yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return SYMBOL; else  return COMMENT;
"@"                                 yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return SYMBOL; else  return COMMENT;
","                                 yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return COLON; else  return COMMENT;
";"                                 yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return SEMICOLON; else  return COMMENT;
"."                                 yylval=(int)strdup(yytext); if(!includefound & !linecomment & !multilinecomment) return DOT; else  return COMMENT;
[" "]+                              /*Ignore white spaces*/
"\t"                                return TAB; /*Ignore Tab*/
"\n"                                lineno++; if (linecomment) linecomment=0; else if(includefound) includefound=0; return NEWLINE;
"\\\n"                              lineno++; /* no new line */ 
"0x"                                if(!includefound & !linecomment & !multilinecomment) return HEXA; else {yylval=(int)strdup(yytext);} return COMMENT;
"$"                                 if(!includefound & !linecomment & !multilinecomment) return DOLLAR; else {yylval=(int)strdup(yytext);} return COMMENT;/* Ignore if(!includefound & !linecomment & !multilinecomment) $ */
"#define"                           if(!includefound & !linecomment & !multilinecomment) return DEFINE; else {yylval=(int)strdup(yytext);} return COMMENT;
"#include"                          includefound = 1;
"#ifdef"                            if(!includefound & !linecomment & !multilinecomment) return PIFDEF; else {yylval=(int)strdup(yytext);} return COMMENT;
"#ifndef"                           if(!includefound & !linecomment & !multilinecomment) return PIFNDEF; else {yylval=(int)strdup(yytext);} return COMMENT;
"#else"                             if(!includefound & !linecomment & !multilinecomment) return PELSE; else {yylval=(int)strdup(yytext);} return COMMENT;
"#endif"                            if(!includefound & !linecomment & !multilinecomment) return PENDDEF; else {yylval=(int)strdup(yytext);} return COMMENT;
"//"                                if (!multilinecomment) linecomment = 1; yylval=(int)strdup(yytext); return COMMENT;
"/*"                                if (!linecomment) multilinecomment = 1; yylval=(int)strdup(yytext); return COMMENT;
"*/"                                if (multilinecomment) multilinecomment = 0; yylval=(int)strdup(yytext); return COMMENT;

"("[ ]*"sc_uint"[ ]*"<"[ ]*[0-9]+[ ]*">"[ ]*")"
"("[ ]*"sc_biguint"[ ]*"<"[ ]*[0-9]+[ ]*">"[ ]*")"
"("[ ]*"sc_int"[ ]*"<"[ ]*[0-9]+[ ]*">"[ ]*")"
"("[ ]*"sc_bigint"[ ]*"<"[ ]*[0-9]+[ ]*">"[ ]*")"
"("[ ]*"int"[ ]*")"


"//"[ ]*[tT][rR][aA][nN][sS][lL][aA][tT][eE][ ]*[oO][fF][fF]  return TRANSLATEOFF;  /*Translate directive*/
"//"[ ]*[tT][rR][aA][nN][sS][lL][aA][tT][eE][ ]*[oO][nN]      return TRANSLATEON;   /*Translate directive*/
"/*"[ ]*[vV][eE][rR][iI][lL][oO][gG][ ]*[bB][eE][gG][iI][nN]  return VERILOGBEGIN;
[vV][eE][rR][iI][lL][oO][gG][ ]*[eE][nN][dD]"*/"              return VERILOGEND;

%%

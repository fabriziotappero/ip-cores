/* A Bison parser, made by GNU Bison 2.2.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     C = 258,
     OBRA = 259,
     CBRA = 260,
     OSBRA = 261,
     CSBRA = 262,
     NUM = 263,
     IMM = 264,
     LABEL = 265,
     USELAB = 266,
     REG = 267,
     ARI = 268,
     LDI = 269,
     LSI = 270,
     CMP = 271,
     BR = 272,
     SHA = 273,
     JUMP = 274,
     CALL = 275,
     MOV = 276,
     MEM = 277,
     SEL = 278,
     SELI = 279,
     LDL = 280,
     NOP = 281
   };
#endif
/* Tokens.  */
#define C 258
#define OBRA 259
#define CBRA 260
#define OSBRA 261
#define CSBRA 262
#define NUM 263
#define IMM 264
#define LABEL 265
#define USELAB 266
#define REG 267
#define ARI 268
#define LDI 269
#define LSI 270
#define CMP 271
#define BR 272
#define SHA 273
#define JUMP 274
#define CALL 275
#define MOV 276
#define MEM 277
#define SEL 278
#define SELI 279
#define LDL 280
#define NOP 281




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 55 "yacc.in"
{
        int num;
        char *str;
}
/* Line 1528 of yacc.c.  */
#line 106 "yacc.tab.in.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;


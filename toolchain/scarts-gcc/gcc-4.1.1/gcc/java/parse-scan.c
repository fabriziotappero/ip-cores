/* A Bison parser, made by GNU Bison 2.0.  */

/* Skeleton parser for Yacc-like parsing with Bison,
   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004 Free Software Foundation, Inc.

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
   Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

/* Written by Richard Stallman by simplifying the original so called
   ``semantic'' parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 1

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     PLUS_TK = 258,
     MINUS_TK = 259,
     MULT_TK = 260,
     DIV_TK = 261,
     REM_TK = 262,
     LS_TK = 263,
     SRS_TK = 264,
     ZRS_TK = 265,
     AND_TK = 266,
     XOR_TK = 267,
     OR_TK = 268,
     BOOL_AND_TK = 269,
     BOOL_OR_TK = 270,
     EQ_TK = 271,
     NEQ_TK = 272,
     GT_TK = 273,
     GTE_TK = 274,
     LT_TK = 275,
     LTE_TK = 276,
     PLUS_ASSIGN_TK = 277,
     MINUS_ASSIGN_TK = 278,
     MULT_ASSIGN_TK = 279,
     DIV_ASSIGN_TK = 280,
     REM_ASSIGN_TK = 281,
     LS_ASSIGN_TK = 282,
     SRS_ASSIGN_TK = 283,
     ZRS_ASSIGN_TK = 284,
     AND_ASSIGN_TK = 285,
     XOR_ASSIGN_TK = 286,
     OR_ASSIGN_TK = 287,
     PUBLIC_TK = 288,
     PRIVATE_TK = 289,
     PROTECTED_TK = 290,
     STATIC_TK = 291,
     FINAL_TK = 292,
     SYNCHRONIZED_TK = 293,
     VOLATILE_TK = 294,
     TRANSIENT_TK = 295,
     NATIVE_TK = 296,
     PAD_TK = 297,
     ABSTRACT_TK = 298,
     MODIFIER_TK = 299,
     STRICT_TK = 300,
     DECR_TK = 301,
     INCR_TK = 302,
     DEFAULT_TK = 303,
     IF_TK = 304,
     THROW_TK = 305,
     BOOLEAN_TK = 306,
     DO_TK = 307,
     IMPLEMENTS_TK = 308,
     THROWS_TK = 309,
     BREAK_TK = 310,
     IMPORT_TK = 311,
     ELSE_TK = 312,
     INSTANCEOF_TK = 313,
     RETURN_TK = 314,
     VOID_TK = 315,
     CATCH_TK = 316,
     INTERFACE_TK = 317,
     CASE_TK = 318,
     EXTENDS_TK = 319,
     FINALLY_TK = 320,
     SUPER_TK = 321,
     WHILE_TK = 322,
     CLASS_TK = 323,
     SWITCH_TK = 324,
     CONST_TK = 325,
     TRY_TK = 326,
     FOR_TK = 327,
     NEW_TK = 328,
     CONTINUE_TK = 329,
     GOTO_TK = 330,
     PACKAGE_TK = 331,
     THIS_TK = 332,
     ASSERT_TK = 333,
     BYTE_TK = 334,
     SHORT_TK = 335,
     INT_TK = 336,
     LONG_TK = 337,
     CHAR_TK = 338,
     INTEGRAL_TK = 339,
     FLOAT_TK = 340,
     DOUBLE_TK = 341,
     FP_TK = 342,
     ID_TK = 343,
     REL_QM_TK = 344,
     REL_CL_TK = 345,
     NOT_TK = 346,
     NEG_TK = 347,
     ASSIGN_ANY_TK = 348,
     ASSIGN_TK = 349,
     OP_TK = 350,
     CP_TK = 351,
     OCB_TK = 352,
     CCB_TK = 353,
     OSB_TK = 354,
     CSB_TK = 355,
     SC_TK = 356,
     C_TK = 357,
     DOT_TK = 358,
     STRING_LIT_TK = 359,
     CHAR_LIT_TK = 360,
     INT_LIT_TK = 361,
     FP_LIT_TK = 362,
     TRUE_TK = 363,
     FALSE_TK = 364,
     BOOL_LIT_TK = 365,
     NULL_TK = 366
   };
#endif
#define PLUS_TK 258
#define MINUS_TK 259
#define MULT_TK 260
#define DIV_TK 261
#define REM_TK 262
#define LS_TK 263
#define SRS_TK 264
#define ZRS_TK 265
#define AND_TK 266
#define XOR_TK 267
#define OR_TK 268
#define BOOL_AND_TK 269
#define BOOL_OR_TK 270
#define EQ_TK 271
#define NEQ_TK 272
#define GT_TK 273
#define GTE_TK 274
#define LT_TK 275
#define LTE_TK 276
#define PLUS_ASSIGN_TK 277
#define MINUS_ASSIGN_TK 278
#define MULT_ASSIGN_TK 279
#define DIV_ASSIGN_TK 280
#define REM_ASSIGN_TK 281
#define LS_ASSIGN_TK 282
#define SRS_ASSIGN_TK 283
#define ZRS_ASSIGN_TK 284
#define AND_ASSIGN_TK 285
#define XOR_ASSIGN_TK 286
#define OR_ASSIGN_TK 287
#define PUBLIC_TK 288
#define PRIVATE_TK 289
#define PROTECTED_TK 290
#define STATIC_TK 291
#define FINAL_TK 292
#define SYNCHRONIZED_TK 293
#define VOLATILE_TK 294
#define TRANSIENT_TK 295
#define NATIVE_TK 296
#define PAD_TK 297
#define ABSTRACT_TK 298
#define MODIFIER_TK 299
#define STRICT_TK 300
#define DECR_TK 301
#define INCR_TK 302
#define DEFAULT_TK 303
#define IF_TK 304
#define THROW_TK 305
#define BOOLEAN_TK 306
#define DO_TK 307
#define IMPLEMENTS_TK 308
#define THROWS_TK 309
#define BREAK_TK 310
#define IMPORT_TK 311
#define ELSE_TK 312
#define INSTANCEOF_TK 313
#define RETURN_TK 314
#define VOID_TK 315
#define CATCH_TK 316
#define INTERFACE_TK 317
#define CASE_TK 318
#define EXTENDS_TK 319
#define FINALLY_TK 320
#define SUPER_TK 321
#define WHILE_TK 322
#define CLASS_TK 323
#define SWITCH_TK 324
#define CONST_TK 325
#define TRY_TK 326
#define FOR_TK 327
#define NEW_TK 328
#define CONTINUE_TK 329
#define GOTO_TK 330
#define PACKAGE_TK 331
#define THIS_TK 332
#define ASSERT_TK 333
#define BYTE_TK 334
#define SHORT_TK 335
#define INT_TK 336
#define LONG_TK 337
#define CHAR_TK 338
#define INTEGRAL_TK 339
#define FLOAT_TK 340
#define DOUBLE_TK 341
#define FP_TK 342
#define ID_TK 343
#define REL_QM_TK 344
#define REL_CL_TK 345
#define NOT_TK 346
#define NEG_TK 347
#define ASSIGN_ANY_TK 348
#define ASSIGN_TK 349
#define OP_TK 350
#define CP_TK 351
#define OCB_TK 352
#define CCB_TK 353
#define OSB_TK 354
#define CSB_TK 355
#define SC_TK 356
#define C_TK 357
#define DOT_TK 358
#define STRING_LIT_TK 359
#define CHAR_LIT_TK 360
#define INT_LIT_TK 361
#define FP_LIT_TK 362
#define TRUE_TK 363
#define FALSE_TK 364
#define BOOL_LIT_TK 365
#define NULL_TK 366




/* Copy the first part of user declarations.  */
#line 38 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"

#define JC1_LITE

#include "config.h"
#include "system.h"
#include "coretypes.h"
#include "tm.h"
#include "obstack.h"
#include "toplev.h"

extern FILE *finput, *out;
 
 const char *main_input_filename;

/* Obstack for the lexer.  */
struct obstack temporary_obstack;

/* The current parser context.  */
struct parser_ctxt *ctxp;

/* Error and warning counts, because they're used elsewhere  */
int java_error_count;
int java_warning_count;

/* Tweak default rules when necessary.  */
static int absorber;
#define USE_ABSORBER absorber = 0

/* Keep track of the current package name.  */
static const char *package_name;

/* Keep track of whether things have be listed before.  */
static int previous_output;

/* Record modifier uses  */
static int modifier_value;

/* Record (almost) cyclomatic complexity.  */
static int complexity; 

/* Keeps track of number of bracket pairs after a variable declarator
   id.  */
static int bracket_count; 

/* Numbers anonymous classes */
static int anonymous_count;

/* This is used to record the current class context.  */
struct class_context
{
  char *name;
  struct class_context *next;
};

/* The global class context.  */
static struct class_context *current_class_context;

/* A special constant used to represent an anonymous context.  */
static const char *anonymous_context = "ANONYMOUS";

/* Count of method depth.  */
static int method_depth; 

/* Record a method declaration  */
struct method_declarator {
  const char *method_name;
  const char *args;
};
#define NEW_METHOD_DECLARATOR(D,N,A)					     \
{									     \
  (D) = xmalloc (sizeof (struct method_declarator));			     \
  (D)->method_name = (N);						     \
  (D)->args = (A);							     \
}

/* Two actions for this grammar */
static int make_class_name_recursive (struct obstack *stack,
				      struct class_context *ctx);
static char *get_class_name (void);
static void report_class_declaration (const char *);
static void report_main_declaration (struct method_declarator *);
static void push_class_context (const char *);
static void pop_class_context (void);

void report (void); 

#include "lex.h"
#include "parse.h"


/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

#if ! defined (YYSTYPE) && ! defined (YYSTYPE_IS_DECLARED)
#line 128 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
typedef union YYSTYPE {
  char *node;
  struct method_declarator *declarator;
  int value;			/* For modifiers */
} YYSTYPE;
/* Line 190 of yacc.c.  */
#line 394 "java/parse-scan.c"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */
#line 134 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"

extern int flag_assert;

#include "lex.c"


/* Line 213 of yacc.c.  */
#line 411 "java/parse-scan.c"

#if ! defined (yyoverflow) || YYERROR_VERBOSE

# ifndef YYFREE
#  define YYFREE free
# endif
# ifndef YYMALLOC
#  define YYMALLOC malloc
# endif

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   else
#    define YYSTACK_ALLOC alloca
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning. */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
# else
#  if defined (__STDC__) || defined (__cplusplus)
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   define YYSIZE_T size_t
#  endif
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
# endif
#endif /* ! defined (yyoverflow) || YYERROR_VERBOSE */


#if (! defined (yyoverflow) \
     && (! defined (__cplusplus) \
	 || (defined (YYSTYPE_IS_TRIVIAL) && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  short int yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short int) + sizeof (YYSTYPE))			\
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined (__GNUC__) && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  register YYSIZE_T yyi;		\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (0)
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (0)

#endif

#if defined (__STDC__) || defined (__cplusplus)
   typedef signed char yysigned_char;
#else
   typedef short int yysigned_char;
#endif

/* YYFINAL -- State number of the termination state. */
#define YYFINAL  28
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   3393

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  112
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  154
/* YYNRULES -- Number of rules. */
#define YYNRULES  358
/* YYNRULES -- Number of states. */
#define YYNSTATES  617

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   366

#define YYTRANSLATE(YYX) 						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    94,
      95,    96,    97,    98,    99,   100,   101,   102,   103,   104,
     105,   106,   107,   108,   109,   110,   111
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const unsigned short int yyprhs[] =
{
       0,     0,     3,     5,     7,     9,    11,    13,    15,    17,
      19,    21,    23,    25,    27,    29,    31,    33,    35,    37,
      40,    43,    45,    47,    49,    53,    55,    56,    58,    60,
      62,    65,    68,    71,    75,    77,    80,    82,    85,    89,
      91,    93,    97,   103,   105,   107,   109,   111,   114,   115,
     123,   124,   131,   132,   135,   136,   139,   141,   145,   148,
     152,   154,   157,   159,   161,   163,   165,   167,   169,   171,
     173,   175,   179,   184,   186,   190,   192,   196,   198,   202,
     204,   206,   207,   211,   215,   219,   224,   229,   233,   238,
     242,   244,   248,   251,   255,   256,   259,   261,   265,   267,
     269,   272,   274,   278,   283,   288,   294,   298,   303,   306,
     310,   314,   319,   324,   330,   338,   345,   347,   349,   350,
     355,   356,   362,   363,   369,   370,   377,   380,   384,   387,
     391,   393,   396,   398,   400,   402,   404,   406,   408,   411,
     414,   418,   422,   427,   429,   433,   436,   440,   442,   445,
     447,   449,   451,   454,   457,   461,   463,   465,   467,   469,
     471,   473,   475,   477,   479,   481,   483,   485,   487,   489,
     491,   493,   495,   497,   499,   501,   503,   505,   507,   509,
     512,   515,   518,   521,   523,   525,   527,   529,   531,   533,
     535,   541,   549,   557,   563,   566,   570,   574,   579,   581,
     584,   587,   589,   592,   596,   599,   604,   607,   610,   612,
     620,   628,   635,   643,   650,   653,   656,   657,   659,   661,
     662,   664,   666,   670,   673,   677,   680,   684,   687,   691,
     695,   701,   705,   708,   712,   718,   724,   726,   730,   734,
     739,   741,   744,   750,   753,   755,   757,   759,   761,   765,
     767,   769,   771,   773,   775,   779,   783,   787,   791,   795,
     801,   806,   808,   813,   819,   825,   832,   833,   840,   841,
     849,   853,   857,   859,   863,   867,   871,   875,   880,   885,
     890,   895,   897,   900,   904,   907,   911,   915,   919,   923,
     928,   934,   941,   947,   954,   959,   964,   966,   968,   970,
     972,   975,   978,   980,   982,   985,   988,   990,   993,   996,
     998,  1001,  1004,  1006,  1012,  1017,  1022,  1028,  1030,  1034,
    1038,  1042,  1044,  1048,  1052,  1054,  1058,  1062,  1066,  1068,
    1072,  1076,  1080,  1084,  1088,  1090,  1094,  1098,  1100,  1104,
    1106,  1110,  1112,  1116,  1118,  1122,  1124,  1128,  1130,  1136,
    1138,  1140,  1144,  1146,  1148,  1150,  1152,  1154,  1156
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const short int yyrhs[] =
{
     113,     0,    -1,   126,    -1,   106,    -1,   107,    -1,   110,
      -1,   105,    -1,   104,    -1,   111,    -1,   116,    -1,   117,
      -1,    84,    -1,    87,    -1,    51,    -1,   118,    -1,   121,
      -1,   122,    -1,   118,    -1,   118,    -1,   116,   237,    -1,
     122,   237,    -1,   123,    -1,   124,    -1,   125,    -1,   122,
     103,   125,    -1,    88,    -1,    -1,   129,    -1,   127,    -1,
     128,    -1,   129,   127,    -1,   129,   128,    -1,   127,   128,
      -1,   129,   127,   128,    -1,   130,    -1,   127,   130,    -1,
     133,    -1,   128,   133,    -1,    76,   122,   101,    -1,   131,
      -1,   132,    -1,    56,   122,   101,    -1,    56,   122,   103,
       5,   101,    -1,   135,    -1,   166,    -1,   187,    -1,    44,
      -1,   134,    44,    -1,    -1,   134,    68,   125,   138,   139,
     136,   141,    -1,    -1,    68,   125,   138,   139,   137,   141,
      -1,    -1,    64,   119,    -1,    -1,    53,   140,    -1,   120,
      -1,   140,   102,   120,    -1,    97,    98,    -1,    97,   142,
      98,    -1,   143,    -1,   142,   143,    -1,   144,    -1,   159,
      -1,   161,    -1,   179,    -1,   145,    -1,   150,    -1,   135,
      -1,   166,    -1,   187,    -1,   115,   146,   101,    -1,   134,
     115,   146,   101,    -1,   147,    -1,   146,   102,   147,    -1,
     148,    -1,   148,    94,   149,    -1,   125,    -1,   148,    99,
     100,    -1,   264,    -1,   177,    -1,    -1,   152,   151,   158,
      -1,   115,   153,   156,    -1,    60,   153,   156,    -1,   134,
     115,   153,   156,    -1,   134,    60,   153,   156,    -1,   125,
      95,    96,    -1,   125,    95,   154,    96,    -1,   153,    99,
     100,    -1,   155,    -1,   154,   102,   155,    -1,   115,   148,
      -1,   134,   115,   148,    -1,    -1,    54,   157,    -1,   119,
      -1,   157,   102,   119,    -1,   179,    -1,   101,    -1,   160,
     179,    -1,    44,    -1,   162,   156,   163,    -1,   134,   162,
     156,   163,    -1,   162,   156,   163,   101,    -1,   134,   162,
     156,   163,   101,    -1,   123,    95,    96,    -1,   123,    95,
     154,    96,    -1,    97,    98,    -1,    97,   164,    98,    -1,
      97,   180,    98,    -1,    97,   164,   180,    98,    -1,   165,
      95,    96,   101,    -1,   165,    95,   233,    96,   101,    -1,
     122,   103,    66,    95,   233,    96,   101,    -1,   122,   103,
      66,    95,    96,   101,    -1,    77,    -1,    66,    -1,    -1,
      62,   125,   167,   172,    -1,    -1,   134,    62,   125,   168,
     172,    -1,    -1,    62,   125,   171,   169,   172,    -1,    -1,
     134,    62,   125,   171,   170,   172,    -1,    64,   120,    -1,
     171,   102,   120,    -1,    97,    98,    -1,    97,   173,    98,
      -1,   174,    -1,   173,   174,    -1,   175,    -1,   176,    -1,
     135,    -1,   166,    -1,   187,    -1,   145,    -1,   152,   101,
      -1,    97,    98,    -1,    97,   178,    98,    -1,    97,   102,
      98,    -1,    97,   178,   102,    98,    -1,   149,    -1,   178,
     102,   149,    -1,    97,    98,    -1,    97,   180,    98,    -1,
     181,    -1,   180,   181,    -1,   182,    -1,   184,    -1,   135,
      -1,   183,   101,    -1,   115,   146,    -1,   134,   115,   146,
      -1,   186,    -1,   189,    -1,   193,    -1,   194,    -1,   203,
      -1,   207,    -1,   186,    -1,   190,    -1,   195,    -1,   204,
      -1,   208,    -1,   179,    -1,   187,    -1,   191,    -1,   196,
      -1,   206,    -1,   214,    -1,   215,    -1,   216,    -1,   219,
      -1,   217,    -1,   221,    -1,   218,    -1,   101,    -1,   125,
      90,    -1,   188,   184,    -1,   188,   185,    -1,   192,   101,
      -1,   261,    -1,   245,    -1,   246,    -1,   242,    -1,   243,
      -1,   239,    -1,   228,    -1,    49,    95,   264,    96,   184,
      -1,    49,    95,   264,    96,   185,    57,   184,    -1,    49,
      95,   264,    96,   185,    57,   185,    -1,    69,    95,   264,
      96,   197,    -1,    97,    98,    -1,    97,   200,    98,    -1,
      97,   198,    98,    -1,    97,   198,   200,    98,    -1,   199,
      -1,   198,   199,    -1,   200,   180,    -1,   201,    -1,   200,
     201,    -1,    63,   265,    90,    -1,    48,    90,    -1,    67,
      95,   264,    96,    -1,   202,   184,    -1,   202,   185,    -1,
      52,    -1,   205,   184,    67,    95,   264,    96,   101,    -1,
     210,   101,   264,   101,   212,    96,   184,    -1,   210,   101,
     101,   212,    96,   184,    -1,   210,   101,   264,   101,   212,
      96,   185,    -1,   210,   101,   101,   212,    96,   185,    -1,
      72,    95,    -1,   209,   211,    -1,    -1,   213,    -1,   183,
      -1,    -1,   213,    -1,   192,    -1,   213,   102,   192,    -1,
      55,   101,    -1,    55,   125,   101,    -1,    74,   101,    -1,
      74,   125,   101,    -1,    59,   101,    -1,    59,   264,   101,
      -1,    50,   264,   101,    -1,    78,   264,    90,   264,   101,
      -1,    78,   264,   101,    -1,    78,     1,    -1,    78,   264,
       1,    -1,   220,    95,   264,    96,   179,    -1,   220,    95,
     264,    96,     1,    -1,    44,    -1,    71,   179,   222,    -1,
      71,   179,   224,    -1,    71,   179,   222,   224,    -1,   223,
      -1,   222,   223,    -1,    61,    95,   155,    96,   179,    -1,
      65,   179,    -1,   226,    -1,   234,    -1,   114,    -1,    77,
      -1,    95,   264,    96,    -1,   228,    -1,   238,    -1,   239,
      -1,   240,    -1,   227,    -1,   122,   103,    77,    -1,   122,
     103,    68,    -1,   121,   103,    68,    -1,   116,   103,    68,
      -1,    60,   103,    68,    -1,    73,   119,    95,   233,    96,
      -1,    73,   119,    95,    96,    -1,   229,    -1,   232,   125,
      95,    96,    -1,   232,   125,    95,    96,   141,    -1,   232,
     125,    95,   233,    96,    -1,   232,   125,    95,   233,    96,
     141,    -1,    -1,    73,   119,    95,    96,   230,   141,    -1,
      -1,    73,   119,    95,   233,    96,   231,   141,    -1,   122,
     103,    73,    -1,   225,   103,    73,    -1,   264,    -1,   233,
     102,   264,    -1,   233,   102,     1,    -1,    73,   116,   235,
      -1,    73,   118,   235,    -1,    73,   116,   235,   237,    -1,
      73,   118,   235,   237,    -1,    73,   118,   237,   177,    -1,
      73,   116,   237,   177,    -1,   236,    -1,   235,   236,    -1,
      99,   264,   100,    -1,    99,   100,    -1,   237,    99,   100,
      -1,   225,   103,   125,    -1,    66,   103,   125,    -1,   122,
      95,    96,    -1,   122,    95,   233,    96,    -1,   225,   103,
     125,    95,    96,    -1,   225,   103,   125,    95,   233,    96,
      -1,    66,   103,   125,    95,    96,    -1,    66,   103,   125,
      95,   233,    96,    -1,   122,    99,   264,   100,    -1,   226,
      99,   264,   100,    -1,   225,    -1,   122,    -1,   242,    -1,
     243,    -1,   241,    47,    -1,   241,    46,    -1,   245,    -1,
     246,    -1,     3,   244,    -1,     4,   244,    -1,   247,    -1,
      47,   244,    -1,    46,   244,    -1,   241,    -1,    91,   244,
      -1,    92,   244,    -1,   248,    -1,    95,   116,   237,    96,
     244,    -1,    95,   116,    96,   244,    -1,    95,   264,    96,
     247,    -1,    95,   122,   237,    96,   247,    -1,   244,    -1,
     249,     5,   244,    -1,   249,     6,   244,    -1,   249,     7,
     244,    -1,   249,    -1,   250,     3,   249,    -1,   250,     4,
     249,    -1,   250,    -1,   251,     8,   250,    -1,   251,     9,
     250,    -1,   251,    10,   250,    -1,   251,    -1,   252,    20,
     251,    -1,   252,    18,   251,    -1,   252,    21,   251,    -1,
     252,    19,   251,    -1,   252,    58,   117,    -1,   252,    -1,
     253,    16,   252,    -1,   253,    17,   252,    -1,   253,    -1,
     254,    11,   253,    -1,   254,    -1,   255,    12,   254,    -1,
     255,    -1,   256,    13,   255,    -1,   256,    -1,   257,    14,
     256,    -1,   257,    -1,   258,    15,   257,    -1,   258,    -1,
     258,    89,   264,    90,   259,    -1,   259,    -1,   261,    -1,
     262,   263,   260,    -1,   122,    -1,   238,    -1,   240,    -1,
      93,    -1,    94,    -1,   260,    -1,   264,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short int yyrline[] =
{
       0,   208,   208,   213,   214,   215,   216,   217,   218,   223,
     224,   228,   233,   238,   246,   247,   251,   255,   259,   263,
     268,   277,   278,   282,   286,   293,   297,   298,   299,   300,
     301,   302,   303,   304,   308,   309,   313,   314,   318,   323,
     324,   328,   332,   336,   337,   338,   345,   353,   366,   365,
     372,   371,   376,   377,   380,   381,   385,   387,   392,   394,
     399,   400,   404,   405,   406,   407,   411,   412,   413,   414,
     415,   420,   422,   428,   429,   433,   434,   438,   440,   445,
     446,   452,   451,   458,   460,   461,   463,   471,   477,   483,
     487,   488,   495,   510,   526,   527,   531,   533,   538,   539,
     544,   548,   558,   559,   562,   564,   571,   573,   578,   579,
     580,   581,   586,   587,   590,   592,   597,   598,   605,   604,
     608,   607,   611,   610,   614,   613,   619,   620,   624,   626,
     631,   632,   636,   637,   638,   639,   640,   644,   648,   653,
     654,   655,   656,   660,   661,   666,   667,   671,   672,   676,
     677,   678,   682,   686,   688,   693,   694,   695,   696,   697,
     698,   702,   703,   704,   705,   706,   710,   711,   712,   713,
     714,   715,   716,   717,   718,   719,   720,   721,   725,   729,
     734,   738,   744,   748,   749,   750,   751,   752,   753,   754,
     758,   762,   767,   772,   776,   777,   778,   779,   783,   784,
     788,   793,   794,   798,   799,   803,   807,   811,   815,   819,
     824,   825,   829,   830,   834,   838,   840,   841,   842,   845,
     846,   850,   851,   855,   856,   862,   863,   867,   868,   872,
     876,   877,   878,   880,   884,   885,   889,   894,   895,   896,
     900,   901,   905,   909,   914,   915,   919,   920,   921,   922,
     923,   924,   925,   926,   930,   935,   937,   939,   941,   946,
     947,   948,   949,   950,   951,   952,   957,   956,   960,   959,
     965,   967,   971,   972,   973,   977,   978,   979,   980,   983,
     984,   988,   989,   993,   997,   999,  1004,  1005,  1012,  1014,
    1016,  1017,  1018,  1019,  1023,  1025,  1029,  1030,  1032,  1033,
    1037,  1041,  1045,  1046,  1047,  1048,  1049,  1053,  1057,  1061,
    1062,  1063,  1064,  1068,  1069,  1070,  1071,  1075,  1076,  1077,
    1078,  1082,  1083,  1084,  1088,  1089,  1090,  1091,  1095,  1096,
    1097,  1098,  1099,  1100,  1104,  1105,  1106,  1110,  1111,  1115,
    1116,  1120,  1121,  1125,  1126,  1131,  1132,  1137,  1138,  1143,
    1144,  1148,  1152,  1154,  1155,  1159,  1160,  1164,  1168
};
#endif

#if YYDEBUG || YYERROR_VERBOSE
/* YYTNME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals. */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "PLUS_TK", "MINUS_TK", "MULT_TK",
  "DIV_TK", "REM_TK", "LS_TK", "SRS_TK", "ZRS_TK", "AND_TK", "XOR_TK",
  "OR_TK", "BOOL_AND_TK", "BOOL_OR_TK", "EQ_TK", "NEQ_TK", "GT_TK",
  "GTE_TK", "LT_TK", "LTE_TK", "PLUS_ASSIGN_TK", "MINUS_ASSIGN_TK",
  "MULT_ASSIGN_TK", "DIV_ASSIGN_TK", "REM_ASSIGN_TK", "LS_ASSIGN_TK",
  "SRS_ASSIGN_TK", "ZRS_ASSIGN_TK", "AND_ASSIGN_TK", "XOR_ASSIGN_TK",
  "OR_ASSIGN_TK", "PUBLIC_TK", "PRIVATE_TK", "PROTECTED_TK", "STATIC_TK",
  "FINAL_TK", "SYNCHRONIZED_TK", "VOLATILE_TK", "TRANSIENT_TK",
  "NATIVE_TK", "PAD_TK", "ABSTRACT_TK", "MODIFIER_TK", "STRICT_TK",
  "DECR_TK", "INCR_TK", "DEFAULT_TK", "IF_TK", "THROW_TK", "BOOLEAN_TK",
  "DO_TK", "IMPLEMENTS_TK", "THROWS_TK", "BREAK_TK", "IMPORT_TK",
  "ELSE_TK", "INSTANCEOF_TK", "RETURN_TK", "VOID_TK", "CATCH_TK",
  "INTERFACE_TK", "CASE_TK", "EXTENDS_TK", "FINALLY_TK", "SUPER_TK",
  "WHILE_TK", "CLASS_TK", "SWITCH_TK", "CONST_TK", "TRY_TK", "FOR_TK",
  "NEW_TK", "CONTINUE_TK", "GOTO_TK", "PACKAGE_TK", "THIS_TK", "ASSERT_TK",
  "BYTE_TK", "SHORT_TK", "INT_TK", "LONG_TK", "CHAR_TK", "INTEGRAL_TK",
  "FLOAT_TK", "DOUBLE_TK", "FP_TK", "ID_TK", "REL_QM_TK", "REL_CL_TK",
  "NOT_TK", "NEG_TK", "ASSIGN_ANY_TK", "ASSIGN_TK", "OP_TK", "CP_TK",
  "OCB_TK", "CCB_TK", "OSB_TK", "CSB_TK", "SC_TK", "C_TK", "DOT_TK",
  "STRING_LIT_TK", "CHAR_LIT_TK", "INT_LIT_TK", "FP_LIT_TK", "TRUE_TK",
  "FALSE_TK", "BOOL_LIT_TK", "NULL_TK", "$accept", "goal", "literal",
  "type", "primitive_type", "reference_type", "class_or_interface_type",
  "class_type", "interface_type", "array_type", "name", "simple_name",
  "qualified_name", "identifier", "compilation_unit",
  "import_declarations", "type_declarations", "package_declaration",
  "import_declaration", "single_type_import_declaration",
  "type_import_on_demand_declaration", "type_declaration", "modifiers",
  "class_declaration", "@1", "@2", "super", "interfaces",
  "interface_type_list", "class_body", "class_body_declarations",
  "class_body_declaration", "class_member_declaration",
  "field_declaration", "variable_declarators", "variable_declarator",
  "variable_declarator_id", "variable_initializer", "method_declaration",
  "@3", "method_header", "method_declarator", "formal_parameter_list",
  "formal_parameter", "throws", "class_type_list", "method_body",
  "static_initializer", "static", "constructor_declaration",
  "constructor_declarator", "constructor_body",
  "explicit_constructor_invocation", "this_or_super",
  "interface_declaration", "@4", "@5", "@6", "@7", "extends_interfaces",
  "interface_body", "interface_member_declarations",
  "interface_member_declaration", "constant_declaration",
  "abstract_method_declaration", "array_initializer",
  "variable_initializers", "block", "block_statements", "block_statement",
  "local_variable_declaration_statement", "local_variable_declaration",
  "statement", "statement_nsi", "statement_without_trailing_substatement",
  "empty_statement", "label_decl", "labeled_statement",
  "labeled_statement_nsi", "expression_statement", "statement_expression",
  "if_then_statement", "if_then_else_statement",
  "if_then_else_statement_nsi", "switch_statement", "switch_block",
  "switch_block_statement_groups", "switch_block_statement_group",
  "switch_labels", "switch_label", "while_expression", "while_statement",
  "while_statement_nsi", "do_statement_begin", "do_statement",
  "for_statement", "for_statement_nsi", "for_header", "for_begin",
  "for_init", "for_update", "statement_expression_list", "break_statement",
  "continue_statement", "return_statement", "throw_statement",
  "assert_statement", "synchronized_statement", "synchronized",
  "try_statement", "catches", "catch_clause", "finally", "primary",
  "primary_no_new_array", "type_literals",
  "class_instance_creation_expression", "anonymous_class_creation", "@8",
  "@9", "something_dot_new", "argument_list", "array_creation_expression",
  "dim_exprs", "dim_expr", "dims", "field_access", "method_invocation",
  "array_access", "postfix_expression", "post_increment_expression",
  "post_decrement_expression", "unary_expression",
  "pre_increment_expression", "pre_decrement_expression",
  "unary_expression_not_plus_minus", "cast_expression",
  "multiplicative_expression", "additive_expression", "shift_expression",
  "relational_expression", "equality_expression", "and_expression",
  "exclusive_or_expression", "inclusive_or_expression",
  "conditional_and_expression", "conditional_or_expression",
  "conditional_expression", "assignment_expression", "assignment",
  "left_hand_side", "assignment_operator", "expression",
  "constant_expression", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const unsigned short int yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   313,   314,
     315,   316,   317,   318,   319,   320,   321,   322,   323,   324,
     325,   326,   327,   328,   329,   330,   331,   332,   333,   334,
     335,   336,   337,   338,   339,   340,   341,   342,   343,   344,
     345,   346,   347,   348,   349,   350,   351,   352,   353,   354,
     355,   356,   357,   358,   359,   360,   361,   362,   363,   364,
     365,   366
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned short int yyr1[] =
{
       0,   112,   113,   114,   114,   114,   114,   114,   114,   115,
     115,   116,   116,   116,   117,   117,   118,   119,   120,   121,
     121,   122,   122,   123,   124,   125,   126,   126,   126,   126,
     126,   126,   126,   126,   127,   127,   128,   128,   129,   130,
     130,   131,   132,   133,   133,   133,   134,   134,   136,   135,
     137,   135,   138,   138,   139,   139,   140,   140,   141,   141,
     142,   142,   143,   143,   143,   143,   144,   144,   144,   144,
     144,   145,   145,   146,   146,   147,   147,   148,   148,   149,
     149,   151,   150,   152,   152,   152,   152,   153,   153,   153,
     154,   154,   155,   155,   156,   156,   157,   157,   158,   158,
     159,   160,   161,   161,   161,   161,   162,   162,   163,   163,
     163,   163,   164,   164,   164,   164,   165,   165,   167,   166,
     168,   166,   169,   166,   170,   166,   171,   171,   172,   172,
     173,   173,   174,   174,   174,   174,   174,   175,   176,   177,
     177,   177,   177,   178,   178,   179,   179,   180,   180,   181,
     181,   181,   182,   183,   183,   184,   184,   184,   184,   184,
     184,   185,   185,   185,   185,   185,   186,   186,   186,   186,
     186,   186,   186,   186,   186,   186,   186,   186,   187,   188,
     189,   190,   191,   192,   192,   192,   192,   192,   192,   192,
     193,   194,   195,   196,   197,   197,   197,   197,   198,   198,
     199,   200,   200,   201,   201,   202,   203,   204,   205,   206,
     207,   207,   208,   208,   209,   210,   211,   211,   211,   212,
     212,   213,   213,   214,   214,   215,   215,   216,   216,   217,
     218,   218,   218,   218,   219,   219,   220,   221,   221,   221,
     222,   222,   223,   224,   225,   225,   226,   226,   226,   226,
     226,   226,   226,   226,   226,   227,   227,   227,   227,   228,
     228,   228,   228,   228,   228,   228,   230,   229,   231,   229,
     232,   232,   233,   233,   233,   234,   234,   234,   234,   234,
     234,   235,   235,   236,   237,   237,   238,   238,   239,   239,
     239,   239,   239,   239,   240,   240,   241,   241,   241,   241,
     242,   243,   244,   244,   244,   244,   244,   245,   246,   247,
     247,   247,   247,   248,   248,   248,   248,   249,   249,   249,
     249,   250,   250,   250,   251,   251,   251,   251,   252,   252,
     252,   252,   252,   252,   253,   253,   253,   254,   254,   255,
     255,   256,   256,   257,   257,   258,   258,   259,   259,   260,
     260,   261,   262,   262,   262,   263,   263,   264,   265
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const unsigned char yyr2[] =
{
       0,     2,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     2,
       2,     1,     1,     1,     3,     1,     0,     1,     1,     1,
       2,     2,     2,     3,     1,     2,     1,     2,     3,     1,
       1,     3,     5,     1,     1,     1,     1,     2,     0,     7,
       0,     6,     0,     2,     0,     2,     1,     3,     2,     3,
       1,     2,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     3,     4,     1,     3,     1,     3,     1,     3,     1,
       1,     0,     3,     3,     3,     4,     4,     3,     4,     3,
       1,     3,     2,     3,     0,     2,     1,     3,     1,     1,
       2,     1,     3,     4,     4,     5,     3,     4,     2,     3,
       3,     4,     4,     5,     7,     6,     1,     1,     0,     4,
       0,     5,     0,     5,     0,     6,     2,     3,     2,     3,
       1,     2,     1,     1,     1,     1,     1,     1,     2,     2,
       3,     3,     4,     1,     3,     2,     3,     1,     2,     1,
       1,     1,     2,     2,     3,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     2,
       2,     2,     2,     1,     1,     1,     1,     1,     1,     1,
       5,     7,     7,     5,     2,     3,     3,     4,     1,     2,
       2,     1,     2,     3,     2,     4,     2,     2,     1,     7,
       7,     6,     7,     6,     2,     2,     0,     1,     1,     0,
       1,     1,     3,     2,     3,     2,     3,     2,     3,     3,
       5,     3,     2,     3,     5,     5,     1,     3,     3,     4,
       1,     2,     5,     2,     1,     1,     1,     1,     3,     1,
       1,     1,     1,     1,     3,     3,     3,     3,     3,     5,
       4,     1,     4,     5,     5,     6,     0,     6,     0,     7,
       3,     3,     1,     3,     3,     3,     3,     4,     4,     4,
       4,     1,     2,     3,     2,     3,     3,     3,     3,     4,
       5,     6,     5,     6,     4,     4,     1,     1,     1,     1,
       2,     2,     1,     1,     2,     2,     1,     2,     2,     1,
       2,     2,     1,     5,     4,     4,     5,     1,     3,     3,
       3,     1,     3,     3,     1,     3,     3,     3,     1,     3,
       3,     3,     3,     3,     1,     3,     3,     1,     3,     1,
       3,     1,     3,     1,     3,     1,     3,     1,     5,     1,
       1,     3,     1,     1,     1,     1,     1,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned short int yydefact[] =
{
      26,    46,     0,     0,     0,     0,   178,     0,     2,    28,
      29,    27,    34,    39,    40,    36,     0,    43,    44,    45,
      25,     0,    21,    22,    23,   118,    52,     0,     1,    32,
      35,    37,    30,    31,    47,     0,     0,    41,     0,     0,
       0,   122,     0,    54,    38,     0,    33,   120,    52,     0,
      24,    18,   126,    16,     0,   119,     0,     0,    17,    53,
       0,    50,     0,   124,    54,    42,    13,     0,    11,    12,
     128,     0,     9,    10,    14,    15,    16,     0,   134,   137,
       0,   135,     0,   130,   132,   133,   136,   127,   123,    56,
      55,     0,   121,     0,    48,     0,    94,    77,     0,    73,
      75,    94,     0,    19,    20,     0,     0,   138,   129,   131,
       0,     0,    51,   125,     0,     0,     0,     0,    84,    71,
       0,     0,     0,    83,   284,     0,    94,     0,    94,    57,
      46,     0,    58,    21,     0,    68,     0,    60,    62,    66,
      67,    81,    63,     0,    64,    94,    69,    65,    70,    49,
      87,     0,     0,     0,    90,    96,    95,    89,    77,    74,
       0,     0,     0,     0,     0,     0,     0,   247,     0,     0,
       0,     0,     7,     6,     3,     4,     5,     8,   246,     0,
       0,   297,    76,    80,   296,   244,   253,   249,   261,     0,
     245,   250,   251,   252,   309,   298,   299,   317,   302,   303,
     306,   312,   321,   324,   328,   334,   337,   339,   341,   343,
     345,   347,   349,   357,   350,     0,    79,    78,   285,    86,
      72,    85,    46,     0,     0,   208,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   145,     0,     9,    15,   297,
      23,     0,   151,   166,     0,   147,   149,     0,   150,   155,
     167,     0,   156,   168,     0,   157,   158,   169,     0,   159,
       0,   170,   160,   216,     0,   171,   172,   173,   175,   177,
     174,     0,   176,   249,   251,     0,   186,   187,   184,   185,
     183,     0,    94,    59,    61,     0,   100,     0,    92,     0,
      88,     0,     0,   297,   250,   252,   304,   305,   308,   307,
       0,     0,     0,    17,     0,   310,   311,     0,   297,     0,
     139,     0,   143,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   301,   300,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   355,   356,     0,     0,     0,
     223,     0,   227,     0,     0,     0,     0,   214,   225,     0,
     232,     0,     0,   153,   179,     0,   146,   148,   152,   236,
     180,   182,   206,     0,     0,   218,   221,   215,   217,     0,
       0,   106,     0,     0,    99,    82,    98,     0,   102,    93,
      91,    97,   258,   287,     0,   275,   281,     0,   276,     0,
       0,     0,    19,    20,   248,   141,   140,     0,   257,   256,
     288,     0,   272,     0,   255,   270,   254,   271,   286,     0,
       0,   318,   319,   320,   322,   323,   325,   326,   327,   330,
     332,   329,   331,     0,   333,   335,   336,   338,   340,   342,
     344,   346,     0,   351,     0,   229,   224,   228,     0,     0,
       0,     0,   237,   240,   238,   226,   233,     0,   231,   248,
     154,     0,     0,   219,     0,     0,   107,   103,   117,   247,
     108,   297,     0,     0,     0,   104,     0,     0,   282,   277,
     280,   278,   279,   260,     0,   314,     0,     0,   315,   142,
     144,   289,     0,   294,     0,   295,   262,     0,     0,     0,
     205,     0,     0,   243,   241,   239,     0,     0,   222,     0,
     220,   219,     0,   105,     0,   109,     0,     0,   110,   292,
       0,   283,     0,   259,   313,   316,   274,   273,   290,     0,
     263,   264,   348,     0,   190,     0,   155,     0,   162,   163,
       0,   164,   165,     0,     0,   193,     0,   230,     0,     0,
       0,   235,   234,     0,   111,     0,     0,   293,   267,     0,
     291,   265,     0,     0,   181,   207,     0,     0,     0,   194,
       0,   198,     0,   201,     0,     0,   211,     0,     0,   112,
       0,   269,     0,   191,   219,     0,   204,   358,     0,   196,
     199,     0,   195,   200,   202,   242,   209,   210,     0,     0,
     113,     0,     0,   219,   203,   197,   115,     0,     0,     0,
       0,   114,     0,   213,     0,   192,   212
};

/* YYDEFGOTO[NTERM-NUM]. */
static const short int yydefgoto[] =
{
      -1,     7,   178,   236,   179,    73,    74,    59,    52,   180,
     181,    22,    23,    24,     8,     9,    10,    11,    12,    13,
      14,    15,   241,   242,   114,    91,    43,    61,    90,   112,
     136,   137,   138,    79,    98,    99,   100,   182,   140,   285,
      80,    96,   153,   154,   118,   156,   385,   142,   143,   144,
     145,   388,   472,   473,    18,    40,    62,    57,    93,    41,
      55,    82,    83,    84,    85,   183,   313,   243,   593,   245,
     246,   247,   248,   535,   249,   250,   251,   252,   538,   253,
     254,   255,   256,   539,   257,   545,   570,   571,   572,   573,
     258,   259,   541,   260,   261,   262,   542,   263,   264,   377,
     509,   510,   265,   266,   267,   268,   269,   270,   271,   272,
     452,   453,   454,   184,   185,   186,   187,   188,   522,   559,
     189,   411,   190,   395,   396,   104,   191,   192,   193,   194,
     195,   196,   197,   198,   199,   200,   201,   202,   203,   204,
     205,   206,   207,   208,   209,   210,   211,   212,   213,   214,
     215,   347,   412,   588
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -513
static const short int yypact[] =
{
     280,  -513,   -68,   -68,   -68,   -68,  -513,    27,  -513,   108,
     105,   108,  -513,  -513,  -513,  -513,   112,  -513,  -513,  -513,
    -513,   -54,  -513,  -513,  -513,    13,    45,   115,  -513,   105,
    -513,  -513,   108,   105,  -513,   -68,   -68,  -513,     5,   -68,
      42,    18,   -68,    72,  -513,   -68,   105,    13,    45,   165,
    -513,  -513,  -513,   148,   346,  -513,   -68,    42,  -513,  -513,
     -68,  -513,    42,    18,    72,  -513,  -513,   -68,  -513,  -513,
    -513,   -68,   169,  -513,  -513,  -513,    66,   624,  -513,  -513,
     186,  -513,   457,  -513,  -513,  -513,  -513,  -513,  -513,  -513,
     179,   206,  -513,    42,  -513,   235,   -28,   235,   -64,  -513,
     121,   -28,   205,   269,   269,   -68,   -68,  -513,  -513,  -513,
     -68,   295,  -513,  -513,   206,   147,   -68,   303,  -513,  -513,
     -68,  1758,   327,  -513,  -513,   329,   -28,   136,   -28,  -513,
     304,  2670,  -513,   321,   624,  -513,   402,  -513,  -513,  -513,
    -513,  -513,  -513,   339,  -513,   385,  -513,  -513,  -513,  -513,
    -513,   -68,   323,    17,  -513,  -513,   340,  -513,  -513,  -513,
    2466,  2466,  2466,  2466,   342,   345,   185,  -513,  2466,  2466,
    2466,  1626,  -513,  -513,  -513,  -513,  -513,  -513,  -513,    78,
     353,   399,  -513,  -513,   360,   369,  -513,  -513,  -513,   -68,
    -513,   445,  -513,   455,   414,  -513,  -513,  -513,  -513,  -513,
    -513,  -513,   316,   512,   351,   259,   549,   474,   462,   475,
     477,    16,  -513,  -513,  -513,   490,  -513,  -513,  -513,  -513,
    -513,  -513,   400,   409,  2466,  -513,    99,  1810,   417,   427,
     339,   434,   109,  1460,  2466,  -513,   -68,    78,   353,   469,
     407,   463,  -513,  -513,  2738,  -513,  -513,   435,  -513,  -513,
    -513,  3146,  -513,  -513,   439,  -513,  -513,  -513,  3146,  -513,
    3146,  -513,  -513,  1312,   442,  -513,  -513,  -513,  -513,  -513,
    -513,   458,  -513,   174,   268,   414,   547,   550,  -513,  -513,
    -513,   436,   385,  -513,  -513,   301,  -513,   464,   460,   -68,
    -513,   422,   -68,   150,  -513,  -513,  -513,  -513,  -513,  -513,
     505,   -68,   476,   476,   484,  -513,  -513,   -16,   399,   491,
    -513,   493,  -513,   311,   521,   527,  1876,  1928,   220,   117,
    2466,   507,  -513,  -513,  2466,  2466,  2466,  2466,  2466,  2466,
    2466,  2466,  2466,  2466,  2466,  2466,   185,  2466,  2466,  2466,
    2466,  2466,  2466,  2466,  2466,  -513,  -513,  2466,  2466,   499,
    -513,   509,  -513,   511,  2466,  2466,   367,  -513,  -513,   535,
    -513,    10,   541,   536,  -513,   -68,  -513,  -513,  -513,  -513,
    -513,  -513,  -513,   577,   323,  -513,  -513,  -513,   543,  1994,
    2466,  -513,    40,   464,  -513,  -513,  -513,  2806,   545,   460,
    -513,  -513,  -513,   554,  1928,   476,  -513,   159,   476,   159,
    2046,  2466,   196,   239,  3282,  -513,  -513,  1692,  -513,  -513,
    -513,   200,  -513,   551,  -513,  -513,  -513,  -513,   555,   553,
    2112,  -513,  -513,  -513,   316,   316,   512,   512,   512,   351,
     351,   351,   351,   169,  -513,   259,   259,   549,   474,   462,
     475,   477,   566,  -513,   564,  -513,  -513,  -513,   565,   568,
     570,   339,   367,  -513,  -513,  -513,  -513,  2466,  -513,  -513,
     536,   571,  3257,  3257,   569,   582,  -513,   572,   345,   587,
    -513,   483,  2874,   588,  2942,  -513,  2164,   567,  -513,   269,
    -513,   269,  -513,   575,   210,  -513,  2466,  3282,  -513,  -513,
    -513,  -513,  1559,  -513,  2230,  -513,   206,   223,  2466,  3214,
    -513,   591,   422,  -513,  -513,  -513,   584,  2466,  -513,   593,
     543,  3257,     7,  -513,   241,  -513,  3010,  2282,  -513,  -513,
     230,  -513,   206,   598,  -513,  -513,  -513,  -513,  -513,   238,
    -513,   206,  -513,   602,  -513,   641,   642,  3214,  -513,  -513,
    3214,  -513,  -513,   599,    33,  -513,   605,  -513,   608,  3146,
     609,  -513,  -513,   611,  -513,   612,   251,  -513,  -513,   206,
    -513,  -513,  2466,  3146,  -513,  -513,  2348,   619,  2466,  -513,
      95,  -513,  2534,  -513,   339,   613,  -513,  3146,  2400,  -513,
     614,  -513,   622,  -513,  3257,   618,  -513,  -513,   620,  -513,
    -513,  2602,  -513,  3078,  -513,  -513,  -513,  -513,   625,   293,
    -513,  3214,   627,  3257,  -513,  -513,  -513,   626,   664,  3214,
     629,  -513,  3214,  -513,  3214,  -513,  -513
};

/* YYPGOTO[NTERM-NUM].  */
static const short int yypgoto[] =
{
    -513,  -513,  -513,   -20,   -37,   395,    28,  -103,   -35,   131,
     289,   -13,  -513,    -3,  -513,   721,   151,  -513,    44,  -513,
    -513,    26,    19,   648,  -513,  -513,   685,   670,  -513,  -105,
    -513,   601,  -513,    15,  -101,   615,  -144,  -167,  -513,  -513,
      30,    97,   459,  -285,   -87,  -513,  -513,  -513,  -513,  -513,
     604,   356,  -513,  -513,    36,  -513,  -513,  -513,  -513,   694,
      -1,  -513,   660,  -513,  -513,  -169,  -513,   -93,  -128,  -242,
    -513,   481,  -236,  -362,  -455,   736,  -430,  -513,  -513,  -513,
    -251,  -513,  -513,  -513,  -513,  -513,  -513,   178,   181,  -512,
    -413,  -513,  -513,  -513,  -513,  -513,  -513,  -513,  -387,  -513,
    -495,   486,  -513,  -513,  -513,  -513,  -513,  -513,  -513,  -513,
    -513,   298,   302,  -513,  -513,  -513,   180,  -513,  -513,  -513,
    -513,  -354,  -513,   450,    23,   -18,  1117,   341,  1141,   411,
     556,   576,   315,   635,   734,  -381,  -513,   307,   197,    53,
     270,   416,   418,   415,   420,   424,  -513,   262,   423,   789,
    -513,  -513,  1033,  -513
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -355
static const short int yytable[] =
{
      25,    26,   367,   244,   312,   127,   390,   288,   551,   149,
      49,   456,   376,   155,   123,   370,   550,    72,   147,    16,
      20,    87,   372,   488,   373,    89,   116,    28,    16,    16,
      16,   343,    47,    48,    71,    50,    31,   119,   120,   219,
      72,   221,    50,   147,   536,    72,   484,    37,    16,    38,
     286,    16,    16,    30,   103,    31,    88,   106,   287,    31,
     594,    92,    71,   304,    95,    16,   497,    51,    97,   537,
      58,   117,    31,    77,    72,   129,    30,    39,    72,   594,
     401,   567,   536,   102,    51,   536,   540,   314,    51,   602,
      81,    71,   113,    20,   237,   151,   568,    72,   133,    72,
     457,    77,    95,    97,   131,   344,   525,   537,   610,    42,
     537,   458,   543,   290,   106,    72,    71,   158,    81,   291,
      56,   133,   520,   133,   540,    60,   139,   540,   240,   302,
     134,   569,   289,   307,   152,   363,   466,   356,    51,    54,
     529,   141,   291,   567,    58,   389,   536,   146,   158,     1,
     543,   139,     1,   543,   536,   134,    34,   536,   568,   536,
      29,   103,    33,   556,     2,   102,   141,     3,   101,    45,
       3,   537,   146,     4,    35,   564,     4,   102,   565,   537,
      36,   314,   537,    46,   537,    75,   321,    20,   540,   391,
     417,     1,   386,   589,   303,   383,   540,    20,    66,   540,
     350,   540,   126,   128,    72,    20,     6,   237,    75,     6,
     358,   508,   376,    75,   543,   121,    44,   546,    45,   103,
     122,   365,   543,   351,   599,   543,   237,   543,   480,   359,
     482,    68,   367,   158,    69,    20,    66,   220,   120,   608,
     490,   240,    75,   150,    72,   316,    75,   613,   240,   317,
     615,    45,   616,   318,    72,   240,   171,   240,   125,   474,
     376,   151,   238,   534,   460,    75,    65,    75,   102,    68,
    -189,   151,    69,    20,   367,  -189,  -189,   332,   333,   334,
     335,   110,   374,    75,   397,   399,   158,   107,   414,   402,
     403,    21,   486,   415,    27,   125,   491,   416,   393,   433,
     152,   370,   492,   111,   372,   124,   523,   553,    20,   414,
     152,   273,   492,   576,   415,    50,   418,   336,   416,   531,
      58,   324,   325,   326,     1,   492,   557,   583,    53,    20,
     115,    53,   492,   376,   560,   487,     2,    72,   125,   130,
     492,   597,     3,    76,   516,    53,    66,   580,     4,    53,
     237,   367,   376,   492,   365,    67,     5,     3,   503,   329,
     330,   331,   158,     4,  -188,   534,    76,    34,   125,  -188,
    -188,    76,    75,   576,    66,   238,   583,   479,   597,    68,
     481,     6,    69,    20,   240,   429,   430,   431,   432,   607,
       1,   530,   131,   132,   238,   492,     6,    66,   131,    53,
      76,  -101,   384,   157,    76,    53,    67,    68,     3,   406,
      69,    20,    75,   407,     4,   103,   281,   558,   478,   552,
     239,   478,    75,    76,   273,    76,   561,   217,   450,   218,
      68,   273,   451,    69,    20,   237,   131,   237,   273,   116,
     273,    76,   292,   273,    70,   300,   130,     6,   301,   293,
     293,   293,   293,    66,   581,    53,   315,   293,   293,   308,
     322,   323,    67,   319,     3,    72,     1,    75,   320,   240,
       4,   240,   274,    66,   340,   296,   297,   298,   299,   237,
       1,   595,   151,   305,   306,   339,    68,    66,   341,    69,
      20,   342,  -352,  -352,   316,  -236,   240,   364,   317,   131,
     283,     1,   318,     6,   348,    75,    68,    34,    66,    69,
      20,    50,   354,   240,    66,   327,   328,    67,   238,     3,
      68,   152,   355,    69,    20,     4,   426,   427,   428,   357,
      76,    36,   381,   239,   240,   237,   368,   240,  -353,  -353,
     371,    68,   275,   379,    69,    20,   240,    68,  -354,  -354,
      69,    20,   239,   380,   237,   108,   237,   -16,     6,   122,
     240,   387,  -352,  -352,   316,   337,   338,   273,   317,   240,
      76,   -16,   318,   392,   240,   394,  -352,  -352,   316,   400,
      76,    53,   317,   345,   346,   274,   514,   404,   240,   408,
     240,   405,   274,  -298,  -298,   409,  -299,  -299,   240,   274,
     445,   274,   420,   238,   274,   238,   240,   435,   436,   240,
     446,   240,   447,   293,   293,   293,   293,   293,   293,   293,
     293,   293,   293,   293,   293,    76,   293,   293,   293,   293,
     293,   293,   293,    75,   424,   425,   455,   459,   120,   421,
     422,   423,   273,   273,   461,   462,   475,   238,    17,   476,
     494,   493,   273,   495,   273,   275,   498,    17,    17,    17,
     499,   500,   275,    76,   501,   502,   507,   521,    34,   275,
     511,   275,  -266,   513,   275,    66,   471,    17,   512,   273,
      17,    17,  -116,   517,   105,   547,    35,   276,   544,   549,
     293,   273,    36,   293,    17,  -268,   273,   562,   563,  -161,
     566,   574,    78,   238,   575,   577,   578,   277,    68,   586,
     604,    69,    20,   579,   596,   600,   485,   273,   601,   603,
     273,   612,   238,   609,   238,   614,   606,   611,   274,   273,
      78,   434,    32,    64,    94,   159,    19,   284,   282,   467,
     382,    63,   109,   273,   375,    19,    19,    19,   590,   378,
     504,   591,   273,   398,   505,   437,   439,   273,   438,   135,
     532,   239,   440,   239,   273,    19,   278,   441,    19,    19,
     443,   273,     0,   273,     0,   293,   293,     0,     0,     0,
       0,   273,    19,   273,   135,     0,     0,   293,     0,   273,
      86,    76,   273,     0,   273,     0,     0,     0,   275,     0,
     276,   524,     0,   274,   274,   239,     0,   276,     0,     0,
       0,     0,     0,   274,   276,   274,   276,     0,    86,   276,
     277,     0,     0,     0,     0,     0,     0,   277,     0,     0,
       0,     0,     0,     0,   277,     0,   277,     0,     0,   277,
     274,     0,     0,     0,     0,     0,     0,   148,     0,     0,
       0,     0,   274,     0,     0,     0,     0,   274,     0,     0,
       0,   239,     0,     0,     0,   279,     0,     0,     0,     0,
       0,     0,   148,   275,   275,     0,     0,     0,   274,   278,
     239,   274,   239,   275,     0,   275,   278,     0,     0,     0,
     274,     0,     0,   278,     0,   278,     0,     0,   278,     0,
       0,     0,     0,     0,   274,     0,     0,     0,     0,     0,
     275,     0,     0,   274,     0,     0,     0,     0,   274,     0,
     280,     0,   275,     0,     0,   274,     0,   275,     0,     0,
       0,     0,   274,     0,   274,     0,     0,     0,     0,     0,
       0,     0,   274,   276,   274,     0,     0,     0,   275,     0,
     274,   275,     0,   274,     0,   274,     0,     0,     0,     0,
     275,     0,     0,   277,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   275,     0,     0,     0,   279,     0,
       0,     0,     0,   275,     0,   279,     0,     0,   275,     0,
       0,     0,   279,     0,   279,   275,     0,   279,     0,     0,
       0,     0,   275,     0,   275,     0,     0,     0,     0,     0,
       0,     0,   275,     0,   275,     0,     0,     0,   276,   276,
     275,     0,   278,   275,     0,   275,     0,     0,   276,     0,
     276,     0,     0,   280,     0,     0,     0,     0,   277,   277,
     280,     0,     0,     0,     0,     0,     0,   280,   277,   280,
     277,     0,   280,     0,     0,   276,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   276,     0,     0,
       0,     0,   276,     0,     0,   277,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   277,     0,     0,
       0,     0,   277,   276,     0,     0,   276,   278,   278,     0,
       0,     0,     0,     0,     0,   276,     0,   278,     0,   278,
       0,     0,     0,   277,     0,     0,   277,     0,     0,   276,
       0,   279,     0,     0,     0,   277,     0,     0,   276,     0,
       0,     0,     0,   276,   278,     0,     0,     0,     0,   277,
     276,     0,     0,     0,     0,     0,   278,   276,   277,   276,
       0,   278,     0,   277,   216,     0,     0,   276,     0,   276,
     277,     0,     0,     0,     0,   276,     0,   277,   276,   277,
     276,     0,   278,     0,     0,   278,   280,   277,     0,   277,
       0,     0,     0,     0,   278,   277,     0,     0,   277,     0,
     277,     0,     0,     0,     0,     0,   279,   279,   278,     0,
       0,     0,     0,   309,   216,     0,   279,   278,   279,     0,
       0,     0,   278,     0,     0,     0,     0,     0,     0,   278,
       0,     0,     0,     0,     0,     0,   278,     0,   278,     0,
       0,     0,     0,   279,     0,     0,   278,     0,   278,     0,
       0,     0,     0,     0,   278,   279,     0,   278,     0,   278,
     279,   280,   280,     0,     0,     0,     0,   349,     0,     0,
     353,   280,     0,   280,     0,     0,   361,   362,     0,     0,
       0,   279,     0,     0,   279,     0,     0,   294,   294,   294,
     294,     0,     0,   279,     0,   294,   294,     0,   280,     0,
       0,     0,     0,     0,     0,     0,     0,   279,     0,     0,
     280,   295,   295,   295,   295,   280,   279,     0,     0,   295,
     295,   279,     0,     0,     0,     0,     0,     0,   279,     0,
       0,     0,     0,     0,     0,   279,   280,   279,     0,   280,
       0,     0,     0,     0,     0,   279,     0,   279,   280,     0,
       0,     0,     0,   279,     0,     0,   279,     0,   279,     0,
     413,     0,   280,   419,     0,     0,     1,     0,   162,   163,
       0,   280,     0,    66,     0,     0,   280,     0,     0,     0,
       0,     0,   164,   280,     0,     0,     0,   442,   165,     0,
     280,   444,   280,     0,     0,   166,     0,   448,   449,   167,
     280,     0,   280,     0,     0,     0,    68,     0,   280,    69,
      20,   280,     0,   280,     0,     0,     0,   234,     0,     0,
       0,     0,   464,   465,     0,     0,   172,   173,   174,   175,
       0,     0,   176,   177,     0,     0,     0,   477,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     216,   294,   294,   294,   294,   294,   294,   294,   294,   294,
     294,   294,   294,     0,   294,   294,   294,   294,   294,   294,
     294,   360,     0,   160,   161,   295,   295,   295,   295,   295,
     295,   295,   295,   295,   295,   295,   295,     0,   295,   295,
     295,   295,   295,   295,   295,     0,     0,     0,     0,     0,
     506,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   162,   163,     0,     0,
       0,    66,     0,     0,     0,     0,     0,     0,   294,     0,
     164,   294,     0,     0,     0,   527,   165,     0,     0,     0,
       0,     0,     0,   166,     0,     0,     0,   167,     0,     0,
     548,     0,   295,     0,    68,   295,     0,    69,    20,     0,
       0,   168,   169,     0,     0,   170,     0,     0,     0,     0,
     526,     0,   160,   161,   172,   173,   174,   175,     0,     0,
     176,   177,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   582,     0,     0,     0,   585,
       0,   587,     0,   294,   294,   162,   163,     0,     0,     0,
      66,     0,     0,     0,     0,   294,     0,     0,     0,   164,
       0,     0,     0,     0,     0,   165,     0,   295,   295,   160,
     161,     0,   166,     0,     0,     0,   167,     0,     0,   295,
       0,     0,     0,    68,     0,     0,    69,    20,     0,     0,
     168,   169,     0,     0,   170,     0,     0,     0,     0,     0,
       0,     0,     0,   172,   173,   174,   175,     0,     0,   176,
     177,     0,   162,   163,     0,     0,     0,    66,     0,     0,
       0,     0,     0,     0,     0,     0,   164,     0,     0,     0,
       0,     0,   165,     0,     0,   160,   161,     0,     0,   166,
       0,     0,     0,   167,     0,     0,     0,     0,     0,     0,
      68,     0,     0,    69,    20,     0,     0,   168,   169,     0,
       0,   170,     0,   171,   310,     0,     0,     0,   311,     0,
     172,   173,   174,   175,     0,     0,   176,   177,   162,   163,
       0,     0,     0,    66,     0,     0,     0,     0,     0,     0,
       0,     0,   164,     0,     0,     0,     0,     0,   165,     0,
       0,   160,   161,     0,     0,   166,     0,     0,     0,   167,
       0,     0,     0,     0,     0,     0,    68,     0,     0,    69,
      20,     0,     0,   168,   169,     0,     0,   170,     0,   171,
     489,     0,     0,     0,     0,     0,   172,   173,   174,   175,
       0,     0,   176,   177,   162,   163,     0,     0,     0,    66,
       0,     0,     0,   160,   161,     0,     0,     0,   164,     0,
       0,     0,     0,     0,   165,     0,     0,     0,     0,     0,
       0,   166,     0,     0,     0,   167,     0,     0,     0,     0,
       0,     0,    68,     0,     0,    69,    20,     0,     0,   168,
     169,     0,     0,   170,     0,   171,   162,   163,     0,     0,
       0,    66,   172,   173,   174,   175,     0,     0,   176,   177,
     164,     0,     0,     0,     0,     0,   165,     0,     0,   160,
     161,     0,     0,   166,     0,     0,     0,   167,     0,     0,
       0,     0,     0,     0,    68,     0,     0,    69,    20,     0,
       0,   168,   169,     0,     0,   170,     0,     0,     0,     0,
       0,   352,     0,     0,   172,   173,   174,   175,     0,     0,
     176,   177,   162,   163,     0,     0,     0,    66,     0,     0,
       0,   160,   161,     0,     0,     0,   164,     0,     0,     0,
       0,     0,   165,     0,     0,     0,     0,     0,     0,   166,
       0,     0,     0,   167,     0,     0,     0,     0,     0,     0,
      68,     0,     0,    69,    20,     0,     0,   168,   169,     0,
       0,   170,   410,     0,   162,   163,     0,     0,     0,    66,
     172,   173,   174,   175,     0,     0,   176,   177,   164,     0,
       0,     0,     0,     0,   165,     0,     0,   160,   161,     0,
       0,   166,     0,     0,     0,   167,     0,     0,     0,     0,
       0,     0,    68,     0,     0,    69,    20,     0,     0,   168,
     169,     0,     0,   170,     0,     0,     0,     0,   124,     0,
       0,     0,   172,   173,   174,   175,     0,     0,   176,   177,
     162,   163,     0,     0,     0,    66,     0,     0,     0,   160,
     161,     0,     0,     0,   164,     0,     0,     0,     0,     0,
     165,     0,     0,     0,     0,     0,     0,   166,     0,     0,
       0,   167,     0,     0,     0,     0,     0,     0,    68,     0,
       0,    69,    20,     0,     0,   168,   169,     0,     0,   170,
       0,     0,   162,   163,     0,   463,     0,    66,   172,   173,
     174,   175,     0,     0,   176,   177,   164,     0,     0,     0,
       0,     0,   165,     0,     0,   160,   161,     0,     0,   166,
       0,     0,     0,   167,     0,     0,     0,     0,     0,     0,
      68,     0,     0,    69,    20,     0,     0,   168,   169,     0,
       0,   170,   483,     0,     0,     0,     0,     0,     0,     0,
     172,   173,   174,   175,     0,     0,   176,   177,   162,   163,
       0,     0,     0,    66,     0,     0,     0,   160,   161,     0,
       0,     0,   164,     0,     0,     0,     0,     0,   165,     0,
       0,     0,     0,     0,     0,   166,     0,     0,     0,   167,
       0,     0,     0,     0,     0,     0,    68,     0,     0,    69,
      20,     0,     0,   168,   169,     0,     0,   170,   496,     0,
     162,   163,     0,     0,     0,    66,   172,   173,   174,   175,
       0,     0,   176,   177,   164,     0,     0,     0,     0,     0,
     165,     0,     0,   160,   161,     0,     0,   166,     0,     0,
       0,   167,     0,     0,     0,     0,     0,     0,    68,     0,
       0,    69,    20,     0,     0,   168,   169,     0,     0,   170,
     519,     0,     0,     0,     0,     0,     0,     0,   172,   173,
     174,   175,     0,     0,   176,   177,   162,   163,     0,     0,
       0,    66,     0,     0,     0,   160,   161,     0,     0,     0,
     164,     0,     0,     0,     0,     0,   165,     0,     0,     0,
       0,     0,     0,   166,     0,     0,     0,   167,     0,     0,
       0,     0,     0,     0,    68,     0,     0,    69,    20,     0,
       0,   168,   169,     0,     0,   170,   528,     0,   162,   163,
       0,     0,     0,    66,   172,   173,   174,   175,     0,     0,
     176,   177,   164,     0,     0,     0,     0,     0,   165,     0,
       0,   160,   161,     0,     0,   166,     0,     0,     0,   167,
       0,     0,     0,     0,     0,     0,    68,     0,     0,    69,
      20,     0,     0,   168,   169,     0,     0,   170,   555,     0,
       0,     0,     0,     0,     0,     0,   172,   173,   174,   175,
       0,     0,   176,   177,   162,   163,     0,     0,     0,    66,
       0,     0,     0,   160,   161,     0,     0,     0,   164,     0,
       0,     0,     0,     0,   165,     0,     0,     0,     0,     0,
       0,   166,     0,     0,     0,   167,     0,     0,     0,     0,
       0,     0,    68,     0,     0,    69,    20,     0,     0,   168,
     169,     0,     0,   170,     0,     0,   162,   163,     0,   584,
       0,    66,   172,   173,   174,   175,     0,     0,   176,   177,
     164,     0,     0,     0,     0,     0,   165,     0,     0,   160,
     161,     0,     0,   166,     0,     0,     0,   167,     0,     0,
       0,     0,     0,     0,    68,     0,     0,    69,    20,     0,
       0,   168,   169,     0,     0,   170,   598,     0,     0,     0,
       0,     0,     0,     0,   172,   173,   174,   175,     0,     0,
     176,   177,   162,   163,     0,     0,     0,    66,     0,     0,
       0,     0,     0,     0,     0,     0,   164,     0,     0,     0,
       0,     0,   165,     0,     0,     0,     0,     0,     0,   166,
       0,     0,     0,   167,     0,     0,     0,     0,     0,     0,
      68,     0,     0,    69,    20,     0,     0,   168,   169,     0,
       0,   170,     0,     0,     0,     0,     0,     0,     0,     0,
     172,   173,   174,   175,     0,     0,   176,   177,   222,     0,
     162,   163,   567,   223,   224,    66,   225,     0,     0,   226,
       0,     0,     0,   227,   164,     0,     0,   568,     0,     0,
     165,   228,     4,   229,     0,   230,   231,   166,   232,     0,
       0,   167,   233,     0,     0,     0,     0,     0,    68,     0,
       0,    69,    20,     0,     0,     0,     0,     0,     0,   234,
       0,   131,   592,     0,     0,     6,     0,     0,   172,   173,
     174,   175,     0,     0,   176,   177,   222,     0,   162,   163,
     567,   223,   224,    66,   225,     0,     0,   226,     0,     0,
       0,   227,   164,     0,     0,   568,     0,     0,   165,   228,
       4,   229,     0,   230,   231,   166,   232,     0,     0,   167,
     233,     0,     0,     0,     0,     0,    68,     0,     0,    69,
      20,     0,     0,     0,     0,     0,     0,   234,     0,   131,
     605,     0,     0,     6,     0,     0,   172,   173,   174,   175,
       0,     0,   176,   177,   222,     0,   162,   163,     0,   223,
     224,    66,   225,     0,     0,   226,     0,     0,     0,   227,
     164,     0,     0,     0,     0,     0,   165,   228,     4,   229,
       0,   230,   231,   166,   232,     0,     0,   167,   233,     0,
       0,     0,     0,     0,    68,     0,     0,    69,    20,     0,
       0,     0,     0,     0,     0,   234,     0,   131,   235,     0,
       0,     6,     0,     0,   172,   173,   174,   175,     0,     0,
     176,   177,   222,     0,   162,   163,     0,   223,   224,    66,
     225,     0,     0,   226,     0,     0,     0,   227,   164,     0,
       0,     0,     0,     0,   165,   228,     4,   229,     0,   230,
     231,   166,   232,     0,     0,   167,   233,     0,     0,     0,
       0,     0,    68,     0,     0,    69,    20,     0,     0,     0,
       0,     0,     0,   234,     0,   131,   366,     0,     0,     6,
       0,     0,   172,   173,   174,   175,     0,     0,   176,   177,
     222,     0,   162,   163,     0,   223,   224,    66,   225,     0,
       0,   226,     0,     0,     0,   227,   164,     0,     0,     0,
       0,     0,   468,   228,     4,   229,     0,   230,   231,   166,
     232,     0,     0,   469,   233,     0,     0,     0,     0,     0,
      68,     0,     0,    69,    20,     0,     0,     0,     0,     0,
       0,   234,     0,   131,   470,     0,     0,     6,     0,     0,
     172,   173,   174,   175,     0,     0,   176,   177,   222,     0,
     162,   163,     0,   223,   224,    66,   225,     0,     0,   226,
       0,     0,     0,   227,   164,     0,     0,     0,     0,     0,
     165,   228,     4,   229,     0,   230,   231,   166,   232,     0,
       0,   167,   233,     0,     0,     0,     0,     0,    68,     0,
       0,    69,    20,     0,     0,     0,     0,     0,     0,   234,
       0,   131,   515,     0,     0,     6,     0,     0,   172,   173,
     174,   175,     0,     0,   176,   177,   222,     0,   162,   163,
       0,   223,   224,    66,   225,     0,     0,   226,     0,     0,
       0,   227,   164,     0,     0,     0,     0,     0,   165,   228,
       4,   229,     0,   230,   231,   166,   232,     0,     0,   167,
     233,     0,     0,     0,     0,     0,    68,     0,     0,    69,
      20,     0,     0,     0,     0,     0,     0,   234,     0,   131,
     518,     0,     0,     6,     0,     0,   172,   173,   174,   175,
       0,     0,   176,   177,   222,     0,   162,   163,     0,   223,
     224,    66,   225,     0,     0,   226,     0,     0,     0,   227,
     164,     0,     0,     0,     0,     0,   165,   228,     4,   229,
       0,   230,   231,   166,   232,     0,     0,   167,   233,     0,
       0,     0,     0,     0,    68,     0,     0,    69,    20,     0,
       0,     0,     0,     0,     0,   234,     0,   131,   554,     0,
       0,     6,     0,     0,   172,   173,   174,   175,     0,     0,
     176,   177,   222,     0,   162,   163,     0,   223,   224,    66,
     225,     0,     0,   226,     0,     0,     0,   227,   164,     0,
       0,     0,     0,     0,   165,   228,     4,   229,     0,   230,
     231,   166,   232,     0,     0,   167,   233,     0,     0,     0,
       0,     0,    68,     0,     0,    69,    20,     0,     0,     0,
       0,     0,     0,   234,     0,   131,     0,     0,     0,     6,
       0,     0,   172,   173,   174,   175,     0,     0,   176,   177,
     369,     0,   162,   163,     0,   223,   224,    66,   225,     0,
       0,   226,     0,     0,     0,   227,   164,     0,     0,     0,
       0,     0,   165,   228,     0,   229,     0,   230,   231,   166,
     232,     0,     0,   167,   233,     0,     0,     0,     0,     0,
      68,     0,     0,    69,    20,     0,     0,     0,     0,     0,
       0,   234,     0,   131,     0,     0,     0,     6,     0,     0,
     172,   173,   174,   175,     0,     0,   176,   177,   369,     0,
     162,   163,     0,   533,   224,    66,   225,     0,     0,   226,
       0,     0,     0,   227,   164,     0,     0,     0,     0,     0,
     165,   228,     0,   229,     0,   230,   231,   166,   232,     0,
       0,   167,   233,     0,     0,     0,     0,     0,    68,     0,
       0,    69,    20,   162,   163,     0,     0,     0,    66,   234,
       0,   131,     0,     0,     0,     6,     0,   164,   172,   173,
     174,   175,     0,   165,   176,   177,     0,     0,     0,     0,
     166,     0,     0,    66,   167,     0,     0,     0,     0,     0,
       0,    68,   164,     0,    69,    20,     0,     0,   165,     0,
       0,     0,   234,     0,     0,   166,     0,     0,     0,   167,
       0,   172,   173,   174,   175,     0,    68,   176,   177,    69,
      20,     0,     0,   168,   169,     0,     0,   170,     0,     0,
       0,     0,     0,     0,     0,     0,   172,   173,   174,   175,
       0,     0,   176,   177
};

static const short int yycheck[] =
{
       3,     4,   244,   131,   171,   106,   291,   151,     1,   114,
       5,     1,   263,   116,   101,   251,   511,    54,   111,     0,
      88,    56,   258,   404,   260,    60,    54,     0,     9,    10,
      11,    15,    35,    36,    54,    38,    10,   101,   102,   126,
      77,   128,    45,   136,   499,    82,   400,   101,    29,   103,
     143,    32,    33,     9,    72,    29,    57,    77,   145,    33,
     572,    62,    82,   166,    67,    46,   420,    39,    71,   499,
      42,    99,    46,    54,   111,   110,    32,    64,   115,   591,
      96,    48,   537,    99,    56,   540,   499,   103,    60,   584,
      54,   111,    93,    88,   131,   115,    63,   134,   111,   136,
      90,    82,   105,   106,    97,    89,   487,   537,   603,    64,
     540,   101,   499,    96,   134,   152,   136,   120,    82,   102,
     102,   134,   476,   136,   537,    53,   111,   540,   131,   166,
     111,    98,   152,   170,   115,   236,    96,   230,   110,    97,
     494,   111,   102,    48,   116,   289,   601,   111,   151,    44,
     537,   136,    44,   540,   609,   136,    44,   612,    63,   614,
       9,   179,    11,   517,    56,    99,   136,    62,    71,   103,
      62,   601,   136,    68,    62,   537,    68,    99,   540,   609,
      68,   103,   612,    32,   614,    54,   189,    88,   601,   292,
      73,    44,   285,    98,   166,   282,   609,    88,    51,   612,
     101,   614,   105,   106,   241,    88,   101,   244,    77,   101,
     101,   462,   463,    82,   601,    94,   101,   502,   103,   237,
      99,   241,   609,   226,   578,   612,   263,   614,   397,   232,
     399,    84,   474,   236,    87,    88,    51,   101,   102,   601,
     407,   244,   111,    96,   281,    95,   115,   609,   251,    99,
     612,   103,   614,   103,   291,   258,    97,   260,    99,   387,
     511,   281,   131,   499,   365,   134,   101,   136,    99,    84,
      96,   291,    87,    88,   516,   101,   102,    18,    19,    20,
      21,   102,   263,   152,   302,   303,   289,   101,    68,   307,
     308,     2,    96,    73,     5,    99,    96,    77,   301,   336,
     281,   537,   102,    97,   540,   100,    96,    66,    88,    68,
     291,   131,   102,   549,    73,   318,   319,    58,    77,    96,
     292,     5,     6,     7,    44,   102,    96,   563,    39,    88,
      95,    42,   102,   584,    96,    96,    56,   374,    99,    44,
     102,   577,    62,    54,   472,    56,    51,    96,    68,    60,
     387,   593,   603,   102,   374,    60,    76,    62,   451,     8,
       9,    10,   365,    68,    96,   601,    77,    44,    99,   101,
     102,    82,   241,   609,    51,   244,   612,   395,   614,    84,
     398,   101,    87,    88,   387,   332,   333,   334,   335,    96,
      44,   496,    97,    98,   263,   102,   101,    51,    97,   110,
     111,    97,   101,   100,   115,   116,    60,    84,    62,    98,
      87,    88,   281,   102,    68,   433,    95,   522,   395,   512,
     131,   398,   291,   134,   244,   136,   531,   100,    61,   100,
      84,   251,    65,    87,    88,   472,    97,   474,   258,    54,
     260,   152,   102,   263,    98,   103,    44,   101,   103,   160,
     161,   162,   163,    51,   559,   166,   103,   168,   169,   170,
      46,    47,    60,   103,    62,   502,    44,   336,    99,   472,
      68,   474,   131,    51,    12,   160,   161,   162,   163,   516,
      44,   574,   502,   168,   169,    11,    84,    51,    13,    87,
      88,    14,    93,    94,    95,    95,   499,    90,    99,    97,
      98,    44,   103,   101,    95,   374,    84,    44,    51,    87,
      88,   514,    95,   516,    51,     3,     4,    60,   387,    62,
      84,   502,    95,    87,    88,    68,   329,   330,   331,    95,
     241,    68,    96,   244,   537,   572,   101,   540,    93,    94,
     101,    84,   131,   101,    87,    88,   549,    84,    93,    94,
      87,    88,   263,    95,   591,    98,   593,    88,   101,    99,
     563,    97,    93,    94,    95,    16,    17,   387,    99,   572,
     281,    88,   103,    68,   577,    99,    93,    94,    95,    95,
     291,   292,    99,    93,    94,   244,   103,    96,   591,    68,
     593,    98,   251,    46,    47,    68,    46,    47,   601,   258,
     101,   260,    95,   472,   263,   474,   609,   337,   338,   612,
     101,   614,   101,   324,   325,   326,   327,   328,   329,   330,
     331,   332,   333,   334,   335,   336,   337,   338,   339,   340,
     341,   342,   343,   502,   327,   328,   101,    96,   102,   324,
     325,   326,   462,   463,    67,   102,   101,   516,     0,    95,
      95,   100,   472,   100,   474,   244,    90,     9,    10,    11,
      96,    96,   251,   374,    96,    95,    95,   100,    44,   258,
     101,   260,    97,   101,   263,    51,   387,    29,    96,   499,
      32,    33,    95,    95,    60,   101,    62,   131,    97,    96,
     401,   511,    68,   404,    46,    97,   516,    95,    57,    57,
     101,    96,    54,   572,    96,    96,    95,   131,    84,    90,
      90,    87,    88,   101,   101,   101,   401,   537,    96,   101,
     540,    57,   591,    96,   593,    96,   101,   101,   387,   549,
      82,   336,    11,    48,    64,   120,     0,   136,   134,   383,
     281,    47,    82,   563,   263,     9,    10,    11,   570,   263,
     452,   570,   572,   303,   452,   339,   341,   577,   340,   111,
     498,   472,   342,   474,   584,    29,   131,   343,    32,    33,
     347,   591,    -1,   593,    -1,   486,   487,    -1,    -1,    -1,
      -1,   601,    46,   603,   136,    -1,    -1,   498,    -1,   609,
      54,   502,   612,    -1,   614,    -1,    -1,    -1,   387,    -1,
     244,   486,    -1,   462,   463,   516,    -1,   251,    -1,    -1,
      -1,    -1,    -1,   472,   258,   474,   260,    -1,    82,   263,
     244,    -1,    -1,    -1,    -1,    -1,    -1,   251,    -1,    -1,
      -1,    -1,    -1,    -1,   258,    -1,   260,    -1,    -1,   263,
     499,    -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,    -1,
      -1,    -1,   511,    -1,    -1,    -1,    -1,   516,    -1,    -1,
      -1,   572,    -1,    -1,    -1,   131,    -1,    -1,    -1,    -1,
      -1,    -1,   136,   462,   463,    -1,    -1,    -1,   537,   244,
     591,   540,   593,   472,    -1,   474,   251,    -1,    -1,    -1,
     549,    -1,    -1,   258,    -1,   260,    -1,    -1,   263,    -1,
      -1,    -1,    -1,    -1,   563,    -1,    -1,    -1,    -1,    -1,
     499,    -1,    -1,   572,    -1,    -1,    -1,    -1,   577,    -1,
     131,    -1,   511,    -1,    -1,   584,    -1,   516,    -1,    -1,
      -1,    -1,   591,    -1,   593,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   601,   387,   603,    -1,    -1,    -1,   537,    -1,
     609,   540,    -1,   612,    -1,   614,    -1,    -1,    -1,    -1,
     549,    -1,    -1,   387,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   563,    -1,    -1,    -1,   244,    -1,
      -1,    -1,    -1,   572,    -1,   251,    -1,    -1,   577,    -1,
      -1,    -1,   258,    -1,   260,   584,    -1,   263,    -1,    -1,
      -1,    -1,   591,    -1,   593,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   601,    -1,   603,    -1,    -1,    -1,   462,   463,
     609,    -1,   387,   612,    -1,   614,    -1,    -1,   472,    -1,
     474,    -1,    -1,   244,    -1,    -1,    -1,    -1,   462,   463,
     251,    -1,    -1,    -1,    -1,    -1,    -1,   258,   472,   260,
     474,    -1,   263,    -1,    -1,   499,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   511,    -1,    -1,
      -1,    -1,   516,    -1,    -1,   499,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   511,    -1,    -1,
      -1,    -1,   516,   537,    -1,    -1,   540,   462,   463,    -1,
      -1,    -1,    -1,    -1,    -1,   549,    -1,   472,    -1,   474,
      -1,    -1,    -1,   537,    -1,    -1,   540,    -1,    -1,   563,
      -1,   387,    -1,    -1,    -1,   549,    -1,    -1,   572,    -1,
      -1,    -1,    -1,   577,   499,    -1,    -1,    -1,    -1,   563,
     584,    -1,    -1,    -1,    -1,    -1,   511,   591,   572,   593,
      -1,   516,    -1,   577,   121,    -1,    -1,   601,    -1,   603,
     584,    -1,    -1,    -1,    -1,   609,    -1,   591,   612,   593,
     614,    -1,   537,    -1,    -1,   540,   387,   601,    -1,   603,
      -1,    -1,    -1,    -1,   549,   609,    -1,    -1,   612,    -1,
     614,    -1,    -1,    -1,    -1,    -1,   462,   463,   563,    -1,
      -1,    -1,    -1,   170,   171,    -1,   472,   572,   474,    -1,
      -1,    -1,   577,    -1,    -1,    -1,    -1,    -1,    -1,   584,
      -1,    -1,    -1,    -1,    -1,    -1,   591,    -1,   593,    -1,
      -1,    -1,    -1,   499,    -1,    -1,   601,    -1,   603,    -1,
      -1,    -1,    -1,    -1,   609,   511,    -1,   612,    -1,   614,
     516,   462,   463,    -1,    -1,    -1,    -1,   224,    -1,    -1,
     227,   472,    -1,   474,    -1,    -1,   233,   234,    -1,    -1,
      -1,   537,    -1,    -1,   540,    -1,    -1,   160,   161,   162,
     163,    -1,    -1,   549,    -1,   168,   169,    -1,   499,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   563,    -1,    -1,
     511,   160,   161,   162,   163,   516,   572,    -1,    -1,   168,
     169,   577,    -1,    -1,    -1,    -1,    -1,    -1,   584,    -1,
      -1,    -1,    -1,    -1,    -1,   591,   537,   593,    -1,   540,
      -1,    -1,    -1,    -1,    -1,   601,    -1,   603,   549,    -1,
      -1,    -1,    -1,   609,    -1,    -1,   612,    -1,   614,    -1,
     317,    -1,   563,   320,    -1,    -1,    44,    -1,    46,    47,
      -1,   572,    -1,    51,    -1,    -1,   577,    -1,    -1,    -1,
      -1,    -1,    60,   584,    -1,    -1,    -1,   344,    66,    -1,
     591,   348,   593,    -1,    -1,    73,    -1,   354,   355,    77,
     601,    -1,   603,    -1,    -1,    -1,    84,    -1,   609,    87,
      88,   612,    -1,   614,    -1,    -1,    -1,    95,    -1,    -1,
      -1,    -1,   379,   380,    -1,    -1,   104,   105,   106,   107,
      -1,    -1,   110,   111,    -1,    -1,    -1,   394,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     407,   324,   325,   326,   327,   328,   329,   330,   331,   332,
     333,   334,   335,    -1,   337,   338,   339,   340,   341,   342,
     343,     1,    -1,     3,     4,   324,   325,   326,   327,   328,
     329,   330,   331,   332,   333,   334,   335,    -1,   337,   338,
     339,   340,   341,   342,   343,    -1,    -1,    -1,    -1,    -1,
     457,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    46,    47,    -1,    -1,
      -1,    51,    -1,    -1,    -1,    -1,    -1,    -1,   401,    -1,
      60,   404,    -1,    -1,    -1,   492,    66,    -1,    -1,    -1,
      -1,    -1,    -1,    73,    -1,    -1,    -1,    77,    -1,    -1,
     507,    -1,   401,    -1,    84,   404,    -1,    87,    88,    -1,
      -1,    91,    92,    -1,    -1,    95,    -1,    -1,    -1,    -1,
       1,    -1,     3,     4,   104,   105,   106,   107,    -1,    -1,
     110,   111,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   562,    -1,    -1,    -1,   566,
      -1,   568,    -1,   486,   487,    46,    47,    -1,    -1,    -1,
      51,    -1,    -1,    -1,    -1,   498,    -1,    -1,    -1,    60,
      -1,    -1,    -1,    -1,    -1,    66,    -1,   486,   487,     3,
       4,    -1,    73,    -1,    -1,    -1,    77,    -1,    -1,   498,
      -1,    -1,    -1,    84,    -1,    -1,    87,    88,    -1,    -1,
      91,    92,    -1,    -1,    95,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   104,   105,   106,   107,    -1,    -1,   110,
     111,    -1,    46,    47,    -1,    -1,    -1,    51,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    60,    -1,    -1,    -1,
      -1,    -1,    66,    -1,    -1,     3,     4,    -1,    -1,    73,
      -1,    -1,    -1,    77,    -1,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    -1,    87,    88,    -1,    -1,    91,    92,    -1,
      -1,    95,    -1,    97,    98,    -1,    -1,    -1,   102,    -1,
     104,   105,   106,   107,    -1,    -1,   110,   111,    46,    47,
      -1,    -1,    -1,    51,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    60,    -1,    -1,    -1,    -1,    -1,    66,    -1,
      -1,     3,     4,    -1,    -1,    73,    -1,    -1,    -1,    77,
      -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,    87,
      88,    -1,    -1,    91,    92,    -1,    -1,    95,    -1,    97,
      98,    -1,    -1,    -1,    -1,    -1,   104,   105,   106,   107,
      -1,    -1,   110,   111,    46,    47,    -1,    -1,    -1,    51,
      -1,    -1,    -1,     3,     4,    -1,    -1,    -1,    60,    -1,
      -1,    -1,    -1,    -1,    66,    -1,    -1,    -1,    -1,    -1,
      -1,    73,    -1,    -1,    -1,    77,    -1,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    -1,    87,    88,    -1,    -1,    91,
      92,    -1,    -1,    95,    -1,    97,    46,    47,    -1,    -1,
      -1,    51,   104,   105,   106,   107,    -1,    -1,   110,   111,
      60,    -1,    -1,    -1,    -1,    -1,    66,    -1,    -1,     3,
       4,    -1,    -1,    73,    -1,    -1,    -1,    77,    -1,    -1,
      -1,    -1,    -1,    -1,    84,    -1,    -1,    87,    88,    -1,
      -1,    91,    92,    -1,    -1,    95,    -1,    -1,    -1,    -1,
      -1,   101,    -1,    -1,   104,   105,   106,   107,    -1,    -1,
     110,   111,    46,    47,    -1,    -1,    -1,    51,    -1,    -1,
      -1,     3,     4,    -1,    -1,    -1,    60,    -1,    -1,    -1,
      -1,    -1,    66,    -1,    -1,    -1,    -1,    -1,    -1,    73,
      -1,    -1,    -1,    77,    -1,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    -1,    87,    88,    -1,    -1,    91,    92,    -1,
      -1,    95,    96,    -1,    46,    47,    -1,    -1,    -1,    51,
     104,   105,   106,   107,    -1,    -1,   110,   111,    60,    -1,
      -1,    -1,    -1,    -1,    66,    -1,    -1,     3,     4,    -1,
      -1,    73,    -1,    -1,    -1,    77,    -1,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    -1,    87,    88,    -1,    -1,    91,
      92,    -1,    -1,    95,    -1,    -1,    -1,    -1,   100,    -1,
      -1,    -1,   104,   105,   106,   107,    -1,    -1,   110,   111,
      46,    47,    -1,    -1,    -1,    51,    -1,    -1,    -1,     3,
       4,    -1,    -1,    -1,    60,    -1,    -1,    -1,    -1,    -1,
      66,    -1,    -1,    -1,    -1,    -1,    -1,    73,    -1,    -1,
      -1,    77,    -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,
      -1,    87,    88,    -1,    -1,    91,    92,    -1,    -1,    95,
      -1,    -1,    46,    47,    -1,   101,    -1,    51,   104,   105,
     106,   107,    -1,    -1,   110,   111,    60,    -1,    -1,    -1,
      -1,    -1,    66,    -1,    -1,     3,     4,    -1,    -1,    73,
      -1,    -1,    -1,    77,    -1,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    -1,    87,    88,    -1,    -1,    91,    92,    -1,
      -1,    95,    96,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     104,   105,   106,   107,    -1,    -1,   110,   111,    46,    47,
      -1,    -1,    -1,    51,    -1,    -1,    -1,     3,     4,    -1,
      -1,    -1,    60,    -1,    -1,    -1,    -1,    -1,    66,    -1,
      -1,    -1,    -1,    -1,    -1,    73,    -1,    -1,    -1,    77,
      -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,    87,
      88,    -1,    -1,    91,    92,    -1,    -1,    95,    96,    -1,
      46,    47,    -1,    -1,    -1,    51,   104,   105,   106,   107,
      -1,    -1,   110,   111,    60,    -1,    -1,    -1,    -1,    -1,
      66,    -1,    -1,     3,     4,    -1,    -1,    73,    -1,    -1,
      -1,    77,    -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,
      -1,    87,    88,    -1,    -1,    91,    92,    -1,    -1,    95,
      96,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   104,   105,
     106,   107,    -1,    -1,   110,   111,    46,    47,    -1,    -1,
      -1,    51,    -1,    -1,    -1,     3,     4,    -1,    -1,    -1,
      60,    -1,    -1,    -1,    -1,    -1,    66,    -1,    -1,    -1,
      -1,    -1,    -1,    73,    -1,    -1,    -1,    77,    -1,    -1,
      -1,    -1,    -1,    -1,    84,    -1,    -1,    87,    88,    -1,
      -1,    91,    92,    -1,    -1,    95,    96,    -1,    46,    47,
      -1,    -1,    -1,    51,   104,   105,   106,   107,    -1,    -1,
     110,   111,    60,    -1,    -1,    -1,    -1,    -1,    66,    -1,
      -1,     3,     4,    -1,    -1,    73,    -1,    -1,    -1,    77,
      -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,    87,
      88,    -1,    -1,    91,    92,    -1,    -1,    95,    96,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   104,   105,   106,   107,
      -1,    -1,   110,   111,    46,    47,    -1,    -1,    -1,    51,
      -1,    -1,    -1,     3,     4,    -1,    -1,    -1,    60,    -1,
      -1,    -1,    -1,    -1,    66,    -1,    -1,    -1,    -1,    -1,
      -1,    73,    -1,    -1,    -1,    77,    -1,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    -1,    87,    88,    -1,    -1,    91,
      92,    -1,    -1,    95,    -1,    -1,    46,    47,    -1,   101,
      -1,    51,   104,   105,   106,   107,    -1,    -1,   110,   111,
      60,    -1,    -1,    -1,    -1,    -1,    66,    -1,    -1,     3,
       4,    -1,    -1,    73,    -1,    -1,    -1,    77,    -1,    -1,
      -1,    -1,    -1,    -1,    84,    -1,    -1,    87,    88,    -1,
      -1,    91,    92,    -1,    -1,    95,    96,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   104,   105,   106,   107,    -1,    -1,
     110,   111,    46,    47,    -1,    -1,    -1,    51,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    60,    -1,    -1,    -1,
      -1,    -1,    66,    -1,    -1,    -1,    -1,    -1,    -1,    73,
      -1,    -1,    -1,    77,    -1,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    -1,    87,    88,    -1,    -1,    91,    92,    -1,
      -1,    95,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     104,   105,   106,   107,    -1,    -1,   110,   111,    44,    -1,
      46,    47,    48,    49,    50,    51,    52,    -1,    -1,    55,
      -1,    -1,    -1,    59,    60,    -1,    -1,    63,    -1,    -1,
      66,    67,    68,    69,    -1,    71,    72,    73,    74,    -1,
      -1,    77,    78,    -1,    -1,    -1,    -1,    -1,    84,    -1,
      -1,    87,    88,    -1,    -1,    -1,    -1,    -1,    -1,    95,
      -1,    97,    98,    -1,    -1,   101,    -1,    -1,   104,   105,
     106,   107,    -1,    -1,   110,   111,    44,    -1,    46,    47,
      48,    49,    50,    51,    52,    -1,    -1,    55,    -1,    -1,
      -1,    59,    60,    -1,    -1,    63,    -1,    -1,    66,    67,
      68,    69,    -1,    71,    72,    73,    74,    -1,    -1,    77,
      78,    -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,    87,
      88,    -1,    -1,    -1,    -1,    -1,    -1,    95,    -1,    97,
      98,    -1,    -1,   101,    -1,    -1,   104,   105,   106,   107,
      -1,    -1,   110,   111,    44,    -1,    46,    47,    -1,    49,
      50,    51,    52,    -1,    -1,    55,    -1,    -1,    -1,    59,
      60,    -1,    -1,    -1,    -1,    -1,    66,    67,    68,    69,
      -1,    71,    72,    73,    74,    -1,    -1,    77,    78,    -1,
      -1,    -1,    -1,    -1,    84,    -1,    -1,    87,    88,    -1,
      -1,    -1,    -1,    -1,    -1,    95,    -1,    97,    98,    -1,
      -1,   101,    -1,    -1,   104,   105,   106,   107,    -1,    -1,
     110,   111,    44,    -1,    46,    47,    -1,    49,    50,    51,
      52,    -1,    -1,    55,    -1,    -1,    -1,    59,    60,    -1,
      -1,    -1,    -1,    -1,    66,    67,    68,    69,    -1,    71,
      72,    73,    74,    -1,    -1,    77,    78,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    -1,    87,    88,    -1,    -1,    -1,
      -1,    -1,    -1,    95,    -1,    97,    98,    -1,    -1,   101,
      -1,    -1,   104,   105,   106,   107,    -1,    -1,   110,   111,
      44,    -1,    46,    47,    -1,    49,    50,    51,    52,    -1,
      -1,    55,    -1,    -1,    -1,    59,    60,    -1,    -1,    -1,
      -1,    -1,    66,    67,    68,    69,    -1,    71,    72,    73,
      74,    -1,    -1,    77,    78,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    -1,    87,    88,    -1,    -1,    -1,    -1,    -1,
      -1,    95,    -1,    97,    98,    -1,    -1,   101,    -1,    -1,
     104,   105,   106,   107,    -1,    -1,   110,   111,    44,    -1,
      46,    47,    -1,    49,    50,    51,    52,    -1,    -1,    55,
      -1,    -1,    -1,    59,    60,    -1,    -1,    -1,    -1,    -1,
      66,    67,    68,    69,    -1,    71,    72,    73,    74,    -1,
      -1,    77,    78,    -1,    -1,    -1,    -1,    -1,    84,    -1,
      -1,    87,    88,    -1,    -1,    -1,    -1,    -1,    -1,    95,
      -1,    97,    98,    -1,    -1,   101,    -1,    -1,   104,   105,
     106,   107,    -1,    -1,   110,   111,    44,    -1,    46,    47,
      -1,    49,    50,    51,    52,    -1,    -1,    55,    -1,    -1,
      -1,    59,    60,    -1,    -1,    -1,    -1,    -1,    66,    67,
      68,    69,    -1,    71,    72,    73,    74,    -1,    -1,    77,
      78,    -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,    87,
      88,    -1,    -1,    -1,    -1,    -1,    -1,    95,    -1,    97,
      98,    -1,    -1,   101,    -1,    -1,   104,   105,   106,   107,
      -1,    -1,   110,   111,    44,    -1,    46,    47,    -1,    49,
      50,    51,    52,    -1,    -1,    55,    -1,    -1,    -1,    59,
      60,    -1,    -1,    -1,    -1,    -1,    66,    67,    68,    69,
      -1,    71,    72,    73,    74,    -1,    -1,    77,    78,    -1,
      -1,    -1,    -1,    -1,    84,    -1,    -1,    87,    88,    -1,
      -1,    -1,    -1,    -1,    -1,    95,    -1,    97,    98,    -1,
      -1,   101,    -1,    -1,   104,   105,   106,   107,    -1,    -1,
     110,   111,    44,    -1,    46,    47,    -1,    49,    50,    51,
      52,    -1,    -1,    55,    -1,    -1,    -1,    59,    60,    -1,
      -1,    -1,    -1,    -1,    66,    67,    68,    69,    -1,    71,
      72,    73,    74,    -1,    -1,    77,    78,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    -1,    87,    88,    -1,    -1,    -1,
      -1,    -1,    -1,    95,    -1,    97,    -1,    -1,    -1,   101,
      -1,    -1,   104,   105,   106,   107,    -1,    -1,   110,   111,
      44,    -1,    46,    47,    -1,    49,    50,    51,    52,    -1,
      -1,    55,    -1,    -1,    -1,    59,    60,    -1,    -1,    -1,
      -1,    -1,    66,    67,    -1,    69,    -1,    71,    72,    73,
      74,    -1,    -1,    77,    78,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    -1,    87,    88,    -1,    -1,    -1,    -1,    -1,
      -1,    95,    -1,    97,    -1,    -1,    -1,   101,    -1,    -1,
     104,   105,   106,   107,    -1,    -1,   110,   111,    44,    -1,
      46,    47,    -1,    49,    50,    51,    52,    -1,    -1,    55,
      -1,    -1,    -1,    59,    60,    -1,    -1,    -1,    -1,    -1,
      66,    67,    -1,    69,    -1,    71,    72,    73,    74,    -1,
      -1,    77,    78,    -1,    -1,    -1,    -1,    -1,    84,    -1,
      -1,    87,    88,    46,    47,    -1,    -1,    -1,    51,    95,
      -1,    97,    -1,    -1,    -1,   101,    -1,    60,   104,   105,
     106,   107,    -1,    66,   110,   111,    -1,    -1,    -1,    -1,
      73,    -1,    -1,    51,    77,    -1,    -1,    -1,    -1,    -1,
      -1,    84,    60,    -1,    87,    88,    -1,    -1,    66,    -1,
      -1,    -1,    95,    -1,    -1,    73,    -1,    -1,    -1,    77,
      -1,   104,   105,   106,   107,    -1,    84,   110,   111,    87,
      88,    -1,    -1,    91,    92,    -1,    -1,    95,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   104,   105,   106,   107,
      -1,    -1,   110,   111
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned short int yystos[] =
{
       0,    44,    56,    62,    68,    76,   101,   113,   126,   127,
     128,   129,   130,   131,   132,   133,   134,   135,   166,   187,
      88,   122,   123,   124,   125,   125,   125,   122,     0,   128,
     130,   133,   127,   128,    44,    62,    68,   101,   103,    64,
     167,   171,    64,   138,   101,   103,   128,   125,   125,     5,
     125,   118,   120,   122,    97,   172,   102,   169,   118,   119,
      53,   139,   168,   171,   138,   101,    51,    60,    84,    87,
      98,   115,   116,   117,   118,   121,   122,   134,   135,   145,
     152,   166,   173,   174,   175,   176,   187,   120,   172,   120,
     140,   137,   172,   170,   139,   125,   153,   125,   146,   147,
     148,   153,    99,   237,   237,    60,   115,   101,    98,   174,
     102,    97,   141,   172,   136,    95,    54,    99,   156,   101,
     102,    94,    99,   156,   100,    99,   153,   146,   153,   120,
      44,    97,    98,   123,   134,   135,   142,   143,   144,   145,
     150,   152,   159,   160,   161,   162,   166,   179,   187,   141,
      96,   115,   134,   154,   155,   119,   157,   100,   125,   147,
       3,     4,    46,    47,    60,    66,    73,    77,    91,    92,
      95,    97,   104,   105,   106,   107,   110,   111,   114,   116,
     121,   122,   149,   177,   225,   226,   227,   228,   229,   232,
     234,   238,   239,   240,   241,   242,   243,   244,   245,   246,
     247,   248,   249,   250,   251,   252,   253,   254,   255,   256,
     257,   258,   259,   260,   261,   262,   264,   100,   100,   156,
     101,   156,    44,    49,    50,    52,    55,    59,    67,    69,
      71,    72,    74,    78,    95,    98,   115,   116,   121,   122,
     125,   134,   135,   179,   180,   181,   182,   183,   184,   186,
     187,   188,   189,   191,   192,   193,   194,   196,   202,   203,
     205,   206,   207,   209,   210,   214,   215,   216,   217,   218,
     219,   220,   221,   228,   239,   241,   242,   243,   245,   246,
     261,    95,   162,    98,   143,   151,   179,   156,   148,   115,
      96,   102,   102,   122,   238,   240,   244,   244,   244,   244,
     103,   103,   116,   118,   119,   244,   244,   116,   122,   264,
      98,   102,   149,   178,   103,   103,    95,    99,   103,   103,
      99,   125,    46,    47,     5,     6,     7,     3,     4,     8,
       9,    10,    18,    19,    20,    21,    58,    16,    17,    11,
      12,    13,    14,    15,    89,    93,    94,   263,    95,   264,
     101,   125,   101,   264,    95,    95,   179,    95,   101,   125,
       1,   264,   264,   146,    90,   115,    98,   181,   101,    44,
     184,   101,   184,   184,   134,   183,   192,   211,   213,   101,
      95,    96,   154,   156,   101,   158,   179,    97,   163,   148,
     155,   119,    68,   125,    99,   235,   236,   237,   235,   237,
      95,    96,   237,   237,    96,    98,    98,   102,    68,    68,
      96,   233,   264,   264,    68,    73,    77,    73,   125,   264,
      95,   244,   244,   244,   249,   249,   250,   250,   250,   251,
     251,   251,   251,   116,   117,   252,   252,   253,   254,   255,
     256,   257,   264,   260,   264,   101,   101,   101,   264,   264,
      61,    65,   222,   223,   224,   101,     1,    90,   101,    96,
     146,    67,   102,   101,   264,   264,    96,   163,    66,    77,
      98,   122,   164,   165,   180,   101,    95,   264,   236,   237,
     177,   237,   177,    96,   233,   244,    96,    96,   247,    98,
     149,    96,   102,   100,    95,   100,    96,   233,    90,    96,
      96,    96,    95,   179,   223,   224,   264,    95,   192,   212,
     213,   101,    96,   101,   103,    98,   180,    95,    98,    96,
     233,   100,   230,    96,   244,   247,     1,   264,    96,   233,
     141,    96,   259,    49,   184,   185,   186,   188,   190,   195,
     202,   204,   208,   210,    97,   197,   155,   101,   264,    96,
     212,     1,   179,    66,    98,    96,   233,    96,   141,   231,
      96,   141,    95,    57,   185,   185,   101,    48,    63,    98,
     198,   199,   200,   201,    96,    96,   184,    96,    95,   101,
      96,   141,   264,   184,   101,   264,    90,   264,   265,    98,
     199,   200,    98,   180,   201,   179,   101,   184,    96,   233,
     101,    96,   212,   101,    90,    98,   101,    96,   185,    96,
     212,   101,    57,   185,    96,   185,   185
};

#if ! defined (YYSIZE_T) && defined (__SIZE_TYPE__)
# define YYSIZE_T __SIZE_TYPE__
#endif
#if ! defined (YYSIZE_T) && defined (size_t)
# define YYSIZE_T size_t
#endif
#if ! defined (YYSIZE_T)
# if defined (__STDC__) || defined (__cplusplus)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# endif
#endif
#if ! defined (YYSIZE_T)
# define YYSIZE_T unsigned int
#endif

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { 								\
      yyerror ("syntax error: cannot back up");\
      YYERROR;							\
    }								\
while (0)


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (N)								\
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (0)
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
              (Loc).first_line, (Loc).first_column,	\
              (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (&yylval, YYLEX_PARAM)
#else
# define YYLEX yylex (&yylval)
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (0)

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)		\
do {								\
  if (yydebug)							\
    {								\
      YYFPRINTF (stderr, "%s ", Title);				\
      yysymprint (stderr, 					\
                  Type, Value);	\
      YYFPRINTF (stderr, "\n");					\
    }								\
} while (0)

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yy_stack_print (short int *bottom, short int *top)
#else
static void
yy_stack_print (bottom, top)
    short int *bottom;
    short int *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (/* Nothing. */; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yy_reduce_print (int yyrule)
#else
static void
yy_reduce_print (yyrule)
    int yyrule;
#endif
{
  int yyi;
  unsigned int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %u), ",
             yyrule - 1, yylno);
  /* Print the symbols being reduced, and their result.  */
  for (yyi = yyprhs[yyrule]; 0 <= yyrhs[yyi]; yyi++)
    YYFPRINTF (stderr, "%s ", yytname [yyrhs[yyi]]);
  YYFPRINTF (stderr, "-> %s\n", yytname [yyr1[yyrule]]);
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (Rule);		\
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   SIZE_MAX < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined (__GLIBC__) && defined (_STRING_H)
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
#   if defined (__STDC__) || defined (__cplusplus)
yystrlen (const char *yystr)
#   else
yystrlen (yystr)
     const char *yystr;
#   endif
{
  register const char *yys = yystr;

  while (*yys++ != '\0')
    continue;

  return yys - yystr - 1;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined (__GLIBC__) && defined (_STRING_H) && defined (_GNU_SOURCE)
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
#   if defined (__STDC__) || defined (__cplusplus)
yystpcpy (char *yydest, const char *yysrc)
#   else
yystpcpy (yydest, yysrc)
     char *yydest;
     const char *yysrc;
#   endif
{
  register char *yyd = yydest;
  register const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

#endif /* !YYERROR_VERBOSE */



#if YYDEBUG
/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yysymprint (FILE *yyoutput, int yytype, YYSTYPE *yyvaluep)
#else
static void
yysymprint (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;

  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);


# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
  switch (yytype)
    {
      default:
        break;
    }
  YYFPRINTF (yyoutput, ")");
}

#endif /* ! YYDEBUG */
/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yymsg, yytype, yyvaluep)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
        break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
int yyparse (void *YYPARSE_PARAM);
# else
int yyparse ();
# endif
#else /* ! YYPARSE_PARAM */
#if defined (__STDC__) || defined (__cplusplus)
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */






/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
int yyparse (void *YYPARSE_PARAM)
# else
int yyparse (YYPARSE_PARAM)
  void *YYPARSE_PARAM;
# endif
#else /* ! YYPARSE_PARAM */
#if defined (__STDC__) || defined (__cplusplus)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{
  /* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;

  register int yystate;
  register int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  short int yyssa[YYINITDEPTH];
  short int *yyss = yyssa;
  register short int *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  register YYSTYPE *yyvsp;



#define YYPOPSTACK   (yyvsp--, yyssp--)

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* When reducing, the number of symbols on the RHS of the reduced
     rule.  */
  int yylen;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;


  yyvsp[0] = yylval;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed. so pushing a state here evens the stacks.
     */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack. Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	short int *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow ("parser stack overflow",
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyoverflowlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyoverflowlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	short int *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyoverflowlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

/* Do appropriate processing given the current state.  */
/* Read a look-ahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to look-ahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;


  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  yystate = yyn;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 11:
#line 229 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    {
		  /* use preset global here. FIXME */
		  (yyval.node) = xstrdup ("int");
		;}
    break;

  case 12:
#line 234 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    {
		  /* use preset global here. FIXME */
		  (yyval.node) = xstrdup ("double");
		;}
    break;

  case 13:
#line 239 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    {
		  /* use preset global here. FIXME */
		  (yyval.node) = xstrdup ("boolean");
		;}
    break;

  case 19:
#line 264 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    {
	          while (bracket_count-- > 0) 
		    (yyval.node) = concat ("[", (yyvsp[-1].node), NULL);
		;}
    break;

  case 20:
#line 269 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    {
	          while (bracket_count-- > 0) 
		    (yyval.node) = concat ("[", (yyvsp[-1].node), NULL);
		;}
    break;

  case 24:
#line 287 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { 
		  (yyval.node) = concat ((yyvsp[-2].node), ".", (yyvsp[0].node), NULL);
		;}
    break;

  case 38:
#line 319 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { package_name = (yyvsp[-1].node); ;}
    break;

  case 46:
#line 346 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { 
		  if ((yyvsp[0].value) == PUBLIC_TK)
		    modifier_value++;
                  if ((yyvsp[0].value) == STATIC_TK)
                    modifier_value++;
	          USE_ABSORBER;
		;}
    break;

  case 47:
#line 354 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { 
		  if ((yyvsp[0].value) == PUBLIC_TK)
		    modifier_value++;
                  if ((yyvsp[0].value) == STATIC_TK)
                    modifier_value++;
		  USE_ABSORBER;
		;}
    break;

  case 48:
#line 366 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { 
		  report_class_declaration((yyvsp[-2].node));
		  modifier_value = 0;
                ;}
    break;

  case 50:
#line 372 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { report_class_declaration((yyvsp[-2].node)); ;}
    break;

  case 56:
#line 386 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 57:
#line 388 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 58:
#line 393 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { pop_class_context (); ;}
    break;

  case 59:
#line 395 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { pop_class_context (); ;}
    break;

  case 71:
#line 421 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 72:
#line 423 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { modifier_value = 0; ;}
    break;

  case 77:
#line 439 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { bracket_count = 0; USE_ABSORBER; ;}
    break;

  case 78:
#line 441 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++bracket_count; ;}
    break;

  case 81:
#line 452 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++method_depth; ;}
    break;

  case 82:
#line 454 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { --method_depth; ;}
    break;

  case 83:
#line 459 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 85:
#line 462 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { modifier_value = 0; ;}
    break;

  case 86:
#line 464 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { 
                  report_main_declaration ((yyvsp[-1].declarator));
		  modifier_value = 0;
		;}
    break;

  case 87:
#line 472 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { 
		  struct method_declarator *d;
		  NEW_METHOD_DECLARATOR (d, (yyvsp[-2].node), NULL);
		  (yyval.declarator) = d;
		;}
    break;

  case 88:
#line 478 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { 
		  struct method_declarator *d;
		  NEW_METHOD_DECLARATOR (d, (yyvsp[-3].node), (yyvsp[-1].node));
		  (yyval.declarator) = d;
		;}
    break;

  case 91:
#line 489 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    {
		  (yyval.node) = concat ((yyvsp[-2].node), ",", (yyvsp[0].node), NULL);
		;}
    break;

  case 92:
#line 496 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { 
		  USE_ABSORBER;
		  if (bracket_count)
		    {
		      int i;
		      char *n = xmalloc (bracket_count + 1 + strlen ((yyval.node)));
		      for (i = 0; i < bracket_count; ++i)
			n[i] = '[';
		      strcpy (n + bracket_count, (yyval.node));
		      (yyval.node) = n;
		    }
		  else
		    (yyval.node) = (yyvsp[-1].node);
		;}
    break;

  case 93:
#line 511 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    {
		  if (bracket_count)
		    {
		      int i;
		      char *n = xmalloc (bracket_count + 1 + strlen ((yyvsp[-1].node)));
		      for (i = 0; i < bracket_count; ++i)
			n[i] = '[';
		      strcpy (n + bracket_count, (yyvsp[-1].node));
		      (yyval.node) = n;
		    }
		  else
		    (yyval.node) = (yyvsp[-1].node);
		;}
    break;

  case 96:
#line 532 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 97:
#line 534 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 101:
#line 549 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 103:
#line 560 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { modifier_value = 0; ;}
    break;

  case 105:
#line 565 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { modifier_value = 0; ;}
    break;

  case 106:
#line 572 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 107:
#line 574 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 114:
#line 591 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 115:
#line 593 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 118:
#line 605 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { report_class_declaration ((yyvsp[0].node)); modifier_value = 0; ;}
    break;

  case 120:
#line 608 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { report_class_declaration ((yyvsp[0].node)); modifier_value = 0; ;}
    break;

  case 122:
#line 611 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { report_class_declaration ((yyvsp[-1].node)); modifier_value = 0; ;}
    break;

  case 124:
#line 614 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { report_class_declaration ((yyvsp[-1].node)); modifier_value = 0; ;}
    break;

  case 128:
#line 625 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { pop_class_context (); ;}
    break;

  case 129:
#line 627 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { pop_class_context (); ;}
    break;

  case 153:
#line 687 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 154:
#line 689 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { modifier_value = 0; ;}
    break;

  case 179:
#line 730 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 190:
#line 758 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 191:
#line 763 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 192:
#line 768 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 200:
#line 788 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 205:
#line 803 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 209:
#line 820 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 215:
#line 838 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 226:
#line 863 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 229:
#line 872 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 232:
#line 879 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    {yyerror ("Missing term"); RECOVER;;}
    break;

  case 233:
#line 881 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    {yyerror ("';' expected"); RECOVER;;}
    break;

  case 236:
#line 890 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 242:
#line 905 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 243:
#line 909 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 254:
#line 931 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 255:
#line 936 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 256:
#line 938 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 257:
#line 940 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 258:
#line 942 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 266:
#line 957 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { report_class_declaration (anonymous_context); ;}
    break;

  case 268:
#line 960 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { report_class_declaration (anonymous_context); ;}
    break;

  case 270:
#line 966 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 284:
#line 998 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { bracket_count = 1; ;}
    break;

  case 285:
#line 1000 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { bracket_count++; ;}
    break;

  case 288:
#line 1013 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ++complexity; ;}
    break;

  case 289:
#line 1015 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ++complexity; ;}
    break;

  case 290:
#line 1016 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 291:
#line 1017 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 292:
#line 1018 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 293:
#line 1019 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 294:
#line 1024 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 297:
#line 1031 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;

  case 344:
#line 1127 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 346:
#line 1133 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 348:
#line 1139 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { ++complexity; ;}
    break;

  case 352:
#line 1153 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"
    { USE_ABSORBER; ;}
    break;


    }

/* Line 1037 of yacc.c.  */
#line 3027 "java/parse-scan.c"

  yyvsp -= yylen;
  yyssp -= yylen;


  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (YYPACT_NINF < yyn && yyn < YYLAST)
	{
	  YYSIZE_T yysize = 0;
	  int yytype = YYTRANSLATE (yychar);
	  const char* yyprefix;
	  char *yymsg;
	  int yyx;

	  /* Start YYX at -YYN if negative to avoid negative indexes in
	     YYCHECK.  */
	  int yyxbegin = yyn < 0 ? -yyn : 0;

	  /* Stay within bounds of both yycheck and yytname.  */
	  int yychecklim = YYLAST - yyn;
	  int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
	  int yycount = 0;

	  yyprefix = ", expecting ";
	  for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	    if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	      {
		yysize += yystrlen (yyprefix) + yystrlen (yytname [yyx]);
		yycount += 1;
		if (yycount == 5)
		  {
		    yysize = 0;
		    break;
		  }
	      }
	  yysize += (sizeof ("syntax error, unexpected ")
		     + yystrlen (yytname[yytype]));
	  yymsg = (char *) YYSTACK_ALLOC (yysize);
	  if (yymsg != 0)
	    {
	      char *yyp = yystpcpy (yymsg, "syntax error, unexpected ");
	      yyp = yystpcpy (yyp, yytname[yytype]);

	      if (yycount < 5)
		{
		  yyprefix = ", expecting ";
		  for (yyx = yyxbegin; yyx < yyxend; ++yyx)
		    if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
		      {
			yyp = yystpcpy (yyp, yyprefix);
			yyp = yystpcpy (yyp, yytname[yyx]);
			yyprefix = " or ";
		      }
		}
	      yyerror (yymsg);
	      YYSTACK_FREE (yymsg);
	    }
	  else
	    yyerror ("syntax error; also virtual memory exhausted");
	}
      else
#endif /* YYERROR_VERBOSE */
	yyerror ("syntax error");
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* If at end of input, pop the error token,
	     then the rest of the stack, then return failure.  */
	  if (yychar == YYEOF)
	     for (;;)
	       {

		 YYPOPSTACK;
		 if (yyssp == yyss)
		   YYABORT;
		 yydestruct ("Error: popping",
                             yystos[*yyssp], yyvsp);
	       }
        }
      else
	{
	  yydestruct ("Error: discarding", yytoken, &yylval);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

#ifdef __GNUC__
  /* Pacify GCC when the user code never invokes YYERROR and the label
     yyerrorlab therefore never appears in user code.  */
  if (0)
     goto yyerrorlab;
#endif

yyvsp -= yylen;
  yyssp -= yylen;
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping", yystos[yystate], yyvsp);
      YYPOPSTACK;
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;


  /* Shift the error token. */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yydestruct ("Error: discarding lookahead",
              yytoken, &yylval);
  yychar = YYEMPTY;
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*----------------------------------------------.
| yyoverflowlab -- parser overflow comes here.  |
`----------------------------------------------*/
yyoverflowlab:
  yyerror ("parser stack overflow");
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
  return yyresult;
}


#line 1171 "/scratch/mitchell/gcc-releases/gcc-4.1.1/gcc-4.1.1/gcc/java/parse-scan.y"


/* Create a new parser context */

void
java_push_parser_context (void)
{
  struct parser_ctxt *new = xcalloc (1, sizeof (struct parser_ctxt));

  new->next = ctxp;
  ctxp = new;
}  

static void
push_class_context (const char *name)
{
  struct class_context *ctx;

  ctx = xmalloc (sizeof (struct class_context));
  ctx->name = (char *) name;
  ctx->next = current_class_context;
  current_class_context = ctx;
}

static void
pop_class_context (void)
{
  struct class_context *ctx;

  if (current_class_context == NULL)
    return;

  ctx = current_class_context->next;
  if (current_class_context->name != anonymous_context)
    free (current_class_context->name);
  free (current_class_context);

  current_class_context = ctx;
  if (current_class_context == NULL)
    anonymous_count = 0;
}

/* Recursively construct the class name.  This is just a helper
   function for get_class_name().  */
static int
make_class_name_recursive (struct obstack *stack, struct class_context *ctx)
{
  if (! ctx)
    return 0;

  make_class_name_recursive (stack, ctx->next);

  /* Replace an anonymous context with the appropriate counter value.  */
  if (ctx->name == anonymous_context)
    {
      char buf[50];
      ++anonymous_count;
      sprintf (buf, "%d", anonymous_count);
      ctx->name = xstrdup (buf);
    }

  obstack_grow (stack, ctx->name, strlen (ctx->name));
  obstack_1grow (stack, '$');

  return ISDIGIT (ctx->name[0]);
}

/* Return a newly allocated string holding the name of the class.  */
static char *
get_class_name (void)
{
  char *result;
  int last_was_digit;
  struct obstack name_stack;

  obstack_init (&name_stack);

  /* Duplicate the logic of parse.y:maybe_make_nested_class_name().  */
  last_was_digit = make_class_name_recursive (&name_stack,
					      current_class_context->next);

  if (! last_was_digit
      && method_depth
      && current_class_context->name != anonymous_context)
    {
      char buf[50];
      ++anonymous_count;
      sprintf (buf, "%d", anonymous_count);
      obstack_grow (&name_stack, buf, strlen (buf));
      obstack_1grow (&name_stack, '$');
    }

  if (current_class_context->name == anonymous_context)
    {
      char buf[50];
      ++anonymous_count;
      sprintf (buf, "%d", anonymous_count);
      current_class_context->name = xstrdup (buf);
      obstack_grow0 (&name_stack, buf, strlen (buf));
    }
  else
    obstack_grow0 (&name_stack, current_class_context->name,
		   strlen (current_class_context->name));

  result = xstrdup (obstack_finish (&name_stack));
  obstack_free (&name_stack, NULL);

  return result;
}

/* Actions defined here */

static void
report_class_declaration (const char * name)
{
  extern int flag_dump_class, flag_list_filename;

  push_class_context (name);
  if (flag_dump_class)
    {
      char *name = get_class_name ();

      if (!previous_output)
	{
	  if (flag_list_filename)
	    fprintf (out, "%s: ", main_input_filename);
	  previous_output = 1;
	}

      if (package_name)
	fprintf (out, "%s.%s ", package_name, name);
      else
	fprintf (out, "%s ", name);

      free (name);
    }
}

static void
report_main_declaration (struct method_declarator *declarator)
{
  extern int flag_find_main;

  if (flag_find_main
      && modifier_value == 2
      && !strcmp (declarator->method_name, "main") 
      && declarator->args 
      && declarator->args [0] == '[' 
      && (! strcmp (declarator->args+1, "String")
	  || ! strcmp (declarator->args + 1, "java.lang.String"))
      && current_class_context)
    {
      if (!previous_output)
	{
	  char *name = get_class_name ();
	  if (package_name)
	    fprintf (out, "%s.%s ", package_name, name);
	  else
	    fprintf (out, "%s", name);
	  free (name);
	  previous_output = 1;
	}
    }
}

void
report (void)
{
  extern int flag_complexity;
  if (flag_complexity)
    fprintf (out, "%s %d\n", main_input_filename, complexity);
}

/* Reset global status used by the report functions.  */

void
reset_report (void)
{
  previous_output = 0;
  package_name = NULL;
  current_class_context = NULL;
  complexity = 0;
}

void
yyerror (const char *msg ATTRIBUTE_UNUSED)
{
  fprintf (stderr, "%s: %s\n", main_input_filename, msg);
  exit (1);
}

#ifdef __XGETTEXT__
/* Depending on the version of Bison used to compile this grammar,
   it may issue generic diagnostics spelled "syntax error" or
   "parse error".  To prevent this from changing the translation
   template randomly, we list all the variants of this particular
   diagnostic here.  Translators: there is no fine distinction
   between diagnostics with "syntax error" in them, and diagnostics
   with "parse error" in them.  It's okay to give them both the same
   translation.  */
const char d1[] = N_("syntax error");
const char d2[] = N_("parse error");
const char d3[] = N_("syntax error; also virtual memory exhausted");
const char d4[] = N_("parse error; also virtual memory exhausted");
const char d5[] = N_("syntax error: cannot back up");
const char d6[] = N_("parse error: cannot back up");
#endif



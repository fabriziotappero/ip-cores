/* A Bison parser, made by GNU Bison 1.875c.  */

/* Skeleton parser for Yacc-like parsing with Bison,
   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003 Free Software Foundation, Inc.

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
#define YYPURE 0

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     INT = 258,
     FLOAT = 259,
     NAME = 260,
     STRUCT = 261,
     CLASS = 262,
     UNION = 263,
     ENUM = 264,
     SIZEOF = 265,
     UNSIGNED = 266,
     COLONCOLON = 267,
     TEMPLATE = 268,
     ERROR = 269,
     NEW = 270,
     DELETE = 271,
     OPERATOR = 272,
     STATIC_CAST = 273,
     REINTERPRET_CAST = 274,
     DYNAMIC_CAST = 275,
     SIGNED_KEYWORD = 276,
     LONG = 277,
     SHORT = 278,
     INT_KEYWORD = 279,
     CONST_KEYWORD = 280,
     VOLATILE_KEYWORD = 281,
     DOUBLE_KEYWORD = 282,
     BOOL = 283,
     ELLIPSIS = 284,
     RESTRICT = 285,
     VOID = 286,
     FLOAT_KEYWORD = 287,
     CHAR = 288,
     WCHAR_T = 289,
     ASSIGN_MODIFY = 290,
     TRUEKEYWORD = 291,
     FALSEKEYWORD = 292,
     DEMANGLER_SPECIAL = 293,
     CONSTRUCTION_VTABLE = 294,
     CONSTRUCTION_IN = 295,
     GLOBAL = 296,
     OROR = 297,
     ANDAND = 298,
     NOTEQUAL = 299,
     EQUAL = 300,
     GEQ = 301,
     LEQ = 302,
     RSH = 303,
     LSH = 304,
     DECREMENT = 305,
     INCREMENT = 306,
     UNARY = 307,
     ARROW = 308
   };
#endif
#define INT 258
#define FLOAT 259
#define NAME 260
#define STRUCT 261
#define CLASS 262
#define UNION 263
#define ENUM 264
#define SIZEOF 265
#define UNSIGNED 266
#define COLONCOLON 267
#define TEMPLATE 268
#define ERROR 269
#define NEW 270
#define DELETE 271
#define OPERATOR 272
#define STATIC_CAST 273
#define REINTERPRET_CAST 274
#define DYNAMIC_CAST 275
#define SIGNED_KEYWORD 276
#define LONG 277
#define SHORT 278
#define INT_KEYWORD 279
#define CONST_KEYWORD 280
#define VOLATILE_KEYWORD 281
#define DOUBLE_KEYWORD 282
#define BOOL 283
#define ELLIPSIS 284
#define RESTRICT 285
#define VOID 286
#define FLOAT_KEYWORD 287
#define CHAR 288
#define WCHAR_T 289
#define ASSIGN_MODIFY 290
#define TRUEKEYWORD 291
#define FALSEKEYWORD 292
#define DEMANGLER_SPECIAL 293
#define CONSTRUCTION_VTABLE 294
#define CONSTRUCTION_IN 295
#define GLOBAL 296
#define OROR 297
#define ANDAND 298
#define NOTEQUAL 299
#define EQUAL 300
#define GEQ 301
#define LEQ 302
#define RSH 303
#define LSH 304
#define DECREMENT 305
#define INCREMENT 306
#define UNARY 307
#define ARROW 308




/* Copy the first part of user declarations.  */
#line 32 "cp-name-parser.y"


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "safe-ctype.h"
#include "libiberty.h"
#include "demangle.h"

/* Bison does not make it easy to create a parser without global
   state, unfortunately.  Here are all the global variables used
   in this parser.  */

/* LEXPTR is the current pointer into our lex buffer.  PREV_LEXPTR
   is the start of the last token lexed, only used for diagnostics.
   ERROR_LEXPTR is the first place an error occurred.  GLOBAL_ERRMSG
   is the first error message encountered.  */

static const char *lexptr, *prev_lexptr, *error_lexptr, *global_errmsg;

/* The components built by the parser are allocated ahead of time,
   and cached in this structure.  */

#define ALLOC_CHUNK 100

struct demangle_info {
  int used;
  struct demangle_info *prev, *next;
  struct demangle_component comps[ALLOC_CHUNK];
};

static struct demangle_info *demangle_info;

static struct demangle_component *
d_grab (void)
{
  struct demangle_info *more;

  if (demangle_info->used >= ALLOC_CHUNK)
    {
      if (demangle_info->next == NULL)
	{
	  more = xmalloc (sizeof (struct demangle_info));
	  more->prev = demangle_info;
	  more->next = NULL;
	  demangle_info->next = more;
	}
      else
	more = demangle_info->next;

      more->used = 0;
      demangle_info = more;
    }
  return &demangle_info->comps[demangle_info->used++];
}

/* The parse tree created by the parser is stored here after a successful
   parse.  */

static struct demangle_component *global_result;

/* Prototypes for helper functions used when constructing the parse
   tree.  */

static struct demangle_component *d_qualify (struct demangle_component *, int,
					     int);

static struct demangle_component *d_int_type (int);

static struct demangle_component *d_unary (const char *,
					   struct demangle_component *);
static struct demangle_component *d_binary (const char *,
					    struct demangle_component *,
					    struct demangle_component *);

/* Flags passed to d_qualify.  */

#define QUAL_CONST 1
#define QUAL_RESTRICT 2
#define QUAL_VOLATILE 4

/* Flags passed to d_int_type.  */

#define INT_CHAR	(1 << 0)
#define INT_SHORT	(1 << 1)
#define INT_LONG	(1 << 2)
#define INT_LLONG	(1 << 3)

#define INT_SIGNED	(1 << 4)
#define INT_UNSIGNED	(1 << 5)

/* Remap normal yacc parser interface names (yyparse, yylex, yyerror, etc),
   as well as gratuitiously global symbol names, so we can have multiple
   yacc generated parsers in gdb.  Note that these are only the variables
   produced by yacc.  If other parser generators (bison, byacc, etc) produce
   additional global names that conflict at link time, then those parser
   generators need to be fixed instead of adding those names to this list. */

#define	yymaxdepth cpname_maxdepth
#define	yyparse	cpname_parse
#define	yylex	cpname_lex
#define	yyerror	cpname_error
#define	yylval	cpname_lval
#define	yychar	cpname_char
#define	yydebug	cpname_debug
#define	yypact	cpname_pact	
#define	yyr1	cpname_r1			
#define	yyr2	cpname_r2			
#define	yydef	cpname_def		
#define	yychk	cpname_chk		
#define	yypgo	cpname_pgo		
#define	yyact	cpname_act		
#define	yyexca	cpname_exca
#define yyerrflag cpname_errflag
#define yynerrs	cpname_nerrs
#define	yyps	cpname_ps
#define	yypv	cpname_pv
#define	yys	cpname_s
#define	yy_yys	cpname_yys
#define	yystate	cpname_state
#define	yytmp	cpname_tmp
#define	yyv	cpname_v
#define	yy_yyv	cpname_yyv
#define	yyval	cpname_val
#define	yylloc	cpname_lloc
#define yyreds	cpname_reds		/* With YYDEBUG defined */
#define yytoks	cpname_toks		/* With YYDEBUG defined */
#define yyname	cpname_name		/* With YYDEBUG defined */
#define yyrule	cpname_rule		/* With YYDEBUG defined */
#define yylhs	cpname_yylhs
#define yylen	cpname_yylen
#define yydefred cpname_yydefred
#define yydgoto	cpname_yydgoto
#define yysindex cpname_yysindex
#define yyrindex cpname_yyrindex
#define yygindex cpname_yygindex
#define yytable	 cpname_yytable
#define yycheck	 cpname_yycheck

int yyparse (void);
static int yylex (void);
static void yyerror (char *);

/* Enable yydebug for the stand-alone parser.  */
#ifdef TEST_CPNAMES
# define YYDEBUG	1
#endif

/* Helper functions.  These wrap the demangler tree interface, handle
   allocation from our global store, and return the allocated component.  */

static struct demangle_component *
fill_comp (enum demangle_component_type d_type, struct demangle_component *lhs,
	   struct demangle_component *rhs)
{
  struct demangle_component *ret = d_grab ();
  cplus_demangle_fill_component (ret, d_type, lhs, rhs);
  return ret;
}

static struct demangle_component *
make_empty (enum demangle_component_type d_type)
{
  struct demangle_component *ret = d_grab ();
  ret->type = d_type;
  return ret;
}

static struct demangle_component *
make_operator (const char *name, int args)
{
  struct demangle_component *ret = d_grab ();
  cplus_demangle_fill_operator (ret, name, args);
  return ret;
}

static struct demangle_component *
make_dtor (enum gnu_v3_dtor_kinds kind, struct demangle_component *name)
{
  struct demangle_component *ret = d_grab ();
  cplus_demangle_fill_dtor (ret, kind, name);
  return ret;
}

static struct demangle_component *
make_builtin_type (const char *name)
{
  struct demangle_component *ret = d_grab ();
  cplus_demangle_fill_builtin_type (ret, name);
  return ret;
}

static struct demangle_component *
make_name (const char *name, int len)
{
  struct demangle_component *ret = d_grab ();
  cplus_demangle_fill_name (ret, name, len);
  return ret;
}

#define d_left(dc) (dc)->u.s_binary.left
#define d_right(dc) (dc)->u.s_binary.right



/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

#if ! defined (YYSTYPE) && ! defined (YYSTYPE_IS_DECLARED)
#line 240 "cp-name-parser.y"
typedef union YYSTYPE {
    struct demangle_component *comp;
    struct nested {
      struct demangle_component *comp;
      struct demangle_component **last;
    } nested;
    struct {
      struct demangle_component *comp, *last;
    } nested1;
    struct {
      struct demangle_component *comp, **last;
      struct nested fn;
      struct demangle_component *start;
      int fold_flag;
    } abstract;
    int lval;
    struct {
      int val;
      struct demangle_component *type;
    } typed_val_int;
    const char *opname;
  } YYSTYPE;
/* Line 191 of yacc.c.  */
#line 412 "cp-name-parser.c.tmp"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */
#line 316 "cp-name-parser.y"

enum {
  GLOBAL_CONSTRUCTORS = DEMANGLE_COMPONENT_LITERAL + 20,
  GLOBAL_DESTRUCTORS = DEMANGLE_COMPONENT_LITERAL + 21
};


/* Line 214 of yacc.c.  */
#line 430 "cp-name-parser.c.tmp"

#if ! defined (yyoverflow) || YYERROR_VERBOSE

# ifndef YYFREE
#  define YYFREE free
# endif
# ifndef YYMALLOC
#  define YYMALLOC xmalloc
# endif

/* The parser invokes alloca or xmalloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   define YYSTACK_ALLOC alloca
#  endif
# else
#  if defined (alloca) || defined (_ALLOCA_H)
#   define YYSTACK_ALLOC alloca
#  else
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
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
  short yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short) + sizeof (YYSTYPE))				\
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
   typedef short yysigned_char;
#endif

/* YYFINAL -- State number of the termination state. */
#define YYFINAL  85
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   1054

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  76
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  40
/* YYNRULES -- Number of rules. */
#define YYNRULES  195
/* YYNRULES -- Number of states. */
#define YYNSTATES  325

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   308

#define YYTRANSLATE(YYX) 						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    73,     2,     2,     2,    64,    50,     2,
      74,    42,    62,    60,    43,    61,    68,    63,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    75,     2,
      53,    44,    54,    45,    59,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    69,     2,    71,    49,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,    48,     2,    72,     2,     2,     2,
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
      35,    36,    37,    38,    39,    40,    41,    46,    47,    51,
      52,    55,    56,    57,    58,    65,    66,    67,    70
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const unsigned short yyprhs[] =
{
       0,     0,     3,     5,     7,     9,    11,    12,    15,    18,
      22,    26,    29,    32,    35,    40,    42,    45,    48,    53,
      58,    61,    64,    67,    70,    73,    76,    79,    82,    85,
      88,    91,    94,    97,   100,   103,   106,   109,   112,   115,
     118,   121,   124,   127,   130,   133,   137,   140,   144,   148,
     151,   154,   156,   160,   163,   165,   170,   173,   175,   178,
     181,   183,   186,   188,   190,   192,   194,   197,   200,   202,
     205,   209,   212,   216,   221,   223,   227,   229,   232,   235,
     240,   242,   244,   247,   251,   256,   260,   265,   270,   274,
     275,   277,   279,   281,   283,   285,   288,   290,   292,   294,
     296,   298,   300,   302,   305,   307,   309,   311,   314,   316,
     318,   320,   323,   325,   329,   334,   337,   341,   344,   346,
     350,   353,   356,   358,   362,   365,   369,   372,   377,   381,
     383,   386,   388,   392,   395,   398,   400,   402,   405,   407,
     412,   415,   417,   420,   423,   425,   429,   432,   435,   437,
     440,   442,   444,   449,   454,   459,   462,   465,   468,   471,
     475,   477,   481,   484,   489,   492,   495,   498,   503,   511,
     519,   527,   531,   535,   539,   543,   547,   551,   555,   559,
     563,   567,   571,   575,   579,   583,   587,   591,   595,   599,
     603,   609,   611,   613,   618,   620
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const yysigned_char yyrhs[] =
{
      77,     0,    -1,    78,    -1,   109,    -1,    81,    -1,    80,
      -1,    -1,    12,    78,    -1,   105,   112,    -1,   105,    96,
      79,    -1,    89,    96,    79,    -1,    84,    79,    -1,    84,
     108,    -1,    38,    78,    -1,    39,    78,    40,    78,    -1,
      41,    -1,    17,    15,    -1,    17,    16,    -1,    17,    15,
      69,    71,    -1,    17,    16,    69,    71,    -1,    17,    60,
      -1,    17,    61,    -1,    17,    62,    -1,    17,    63,    -1,
      17,    64,    -1,    17,    49,    -1,    17,    50,    -1,    17,
      48,    -1,    17,    72,    -1,    17,    73,    -1,    17,    44,
      -1,    17,    53,    -1,    17,    54,    -1,    17,    35,    -1,
      17,    58,    -1,    17,    57,    -1,    17,    52,    -1,    17,
      51,    -1,    17,    56,    -1,    17,    55,    -1,    17,    47,
      -1,    17,    46,    -1,    17,    66,    -1,    17,    65,    -1,
      17,    43,    -1,    17,    70,    62,    -1,    17,    70,    -1,
      17,    74,    42,    -1,    17,    69,    71,    -1,    17,   105,
      -1,    91,    83,    -1,    83,    -1,    12,    91,    83,    -1,
      12,    83,    -1,    82,    -1,    82,    53,    93,    54,    -1,
      72,     5,    -1,    87,    -1,    12,    87,    -1,    91,     5,
      -1,     5,    -1,    91,    92,    -1,    92,    -1,    86,    -1,
      89,    -1,    90,    -1,    12,    90,    -1,    91,    85,    -1,
      85,    -1,     5,    12,    -1,    91,     5,    12,    -1,    92,
      12,    -1,    91,    92,    12,    -1,     5,    53,    93,    54,
      -1,    94,    -1,    93,    43,    94,    -1,   105,    -1,   105,
     106,    -1,    50,    78,    -1,    50,    74,    78,    42,    -1,
     114,    -1,   105,    -1,   105,   106,    -1,    95,    43,   105,
      -1,    95,    43,   105,   106,    -1,    95,    43,    29,    -1,
      74,    95,    42,    97,    -1,    74,    31,    42,    97,    -1,
      74,    42,    97,    -1,    -1,    99,    -1,    30,    -1,    26,
      -1,    25,    -1,    98,    -1,    98,    99,    -1,    24,    -1,
      21,    -1,    11,    -1,    33,    -1,    22,    -1,    23,    -1,
     100,    -1,   101,   100,    -1,   101,    -1,    32,    -1,    27,
      -1,    22,    27,    -1,    28,    -1,    34,    -1,    31,    -1,
      62,    97,    -1,    50,    -1,    91,    62,    97,    -1,    12,
      91,    62,    97,    -1,    69,    71,    -1,    69,     3,    71,
      -1,   102,    99,    -1,   102,    -1,    99,   102,    99,    -1,
      99,   102,    -1,    87,    99,    -1,    87,    -1,    99,    87,
      99,    -1,    99,    87,    -1,    12,    87,    99,    -1,    12,
      87,    -1,    99,    12,    87,    99,    -1,    99,    12,    87,
      -1,   103,    -1,   103,   106,    -1,   107,    -1,    74,   106,
      42,    -1,   107,    96,    -1,   107,   104,    -1,   104,    -1,
     103,    -1,   103,   108,    -1,   107,    -1,   107,    96,    12,
      78,    -1,    96,    79,    -1,   105,    -1,   105,   106,    -1,
     103,   110,    -1,   111,    -1,    74,   110,    42,    -1,   111,
      96,    -1,   111,   104,    -1,    88,    -1,   103,   112,    -1,
      88,    -1,   113,    -1,    88,    96,    12,    78,    -1,   113,
      96,    12,    78,    -1,    74,   103,   110,    42,    -1,   113,
      96,    -1,   113,   104,    -1,    88,    96,    -1,    88,   104,
      -1,    74,   115,    42,    -1,   114,    -1,   114,    54,   114,
      -1,    50,    78,    -1,    50,    74,    78,    42,    -1,    61,
     114,    -1,    73,   114,    -1,    72,   114,    -1,    74,   109,
      42,   114,    -1,    18,    53,   109,    54,    74,   115,    42,
      -1,    20,    53,   109,    54,    74,   115,    42,    -1,    19,
      53,   109,    54,    74,   115,    42,    -1,   114,    62,   114,
      -1,   114,    63,   114,    -1,   114,    64,   114,    -1,   114,
      60,   114,    -1,   114,    61,   114,    -1,   114,    58,   114,
      -1,   114,    57,   114,    -1,   114,    52,   114,    -1,   114,
      51,   114,    -1,   114,    56,   114,    -1,   114,    55,   114,
      -1,   114,    53,   114,    -1,   114,    50,   114,    -1,   114,
      49,   114,    -1,   114,    48,   114,    -1,   114,    47,   114,
      -1,   114,    46,   114,    -1,   114,    70,     5,    -1,   114,
      68,     5,    -1,   114,    45,   114,    75,   114,    -1,     3,
      -1,     4,    -1,    10,    74,   109,    42,    -1,    36,    -1,
      37,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short yyrline[] =
{
       0,   366,   366,   370,   372,   374,   379,   380,   387,   396,
     399,   403,   406,   425,   429,   431,   437,   439,   441,   443,
     445,   447,   449,   451,   453,   455,   457,   459,   461,   463,
     465,   467,   469,   471,   473,   475,   477,   479,   481,   483,
     485,   487,   489,   491,   493,   495,   497,   499,   501,   509,
     514,   519,   523,   528,   536,   537,   539,   551,   552,   558,
     560,   561,   563,   566,   567,   570,   571,   575,   577,   580,
     586,   593,   599,   610,   614,   617,   628,   629,   633,   635,
     637,   640,   644,   649,   654,   660,   670,   674,   678,   686,
     687,   690,   692,   694,   698,   699,   706,   708,   710,   712,
     714,   716,   720,   721,   725,   727,   729,   731,   733,   735,
     737,   741,   747,   751,   759,   769,   773,   789,   791,   792,
     794,   797,   799,   800,   802,   805,   807,   809,   811,   816,
     819,   824,   831,   835,   846,   852,   870,   873,   881,   883,
     894,   901,   902,   908,   912,   916,   918,   923,   928,   941,
     945,   950,   958,   963,   972,   976,   981,   986,   990,   996,
    1002,  1005,  1012,  1014,  1019,  1023,  1027,  1034,  1050,  1057,
    1064,  1083,  1087,  1091,  1095,  1099,  1103,  1107,  1111,  1115,
    1119,  1123,  1127,  1131,  1135,  1139,  1143,  1147,  1152,  1156,
    1160,  1167,  1171,  1174,  1179,  1188
};
#endif

#if YYDEBUG || YYERROR_VERBOSE
/* YYTNME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals. */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "INT", "FLOAT", "NAME", "STRUCT",
  "CLASS", "UNION", "ENUM", "SIZEOF", "UNSIGNED", "COLONCOLON", "TEMPLATE",
  "ERROR", "NEW", "DELETE", "OPERATOR", "STATIC_CAST", "REINTERPRET_CAST",
  "DYNAMIC_CAST", "SIGNED_KEYWORD", "LONG", "SHORT", "INT_KEYWORD",
  "CONST_KEYWORD", "VOLATILE_KEYWORD", "DOUBLE_KEYWORD", "BOOL",
  "ELLIPSIS", "RESTRICT", "VOID", "FLOAT_KEYWORD", "CHAR", "WCHAR_T",
  "ASSIGN_MODIFY", "TRUEKEYWORD", "FALSEKEYWORD", "DEMANGLER_SPECIAL",
  "CONSTRUCTION_VTABLE", "CONSTRUCTION_IN", "GLOBAL", "')'", "','", "'='",
  "'?'", "OROR", "ANDAND", "'|'", "'^'", "'&'", "NOTEQUAL", "EQUAL", "'<'",
  "'>'", "GEQ", "LEQ", "RSH", "LSH", "'@'", "'+'", "'-'", "'*'", "'/'",
  "'%'", "DECREMENT", "INCREMENT", "UNARY", "'.'", "'['", "ARROW", "']'",
  "'~'", "'!'", "'('", "':'", "$accept", "result", "start", "start_opt",
  "function", "demangler_special", "operator", "conversion_op",
  "conversion_op_name", "unqualified_name", "colon_name", "name",
  "colon_ext_name", "colon_ext_only", "ext_only_name", "nested_name",
  "template", "template_params", "template_arg", "function_args",
  "function_arglist", "qualifiers_opt", "qualifier", "qualifiers",
  "int_part", "int_seq", "builtin_type", "ptr_operator", "array_indicator",
  "typespec_2", "abstract_declarator", "direct_abstract_declarator",
  "abstract_declarator_fn", "type", "declarator", "direct_declarator",
  "declarator_1", "direct_declarator_1", "exp", "exp1", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const unsigned short yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,    41,    44,    61,    63,   297,   298,   124,    94,
      38,   299,   300,    60,    62,   301,   302,   303,   304,    64,
      43,    45,    42,    47,    37,   305,   306,   307,    46,    91,
     308,    93,   126,    33,    40,    58
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned char yyr1[] =
{
       0,    76,    77,    78,    78,    78,    79,    79,    80,    80,
      80,    80,    80,    81,    81,    81,    82,    82,    82,    82,
      82,    82,    82,    82,    82,    82,    82,    82,    82,    82,
      82,    82,    82,    82,    82,    82,    82,    82,    82,    82,
      82,    82,    82,    82,    82,    82,    82,    82,    82,    83,
      84,    84,    84,    84,    85,    85,    85,    86,    86,    87,
      87,    87,    87,    88,    88,    89,    89,    90,    90,    91,
      91,    91,    91,    92,    93,    93,    94,    94,    94,    94,
      94,    95,    95,    95,    95,    95,    96,    96,    96,    97,
      97,    98,    98,    98,    99,    99,   100,   100,   100,   100,
     100,   100,   101,   101,   102,   102,   102,   102,   102,   102,
     102,   103,   103,   103,   103,   104,   104,   105,   105,   105,
     105,   105,   105,   105,   105,   105,   105,   105,   105,   106,
     106,   106,   107,   107,   107,   107,   108,   108,   108,   108,
     108,   109,   109,   110,   110,   111,   111,   111,   111,   112,
     112,   112,   112,   112,   113,   113,   113,   113,   113,   114,
     115,   115,   115,   115,   114,   114,   114,   114,   114,   114,
     114,   114,   114,   114,   114,   114,   114,   114,   114,   114,
     114,   114,   114,   114,   114,   114,   114,   114,   114,   114,
     114,   114,   114,   114,   114,   114
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const unsigned char yyr2[] =
{
       0,     2,     1,     1,     1,     1,     0,     2,     2,     3,
       3,     2,     2,     2,     4,     1,     2,     2,     4,     4,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     3,     2,     3,     3,     2,
       2,     1,     3,     2,     1,     4,     2,     1,     2,     2,
       1,     2,     1,     1,     1,     1,     2,     2,     1,     2,
       3,     2,     3,     4,     1,     3,     1,     2,     2,     4,
       1,     1,     2,     3,     4,     3,     4,     4,     3,     0,
       1,     1,     1,     1,     1,     2,     1,     1,     1,     1,
       1,     1,     1,     2,     1,     1,     1,     2,     1,     1,
       1,     2,     1,     3,     4,     2,     3,     2,     1,     3,
       2,     2,     1,     3,     2,     3,     2,     4,     3,     1,
       2,     1,     3,     2,     2,     1,     1,     2,     1,     4,
       2,     1,     2,     2,     1,     3,     2,     2,     1,     2,
       1,     1,     4,     4,     4,     2,     2,     2,     2,     3,
       1,     3,     2,     4,     2,     2,     2,     4,     7,     7,
       7,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       5,     1,     1,     4,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned char yydefact[] =
{
       0,    60,    98,     0,     0,    97,   100,   101,    96,    93,
      92,   106,   108,    91,   110,   105,    99,   109,     0,     0,
      15,     0,     0,     2,     5,     4,    54,    51,     6,    68,
     122,     0,    65,     0,    62,    94,     0,   102,   104,   118,
     141,     3,    69,     0,    53,   126,    66,     0,     0,    16,
      17,    33,    44,    30,    41,    40,    27,    25,    26,    37,
      36,    31,    32,    39,    38,    35,    34,    20,    21,    22,
      23,    24,    43,    42,     0,    46,    28,    29,     0,     0,
      49,   107,    13,     0,    56,     1,     0,     0,     0,   112,
      89,     0,     0,    11,     0,     0,     6,   136,   135,   138,
      12,   121,     0,     6,    59,    50,    67,    61,    71,    95,
       0,   124,   120,   100,   103,   117,     0,     0,     0,    63,
      57,   150,    64,     0,     6,   129,   142,   131,     8,   151,
     191,   192,     0,     0,     0,     0,   194,   195,     0,     0,
       0,     0,     0,     0,    74,    76,    80,   125,    52,     0,
       0,    48,    45,    47,     0,     0,     7,     0,   111,    90,
       0,   115,     0,   110,    89,     0,     0,     0,   129,    81,
       0,     0,    89,     0,     0,   140,     0,   137,   133,   134,
      10,    70,    72,   128,   123,   119,    58,     0,   129,   157,
     158,     9,     0,   130,   149,   133,   155,   156,     0,     0,
       0,     0,     0,    78,   164,   166,   165,     0,   141,     0,
     160,     0,     0,    73,    77,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    18,    19,    14,    55,    89,
     116,     0,    89,    88,    89,     0,    82,   132,   113,     0,
       0,   127,     0,   148,   129,     0,   144,     0,     0,     0,
       0,     0,     0,     0,     0,   162,     0,     0,   159,    75,
       0,   187,   186,   185,   184,   183,   179,   178,   182,   181,
     180,   177,   176,   174,   175,   171,   172,   173,   189,   188,
     114,    87,    86,    85,    83,   139,     0,   143,   154,   146,
     147,   152,   153,   193,     0,     0,     0,    79,     0,   167,
     161,     0,    84,   145,     0,     0,     0,   163,   190,     0,
       0,     0,   168,   170,   169
};

/* YYDEFGOTO[NTERM-NUM]. */
static const short yydefgoto[] =
{
      -1,    22,   156,    93,    24,    25,    26,    27,    28,    29,
     119,    30,   253,    31,    32,    79,    34,   143,   144,   167,
      96,   158,    35,    36,    37,    38,    39,   168,    98,    40,
     170,   127,   100,    41,   255,   256,   128,   129,   210,   211
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -263
static const short yypact[] =
{
     702,    22,  -263,    41,   499,  -263,   -14,  -263,  -263,  -263,
    -263,  -263,  -263,  -263,  -263,  -263,  -263,  -263,   702,   702,
    -263,    21,    30,  -263,  -263,  -263,     2,  -263,   228,  -263,
     111,   -11,  -263,    54,    57,   111,   661,  -263,   435,   111,
     628,  -263,  -263,   342,  -263,   111,  -263,    54,    67,    35,
      42,  -263,  -263,  -263,  -263,  -263,  -263,  -263,  -263,  -263,
    -263,  -263,  -263,  -263,  -263,  -263,  -263,  -263,  -263,  -263,
    -263,  -263,  -263,  -263,     6,    32,  -263,  -263,    72,    94,
    -263,  -263,  -263,    83,  -263,  -263,   342,    22,   702,  -263,
     111,     8,   466,  -263,    27,    57,   120,   230,  -263,   -53,
    -263,  -263,   726,   120,    49,  -263,  -263,   130,  -263,  -263,
      67,   111,   111,  -263,  -263,  -263,    59,   729,   466,  -263,
    -263,   -53,  -263,    19,   120,   629,  -263,   -53,  -263,   -53,
    -263,  -263,    70,    95,    96,    99,  -263,  -263,   565,    47,
      47,    47,   401,    85,  -263,   260,   865,  -263,  -263,    82,
      84,  -263,  -263,  -263,   702,    86,  -263,    28,  -263,  -263,
      88,  -263,    67,   114,   111,   260,    36,   104,   260,   260,
     115,    49,   111,   130,   702,  -263,   167,  -263,   161,  -263,
    -263,  -263,  -263,   111,  -263,  -263,  -263,   105,   637,   168,
    -263,  -263,   260,  -263,  -263,  -263,   169,  -263,   849,   849,
     849,   849,   702,  -263,    -8,    -8,    -8,   597,   260,   140,
     839,   142,   342,  -263,  -263,    47,    47,    47,    47,    47,
      47,    47,    47,    47,    47,    47,    47,    47,    47,    47,
      47,    47,    47,   180,   188,  -263,  -263,  -263,  -263,   111,
    -263,    43,   111,  -263,   111,   819,  -263,  -263,  -263,    44,
     702,  -263,   637,  -263,   637,   152,   -53,   702,   702,   154,
     144,   145,   146,   162,   702,  -263,    47,    47,  -263,  -263,
     759,   889,   912,   934,   600,   954,   970,   970,   984,   984,
     984,   795,   795,   268,   268,    -8,    -8,    -8,  -263,  -263,
    -263,  -263,  -263,  -263,   260,  -263,   163,  -263,  -263,  -263,
    -263,  -263,  -263,  -263,   129,   157,   171,  -263,   195,    -8,
     865,    47,  -263,  -263,   445,   445,   445,  -263,   865,   201,
     206,   207,  -263,  -263,  -263
};

/* YYPGOTO[NTERM-NUM].  */
static const short yypgoto[] =
{
    -263,  -263,    25,   -86,  -263,  -263,  -263,     9,  -263,   -27,
    -263,    -1,   -32,   -13,     1,     0,   150,   170,    50,  -263,
     -26,  -157,  -263,   156,   221,  -263,   227,    46,   -98,   185,
     -18,   -19,   172,   113,  -184,  -263,   141,  -263,    -6,  -262
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const unsigned short yytable[] =
{
      33,   179,    45,    47,    46,   103,   106,   243,   121,    99,
     175,   160,    44,    81,   124,   248,    91,   180,    33,    33,
     106,   102,   126,   190,   104,    23,    84,   122,    94,   179,
      85,   197,   171,   104,    42,   111,   117,   146,   191,   120,
     123,   104,   105,    82,    83,     4,     1,    45,   104,   171,
     130,   131,   319,   320,   321,    86,   148,   132,     4,   104,
     233,   181,   234,   102,     1,   133,   134,   135,   296,   108,
     297,     4,     1,   178,    97,    43,   117,   151,    99,   161,
     146,   172,   290,   136,   137,   291,   125,   292,   157,   172,
     239,    21,   166,   121,   152,   189,   106,    94,   172,   104,
      21,   195,    43,   196,   149,   239,   239,   193,   139,   183,
     104,   150,   122,    21,   153,   186,   187,    46,   166,   140,
     141,   142,   117,   154,   120,   123,    21,   214,   212,   212,
     106,    21,   174,   204,   205,   206,     9,    10,    33,   213,
     238,    13,   182,    97,   198,    94,   244,   245,   199,   200,
     193,   246,   201,   235,    33,   236,   242,   247,   300,   240,
     106,    45,   241,   203,   188,    94,   105,   239,    94,    94,
     193,   125,    87,   250,    33,   122,   249,    21,    95,   237,
     257,   258,   266,   107,   268,   288,   101,   120,   123,    80,
     126,   109,    94,   289,   298,   115,   303,   107,   304,   305,
     306,   147,    33,   314,   307,   313,   146,    33,    94,   270,
     271,   272,   273,   274,   275,   276,   277,   278,   279,   280,
     281,   282,   283,   284,   285,   286,   287,   263,   145,   107,
     299,   315,   265,    87,   254,    87,   193,   317,   188,   122,
      88,   122,   176,   322,   173,   316,   159,    95,   323,   324,
      33,   120,   123,   120,   123,   209,   155,    33,    33,   114,
     309,   310,   269,   112,    33,    87,   194,   184,   185,   177,
       0,   145,   176,   107,     0,   295,   312,   169,    89,     0,
      89,     0,   301,   302,     0,     0,     0,   169,     0,   308,
      90,     0,    90,     0,    94,    95,     0,    91,   254,    91,
     254,     0,    92,   169,    92,   318,     0,   107,     0,     0,
      89,   259,   260,   261,   262,    95,   107,     0,    95,    95,
     159,     0,    90,     0,     0,     0,    95,   208,   159,    91,
     230,   231,   232,     0,   165,     0,   233,   107,   234,   251,
       0,     0,    95,     0,     0,   130,   131,     1,     0,     0,
       0,     0,   132,     2,    48,     0,     0,     0,    95,     0,
     133,   134,   135,     5,     6,     7,     8,     9,    10,    11,
      12,     0,    13,    14,    15,    16,    17,     0,   136,   137,
       0,     0,     0,   208,   208,   208,   208,     0,     0,     0,
       0,   107,   138,     0,     0,   159,     0,   145,   159,   173,
     159,     0,     0,   139,   130,   131,     1,     0,     0,     0,
       0,   132,     2,    48,   140,   141,   142,     0,     0,   133,
     134,   135,     5,     6,     7,     8,     9,    10,    11,    12,
     294,    13,    14,    15,    16,    17,     0,   136,   137,     0,
       0,     0,     0,     0,    95,     0,     2,     0,   130,   131,
       0,   207,     0,     0,     0,   132,     5,   113,     7,     8,
       0,     0,   139,   133,   134,   135,     0,     0,    16,     0,
       0,     1,     0,   140,   141,   142,     0,     2,   162,     0,
       0,   136,   137,     0,     0,     0,     0,     5,     6,     7,
       8,     9,    10,    11,    12,   207,    13,   163,    15,    16,
      17,     0,     0,     0,     1,     0,   139,     0,   164,     0,
       2,    48,     0,     0,    49,    50,    89,   140,   141,   142,
       5,     6,     7,     8,     9,    10,    11,    12,    90,    13,
      14,    15,    16,    17,    51,    91,     0,     0,     0,     0,
     165,     0,    52,    53,     0,    54,    55,    56,    57,    58,
      59,    60,    61,    62,    63,    64,    65,    66,     0,    67,
      68,    69,    70,    71,    72,    73,     0,     0,    74,    75,
       1,    76,    77,    78,     0,     0,     2,     3,     0,     0,
       0,     0,     4,     0,     0,     0,     5,     6,     7,     8,
       9,    10,    11,    12,     0,    13,    14,    15,    16,    17,
       0,     0,     1,    18,    19,     0,    20,     0,     2,     3,
       0,     0,     0,     0,     4,     0,     0,     0,     5,     6,
       7,     8,     9,    10,    11,    12,     0,    13,    14,    15,
      16,    17,     0,     1,     1,    18,    19,    21,    20,   202,
     116,   116,     1,     0,     0,   117,   117,     0,     0,   116,
     220,   221,   222,   223,   117,   224,   225,   226,   227,     0,
     228,   229,   230,   231,   232,     0,     1,     0,   233,    21,
     234,   264,     2,   110,     0,     0,     0,     0,    89,    89,
       0,     0,     5,     6,     7,     8,     0,    89,    11,    12,
      90,    90,    14,    15,    16,    17,     0,    91,    91,    90,
      21,    21,   118,   192,     0,     0,    91,     1,     0,    21,
       0,   252,     0,     2,     3,     0,     0,     0,     0,     4,
       0,     0,     0,     5,     6,     7,     8,     9,    10,    11,
      12,     1,    13,    14,    15,    16,    17,     2,    48,     0,
      18,    19,     0,    20,    49,    50,     0,     5,     6,     7,
       8,     9,    10,    11,    12,     0,    13,   163,    15,    16,
      17,     0,     0,     0,    51,     0,     0,     0,   164,     0,
       0,     0,    52,    53,    21,    54,    55,    56,    57,    58,
      59,    60,    61,    62,    63,    64,    65,    66,     0,    67,
      68,    69,    70,    71,    72,    73,     0,     0,    74,    75,
       0,    76,    77,    78,   215,   216,   217,   218,   219,   220,
     221,   222,   223,     0,   224,   225,   226,   227,     0,   228,
     229,   230,   231,   232,     1,     0,     0,   233,     0,   234,
       2,    48,     0,     0,   311,     0,     0,     0,     0,     0,
       5,     6,     7,     8,     9,    10,    11,    12,   293,    13,
      14,    15,    16,    17,     1,   228,   229,   230,   231,   232,
       2,    48,     0,   233,     0,   234,     0,     0,     0,     0,
       5,     6,     7,     8,     9,    10,    11,    12,     0,    13,
      14,    15,    16,    17,   215,   216,   217,   218,   219,   220,
     221,   222,   223,   267,   224,   225,   226,   227,     0,   228,
     229,   230,   231,   232,     0,     0,     0,   233,     0,   234,
     215,   216,   217,   218,   219,   220,   221,   222,   223,     0,
     224,   225,   226,   227,     0,   228,   229,   230,   231,   232,
       0,     0,     0,   233,     0,   234,   217,   218,   219,   220,
     221,   222,   223,     0,   224,   225,   226,   227,     0,   228,
     229,   230,   231,   232,     0,     0,     0,   233,     0,   234,
     218,   219,   220,   221,   222,   223,     0,   224,   225,   226,
     227,     0,   228,   229,   230,   231,   232,     0,     0,     0,
     233,     0,   234,   219,   220,   221,   222,   223,     0,   224,
     225,   226,   227,     0,   228,   229,   230,   231,   232,     0,
       0,     0,   233,     0,   234,   221,   222,   223,     0,   224,
     225,   226,   227,     0,   228,   229,   230,   231,   232,     0,
       0,     0,   233,   223,   234,   224,   225,   226,   227,     0,
     228,   229,   230,   231,   232,     0,     0,     0,   233,     0,
     234,   226,   227,     0,   228,   229,   230,   231,   232,     0,
       0,     0,   233,     0,   234
};

static const short yycheck[] =
{
       0,    99,     3,     3,     3,    31,    33,   164,    40,    28,
      96,     3,     3,    27,    40,   172,    69,   103,    18,    19,
      47,    74,    40,   121,     5,     0,     5,    40,    28,   127,
       0,   129,     5,     5,    12,    36,    17,    43,   124,    40,
      40,     5,    33,    18,    19,    17,     5,    48,     5,     5,
       3,     4,   314,   315,   316,    53,    47,    10,    17,     5,
      68,    12,    70,    74,     5,    18,    19,    20,   252,    12,
     254,    17,     5,    99,    28,    53,    17,    71,    97,    71,
      86,    62,   239,    36,    37,   242,    40,   244,    88,    62,
      62,    72,    92,   125,    62,   121,   123,    97,    62,     5,
      72,   127,    53,   129,    69,    62,    62,   125,    61,   110,
       5,    69,   125,    72,    42,   116,   116,   116,   118,    72,
      73,    74,    17,    40,   125,   125,    72,   145,    43,    43,
     157,    72,    12,   139,   140,   141,    25,    26,   138,    54,
      54,    30,    12,    97,    74,   145,    42,    43,    53,    53,
     168,   169,    53,    71,   154,    71,    42,    42,   256,    71,
     187,   162,   162,   138,   118,   165,   157,    62,   168,   169,
     188,   125,     5,    12,   174,   188,   176,    72,    28,   154,
      12,    12,    42,    33,    42,     5,    30,   188,   188,     4,
     208,    35,   192,     5,    42,    39,    42,    47,    54,    54,
      54,    45,   202,    74,    42,    42,   212,   207,   208,   215,
     216,   217,   218,   219,   220,   221,   222,   223,   224,   225,
     226,   227,   228,   229,   230,   231,   232,   202,    43,    79,
     256,    74,   207,     5,   188,     5,   254,    42,   192,   252,
      12,   254,    12,    42,    94,    74,    90,    97,    42,    42,
     250,   252,   252,   254,   254,   142,    86,   257,   258,    38,
     266,   267,   212,    36,   264,     5,   125,   111,   112,    97,
      -1,    86,    12,   123,    -1,   250,   294,    92,    50,    -1,
      50,    -1,   257,   258,    -1,    -1,    -1,   102,    -1,   264,
      62,    -1,    62,    -1,   294,   145,    -1,    69,   252,    69,
     254,    -1,    74,   118,    74,   311,    -1,   157,    -1,    -1,
      50,   198,   199,   200,   201,   165,   166,    -1,   168,   169,
     164,    -1,    62,    -1,    -1,    -1,   176,   142,   172,    69,
      62,    63,    64,    -1,    74,    -1,    68,   187,    70,   183,
      -1,    -1,   192,    -1,    -1,     3,     4,     5,    -1,    -1,
      -1,    -1,    10,    11,    12,    -1,    -1,    -1,   208,    -1,
      18,    19,    20,    21,    22,    23,    24,    25,    26,    27,
      28,    -1,    30,    31,    32,    33,    34,    -1,    36,    37,
      -1,    -1,    -1,   198,   199,   200,   201,    -1,    -1,    -1,
      -1,   241,    50,    -1,    -1,   239,    -1,   212,   242,   249,
     244,    -1,    -1,    61,     3,     4,     5,    -1,    -1,    -1,
      -1,    10,    11,    12,    72,    73,    74,    -1,    -1,    18,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
     245,    30,    31,    32,    33,    34,    -1,    36,    37,    -1,
      -1,    -1,    -1,    -1,   294,    -1,    11,    -1,     3,     4,
      -1,    50,    -1,    -1,    -1,    10,    21,    22,    23,    24,
      -1,    -1,    61,    18,    19,    20,    -1,    -1,    33,    -1,
      -1,     5,    -1,    72,    73,    74,    -1,    11,    12,    -1,
      -1,    36,    37,    -1,    -1,    -1,    -1,    21,    22,    23,
      24,    25,    26,    27,    28,    50,    30,    31,    32,    33,
      34,    -1,    -1,    -1,     5,    -1,    61,    -1,    42,    -1,
      11,    12,    -1,    -1,    15,    16,    50,    72,    73,    74,
      21,    22,    23,    24,    25,    26,    27,    28,    62,    30,
      31,    32,    33,    34,    35,    69,    -1,    -1,    -1,    -1,
      74,    -1,    43,    44,    -1,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    -1,    60,
      61,    62,    63,    64,    65,    66,    -1,    -1,    69,    70,
       5,    72,    73,    74,    -1,    -1,    11,    12,    -1,    -1,
      -1,    -1,    17,    -1,    -1,    -1,    21,    22,    23,    24,
      25,    26,    27,    28,    -1,    30,    31,    32,    33,    34,
      -1,    -1,     5,    38,    39,    -1,    41,    -1,    11,    12,
      -1,    -1,    -1,    -1,    17,    -1,    -1,    -1,    21,    22,
      23,    24,    25,    26,    27,    28,    -1,    30,    31,    32,
      33,    34,    -1,     5,     5,    38,    39,    72,    41,    74,
      12,    12,     5,    -1,    -1,    17,    17,    -1,    -1,    12,
      50,    51,    52,    53,    17,    55,    56,    57,    58,    -1,
      60,    61,    62,    63,    64,    -1,     5,    -1,    68,    72,
      70,    74,    11,    12,    -1,    -1,    -1,    -1,    50,    50,
      -1,    -1,    21,    22,    23,    24,    -1,    50,    27,    28,
      62,    62,    31,    32,    33,    34,    -1,    69,    69,    62,
      72,    72,    74,    74,    -1,    -1,    69,     5,    -1,    72,
      -1,    74,    -1,    11,    12,    -1,    -1,    -1,    -1,    17,
      -1,    -1,    -1,    21,    22,    23,    24,    25,    26,    27,
      28,     5,    30,    31,    32,    33,    34,    11,    12,    -1,
      38,    39,    -1,    41,    15,    16,    -1,    21,    22,    23,
      24,    25,    26,    27,    28,    -1,    30,    31,    32,    33,
      34,    -1,    -1,    -1,    35,    -1,    -1,    -1,    42,    -1,
      -1,    -1,    43,    44,    72,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    -1,    60,
      61,    62,    63,    64,    65,    66,    -1,    -1,    69,    70,
      -1,    72,    73,    74,    45,    46,    47,    48,    49,    50,
      51,    52,    53,    -1,    55,    56,    57,    58,    -1,    60,
      61,    62,    63,    64,     5,    -1,    -1,    68,    -1,    70,
      11,    12,    -1,    -1,    75,    -1,    -1,    -1,    -1,    -1,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,     5,    60,    61,    62,    63,    64,
      11,    12,    -1,    68,    -1,    70,    -1,    -1,    -1,    -1,
      21,    22,    23,    24,    25,    26,    27,    28,    -1,    30,
      31,    32,    33,    34,    45,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    -1,    60,
      61,    62,    63,    64,    -1,    -1,    -1,    68,    -1,    70,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    -1,
      55,    56,    57,    58,    -1,    60,    61,    62,    63,    64,
      -1,    -1,    -1,    68,    -1,    70,    47,    48,    49,    50,
      51,    52,    53,    -1,    55,    56,    57,    58,    -1,    60,
      61,    62,    63,    64,    -1,    -1,    -1,    68,    -1,    70,
      48,    49,    50,    51,    52,    53,    -1,    55,    56,    57,
      58,    -1,    60,    61,    62,    63,    64,    -1,    -1,    -1,
      68,    -1,    70,    49,    50,    51,    52,    53,    -1,    55,
      56,    57,    58,    -1,    60,    61,    62,    63,    64,    -1,
      -1,    -1,    68,    -1,    70,    51,    52,    53,    -1,    55,
      56,    57,    58,    -1,    60,    61,    62,    63,    64,    -1,
      -1,    -1,    68,    53,    70,    55,    56,    57,    58,    -1,
      60,    61,    62,    63,    64,    -1,    -1,    -1,    68,    -1,
      70,    57,    58,    -1,    60,    61,    62,    63,    64,    -1,
      -1,    -1,    68,    -1,    70
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned char yystos[] =
{
       0,     5,    11,    12,    17,    21,    22,    23,    24,    25,
      26,    27,    28,    30,    31,    32,    33,    34,    38,    39,
      41,    72,    77,    78,    80,    81,    82,    83,    84,    85,
      87,    89,    90,    91,    92,    98,    99,   100,   101,   102,
     105,   109,    12,    53,    83,    87,    90,    91,    12,    15,
      16,    35,    43,    44,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    60,    61,    62,
      63,    64,    65,    66,    69,    70,    72,    73,    74,    91,
     105,    27,    78,    78,     5,     0,    53,     5,    12,    50,
      62,    69,    74,    79,    91,    92,    96,   103,   104,   107,
     108,    99,    74,    96,     5,    83,    85,    92,    12,    99,
      12,    87,   102,    22,   100,    99,    12,    17,    74,    86,
      87,    88,    89,    91,    96,   103,   106,   107,   112,   113,
       3,     4,    10,    18,    19,    20,    36,    37,    50,    61,
      72,    73,    74,    93,    94,   105,   114,    99,    83,    69,
      69,    71,    62,    42,    40,    93,    78,    91,    97,    99,
       3,    71,    12,    31,    42,    74,    91,    95,   103,   105,
     106,     5,    62,    92,    12,    79,    12,   108,    96,   104,
      79,    12,    12,    87,    99,    99,    87,    91,   103,    96,
     104,    79,    74,   106,   112,    96,    96,   104,    74,    53,
      53,    53,    74,    78,   114,   114,   114,    50,   105,   109,
     114,   115,    43,    54,   106,    45,    46,    47,    48,    49,
      50,    51,    52,    53,    55,    56,    57,    58,    60,    61,
      62,    63,    64,    68,    70,    71,    71,    78,    54,    62,
      71,    91,    42,    97,    42,    43,   106,    42,    97,    91,
      12,    99,    74,    88,   103,   110,   111,    12,    12,   109,
     109,   109,   109,    78,    74,    78,    42,    54,    42,    94,
     114,   114,   114,   114,   114,   114,   114,   114,   114,   114,
     114,   114,   114,   114,   114,   114,   114,   114,     5,     5,
      97,    97,    97,    29,   105,    78,   110,   110,    42,    96,
     104,    78,    78,    42,    54,    54,    54,    42,    78,   114,
     114,    75,   106,    42,    74,    74,    74,    42,   114,   115,
     115,   115,    42,    42,    42
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

/* YYLLOC_DEFAULT -- Compute the default location (before the actions
   are run).  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)		\
   ((Current).first_line   = (Rhs)[1].first_line,	\
    (Current).first_column = (Rhs)[1].first_column,	\
    (Current).last_line    = (Rhs)[N].last_line,	\
    (Current).last_column  = (Rhs)[N].last_column)
#endif

/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
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

# define YYDSYMPRINT(Args)			\
do {						\
  if (yydebug)					\
    yysymprint Args;				\
} while (0)

# define YYDSYMPRINTF(Title, Token, Value, Location)		\
do {								\
  if (yydebug)							\
    {								\
      YYFPRINTF (stderr, "%s ", Title);				\
      yysymprint (stderr, 					\
                  Token, Value);	\
      YYFPRINTF (stderr, "\n");					\
    }								\
} while (0)

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yy_stack_print (short *bottom, short *top)
#else
static void
yy_stack_print (bottom, top)
    short *bottom;
    short *top;
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
# define YYDSYMPRINT(Args)
# define YYDSYMPRINTF(Title, Token, Value, Location)
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

#if defined (YYMAXDEPTH) && YYMAXDEPTH == 0
# undef YYMAXDEPTH
#endif

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
    {
      YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
# ifdef YYPRINT
      YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
    }
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

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
yydestruct (int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yytype, yyvaluep)
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;

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



/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



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
  
  register int yystate;
  register int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to xreallocate them elsewhere.  */

  /* The state stack.  */
  short	yyssa[YYINITDEPTH];
  short *yyss = yyssa;
  register short *yyssp;

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
	/* Give user a chance to xreallocate the stack. Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	short *yyss1 = yyss;


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
	short *yyss1 = yyss;
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
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
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
      YYDSYMPRINTF ("Next token is", yytoken, &yylval, &yylloc);
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

  /* Shift the lookahead token.  */
  YYDPRINTF ((stderr, "Shifting token %s, ", yytname[yytoken]));

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
        case 2:
#line 367 "cp-name-parser.y"
    { global_result = yyvsp[0].comp; }
    break;

  case 6:
#line 379 "cp-name-parser.y"
    { yyval.comp = NULL; }
    break;

  case 7:
#line 381 "cp-name-parser.y"
    { yyval.comp = yyvsp[0].comp; }
    break;

  case 8:
#line 388 "cp-name-parser.y"
    { yyval.comp = yyvsp[0].nested.comp;
			  *yyvsp[0].nested.last = yyvsp[-1].comp;
			}
    break;

  case 9:
#line 397 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_TYPED_NAME, yyvsp[-2].comp, yyvsp[-1].nested.comp);
			  if (yyvsp[0].comp) yyval.comp = fill_comp (DEMANGLE_COMPONENT_LOCAL_NAME, yyval.comp, yyvsp[0].comp); }
    break;

  case 10:
#line 400 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_TYPED_NAME, yyvsp[-2].comp, yyvsp[-1].nested.comp);
			  if (yyvsp[0].comp) yyval.comp = fill_comp (DEMANGLE_COMPONENT_LOCAL_NAME, yyval.comp, yyvsp[0].comp); }
    break;

  case 11:
#line 404 "cp-name-parser.y"
    { yyval.comp = yyvsp[-1].nested.comp;
			  if (yyvsp[0].comp) yyval.comp = fill_comp (DEMANGLE_COMPONENT_LOCAL_NAME, yyval.comp, yyvsp[0].comp); }
    break;

  case 12:
#line 407 "cp-name-parser.y"
    { if (yyvsp[0].abstract.last)
			    {
			       /* First complete the abstract_declarator's type using
				  the typespec from the conversion_op_name.  */
			      *yyvsp[0].abstract.last = *yyvsp[-1].nested.last;
			      /* Then complete the conversion_op_name with the type.  */
			      *yyvsp[-1].nested.last = yyvsp[0].abstract.comp;
			    }
			  /* If we have an arglist, build a function type.  */
			  if (yyvsp[0].abstract.fn.comp)
			    yyval.comp = fill_comp (DEMANGLE_COMPONENT_TYPED_NAME, yyvsp[-1].nested.comp, yyvsp[0].abstract.fn.comp);
			  else
			    yyval.comp = yyvsp[-1].nested.comp;
			  if (yyvsp[0].abstract.start) yyval.comp = fill_comp (DEMANGLE_COMPONENT_LOCAL_NAME, yyval.comp, yyvsp[0].abstract.start);
			}
    break;

  case 13:
#line 426 "cp-name-parser.y"
    { yyval.comp = make_empty (yyvsp[-1].lval);
			  d_left (yyval.comp) = yyvsp[0].comp;
			  d_right (yyval.comp) = NULL; }
    break;

  case 14:
#line 430 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_CONSTRUCTION_VTABLE, yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 15:
#line 432 "cp-name-parser.y"
    { yyval.comp = make_empty (yyvsp[0].typed_val_int.val);
			  d_left (yyval.comp) = yyvsp[0].typed_val_int.type;
			  d_right (yyval.comp) = NULL; }
    break;

  case 16:
#line 438 "cp-name-parser.y"
    { yyval.comp = make_operator ("new", 1); }
    break;

  case 17:
#line 440 "cp-name-parser.y"
    { yyval.comp = make_operator ("delete", 1); }
    break;

  case 18:
#line 442 "cp-name-parser.y"
    { yyval.comp = make_operator ("new[]", 1); }
    break;

  case 19:
#line 444 "cp-name-parser.y"
    { yyval.comp = make_operator ("delete[]", 1); }
    break;

  case 20:
#line 446 "cp-name-parser.y"
    { yyval.comp = make_operator ("+", 2); }
    break;

  case 21:
#line 448 "cp-name-parser.y"
    { yyval.comp = make_operator ("-", 2); }
    break;

  case 22:
#line 450 "cp-name-parser.y"
    { yyval.comp = make_operator ("*", 2); }
    break;

  case 23:
#line 452 "cp-name-parser.y"
    { yyval.comp = make_operator ("/", 2); }
    break;

  case 24:
#line 454 "cp-name-parser.y"
    { yyval.comp = make_operator ("%", 2); }
    break;

  case 25:
#line 456 "cp-name-parser.y"
    { yyval.comp = make_operator ("^", 2); }
    break;

  case 26:
#line 458 "cp-name-parser.y"
    { yyval.comp = make_operator ("&", 2); }
    break;

  case 27:
#line 460 "cp-name-parser.y"
    { yyval.comp = make_operator ("|", 2); }
    break;

  case 28:
#line 462 "cp-name-parser.y"
    { yyval.comp = make_operator ("~", 1); }
    break;

  case 29:
#line 464 "cp-name-parser.y"
    { yyval.comp = make_operator ("!", 1); }
    break;

  case 30:
#line 466 "cp-name-parser.y"
    { yyval.comp = make_operator ("=", 2); }
    break;

  case 31:
#line 468 "cp-name-parser.y"
    { yyval.comp = make_operator ("<", 2); }
    break;

  case 32:
#line 470 "cp-name-parser.y"
    { yyval.comp = make_operator (">", 2); }
    break;

  case 33:
#line 472 "cp-name-parser.y"
    { yyval.comp = make_operator (yyvsp[0].opname, 2); }
    break;

  case 34:
#line 474 "cp-name-parser.y"
    { yyval.comp = make_operator ("<<", 2); }
    break;

  case 35:
#line 476 "cp-name-parser.y"
    { yyval.comp = make_operator (">>", 2); }
    break;

  case 36:
#line 478 "cp-name-parser.y"
    { yyval.comp = make_operator ("==", 2); }
    break;

  case 37:
#line 480 "cp-name-parser.y"
    { yyval.comp = make_operator ("!=", 2); }
    break;

  case 38:
#line 482 "cp-name-parser.y"
    { yyval.comp = make_operator ("<=", 2); }
    break;

  case 39:
#line 484 "cp-name-parser.y"
    { yyval.comp = make_operator (">=", 2); }
    break;

  case 40:
#line 486 "cp-name-parser.y"
    { yyval.comp = make_operator ("&&", 2); }
    break;

  case 41:
#line 488 "cp-name-parser.y"
    { yyval.comp = make_operator ("||", 2); }
    break;

  case 42:
#line 490 "cp-name-parser.y"
    { yyval.comp = make_operator ("++", 1); }
    break;

  case 43:
#line 492 "cp-name-parser.y"
    { yyval.comp = make_operator ("--", 1); }
    break;

  case 44:
#line 494 "cp-name-parser.y"
    { yyval.comp = make_operator (",", 2); }
    break;

  case 45:
#line 496 "cp-name-parser.y"
    { yyval.comp = make_operator ("->*", 2); }
    break;

  case 46:
#line 498 "cp-name-parser.y"
    { yyval.comp = make_operator ("->", 2); }
    break;

  case 47:
#line 500 "cp-name-parser.y"
    { yyval.comp = make_operator ("()", 0); }
    break;

  case 48:
#line 502 "cp-name-parser.y"
    { yyval.comp = make_operator ("[]", 2); }
    break;

  case 49:
#line 510 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_CAST, yyvsp[0].comp, NULL); }
    break;

  case 50:
#line 515 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[-1].nested1.comp;
			  d_right (yyvsp[-1].nested1.last) = yyvsp[0].comp;
			  yyval.nested.last = &d_left (yyvsp[0].comp);
			}
    break;

  case 51:
#line 520 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[0].comp;
			  yyval.nested.last = &d_left (yyvsp[0].comp);
			}
    break;

  case 52:
#line 524 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[-1].nested1.comp;
			  d_right (yyvsp[-1].nested1.last) = yyvsp[0].comp;
			  yyval.nested.last = &d_left (yyvsp[0].comp);
			}
    break;

  case 53:
#line 529 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[0].comp;
			  yyval.nested.last = &d_left (yyvsp[0].comp);
			}
    break;

  case 55:
#line 538 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_TEMPLATE, yyvsp[-3].comp, yyvsp[-1].nested.comp); }
    break;

  case 56:
#line 540 "cp-name-parser.y"
    { yyval.comp = make_dtor (gnu_v3_complete_object_dtor, yyvsp[0].comp); }
    break;

  case 58:
#line 553 "cp-name-parser.y"
    { yyval.comp = yyvsp[0].comp; }
    break;

  case 59:
#line 559 "cp-name-parser.y"
    { yyval.comp = yyvsp[-1].nested1.comp; d_right (yyvsp[-1].nested1.last) = yyvsp[0].comp; }
    break;

  case 61:
#line 562 "cp-name-parser.y"
    { yyval.comp = yyvsp[-1].nested1.comp; d_right (yyvsp[-1].nested1.last) = yyvsp[0].comp; }
    break;

  case 66:
#line 572 "cp-name-parser.y"
    { yyval.comp = yyvsp[0].comp; }
    break;

  case 67:
#line 576 "cp-name-parser.y"
    { yyval.comp = yyvsp[-1].nested1.comp; d_right (yyvsp[-1].nested1.last) = yyvsp[0].comp; }
    break;

  case 69:
#line 581 "cp-name-parser.y"
    { yyval.nested1.comp = make_empty (DEMANGLE_COMPONENT_QUAL_NAME);
			  d_left (yyval.nested1.comp) = yyvsp[-1].comp;
			  d_right (yyval.nested1.comp) = NULL;
			  yyval.nested1.last = yyval.nested1.comp;
			}
    break;

  case 70:
#line 587 "cp-name-parser.y"
    { yyval.nested1.comp = yyvsp[-2].nested1.comp;
			  d_right (yyvsp[-2].nested1.last) = make_empty (DEMANGLE_COMPONENT_QUAL_NAME);
			  yyval.nested1.last = d_right (yyvsp[-2].nested1.last);
			  d_left (yyval.nested1.last) = yyvsp[-1].comp;
			  d_right (yyval.nested1.last) = NULL;
			}
    break;

  case 71:
#line 594 "cp-name-parser.y"
    { yyval.nested1.comp = make_empty (DEMANGLE_COMPONENT_QUAL_NAME);
			  d_left (yyval.nested1.comp) = yyvsp[-1].comp;
			  d_right (yyval.nested1.comp) = NULL;
			  yyval.nested1.last = yyval.nested1.comp;
			}
    break;

  case 72:
#line 600 "cp-name-parser.y"
    { yyval.nested1.comp = yyvsp[-2].nested1.comp;
			  d_right (yyvsp[-2].nested1.last) = make_empty (DEMANGLE_COMPONENT_QUAL_NAME);
			  yyval.nested1.last = d_right (yyvsp[-2].nested1.last);
			  d_left (yyval.nested1.last) = yyvsp[-1].comp;
			  d_right (yyval.nested1.last) = NULL;
			}
    break;

  case 73:
#line 611 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_TEMPLATE, yyvsp[-3].comp, yyvsp[-1].nested.comp); }
    break;

  case 74:
#line 615 "cp-name-parser.y"
    { yyval.nested.comp = fill_comp (DEMANGLE_COMPONENT_TEMPLATE_ARGLIST, yyvsp[0].comp, NULL);
			yyval.nested.last = &d_right (yyval.nested.comp); }
    break;

  case 75:
#line 618 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[-2].nested.comp;
			  *yyvsp[-2].nested.last = fill_comp (DEMANGLE_COMPONENT_TEMPLATE_ARGLIST, yyvsp[0].comp, NULL);
			  yyval.nested.last = &d_right (*yyvsp[-2].nested.last);
			}
    break;

  case 77:
#line 630 "cp-name-parser.y"
    { yyval.comp = yyvsp[0].abstract.comp;
			  *yyvsp[0].abstract.last = yyvsp[-1].comp;
			}
    break;

  case 78:
#line 634 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_UNARY, make_operator ("&", 1), yyvsp[0].comp); }
    break;

  case 79:
#line 636 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_UNARY, make_operator ("&", 1), yyvsp[-1].comp); }
    break;

  case 81:
#line 641 "cp-name-parser.y"
    { yyval.nested.comp = fill_comp (DEMANGLE_COMPONENT_ARGLIST, yyvsp[0].comp, NULL);
			  yyval.nested.last = &d_right (yyval.nested.comp);
			}
    break;

  case 82:
#line 645 "cp-name-parser.y"
    { *yyvsp[0].abstract.last = yyvsp[-1].comp;
			  yyval.nested.comp = fill_comp (DEMANGLE_COMPONENT_ARGLIST, yyvsp[0].abstract.comp, NULL);
			  yyval.nested.last = &d_right (yyval.nested.comp);
			}
    break;

  case 83:
#line 650 "cp-name-parser.y"
    { *yyvsp[-2].nested.last = fill_comp (DEMANGLE_COMPONENT_ARGLIST, yyvsp[0].comp, NULL);
			  yyval.nested.comp = yyvsp[-2].nested.comp;
			  yyval.nested.last = &d_right (*yyvsp[-2].nested.last);
			}
    break;

  case 84:
#line 655 "cp-name-parser.y"
    { *yyvsp[0].abstract.last = yyvsp[-1].comp;
			  *yyvsp[-3].nested.last = fill_comp (DEMANGLE_COMPONENT_ARGLIST, yyvsp[0].abstract.comp, NULL);
			  yyval.nested.comp = yyvsp[-3].nested.comp;
			  yyval.nested.last = &d_right (*yyvsp[-3].nested.last);
			}
    break;

  case 85:
#line 661 "cp-name-parser.y"
    { *yyvsp[-2].nested.last
			    = fill_comp (DEMANGLE_COMPONENT_ARGLIST,
					   make_builtin_type ("..."),
					   NULL);
			  yyval.nested.comp = yyvsp[-2].nested.comp;
			  yyval.nested.last = &d_right (*yyvsp[-2].nested.last);
			}
    break;

  case 86:
#line 671 "cp-name-parser.y"
    { yyval.nested.comp = fill_comp (DEMANGLE_COMPONENT_FUNCTION_TYPE, NULL, yyvsp[-2].nested.comp);
			  yyval.nested.last = &d_left (yyval.nested.comp);
			  yyval.nested.comp = d_qualify (yyval.nested.comp, yyvsp[0].lval, 1); }
    break;

  case 87:
#line 675 "cp-name-parser.y"
    { yyval.nested.comp = fill_comp (DEMANGLE_COMPONENT_FUNCTION_TYPE, NULL, NULL);
			  yyval.nested.last = &d_left (yyval.nested.comp);
			  yyval.nested.comp = d_qualify (yyval.nested.comp, yyvsp[0].lval, 1); }
    break;

  case 88:
#line 679 "cp-name-parser.y"
    { yyval.nested.comp = fill_comp (DEMANGLE_COMPONENT_FUNCTION_TYPE, NULL, NULL);
			  yyval.nested.last = &d_left (yyval.nested.comp);
			  yyval.nested.comp = d_qualify (yyval.nested.comp, yyvsp[0].lval, 1); }
    break;

  case 89:
#line 686 "cp-name-parser.y"
    { yyval.lval = 0; }
    break;

  case 91:
#line 691 "cp-name-parser.y"
    { yyval.lval = QUAL_RESTRICT; }
    break;

  case 92:
#line 693 "cp-name-parser.y"
    { yyval.lval = QUAL_VOLATILE; }
    break;

  case 93:
#line 695 "cp-name-parser.y"
    { yyval.lval = QUAL_CONST; }
    break;

  case 95:
#line 700 "cp-name-parser.y"
    { yyval.lval = yyvsp[-1].lval | yyvsp[0].lval; }
    break;

  case 96:
#line 707 "cp-name-parser.y"
    { yyval.lval = 0; }
    break;

  case 97:
#line 709 "cp-name-parser.y"
    { yyval.lval = INT_SIGNED; }
    break;

  case 98:
#line 711 "cp-name-parser.y"
    { yyval.lval = INT_UNSIGNED; }
    break;

  case 99:
#line 713 "cp-name-parser.y"
    { yyval.lval = INT_CHAR; }
    break;

  case 100:
#line 715 "cp-name-parser.y"
    { yyval.lval = INT_LONG; }
    break;

  case 101:
#line 717 "cp-name-parser.y"
    { yyval.lval = INT_SHORT; }
    break;

  case 103:
#line 722 "cp-name-parser.y"
    { yyval.lval = yyvsp[-1].lval | yyvsp[0].lval; if (yyvsp[-1].lval & yyvsp[0].lval & INT_LONG) yyval.lval = yyvsp[-1].lval | INT_LLONG; }
    break;

  case 104:
#line 726 "cp-name-parser.y"
    { yyval.comp = d_int_type (yyvsp[0].lval); }
    break;

  case 105:
#line 728 "cp-name-parser.y"
    { yyval.comp = make_builtin_type ("float"); }
    break;

  case 106:
#line 730 "cp-name-parser.y"
    { yyval.comp = make_builtin_type ("double"); }
    break;

  case 107:
#line 732 "cp-name-parser.y"
    { yyval.comp = make_builtin_type ("long double"); }
    break;

  case 108:
#line 734 "cp-name-parser.y"
    { yyval.comp = make_builtin_type ("bool"); }
    break;

  case 109:
#line 736 "cp-name-parser.y"
    { yyval.comp = make_builtin_type ("wchar_t"); }
    break;

  case 110:
#line 738 "cp-name-parser.y"
    { yyval.comp = make_builtin_type ("void"); }
    break;

  case 111:
#line 742 "cp-name-parser.y"
    { yyval.nested.comp = make_empty (DEMANGLE_COMPONENT_POINTER);
			  yyval.nested.comp->u.s_binary.left = yyval.nested.comp->u.s_binary.right = NULL;
			  yyval.nested.last = &d_left (yyval.nested.comp);
			  yyval.nested.comp = d_qualify (yyval.nested.comp, yyvsp[0].lval, 0); }
    break;

  case 112:
#line 748 "cp-name-parser.y"
    { yyval.nested.comp = make_empty (DEMANGLE_COMPONENT_REFERENCE);
			  yyval.nested.comp->u.s_binary.left = yyval.nested.comp->u.s_binary.right = NULL;
			  yyval.nested.last = &d_left (yyval.nested.comp); }
    break;

  case 113:
#line 752 "cp-name-parser.y"
    { yyval.nested.comp = make_empty (DEMANGLE_COMPONENT_PTRMEM_TYPE);
			  yyval.nested.comp->u.s_binary.left = yyvsp[-2].nested1.comp;
			  /* Convert the innermost DEMANGLE_COMPONENT_QUAL_NAME to a DEMANGLE_COMPONENT_NAME.  */
			  *yyvsp[-2].nested1.last = *d_left (yyvsp[-2].nested1.last);
			  yyval.nested.comp->u.s_binary.right = NULL;
			  yyval.nested.last = &d_right (yyval.nested.comp);
			  yyval.nested.comp = d_qualify (yyval.nested.comp, yyvsp[0].lval, 0); }
    break;

  case 114:
#line 760 "cp-name-parser.y"
    { yyval.nested.comp = make_empty (DEMANGLE_COMPONENT_PTRMEM_TYPE);
			  yyval.nested.comp->u.s_binary.left = yyvsp[-2].nested1.comp;
			  /* Convert the innermost DEMANGLE_COMPONENT_QUAL_NAME to a DEMANGLE_COMPONENT_NAME.  */
			  *yyvsp[-2].nested1.last = *d_left (yyvsp[-2].nested1.last);
			  yyval.nested.comp->u.s_binary.right = NULL;
			  yyval.nested.last = &d_right (yyval.nested.comp);
			  yyval.nested.comp = d_qualify (yyval.nested.comp, yyvsp[0].lval, 0); }
    break;

  case 115:
#line 770 "cp-name-parser.y"
    { yyval.comp = make_empty (DEMANGLE_COMPONENT_ARRAY_TYPE);
			  d_left (yyval.comp) = NULL;
			}
    break;

  case 116:
#line 774 "cp-name-parser.y"
    { yyval.comp = make_empty (DEMANGLE_COMPONENT_ARRAY_TYPE);
			  d_left (yyval.comp) = yyvsp[-1].comp;
			}
    break;

  case 117:
#line 790 "cp-name-parser.y"
    { yyval.comp = d_qualify (yyvsp[-1].comp, yyvsp[0].lval, 0); }
    break;

  case 119:
#line 793 "cp-name-parser.y"
    { yyval.comp = d_qualify (yyvsp[-1].comp, yyvsp[-2].lval | yyvsp[0].lval, 0); }
    break;

  case 120:
#line 795 "cp-name-parser.y"
    { yyval.comp = d_qualify (yyvsp[0].comp, yyvsp[-1].lval, 0); }
    break;

  case 121:
#line 798 "cp-name-parser.y"
    { yyval.comp = d_qualify (yyvsp[-1].comp, yyvsp[0].lval, 0); }
    break;

  case 123:
#line 801 "cp-name-parser.y"
    { yyval.comp = d_qualify (yyvsp[-1].comp, yyvsp[-2].lval | yyvsp[0].lval, 0); }
    break;

  case 124:
#line 803 "cp-name-parser.y"
    { yyval.comp = d_qualify (yyvsp[0].comp, yyvsp[-1].lval, 0); }
    break;

  case 125:
#line 806 "cp-name-parser.y"
    { yyval.comp = d_qualify (yyvsp[-1].comp, yyvsp[0].lval, 0); }
    break;

  case 126:
#line 808 "cp-name-parser.y"
    { yyval.comp = yyvsp[0].comp; }
    break;

  case 127:
#line 810 "cp-name-parser.y"
    { yyval.comp = d_qualify (yyvsp[-1].comp, yyvsp[-3].lval | yyvsp[0].lval, 0); }
    break;

  case 128:
#line 812 "cp-name-parser.y"
    { yyval.comp = d_qualify (yyvsp[0].comp, yyvsp[-2].lval, 0); }
    break;

  case 129:
#line 817 "cp-name-parser.y"
    { yyval.abstract.comp = yyvsp[0].nested.comp; yyval.abstract.last = yyvsp[0].nested.last;
			  yyval.abstract.fn.comp = NULL; yyval.abstract.fn.last = NULL; }
    break;

  case 130:
#line 820 "cp-name-parser.y"
    { yyval.abstract = yyvsp[0].abstract; yyval.abstract.fn.comp = NULL; yyval.abstract.fn.last = NULL;
			  if (yyvsp[0].abstract.fn.comp) { yyval.abstract.last = yyvsp[0].abstract.fn.last; *yyvsp[0].abstract.last = yyvsp[0].abstract.fn.comp; }
			  *yyval.abstract.last = yyvsp[-1].nested.comp;
			  yyval.abstract.last = yyvsp[-1].nested.last; }
    break;

  case 131:
#line 825 "cp-name-parser.y"
    { yyval.abstract.fn.comp = NULL; yyval.abstract.fn.last = NULL;
			  if (yyvsp[0].abstract.fn.comp) { yyval.abstract.last = yyvsp[0].abstract.fn.last; *yyvsp[0].abstract.last = yyvsp[0].abstract.fn.comp; }
			}
    break;

  case 132:
#line 832 "cp-name-parser.y"
    { yyval.abstract = yyvsp[-1].abstract; yyval.abstract.fn.comp = NULL; yyval.abstract.fn.last = NULL; yyval.abstract.fold_flag = 1;
			  if (yyvsp[-1].abstract.fn.comp) { yyval.abstract.last = yyvsp[-1].abstract.fn.last; *yyvsp[-1].abstract.last = yyvsp[-1].abstract.fn.comp; }
			}
    break;

  case 133:
#line 836 "cp-name-parser.y"
    { yyval.abstract.fold_flag = 0;
			  if (yyvsp[-1].abstract.fn.comp) { yyval.abstract.last = yyvsp[-1].abstract.fn.last; *yyvsp[-1].abstract.last = yyvsp[-1].abstract.fn.comp; }
			  if (yyvsp[-1].abstract.fold_flag)
			    {
			      *yyval.abstract.last = yyvsp[0].nested.comp;
			      yyval.abstract.last = yyvsp[0].nested.last;
			    }
			  else
			    yyval.abstract.fn = yyvsp[0].nested;
			}
    break;

  case 134:
#line 847 "cp-name-parser.y"
    { yyval.abstract.fn.comp = NULL; yyval.abstract.fn.last = NULL; yyval.abstract.fold_flag = 0;
			  if (yyvsp[-1].abstract.fn.comp) { yyval.abstract.last = yyvsp[-1].abstract.fn.last; *yyvsp[-1].abstract.last = yyvsp[-1].abstract.fn.comp; }
			  *yyvsp[-1].abstract.last = yyvsp[0].comp;
			  yyval.abstract.last = &d_right (yyvsp[0].comp);
			}
    break;

  case 135:
#line 853 "cp-name-parser.y"
    { yyval.abstract.fn.comp = NULL; yyval.abstract.fn.last = NULL; yyval.abstract.fold_flag = 0;
			  yyval.abstract.comp = yyvsp[0].comp;
			  yyval.abstract.last = &d_right (yyvsp[0].comp);
			}
    break;

  case 136:
#line 871 "cp-name-parser.y"
    { yyval.abstract.comp = yyvsp[0].nested.comp; yyval.abstract.last = yyvsp[0].nested.last;
			  yyval.abstract.fn.comp = NULL; yyval.abstract.fn.last = NULL; yyval.abstract.start = NULL; }
    break;

  case 137:
#line 874 "cp-name-parser.y"
    { yyval.abstract = yyvsp[0].abstract;
			  if (yyvsp[0].abstract.last)
			    *yyval.abstract.last = yyvsp[-1].nested.comp;
			  else
			    yyval.abstract.comp = yyvsp[-1].nested.comp;
			  yyval.abstract.last = yyvsp[-1].nested.last;
			}
    break;

  case 138:
#line 882 "cp-name-parser.y"
    { yyval.abstract.comp = yyvsp[0].abstract.comp; yyval.abstract.last = yyvsp[0].abstract.last; yyval.abstract.fn = yyvsp[0].abstract.fn; yyval.abstract.start = NULL; }
    break;

  case 139:
#line 884 "cp-name-parser.y"
    { yyval.abstract.start = yyvsp[0].comp;
			  if (yyvsp[-3].abstract.fn.comp) { yyval.abstract.last = yyvsp[-3].abstract.fn.last; *yyvsp[-3].abstract.last = yyvsp[-3].abstract.fn.comp; }
			  if (yyvsp[-3].abstract.fold_flag)
			    {
			      *yyval.abstract.last = yyvsp[-2].nested.comp;
			      yyval.abstract.last = yyvsp[-2].nested.last;
			    }
			  else
			    yyval.abstract.fn = yyvsp[-2].nested;
			}
    break;

  case 140:
#line 895 "cp-name-parser.y"
    { yyval.abstract.fn = yyvsp[-1].nested;
			  yyval.abstract.start = yyvsp[0].comp;
			  yyval.abstract.comp = NULL; yyval.abstract.last = NULL;
			}
    break;

  case 142:
#line 903 "cp-name-parser.y"
    { yyval.comp = yyvsp[0].abstract.comp;
			  *yyvsp[0].abstract.last = yyvsp[-1].comp;
			}
    break;

  case 143:
#line 909 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[0].nested.comp;
			  yyval.nested.last = yyvsp[-1].nested.last;
			  *yyvsp[0].nested.last = yyvsp[-1].nested.comp; }
    break;

  case 145:
#line 917 "cp-name-parser.y"
    { yyval.nested = yyvsp[-1].nested; }
    break;

  case 146:
#line 919 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[-1].nested.comp;
			  *yyvsp[-1].nested.last = yyvsp[0].nested.comp;
			  yyval.nested.last = yyvsp[0].nested.last;
			}
    break;

  case 147:
#line 924 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[-1].nested.comp;
			  *yyvsp[-1].nested.last = yyvsp[0].comp;
			  yyval.nested.last = &d_right (yyvsp[0].comp);
			}
    break;

  case 148:
#line 929 "cp-name-parser.y"
    { yyval.nested.comp = make_empty (DEMANGLE_COMPONENT_TYPED_NAME);
			  d_left (yyval.nested.comp) = yyvsp[0].comp;
			  yyval.nested.last = &d_right (yyval.nested.comp);
			}
    break;

  case 149:
#line 942 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[0].nested.comp;
			  yyval.nested.last = yyvsp[-1].nested.last;
			  *yyvsp[0].nested.last = yyvsp[-1].nested.comp; }
    break;

  case 150:
#line 946 "cp-name-parser.y"
    { yyval.nested.comp = make_empty (DEMANGLE_COMPONENT_TYPED_NAME);
			  d_left (yyval.nested.comp) = yyvsp[0].comp;
			  yyval.nested.last = &d_right (yyval.nested.comp);
			}
    break;

  case 152:
#line 959 "cp-name-parser.y"
    { yyval.nested.comp = fill_comp (DEMANGLE_COMPONENT_TYPED_NAME, yyvsp[-3].comp, yyvsp[-2].nested.comp);
			  yyval.nested.last = yyvsp[-2].nested.last;
			  yyval.nested.comp = fill_comp (DEMANGLE_COMPONENT_LOCAL_NAME, yyval.nested.comp, yyvsp[0].comp);
			}
    break;

  case 153:
#line 964 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[-3].nested.comp;
			  *yyvsp[-3].nested.last = yyvsp[-2].nested.comp;
			  yyval.nested.last = yyvsp[-2].nested.last;
			  yyval.nested.comp = fill_comp (DEMANGLE_COMPONENT_LOCAL_NAME, yyval.nested.comp, yyvsp[0].comp);
			}
    break;

  case 154:
#line 973 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[-1].nested.comp;
			  yyval.nested.last = yyvsp[-2].nested.last;
			  *yyvsp[-1].nested.last = yyvsp[-2].nested.comp; }
    break;

  case 155:
#line 977 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[-1].nested.comp;
			  *yyvsp[-1].nested.last = yyvsp[0].nested.comp;
			  yyval.nested.last = yyvsp[0].nested.last;
			}
    break;

  case 156:
#line 982 "cp-name-parser.y"
    { yyval.nested.comp = yyvsp[-1].nested.comp;
			  *yyvsp[-1].nested.last = yyvsp[0].comp;
			  yyval.nested.last = &d_right (yyvsp[0].comp);
			}
    break;

  case 157:
#line 987 "cp-name-parser.y"
    { yyval.nested.comp = fill_comp (DEMANGLE_COMPONENT_TYPED_NAME, yyvsp[-1].comp, yyvsp[0].nested.comp);
			  yyval.nested.last = yyvsp[0].nested.last;
			}
    break;

  case 158:
#line 991 "cp-name-parser.y"
    { yyval.nested.comp = fill_comp (DEMANGLE_COMPONENT_TYPED_NAME, yyvsp[-1].comp, yyvsp[0].comp);
			  yyval.nested.last = &d_right (yyvsp[0].comp);
			}
    break;

  case 159:
#line 997 "cp-name-parser.y"
    { yyval.comp = yyvsp[-1].comp; }
    break;

  case 161:
#line 1006 "cp-name-parser.y"
    { yyval.comp = d_binary (">", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 162:
#line 1013 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_UNARY, make_operator ("&", 1), yyvsp[0].comp); }
    break;

  case 163:
#line 1015 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_UNARY, make_operator ("&", 1), yyvsp[-1].comp); }
    break;

  case 164:
#line 1020 "cp-name-parser.y"
    { yyval.comp = d_unary ("-", yyvsp[0].comp); }
    break;

  case 165:
#line 1024 "cp-name-parser.y"
    { yyval.comp = d_unary ("!", yyvsp[0].comp); }
    break;

  case 166:
#line 1028 "cp-name-parser.y"
    { yyval.comp = d_unary ("~", yyvsp[0].comp); }
    break;

  case 167:
#line 1035 "cp-name-parser.y"
    { if (yyvsp[0].comp->type == DEMANGLE_COMPONENT_LITERAL
		      || yyvsp[0].comp->type == DEMANGLE_COMPONENT_LITERAL_NEG)
		    {
		      yyval.comp = yyvsp[0].comp;
		      d_left (yyvsp[0].comp) = yyvsp[-2].comp;
		    }
		  else
		    yyval.comp = fill_comp (DEMANGLE_COMPONENT_UNARY,
				      fill_comp (DEMANGLE_COMPONENT_CAST, yyvsp[-2].comp, NULL),
				      yyvsp[0].comp);
		}
    break;

  case 168:
#line 1051 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_UNARY,
				    fill_comp (DEMANGLE_COMPONENT_CAST, yyvsp[-4].comp, NULL),
				    yyvsp[-1].comp);
		}
    break;

  case 169:
#line 1058 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_UNARY,
				    fill_comp (DEMANGLE_COMPONENT_CAST, yyvsp[-4].comp, NULL),
				    yyvsp[-1].comp);
		}
    break;

  case 170:
#line 1065 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_UNARY,
				    fill_comp (DEMANGLE_COMPONENT_CAST, yyvsp[-4].comp, NULL),
				    yyvsp[-1].comp);
		}
    break;

  case 171:
#line 1084 "cp-name-parser.y"
    { yyval.comp = d_binary ("*", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 172:
#line 1088 "cp-name-parser.y"
    { yyval.comp = d_binary ("/", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 173:
#line 1092 "cp-name-parser.y"
    { yyval.comp = d_binary ("%", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 174:
#line 1096 "cp-name-parser.y"
    { yyval.comp = d_binary ("+", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 175:
#line 1100 "cp-name-parser.y"
    { yyval.comp = d_binary ("-", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 176:
#line 1104 "cp-name-parser.y"
    { yyval.comp = d_binary ("<<", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 177:
#line 1108 "cp-name-parser.y"
    { yyval.comp = d_binary (">>", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 178:
#line 1112 "cp-name-parser.y"
    { yyval.comp = d_binary ("==", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 179:
#line 1116 "cp-name-parser.y"
    { yyval.comp = d_binary ("!=", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 180:
#line 1120 "cp-name-parser.y"
    { yyval.comp = d_binary ("<=", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 181:
#line 1124 "cp-name-parser.y"
    { yyval.comp = d_binary (">=", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 182:
#line 1128 "cp-name-parser.y"
    { yyval.comp = d_binary ("<", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 183:
#line 1132 "cp-name-parser.y"
    { yyval.comp = d_binary ("&", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 184:
#line 1136 "cp-name-parser.y"
    { yyval.comp = d_binary ("^", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 185:
#line 1140 "cp-name-parser.y"
    { yyval.comp = d_binary ("|", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 186:
#line 1144 "cp-name-parser.y"
    { yyval.comp = d_binary ("&&", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 187:
#line 1148 "cp-name-parser.y"
    { yyval.comp = d_binary ("||", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 188:
#line 1153 "cp-name-parser.y"
    { yyval.comp = d_binary ("->", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 189:
#line 1157 "cp-name-parser.y"
    { yyval.comp = d_binary (".", yyvsp[-2].comp, yyvsp[0].comp); }
    break;

  case 190:
#line 1161 "cp-name-parser.y"
    { yyval.comp = fill_comp (DEMANGLE_COMPONENT_TRINARY, make_operator ("?", 3),
				    fill_comp (DEMANGLE_COMPONENT_TRINARY_ARG1, yyvsp[-4].comp,
						 fill_comp (DEMANGLE_COMPONENT_TRINARY_ARG2, yyvsp[-2].comp, yyvsp[0].comp)));
		}
    break;

  case 193:
#line 1175 "cp-name-parser.y"
    { yyval.comp = d_unary ("sizeof", yyvsp[-1].comp); }
    break;

  case 194:
#line 1180 "cp-name-parser.y"
    { struct demangle_component *i;
		  i = make_name ("1", 1);
		  yyval.comp = fill_comp (DEMANGLE_COMPONENT_LITERAL,
				    make_builtin_type ("bool"),
				    i);
		}
    break;

  case 195:
#line 1189 "cp-name-parser.y"
    { struct demangle_component *i;
		  i = make_name ("0", 1);
		  yyval.comp = fill_comp (DEMANGLE_COMPONENT_LITERAL,
				    make_builtin_type ("bool"),
				    i);
		}
    break;


    }

/* Line 1000 of yacc.c.  */
#line 2843 "cp-name-parser.c.tmp"

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
      /* If just tried and failed to reuse lookahead token after an
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
		 YYDSYMPRINTF ("Error: popping", yystos[*yyssp], yyvsp, yylsp);
		 yydestruct (yystos[*yyssp], yyvsp);
	       }
        }
      else
	{
	  YYDSYMPRINTF ("Error: discarding", yytoken, &yylval, &yylloc);
	  yydestruct (yytoken, &yylval);
	  yychar = YYEMPTY;

	}
    }

  /* Else will try to reuse lookahead token after shifting the error
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

      YYDSYMPRINTF ("Error: popping", yystos[*yyssp], yyvsp, yylsp);
      yydestruct (yystos[yystate], yyvsp);
      YYPOPSTACK;
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  YYDPRINTF ((stderr, "Shifting error token, "));

  *++yyvsp = yylval;


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


#line 1199 "cp-name-parser.y"


/* Apply QUALIFIERS to LHS and return a qualified component.  IS_METHOD
   is set if LHS is a method, in which case the qualifiers are logically
   applied to "this".  We apply qualifiers in a consistent order; LHS
   may already be qualified; duplicate qualifiers are not created.  */

struct demangle_component *
d_qualify (struct demangle_component *lhs, int qualifiers, int is_method)
{
  struct demangle_component **inner_p;
  enum demangle_component_type type;

  /* For now the order is CONST (innermost), VOLATILE, RESTRICT.  */

#define HANDLE_QUAL(TYPE, MTYPE, QUAL)				\
  if ((qualifiers & QUAL) && (type != TYPE) && (type != MTYPE))	\
    {								\
      *inner_p = fill_comp (is_method ? MTYPE : TYPE,	\
			      *inner_p, NULL);			\
      inner_p = &d_left (*inner_p);				\
      type = (*inner_p)->type;					\
    }								\
  else if (type == TYPE || type == MTYPE)			\
    {								\
      inner_p = &d_left (*inner_p);				\
      type = (*inner_p)->type;					\
    }

  inner_p = &lhs;

  type = (*inner_p)->type;

  HANDLE_QUAL (DEMANGLE_COMPONENT_RESTRICT, DEMANGLE_COMPONENT_RESTRICT_THIS, QUAL_RESTRICT);
  HANDLE_QUAL (DEMANGLE_COMPONENT_VOLATILE, DEMANGLE_COMPONENT_VOLATILE_THIS, QUAL_VOLATILE);
  HANDLE_QUAL (DEMANGLE_COMPONENT_CONST, DEMANGLE_COMPONENT_CONST_THIS, QUAL_CONST);

  return lhs;
}

/* Return a builtin type corresponding to FLAGS.  */

static struct demangle_component *
d_int_type (int flags)
{
  const char *name;

  switch (flags)
    {
    case INT_SIGNED | INT_CHAR:
      name = "signed char";
      break;
    case INT_CHAR:
      name = "char";
      break;
    case INT_UNSIGNED | INT_CHAR:
      name = "unsigned char";
      break;
    case 0:
    case INT_SIGNED:
      name = "int";
      break;
    case INT_UNSIGNED:
      name = "unsigned int";
      break;
    case INT_LONG:
    case INT_SIGNED | INT_LONG:
      name = "long";
      break;
    case INT_UNSIGNED | INT_LONG:
      name = "unsigned long";
      break;
    case INT_SHORT:
    case INT_SIGNED | INT_SHORT:
      name = "short";
      break;
    case INT_UNSIGNED | INT_SHORT:
      name = "unsigned short";
      break;
    case INT_LLONG | INT_LONG:
    case INT_SIGNED | INT_LLONG | INT_LONG:
      name = "long long";
      break;
    case INT_UNSIGNED | INT_LLONG | INT_LONG:
      name = "unsigned long long";
      break;
    default:
      return NULL;
    }

  return make_builtin_type (name);
}

/* Wrapper to create a unary operation.  */

static struct demangle_component *
d_unary (const char *name, struct demangle_component *lhs)
{
  return fill_comp (DEMANGLE_COMPONENT_UNARY, make_operator (name, 1), lhs);
}

/* Wrapper to create a binary operation.  */

static struct demangle_component *
d_binary (const char *name, struct demangle_component *lhs, struct demangle_component *rhs)
{
  return fill_comp (DEMANGLE_COMPONENT_BINARY, make_operator (name, 2),
		      fill_comp (DEMANGLE_COMPONENT_BINARY_ARGS, lhs, rhs));
}

/* Find the end of a symbol name starting at LEXPTR.  */

static const char *
symbol_end (const char *lexptr)
{
  const char *p = lexptr;

  while (*p && (ISALNUM (*p) || *p == '_' || *p == '$' || *p == '.'))
    p++;

  return p;
}

/* Take care of parsing a number (anything that starts with a digit).
   The number starts at P and contains LEN characters.  Store the result in
   YYLVAL.  */

static int
parse_number (const char *p, int len, int parsed_float)
{
  int unsigned_p = 0;

  /* Number of "L" suffixes encountered.  */
  int long_p = 0;

  struct demangle_component *signed_type;
  struct demangle_component *unsigned_type;
  struct demangle_component *type, *name;
  enum demangle_component_type literal_type;

  if (p[0] == '-')
    {
      literal_type = DEMANGLE_COMPONENT_LITERAL_NEG;
      p++;
      len--;
    }
  else
    literal_type = DEMANGLE_COMPONENT_LITERAL;

  if (parsed_float)
    {
      /* It's a float since it contains a point or an exponent.  */
      char c;

      /* The GDB lexer checks the result of scanf at this point.  Not doing
         this leaves our error checking slightly weaker but only for invalid
         data.  */

      /* See if it has `f' or `l' suffix (float or long double).  */

      c = TOLOWER (p[len - 1]);

      if (c == 'f')
      	{
      	  len--;
      	  type = make_builtin_type ("float");
      	}
      else if (c == 'l')
	{
	  len--;
	  type = make_builtin_type ("long double");
	}
      else if (ISDIGIT (c) || c == '.')
	type = make_builtin_type ("double");
      else
	return ERROR;

      name = make_name (p, len);
      yylval.comp = fill_comp (literal_type, type, name);

      return FLOAT;
    }

  /* This treats 0x1 and 1 as different literals.  We also do not
     automatically generate unsigned types.  */

  long_p = 0;
  unsigned_p = 0;
  while (len > 0)
    {
      if (p[len - 1] == 'l' || p[len - 1] == 'L')
	{
	  len--;
	  long_p++;
	  continue;
	}
      if (p[len - 1] == 'u' || p[len - 1] == 'U')
	{
	  len--;
	  unsigned_p++;
	  continue;
	}
      break;
    }

  if (long_p == 0)
    {
      unsigned_type = make_builtin_type ("unsigned int");
      signed_type = make_builtin_type ("int");
    }
  else if (long_p == 1)
    {
      unsigned_type = make_builtin_type ("unsigned long");
      signed_type = make_builtin_type ("long");
    }
  else
    {
      unsigned_type = make_builtin_type ("unsigned long long");
      signed_type = make_builtin_type ("long long");
    }

   if (unsigned_p)
     type = unsigned_type;
   else
     type = signed_type;

   name = make_name (p, len);
   yylval.comp = fill_comp (literal_type, type, name);

   return INT;
}

static char backslashable[] = "abefnrtv";
static char represented[] = "\a\b\e\f\n\r\t\v";

/* Translate the backslash the way we would in the host character set.  */
static int
c_parse_backslash (int host_char, int *target_char)
{
  const char *ix;
  ix = strchr (backslashable, host_char);
  if (! ix)
    return 0;
  else
    *target_char = represented[ix - backslashable];
  return 1;
}

/* Parse a C escape sequence.  STRING_PTR points to a variable
   containing a pointer to the string to parse.  That pointer
   should point to the character after the \.  That pointer
   is updated past the characters we use.  The value of the
   escape sequence is returned.

   A negative value means the sequence \ newline was seen,
   which is supposed to be equivalent to nothing at all.

   If \ is followed by a null character, we return a negative
   value and leave the string pointer pointing at the null character.

   If \ is followed by 000, we return 0 and leave the string pointer
   after the zeros.  A value of 0 does not mean end of string.  */

static int
parse_escape (const char **string_ptr)
{
  int target_char;
  int c = *(*string_ptr)++;
  if (c_parse_backslash (c, &target_char))
    return target_char;
  else
    switch (c)
      {
      case '\n':
	return -2;
      case 0:
	(*string_ptr)--;
	return 0;
      case '^':
	{
	  c = *(*string_ptr)++;

	  if (c == '?')
	    return 0177;
	  else if (c == '\\')
	    target_char = parse_escape (string_ptr);
	  else
	    target_char = c;

	  /* Now target_char is something like `c', and we want to find
	     its control-character equivalent.  */
	  target_char = target_char & 037;

	  return target_char;
	}

      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
	{
	  int i = c - '0';
	  int count = 0;
	  while (++count < 3)
	    {
	      c = (**string_ptr);
	      if (c >= '0' && c <= '7')
		{
		  (*string_ptr)++;
		  i *= 8;
		  i += c - '0';
		}
	      else
		{
		  break;
		}
	    }
	  return i;
	}
      default:
	return c;
      }
}

#define HANDLE_SPECIAL(string, comp)				\
  if (strncmp (tokstart, string, sizeof (string) - 1) == 0)	\
    {								\
      lexptr = tokstart + sizeof (string) - 1;			\
      yylval.lval = comp;					\
      return DEMANGLER_SPECIAL;					\
    }

#define HANDLE_TOKEN2(string, token)			\
  if (lexptr[1] == string[1])				\
    {							\
      lexptr += 2;					\
      yylval.opname = string;				\
      return token;					\
    }      

#define HANDLE_TOKEN3(string, token)			\
  if (lexptr[1] == string[1] && lexptr[2] == string[2])	\
    {							\
      lexptr += 3;					\
      yylval.opname = string;				\
      return token;					\
    }      

/* Read one token, getting characters through LEXPTR.  */

static int
yylex (void)
{
  int c;
  int namelen;
  const char *tokstart, *tokptr;

 retry:
  prev_lexptr = lexptr;
  tokstart = lexptr;

  switch (c = *tokstart)
    {
    case 0:
      return 0;

    case ' ':
    case '\t':
    case '\n':
      lexptr++;
      goto retry;

    case '\'':
      /* We either have a character constant ('0' or '\177' for example)
	 or we have a quoted symbol reference ('foo(int,int)' in C++
	 for example). */
      lexptr++;
      c = *lexptr++;
      if (c == '\\')
	c = parse_escape (&lexptr);
      else if (c == '\'')
	{
	  yyerror ("empty character constant");
	  return ERROR;
	}

      c = *lexptr++;
      if (c != '\'')
	{
	  yyerror ("invalid character constant");
	  return ERROR;
	}

      /* FIXME: We should refer to a canonical form of the character,
	 presumably the same one that appears in manglings - the decimal
	 representation.  But if that isn't in our input then we have to
	 allocate memory for it somewhere.  */
      yylval.comp = fill_comp (DEMANGLE_COMPONENT_LITERAL,
				 make_builtin_type ("char"),
				 make_name (tokstart, lexptr - tokstart));

      return INT;

    case '(':
      if (strncmp (tokstart, "(anonymous namespace)", 21) == 0)
	{
	  lexptr += 21;
	  yylval.comp = make_name ("(anonymous namespace)",
				     sizeof "(anonymous namespace)" - 1);
	  return NAME;
	}
	/* FALL THROUGH */

    case ')':
    case ',':
      lexptr++;
      return c;

    case '.':
      if (lexptr[1] == '.' && lexptr[2] == '.')
	{
	  lexptr += 3;
	  return ELLIPSIS;
	}

      /* Might be a floating point number.  */
      if (lexptr[1] < '0' || lexptr[1] > '9')
	goto symbol;		/* Nope, must be a symbol. */

      goto try_number;

    case '-':
      HANDLE_TOKEN2 ("-=", ASSIGN_MODIFY);
      HANDLE_TOKEN2 ("--", DECREMENT);
      HANDLE_TOKEN2 ("->", ARROW);

      /* For construction vtables.  This is kind of hokey.  */
      if (strncmp (tokstart, "-in-", 4) == 0)
	{
	  lexptr += 4;
	  return CONSTRUCTION_IN;
	}

      if (lexptr[1] < '0' || lexptr[1] > '9')
	{
	  lexptr++;
	  return '-';
	}
      /* FALL THRU into number case.  */

    try_number:
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      {
	/* It's a number.  */
	int got_dot = 0, got_e = 0, toktype;
	const char *p = tokstart;
	int hex = 0;

	if (c == '-')
	  p++;

	if (c == '0' && (p[1] == 'x' || p[1] == 'X'))
	  {
	    p += 2;
	    hex = 1;
	  }
	else if (c == '0' && (p[1]=='t' || p[1]=='T' || p[1]=='d' || p[1]=='D'))
	  {
	    p += 2;
	    hex = 0;
	  }

	for (;; ++p)
	  {
	    /* This test includes !hex because 'e' is a valid hex digit
	       and thus does not indicate a floating point number when
	       the radix is hex.  */
	    if (!hex && !got_e && (*p == 'e' || *p == 'E'))
	      got_dot = got_e = 1;
	    /* This test does not include !hex, because a '.' always indicates
	       a decimal floating point number regardless of the radix.

	       NOTE drow/2005-03-09: This comment is not accurate in C99;
	       however, it's not clear that all the floating point support
	       in this file is doing any good here.  */
	    else if (!got_dot && *p == '.')
	      got_dot = 1;
	    else if (got_e && (p[-1] == 'e' || p[-1] == 'E')
		     && (*p == '-' || *p == '+'))
	      /* This is the sign of the exponent, not the end of the
		 number.  */
	      continue;
	    /* We will take any letters or digits.  parse_number will
	       complain if past the radix, or if L or U are not final.  */
	    else if (! ISALNUM (*p))
	      break;
	  }
	toktype = parse_number (tokstart, p - tokstart, got_dot|got_e);
        if (toktype == ERROR)
	  {
	    char *err_copy = (char *) alloca (p - tokstart + 1);

	    memcpy (err_copy, tokstart, p - tokstart);
	    err_copy[p - tokstart] = 0;
	    yyerror ("invalid number");
	    return ERROR;
	  }
	lexptr = p;
	return toktype;
      }

    case '+':
      HANDLE_TOKEN2 ("+=", ASSIGN_MODIFY);
      HANDLE_TOKEN2 ("++", INCREMENT);
      lexptr++;
      return c;
    case '*':
      HANDLE_TOKEN2 ("*=", ASSIGN_MODIFY);
      lexptr++;
      return c;
    case '/':
      HANDLE_TOKEN2 ("/=", ASSIGN_MODIFY);
      lexptr++;
      return c;
    case '%':
      HANDLE_TOKEN2 ("%=", ASSIGN_MODIFY);
      lexptr++;
      return c;
    case '|':
      HANDLE_TOKEN2 ("|=", ASSIGN_MODIFY);
      HANDLE_TOKEN2 ("||", OROR);
      lexptr++;
      return c;
    case '&':
      HANDLE_TOKEN2 ("&=", ASSIGN_MODIFY);
      HANDLE_TOKEN2 ("&&", ANDAND);
      lexptr++;
      return c;
    case '^':
      HANDLE_TOKEN2 ("^=", ASSIGN_MODIFY);
      lexptr++;
      return c;
    case '!':
      HANDLE_TOKEN2 ("!=", NOTEQUAL);
      lexptr++;
      return c;
    case '<':
      HANDLE_TOKEN3 ("<<=", ASSIGN_MODIFY);
      HANDLE_TOKEN2 ("<=", LEQ);
      HANDLE_TOKEN2 ("<<", LSH);
      lexptr++;
      return c;
    case '>':
      HANDLE_TOKEN3 (">>=", ASSIGN_MODIFY);
      HANDLE_TOKEN2 (">=", GEQ);
      HANDLE_TOKEN2 (">>", RSH);
      lexptr++;
      return c;
    case '=':
      HANDLE_TOKEN2 ("==", EQUAL);
      lexptr++;
      return c;
    case ':':
      HANDLE_TOKEN2 ("::", COLONCOLON);
      lexptr++;
      return c;

    case '[':
    case ']':
    case '?':
    case '@':
    case '~':
    case '{':
    case '}':
    symbol:
      lexptr++;
      return c;

    case '"':
      /* These can't occur in C++ names.  */
      yyerror ("unexpected string literal");
      return ERROR;
    }

  if (!(c == '_' || c == '$' || ISALPHA (c)))
    {
      /* We must have come across a bad character (e.g. ';').  */
      yyerror ("invalid character");
      return ERROR;
    }

  /* It's a name.  See how long it is.  */
  namelen = 0;
  do
    c = tokstart[++namelen];
  while (ISALNUM (c) || c == '_' || c == '$');

  lexptr += namelen;

  /* Catch specific keywords.  Notice that some of the keywords contain
     spaces, and are sorted by the length of the first word.  They must
     all include a trailing space in the string comparison.  */
  switch (namelen)
    {
    case 16:
      if (strncmp (tokstart, "reinterpret_cast", 16) == 0)
        return REINTERPRET_CAST;
      break;
    case 12:
      if (strncmp (tokstart, "construction vtable for ", 24) == 0)
	{
	  lexptr = tokstart + 24;
	  return CONSTRUCTION_VTABLE;
	}
      if (strncmp (tokstart, "dynamic_cast", 12) == 0)
        return DYNAMIC_CAST;
      break;
    case 11:
      if (strncmp (tokstart, "static_cast", 11) == 0)
        return STATIC_CAST;
      break;
    case 9:
      HANDLE_SPECIAL ("covariant return thunk to ", DEMANGLE_COMPONENT_COVARIANT_THUNK);
      HANDLE_SPECIAL ("reference temporary for ", DEMANGLE_COMPONENT_REFTEMP);
      break;
    case 8:
      HANDLE_SPECIAL ("typeinfo for ", DEMANGLE_COMPONENT_TYPEINFO);
      HANDLE_SPECIAL ("typeinfo fn for ", DEMANGLE_COMPONENT_TYPEINFO_FN);
      HANDLE_SPECIAL ("typeinfo name for ", DEMANGLE_COMPONENT_TYPEINFO_NAME);
      if (strncmp (tokstart, "operator", 8) == 0)
	return OPERATOR;
      if (strncmp (tokstart, "restrict", 8) == 0)
	return RESTRICT;
      if (strncmp (tokstart, "unsigned", 8) == 0)
	return UNSIGNED;
      if (strncmp (tokstart, "template", 8) == 0)
	return TEMPLATE;
      if (strncmp (tokstart, "volatile", 8) == 0)
	return VOLATILE_KEYWORD;
      break;
    case 7:
      HANDLE_SPECIAL ("virtual thunk to ", DEMANGLE_COMPONENT_VIRTUAL_THUNK);
      if (strncmp (tokstart, "wchar_t", 7) == 0)
	return WCHAR_T;
      break;
    case 6:
      if (strncmp (tokstart, "global constructors keyed to ", 29) == 0)
	{
	  const char *p;
	  lexptr = tokstart + 29;
	  yylval.typed_val_int.val = GLOBAL_CONSTRUCTORS;
	  /* Find the end of the symbol.  */
	  p = symbol_end (lexptr);
	  yylval.typed_val_int.type = make_name (lexptr, p - lexptr);
	  lexptr = p;
	  return GLOBAL;
	}
      if (strncmp (tokstart, "global destructors keyed to ", 28) == 0)
	{
	  const char *p;
	  lexptr = tokstart + 28;
	  yylval.typed_val_int.val = GLOBAL_DESTRUCTORS;
	  /* Find the end of the symbol.  */
	  p = symbol_end (lexptr);
	  yylval.typed_val_int.type = make_name (lexptr, p - lexptr);
	  lexptr = p;
	  return GLOBAL;
	}

      HANDLE_SPECIAL ("vtable for ", DEMANGLE_COMPONENT_VTABLE);
      if (strncmp (tokstart, "delete", 6) == 0)
	return DELETE;
      if (strncmp (tokstart, "struct", 6) == 0)
	return STRUCT;
      if (strncmp (tokstart, "signed", 6) == 0)
	return SIGNED_KEYWORD;
      if (strncmp (tokstart, "sizeof", 6) == 0)
	return SIZEOF;
      if (strncmp (tokstart, "double", 6) == 0)
	return DOUBLE_KEYWORD;
      break;
    case 5:
      HANDLE_SPECIAL ("guard variable for ", DEMANGLE_COMPONENT_GUARD);
      if (strncmp (tokstart, "false", 5) == 0)
	return FALSEKEYWORD;
      if (strncmp (tokstart, "class", 5) == 0)
	return CLASS;
      if (strncmp (tokstart, "union", 5) == 0)
	return UNION;
      if (strncmp (tokstart, "float", 5) == 0)
	return FLOAT_KEYWORD;
      if (strncmp (tokstart, "short", 5) == 0)
	return SHORT;
      if (strncmp (tokstart, "const", 5) == 0)
	return CONST_KEYWORD;
      break;
    case 4:
      if (strncmp (tokstart, "void", 4) == 0)
	return VOID;
      if (strncmp (tokstart, "bool", 4) == 0)
	return BOOL;
      if (strncmp (tokstart, "char", 4) == 0)
	return CHAR;
      if (strncmp (tokstart, "enum", 4) == 0)
	return ENUM;
      if (strncmp (tokstart, "long", 4) == 0)
	return LONG;
      if (strncmp (tokstart, "true", 4) == 0)
	return TRUEKEYWORD;
      break;
    case 3:
      HANDLE_SPECIAL ("VTT for ", DEMANGLE_COMPONENT_VTT);
      HANDLE_SPECIAL ("non-virtual thunk to ", DEMANGLE_COMPONENT_THUNK);
      if (strncmp (tokstart, "new", 3) == 0)
	return NEW;
      if (strncmp (tokstart, "int", 3) == 0)
	return INT_KEYWORD;
      break;
    default:
      break;
    }

  yylval.comp = make_name (tokstart, namelen);
  return NAME;
}

static void
yyerror (char *msg)
{
  if (global_errmsg)
    return;

  error_lexptr = prev_lexptr;
  global_errmsg = msg ? msg : "parse error";
}

/* Allocate a chunk of the components we'll need to build a tree.  We
   generally allocate too many components, but the extra memory usage
   doesn't hurt because the trees are temporary and the storage is
   reused.  More may be allocated later, by d_grab.  */
static void
allocate_info (void)
{
  if (demangle_info == NULL)
    {
      demangle_info = xmalloc (sizeof (struct demangle_info));
      demangle_info->prev = NULL;
      demangle_info->next = NULL;
    }
  else
    while (demangle_info->prev)
      demangle_info = demangle_info->prev;

  demangle_info->used = 0;
}

/* Convert RESULT to a string.  The return value is allocated
   using xmalloc.  ESTIMATED_LEN is used only as a guide to the
   length of the result.  This functions handles a few cases that
   cplus_demangle_print does not, specifically the global destructor
   and constructor labels.  */

char *
cp_comp_to_string (struct demangle_component *result, int estimated_len)
{
  char *str, *prefix = NULL, *buf;
  size_t err = 0;

  if (result->type == GLOBAL_DESTRUCTORS)
    {
      result = d_left (result);
      prefix = "global destructors keyed to ";
    }
  else if (result->type == GLOBAL_CONSTRUCTORS)
    {
      result = d_left (result);
      prefix = "global constructors keyed to ";
    }

  str = cplus_demangle_print (DMGL_PARAMS | DMGL_ANSI, result, estimated_len, &err);
  if (str == NULL)
    return NULL;

  if (prefix == NULL)
    return str;

  buf = xmalloc (strlen (str) + strlen (prefix) + 1);
  strcpy (buf, prefix);
  strcat (buf, str);
  free (str);
  return (buf);
}

/* Convert a demangled name to a demangle_component tree.  On success,
   the root of the new tree is returned; it is valid until the next
   call to this function and should not be freed.  On error, NULL is
   returned, and an error message will be set in *ERRMSG (which does
   not need to be freed).  */

struct demangle_component *
cp_demangled_name_to_comp (const char *demangled_name, const char **errmsg)
{
  static char errbuf[60];
  struct demangle_component *result;

  prev_lexptr = lexptr = demangled_name;
  error_lexptr = NULL;
  global_errmsg = NULL;

  allocate_info ();

  if (yyparse ())
    {
      if (global_errmsg && errmsg)
	{
	  snprintf (errbuf, sizeof (errbuf) - 2, "%s, near `%s",
		    global_errmsg, error_lexptr);
	  strcat (errbuf, "'");
	  *errmsg = errbuf;
	}
      return NULL;
    }

  result = global_result;
  global_result = NULL;

  return result;
}

#ifdef TEST_CPNAMES

static void
cp_print (struct demangle_component *result)
{
  char *str;
  size_t err = 0;

  if (result->type == GLOBAL_DESTRUCTORS)
    {
      result = d_left (result);
      fputs ("global destructors keyed to ", stdout);
    }
  else if (result->type == GLOBAL_CONSTRUCTORS)
    {
      result = d_left (result);
      fputs ("global constructors keyed to ", stdout);
    }

  str = cplus_demangle_print (DMGL_PARAMS | DMGL_ANSI, result, 64, &err);
  if (str == NULL)
    return;

  fputs (str, stdout);

  free (str);
}

static char
trim_chars (char *lexptr, char **extra_chars)
{
  char *p = (char *) symbol_end (lexptr);
  char c = 0;

  if (*p)
    {
      c = *p;
      *p = 0;
      *extra_chars = p + 1;
    }

  return c;
}

int
main (int argc, char **argv)
{
  char *str2, *extra_chars = "", c;
  char buf[65536];
  int arg;
  const char *errmsg;
  struct demangle_component *result;

  arg = 1;
  if (argv[arg] && strcmp (argv[arg], "--debug") == 0)
    {
      yydebug = 1;
      arg++;
    }

  if (argv[arg] == NULL)
    while (fgets (buf, 65536, stdin) != NULL)
      {
	int len;
	buf[strlen (buf) - 1] = 0;
	/* Use DMGL_VERBOSE to get expanded standard substitutions.  */
	c = trim_chars (buf, &extra_chars);
	str2 = cplus_demangle (buf, DMGL_PARAMS | DMGL_ANSI | DMGL_VERBOSE);
	if (str2 == NULL)
	  {
	    /* printf ("Demangling error\n"); */
	    if (c)
	      printf ("%s%c%s\n", buf, c, extra_chars);
	    else
	      printf ("%s\n", buf);
	    continue;
	  }
	result = cp_demangled_name_to_comp (str2, &errmsg);
	if (result == NULL)
	  {
	    fputs (errmsg, stderr);
	    fputc ('\n', stderr);
	    continue;
	  }

	cp_print (result);

	free (str2);
	if (c)
	  {
	    putchar (c);
	    fputs (extra_chars, stdout);
	  }
	putchar ('\n');
      }
  else
    {
      result = cp_demangled_name_to_comp (argv[arg], &errmsg);
      if (result == NULL)
	{
	  fputs (errmsg, stderr);
	  fputc ('\n', stderr);
	  return 0;
	}
      cp_print (result);
      putchar ('\n');
    }
  return 0;
}

#endif



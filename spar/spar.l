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
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <getopt.h>

#include "spar.h"
#include "ui.h"
#include "checks.h"
#include "code.h"
#include "emit.h"
#include "expand.h"
#include "exprs.h"
#include "fixes.h"
#include "optab.h"
#include "output.h"
#include "segtab.h"
#include "symtab.h"

char *command = NULL;

int8_t  output_mode = DEFAULT_MODE;
FILE   *output_file = NULL;
FILE   *rom0_file = NULL;
FILE   *rom1_file = NULL;

uint32_t codesize = DEFAULT_CODESIZE;
uint32_t datasize = DEFAULT_DATASIZE;
uint32_t romsize  = DEFAULT_ROMSIZE;
uint16_t filler = DEFAULT_FILLER;

int nostart = 0;
int noend = 0;

uint32_t line_count = 1;
uint32_t file_count = 0;
uint32_t error_count = 0;

int      seen_op = 0;
int8_t   args_to_match = -1;

/***************** WHAT TO DO ****************/
int initialize(void);
int merge(void);
int postprocess(void);

/* this does not really fit anywhere */
void expand_mod(void);

/***************** SHORTCUT ****************/
#define MATCH_OP(X) \
do { \
  struct seg *seg = get_current_seg(); \
  adjust_segsize(seg, seg->pos+1); \
  set_op(seg, seg->pos, (X)); \
  trace_listing(seg, seg->pos, yytext); \
  trace_listing(seg, seg->pos, "\t"); \
  seen_op = 1; \
  args_to_match = get_arg_count(seg, seg->pos)*2 - 1; \
} while(0)

%}

REG  (r[0-9]+)
NUM  ((-?0[0-7]*)|(-?[1-9][0-9]*)|(-?0x[0-9a-fA-F]+))
BNUM (0b[0-1]+)
SYM  (\.?[_\.a-zA-Z0-9]+)
EXPR (([^ \t\r\n,;])|([^ \t\r\n,;][^,;\n]*[^ \t\r\n,;]))

%%

\.file[ \t]*\r?\n   file_count++;

\.text[ \t]*\r?\n   set_current_segnum(SEG_TEXT);
\.data[ \t]*\r?\n   set_current_segnum(SEG_DATA);
\.bss[ \t]*\r?\n    set_current_segnum(SEG_BSS);

\.align[ \t]{EXPR}\r?\n {
         struct seg *seg = get_current_seg();
         char *s = xstrdup(yytext+7);
         int32_t a = 1 << expr_nevaluate(s);

	 while ((seg->pos % a) != 0)
	   {
	     if (get_current_segnum() == SEG_TEXT)
	       {
		 emit_nop(seg);
	       }
	     else
	       {
		 emit_zero(seg);
	       }
	   }
       }

\.comm[ \t]{SYM}[ \t]*,[ \t]*{EXPR}\r?\n {
	 int32_t i;
         char *s = xstrdup(yytext+6);
	 char *t = s;
	 
	 t = strpbrk(s, ",");
	 *t++ = '\0';
	 
	 s = localize_string(s);
	 check_sym_dup(s);
	 push_sym(s, SEG_BSS, get_seg(SEG_BSS)->pos);
	 trace_listing(get_seg(SEG_BSS), get_seg(SEG_BSS)->pos, s);
	 trace_listing(get_seg(SEG_BSS), get_seg(SEG_BSS)->pos, ":\t");

	 for (i=0; i < expr_nevaluate(t); i++)
	   {
	     emit_zero(get_seg(SEG_BSS));
	   }
       }

\.lcomm[ \t]{SYM}[ \t]*,[ \t]*{EXPR}\r?\n {
	 int32_t i;
         char *s = xstrdup(yytext+7);
	 char *t = s;
	 
	 t = strpbrk(s, ",");
	 *t++ = '\0';
	 
	 s = localize_string(s);
	 check_sym_dup(s);
	 push_sym(s, SEG_BSS, get_seg(SEG_BSS)->pos);
	 trace_listing(get_seg(SEG_BSS), get_seg(SEG_BSS)->pos, s);
	 trace_listing(get_seg(SEG_BSS), get_seg(SEG_BSS)->pos, ":\t");

	 for (i=0; i < expr_nevaluate(t); i++)
	   {
	     emit_zero(get_seg(SEG_BSS));
	   }
       }

\.org[ \t]{EXPR}\r?\n {
         struct seg *seg = get_current_seg();
         char *s = xstrdup(yytext+6);
         int32_t o = expr_nevaluate(s);

	 check_org_advances(seg, o);

	 while (seg->pos < o)
	   {
	     if (get_current_segnum() == SEG_TEXT)
	       {
		 emit_nop(seg);
	       }
	     else
	       {
		 emit_zero(seg);
	       }
	   }
       }

\.skip[ \t]{EXPR}\r?\n {
         struct seg *seg = get_current_seg();
         char *s = xstrdup(yytext+6);
         int32_t i;

	 for (i = 0; i < expr_nevaluate(s); i++)
	   {
	     if (get_current_segnum() == SEG_TEXT)
	       {
		 emit_nop(seg);
	       }
	     else
	       {
		 emit_zero(seg);
	       }
	   }
       }

{SYM}: {
         char *s;
	 struct seg *seg = get_current_seg();
	 s = xstrdup(yytext);
	 s[yyleng-1] = '\0';
	 s = localize_string(s);
	 check_sym_dup(s);
	 push_sym(s, get_current_segnum(), seg->pos);
	 trace_listing(seg, seg->pos, s);
	 trace_listing(seg, seg->pos, ":\t");
       }  

data     MATCH_OP(DATA);
add      MATCH_OP(ADD);
addc     MATCH_OP(ADDC);
sub      MATCH_OP(SUB);
subc     MATCH_OP(SUBC);
and      MATCH_OP(AND);
or       MATCH_OP(OR);
xor      MATCH_OP(XOR);
mul      MATCH_OP(MUL);
div      MATCH_OP(DIV);
udiv     MATCH_OP(UDIV);
ldil     MATCH_OP(LDIL);
ldih     MATCH_OP(LDIH);
ldib     MATCH_OP(LDIB);
mov      MATCH_OP(MOV);
not      MATCH_OP(NOT);
neg      MATCH_OP(NEG);
cmp      MATCH_OP(CMP);
addi     MATCH_OP(ADDI);
cmpi     MATCH_OP(CMPI);
shl      MATCH_OP(SHL);
shr      MATCH_OP(SHR);
sar      MATCH_OP(SAR);
mod      MATCH_OP(MOD);
umod     MATCH_OP(UMOD);
rolc     MATCH_OP(ROLC);
rorc     MATCH_OP(RORC);
bset     MATCH_OP(BSET);
bclr     MATCH_OP(BCLR);
btest    MATCH_OP(BTEST);
load     MATCH_OP(LOAD);
store    MATCH_OP(STORE);
loadl    MATCH_OP(LOADL);
loadh    MATCH_OP(LOADH);
loadb    MATCH_OP(LOADB);
storel   MATCH_OP(STOREL);
storeh   MATCH_OP(STOREH);
call     MATCH_OP(CALL);

br       MATCH_OP(BR);
brz      MATCH_OP(BRZ);
brnz     MATCH_OP(BRNZ);
brle     MATCH_OP(BRLE);
brlt     MATCH_OP(BRLT);
brge     MATCH_OP(BRGE);
brgt     MATCH_OP(BRGT);
brule    MATCH_OP(BRULE);
brult    MATCH_OP(BRULT);
bruge    MATCH_OP(BRUGE);
brugt    MATCH_OP(BRUGT);
sext     MATCH_OP(SEXT);
ldvec    MATCH_OP(LDVEC);
stvec    MATCH_OP(STVEC);

jmp      MATCH_OP(JMP);
jmpz     MATCH_OP(JMPZ);
jmpnz    MATCH_OP(JMPNZ);
jmple    MATCH_OP(JMPLE);
jmplt    MATCH_OP(JMPLT);
jmpge    MATCH_OP(JMPGE);
jmpgt    MATCH_OP(JMPGT);
jmpule   MATCH_OP(JMPULE);
jmpult   MATCH_OP(JMPULT);
jmpuge   MATCH_OP(JMPUGE);
jmpugt   MATCH_OP(JMPUGT);
intr     MATCH_OP(INTR);
getira   MATCH_OP(GETIRA);
setira   MATCH_OP(SETIRA);
getfl    MATCH_OP(GETFL);
setfl    MATCH_OP(SETFL);
getshfl  MATCH_OP(GETSHFL);
setshfl  MATCH_OP(SETSHFL);

reti     MATCH_OP(RETI);
nop      MATCH_OP(NOP);
sei      MATCH_OP(SEI);
cli      MATCH_OP(CLI);
error    MATCH_OP(ERROR);

{REG} {
	struct seg *seg = get_current_seg();
        int arg_index = get_arg_count(seg, seg->pos) - (args_to_match+1)/2;

	if (check_arg_count() || check_arg_type(seg, seg->pos, arg_index, 'r'))
	  YY_BREAK;

	set_regnum(seg, seg->pos, arg_index, strtol(yytext+1, NULL, 10));
	set_mode(seg, seg->pos, arg_index, 'r');
	trace_listing(seg, seg->pos, yytext);
	args_to_match--;
      }

{EXPR} {
	struct seg *seg = get_current_seg();
        int arg_index;

	if (!seen_op)
	  {
	    REJECT;
	  }

        arg_index = get_arg_count(seg, seg->pos) - (args_to_match+1)/2;	

	if (check_arg_count() || check_arg_type(seg, seg->pos, arg_index, 'n'))
	  YY_BREAK;

	set_expr(seg, seg->pos, arg_index, expr_localize(yytext));
	set_mode(seg, seg->pos, arg_index, 'n');
	trace_listing(seg, seg->pos, yytext);
	args_to_match--;
       }

,	   {
             check_colon_ok();
             trace_listing(get_current_seg(), get_current_seg()->pos, ", ");
	     args_to_match--;
           }

;.*        { /* ignore comments */ }

[ \t\r]+   { /* ignore whitespace */ }

\n+ {
      check_premature();
      expand_mod();
      if (seen_op)
	{
	  get_current_seg()->pos++;
	  seen_op = 0;
	  args_to_match = -1;
	}
      line_count += yyleng;
    }

<<EOF>> {
      check_premature();
      expand_mod();
      if (seen_op)
	{
	  get_current_seg()->pos++;
	  seen_op = 0;
	  args_to_match = -1;
	}
      yyterminate();
    }

. {
    fprintf(stderr, "invalid input `%c' in line %lu\n", yytext[0], line_count);
    error_count++;
  }

%%

int initialize(void)
{
  init_symtab();

  init_seg(SEG_DATA, SEG_INITSIZE/2);
  init_seg(SEG_BSS, SEG_INITSIZE/2);
  init_seg(SEG_TEXT, SEG_INITSIZE);

  set_current_segnum(SEG_TEXT);

  return 0;
}

int merge(void)
{
  uint32_t pos;
  int retval = 0;

  init_seg(SEG_PILE, SEG_INITSIZE);

  /* align .data to word boundary */
  if ((get_seg(SEG_DATA)->pos % 2) != 0)
    {
      emit_zero(get_seg(SEG_DATA));
    }

  /* align .bss to word boundary */
  if ((get_seg(SEG_BSS)->pos % 2) != 0)
    {
      emit_zero(get_seg(SEG_BSS));
    }

  /* check .data */
  for (pos = 0; pos < get_seg(SEG_DATA)->pos; pos += 2)
    {
      if ((get_op(get_seg(SEG_DATA), pos) != DATA)
	  || (get_op(get_seg(SEG_DATA), pos+1) != DATA))
	{
	  fprintf(stderr, "cannot initialize anything but `data' in .data\n");
	  error_count++;
	  retval = 1;
	}
    }

  /* check .bss */
  for (pos = 0; pos < get_seg(SEG_BSS)->pos; pos++)
    {
      if ((get_op(get_seg(SEG_BSS), pos) != DATA)
	  || (expr_symcount(get_expr(get_seg(SEG_BSS), pos, 0)) > 0)
	  || (expr_evaluate(get_expr(get_seg(SEG_BSS), pos, 0)) != 0))
	{
	  fprintf(stderr, "cannot put anything but `data 0' in .bss\n");
	  error_count++;
	  retval = 1;
	}
    }

  /* copy data from ROM */
  if (get_seg(SEG_DATA)->pos != 0)
    {
      emit_ldil(get_seg(SEG_PILE), 0,
		xsprintf("lo(%d)", get_seg(SEG_DATA)->pos));
      emit_ldih(get_seg(SEG_PILE), 0,
		xsprintf("hi(%d)", get_seg(SEG_DATA)->pos));

      emit_ldil(get_seg(SEG_PILE), 1,
		xsprintf("lo(%d)", datasize));
      emit_ldih(get_seg(SEG_PILE), 1,
		xsprintf("hi(%d)", datasize));

      emit_ldib(get_seg(SEG_PILE), 2, "0");
      push_sym("__init_data_loop__", SEG_PILE, get_seg(SEG_PILE)->pos);
      trace_listing(get_seg(SEG_PILE), get_seg(SEG_PILE)->pos,
                    "__init_data_loop__:\t");
      emit_load(get_seg(SEG_PILE), 3, 1);
      emit_store(get_seg(SEG_PILE), 3, 2);
      emit_addi(get_seg(SEG_PILE), 1, "2");
      emit_addi(get_seg(SEG_PILE), 2, "2");
      emit_cmp(get_seg(SEG_PILE), 0, 2);
      emit_brnz(get_seg(SEG_PILE), "__init_data_loop__");
    }

  /* clear .bss */
  if (get_seg(SEG_BSS)->pos != 0)
    {
      emit_ldil(get_seg(SEG_PILE), 0,
		xsprintf("lo(%d+%d)", get_seg(SEG_DATA)->pos,
                                      get_seg(SEG_BSS)->pos));
      emit_ldih(get_seg(SEG_PILE), 0,
		xsprintf("hi(%d+%d)", get_seg(SEG_DATA)->pos,
                                      get_seg(SEG_BSS)->pos));
      emit_ldib(get_seg(SEG_PILE), 3, "0");
      push_sym("__init_bss_loop__", SEG_PILE, get_seg(SEG_PILE)->pos);
      trace_listing(get_seg(SEG_PILE), get_seg(SEG_PILE)->pos,
                    "__init_bss_loop__:\t");
      emit_store(get_seg(SEG_PILE), 3, 2);
      emit_addi(get_seg(SEG_PILE), 2, "2");
      emit_cmp(get_seg(SEG_PILE), 0, 2);
      emit_brnz(get_seg(SEG_PILE), "__init_bss_loop__");      
    }

  reloc_syms(SEG_BSS, get_seg(SEG_DATA)->pos);
  reloc_syms(SEG_TEXT, get_seg(SEG_PILE)->pos);

  for(pos = 0; pos < get_seg(SEG_TEXT)->pos; pos++)
    {
      emit_op(get_seg(SEG_PILE), get_seg(SEG_TEXT)->code[pos]);
    }

  set_current_segnum(SEG_PILE);

  return retval;
}

int postprocess(void)
{
  struct seg *seg;
  uint32_t pos;
  int retval = 0;

  if ((output_mode != MODE_DRYRUN)
      && (check_code_size()
	  || check_data_size()))
    {
      retval = 1;
    }

  seg = get_seg(SEG_PILE);
  for (pos = 0; pos < seg->pos; pos++)
    {
      if (check_mnemonic(seg, pos))
	{
	  retval = 1;
	}
      if ((output_mode != MODE_DRYRUN)
	  && (fix_operands(seg, pos)
	      || check_ranges(seg, pos)
	      || fix_code(seg, pos)))
	{
	  retval = 1;
	}
    }

  seg = get_seg(SEG_DATA);
  for (pos = 0; pos < seg->pos; pos++)
    {
      if (check_mnemonic(seg, pos))
	{
	  retval = 1;
	}
      if ((output_mode != MODE_DRYRUN)
	  && (fix_operands(seg, pos)
	      || check_ranges(seg, pos)
	      || fix_code(seg, pos)))
	{
	  retval = 1;
	}
    }

  return retval;
}

/***************** LIB *****************/

void *xmalloc(size_t size)
{
  void *retval = malloc(size);
  if (retval == NULL)
    {
      fprintf(stderr, "run out of memory\n");
      exit(EXIT_FAILURE);
    }
  return retval;  
}

void *xrealloc(void *ptr, size_t size)
{
  void *retval = realloc(ptr, size);
  if (retval == NULL)
    {
      fprintf(stderr, "run out of memory\n");
      exit(EXIT_FAILURE);
    }
  return retval;  
}

char *xstrdup(const char *str)
{
  size_t len = strlen(str);
  void *retval = xmalloc(len+1);
  memcpy(retval, str, len+1);
  return retval;  
}

char *xsprintf(const char *fmt, ...)
{
  va_list ap;
  char *retval;

  va_start(ap, fmt);
  vasprintf(&retval, fmt, ap);
  va_end(ap);

  if (retval == NULL)
    {
      fprintf(stderr, "run out of memory\n");
      exit(EXIT_FAILURE);
    }

  return retval;
}

/***************** MAIN *****************/

int yywrap()
{
  return 1;
}

int main(int argc, char **argv)
{
  int opt;

  int opterr = 0;

  int hopt = 0;
  int vopt = 0;

  command = argv[0];

  while (optind < argc)
    {
      if (strcmp(argv[optind], "-") == 0 || (argv[optind][0] != '-'))
	{
	  opt = -1;
	}
      else
	{
	  opt = getopt_long(argc, argv, options, long_options, 0);
	}

      switch(opt)
	{
	case 'h': hopt++; break;
	case 'v': vopt++; break;
	case 'o': case '0': case '1':
	case 'c': case 'd': case 'r':
	case 'f': case 'i': case 'n': case 'l':
	case 'm': case 's': case 'e':
          break;
	case '?': opterr = 1; break;
	case -1: optind++; break;
	}
    }

  if (opterr)
    {
      printf("Usage:\n"
             "    %s [--intel|--nointel|--download|--dryrun]\n"
             "    [--codesize=*n*] [--datasize=*n*] [--romsize=*n*]\n"
             "    [--filler=*n*] [--output=file] [--rom0file=file] [--rom1file=file]\n"
	     "    [--nostart] [--noend] file ...\n", command);
      return EXIT_FAILURE;
    }

  if (vopt)
    {
      printf("spar 0.2\n");
      return EXIT_SUCCESS;
    }

  if (hopt)
    {
      printf("Usage:\n"
             "    %s [--intel|--nointel|--download|--dryrun]\n"
             "    [--codesize=*n*] [--datasize=*n*] [--romsize=*n*]\n"
             "    [--filler=*n*] [--output=file] [--rom0file=file] [--rom1file=file]\n"
	     "    [--nostart] [--noend] file ...\n", command);
      return EXIT_SUCCESS;
    }

  optind = 1;

  initialize();

  while (optind < argc)
    {
      if (strcmp(argv[optind], "-") == 0 || (argv[optind][0] != '-'))
	{
	  opt = -1;
	}
      else
	{
	  opt = getopt_long(argc, argv, options, long_options, 0);
	}

      switch (opt)
	{
	case 'h': case 'v':
	  break;
        case 'o':
	  if (strcmp(optarg, "-") == 0)
	    {
	      output_file = stdout;
	    }
	  else
	    {
	      output_file = fopen(optarg, "w");
	      if (output_file == NULL)
		{
		  fprintf(stderr, "cannot open file %s\n", optarg);
		  return EXIT_FAILURE;		  
		}
	    }
	  break;
        case '0':
	  if (strcmp(optarg, "-") == 0)
	    {
	      rom0_file = stdout;
	    }
	  else
	    {
	      rom0_file = fopen(optarg, "w");
	      if (rom0_file == NULL)
		{
		  fprintf(stderr, "cannot open file %s\n", optarg);
		  return EXIT_FAILURE;		  
		}
	    }
	  break;
        case '1':
	  if (strcmp(optarg, "-") == 0)
	    {
	      rom1_file = stdout;
	    }
	  else
	    {
	      rom1_file = fopen(optarg, "w");
	      if (rom1_file == NULL)
		{
		  fprintf(stderr, "cannot open file %s\n", optarg);
		  return EXIT_FAILURE;		  
		}
	    }
	  break;
	case 'c':
	  {
	    char * errptr = NULL;
	    romsize = strtol(optarg, &errptr, 0);
	    if (*errptr != '\0')
	      {
		fprintf(stderr, "invalid codesize %s\n", optarg);
		return EXIT_FAILURE;		  
	      }
	  }
	  break;
	case 'd':
	  {
	    char * errptr = NULL;
	    romsize = strtol(optarg, &errptr, 0);
	    if (*errptr != '\0')
	      {
		fprintf(stderr, "invalid datasize %s\n", optarg);
		return EXIT_FAILURE;		  
	      }
	  }
	  break;
	case 'r':
	  {
	    char * errptr = NULL;
	    romsize = strtol(optarg, &errptr, 0);
	    if (*errptr != '\0')
	      {
		fprintf(stderr, "invalid romsize %s\n", optarg);
		return EXIT_FAILURE;		  
	      }
	  }
	  break;
	case 'f':
	  {
	    char * errptr = NULL;
	    filler = strtol(optarg, &errptr, 0);
	    if (*errptr != '\0')
	      {
		fprintf(stderr, "invalid filler %s\n", optarg);
		return EXIT_FAILURE;		  
	      }
	  }
	  break;
	case 'i': output_mode = MODE_INTEL; break;
	case 'n': output_mode = MODE_DRYRUN; break;
	case 'l': output_mode = MODE_DOWNLOAD; break;
	case 'm': output_mode = MODE_MIF; break;
	case 's': nostart = 1; break;
	case 'e': noend = 1; break;
	case '?': break;
	case -1:
	  if (argv[optind] == NULL)
	    break;
	  if (strcmp(argv[optind], "-") == 0)
	    {
	      yyin = stdin;
	    }
	  else
	    {
	      yyin = fopen(argv[optind], "r");
	      if (yyin == NULL)
		{
		  fprintf(stderr, "cannot open file %s\n", argv[optind]);
		  return EXIT_FAILURE;		  
		}
	    }
	  yylex();
	  file_count++;

	  optind++;
	  break;
	}
    }

  if (output_file == NULL)
    {
      output_file = stdout;
    }
  if (rom0_file == NULL)
    {
      rom0_file = stdout;
    }
  if (rom1_file == NULL)
    {
      rom1_file = stdout;
    }

  if (file_count == 0)
    {
      yyin = stdin;
      yylex();
    }

  merge();

  postprocess();

  if (error_count != 0)
    {
      fprintf(stderr, "found %lu error(s)\n", error_count);
      return EXIT_FAILURE;
    }

  if (output_file == NULL)
    {
      output_file = stdout;
    }
  if (rom0_file == NULL)
    {
      rom0_file = stdout;
    }
  if (rom1_file == NULL)
    {
      rom1_file = stdout;
    }

  switch (output_mode)
    {
    case MODE_DRYRUN: break;
    case MODE_DOWNLOAD: print_download(output_file, rom0_file, rom1_file); break;
    case MODE_INTEL: print_intel(output_file, rom0_file, rom1_file); break;
    case MODE_MIF: print_mif(output_file, rom0_file, rom1_file); break;
    }

  if (output_file != stdout)
    {
      fclose(output_file);
    }
  if (rom0_file != stdout)
    {
      fclose(rom0_file);
    }
  if (rom1_file != stdout)
    {
      fclose(rom1_file);
    }

  return EXIT_SUCCESS;
}

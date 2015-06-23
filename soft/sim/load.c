#include "sim.h"
#include "bfd.h"
#include "dis-asm.h"

static char *default_target = "elf32-littlearm";	/* Default at runtime.  */
/* Architecture to disassemble for, or default if NULL.  */
static char *machine = "arm";

/* Endianness to disassemble for, or default if BFD_ENDIAN_UNKNOWN.  */
static enum bfd_endian endian = BFD_ENDIAN_UNKNOWN;

static bfd_boolean disassemble_all;	/* -D */

/* Target specific options to the disassembler.  */
static char *disassembler_options = (char *) NULL;

void parse_args PARAMS ((int, char **));
static int dump_reloc_info;		/* -r */

int exit_status = 0;

static char *only = 0;			/* -j secname */

#ifndef SKIP_ZEROES
#define SKIP_ZEROES (8)
#endif

#ifndef SKIP_ZEROES_AT_END
#define SKIP_ZEROES_AT_END (3)
#endif

static bfd_vma adjust_section_vma = 0;	/* --adjust-vma */

static int with_line_numbers;		/* -l */
static bfd_boolean with_source_code;	/* -S */
static int show_raw_insn;		/* --show-raw-insn */



/* Pseudo FILE object for strings.  */
typedef struct
{
  char *buffer;
  size_t size;
  char *current;
} SFILE;


static int
objdump_sprintf VPARAMS ((SFILE *f, const char *format, ...))
{
  char *buf;
  size_t n;

  VA_OPEN (args, format);
  VA_FIXEDARG (args, SFILE *, f);
  VA_FIXEDARG (args, const char *, format);

  vasprintf (&buf, format, args);

  if (buf == NULL)
    {
      va_end (args);
      fatal ("Out of virtual memory");
    }

  n = strlen (buf);

  while ((size_t) ((f->buffer + f->size) - f->current) < n + 1)
    {
      size_t curroff;

      curroff = f->current - f->buffer;
      f->size *= 2;
      f->buffer = xrealloc (f->buffer, f->size);
      f->current = f->buffer + curroff;
    }

  memcpy (f->current, buf, n);
  f->current += n;
  f->current[0] = '\0';

  free (buf);

  VA_CLOSE (args);
  return n;
}


/* Should perhaps share code and display with nm?  */
static int disassemble_zeroes;		/* --disassemble-zeroes */

/* The dynamic symbol table.  */
static asymbol **dynsyms;

/* Number of symbols in `dynsyms'.  */
static long dynsymcount = 0;

/* The symbol table.  */
static asymbol **syms;

/* Number of symbols in `syms'.  */
static long symcount = 0;

/* The sorted symbol table.  */
static asymbol **sorted_syms;

/* Number of symbols in `sorted_syms'.  */
static long sorted_symcount = 0;


/* Extra info to pass to the disassembler address printing function.  */
struct objdump_disasm_info
{
  bfd *abfd;
  asection *sec;
  bfd_boolean require_sec;
};

/* Hold the last function name and the last line number we displayed
   in a disassembly.  */

static char *prev_functionname;
static unsigned int prev_line;

/* We keep a list of all files that we have seen when doing a
   dissassembly with source, so that we know how much of the file to
   display.  This can be important for inlined functions.  */

struct print_file_list
{
  struct print_file_list *next;
  char *filename;
  unsigned int line;
  FILE *f;
};



int
main (argc, argv)
     int argc;
     char **argv;
{
  char *target = default_target;
  bfd_boolean seenflag = FALSE;

  //parse_args(argc,argv);
  bfd_init ();
  //set_default_bfd_target ();


  read_exe (argv[1], target);
 

  return exit_status;
}

static bfd_vma start_address = (bfd_vma) -1; /* --start-address */
static bfd_vma stop_address = (bfd_vma) -1;  /* --stop-address */

static int wide_output;			/* -w */

static int prefix_addresses;		/* --prefix-addresses */




/* Print the name of a symbol.  */

static void
objdump_print_symname (abfd, info, sym)
     bfd *abfd;
     struct disassemble_info *info;
     asymbol *sym;
{
  char *alloc;
  const char *name;

  alloc = NULL;
  name = bfd_asymbol_name (sym);
  //if (do_demangle && name[0] != '\0')
  //  {
      /* Demangle the name.  */
  //    alloc = demangle (abfd, name);
  //    name = alloc;
  //  }

  if (info != NULL)
    (*info->fprintf_func) (info->stream, "%s", name);
  else
    printf ("%s", name);

  if (alloc != NULL)
    free (alloc);
}

/* Locate a symbol given a bfd, a section, and a VMA.  If REQUIRE_SEC
   is TRUE, then always require the symbol to be in the section.  This
   returns NULL if there is no suitable symbol.  If PLACE is not NULL,
   then *PLACE is set to the index of the symbol in sorted_syms.  */

static asymbol *
find_symbol_for_address (abfd, sec, vma, require_sec, place)
     bfd *abfd;
     asection *sec;
     bfd_vma vma;
     bfd_boolean require_sec;
     long *place;
{
  /* @@ Would it speed things up to cache the last two symbols returned,
     and maybe their address ranges?  For many processors, only one memory
     operand can be present at a time, so the 2-entry cache wouldn't be
     constantly churned by code doing heavy memory accesses.  */

  /* Indices in `sorted_syms'.  */
  long min = 0;
  long max = sorted_symcount;
  long thisplace;
  unsigned int opb = bfd_octets_per_byte (abfd);

  if (sorted_symcount < 1)
    return NULL;

  /* Perform a binary search looking for the closest symbol to the
     required value.  We are searching the range (min, max].  */
  while (min + 1 < max)
    {
      asymbol *sym;

      thisplace = (max + min) / 2;
      sym = sorted_syms[thisplace];

      if (bfd_asymbol_value (sym) > vma)
	max = thisplace;
      else if (bfd_asymbol_value (sym) < vma)
	min = thisplace;
      else
	{
	  min = thisplace;
	  break;
	}
    }

  /* The symbol we want is now in min, the low end of the range we
     were searching.  If there are several symbols with the same
     value, we want the first one.  */
  thisplace = min;
  while (thisplace > 0
	 && (bfd_asymbol_value (sorted_syms[thisplace])
	     == bfd_asymbol_value (sorted_syms[thisplace - 1])))
    --thisplace;

  /* If the file is relocateable, and the symbol could be from this
     section, prefer a symbol from this section over symbols from
     others, even if the other symbol's value might be closer.

     Note that this may be wrong for some symbol references if the
     sections have overlapping memory ranges, but in that case there's
     no way to tell what's desired without looking at the relocation
     table.  */
  if (sorted_syms[thisplace]->section != sec
      && (require_sec
	  || ((abfd->flags & HAS_RELOC) != 0
	      && vma >= bfd_get_section_vma (abfd, sec)
	      && vma < (bfd_get_section_vma (abfd, sec)
			+ bfd_section_size (abfd, sec) / opb))))
    {
      long i;

      for (i = thisplace + 1; i < sorted_symcount; i++)
	{
	  if (bfd_asymbol_value (sorted_syms[i])
	      != bfd_asymbol_value (sorted_syms[thisplace]))
	    break;
	}

      --i;

      for (; i >= 0; i--)
	{
	  if (sorted_syms[i]->section == sec
	      && (i == 0
		  || sorted_syms[i - 1]->section != sec
		  || (bfd_asymbol_value (sorted_syms[i])
		      != bfd_asymbol_value (sorted_syms[i - 1]))))
	    {
	      thisplace = i;
	      break;
	    }
	}

      if (sorted_syms[thisplace]->section != sec)
	{
	  /* We didn't find a good symbol with a smaller value.
	     Look for one with a larger value.  */
	  for (i = thisplace + 1; i < sorted_symcount; i++)
	    {
	      if (sorted_syms[i]->section == sec)
		{
		  thisplace = i;
		  break;
		}
	    }
	}

      if (sorted_syms[thisplace]->section != sec
	  && (require_sec
	      || ((abfd->flags & HAS_RELOC) != 0
		  && vma >= bfd_get_section_vma (abfd, sec)
		  && vma < (bfd_get_section_vma (abfd, sec)
			    + bfd_section_size (abfd, sec)))))
	{
	  /* There is no suitable symbol.  */
	  return NULL;
	}
    }

  if (place != NULL)
    *place = thisplace;

  return sorted_syms[thisplace];
}

/* Sort relocs into address order.  */

static int
compare_relocs (ap, bp)
     const PTR ap;
     const PTR bp;
{
  const arelent *a = *(const arelent **)ap;
  const arelent *b = *(const arelent **)bp;

  if (a->address > b->address)
    return 1;
  else if (a->address < b->address)
    return -1;

  /* So that associated relocations tied to the same address show up
     in the correct order, we don't do any further sorting.  */
  if (a > b)
    return 1;
  else if (a < b)
    return -1;
  else
    return 0;
}


/* Sort symbols into value order.  */

static int
compare_symbols (ap, bp)
     const PTR ap;
     const PTR bp;
{
  const asymbol *a = *(const asymbol **)ap;
  const asymbol *b = *(const asymbol **)bp;
  const char *an, *bn;
  size_t anl, bnl;
  bfd_boolean af, bf;
  flagword aflags, bflags;

  if (bfd_asymbol_value (a) > bfd_asymbol_value (b))
    return 1;
  else if (bfd_asymbol_value (a) < bfd_asymbol_value (b))
    return -1;

  if (a->section > b->section)
    return 1;
  else if (a->section < b->section)
    return -1;

  an = bfd_asymbol_name (a);
  bn = bfd_asymbol_name (b);
  anl = strlen (an);
  bnl = strlen (bn);

  /* The symbols gnu_compiled and gcc2_compiled convey no real
     information, so put them after other symbols with the same value.  */
  af = (strstr (an, "gnu_compiled") != NULL
	|| strstr (an, "gcc2_compiled") != NULL);
  bf = (strstr (bn, "gnu_compiled") != NULL
	|| strstr (bn, "gcc2_compiled") != NULL);

  if (af && ! bf)
    return 1;
  if (! af && bf)
    return -1;

  /* We use a heuristic for the file name, to try to sort it after
     more useful symbols.  It may not work on non Unix systems, but it
     doesn't really matter; the only difference is precisely which
     symbol names get printed.  */

#define file_symbol(s, sn, snl)			\
  (((s)->flags & BSF_FILE) != 0			\
   || ((sn)[(snl) - 2] == '.'			\
       && ((sn)[(snl) - 1] == 'o'		\
	   || (sn)[(snl) - 1] == 'a')))

  af = file_symbol (a, an, anl);
  bf = file_symbol (b, bn, bnl);

  if (af && ! bf)
    return 1;
  if (! af && bf)
    return -1;

  /* Try to sort global symbols before local symbols before function
     symbols before debugging symbols.  */

  aflags = a->flags;
  bflags = b->flags;

  if ((aflags & BSF_DEBUGGING) != (bflags & BSF_DEBUGGING))
    {
      if ((aflags & BSF_DEBUGGING) != 0)
	return 1;
      else
	return -1;
    }
  if ((aflags & BSF_FUNCTION) != (bflags & BSF_FUNCTION))
    {
      if ((aflags & BSF_FUNCTION) != 0)
	return -1;
      else
	return 1;
    }
  if ((aflags & BSF_LOCAL) != (bflags & BSF_LOCAL))
    {
      if ((aflags & BSF_LOCAL) != 0)
	return 1;
      else
	return -1;
    }
  if ((aflags & BSF_GLOBAL) != (bflags & BSF_GLOBAL))
    {
      if ((aflags & BSF_GLOBAL) != 0)
	return -1;
      else
	return 1;
    }

  /* Symbols that start with '.' might be section names, so sort them
     after symbols that don't start with '.'.  */
  if (an[0] == '.' && bn[0] != '.')
    return 1;
  if (an[0] != '.' && bn[0] == '.')
    return -1;

  /* Finally, if we can't distinguish them in any other way, try to
     get consistent results by sorting the symbols by name.  */
  return strcmp (an, bn);
}

/* Print VMA to STREAM.  If SKIP_ZEROES is TRUE, omit leading zeroes.  */

static void
objdump_print_value (vma, info, skip_zeroes)
     bfd_vma vma;
     struct disassemble_info *info;
     bfd_boolean skip_zeroes;
{
  char buf[30];
  char *p;
  struct objdump_disasm_info *aux
    = (struct objdump_disasm_info *) info->application_data;

  bfd_sprintf_vma (aux->abfd, buf, vma);
  if (! skip_zeroes)
    p = buf;
  else
    {
      for (p = buf; *p == '0'; ++p)
	;
      if (*p == '\0')
	--p;
    }
  (*info->fprintf_func) (info->stream, "%s", p);
}


/* Print an address to INFO symbolically.  */

static void
objdump_print_addr_with_sym (abfd, sec, sym, vma, info, skip_zeroes)
     bfd *abfd;
     asection *sec;
     asymbol *sym;
     bfd_vma vma;
     struct disassemble_info *info;
     bfd_boolean skip_zeroes;
{
  objdump_print_value (vma, info, skip_zeroes);

  if (sym == NULL)
    {
      bfd_vma secaddr;

      (*info->fprintf_func) (info->stream, " <%s",
			     bfd_get_section_name (abfd, sec));
      secaddr = bfd_get_section_vma (abfd, sec);
      if (vma < secaddr)
	{
	  (*info->fprintf_func) (info->stream, "-0x");
	  objdump_print_value (secaddr - vma, info, TRUE);
	}
      else if (vma > secaddr)
	{
	  (*info->fprintf_func) (info->stream, "+0x");
	  objdump_print_value (vma - secaddr, info, TRUE);
	}
      (*info->fprintf_func) (info->stream, ">");
    }
  else
    {
      (*info->fprintf_func) (info->stream, " <");
      objdump_print_symname (abfd, info, sym);
      if (bfd_asymbol_value (sym) > vma)
	{
	  (*info->fprintf_func) (info->stream, "-0x");
	  objdump_print_value (bfd_asymbol_value (sym) - vma, info, TRUE);
	}
      else if (vma > bfd_asymbol_value (sym))
	{
	  (*info->fprintf_func) (info->stream, "+0x");
	  objdump_print_value (vma - bfd_asymbol_value (sym), info, TRUE);
	}
      (*info->fprintf_func) (info->stream, ">");
    }
}

/* Print VMA to INFO, symbolically if possible.  If SKIP_ZEROES is
   TRUE, don't output leading zeroes.  */

static void
objdump_print_addr (vma, info, skip_zeroes)
     bfd_vma vma;
     struct disassemble_info *info;
     bfd_boolean skip_zeroes;
{
  struct objdump_disasm_info *aux;
  asymbol *sym;

  if (sorted_symcount < 1)
    {
      (*info->fprintf_func) (info->stream, "0x");
      objdump_print_value (vma, info, skip_zeroes);
      return;
    }

  aux = (struct objdump_disasm_info *) info->application_data;
  sym = find_symbol_for_address (aux->abfd, aux->sec, vma, aux->require_sec,
				 (long *) NULL);
  objdump_print_addr_with_sym (aux->abfd, aux->sec, sym, vma, info,
			       skip_zeroes);
}

/* Print VMA to INFO.  This function is passed to the disassembler
   routine.  */

static void
objdump_print_address (vma, info)
     bfd_vma vma;
     struct disassemble_info *info;
{
  objdump_print_addr (vma, info, ! prefix_addresses);
}

/* Determine of the given address has a symbol associated with it.  */

static int
objdump_symbol_at_address (vma, info)
     bfd_vma vma;
     struct disassemble_info * info;
{
  struct objdump_disasm_info * aux;
  asymbol * sym;

  /* No symbols - do not bother checking.  */
  if (sorted_symcount < 1)
    return 0;

  aux = (struct objdump_disasm_info *) info->application_data;
  sym = find_symbol_for_address (aux->abfd, aux->sec, vma, aux->require_sec,
				 (long *) NULL);

  return (sym != NULL && (bfd_asymbol_value (sym) == vma));
}

static struct print_file_list *print_files;


/* Filter out (in place) symbols that are useless for disassembly.
   COUNT is the number of elements in SYMBOLS.
   Return the number of useful symbols.  */

static long
remove_useless_symbols (symbols, count)
     asymbol **symbols;
     long count;
{
  register asymbol **in_ptr = symbols, **out_ptr = symbols;

  while (--count >= 0)
    {
      asymbol *sym = *in_ptr++;

      if (sym->name == NULL || sym->name[0] == '\0')
	continue;
      if (sym->flags & (BSF_DEBUGGING))
	continue;
      if (bfd_is_und_section (sym->section)
	  || bfd_is_com_section (sym->section))
	continue;

      *out_ptr++ = sym;
    }
  return out_ptr - symbols;
}

static void
skip_to_line (p, line, show)
     struct print_file_list *p;
     unsigned int line;
     bfd_boolean show;
{
  while (p->line < line)
    {
      char buf[100];

      if (fgets (buf, sizeof buf, p->f) == NULL)
	{
	  fclose (p->f);
	  p->f = NULL;
	  break;
	}

      if (show)
	printf ("%s", buf);

      if (strchr (buf, '\n') != NULL)
	++p->line;
    }
}


static int file_start_context = 0;      /* --file-start-context */


#define SHOW_PRECEDING_CONTEXT_LINES (5)



/* Show the line number, or the source line, in a dissassembly
   listing.  */

static void
show_line (abfd, section, addr_offset)
     bfd *abfd;
     asection *section;
     bfd_vma addr_offset;
{
  const char *filename;
  const char *functionname;
  unsigned int line;

  if (! with_line_numbers && ! with_source_code)
    return;

  if (! bfd_find_nearest_line (abfd, section, syms, addr_offset, &filename,
			       &functionname, &line))
    return;

  if (filename != NULL && *filename == '\0')
    filename = NULL;
  if (functionname != NULL && *functionname == '\0')
    functionname = NULL;

  if (with_line_numbers)
    {
      if (functionname != NULL
	  && (prev_functionname == NULL
	      || strcmp (functionname, prev_functionname) != 0))
	printf ("%s():\n", functionname);
      if (line > 0 && line != prev_line)
	printf ("%s:%u\n", filename == NULL ? "???" : filename, line);
    }

  if (with_source_code
      && filename != NULL
      && line > 0)
    {
      struct print_file_list **pp, *p;

      for (pp = &print_files; *pp != NULL; pp = &(*pp)->next)
	if (strcmp ((*pp)->filename, filename) == 0)
	  break;
      p = *pp;

      if (p != NULL)
	{
	  if (p != print_files)
	    {
	      int l;

	      /* We have reencountered a file name which we saw
		 earlier.  This implies that either we are dumping out
		 code from an included file, or the same file was
		 linked in more than once.  There are two common cases
		 of an included file: inline functions in a header
		 file, and a bison or flex skeleton file.  In the
		 former case we want to just start printing (but we
		 back up a few lines to give context); in the latter
		 case we want to continue from where we left off.  I
		 can't think of a good way to distinguish the cases,
		 so I used a heuristic based on the file name.  */
	      if (strcmp (p->filename + strlen (p->filename) - 2, ".h") != 0)
		l = p->line;
	      else
		{
		  l = line - SHOW_PRECEDING_CONTEXT_LINES;
		  if (l < 0)
		    l = 0;
		}

	      if (p->f == NULL)
		{
		  p->f = fopen (p->filename, "r");
		  p->line = 0;
		}
	      if (p->f != NULL)
		skip_to_line (p, l, FALSE);

	      if (print_files->f != NULL)
		{
		  fclose (print_files->f);
		  print_files->f = NULL;
		}
	    }

	  if (p->f != NULL)
	    {
	      skip_to_line (p, line, TRUE);
	      *pp = p->next;
	      p->next = print_files;
	      print_files = p;
	    }
	}
      else
	{
	  FILE *f;

	  f = fopen (filename, "r");
	  if (f != NULL)
	    {
	      int l;

	      p = ((struct print_file_list *)
		   xmalloc (sizeof (struct print_file_list)));
	      p->filename = xmalloc (strlen (filename) + 1);
	      strcpy (p->filename, filename);
	      p->line = 0;
	      p->f = f;

	      if (print_files != NULL && print_files->f != NULL)
		{
		  fclose (print_files->f);
		  print_files->f = NULL;
		}
	      p->next = print_files;
	      print_files = p;

	      if (file_start_context)
		l = 0;
	      else
		l = line - SHOW_PRECEDING_CONTEXT_LINES;
	      if (l < 0)
		l = 0;
	      skip_to_line (p, l, FALSE);
	      if (p->f != NULL)
		skip_to_line (p, line, TRUE);
	    }
	}
    }

  if (functionname != NULL
      && (prev_functionname == NULL
	  || strcmp (functionname, prev_functionname) != 0))
    {
      if (prev_functionname != NULL)
	free (prev_functionname);
      prev_functionname = xmalloc (strlen (functionname) + 1);
      strcpy (prev_functionname, functionname);
    }

  if (line > 0 && line != prev_line)
    prev_line = line;
}










/* Disassemble some data in memory between given values.  */

static void
disassemble_bytes (info, disassemble_fn, insns, data,
		   start_offset, stop_offset, relppp,
		   relppend)
     struct disassemble_info *info;
     disassembler_ftype disassemble_fn;
     bfd_boolean insns;
     bfd_byte *data;
     bfd_vma start_offset;
     bfd_vma stop_offset;
     arelent ***relppp;
     arelent **relppend;
{
  struct objdump_disasm_info *aux;
  asection *section;
  int octets_per_line;
  bfd_boolean done_dot;
  int skip_addr_chars;
  bfd_vma addr_offset;
  int opb = info->octets_per_byte;

  aux = (struct objdump_disasm_info *) info->application_data;
  section = aux->sec;

  if (insns)
    octets_per_line = 4;
  else
    octets_per_line = 16;

  /* Figure out how many characters to skip at the start of an
     address, to make the disassembly look nicer.  We discard leading
     zeroes in chunks of 4, ensuring that there is always a leading
     zero remaining.  */
  skip_addr_chars = 0;
  if (! prefix_addresses)
    {
      char buf[30];
      char *s;

      bfd_sprintf_vma
	(aux->abfd, buf,
	 (section->vma
	  + bfd_section_size (section->owner, section) / opb));
      s = buf;
      while (s[0] == '0' && s[1] == '0' && s[2] == '0' && s[3] == '0'
	     && s[4] == '0')
	{
	  skip_addr_chars += 4;
	  s += 4;
	}
    }

  info->insn_info_valid = 0;

  done_dot = FALSE;
  addr_offset = start_offset;
  while (addr_offset < stop_offset)
    {
      bfd_vma z;
      int octets = 0;
      bfd_boolean need_nl = FALSE;

      /* If we see more than SKIP_ZEROES octets of zeroes, we just
         print `...'.  */
      for (z = addr_offset * opb; z < stop_offset * opb; z++)
	if (data[z] != 0)
	  break;
      if (! disassemble_zeroes
	  && (info->insn_info_valid == 0
	      || info->branch_delay_insns == 0)
	  && (z - addr_offset * opb >= SKIP_ZEROES
	      || (z == stop_offset * opb &&
		  z - addr_offset * opb < SKIP_ZEROES_AT_END)))
	{
	  printf ("\t...\n");

	  /* If there are more nonzero octets to follow, we only skip
             zeroes in multiples of 4, to try to avoid running over
             the start of an instruction which happens to start with
             zero.  */
	  if (z != stop_offset * opb)
	    z = addr_offset * opb + ((z - addr_offset * opb) &~ 3);

	  octets = z - addr_offset * opb;
	}
      else
	{
	  char buf[50];
	  SFILE sfile;
	  int bpc = 0;
	  int pb = 0;

	  done_dot = FALSE;

	  if (with_line_numbers || with_source_code)
	    /* The line number tables will refer to unadjusted
	       section VMAs, so we must undo any VMA modifications
	       when calling show_line.  */
	    show_line (aux->abfd, section, addr_offset - adjust_section_vma);

	  if (! prefix_addresses)
	    {
	      char *s;

	      bfd_sprintf_vma (aux->abfd, buf, section->vma + addr_offset);
	      for (s = buf + skip_addr_chars; *s == '0'; s++)
		*s = ' ';
	      if (*s == '\0')
		*--s = '0';
	      printf ("%s:\t", buf + skip_addr_chars);
	    }
	  else
	    {
	      aux->require_sec = TRUE;
	      objdump_print_address (section->vma + addr_offset, info);
	      aux->require_sec = FALSE;
	      putchar (' ');
	    }

	  if (insns)
	    {
	      sfile.size = 120;
	      sfile.buffer = xmalloc (sfile.size);
	      sfile.current = sfile.buffer;
	      info->fprintf_func = (fprintf_ftype) objdump_sprintf;
	      info->stream = (FILE *) &sfile;
	      info->bytes_per_line = 0;
	      info->bytes_per_chunk = 0;

#ifdef DISASSEMBLER_NEEDS_RELOCS
	      /* FIXME: This is wrong.  It tests the number of octets
                 in the last instruction, not the current one.  */
	      if (*relppp < relppend
		  && (**relppp)->address >= addr_offset
		  && (**relppp)->address <= addr_offset + octets / opb)
		info->flags = INSN_HAS_RELOC;
	      else
#endif
		info->flags = 0;

	      octets = (*disassemble_fn) (section->vma + addr_offset, info);
	      info->fprintf_func = (fprintf_ftype) fprintf;
	      info->stream = stdout;
	      if (info->bytes_per_line != 0)
		octets_per_line = info->bytes_per_line;
	      if (octets < 0)
		{
		  if (sfile.current != sfile.buffer)
		    printf ("%s\n", sfile.buffer);
		  free (sfile.buffer);
		  break;
		}
	    }
	  else
	    {
	      bfd_vma j;

	      octets = octets_per_line;
	      if (addr_offset + octets / opb > stop_offset)
		octets = (stop_offset - addr_offset) * opb;

	      for (j = addr_offset * opb; j < addr_offset * opb + octets; ++j)
		{
		  if (isprint (data[j]))
		    buf[j - addr_offset * opb] = data[j];
		  else
		    buf[j - addr_offset * opb] = '.';
		}
	      buf[j - addr_offset * opb] = '\0';
	    }

	  if (prefix_addresses
	      ? show_raw_insn > 0
	      : show_raw_insn >= 0)
	    {
	      bfd_vma j;

	      /* If ! prefix_addresses and ! wide_output, we print
                 octets_per_line octets per line.  */
	      pb = octets;
	      if (pb > octets_per_line && ! prefix_addresses && ! wide_output)
		pb = octets_per_line;

	      if (info->bytes_per_chunk)
		bpc = info->bytes_per_chunk;
	      else
		bpc = 1;

	      for (j = addr_offset * opb; j < addr_offset * opb + pb; j += bpc)
		{
		  int k;
		  if (bpc > 1 && info->display_endian == BFD_ENDIAN_LITTLE)
		    {
		      for (k = bpc - 1; k >= 0; k--)
			printf ("%02x", (unsigned) data[j + k]);
		      putchar (' ');
		    }
		  else
		    {
		      for (k = 0; k < bpc; k++)
			printf ("%02x", (unsigned) data[j + k]);
		      putchar (' ');
		    }
		}

	      for (; pb < octets_per_line; pb += bpc)
		{
		  int k;

		  for (k = 0; k < bpc; k++)
		    printf ("  ");
		  putchar (' ');
		}

	      /* Separate raw data from instruction by extra space.  */
	      if (insns)
		putchar ('\t');
	      else
		printf ("    ");
	    }

	  if (! insns)
	    printf ("%s", buf);
	  else
	    {
	      printf ("%s", sfile.buffer);
	      free (sfile.buffer);
	    }

	  if (prefix_addresses
	      ? show_raw_insn > 0
	      : show_raw_insn >= 0)
	    {
	      while (pb < octets)
		{
		  bfd_vma j;
		  char *s;

		  putchar ('\n');
		  j = addr_offset * opb + pb;

		  bfd_sprintf_vma (aux->abfd, buf, section->vma + j / opb);
		  for (s = buf + skip_addr_chars; *s == '0'; s++)
		    *s = ' ';
		  if (*s == '\0')
		    *--s = '0';
		  printf ("%s:\t", buf + skip_addr_chars);

		  pb += octets_per_line;
		  if (pb > octets)
		    pb = octets;
		  for (; j < addr_offset * opb + pb; j += bpc)
		    {
		      int k;

		      if (bpc > 1 && info->display_endian == BFD_ENDIAN_LITTLE)
			{
			  for (k = bpc - 1; k >= 0; k--)
			    printf ("%02x", (unsigned) data[j + k]);
			  putchar (' ');
			}
		      else
			{
			  for (k = 0; k < bpc; k++)
			    printf ("%02x", (unsigned) data[j + k]);
			  putchar (' ');
			}
		    }
		}
	    }

	  if (!wide_output)
	    putchar ('\n');
	  else
	    need_nl = TRUE;
	}

      if ((section->flags & SEC_RELOC) != 0
#ifndef DISASSEMBLER_NEEDS_RELOCS
	  && dump_reloc_info
#endif
	  )
	{
	  while ((*relppp) < relppend
		 && ((**relppp)->address >= (bfd_vma) addr_offset
		     && (**relppp)->address < (bfd_vma) addr_offset + octets / opb))
#ifdef DISASSEMBLER_NEEDS_RELOCS
	    if (! dump_reloc_info)
	      ++(*relppp);
	    else
#endif
	    {
	      arelent *q;

	      q = **relppp;

	      if (wide_output)
		putchar ('\t');
	      else
		printf ("\t\t\t");

	      objdump_print_value (section->vma + q->address, info, TRUE);

	      printf (": %s\t", q->howto->name);

	      if (q->sym_ptr_ptr == NULL || *q->sym_ptr_ptr == NULL)
		printf ("*unknown*");
	      else
		{
		  const char *sym_name;

		  sym_name = bfd_asymbol_name (*q->sym_ptr_ptr);
		  if (sym_name != NULL && *sym_name != '\0')
		    objdump_print_symname (aux->abfd, info, *q->sym_ptr_ptr);
		  else
		    {
		      asection *sym_sec;

		      sym_sec = bfd_get_section (*q->sym_ptr_ptr);
		      sym_name = bfd_get_section_name (aux->abfd, sym_sec);
		      if (sym_name == NULL || *sym_name == '\0')
			sym_name = "*unknown*";
		      printf ("%s", sym_name);
		    }
		}

	      if (q->addend)
		{
		  printf ("+0x");
		  objdump_print_value (q->addend, info, TRUE);
		}

	      printf ("\n");
	      need_nl = FALSE;
	      ++(*relppp);
	    }
	}

      if (need_nl)
	printf ("\n");

      addr_offset += octets / opb;
    }
}







/* Disassemble the contents of an object file.  */

static void
disassemble_data (abfd)
     bfd *abfd;
{
  unsigned long addr_offset;
  disassembler_ftype disassemble_fn;
  struct disassemble_info disasm_info;
  struct objdump_disasm_info aux;
  asection *section;
  unsigned int opb;

  print_files = NULL;
  prev_functionname = NULL;
  prev_line = -1;

  /* We make a copy of syms to sort.  We don't want to sort syms
     because that will screw up the relocs.  */
  sorted_syms = (asymbol **) xmalloc (symcount * sizeof (asymbol *));
  memcpy (sorted_syms, syms, symcount * sizeof (asymbol *));

  sorted_symcount = remove_useless_symbols (sorted_syms, symcount);

  /* Sort the symbols into section and symbol order.  */
  qsort (sorted_syms, sorted_symcount, sizeof (asymbol *), compare_symbols);

  INIT_DISASSEMBLE_INFO (disasm_info, stdout, fprintf);

  disasm_info.application_data = (PTR) &aux;
  aux.abfd = abfd;
  aux.require_sec = FALSE;
  disasm_info.print_address_func = objdump_print_address;
  disasm_info.symbol_at_address_func = objdump_symbol_at_address;

  if (machine != (char *) NULL)
    {
      const bfd_arch_info_type *info = bfd_scan_arch (machine);

      if (info == NULL)
	fatal ("Can't use supplied machine %s", machine);

      abfd->arch_info = info;
    }

  if (endian != BFD_ENDIAN_UNKNOWN)
    {
      struct bfd_target *xvec;

      xvec = (struct bfd_target *) xmalloc (sizeof (struct bfd_target));
      memcpy (xvec, abfd->xvec, sizeof (struct bfd_target));
      xvec->byteorder = endian;
      abfd->xvec = xvec;
    }

  disassemble_fn = disassembler (abfd);
  if (!disassemble_fn)
    {
      non_fatal ("Can't disassemble for architecture %s\n",
		 bfd_printable_arch_mach (bfd_get_arch (abfd), 0));
      exit_status = 1;
      return;
    }

  opb = bfd_octets_per_byte (abfd);

  disasm_info.flavour = bfd_get_flavour (abfd);
  disasm_info.arch = bfd_get_arch (abfd);
  disasm_info.mach = bfd_get_mach (abfd);
  disasm_info.disassembler_options = disassembler_options;
  disasm_info.octets_per_byte = opb;

  if (bfd_big_endian (abfd))
    disasm_info.display_endian = disasm_info.endian = BFD_ENDIAN_BIG;
  else if (bfd_little_endian (abfd))
    disasm_info.display_endian = disasm_info.endian = BFD_ENDIAN_LITTLE;
  else
    /* ??? Aborting here seems too drastic.  We could default to big or little
       instead.  */
    disasm_info.endian = BFD_ENDIAN_UNKNOWN;

  for (section = abfd->sections;
       section != (asection *) NULL;
       section = section->next)
    {
      bfd_byte *data = NULL;
      bfd_size_type datasize = 0;
      arelent **relbuf = NULL;
      arelent **relpp = NULL;
      arelent **relppend = NULL;
      unsigned long stop_offset;
      asymbol *sym = NULL;
      long place = 0;

      if ((section->flags & SEC_LOAD) == 0
	  || (! disassemble_all
	      && only == NULL
	      && (section->flags & SEC_CODE) == 0))
	continue;
      if (only != (char *) NULL && strcmp (only, section->name) != 0)
	continue;

      if ((section->flags & SEC_RELOC) != 0
#ifndef DISASSEMBLER_NEEDS_RELOCS
	  && dump_reloc_info
#endif
	  )
	{
	  long relsize;

	  relsize = bfd_get_reloc_upper_bound (abfd, section);
	  if (relsize < 0)
	    bfd_fatal (bfd_get_filename (abfd));

	  if (relsize > 0)
	    {
	      long relcount;

	      relbuf = (arelent **) xmalloc (relsize);
	      relcount = bfd_canonicalize_reloc (abfd, section, relbuf, syms);
	      if (relcount < 0)
		bfd_fatal (bfd_get_filename (abfd));

	      /* Sort the relocs by address.  */
	      qsort (relbuf, relcount, sizeof (arelent *), compare_relocs);

	      relpp = relbuf;
	      relppend = relpp + relcount;

	      /* Skip over the relocs belonging to addresses below the
		 start address.  */
	      if (start_address != (bfd_vma) -1)
		while (relpp < relppend
		       && (*relpp)->address < start_address)
		  ++relpp;
	    }
	}

      printf ("Disassembly of section %s:\n", section->name);

      datasize = bfd_get_section_size_before_reloc (section);
      if (datasize == 0)
	continue;

      data = (bfd_byte *) xmalloc ((size_t) datasize);

      bfd_get_section_contents (abfd, section, data, 0, datasize);

      aux.sec = section;
      disasm_info.buffer = data;
      disasm_info.buffer_vma = section->vma;
      disasm_info.buffer_length = datasize;
      disasm_info.section = section;

      if (start_address == (bfd_vma) -1
	  || start_address < disasm_info.buffer_vma)
	addr_offset = 0;
      else
	addr_offset = start_address - disasm_info.buffer_vma;

      if (stop_address == (bfd_vma) -1)
	stop_offset = datasize / opb;
      else
	{
	  if (stop_address < disasm_info.buffer_vma)
	    stop_offset = 0;
	  else
	    stop_offset = stop_address - disasm_info.buffer_vma;
	  if (stop_offset > disasm_info.buffer_length / opb)
	    stop_offset = disasm_info.buffer_length / opb;
	}

      sym = find_symbol_for_address (abfd, section, section->vma + addr_offset,
				     TRUE, &place);

      while (addr_offset < stop_offset)
	{
	  asymbol *nextsym;
	  unsigned long nextstop_offset;
	  bfd_boolean insns;

	  if (sym != NULL && bfd_asymbol_value (sym) <= section->vma + addr_offset)
	    {
	      int x;

	      for (x = place;
		   (x < sorted_symcount
		    && bfd_asymbol_value (sorted_syms[x]) <= section->vma + addr_offset);
		   ++x)
		continue;

	      disasm_info.symbols = & sorted_syms[place];
	      disasm_info.num_symbols = x - place;
	    }
	  else
	    disasm_info.symbols = NULL;

	  if (! prefix_addresses)
	    {
	      (* disasm_info.fprintf_func) (disasm_info.stream, "\n");
	      objdump_print_addr_with_sym (abfd, section, sym,
					   section->vma + addr_offset,
					   &disasm_info,
					   FALSE);
	      (* disasm_info.fprintf_func) (disasm_info.stream, ":\n");
	    }

	  if (sym != NULL && bfd_asymbol_value (sym) > section->vma + addr_offset)
	    nextsym = sym;
	  else if (sym == NULL)
	    nextsym = NULL;
	  else
	    {
	      /* Search forward for the next appropriate symbol in
                 SECTION.  Note that all the symbols are sorted
                 together into one big array, and that some sections
                 may have overlapping addresses.  */
	      while (place < sorted_symcount
		     && (sorted_syms[place]->section != section
			 || (bfd_asymbol_value (sorted_syms[place])
			     <= bfd_asymbol_value (sym))))
		++place;
	      if (place >= sorted_symcount)
		nextsym = NULL;
	      else
		nextsym = sorted_syms[place];
	    }

	  if (sym != NULL && bfd_asymbol_value (sym) > section->vma + addr_offset)
	    {
	      nextstop_offset = bfd_asymbol_value (sym) - section->vma;
	      if (nextstop_offset > stop_offset)
		nextstop_offset = stop_offset;
	    }
	  else if (nextsym == NULL)
	    nextstop_offset = stop_offset;
	  else
	    {
	      nextstop_offset = bfd_asymbol_value (nextsym) - section->vma;
	      if (nextstop_offset > stop_offset)
		nextstop_offset = stop_offset;
	    }

	  /* If a symbol is explicitly marked as being an object
	     rather than a function, just dump the bytes without
	     disassembling them.  */
	  if (disassemble_all
	      || sym == NULL
	      || bfd_asymbol_value (sym) > section->vma + addr_offset
	      || ((sym->flags & BSF_OBJECT) == 0
		  && (strstr (bfd_asymbol_name (sym), "gnu_compiled")
		      == NULL)
		  && (strstr (bfd_asymbol_name (sym), "gcc2_compiled")
		      == NULL))
	      || (sym->flags & BSF_FUNCTION) != 0)
	    insns = TRUE;
	  else
	    insns = FALSE;

	  disassemble_bytes (&disasm_info, disassemble_fn, insns, data,
			     addr_offset, nextstop_offset, &relpp, relppend);

	  addr_offset = nextstop_offset;
	  sym = nextsym;
	}

      free (data);

      if (relbuf != NULL)
	free (relbuf);
    }
  free (sorted_syms);
}























static asymbol **
slurp_symtab (abfd)
     bfd *abfd;
{
  asymbol **sy = (asymbol **) NULL;
  long storage;

  if (!(bfd_get_file_flags (abfd) & HAS_SYMS))
    {
      symcount = 0;
      return NULL;
    }

  storage = bfd_get_symtab_upper_bound (abfd);
  if (storage < 0)
    bfd_fatal (bfd_get_filename (abfd));
  if (storage)
    sy = (asymbol **) xmalloc (storage);

  symcount = bfd_canonicalize_symtab (abfd, sy);
  if (symcount < 0)
    bfd_fatal (bfd_get_filename (abfd));
  return sy;
}

/* Read in the dynamic symbols.  */

static asymbol **
slurp_dynamic_symtab (abfd)
     bfd *abfd;
{
  asymbol **sy = (asymbol **) NULL;
  long storage;

  storage = bfd_get_dynamic_symtab_upper_bound (abfd);
  if (storage < 0)
    {
      if (!(bfd_get_file_flags (abfd) & DYNAMIC))
	{
	  non_fatal ("%s: not a dynamic object", bfd_get_filename (abfd));
	  dynsymcount = 0;
	  return NULL;
	}

      bfd_fatal (bfd_get_filename (abfd));
    }
  if (storage)
    sy = (asymbol **) xmalloc (storage);

  dynsymcount = bfd_canonicalize_dynamic_symtab (abfd, sy);
  if (dynsymcount < 0)
    bfd_fatal (bfd_get_filename (abfd));
  return sy;
}




static void
dump_symbols (abfd, dynamic)
     bfd *abfd ATTRIBUTE_UNUSED;
     bfd_boolean dynamic;
{
  asymbol **current;
  long max;
  long count;

  if (dynamic)
    {
      current = dynsyms;
      max = dynsymcount;
      printf ("DYNAMIC SYMBOL TABLE:\n");
    }
  else
    {
      current = syms;
      max = symcount;
      printf ("SYMBOL TABLE:\n");
    }

  if (max == 0)
    printf ("no symbols\n");

  for (count = 0; count < max; count++)
    {
      if (*current)
	{
	  bfd *cur_bfd = bfd_asymbol_bfd (*current);

	  if (cur_bfd != NULL)
	    {
	      const char *name;
	      char *alloc;

	      name = (*current)->name;
	      alloc = NULL;
	      //if (do_demangle && name != NULL && *name != '\0')
	      //	{
		  /* If we want to demangle the name, we demangle it
                     here, and temporarily clobber it while calling
                     bfd_print_symbol.  FIXME: This is a gross hack.  */
		  //alloc = demangle (cur_bfd, name);
		  //(*current)->name = alloc;
		  //}

	      bfd_print_symbol (cur_bfd, stdout, *current,
				bfd_print_symbol_all);

	      (*current)->name = name;
	      if (alloc != NULL)
		free (alloc);

	      printf ("\n");
	    }
	}
      current++;
    }
  printf ("\n");
  printf ("\n");
}



static void
dump_section_header (abfd, section, ignored)
     bfd *abfd ATTRIBUTE_UNUSED;
     asection *section;
     PTR ignored ATTRIBUTE_UNUSED;
{
  char *comma = "";
  unsigned int opb = bfd_octets_per_byte (abfd);

  printf ("%3d %-13s %08lx  ", section->index,
	  bfd_get_section_name (abfd, section),
	  (unsigned long) bfd_section_size (abfd, section) / opb);
  bfd_printf_vma (abfd, bfd_get_section_vma (abfd, section));
  printf ("  ");
  bfd_printf_vma (abfd, section->lma);
  printf ("  %08lx  2**%u", (unsigned long) section->filepos,
	  bfd_get_section_alignment (abfd, section));
  if (! wide_output)
    printf ("\n                ");
  printf ("  ");

#define PF(x, y) \
  if (section->flags & x) { printf ("%s%s", comma, y); comma = ", "; }

  PF (SEC_HAS_CONTENTS, "CONTENTS");
  PF (SEC_ALLOC, "ALLOC");
  PF (SEC_CONSTRUCTOR, "CONSTRUCTOR");
  PF (SEC_LOAD, "LOAD");
  PF (SEC_RELOC, "RELOC");
  PF (SEC_READONLY, "READONLY");
  PF (SEC_CODE, "CODE");
  PF (SEC_DATA, "DATA");
  PF (SEC_ROM, "ROM");
  PF (SEC_DEBUGGING, "DEBUGGING");
  PF (SEC_NEVER_LOAD, "NEVER_LOAD");
  PF (SEC_EXCLUDE, "EXCLUDE");
  PF (SEC_SORT_ENTRIES, "SORT_ENTRIES");
  PF (SEC_BLOCK, "BLOCK");
  PF (SEC_CLINK, "CLINK");
  PF (SEC_SMALL_DATA, "SMALL_DATA");
  PF (SEC_SHARED, "SHARED");
  PF (SEC_ARCH_BIT_0, "ARCH_BIT_0");
  PF (SEC_THREAD_LOCAL, "THREAD_LOCAL");

  if ((section->flags & SEC_LINK_ONCE) != 0)
    {
      const char *ls;

      switch (section->flags & SEC_LINK_DUPLICATES)
	{
	default:
	  abort ();
	case SEC_LINK_DUPLICATES_DISCARD:
	  ls = "LINK_ONCE_DISCARD";
	  break;
	case SEC_LINK_DUPLICATES_ONE_ONLY:
	  ls = "LINK_ONCE_ONE_ONLY";
	  break;
	case SEC_LINK_DUPLICATES_SAME_SIZE:
	  ls = "LINK_ONCE_SAME_SIZE";
	  break;
	case SEC_LINK_DUPLICATES_SAME_CONTENTS:
	  ls = "LINK_ONCE_SAME_CONTENTS";
	  break;
	}
      printf ("%s%s", comma, ls);

      if (section->comdat != NULL)
	printf (" (COMDAT %s %ld)", section->comdat->name,
		section->comdat->symbol);

      comma = ", ";
    }

  printf ("\n");
#undef PF
}



static void
dump_headers (abfd)
     bfd *abfd;
{
  printf ("Sections:\n");

#ifndef BFD64
  printf ("Idx Name          Size      VMA       LMA       File off  Algn");
#else
  /* With BFD64, non-ELF returns -1 and wants always 64 bit addresses.  */
  if (bfd_get_arch_size (abfd) == 32)
    printf ("Idx Name          Size      VMA       LMA       File off  Algn");
  else
    printf ("Idx Name          Size      VMA               LMA               File off  Algn");
#endif

  if (wide_output)
    printf ("  Flags");
  if (abfd->flags & HAS_LOAD_PAGE)
    printf ("  Pg");
  printf ("\n");

  bfd_map_over_sections (abfd, dump_section_header, (PTR) NULL);
}


static void
dump_bfd_header (abfd)
     bfd *abfd;
{
  char *comma = "";

  printf ("architecture: %s, ",
	  bfd_printable_arch_mach (bfd_get_arch (abfd),
				   bfd_get_mach (abfd)));
  printf ("flags 0x%08x:\n", abfd->flags);

#define PF(x, y)    if (abfd->flags & x) {printf("%s%s", comma, y); comma=", ";}
  PF (HAS_RELOC, "HAS_RELOC");
  PF (EXEC_P, "EXEC_P");
  PF (HAS_LINENO, "HAS_LINENO");
  PF (HAS_DEBUG, "HAS_DEBUG");
  PF (HAS_SYMS, "HAS_SYMS");
  PF (HAS_LOCALS, "HAS_LOCALS");
  PF (DYNAMIC, "DYNAMIC");
  PF (WP_TEXT, "WP_TEXT");
  PF (D_PAGED, "D_PAGED");
  PF (BFD_IS_RELAXABLE, "BFD_IS_RELAXABLE");
  PF (HAS_LOAD_PAGE, "HAS_LOAD_PAGE");
  printf ("\nstart address 0x");
  bfd_printf_vma (abfd, abfd->start_address);
  printf ("\n");
}





static void
l1_read_data (abfd)
     bfd *abfd;
{
  asection *section;
  bfd_byte *data = 0;
  bfd_size_type datasize = 0;
  bfd_size_type addr_offset;
  bfd_size_type start_offset, stop_offset;
  unsigned int opb = bfd_octets_per_byte (abfd);

  dump_bfd_header (abfd);
  dump_headers (abfd);
  
  syms = slurp_symtab (abfd);
  dynsyms = slurp_dynamic_symtab (abfd);

  dump_symbols (abfd, 0);
  disassemble_data (abfd);
  
  for (section = abfd->sections; section != NULL; section =
       section->next)
    {
      int onaline = 16;

      if (only == (char *) NULL ||
	  strcmp (only, section->name) == 0)
	{
	  if (section->flags & SEC_HAS_CONTENTS)
	    {
	      char buf[64];
	      int count, width;
	      
	      printf ("Contents of section %s:\n", section->name);

	      if (bfd_section_size (abfd, section) == 0)
		continue;
	      data = (bfd_byte *) xmalloc ((size_t) bfd_section_size (abfd, section));
	      datasize = bfd_section_size (abfd, section);


	      bfd_get_section_contents (abfd, section, (PTR) data, 0, bfd_section_size (abfd, section));

	      if (start_address == (bfd_vma) -1
		  || start_address < section->vma)
		start_offset = 0;
	      else
		start_offset = start_address - section->vma;
	      if (stop_address == (bfd_vma) -1)
		stop_offset = bfd_section_size (abfd, section) / opb;
	      else
		{
		  if (stop_address < section->vma)
		    stop_offset = 0;
		  else
		    stop_offset = stop_address - section->vma;
		  if (stop_offset > bfd_section_size (abfd, section) / opb)
		    stop_offset = bfd_section_size (abfd, section) / opb;
		}

	      width = 4;

	      bfd_sprintf_vma (abfd, buf, start_offset + section->vma);
	      if (strlen (buf) >= sizeof (buf))
		abort ();
	      count = 0;
	      while (buf[count] == '0' && buf[count+1] != '\0')
		count++;
	      count = strlen (buf) - count;
	      if (count > width)
		width = count;

	      bfd_sprintf_vma (abfd, buf, stop_offset + section->vma - 1);
	      if (strlen (buf) >= sizeof (buf))
		abort ();
	      count = 0;
	      while (buf[count] == '0' && buf[count+1] != '\0')
		count++;
	      count = strlen (buf) - count;
	      if (count > width)
		width = count;

	      for (addr_offset = start_offset;
		   addr_offset < stop_offset; addr_offset += onaline / opb)
		{
		  bfd_size_type j;

		  bfd_sprintf_vma (abfd, buf, (addr_offset + section->vma));
		  count = strlen (buf);
		  if (count >= sizeof (buf))
		    abort ();
		  putchar (' ');
		  while (count < width)
		    {
		      putchar ('0');
		      count++;
		    }
		  fputs (buf + count - width, stdout);
		  putchar (' ');

		  for (j = addr_offset * opb;
		       j < addr_offset * opb + onaline; j++)
		    {
		      if (j < stop_offset * opb)
			printf ("%02x", (unsigned) (data[j]));
		      else
			printf ("  ");
		      if ((j & 3) == 3)
			printf (" ");
		    }

		  printf (" ");
		  for (j = addr_offset * opb;
		       j < addr_offset * opb + onaline; j++)
		    {
		      if (j >= stop_offset * opb)
			printf (" ");
		      else
			printf ("%c", isprint (data[j]) ? data[j] : '.');
		    }
		  putchar ('\n');
		}
	      free (data);
	    }
	}
    }
}


static void
l1_read_bfd (abfd)
     bfd *abfd;
{
  char **matching;

  printf ("\n%s:     file format %s\n", bfd_get_filename (abfd),
	  abfd->xvec->name);

  if (bfd_check_format_matches (abfd, bfd_object, &matching))
    {
      l1_read_data (abfd);
      return;
    }

  if (bfd_get_error () == bfd_error_file_ambiguously_recognized)
    {
      nonfatal (bfd_get_filename (abfd));
      list_matching_formats (matching);
      free (matching);
      
      
      //read_exe (char *filename, char *target) {


      return;
    }

  if (bfd_get_error () != bfd_error_file_not_recognized)
    {
      nonfatal (bfd_get_filename (abfd));
      return;
    }

  if (bfd_check_format_matches (abfd, bfd_core, &matching))
    {
      l1_read_data (abfd);
      return;
    }

  nonfatal (bfd_get_filename (abfd));

  if (bfd_get_error () == bfd_error_file_ambiguously_recognized)
    {
      list_matching_formats (matching);
      free (matching);
    }
}


void read_exe (char *filename, char *target) {
  
  bfd *file, *arfile = (bfd *) NULL;

  file = bfd_openr (filename, target);
  if (file == NULL)
    {
      nonfatal (filename);
      return;
    }

  if (bfd_check_format (file, bfd_archive))
    {
      bfd *last_arfile = NULL;

      printf ("In archive %s:\n", bfd_get_filename (file));
      for (;;)
	{
	  bfd_set_error (bfd_error_no_error);

	  arfile = bfd_openr_next_archived_file (file, arfile);
	  if (arfile == NULL)
	    {
	      if (bfd_get_error () != bfd_error_no_more_archived_files)
		nonfatal (bfd_get_filename (file));
	      break;
	    }

	  l1_read_bfd (arfile);

	  if (last_arfile != NULL)
	    bfd_close (last_arfile);
	  last_arfile = arfile;
	}

      if (last_arfile != NULL)
	bfd_close (last_arfile);
    }
  else
    l1_read_bfd (file);

  bfd_close (file);
}

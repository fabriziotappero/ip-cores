
#include "sim.h"

char *program_name = "sim";
#define REPORT_BUGS_TO "Konrad Eisele <eiselekd@web.de>"
static void print_version(char *n) {
  printf(n);
}

struct option options[] =
{
  {"all",	       no_argument, 0, 'a'},
  {"file-header",      no_argument, 0, 'h'},
  {"program-headers",  no_argument, 0, 'l'},
  {"headers",	       no_argument, 0, 'e'},
  {"histogram",	       no_argument, 0, 'I'},
  {"segments",	       no_argument, 0, 'l'},
  {"sections",	       no_argument, 0, 'S'},
  {"section-headers",  no_argument, 0, 'S'},
  {"symbols",	       no_argument, 0, 's'},
  {"syms",	       no_argument, 0, 's'},
  {"relocs",	       no_argument, 0, 'r'},
  {"notes",	       no_argument, 0, 'n'},
  {"dynamic",	       no_argument, 0, 'd'},
  {"arch-specific",    no_argument, 0, 'A'},
  {"version-info",     no_argument, 0, 'V'},
  {"use-dynamic",      no_argument, 0, 'D'},
  {"hex-dump",	       required_argument, 0, 'x'},
  {"unwind",	       no_argument, 0, 'u'},
#ifdef SUPPORT_DISASSEMBLY
  {"instruction-dump", required_argument, 0, 'i'},
#endif

  {"version",	       no_argument, 0, 'v'},
  {"wide",	       no_argument, 0, 'W'},
  {"help",	       no_argument, 0, 'H'},
  {0,		       no_argument, 0, 0}
};

static void
usage ()
{
  fprintf (stdout, "Usage: readelf <option(s)> elf-file(s)\n");
  fprintf (stdout, " Display information about the contents of ELF format files\n");
  fprintf (stdout, " Options are:\n\
  -a --all               Equivalent to: -h -l -S -s -r -d -V -A -I\n\
  -h --file-header       Display the ELF file header\n\
  -l --program-headers   Display the program headers\n\
     --segments          An alias for --program-headers\n\
  -S --section-headers   Display the sections' header\n\
     --sections          An alias for --section-headers\n\
  -e --headers           Equivalent to: -h -l -S\n\
  -s --syms              Display the symbol table\n\
      --symbols          An alias for --syms\n\
  -n --notes             Display the core notes (if present)\n\
  -r --relocs            Display the relocations (if present)\n\
  -u --unwind            Display the unwind info (if present)\n\
  -d --dynamic           Display the dynamic segment (if present)\n\
  -V --version-info      Display the version sections (if present)\n\
  -A --arch-specific     Display architecture specific information (if any).\n\
  -D --use-dynamic       Use the dynamic section info when displaying symbols\n\
  -x --hex-dump=<number> Dump the contents of section <number>\n\
  -w[liaprmfFso] or\n\
  --debug-dump[=line,=info,=abbrev,=pubnames,=ranges,=macro,=frames,=str,=loc]\n\
                         Display the contents of DWARF2 debug sections\n");
#ifdef SUPPORT_DISASSEMBLY
  fprintf (stdout, "\
  -i --instruction-dump=<number>\n\
                         Disassemble the contents of section <number>\n");
#endif
  fprintf (stdout, "\
  -I --histogram         Display histogram of bucket list lengths\n\
  -W --wide              Allow output width to exceed 80 characters\n\
  -H --help              Display this information\n\
  -v --version           Display the version number of readelf\n");
  fprintf (stdout, "Report bugs to %s\n", REPORT_BUGS_TO);

  exit (0);
}

void
parse_args (argc, argv)
     int argc;
     char **argv;
{
  int c;

  if (argc < 2)
    usage ();
  
  while ((c = getopt_long
	  (argc, argv, "ersuahnldSDAIw::x:i:vVWH", options, NULL)) != EOF)
    {
      char *cp;
      int section;

      switch (c)
	{
	case 0:
	  /* Long options.  */
	  break;
	case 'H':
	  usage ();
	  break;

	case 'a':
	  break;
	case 'e':
	  break;
	case 'A':
	  break;
	case 'D':
	  break;
	case 'r':
	  break;
	case 'u':
	  break;
	case 'h':
	  break;
	case 'l':
	  break;
	case 's':
	  break;
	case 'd':
	  break;
	case 'I':
	  break;
	case 'n':
	  break;
	case 'x':
	  goto oops;
	case 'w':
	  break;
#ifdef SUPPORT_DISASSEMBLY
	case 'i':
	  goto oops;
#endif
	case 'v':
	  print_version (program_name);
	  break;
	case 'V':
	  break;
	case 'W':
	  break;
	default:
	oops:
	  /* xgettext:c-format */
	  //error ("Invalid option '-%c'\n", c);
	  /* Drop through.  */
	case '?':
	  usage ();
	}
    }
 
    usage ();
}



#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "List.hh"
#include "Backend.hh"

extern FILE * yyin;
extern FILE * out;
extern int yyparse();

static int usage(const char * prog, int ret);

FILE * out = 0;

extern bool is_loader;
extern int  memtop;

bool is_loader = false;
int  memtop = 0;

//-----------------------------------------------------------------------------
int main(int argc, char * argv[])
{
int ret = 0;

const char * prog = *argv;
   argv++;
   argc--;

   if (argc < 1)   return usage(prog, 1);

   if (!strcmp(*argv, "-l"))
      {
        argv++;
        argc--;
        is_loader = true;
      }

   if (argc < 1)   return usage(prog, 2);

   memtop = strtol(*argv, 0, 0);
   if (!memtop)   return usage(prog, 3);
   fprintf(stderr, "Top of memory is 0x%X\n", memtop);
   argv++;
   argc--;

   if (argc < 1)   return usage(prog, 4);
   yyin = fopen(*argv,  "r");
   if (yyin == 0)
      {
        fprintf(stderr, "Can't open input file %s\n", *argv);
        return 5;
      }
   argv++;
   argc--;

   out = stdout;
   if (argc)
      {
        out = fopen(*argv, "w");
        if (out == 0)
           {
             fprintf(stderr, "Can't open output file %s\n", *argv);
             return 6;
           }
      }

   Backend::file_header();

   if (yyparse())
      {
        fprintf(stderr, "PARSE ERROR\n");
	ret = 7;
      }
   else
      {
        fprintf(stderr, "PARSED OK\n");
        if (Node::GetSemanticErrors())
           {
             fprintf(stderr, "BUT: %d errors\n", Node::GetSemanticErrors());
	     ret = Node::GetSemanticErrors();
           }
      }

   Backend::file_footer();

   fclose(yyin);
   fclose(out);
   yyin = 0;
   return ret;
}
//-----------------------------------------------------------------------------
int usage(const char * prog, int ret)
{
   fprintf(stderr, "\n%s: Error %d\n", prog, ret);
   fprintf(stderr, "\nUsage:\n   %s [-l] memtop file.c [file.asm]\n", prog);
   return ret;
}
//-----------------------------------------------------------------------------


#include <stdio.h>
#include <string.h>
#include <assert.h>

extern FILE * yyin;
extern FILE * out;
extern FILE * sym;
extern FILE * ihx;
extern int yyparse();

static void usage(const char * prog);

FILE * out  = 0;
FILE * sym  = 0;
FILE * list = 0;
FILE * ihx  = 0;
char listname[256];
char outname [256];
char ihxname [256];
char symname [256];

//-----------------------------------------------------------------------------
int main(int argc, char * argv[])
{
   if (argc < 2)   { usage(argv[0]);   return 1; }

char * asmname = argv[1];
   yyin = fopen(asmname,  "r");
   if (yyin == 0)
      {
        fprintf(stderr, "Can't open %s\n", asmname);
        return 1;
      }

char * asmend = strrchr(asmname, '.');
   if (asmend)   *asmend = 0;

   if (argc == 3)   sprintf(outname, "%s", argv[2]);
   else             sprintf(outname,  "%s.bin", asmname);

   if (argc == 4)   sprintf(listname, "%s", argv[3]);
   else             sprintf(listname, "%s.lst", asmname);

   if (argc == 5)   sprintf(symname, "%s", argv[4]);
   else             sprintf(symname, "%s.sym", asmname);

   if (argc == 6)   sprintf(ihxname, "%s", argv[5]);
   else             sprintf(ihxname, "%s.ihx", asmname);

   fprintf(stderr, "Asmname  = %s\n", asmname);
   fprintf(stderr, "Listname = %s\n", listname);
   fprintf(stderr, "Outname  = %s\n", outname);
   fprintf(stderr, "Symname  = %s\n", symname);
   fprintf(stderr, "Ihxname  = %s\n", ihxname);

   list = fopen(listname, "w");   assert(list);
   out  = fopen(outname, "wb");   assert(out);
   sym  = fopen(symname, "w");    assert(sym);
   ihx  = fopen(ihxname, "w");    assert(ihx);

   if (yyparse())
      {
        fprintf(stderr, "PARSE ERROR\n");
      }
   else
      {
        fprintf(stderr, "PARSED OK\n");
      }

   fclose(yyin);
   fclose(list);
   fclose(out);
   fclose(sym);
   yyin = 0;
   return 0;
}
//-----------------------------------------------------------------------------
void usage(const char * prog)
{
   fprintf(stderr, "Usage: %s [-l] file.asm [file.asm]\r\n", prog);
}
//-----------------------------------------------------------------------------

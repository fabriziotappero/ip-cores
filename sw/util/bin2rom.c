#include <stdio.h>
#include <string.h>

unsigned power(unsigned base,unsigned n) {
  unsigned p;
  for(p=1; n > 0; --n)
     p=p*base;
  return p;
}

int main(int argc, char *argv[]) {

  FILE *infile, *outfile;
  int c;
  unsigned program_size;
  unsigned i = 0;

  if (argc != 4) {
    print_help(argv[0]);
    return(1);
  }
  
  infile = fopen(argv[1], "rb");
  if (!infile) {
    printf("Cannot open file %s\n", argv[1]);
    return(1);
  }
  
  outfile = fopen(argv[2], "w");
  if (!outfile) {
    printf("Cannot open file %s\n", argv[2]);
    return(1);
  }

  if (strlen(argv[3]) <= 0) {
    printf("Argument depth missing", argv[3]);
    return(1);
  }

  fprintf(outfile,"\
----------------------------------------------------------------------------------------------\n\
--\n\
--      Input file         : pram.vhd\n\
--      Design name        : pram\n\
--      Author             : Tamar Kranenburg\n\
--      Company            : Delft University of Technology\n\
--\n\
--      Description        : Single Port Synchronous Random Access Memory\n\
--\n\
----------------------------------------------------------------------------------------------\n\
\n\
LIBRARY ieee;\n\
USE ieee.std_logic_1164.ALL;\n\
USE ieee.std_logic_unsigned.ALL;\n\
\n\
LIBRARY mblite;\n\
USE mblite.std_Pkg.ALL;\n\
\n\
ENTITY pram IS\n\
    GENERIC\n\
    (\n\
        WIDTH : integer := 32;\n\
        SIZE  : integer := %s\n\
    );\n\
    PORT\n\
    (\n\
        dat_o                   : OUT std_logic_vector(WIDTH - 1 DOWNTO 0);\n\
        dat_i                   : IN std_logic_vector(WIDTH - 1 DOWNTO 0);\n\
        adr_i                   : IN std_logic_vector(SIZE - 1 DOWNTO 0);\n\
        wre_i                   : IN std_logic;\n\
        ena_i                   : IN std_logic;\n\
        clk_i                   : IN std_logic\n\
    );\n\
END pram;\n\
\n\
ARCHITECTURE arch OF pram IS\n\
  TYPE ram_type IS array (0 TO 2 ** SIZE - 1) OF std_logic_vector(WIDTH - 1 DOWNTO 0);\n\
  SIGNAL ram : ram_type := (", argv[3]);

  while((c = fgetc(infile)) != EOF)
  {
    if ((i % 32) == 0 ) { fprintf(outfile,"\n    "); }
    if ((i % 4) == 0 ) { fprintf(outfile,"X\""); }
    fprintf(outfile,"%.2X", (unsigned char) c & 0x0ff);
    if ((i % 4) == 3 ) { fprintf(outfile,"\","); }
    i++;
  }

  fprintf(outfile, "X\"FFFFFFFF\"");
  i+=4;
  /* Fill rest of ram */

  program_size = power(2, atoi(argv[3])) * 4;

  while(i < program_size)
  {
    if ((i % 4) == 0 ) { fprintf(outfile,","); }
    if ((i % 32) == 0 ) { fprintf(outfile,"\n    "); }
    if ((i % 4) == 0 ) { fprintf(outfile,"X\""); }
    fprintf(outfile,"00");
    if ((i % 4) == 3 ) { fprintf(outfile,"\""); }
    i++;
  }

  fprintf(outfile,");\n\
\n\
BEGIN\n\
    PROCESS(clk_i)\n\
    BEGIN\n\
        IF rising_edge(clk_i) THEN\n\
            IF notx(adr_i) AND ena_i = '1' THEN\n\
                IF wre_i = '1' THEN\n\
                    ram(conv_integer(adr_i)) <= dat_i;\n\
                END IF;\n\
                dat_o <= ram(conv_integer(adr_i));\n\
            END IF;\n\
        END IF;\n\
    END PROCESS;\n\
END arch;\n\
");

  fclose(infile);
  fclose(outfile);

  return 0;

}

int print_help(char * name)
{
  fprintf(stderr, "Usage: %s INFILE OUTFILE WIDTH DEPTH\n", name);
  fprintf(stderr, "%s converts a binary into a VHDL rom file\n", name);
  fprintf(stderr, "DEPTH in log(n) elements\n");
  return 0;
}

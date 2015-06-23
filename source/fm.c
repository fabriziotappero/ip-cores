#include <stdio.h>
#include <string.h>
#include "genpat.h"

char *inttostr(entier)
int entier;
 {
 char *str;
 str = (char *) mbkalloc (32 * sizeof (char));
 sprintf (str, "%d",entier);
 return(str);
 }
  /*------------------------------*/
  /* end of the description       */
  /*------------------------------*/

main (int argc, char *argv[])
{
int i,c;
int ks;
FILE *f1;
char *fname1 = "fm.txt";
char  fmin[5000][50];

if (argc > 1 ) { 
  if (argc == 2) {
    fname1 = argv[1];
    printf("Using (%s)\n", fname1);
  } else {
    printf("Usage %s: fm-source.txt\n", argv[0]);
    return 0;
  }
}

if(fname1 && (f1 = fopen(fname1, "rt"))) {
  i = 0;
  while(fgets(fmin[i],sizeof(fmin[i]),f1) != NULL) {
    c = strlen(fmin[i]);
    if(fmin[i][c-1] == '\n') fmin[i][c-1] = '\0';
    i++;
  }
  fclose (f1);
} else {
  fclose (f1);
}

ks = i;

DEF_GENPAT("fm");
SETTUNIT("ns");

DECLAR (  "clk", ":1", "B", IN , ""           , "" );
DECLAR ("reset", ":1", "B", IN , ""           , "" );
DECLAR ("fmin" , ":1", "B", IN , " 7 downto 0", "" );
DECLAR ("dmout", ":1", "B", OUT, "11 downto 0", "" );
DECLAR (  "vss", ":1", "B", IN , ""           , "" );
DECLAR (  "vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");

AFFECT (  "0","fmin","0x00");
AFFECT (  "0","reset","0b1");
AFFECT (  "0", "clk", "0b0");
AFFECT ("+50", "clk", "0b1");
AFFECT ("+50", "clk", "0b0");
AFFECT ( "+0","reset","0b0");

for (i = 0; i < ks; i++)
{
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
  AFFECT ( "+0","fmin",fmin[i]);
}

AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );
AFFECT ( "+0","fmin", "0x00");

for (; i <1100; i++)
{
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
}

AFFECT ("+50", "clk", "0b1");

SAV_GENPAT ();
}


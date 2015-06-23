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

main (int argc, char *argv[])
{
int i,c;
int Nk,ks,ps;
char sNk[4];
FILE *f1, *f2;
//char *fname1 = "key.lst";
char *fname2 = "ckey.lst";
//char  key[0xff][0x4f];
char  fpt[0xff][0x4f];

Nk = 4;
/* remember argc start from 1 not zero and command line is the first array */
if (argc > 1 ) { 
  if (argc == 3) {
    fname2 = argv[2];
    sscanf(argv[1], "%d", &Nk);
    printf("Using Nk(0x%x) key (%s)\n", Nk, fname2);
  } else {
    printf("Usage %s: Nk key\n", argv[0]);
    return 0;
  }
}

sprintf(sNk, "0x%x", Nk);

if(fname2 && (f2 = fopen(fname2, "rt"))) {
  i = 0;
  while(fgets(fpt[i],sizeof(fpt[i]),f2) != NULL) {
    c = strlen(fpt[i]);
    if(fpt[i][c-1] == '\n') fpt[i][c-1] = '\0';
    i++;
  }
  fclose (f2);
} else {
  fclose (f2);
}

ps = i;

DEF_GENPAT("keyscheduler");
SETTUNIT("ns");

DECLAR ("clk", ":1", "B", IN , ""           , "" );
DECLAR ("rst", ":1", "B", IN , ""           , "" );
DECLAR ("ldk", ":1", "B", IN , ""           , "" );
DECLAR ("key", ":2", "X", IN , "63 downto 0", "" );
DECLAR ( "Nk", ":2", "X", IN , " 3 downto 0", "" );
DECLAR (  "w", ":2", "X", OUT, "63 downto 0", "" );
DECLAR (  "v", ":1", "B", OUT, ""           , "" );
DECLAR ("vss", ":1", "B", IN , ""           , "" );
DECLAR ("vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");

AFFECT (  "0", "key", "0x0000000000000000");
AFFECT (  "0", "rst", "0b1");
AFFECT (  "0","ldk", "0b0");
AFFECT (  "0",  "Nk",  sNk );
AFFECT (  "0", "clk", "0b0");
AFFECT ("+50", "clk", "0b1");
AFFECT ("+50", "clk", "0b0");
AFFECT ( "+0", "rst", "0b0");
AFFECT ( "+0","ldk", "0b1");

for (i=0; i < ps; i++)
{
  AFFECT ( "+0",  "key", fpt[i]);
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );

}

AFFECT ( "+0","ldk", "0b0");
AFFECT ( "+0",  "key", "0x0000000000000000");

for (; i < 0x2f; i++)
{
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
}

AFFECT ("+50", "clk", "0b1");

SAV_GENPAT ();
}


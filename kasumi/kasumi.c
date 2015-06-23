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
int ks,ps;
FILE *f1, *f2;
char *fname1 = "key.lst";
char *fname2 = "pt.lst";
char  key[0xff][0x4f];
char  fpt[0xff][0x4f];

/* remember argc start from 1 not zero and command line is the first array */
if (argc > 1 ) { 
  if (argc == 3) {
    fname1 = argv[2]; /* key */
    fname2 = argv[1]; /* plain text*/
    printf("Using plain-text (%s) key (%s)\n", fname2, fname1);
  } else {
    printf("Usage %s: plain-text key\n", argv[0]);
    return 0;
  }
}

if(fname1 && (f1 = fopen(fname1, "rt"))) {
  i = 0;
  while(fgets(key[i],sizeof(key[i]),f1) != NULL) {
    c = strlen(key[i]);
    if(key[i][c-1] == '\n') key[i][c-1] = '\0';
    i++;
  }
  fclose (f1);
} else {
  fclose (f1);
}

ks = i;

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

DEF_GENPAT("kasumi");
SETTUNIT("ns");

/* interface */
DECLAR ("clk", ":1", "B", IN , ""           , "" );
DECLAR ("rst", ":1", "B", IN , ""           , "" );
DECLAR ("ldpt",":1", "B", IN , ""           , "" );
DECLAR ( "pt", ":1", "X", IN , "31 downto 0", "" );
DECLAR ("ldk", ":1", "B", IN , ""           , "" );
DECLAR ("key", ":1", "X", IN , "63 downto 0", "" );
DECLAR (  "v", ":1", "B", OUT, ""           , "" );
DECLAR ( "ct", ":1", "X", OUT, "63 downto 0", "" );
//DECLAR ( "rnd_prb", ":2", "X", OUT, " 1 downto 0", "" );
//DECLAR (  "c3b_rst_prb", ":1", "B", OUT, ""           , "" );
//DECLAR (  "L_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR (  "R_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ( "ikey_prb", ":2", "X", OUT, "15 downto 0", "" );
//DECLAR ( "FL_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ( "FO_prb", ":2", "X", OUT, "15 downto 0", "" );
//DECLAR ( "FI_prb", ":2", "X", OUT, "15 downto 0", "" );
//DECLAR ("even_prb",":1", "B", OUT, ""           , "" );
//DECLAR ( "st_prb", ":2", "X", OUT, " 3 downto 0", "" );
DECLAR ("vss", ":1", "B", IN , ""           , "" );
DECLAR ("vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");

AFFECT (  "0",  "pt", "0x0000");
AFFECT (  "0", "key", "0x0000000000000000");
AFFECT (  "0", "rst", "0b1");
AFFECT (  "0","ldpt", "0b0");
AFFECT (  "0", "ldk", "0b0");
AFFECT (  "0", "clk", "0b0");
AFFECT ("+50", "clk", "0b1");
AFFECT ("+50", "clk", "0b0");
AFFECT ( "+0", "rst", "0b0");
AFFECT ( "+0","ldpt", "0b1");
AFFECT ( "+0", "ldk", "0b1");

for (i=0; i < ps; i++)
{
  AFFECT ( "+0",  "pt", fpt[i]);
  AFFECT ( "+0",  "key", key[i]);
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
}

AFFECT ( "+0","ldpt", "0b0");
AFFECT ( "+0", "ldk", "0b0");
AFFECT ( "+0",  "pt", "0x0000");
AFFECT ( "+0", "key", "0x0000000000000000");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );
/*
for (i=0; i < ks; i++)
{
  AFFECT ( "+0", "key", key[i]);
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
}

AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );
AFFECT ( "+0", "key", "0x0000");
*/
for (i=0; i < 0x50; i++)
{
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
}

AFFECT ("+50", "clk", "0b1");

SAV_GENPAT ();
}


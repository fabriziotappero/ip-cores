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
int Nk,ks,ps;
char sNk[4];
FILE *f1, *f2;
char *fname1 = "invkey.lst";
char *fname2 = "ct.lst";
char  key[80][20];
char  fpt[10][20];

Nk = 4;
/* remember argc start from 1 not zero and command line is the first array */
if (argc > 1 ) { 
  if (argc == 4) {
    fname1 = argv[3]; /* key */
    fname2 = argv[2]; /* plain text*/
    sscanf(argv[1], "%d", &Nk);
    printf("Using Nk(0x%x) cipher-text (%s) key (%s)\n", Nk, fname2, fname1);
  } else {
    printf("Usage %s: Nk cipher-text key\n", argv[0]);
    return 0;
  }
}

sprintf(sNk, "0x%x", Nk);

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

DEF_GENPAT("invcipher");
SETTUNIT("ns");

/* interface */
DECLAR ("clk", ":1", "B", IN , ""           , "" );
DECLAR ("rst", ":1", "B", IN , ""           , "" );
DECLAR ("ldct",":1", "B", IN , ""           , "" );
DECLAR ( "ct", ":2", "X", IN , "31 downto 0", "" );
//DECLAR ("cipher_inst_ildpt", ":1", "B", SIGNAL , ""           , "" );
//DECLAR ("cipher_inst_ipt"  , ":1", "X", SIGNAL , "31 downto 0", "" );
DECLAR ( "Nk", ":2", "X", IN , " 3 downto 0", "" );
//DECLAR ( "st", ":2", "X", OUT, " 7 downto 0", "" );
DECLAR ("key", ":2", "X", IN , "31 downto 0", "" );
DECLAR ( "pt", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ("cipher_inst_swp", ":1", "B", SIGNAL , ""           , "" );
DECLAR (  "v", ":1", "B", OUT, ""           , "" );
DECLAR ("invcipher_inst_rnd", ":1", "X", SIGNAL , "  3 downto 0"           , "" );
//DECLAR ( "sr_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ( "sb_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ( "mc_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ("ct2b_1", ":1", "B", SIGNAL , ""           , "" );
//DECLAR ("ct2b_0", ":1", "B", SIGNAL , ""           , "" );
//DECLAR ("invcipher_inst_wsb", ":1", "X", SIGNAL , "31 downto 0"           , "" );
//DECLAR ("invcipher_inst_ireg1", ":1", "X", SIGNAL , "127 downto 0"           , "" );
//DECLAR ("invcipher_inst_ireg2", ":1", "X", SIGNAL , "127 downto 0"           , "" );
//DECLAR ("cipher_inst_swp1", ":1", "B", SIGNAL , ""           , "" );
DECLAR ("vss", ":1", "B", IN , ""           , "" );
DECLAR ("vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");

AFFECT (  "0",  "ct", "0x00000000");
AFFECT (  "0", "key", "0x00000000");
AFFECT (  "0", "rst", "0b1");
AFFECT (  "0","ldct", "0b0");
AFFECT (  "0",  "Nk",  sNk );
AFFECT (  "0", "clk", "0b0");
AFFECT ("+50", "clk", "0b1");
AFFECT ("+50", "clk", "0b0");
AFFECT ( "+0", "rst", "0b0");
AFFECT ( "+0","ldct", "0b1");

for (i=0; i < ps; i++)
{
  AFFECT ( "+0",  "ct", fpt[i]);
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
  AFFECT ( "+0", "key", key[i]);

}

AFFECT ( "+0","ldct", "0b0");
AFFECT ( "+0",  "ct", "0x00000000");

for (; i < ks; i++)
{
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
  AFFECT ( "+0", "key", key[i]);
}

AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );
AFFECT ( "+0", "key", "0x00000000");

for (; i < 64; i++)
{
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
}

AFFECT ("+50", "clk", "0b1");

SAV_GENPAT ();
}


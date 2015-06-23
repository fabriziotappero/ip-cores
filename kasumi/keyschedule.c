#include <stdio.h>
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

main ()
{
int i,j;
int cur_vect = 0;

DEF_GENPAT("keyschedule");
SETTUNIT("ns");

/* interface */
DECLAR ("clk", ":1", "B", IN , ""           , "" );
DECLAR ("rst", ":1", "B", IN , ""           , "" );
DECLAR ("key", ":2", "X", IN ,"63  downto 0", "" );
DECLAR ( "st", ":2", "X", IN , "3  downto 0", "" );
DECLAR ("ildk",":1", "B", IN , ""           , "" );
//DECLAR ("keyreg1_prb", ":2", "X", OUT,"127 downto 0", "" );
//DECLAR ("keyreg2_prb", ":2", "X", OUT,"127 downto 0", "" );
DECLAR ("rk" , ":2", "X", OUT, "15 downto 0", "" ); 
//DECLAR ("y9" , ":2", "X", OUT, "8  downto 0", "" );
DECLAR ("vss", ":1", "B", IN , ""           , "" );
DECLAR ("vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");
AFFECT ("0", "rst", "0b1");
AFFECT ("0", "key", "0x0000000000000000");
AFFECT ("0",  "st", "0x0");
AFFECT ( "0","ildk","0b0");
AFFECT (  "0", "clk", "0b0");
AFFECT ("+10", "clk", "0b1");
AFFECT ("+10", "clk", "0b0");
AFFECT ( "+0", "rst", "0b0");
AFFECT ( "+0","ildk", "0b1");
AFFECT ("+0",  "key", "0x0011223344556677");
AFFECT ("+10", "clk", "0b1");
AFFECT ("+10", "clk", "0b0");
AFFECT ("+0",  "key", "0x8899aabbccddeeff");
AFFECT ("+10", "clk", "0b1");
AFFECT ("+10", "clk", "0b0");
AFFECT ( "+0","ildk", "0b0");
AFFECT ("+0",  "key", "0x0000000000000000");
for (j=0; j<0x004; j++)
for (i=0; i<0x010; i++)
{
  AFFECT ( "+0", "st", inttostr(i) );
  AFFECT ("+10", "clk", "0b1");
  AFFECT ("+10", "clk", "0b0");
  cur_vect++;
}

SAV_GENPAT ();
}


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
int i;

DEF_GENPAT("c6b");
SETTUNIT("ns");

/* interface */
DECLAR ("clk", ":1", "B", IN , ""           , "" );
DECLAR ("rst", ":1", "B", IN , ""           , "" );
DECLAR ("cnt", ":2", "X", OUT, "5  downto 0", "" );
DECLAR ("c6b.sum",":2","X",REGISTER,"5  downto 0","");
DECLAR ("c6b.cr" ,":2","X",SIGNAL  ,"5  downto 0","");
DECLAR ("vss", ":1", "B", IN , ""           , "" );
DECLAR ("vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");

AFFECT (  "0", "rst", "0b1");
AFFECT (  "0", "clk", "0b0");
AFFECT ("+10", "clk", "0b1");
AFFECT ("+10", "clk", "0b0");
AFFECT ( "+0", "rst", "0b0");

for (i=1; i<256; i++)
{
  AFFECT ("+10", "clk", "0b1" );
  AFFECT ("+10", "clk", "0b0" );
}


SAV_GENPAT ();
}


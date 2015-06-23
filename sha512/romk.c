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

main ()
{
int i;
int cur_vect = 0;

DEF_GENPAT("romk");
SETTUNIT("ns");

/* interface */
DECLAR ("addr",":2", "X", IN , "6  downto 0", "" );
DECLAR ("k"  , ":2", "X", OUT, "63 downto 0", "" );
DECLAR ("vss", ":1", "B", IN , ""           , "" );
DECLAR ("vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");
AFFECT ("0","addr", "0b000000");

for (i=1; i<0x80; i++) {
  AFFECT ("+10", "addr", inttostr(i%0x40) );
  cur_vect++;
}

SAV_GENPAT ();
}


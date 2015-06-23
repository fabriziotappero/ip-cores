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
int cur_vect = 0;

DEF_GENPAT("xtime_2");
SETTUNIT("ns");

/* interface */
DECLAR ("x2i", ":2", "X", IN , "7  downto 0", "" );
DECLAR ("x2o", ":2", "X", OUT, "7  downto 0", "" );
DECLAR ("vss", ":1", "B", IN , ""           , "" );
DECLAR ("vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");
AFFECT ("0", "x2i","0x00");

for (i=1; i<256; i++)
{
  AFFECT ("+10", "x2i", inttostr(i) );
  cur_vect++;
}


SAV_GENPAT ();
}


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

DEF_GENPAT("key");
SETTUNIT("ns");

/* interface */
DECLAR ("st" , ":2", "X", IN , " 7 downto 0", "" );
DECLAR ("Nk" , ":2", "X", IN , " 3 downto 0", "" );
DECLAR ("key", ":2", "X", OUT, "31 downto 0", "" );
DECLAR ("vss", ":1", "B", IN , ""           , "" );
DECLAR ("vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");

AFFECT (  "0",  "Nk", "0x4");
AFFECT (  "0",  "st", "0x0");
AFFECT ("+10",  "st", "0x0");

for (i=1; i<60; i++)
{
  AFFECT ("+10", "st", inttostr(i) );
  AFFECT ("+10", "st", inttostr(i) );
  cur_vect++;
}

AFFECT ("+10",  "Nk", "0x6");
AFFECT ("+10",  "st", "0x0");
AFFECT ("+20",  "st", "0x0");

for (i=1; i<60; i++)
{
  AFFECT ("+10", "st", inttostr(i) );
  AFFECT ("+10", "st", inttostr(i) );
  cur_vect++;
}

AFFECT ("+10",  "Nk", "0x8");
AFFECT ("+10",  "st", "0x0");
AFFECT ("+20",  "st", "0x0");

for (i=1; i<60; i++)
{
  AFFECT ("+10", "st", inttostr(i) );
  AFFECT ("+10", "st", inttostr(i) );
  cur_vect++;
}

SAV_GENPAT ();
}


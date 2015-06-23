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

DEF_GENPAT("sbox");
SETTUNIT("ns");

/* interface */
DECLAR ( "x" , ":2", "X", IN , "8  downto 0", "" );
DECLAR ("y7" , ":2", "X", OUT, "6  downto 0", "" ); 
DECLAR ("y9" , ":2", "X", OUT, "8  downto 0", "" );
DECLAR ("vss", ":1", "B", IN , ""           , "" );
DECLAR ("vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");
AFFECT ("0",  "x", "0b00000000");

for (i=1; i<0x200; i++)
{
  AFFECT ("+10", "x", inttostr(i) );
  cur_vect++;
}

SAV_GENPAT ();
}


// File Name    : reg01_pat.c
// Description  : Test Pattern for block register
// Author       : Sigit Dewantoro
// Date         : July 3rd, 2001

#include <stdio.h>
#include "genpat.h"

char *inttostr (entier)
int entier;
{
  char *str;
  str = (char *) mbkalloc (32 * sizeof (char));
  sprintf (str, "%d", entier);
  return (str);
}

main ()
{
  int i, j, k, l, m;
  int vect_date; /* this date is an absolute date, in ps */

  DEF_GENPAT ("reg01");

  SETTUNIT ("ns");

  /* interface */
  DECLAR ("vdd", ":2", "B", IN, "", "");
  DECLAR ("vss", ":2", "B", IN, "", "");
  DECLAR ("a", ":2", "B", IN, "", "");
  DECLAR ("rst", ":2", "B", IN, "", "");
  DECLAR ("en", ":2", "B", IN, "", "");
  DECLAR ("b", ":2", "B", OUT, "", "");
  DECLAR ("c", ":2", "B", OUT, "", "");

  LABEL ("pat");
  AFFECT ("0", "vss", "0b0");
  AFFECT ("0", "vdd", "0b1");


  for (i=0; i<2; i++)
    for (j=0; j<2; j++)
    for (k=0; k<2; k++)
    for (l=0; l<2; l++)
    {
      vect_date = ((i*2 + j)*2 + k);
      AFFECT (inttostr(vect_date), "a", inttostr(i));
      AFFECT (inttostr(vect_date), "rst", inttostr(j));
      AFFECT (inttostr(vect_date), "en", inttostr(k));
    }

  vect_date = vect_date + 1;
  AFFECT (inttostr(vect_date), "vss", "0b0");
  AFFECT (inttostr(vect_date), "a", "0b0");
  AFFECT (inttostr(vect_date), "rst", "0b0");
  AFFECT (inttostr(vect_date), "en", "0b0");

  SAV_GENPAT ();
}

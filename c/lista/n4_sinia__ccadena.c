#include "tipodef.h"

n4 n4_sinia__ccadena(char *ccadena)
{
 n4 sinia=0;
 n1 c;

 while ((c = *ccadena++) != 0)
 {
  sinia ^=  ((n4)(c)<<11) ^ (sinia << 7);
  sinia ^=  ((n4)(c)) ^ (sinia >> 17);
  sinia ^=  ((n4)(c)<<4) ^ (sinia << 11);
 }

 return sinia;
}
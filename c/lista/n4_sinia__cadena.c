#include "tipodef.h"

n4 n4_sinia__cadena(n1 *cadena, nN cuantia)
{
 n4 sinia=0;
 nN indise=0;
 n1 c;
 
 for (indise=0;indise<cuantia; indise++)
 {
  c=cadena[indise];
  sinia ^=  ((n4)(c)<<11) ^ (sinia << 7);
  sinia ^=  ((n4)(c)) ^ (sinia >> 17);
  sinia ^=  ((n4)(c)<<4) ^ (sinia << 11);
 }

 return sinia;
}
#include "tipodef.h"

n8 n8_sinia__cadena(n1 *cadena,nN cuantia)
{
 n8 sinia=0;
 nN indise=0;
 n1 c;
 
 for (indise=0;indise<cuantia; indise++)
 {
  c=cadena[indise];
  sinia ^=  ((n8)(c)<<31) ^ (sinia << 7);
  sinia ^=  ((n8)(c)) ^ (sinia >> 17);
  sinia ^=  ((n8)(c)<<3) ^ (sinia << 31);
 }

 return sinia;
}
#include "tipodef.h"

n8 n8_sinia__ccadena(char *ccadena)
{
 n8 sinia=0;
 n1 c;

 while ((c = *ccadena++) != 0)
 {
  sinia ^=  ((n8)(c)<<31) ^ (sinia << 7);
  sinia ^=  ((n8)(c)) ^ (sinia >> 17);
  sinia ^=  ((n8)(c)<<3) ^ (sinia << 31);
 }

 return sinia;
}
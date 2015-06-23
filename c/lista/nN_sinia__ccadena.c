#include "lista.h"

nN nN_sinia__ccadena(char *ccadena)
{
 nN sinia = 0;
 n1 c;

 while ((c = *ccadena++) != 0)
 {
  sinia <<= 2;
  sinia ^=  c | (sinia << 8);
 }

 return sinia;
}
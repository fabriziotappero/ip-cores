#include "lista.h"

nN nN_sinia__cadena(n1 *cadena, nN cuantia)
{
 nN sinia=0;
 nN indise=0;
 
 while (indise<cuantia)
 {
  sinia <<= 2;
  sinia ^=  cadena[indise++] | (sinia << 8);
 }

 return sinia;
}
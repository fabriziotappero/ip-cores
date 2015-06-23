#include "lista.h"

nN nN_sinia__lista(struct lista *esta)
{
 n1 *cadena=esta->datos;
 nN cuantia=esta->contador;
 nN sinia=0;
 nN indise=0;
 
 while (indise<cuantia)
 {
  sinia <<= 2;
  sinia ^=  cadena[indise++] | (sinia << 8);
 }

 return sinia;
}
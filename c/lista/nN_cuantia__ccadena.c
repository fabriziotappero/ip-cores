#include "tipodef.h"

nN nN_cuantia__ccadena(char * ccadena)
{
 nN conta = 0;
 
 while (ccadena[conta]!=0)
 {
  conta++;
 }
 
 return conta;
}
#include "tipodef.h"

n8 n8__exadesimal_cadena(n1 * cadena, nN cuantia)
{
 n8 valua = 0;
 n1 c;
 nN i = 0;
  
 while(i<cuantia)
 {
  c = cadena[i++];
  if(c>0x39) c+=0x09;
  valua |= (c&0x0f);
  if(i<cuantia) valua <<= 4;
 }
  
 return valua;
}
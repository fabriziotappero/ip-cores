#include "lista.h"

n4 n4__ccadenaexadesimal(char * a)
{
 nN cuantia = nN_cuantia__ccadena(a);
 n4 binaria = 0;
 n1 c;
 nN i = 0;
 
 while(cuantia>0)
 {
  c = a[i++];
  c = (c>0x39) ? c : c+0x09;
  binaria |= (c&0x0f);
  binaria <<= 4;
 }
 
 return binaria;
}
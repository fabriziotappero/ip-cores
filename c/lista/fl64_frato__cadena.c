#include "tipodef.h"

fl2 fl2_frato__cadena(n1 *cadena, nN cuantia)
{
 fl2 fl=0.0;
 n1 c;
 nN i;
 
 if (cuantia>0)
 {
  fl=(fl2)(cadena[--cuantia]&0x0f)*0.1;
  
  for (i=--cuantia;i>=0;i--)
  {
   fl=(fl+(fl2)(cadena[i]&0x0f))*0.1;
  }
 }

 return fl;
}
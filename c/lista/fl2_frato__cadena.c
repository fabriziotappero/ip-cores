#include "tipodef.h"

fl2 fl2_frato__cadena(n1 *cadena, nN cuantia)
{
 fl2 fl=0.0;
 nN i;
 
 if (cuantia>0)
 {
  
  for(i=0;i<cuantia;i++){fl=(fl*10.0)+(fl2)(cadena[i]&0x0f);}
  for(i=0;i<cuantia;i++){fl*=0.1; }
 }

 return fl;
}
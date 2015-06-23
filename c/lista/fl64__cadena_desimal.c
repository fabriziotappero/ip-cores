#include "tipodef.h"

fl64 fl64__cadena_desimal(n1 *cadena, nN cuantia)
{
 fl64 fl=0.0;
 nN i;
 
 if (cuantia>0)
 {
//  fl=cadena[--cuantia]&0x0f;
  
  for(i=0;i<cuantia;i++)
  {
   fl=(fl*10);//+(fl64)(cadena[i]&0x0f);
  }
 }
 fl=0.1;
 return 1.1;
}

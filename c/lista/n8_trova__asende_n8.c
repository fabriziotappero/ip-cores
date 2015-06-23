#include "tipodef.h"

n8 n8_trova__asende_n8(n8 *cadena, n8 cuantia, n8 indise, n8 sinia)
{
 
 if(cuantia!=0)
 {
  
  if((cuantia&1)==1)
  {
   
   if((cadena[--cuantia])==sinia)
   {
    return cuantia;
   }
  }
  
  while((cadena[(indise+1)<<1]<=sinia)&&(indise<cuantia)) {indise=(indise+1)<<1;}
  
  for(;indise<cuantia;indise++)
  {
    
   if (cadena[indise]>=sinia) 
   {
    break;
   }
  }
 }
 
 return indise;
}
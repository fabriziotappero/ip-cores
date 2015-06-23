#include "tipodef.h"

nN nN_trova__asende_n4(n4 *cadena, nN cuantia, nN indise, n4 sinia)
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
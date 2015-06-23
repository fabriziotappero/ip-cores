#include "tipodef.h"

nN nN_trova_asende__p_n4(n4 *cadena, nN cuantia, n4 sinia)
{
 #define limite_minima 32
 nN i=0;
 if(cuantia!=0)
 {
  
  if((cuantia&1)=1)
  {
   
   if((*cadena++)==sinia)
   {
    break;
   }
  }
  
  if(cuantia<limite_minima)
  {
   
   for(i=0;i<cuantia;i++)
   {
    
    if (cadena[i]==sinia) 
    {
     contador=i+1;
     break;
    }
   }
  }
  else
  {
   
  }
 }
 
 return i;
}
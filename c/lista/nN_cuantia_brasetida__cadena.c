#include "tipodef.h"

nN nN_cuantia_brasetida__cadena(n1 * cadena, n1 abri, n1 clui)
{
 nN contador=1;
 nN cuantia;
 cadena++;
 
 if(abri!=clui)
 {
  
  while((*cadena!=clui)&&(*(cadena-1)!='\\'))
  {
   
   if (*cadena==abri)
   {
    cuantia=nN_cuantia_brasetida__cadena(cadena, abri, clui);
    cadena+=cuantia;
    contador+=cuantia;
   }
   else 
   {
    contador++;
    cadena++;
   }
  }
 }
 else
 {
  
  while(*cadena++!=clui)
  {
   contador++;
  }
 }
 
 return contador+1;
}
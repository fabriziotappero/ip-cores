#include "tipodef.h"

#include <stdio.h>

void debug_out(n1 *cadena,nN cuantia);

fl2 fl2__cadena(n1 *cadena,nN cuantia)
{
 n1 sinia_entero=0,sinia_potia=0;
 if (*cadena=='-') { cadena++; cuantia--; sinia_entero=1; }
 n1 *cadena_frato=0,*cadena_potia=0;
 nN cuantia_cadena_frato,cuantia_cadena_entero,cuantia_cadena_potia;
 nN indise;
  
 for(indise=0;indise<cuantia;indise++) 
 { 
  if(cadena[indise]=='.'){cadena_frato=cadena+indise+1; break;} 
 }
 
 if (cadena_frato!=0)
 {
  for(cuantia_cadena_frato=0;cuantia_cadena_frato<(cuantia-(cadena_frato-cadena));cuantia_cadena_frato++)
  { 
   if(cadena_frato[cuantia_cadena_frato]=='E') 
   { 
    cadena_potia=cadena_frato+cuantia_cadena_frato+1;
    if(*cadena_potia=='-') { cadena_potia++; sinia_potia=1; }
    cuantia_cadena_potia=cuantia-(cadena_potia-cadena);
    break; 
   }
  }
 }
 
 cuantia_cadena_entero=-(cadena-cadena_frato)-1;
 cuantia_cadena_entero=3;
 fl2 fl=0.0;
 fl=fl2__cadena_desimal(cadena,cuantia_cadena_entero);
 printf("%f\n",fl);
 return fl;
}

void debug_out(n1 *cadena,nN cuantia)
{
 nN i;
 for(i=0;i<cuantia;i++)
 {
  putchar(cadena[i]);
 }
}

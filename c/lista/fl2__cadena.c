#include "tipodef.h"

fl2 fl2__cadena(n1 *cadena,nN cuantia)
{
 if(cuantia==0) return 0.0;
 n1 sinia_entero=0,sinia_potia=0;
 if (*cadena=='-') { cadena++; cuantia--; sinia_entero=1; }
 n1 *cadena_frato=0,*cadena_potia=0;
 nN cuantia_cadena_frato=0,cuantia_cadena_entero=cuantia,cuantia_cadena_potia=0;
 nN indise;
  
 for(indise=0;indise<cuantia;indise++) 
 { 
  if(cadena[indise]=='.'){cadena_frato=cadena+indise+1; cuantia_cadena_entero=indise; break;} 
 }
 
 if (cadena_frato!=0)
 {
  for(cuantia_cadena_frato=0;cuantia_cadena_frato<(cuantia-(cadena_frato-cadena));cuantia_cadena_frato++)
  { 
   if((cadena_frato[cuantia_cadena_frato]|0x20)=='e') 
   { 
    cadena_potia=cadena_frato+cuantia_cadena_frato+1;
    if(*cadena_potia=='-') { cadena_potia++; sinia_potia=1; }
    cuantia_cadena_potia=cuantia-(cadena_potia-cadena);
    break; 
   }
  }
 }
  
 fl2 fl=0.0;
 sN potia=0;
 sN i;
 for(i=0;i<cuantia_cadena_entero;i++){ fl=(fl*10.0)+(fl2)(cadena[i]&0x0f); }
 for(i=0;i<cuantia_cadena_frato;i++){ fl=(fl*10.0)+(fl2)(cadena_frato[i]&0x0f); }
 if(sinia_entero!=0){ fl*=-1.0; }
 for(i=0;i<cuantia_cadena_potia;i++){ potia=(potia*10)+(cadena_potia[i]&0x0f); }
 if(sinia_potia!=0){ potia=-potia; }
 potia-=cuantia_cadena_frato;
 for(i=0;i<potia;i++){ fl*=10.0; }
 for(i=0;i>potia;i--){ fl*=0.1; }
 return fl;
}
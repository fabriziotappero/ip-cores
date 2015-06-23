#include "tipodef.h"

nN nN__desimal_cadena(n1 *cadena, nN cuantia)
{
 nN valua=0;
 nN i;
 n1 negativa=0;
 
 if (*cadena=='-')
 {
  negativa=1;
  cadena++;
 }
 
 if(cuantia>0)
 {
  valua=(*cadena++)&0x0f; cuantia--;
  
  for(i=0;i<cuantia;i++)
  {
   valua=(valua<<3)+(valua<<1)+((*cadena++)&0x0f);
  }
 }
 
 if(negativa!=0)
 {
  valua=(valua^(-1))+1; 
 }
 
 return valua;
}
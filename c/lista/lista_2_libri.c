#include "lista.h"

void lista_2_libri(struct lista *esta)
{
 
 if(esta!=0)
 {
  nN i;
  for(i=0;i<(esta->contador/sizeof(P));i++) 
  {
  
   if(((struct lista **)(esta->datos))[i]!=0)
   {
    lista_libri(((struct lista **)(esta->datos))[i]);
   }
  }
 }
 
 lista_libri(esta);
}
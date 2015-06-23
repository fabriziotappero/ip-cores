#include "cpu_1664.h"

void cpu_1664_dev_dev_libri(struct lista *lista_dev)
{
 
 if(lista_dev!=0)
 {
  
  if(((struct lista **)(lista_dev->datos))[0]!=0)
  {
   lista_libri(((struct lista **)(lista_dev->datos))[0]);
  }
  lista_2_libri(((struct lista **)(lista_dev->datos))[1]);
  lista_2_libri(((struct lista **)(lista_dev->datos))[2]);
  lista_libri(lista_dev);
 }
}
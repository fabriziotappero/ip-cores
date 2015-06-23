#include "lista.h"

void lista_libri(struct lista *esta)
{
 
 if(esta!=0)
 {
  memoria_libri((P)esta->datos);
  memoria_libri((P)esta);
 }
}
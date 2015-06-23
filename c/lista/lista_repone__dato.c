#include "lista.h"

void lista_repone__dato(struct lista *esta,n1 dato,nN indise)
{
 if (indise<esta->contador)
 {
  esta->datos[indise]=dato;
 }
}
#include "lista.h"

void lista_sutrae__datos(struct lista *esta,nN indise,nN cuantia)
{
 if((indise+cuantia)<esta->contador)
 {
  memoria_copia((P)(esta->datos+indise),(P)(esta->datos+indise+cuantia),cuantia);
  esta->contador-=cuantia;
 }
}
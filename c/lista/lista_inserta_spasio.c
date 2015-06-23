#include "lista.h"

void lista_inserta_spasio(struct lista *esta,nN indise,nN cuantia)
{
 if (indise<=esta->contador)
 {
  if (indise!=esta->contador) lista_crese(esta,cuantia);
  memoria_move((P)(esta->datos+indise+cuantia),(P)(esta->datos+indise),esta->contador-indise);
  esta->contador=+cuantia;
 }
}
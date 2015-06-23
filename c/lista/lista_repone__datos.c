#include "lista.h"

void lista_replace__datos(struct lista *esta,n1 *datos,nN cuantia,nN indise)
{
 
 if (indise<esta->contador)
 {
  if (esta->contador<(indise+cuantia)) lista_crese(esta,(indise+cuantia)-esta->contador);
  memoria_copia((P)(esta->datos+indise),(P)datos,cuantia);
 }
}
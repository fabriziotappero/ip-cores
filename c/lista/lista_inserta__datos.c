#include "lista.h"

void lista_inserta__datos(struct lista *esta,n1 *datos,nN cuantia,nN indise)
{
 lista_inserta_capasia(esta,indise,cuantia);
 memoria_copia((P)(esta->datos+indise),(P)datos,cuantia);
}
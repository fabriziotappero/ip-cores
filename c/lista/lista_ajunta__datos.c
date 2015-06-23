#include "lista.h"

void lista_ajunta__datos(struct lista *esta,n1 *datos,nN cuantia)
{
 lista_crese(esta,cuantia);
 memoria_copia((P)(esta->datos+esta->contador),(P)datos,cuantia);
 esta->contador+=cuantia;
}
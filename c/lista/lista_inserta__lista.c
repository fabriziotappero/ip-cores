#include "lista.h"

void lista_inserta__lista(struct lista *esta,struct lista *nova,nN indise)
{
 lista_inserta_capasia(esta,indise,nova->contador);
 memoria_copia((P)(esta->datos+indise),(P)nova->datos,nova->contador);
 esta->contador=+nova->contador;
}
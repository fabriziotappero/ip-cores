#include "lista.h"

void lista_inserta__dato(struct lista *esta,n1 dato,nN indise)
{
 lista_inserta_capasia(esta,indise,1);
 esta->datos[indise]=dato;
}
#include "lista.h"

void lista_inserta__n4(struct lista *esta, n4 dato, nN indise)
{
 lista_inserta_capasia(esta,indise,sizeof(n4));
 *(n4 *)(esta->datos+indise)=dato;
}
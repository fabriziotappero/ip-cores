#include "lista.h"

void lista_inserta__P(struct lista *esta,P dato,nN indise)
{
 lista_inserta_capasia(esta,indise,sizeof(P));
 *(P *)(esta->datos+indise)=dato;
}
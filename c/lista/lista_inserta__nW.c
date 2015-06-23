#define lista_fonte
#include "lista.h"

void lista_insert__P(struct lista *esta,P dato,nN indise)
{
 lista_insert_spasio(esta,indise,sizeof(P));
 *(esta->datos+indise)=dato;
}
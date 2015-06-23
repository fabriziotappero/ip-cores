#include "lista.h"

void lista_ajunta__P(struct lista *esta,P dato)
{
 lista_crese(esta,sizeof(P));
 *(P *)(esta->datos+esta->contador)=dato;
 esta->contador+=sizeof(P);
}
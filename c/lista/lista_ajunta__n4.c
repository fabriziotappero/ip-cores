#include "lista.h"

void lista_ajunta__n4(struct lista *esta,n4 dato)
{
 lista_crese(esta, sizeof(n4));
 *(n4 *)(esta->datos+esta->contador)=dato;
 esta->contador+=sizeof(n4);
}
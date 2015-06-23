#include "lista.h"

void lista_ajunta__n2(struct lista *esta,n2 dato)
{
 lista_crese(esta, sizeof(n2));
 *(n2 *)(esta->datos+esta->contador)=dato;
 esta->contador+=sizeof(n2);
}
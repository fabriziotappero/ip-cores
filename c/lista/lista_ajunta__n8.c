#include "lista.h"

void lista_ajunta__n8(struct lista *esta,n8 dato)
{
 lista_crese(esta, sizeof(n8));
 *(n8 *)(esta->datos+esta->contador)=dato;
 esta->contador+=sizeof(n8);
}
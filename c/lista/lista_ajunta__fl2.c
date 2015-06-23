#include "lista.h"

void lista_ajunta__fl2(struct lista *esta,fl2 dato)
{
 lista_crese(esta,sizeof(fl2));
 *(fl2 *)(esta->datos+esta->contador)=dato;
 esta->contador+=sizeof(fl2);
}
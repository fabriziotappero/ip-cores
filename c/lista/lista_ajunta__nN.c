#include "lista.h"

void lista_ajunta__nN(struct lista *esta,nN dato)
{
 lista_crese(esta,sizeof(nN));
 *(nN *)(esta->datos+esta->contador)=dato;
 esta->contador+=sizeof(nN);
}
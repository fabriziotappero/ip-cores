#include "lista.h"

P lista_P_final(struct lista *esta)
{
 return (esta->contador>=sizeof(P)) ? *(P *)(esta->datos+esta->contador-sizeof(P)) : 0;
}
#include "lista.h"

void lista_defini__crese(struct lista *esta,nN crese)
{
 crese+=0x10; crese&=-0x10;
 esta->crese=(crese > lista_minima_crese) ? crese : lista_minima_crese;
}


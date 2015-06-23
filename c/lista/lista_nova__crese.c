#include "lista.h"

struct lista* lista_nova__crese(nN cuantia, nN crese)
{
 crese+=0x10; crese&=-0x10;
 nN nova_cuantia = (cuantia > lista_minima_cuantia) ? cuantia : lista_minima_cuantia;
 struct lista *esta = (struct lista *)memoria_nova(sizeof(struct lista));
 esta->datos=(n1 *)memoria_nova(nova_cuantia);
 esta->capasia=nova_cuantia;
 esta->contador=0;
 esta->crese=(crese > lista_minima_crese) ? crese : lista_minima_crese;
 return esta;
}


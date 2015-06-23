#include "lista.h"

struct lista* lista_nova__ccadena(char *ccadena)
{
 nN cuantia = 0; while (ccadena[cuantia]!=0){cuantia++;}
 nN nova_cuantia = (cuantia > lista_minima_cuantia) ? cuantia : lista_minima_cuantia;
 struct lista *esta = (struct lista *)memoria_nova(sizeof(struct lista));
 esta->datos=(n1 *)memoria_nova(nova_cuantia);
 esta->capasia=nova_cuantia;
 esta->contador=cuantia;
 memoria_copia((P)esta->datos,(P)ccadena,cuantia);
 esta->crese=lista_minima_crese;
 return esta;
}


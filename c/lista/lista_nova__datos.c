#include "lista.h"

struct lista* lista_nova__datos(n1 *datos, nN cuantia)
{
 struct lista *esta=0;
 
 if (cuantia>0)
 {
  nN nova_cuantia = (cuantia > lista_minima_cuantia) ? cuantia : lista_minima_cuantia;
  esta = (struct lista *)memoria_nova(sizeof(struct lista));
  esta->datos=(n1 *)memoria_nova(nova_cuantia);
  esta->capasia=nova_cuantia;
  esta->contador=cuantia;
  memoria_copia((P)esta->datos,(P)datos,cuantia);
  esta->crese=lista_minima_crese;
 }
 
 return esta;
}


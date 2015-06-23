#include "lista.h"

struct lista* lista_2_nova__lista_2(struct lista *lista)
{
 nN cuantia=lista->contador/sizeof(P);
 struct lista *esta=lista_nova(cuantia);
 
 nN i;
 for(i=0;i<cuantia;i++)
 {
  lista_ajunta__P(esta, (P)lista_nova__datos(((struct lista **)(lista->datos))[i]->datos,((struct lista **)(lista->datos))[i]->contador));
 }
 
 return esta;
}


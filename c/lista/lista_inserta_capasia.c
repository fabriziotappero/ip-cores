#include "lista.h"

void lista_inserta_capasia(struct lista *lista, nN indise, nN cuantia)
{
 
 if (indise<=lista->contador)
 {
  lista_crese(lista, cuantia);
  lista->contador+=cuantia;
  memoria_move((lista->datos+indise+cuantia),(lista->datos+indise),lista->contador-indise);
 }
 else
 {
  lista_crese(lista, cuantia);
 }
}
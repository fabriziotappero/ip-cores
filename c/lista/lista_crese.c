#include "lista.h"

void lista_crese(struct lista *lista, nN capasia_crese)
{
 nN capasia_disponable = lista->capasia-lista->contador;
  
 if (capasia_crese > capasia_disponable) 
 {
  // contrato de crese
  lista->capasia=(lista->capasia-capasia_disponable)+capasia_crese+lista->crese;
  lista->datos=(n1 *)memoria_crese(lista->datos, lista->capasia);
 }
}
#include "lista.h"

void lista_ajunta__dato(struct lista *lista, n1 dato)
{
 lista_crese(lista, 1);
 lista->datos[lista->contador]=dato;
 lista->contador+=1;
}
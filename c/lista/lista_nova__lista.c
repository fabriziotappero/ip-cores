#include "lista.h"

struct lista* lista_nova__lista(struct lista *lista)
{
 return lista_nova__datos(lista->datos, lista->contador);
}


#define lista_fonte
#include "lista.h"

n1 * lista_datos_final(struct lista *esta,nN cuantia)
{
 return (esta->contador>=cuantia) ? esta->datos+esta->contador-cuantia : 0;
}
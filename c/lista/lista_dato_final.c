#define lista_fonte
#include "lista.h"

n1 lista_dato_final(struct lista *esta)
{
 return (esta->contador>=sizeof(n1)) ? esta->datos[esta->contador-sizeof(n1)] : 0;
}
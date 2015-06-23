#define lista_fonte
#include "lista.h"

n1 * lista_pone__dato(struct lista *esta,n1 dato,nN indise)
{
 if (indise>esta->contador) lista_crese(esta,indise-esta->contador);
 esta->datos[indise]=dato;
}
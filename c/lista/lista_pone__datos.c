#define lista_fonte
#include "lista.h"

n1 * lista_write__datos(struct lista *esta,n1 *datos,nN cuantia,nN indise)
{
 if ((indise+cuantia)>esta->contador) lista_crese(esta,(indise+cuantia)-esta->contador);
 memoria_copia((P)(esta->datos+indise),(P)datos,indise);
}
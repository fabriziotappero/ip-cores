#include "cpu_1664.h"

struct lista * cpu_1664_dev_opera_parametre_funsiona__8e(struct cpu_1664 * cpu, n1 bait)
{
 struct lista *lista_2=lista_nova(0);
 struct lista *lista_parametre=lista_nova(0);
 struct lista *lista_informa=lista_nova(0);
 
 lista_ajunta_asciiexadesimal__n1(lista_parametre, bait);
 
 lista_ajunta__P(lista_2, (P)lista_parametre);
 lista_ajunta__P(lista_2, (P)lista_informa);
 return lista_2;
}
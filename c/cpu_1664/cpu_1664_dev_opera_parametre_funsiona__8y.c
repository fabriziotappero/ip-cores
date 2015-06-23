#include "cpu_1664.h"

struct lista * cpu_1664_dev_opera_parametre_funsiona__8y(struct cpu_1664 * cpu, n1 bait)
{
 struct lista *lista_2=lista_nova(0);
 struct lista *lista_parametre=lista_nova(0);
 struct lista *lista_informa=lista_nova(0);
 
 cpu_1664_sinia_t desloca;
 n1 valua=bait&0x7f;
 n1 negativa=(bait>0x80);
 n1 valua_negativa=-bait;
 
 if (negativa) 
 {
  lista_ajunta__dato(lista_parametre, '-');
  lista_ajunta_asciiexadesimal__n1(lista_parametre, valua_negativa);
 }
 else
 {
  lista_ajunta_asciiexadesimal__n1(lista_parametre, valua);
 }
 
 desloca= (negativa) ? cpu->sinia[cpu_1664_sinia_IP]-(valua_negativa<<1) : cpu->sinia[cpu_1664_sinia_IP]+(valua<<1);
 lista_ajunta_asciiexadesimal__n8(lista_informa, desloca);
 
 lista_ajunta__P(lista_2, (P)lista_parametre);
 lista_ajunta__P(lista_2, (P)lista_informa);
 return lista_2;
}
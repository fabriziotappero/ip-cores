#include "cpu_1664.h"

struct lista * cpu_1664_dev_opera_parametre_funsiona__m(struct cpu_1664 * cpu, n1 bait)
{
 struct lista *lista_2=lista_nova(0);
 struct lista *lista_parametre=lista_nova(0);
 struct lista *lista_informa=lista_nova(0);
 
 nN sinia=(bait&((1<<cpu_1664_opera_ldm_sinia)-1));
 n1 ajusta=(bait&(1<<cpu_1664_opera_ldm_bitio_ajusta))!=0;
 n1 ordina=(bait&(1<<cpu_1664_opera_ldm_bitio_ordina))!=0;
 n1 orienta=(bait&(1<<cpu_1664_opera_ldm_bitio_orienta))!=0;
 n1 estende=1<<((bait&(3<<cpu_1664_opera_ldm_bitio_estende0))>>cpu_1664_opera_ldm_bitio_estende0);
 
 n1 estende_c=(estende|'0');
 n1 orienta_c=(orienta==0) ? '-' : '+';
 
 lista_ajunta__dato(lista_parametre, '[');
 
 if(ajusta&&!ordina)
 {
  lista_ajunta__dato(lista_parametre, orienta_c);
 }
 
 lista_ajunta__dato(lista_parametre, sinia|'0');
 
 if(ajusta&&ordina)
 {
  lista_ajunta__dato(lista_parametre, orienta_c);
 }
 
 lista_ajunta__dato(lista_parametre, ']');
 
 if(estende!=0)
 {
  lista_ajunta__dato(lista_parametre, ' ');
  lista_ajunta__dato(lista_parametre, estende_c);
 }
 
 lista_ajunta__P(lista_2, (P)lista_parametre);
 lista_ajunta__P(lista_2, (P)lista_informa);
 return lista_2;
}
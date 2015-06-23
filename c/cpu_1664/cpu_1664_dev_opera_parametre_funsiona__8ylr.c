#include "cpu_1664.h"

struct lista * cpu_1664_dev_opera_parametre_funsiona__8ylr(struct cpu_1664 * cpu, n1 bait)
{
 struct lista *lista_2=lista_nova(0);
 struct lista *lista_parametre=lista_nova(0);
 struct lista *lista_informa=lista_nova(0);
 
 n1 A=bait&((1<<cpu_1664_bitio_r)-1);
 n1 B=bait>>cpu_1664_bitio_r;
 n1 bool_indise=B>2;
 n1 bool_nondireta=B&1;
 
 if(bool_nondireta!=0)
 {
  lista_ajunta__dato(lista_parametre, '[');
 }
 if(bool_indise!=0)
 {
  lista_ajunta__dato(lista_parametre, '+');
 }
 lista_ajunta_asciiexadesimal__n1(lista_parametre, A);
 if(bool_nondireta!=0)
 {
  lista_ajunta__dato(lista_parametre, ']');
 }
 
 if(bool_indise!=0)
 {
  lista_ajunta_asciiexadesimal__n8(lista_informa, cpu->sinia[A]+cpu->sinia[cpu_1664_sinia_IP]);
 }
 else
 {
  lista_ajunta_asciiexadesimal__n8(lista_informa, cpu->sinia[A]);
 }
 
 lista_ajunta__P(lista_2, (P)lista_parametre);
 lista_ajunta__P(lista_2, (P)lista_informa);
 return lista_2;
}
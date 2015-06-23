#include "cpu_1664.h"

struct lista * cpu_1664_dev_opera_parametre_funsiona__3e3e2e(struct cpu_1664 * cpu, n1 bait)
{

 char opera_eor[]={"eor"};
 char opera_and[]={"and"};
 char opera_or[]={"or"};
 char opera_cam[]={"cam"};
 char *opera[4]={opera_eor,opera_and,opera_or,opera_cam};
 
 struct lista *lista_2=lista_nova(0);
 struct lista *lista_parametre=lista_nova(0);
 struct lista *lista_informa=lista_nova(0);
 
 n1 A=bait&0x07;;
 n1 B=(bait>>3)&0x07;;
 n1 C=bait>>6; 
 
 lista_ajunta_asciiexadesimal__n1(lista_parametre, A);
 lista_ajunta__dato(lista_parametre, ' ');
 lista_ajunta_asciiexadesimal__n1(lista_parametre, B);
 lista_ajunta__dato(lista_parametre, ' ');
 lista_ajunta_asciiexadesimal__n1(lista_parametre, C);
 
 if(C<3)
 {
  lista_ajunta__dato(lista_informa, (cpu->depende[A]!=0)|'0');
  lista_ajunta__dato(lista_informa, ' ');
  lista_ajunta__ccadena(lista_informa, opera[C]);
  lista_ajunta__dato(lista_informa, ' ');
  lista_ajunta__dato(lista_informa, (cpu->depende[B]!=0)|'0');
 }
 else
 {
 lista_ajunta__dato(lista_informa, (cpu->depende[A]!=0)|'0');
 lista_ajunta__ccadena(lista_informa, " -> <- ");
 lista_ajunta__dato(lista_informa, (cpu->depende[B]!=0)|'0');
 }
 
 lista_ajunta__P(lista_2, (P)lista_parametre);
 lista_ajunta__P(lista_2, (P)lista_informa);
 return lista_2;
}
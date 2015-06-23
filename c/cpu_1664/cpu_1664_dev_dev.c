#include "cpu_1664.h"

#define cadena_nd "<no definida>"
/*
  {
   {{?depende} {opera} {p}..{p}}
   {{depende} {opera_desifri_cadena}}
   {{dev_parametre} {dev_informa}}
  }
*/
struct lista * cpu_1664_dev_dev(struct cpu_1664 * cpu, cpu_1664_sinia_t desloca, cpu_1664_opera_t parola)
{
 struct lista *lista_dev=lista_nova(0);
 n1 opera_sifri=parola&((1<<cpu_1664_bitio_opera)-1);
 n1 opera_desifri=cpu->opera_ajusta[opera_sifri]&0x7f;
 n1 depende=(parola>>cpu_1664_bitio_opera)&((1<<(8-cpu_1664_bitio_opera))-1)*(opera_desifri!=0);
 n1 parametre=parola>>8;
 nN indise=n8_trova__asende_n8((n8 *)cpu->lista_dev_asm_desloca->datos,cpu->lista_dev_asm_desloca->contador/sizeof(n8), 0, desloca);
 
 if(cpu->lista_dev_asm_desloca->contador!=0)
 {
  
  if(((n8 *)(cpu->lista_dev_asm_desloca->datos))[indise]==desloca)
  {
   lista_ajunta__P(lista_dev, (P)lista_nova__lista(((struct lista **)(cpu->lista_dev_asm_cadena->datos))[indise]));
  }
  else
  {
   lista_ajunta__P(lista_dev, 0);
  }
 }
 else
 {
  lista_ajunta__P(lista_dev, 0);
 }
 
 {//{{cadena_depende}{cadena_opera}}
  struct lista *lista_opera=lista_nova(0);
  struct lista *lista_opera_depende=lista_nova(0);
  struct lista *lista_opera_opera=lista_nova(0);
  
  lista_ajunta__P(lista_dev, (P)lista_opera);
  lista_ajunta__P(lista_opera, (P)lista_opera_depende);
  lista_ajunta__P(lista_opera, (P)lista_opera_opera);
  
  if(opera_desifri<(cpu->lista_dev_opera_cadena->contador/sizeof(P)))
  {
   lista_ajunta__lista(lista_opera_opera, ((struct lista **)(cpu->lista_dev_opera_cadena->datos))[opera_desifri]);
  }
  else
  {
   lista_ajunta__ccadena(lista_opera_opera, ".do 0x");
   lista_ajunta_asciiexadesimal__n2(lista_opera_opera, parola);
  }
  
  if((depende!=cpu_1664_depende_1)&&(opera_desifri!=0))
  {
   lista_ajunta__dato(lista_opera_depende, depende|'0');
  }
  else
  {
   lista_ajunta__dato(lista_opera_depende, ' ');
  }
 }
 
 if(opera_desifri==0) //opera_ajusta
 {
  struct lista *lista_2=lista_nova(0);
  struct lista *lista_parametre=lista_nova(0);
  struct lista *lista_informa=lista_nova(0);
  n1 ajusta=((parola>>cpu_1664_bitio_opera)&((1<<cpu_1664_bitio_co)-1))+0x10;
  n1 opera=(parola>>(cpu_1664_bitio_opera+cpu_1664_bitio_co));
  lista_ajunta_asciiexadesimal__n1(lista_parametre, ajusta);
  lista_ajunta__dato(lista_parametre, ' ');
  if(opera<cpu->lista_dev_opera_cadena->contador/sizeof(P))
  {
   lista_ajunta__lista(lista_parametre, ((struct lista **)(cpu->lista_dev_opera_cadena->datos))[opera]);
  }
  else
  {
   lista_ajunta_asciiexadesimal__n1(lista_parametre, opera);
  }
  
  if(cpu->opera_ajusta[ajusta]<cpu->lista_dev_opera_cadena->contador/sizeof(P))
  {
   lista_ajunta__lista(lista_informa, ((struct lista **)(cpu->lista_dev_opera_cadena->datos))[cpu->opera_ajusta[ajusta]]);
  }
  else
  {
   lista_ajunta__ccadena(lista_informa, cadena_nd);
  }
  
  lista_ajunta__ccadena(lista_informa, " <- ");
  
  if(opera<cpu->lista_dev_opera_cadena->contador/sizeof(P))
  {
   lista_ajunta__lista(lista_informa, ((struct lista **)(cpu->lista_dev_opera_cadena->datos))[opera]);
  }
  else
  {
   lista_ajunta__ccadena(lista_informa, cadena_nd);
  }
  
  lista_ajunta__P(lista_2, (P)lista_parametre);
  lista_ajunta__P(lista_2, (P)lista_informa);
  lista_ajunta__P(lista_dev, (P)lista_2);
 }
 else
 {
  
  if(opera_desifri<cpu->lista_dev_opera_parametre_funsiona->contador/sizeof(P))
  {
   lista_ajunta__P(lista_dev, ((P (**)(struct cpu_1664 *, n1))(cpu->lista_dev_opera_parametre_funsiona->datos))[opera_desifri](cpu, parametre));
  }
  else
  {
   lista_ajunta__P(lista_dev, cpu_1664_dev_opera_parametre_funsiona__nd(cpu, parametre));
  }
 }
 
 return lista_dev;
}
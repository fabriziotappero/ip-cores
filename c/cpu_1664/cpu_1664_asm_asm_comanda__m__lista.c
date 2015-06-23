#include "cpu_1664.h"
#include <stdio.h>

void cpu_1664_asm_asm_comanda__m__lista(struct cpu_1664 *cpu, struct lista *lista_parametre)
{
 const n1 sinia_no_braso[] = {cpu_1664_asm_table_sinia};
 const n1 sinia_braso_clui[] = {cpu_1664_asm_table_clui};
 nN indise_limite=lista_parametre->contador/sizeof(P);
 struct lista *m=((struct lista **)(lista_parametre->datos))[0];
 nN indise_desloca;
 
 if(m->datos[0]!='{')
 {
  m=0;
  cpu_1664_asm_sinia_t sinia=cpu_1664_asm_sinia_t_sinia__cadena(((struct lista **)(lista_parametre->datos))[0]->datos,((struct lista **)(lista_parametre->datos))[0]->contador);
  indise_desloca=1;
  nN i;
  for(i=0;i<cpu->lista_model_sinia->contador/sizeof(cpu_1664_asm_sinia_t);i++)
  {
   
   if(((cpu_1664_asm_sinia_t *)(cpu->lista_model_sinia->datos))[i]==sinia)
   {
    m=((struct lista **)(cpu->lista_model->datos))[i];
   }
  }
 }
 else
 {
//  printf("\n* %s %s [%x] *\n",m->datos, ((struct lista **)(lista_parametre->datos))[1]->datos, m->contador);
  indise_desloca=1;
 }
 
 if(m!=0)
 {
  struct lista *lista;
  struct lista *lista_inisial=lista_nova(0);
  struct lista *lista_redise=lista_nova(0);
   
   
  lista=lista_inisial;
   
  nN k;
  n8 valua;
  nN indise;
  
  nN j=0;
  while(j<m->contador)
  {
    
   switch(m->datos[j])
   {
    default:
     lista_ajunta__dato(lista, m->datos[j++]);
     break;
     
    case '\\':
     j++;
     if(m->datos[j-2]!='\\')
     {
      lista_ajunta__dato(lista, m->datos[j++]);
     }
     break;
      
      
    case cpu_1664_asm_sinia_model:
     j++;
      
     switch(m->datos[j])
     {
      default:
       lista_ajunta__dato(lista, cpu_1664_asm_sinia_model);
       lista_ajunta__dato(lista, m->datos[j++]);
       break;

      case '@': //asm_desloca
       lista_ajunta__ccadena(lista, "0x");
       lista_ajunta_asciiexadesimal__n8(lista, cpu->lista_imaje_asm->contador);
       j++;
       break;
      
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
       indise=indise_desloca+m->datos[j]&0x0f;
       if(indise<indise_limite) { lista_ajunta__datos(lista, ((struct lista **)(lista_parametre->datos))[indise]->datos,((struct lista **)(lista_parametre->datos))[indise]->contador); }
       j++;
       break;
        
      case '{': //parametre sustitua
       k=nN_cuantia_brasetida__cadena(m->datos+j, m->datos[j], sinia_braso_clui[m->datos[j]]);
       indise=indise_desloca+cpu_1664_asm_n8_valua__cadena(cpu, m->datos+j, k);
       if(indise<indise_limite) { lista_ajunta__datos(lista, ((struct lista **)(lista_parametre->datos))[indise]->datos,((struct lista **)(lista_parametre->datos))[indise]->contador); }
       j+=k;
       break;
     }
     break;
   }
  }
  j=1;
  m=lista_inisial;
  lista=lista_redise;
  while(j<m->contador-1)
  {
    
   switch(m->datos[j])
   {
    default:
     lista_ajunta__dato(lista, m->datos[j++]);
     break;
     
    case cpu_1664_asm_sinia_model:
     j++;
      
     if(m->datos[j-2]!='\\')
     {
       
      switch(m->datos[j])
      {
       default:  //parametre sustitua
        indise=indise_desloca+m->datos[j]&0x0f;
        if(indise<indise_limite) { lista_ajunta__datos(lista, ((struct lista **)(lista_parametre->datos))[indise]->datos,((struct lista **)(lista_parametre->datos))[indise]->contador); }
        j++;
        break;
        
       case '-': //comenta si evalua no zero
        j++;
        k=nN_cuantia_brasetida__cadena(m->datos+j, m->datos[j], sinia_braso_clui[m->datos[j]]);
        valua=cpu_1664_asm_n8_valua__cadena(cpu, m->datos+j, k);
        if(valua!=0) { lista_ajunta__dato(lista, cpu_1664_asm_sinia_comenta); }
        j+=k;
        break;
         
       case '+': //comenta si evalua zero
        j++;
        k=nN_cuantia_brasetida__cadena(m->datos+j, m->datos[j], sinia_braso_clui[m->datos[j]]);
        valua=cpu_1664_asm_n8_valua__cadena(cpu, m->datos+j, k);
        if(valua==0) { lista_ajunta__dato(lista, cpu_1664_asm_sinia_comenta); }
        j+=k;
        break;
        
       case '>': //avansa 1 si evalua no zero
        j++;
        k=nN_cuantia_brasetida__cadena(m->datos+j, m->datos[j], sinia_braso_clui[m->datos[j]]);
        valua=cpu_1664_asm_n8_valua__cadena(cpu, m->datos+j, k);
        j+=k+(valua!=0);
        break;
        
       case '{': //parametre sustitua
        k=nN_cuantia_brasetida__cadena(m->datos+j, m->datos[j], sinia_braso_clui[m->datos[j]]);
        indise=indise_desloca+cpu_1664_asm_n8_valua__cadena(cpu, m->datos+j, k);
        if(indise<indise_limite) { lista_ajunta__datos(lista, ((struct lista **)(lista_parametre->datos))[indise]->datos,((struct lista **)(lista_parametre->datos))[indise]->contador); }
        j+=k;
        break;
      }
     }
     break;
   }
  }
  
//  if(((struct lista **)(lista_parametre->datos))[0]->datos[0]=='{') { printf("<%s>\n",lista->datos); }
  cpu_1664_asm_ajunta__cadena(cpu, lista->datos, lista->contador);
  lista_libri(lista_inisial);
  lista_libri(lista_redise);
 }
 
}
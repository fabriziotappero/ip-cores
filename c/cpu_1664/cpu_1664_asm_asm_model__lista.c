#include "cpu_1664.h"

void cpu_1664_asm_asm_model__lista(struct cpu_1664 *cpu, struct lista *model, struct lista *lista_parametre, nN indise_desloca)
{
 const n1 sinia_braso_clui[] = {cpu_1664_asm_table_clui};
 nN indise_limite=lista_parametre->contador/sizeof(P);

 if(model!=0)
 {
  struct lista *lista;
  struct lista *lista_inisial=lista_nova(256);
  struct lista *lista_redise=lista_nova(256);
   
   
  lista=lista_inisial;
   
  nN k;
  n8 valua;
  nN indise;
  
  nN j=0;
  while(j<model->contador)
  {
    
   switch(model->datos[j])
   {
    default:
     lista_ajunta__dato(lista, model->datos[j++]);
     break;
     
    case '\\':
     j++;
     if(model->datos[j-2]!='\\')
     {
      lista_ajunta__dato(lista, model->datos[j++]);
     }
     break;
      
      
    case cpu_1664_asm_sinia_model_opera:
     j++;
      
     switch(model->datos[j])
     {
      default:
       lista_ajunta__dato(lista, cpu_1664_asm_sinia_model_opera);
       lista_ajunta__dato(lista, model->datos[j++]);
       break;

      case '@': //asm_desloca
       lista_ajunta__ccadena(lista, "0x");
       lista_ajunta_asciiexadesimal__n8(lista, cpu->lista_imaje_asm->contador);
       j++;
       break;
      
      case 'c': //parametre contador
       lista_ajunta__ccadena(lista, "0x");
       lista_ajunta_asciiexadesimal__n8(lista, indise_limite-1);
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
       indise=indise_desloca+(model->datos[j]&0x0f);
       if(indise<indise_limite) { lista_ajunta__datos(lista, ((struct lista **)(lista_parametre->datos))[indise]->datos,((struct lista **)(lista_parametre->datos))[indise]->contador); }
       j++;
       break;
        
      case '{': //parametre sustitua
       k=nN_cuantia_brasetida__cadena(model->datos+j, model->datos[j], sinia_braso_clui[model->datos[j]]);
       indise=indise_desloca+cpu_1664_asm_n8_valua__cadena(cpu, model->datos+j, k);
       if(indise<indise_limite) { lista_ajunta__datos(lista, ((struct lista **)(lista_parametre->datos))[indise]->datos,((struct lista **)(lista_parametre->datos))[indise]->contador); }
       j+=k;
       break;
     }
     break;
   }
  }
  j=1;
  model=lista_inisial;
  lista=lista_redise;
  while(j<model->contador-1)
  {
    
   switch(model->datos[j])
   {
    default:
     lista_ajunta__dato(lista, model->datos[j++]);
     break;
     
    case cpu_1664_asm_sinia_model_opera:
     j++;
      
     if(model->datos[j-2]!='\\')
     {
       
      switch(model->datos[j])
      {
       default:  //parametre sustitua
        indise=indise_desloca+(model->datos[j]&0x0f);
        if(indise<indise_limite) { lista_ajunta__datos(lista, ((struct lista **)(lista_parametre->datos))[indise]->datos,((struct lista **)(lista_parametre->datos))[indise]->contador); }
        j++;
        break;
        
       case '-': //comenta si evalua no zero
        j++;
        k=nN_cuantia_brasetida__cadena(model->datos+j, model->datos[j], sinia_braso_clui[model->datos[j]]);
        valua=cpu_1664_asm_n8_valua__cadena(cpu, model->datos+j, k);
        if(valua!=0) { lista_ajunta__dato(lista, cpu_1664_asm_sinia_comenta); }
        j+=k;
        break;
         
       case '+': //comenta si evalua zero
        j++;
        k=nN_cuantia_brasetida__cadena(model->datos+j, model->datos[j], sinia_braso_clui[model->datos[j]]);
        valua=cpu_1664_asm_n8_valua__cadena(cpu, model->datos+j, k);
        if(valua==0) { lista_ajunta__dato(lista, cpu_1664_asm_sinia_comenta); }
        j+=k;
        break;
        
       case '>': //avansa 1 si evalua no zero
        j++;
        k=nN_cuantia_brasetida__cadena(model->datos+j, model->datos[j], sinia_braso_clui[model->datos[j]]);
        valua=cpu_1664_asm_n8_valua__cadena(cpu, model->datos+j, k);
        j+=k+(valua!=0);
        break;
       
       case '.':
        j++;
        k=nN_cuantia_brasetida__cadena(model->datos+j, model->datos[j], sinia_braso_clui[model->datos[j]]);
        valua=cpu_1664_asm_n8_valua__cadena(cpu, model->datos+j, k);
        if(valua!=0) 
        { 
         j=model->contador; 
        }
        else
        {
         j+=k;
        }
        break;
        
       case '!':
        j++;
        k=nN_cuantia_brasetida__cadena(model->datos+j, model->datos[j], sinia_braso_clui[model->datos[j]]);
        valua=cpu_1664_asm_n8_valua__cadena(cpu, model->datos+j, k);
        j+=k;
        while(model->datos[j]!='"') { j++; }
        k=nN_cuantia_brasetida__cadena(model->datos+j, model->datos[j], sinia_braso_clui[model->datos[j]]);
        
        if(valua!=0) 
        { 
         cpu->asm_eror=1;
         cadena__f((P)scrive_stdout,"%*s\n", k-2, model->datos+j+1);
         j=model->contador; 
        }
        else
        {
         j+=k;
        }
        break;
       
       case 'I': //informa
        j++;
        while(model->datos[j]!='"') { j++; }
        k=nN_cuantia_brasetida__cadena(model->datos+j, model->datos[j], sinia_braso_clui[model->datos[j]]);
        cadena__f((P)scrive_stdout,"%*s\n", k-2, model->datos+j+1);
        j+=k;
        break;
       
       case '{': //parametre sustitua
        k=nN_cuantia_brasetida__cadena(model->datos+j, model->datos[j], sinia_braso_clui[model->datos[j]]);
        indise=indise_desloca+cpu_1664_asm_n8_valua__cadena(cpu, model->datos+j, k);
        if(indise<indise_limite) { lista_ajunta__datos(lista, ((struct lista **)(lista_parametre->datos))[indise]->datos,((struct lista **)(lista_parametre->datos))[indise]->contador); }
        j+=k;
        break;
      }
     }
     break;
   }
  }
  
  cpu_1664_asm_ajunta__cadena(cpu, lista->datos, lista->contador);
  lista_libri(lista_inisial);
  lista_libri(lista_redise);
 }
 
}
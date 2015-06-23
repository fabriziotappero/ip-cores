#include "cpu_1664.h"

void cpu_1664_asm_ajunta__cadena(struct cpu_1664 *cpu, n1 *cadena, nN cuantia)
{
 const n1 sinia_braso_clui[] = {cpu_1664_asm_table_clui};
 const n1 sinia_braso_inclui[] ={cpu_1664_asm_table_sinia_inclui_brasos};
 struct lista *lista_parametre;
 n1 *fini=cadena+cuantia;
 n1 *cadena_;
 struct lista *lista_eticeta_cadena;
 nN i;
 struct lista *model_cadena;
 cpu_1664_asm_sinia_t sinia;
 
 while(cadena<fini)
 {
  
  if(cpu->asm_eror!=0)
  {
   break;
  }
  
  cpu->asm_eror=0;
  
  switch(*cadena)
  {
   default:
    lista_parametre=cpu_1664_asm_lista_parametre__cadena(cadena);
    sinia=cpu_1664_asm_sinia_t_sinia__cadena(((struct lista **)(lista_parametre->datos))[0]->datos,((struct lista **)(lista_parametre->datos))[0]->contador);
    
    for(model_cadena=0, i=0;i<cpu->lista_model_sinia->contador/sizeof(cpu_1664_asm_sinia_t);i++)
    {
   
     if(((cpu_1664_asm_sinia_t *)(cpu->lista_model_sinia->datos))[i]==sinia)
     {
      model_cadena=((struct lista **)(cpu->lista_model->datos))[i]; break;
     }
    }
  
    if(model_cadena!=0)
    {
     cpu_1664_asm_asm_model__lista(cpu, model_cadena, lista_parametre, 1);
     
     while((*cadena!=cpu_1664_asm_sinia_fini)&&(*(cadena-1)!='\\')&&(cadena<fini)) 
     { 
     
      switch(*cadena)
      {
       default:
        cadena++; 
        break;
      
       case '"':
       case '[':
       case '(':
       case '{':
        cadena+=nN_cuantia_brasetida__cadena(cadena, *cadena, sinia_braso_clui[*cadena]);
        break;
      }
     }
    }
    else
    {
     cpu_1664_asm_asm_opera__lista_2(cpu, lista_parametre);
     while((*cadena!=cpu_1664_asm_sinia_fini)&&(cadena<fini)) { cadena++; }
    }
    
    lista_2_libri(lista_parametre);
    break;
   
   case cpu_1664_asm_sinia_comenta:
    while((*cadena!=cpu_1664_asm_sinia_fini)&&(cadena<fini)) { cadena++; }
    break;
   
   //case 0x0a:
   case cpu_1664_asm_sinia_fini:
   case 0x09:
   case ' ':
    cadena++;
    break;
   
   case cpu_1664_asm_sinia_opera:
    cadena++;
    cpu_1664_asm_asm_opera__cadena(cpu, cadena);
    while((*cadena!=cpu_1664_asm_sinia_fini)&&(cadena<fini)) { cadena++; }
    break;
   
   case cpu_1664_asm_sinia_eticeta:
    cadena_=++cadena;
    while((sinia_braso_inclui[*cadena]==1)&&(cadena<fini)) { cadena++; }
    cpu_1664_asm_defina_valua(cpu, cpu_1664_asm_sinia_t_sinia__cadena(cadena_,cadena-cadena_), cpu->lista_imaje_asm->contador);
    lista_libri(cpu->lista_eticeta_cadena);
    cpu->lista_eticeta_cadena=lista_nova__datos(cadena_, cadena-cadena_);
    break;
      
   case cpu_1664_asm_sinia_eticeta_su:
    cadena_=cadena;
    while((sinia_braso_inclui[*cadena]==1)&&(cadena<fini)) { cadena++; }
    lista_eticeta_cadena=lista_nova__lista(cpu->lista_eticeta_cadena);
    lista_ajunta__datos(lista_eticeta_cadena, cadena_, cadena-cadena_);
    cpu_1664_asm_defina_valua(cpu, cpu_1664_asm_sinia_t_sinia__cadena(lista_eticeta_cadena->datos, lista_eticeta_cadena->contador), cpu->lista_imaje_asm->contador);
    lista_libri(lista_eticeta_cadena);
    break;
   
   case '{': //pasaladal ".m"
    cpu_1664_asm_asm_comanda__m(cpu, cadena);
    cadena+=nN_cuantia_brasetida__cadena(cadena, *cadena, sinia_braso_clui[*cadena]);
    
    while((*cadena!=cpu_1664_asm_sinia_fini)&&(*(cadena-1)!='\\')&&(cadena<fini)) 
    { 
     
     switch(*cadena)
     {
      default:
       cadena++; 
       break;
      
      case '"':
      case '[':
      case '(':
      case '{':
       cadena+=nN_cuantia_brasetida__cadena(cadena, *cadena, sinia_braso_clui[*cadena]);
       break;
     }
    }
    break;
   
   case cpu_1664_asm_sinia_comanda:
    cpu_1664_asm_asm_comanda(cpu, cadena+1);
    
    while((*cadena!=cpu_1664_asm_sinia_fini)&&(*(cadena-1)!='\\')&&(cadena<fini)) 
    { 
     
     switch(*cadena)
     {
      default:
       cadena++; 
       break;
      
      case '"':
      case '[':
      case '(':
      case '{':
       cadena+=nN_cuantia_brasetida__cadena(cadena, *cadena, sinia_braso_clui[*cadena]);
       break;
     }
    }
    break;
   
  }
 }
// taxe
 if(cpu->lista_taxe->contador!=0)
 {
  nN i;
  cpu_1664_sinia_t desloca_;
  struct lista *lista_taxe_=lista_nova(0);
  struct cpu_1664_asm_taxe *taxe;
  for(i=0;i<cpu->lista_taxe->contador/sizeof(P);i++)
  {
   cpu->avisa__no_definida=0;
   taxe=((struct cpu_1664_asm_taxe *)((struct lista **)(cpu->lista_taxe->datos))[i]);
   desloca_=cpu->lista_imaje_asm->contador;
   cpu->lista_imaje_asm->contador=taxe->desloca;
   taxe->parola=(taxe->parola&0xff)|taxe->asm_opera_parametre_funsiona(cpu, taxe->lista)<<8;
   *((cpu_1664_opera_t *)(cpu->lista_imaje_asm->datos+taxe->desloca))=taxe->parola;
   if(cpu->avisa__no_definida!=0)
   {
//    cadena__f((P)scrive_stdout, "avisa : taxe [%.*x] no definida\n",8,taxe->desloca);
    lista_ajunta__P(lista_taxe_, (P)taxe);
   }
   else
   { 
    lista_2_libri(taxe->lista);
    memoria_libri((P)taxe);
   }
   cpu->lista_imaje_asm->contador=desloca_;
  }
  lista_libri(cpu->lista_taxe);
  cpu->lista_taxe=lista_taxe_;
 }
 
// taxe_d
 if(cpu->lista_taxe_d->contador!=0)
 {
  struct lista *lista_taxe_d_=lista_nova(0);
  struct cpu_1664_asm_taxe_d *taxe_d;
  cpu_1664_sinia_t valua[1];
  nN i,j;
  for(i=0;i<cpu->lista_taxe_d->contador/sizeof(P);i++)
  {
   cpu->avisa__no_definida=0;
   taxe_d=((struct cpu_1664_asm_taxe_d *)((struct lista **)(cpu->lista_taxe_d->datos))[i]);
   valua[0]=cpu_1664_asm_n8_valua__lista(cpu, taxe_d->lista);
   
   for(j=0;j<taxe_d->cuantia;j++)
   {
    ((n1 *)(cpu->lista_imaje_asm->datos+taxe_d->desloca))[j]=((n1 *)(valua))[j];
   }
   
   if(cpu->avisa__no_definida!=0)
   {
//    cadena__f((P)scrive_stdout, "avisa : taxe_d [%.*x] no definida\n",8,taxe_d->desloca);
    lista_ajunta__P(lista_taxe_d_, (P)taxe_d);
   }
   else
   {
    lista_libri(taxe_d->lista);
    memoria_libri((P)taxe_d);
   }
  }
  lista_libri(cpu->lista_taxe_d);
  cpu->lista_taxe_d=lista_taxe_d_;
 }
}

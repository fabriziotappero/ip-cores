#include "cpu_1664.h"

SPR_t cpu_1664_asm_n8_valua__cadena(struct cpu_1664 *cpu, n1 *cadena, nN cuantia)
{
 const n1 sinia_no_braso[] = {cpu_1664_asm_table_sinia};
 const n1 sinia_braso_clui[] = {cpu_1664_asm_table_clui};
 SPR_t valua=0;
 cpu_1664_asm_sinia_t sinia;
 nN i;
 n1 bool_negativa=0;
 n1 loca=0;
 SPR_t masca=-1;
 struct lista *lista;
 nN bitio_masca;
 
 if(*cadena=='-')
 {
  bool_negativa=1;
  cadena++;
  cuantia--;
 }

 n1 *fini=cadena+cuantia;
 nN cuantia_braso;
 nN j,k;
 struct lista *pila;
 nN evalua_braso_cuantia;
 SPR_t f,f0,f1;
 SPR_t e0,e1;
 n1 *cadena_;
 while(cadena<fini)
 {
 
 switch(*cadena)
 {
  case 0x09:
  case ' ':
   cadena++;
   break;
  
  case '\"':
   cuantia_braso=nN_cuantia_brasetida__cadena(cadena, *cadena, sinia_braso_clui[*cadena]);
   cadena+=cuantia_braso;
   break;
  
  case '{': //simboles polsce reversa
   pila=lista_nova(sizeof(SPR_t)*8);
   evalua_braso_cuantia=nN_cuantia_brasetida__cadena(cadena, *cadena, sinia_braso_clui[*cadena]);
   
   for(j=1;j<(evalua_braso_cuantia-1);j++)
   {
    
    switch(cadena[j])
    {
     default:
      cadena_=cadena+j;
      while(sinia_no_braso[cadena[j]]!=0){ j++; }
      f=cpu_1664_asm_n8_valua__cadena(cpu, cadena_,(cadena+j)-cadena_);
      lista_ajunta__SPR_t(pila, f);
      break;
     
     case 0x09:
     case ' ':
      break;
     
     case '{':
      k=nN_cuantia_brasetida__cadena(cadena+j, cadena[j], sinia_braso_clui[*cadena]);
      f=cpu_1664_asm_n8_valua__cadena(cpu, cadena+j, k);
      lista_ajunta__SPR_t(pila, f);
      j+=k;
      break;
      
     case '.':
      
      switch(cadena[++j])
      {
       case '-': //negativa
        if((pila->contador/sizeof(SPR_t))>=1)
        {
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1]=-((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
        }
        j++;
        break;
       
       case '+': //asoluta
        if((pila->contador/sizeof(SPR_t))>=1)
        {
         f0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         if(f0<0.0) { ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1]=-f0; }
        }
        j++;
        break;
       
       case '/': //invertida
        if((pila->contador/sizeof(SPR_t))>=1)
        {
         f0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1]=1.0/f0;
        }
        j++;
        break;
       
       case 'd': //dupli
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         f0=(((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1])+1;
         if((pila->contador/sizeof(SPR_t))>=f0)
         {
          ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1]=((SPR_t *)(pila->datos))[f0];
         }
        }
        j++;
        break;
       
       case 'x': //intercambia
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         f1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         f0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=f0;
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1]=f1;
        }
        j++;
        break;
       
       case '<': //cade
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         f0=(((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1])+1;
         if((pila->contador/sizeof(SPR_t))>=f0)
         {
          pila->contador-=sizeof(SPR_t)*f0;
         }
        }
        j++;
        break;
       
       default:
        //zero funsiona
        break;
      }
      break;
     
     case '>':
      switch(cadena[++j])
      {
       case '>': //loca
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         e1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         e0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         e1>>=e0;
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=e1;
         pila->contador-=sizeof(SPR_t);
        }
        j++;
        break;
       
       case '=': //lojica
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         f1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         f0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=f1>=f0;
         pila->contador-=sizeof(SPR_t);
        }
        break;
       
       default: //lojica
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         f1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         f0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=f1>f0;
         pila->contador-=sizeof(SPR_t);
        }
        break;
      }
      break;
     
     case '<':
      switch(cadena[++j])
      {
       case '<': //loca
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         e1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         e0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         e1<<=e0;
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=e1;
         pila->contador-=sizeof(SPR_t);
        }
        j++;
        break;
       
       case '=': //lojica
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         f1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         f0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=f1<=f0;
         pila->contador-=sizeof(SPR_t);
        }
        break;
       
       default: //lojica
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         f1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         f0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=f1<f0;
         pila->contador-=sizeof(SPR_t);
        }
        break;
      }
      break;
     
     case '&':
      switch(cadena[++j])
      {
       default: //bitio
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         e1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         e0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         e1&=e0;
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=e1;
         pila->contador-=sizeof(SPR_t);
        }
        break;
       
       case '&': //lojica
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         e1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         e0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         e1=(SPR_t)e1&&(SPR_t)e0;
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=e1;
         pila->contador-=sizeof(SPR_t);
        }
        j++;
        break;
      }
      break;
     
     case '|':
      switch(cadena[++j])
      {
       default: //bitio
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         e1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         e0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         e1|=e0;
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=e1;
         pila->contador-=sizeof(SPR_t);
        }
        break;
       
       case '|': //lojica
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         e1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         e0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         e1=(SPR_t)e1||(SPR_t)e0;
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=e1;
         pila->contador-=sizeof(SPR_t);
        }
        j++;
        break;
      }
      break;
     
     case '!':
      switch(cadena[++j])
      {
      
       case '=': //lojica
        if((pila->contador/sizeof(SPR_t))>=2)
        {
         f1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
         f0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
         ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=f1!=f0;
         pila->contador-=sizeof(SPR_t);
        }
        break;
 
      }
      break;
     
     case '=': //lojica
      if((pila->contador/sizeof(SPR_t))>=2)
      {
       f1=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2];
       f0=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
       ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]=(f1==f0);
       pila->contador-=sizeof(SPR_t);
      }
      break;
     
     case '+':
      if((pila->contador/sizeof(SPR_t))>=2)
      {
       ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]+=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
       pila->contador-=sizeof(SPR_t);
      }
      j++;
      break;
     
     case '-':
      if(sinia_no_braso[cadena[j+1]]==1)
      {
       cadena_=cadena+j;
       while(sinia_no_braso[cadena[j]]==1) { j++; }
       f=cpu_1664_asm_n8_valua__cadena(cpu, cadena_,(cadena+j)-cadena_);
       lista_ajunta__SPR_t(pila, f);
      }
      else
      {
       if((pila->contador/sizeof(SPR_t))>=2)
       {
        ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]-=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
        pila->contador-=sizeof(SPR_t);
       }
       j++;
      }
      break;
     
     case '*':
      if((pila->contador/sizeof(SPR_t))>=2)
      {
       ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]*=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
       pila->contador-=sizeof(SPR_t);
      }
      j++;
      break;
     
     case '/':
      if((pila->contador/sizeof(SPR_t))>=2)
      {
       ((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-2]/=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
       pila->contador-=sizeof(SPR_t);
      }
      j++;
      break;
     
    }
   }
   if(pila->contador!=0)
   {
    valua=((SPR_t *)(pila->datos))[(pila->contador/sizeof(SPR_t))-1];
   }
   cadena+=evalua_braso_cuantia;
   lista_libri(pila);
   break;
  
  case '(':
   cuantia_braso=nN_cuantia_brasetida__cadena(cadena, *cadena, sinia_braso_clui[*cadena]);
   valua=cpu_1664_asm_n8_valua__cadena(cpu, cadena+1, cuantia_braso-2);
   cadena+=cuantia_braso;
   break;
  
  case '}': // dev
  case ']': // dev
  case ')':
   cadena++;
   break;
  
  case '[':
   cuantia_braso=nN_cuantia_brasetida__cadena(cadena, *cadena, sinia_braso_clui[*cadena]);
   lista=cpu_1664_asm_lista_parametre__cadena(cadena+1);
   bitio_masca=8;
   
   if((lista->contador/sizeof(P)>0)&&(lista->contador/sizeof(P)<3))
   {
    loca=cpu_1664_asm_n8_valua__cadena(cpu, ((struct lista **)(lista->datos))[0]->datos,((struct lista **)(lista->datos))[0]->contador);
    if((lista->contador/sizeof(P)>1)) bitio_masca=cpu_1664_asm_n8_valua__cadena(cpu, ((struct lista **)(lista->datos))[1]->datos,((struct lista **)(lista->datos))[1]->contador);
    masca=(1<<bitio_masca)-1;
   }
    
   lista_2_libri(lista);
   
   cadena+=cuantia_braso;
   break;
  
  case '0':
   
   if(*(cadena+1)=='x')
   {
    nN j;
    cadena+=2;
    for(j=0;(sinia_no_braso[cadena[j]]==1)&&((cadena+j)<fini);j++){}
    valua=n8__exadesimal_cadena(cadena, j);
    cadena+=j;
    break;
   }
   else if (cuantia>1)
   {
    //octal
   }
  case '1' ... '9':
   for(j=1;(sinia_no_braso[cadena[j]]==1)&&((cadena+j)<fini);j++){}
   valua=n8__desimal_cadena(cadena, j);
   cadena+=j;
   break;
  
  default:
   for(j=0;(sinia_no_braso[cadena[j]]==1)&&((cadena+j)<fini);j++){}
   sinia=cpu_1664_asm_sinia_t_sinia__cadena(cadena, j);
   cadena+=j;
   
   for(i=0;i<(cpu->lista_defina_sinia->contador/sizeof(cpu_1664_asm_sinia_t));i++)
   {
   
    if(((cpu_1664_asm_sinia_t *)(cpu->lista_defina_sinia->datos))[i]==sinia)
    {
     valua=((cpu_1664_sinia_t *)(cpu->lista_defina_valua->datos))[i];
     break;
    }
   
   }
    
   if (i>=(cpu->lista_defina_sinia->contador/sizeof(cpu_1664_asm_sinia_t))) 
   { 
    cpu->avisa__no_definida=1;
   }
  
   break;
 }
 }
 
 if(bool_negativa!=0)
 {
  valua=(-valua);
 }
 
 valua=(valua>>loca)&masca;
 return valua;
}
#include "cpu_1664.h"

n1 cpu_1664_asm_opera_parametre_funsiona__8y(struct cpu_1664 * cpu, struct lista *lista)
{
 n8 desloca=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista->datos))[(lista->contador/sizeof(P))-1]);
 n1 c=((struct lista **)(lista->datos))[(lista->contador/sizeof(P))-1]->datos[0];
 
 if(((c>'9')||(c<'0'))&&(c!='-'))
 {
  
  if(desloca>=cpu->lista_imaje_asm->contador)
  {
   desloca-=cpu->lista_imaje_asm->contador;
   
   if((desloca&0x01)!=0)
   {
    if(cpu->avisa__no_definida==0) 
    {
     cadena__f((P)scrive_stdout, "avisa : \"desloca no alinia [%*x]\"\n",8,cpu->lista_imaje_asm->contador);
     cpu->asm_eror=1;
    }
   }
   
   desloca>>=1;
   
   if(desloca>=0x80)
   {
    if(cpu->avisa__no_definida==0) 
    {
     cadena__f((P)scrive_stdout, "avisa : \"desloca plu masima [%*x]\"\n",8,cpu->lista_imaje_asm->contador);
     cpu->asm_eror=1;
    }
   }
  }
  else
  {
   desloca-=cpu->lista_imaje_asm->contador;
   
   if((desloca&0x01)!=0)
   {
    if(cpu->avisa__no_definida==0) 
    {
     cadena__f((P)scrive_stdout, "avisa : \"desloca no alinia [%*x]\"\n",8,cpu->lista_imaje_asm->contador);
     cpu->asm_eror=1;
    }
   }
   
   desloca=(desloca>>1)&0xff;
   
   if(desloca<0x80)
   {
    if(cpu->avisa__no_definida==0) 
    {
     cadena__f((P)scrive_stdout, "avisa : \"desloca plu masima [%*x]\"\n",8,cpu->lista_imaje_asm->contador);
     cpu->asm_eror=1;
    }
   }
  }
 }
 
 n1 bait=desloca;
 return bait;
}
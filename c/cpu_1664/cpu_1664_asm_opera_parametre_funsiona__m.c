#include "cpu_1664.h"

n1 cpu_1664_asm_opera_parametre_funsiona__m(struct cpu_1664 *cpu, struct lista *lista)
{
 
 const n1 sinia_m[] = {cpu_1664_asm_table_sinia_m};
 
 struct lista *m;
 nN lista_cuantia=lista->contador/sizeof(P);
 nN indise_m;
 n1 bitio_ajusta=0;
 n1 bitio_estende=0;
 n1 bitio_ordina=0;
 n1 bitio_orienta=0;
 nN estende;
 nN Ar=-1;
 
 if(lista_cuantia==0)
 {
  cadena__f((P)scrive_stdout, "eror ylr -\n");
  cpu->asm_eror=1;
  return 0;
 }
 else
 {
 
  if((((struct lista **)(lista->datos))[lista_cuantia-1])->datos[0]!='[')
  {
   estende=cpu_1664_asm_n8_valua__lista(cpu,((struct lista **)(lista->datos))[lista_cuantia-1]);
   indise_m=lista_cuantia-2;
  }
  else
  {
   estende=sizeof(cpu_1664_sinia_t);
   indise_m=lista_cuantia-1;
  }

  m=((struct lista **)(lista->datos))[indise_m];
  nN i=1;
  nN j;
  while(m->datos[i]!=']')
  {
   
   switch(m->datos[i])
   {
    default:
     if(bitio_ajusta==0) bitio_ordina=1;
     for(j=0; sinia_m[m->datos[i+j]]==1; j++) { }
     Ar=(cpu_1664_asm_n8_valua__cadena(cpu, m->datos+i, j));
     i+=j;
     break;
    
    case '+':
     bitio_ajusta=1;
     bitio_orienta=1;
     i++;
     break;
    
    case '-':
     bitio_ajusta=1;
     i++;
     break;
    
    case ',':
    case 0x09:
    case ' ':
     i++;
     break; 
   }
  }
  
  if(bitio_ajusta==0)
  {
   bitio_orienta=0;
   bitio_ordina=0;
  }
  
  switch(estende)
  {
   default:
    bitio_estende=4;
    break; 
  
   case 8:
    bitio_estende=3;
    break;
  
   case 4:
    bitio_estende=2;
    break;
  
   case 2:
    bitio_estende=1;
    break;
  
   case 1:
    bitio_estende=0;
    break;
  }
 
  if((Ar>=(1<<cpu_1664_opera_ldm_sinia))||(bitio_estende>3))
  {
   cadena__f((P)scrive_stdout, "eror ylr [%x] %x\n",Ar,1<<bitio_estende);
   cpu->asm_eror=1;
   return 0;
  }
  else
  {
   n1 bait= Ar|(bitio_estende<<cpu_1664_opera_ldm_bitio_estende0)|\
        (bitio_ajusta<<cpu_1664_opera_ldm_bitio_ajusta)|\
        (bitio_ordina<<cpu_1664_opera_ldm_bitio_ordina)|\
        (bitio_orienta<<cpu_1664_opera_ldm_bitio_orienta);
 
   return bait; 
  }
 }
}

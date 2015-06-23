#include "cpu_1664.h"

n1 cpu_1664_asm_n1_opera_valua__lista(struct cpu_1664 *cpu, struct lista *lista)
{
 n1 opera=0xff;
 cpu_1664_asm_sinia_t sinia_opera=cpu_1664_asm_sinia_t_sinia__cadena(lista->datos,lista->contador);
 
 nN i;
 for(i=0;i<(cpu->lista_opera_sinia->contador/sizeof(cpu_1664_asm_sinia_t));i++)
 {
  if(((cpu_1664_asm_sinia_t *)(cpu->lista_opera_sinia->datos))[i]==sinia_opera)
  {
   opera=i;
   break;
  }
 }
 
 return opera; 
}
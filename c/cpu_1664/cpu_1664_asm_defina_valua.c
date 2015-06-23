#include "cpu_1664.h"

void cpu_1664_asm_defina_valua(struct cpu_1664 *cpu, cpu_1664_asm_sinia_t sinia, cpu_1664_sinia_t valua)
{
 nN i=0;
 
 for(i=0;i<(cpu->lista_defina_valua->contador/sizeof(nN));i++)
 {
  
  if(((cpu_1664_asm_sinia_t *)(cpu->lista_defina_sinia->datos))[i]==sinia)
  {
   ((cpu_1664_sinia_t *)(cpu->lista_defina_valua->datos))[i]=valua;
   return;
  }
 }
 
 lista_ajunta__cpu_1664_asm_sinia_t(cpu->lista_defina_sinia, sinia);
 lista_ajunta__cpu_1664_sinia_t(cpu->lista_defina_valua, valua);
}
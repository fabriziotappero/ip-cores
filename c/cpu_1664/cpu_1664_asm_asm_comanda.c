#include "cpu_1664.h"

void cpu_1664_asm_asm_comanda(struct cpu_1664 *cpu, n1 *cadena)
{
 const n1 sinia[] = {cpu_1664_asm_table_sinia};
 
 nN i=0;
 while(sinia[*(n1 *)(cadena+i)]==1){ i++; }
 cpu_1664_asm_sinia_t comanda_sinia = cpu_1664_asm_sinia_t_sinia__cadena(cadena, i);
 cadena+=i;
  
 for(i=0;i<(cpu->lista_asm_comanda_funsiona->contador/sizeof(P));i++)
 {
  
  if (((cpu_1664_asm_sinia_t *)(cpu->lista_asm_comanda_sinia->datos))[i]==comanda_sinia)
  {
   ((void (**)(struct cpu_1664 *,n1 *)) (cpu->lista_asm_comanda_funsiona->datos))[i](cpu,cadena);
  }
 }
 
}
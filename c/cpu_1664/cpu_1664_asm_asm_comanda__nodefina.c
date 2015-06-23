#include "cpu_1664.h"

void cpu_1664_asm_asm_comanda__nodefina(struct cpu_1664 *cpu, n1 *cadena)
{
 struct lista *lista_parametre=cpu_1664_asm_lista_parametre__cadena(cadena);
 cpu_1664_asm_sinia_t sinia=cpu_1664_asm_sinia_t_sinia__cadena(((struct lista **)(lista_parametre->datos))[0]->datos,((struct lista **)(lista_parametre->datos))[0]->contador);
 
 nN i;
 for(i=0;i<(cpu->lista_defina_valua->contador/sizeof(nN));i++)
 {
  
  if(((cpu_1664_asm_sinia_t *)(cpu->lista_defina_sinia->datos))[i]==sinia)
  {
   ((cpu_1664_asm_sinia_t *)(cpu->lista_defina_sinia->datos))[i]=0;
   ((cpu_1664_sinia_t *)(cpu->lista_defina_valua->datos))[i]=0;
   return;
  }
 }
 
 lista_2_libri(lista_parametre);
}
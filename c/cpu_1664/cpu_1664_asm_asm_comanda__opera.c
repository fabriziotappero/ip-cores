#include "cpu_1664.h"

void cpu_1664_asm_asm_comanda__opera(struct cpu_1664 *cpu, n1 *cadena)
{
 struct lista *lista_parametre=cpu_1664_asm_lista_parametre__cadena(cadena);
 lista_ajunta__cpu_1664_asm_sinia_t(cpu->lista_opera_sinia, cpu_1664_asm_sinia_t_sinia__cadena(((struct lista **)(lista_parametre->datos))[0]->datos,((struct lista **)(lista_parametre->datos))[0]->contador));
 cpu_1664_asm_sinia_t opera_parametre_funsiona_sinia=cpu_1664_asm_sinia_t_sinia__cadena(((struct lista **)(lista_parametre->datos))[1]->datos,((struct lista **)(lista_parametre->datos))[1]->contador);
 struct lista *lista_opera_cadena=lista_nova__datos(((struct lista **)(lista_parametre->datos))[0]->datos,((struct lista **)(lista_parametre->datos))[0]->contador);
 lista_ajunta__P(cpu->lista_dev_opera_cadena, lista_opera_cadena);
 
 nN i;
 for(i=0;i<(cpu->lista_asm_opera_parametre_referi->contador/sizeof(P));i++)
 {
  
  if(((cpu_1664_asm_sinia_t *)(cpu->lista_opera_parametre_sinia->datos))[i]==opera_parametre_funsiona_sinia)
  {
   lista_ajunta__P(cpu->lista_asm_opera_parametre_funsiona, ((P *)(cpu->lista_asm_opera_parametre_referi->datos))[i]);
   lista_ajunta__P(cpu->lista_dev_opera_parametre_funsiona, ((P *)(cpu->lista_dev_opera_parametre_referi->datos))[i]);
   break;
  }
 }
 
 lista_2_libri(lista_parametre);
}
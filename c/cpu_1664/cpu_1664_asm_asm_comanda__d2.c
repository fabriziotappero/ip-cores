#include "cpu_1664.h"

void cpu_1664_asm_asm_comanda__d2(struct cpu_1664 *cpu, n1 *cadena)
{
 struct lista *lista=cpu_1664_asm_lista_parametre__cadena(cadena);
 n8 valua;
 
 nN i;
 for(i=0;i<lista->contador/sizeof(P);i++)
 {
  cpu->avisa__no_definida=0;
  valua=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista->datos))[i]);
  
  if(cpu->avisa__no_definida!=0)
  {
   cpu_1664_asm_taxe_d_ajunta(cpu, ((struct lista **)(lista->datos))[i], sizeof(n2));
  }
  
  lista_ajunta__n2(cpu->lista_imaje_asm, valua);
 }
 
 lista_2_libri(lista);
}